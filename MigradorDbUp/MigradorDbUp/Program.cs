using DbUp;
using DbUp.Engine;  // SqlScript
using Microsoft.Data.SqlClient;
using System.Diagnostics;

class Program
{
    static int Main()
    {
        // === CONFIG BÁSICA (fallback local) ===
        var server = @".\SQLEXPRESS";
        var dbName = "migraciondb";
        var targetCs = $@"Data Source={server};Initial Catalog={dbName};
                          Integrated Security=True;Encrypt=True;TrustServerCertificate=True;Connect Timeout=5";

        // Si hay variable de entorno, úsala (pipeline/script); si no, usa SQLEXPRESS local
        var envCs = Environment.GetEnvironmentVariable("CONNECTION_STRING");
        var effectiveCs = string.IsNullOrWhiteSpace(envCs) ? targetCs : envCs;

        var masterCs = BuildMasterConnectionString(effectiveCs);

        // Log básico
        var prev = Console.ForegroundColor;
        Console.ForegroundColor = ConsoleColor.Green;
        Console.WriteLine($"{DateTimeOffset.Now:yyyy-MM-dd HH:mm:ss zzz} [INF] Master ConnectionString => {MaskPassword(masterCs)}");
        Console.ForegroundColor = prev;

        // Asegura que exista la BD (SQL Server)
        EnsureDatabase.For.SqlDatabase(effectiveCs);

        // === FLAGS ===
        var argsList = Environment.GetCommandLineArgs().Skip(1).ToArray();
        bool onlyRollback = argsList.Any(a => a.Equals("--rollback", StringComparison.OrdinalIgnoreCase));
        bool includeRollback = argsList.Any(a => a.Equals("--include-rollback", StringComparison.OrdinalIgnoreCase));
        bool ciMode = argsList.Any(a => a.Equals("--ci", StringComparison.OrdinalIgnoreCase))
                              || !string.IsNullOrWhiteSpace(Environment.GetEnvironmentVariable("CI"));

        if (onlyRollback)
            Console.WriteLine("[INF] MODO ROLLBACK ACTIVADO (solo carpeta 3Rollback).");
        if (includeRollback && !onlyRollback)
            Console.WriteLine("[INF] INCLUDE-ROLLBACK (se ejecuta forward y luego 3Rollback).");
        if (ciMode)
            Console.WriteLine("[INF] CI mode ON (sin ReadKey).");

        // === Ubicar carpetas ===
        var dir1 = FindDir("1Creacion_Tablas");
        var dir2 = FindDir("2Insertar_Data");
        var dir3 = FindDir("3Rollback");
        var dir4 = FindDir("3modificar");
        var dir5 = FindDir("4Migrar_Data");

        // === Armar lista de scripts ===
        var allScripts = new List<SqlScript>();

        if (onlyRollback)
        {
            if (dir3 != null) allScripts.AddRange(ListScripts(dir3));
        }
        else
        {
            if (dir1 != null) allScripts.AddRange(ListScripts(dir1));
            if (dir2 != null) allScripts.AddRange(ListScripts(dir2));
            if (dir4 != null) allScripts.AddRange(ListScripts(dir4));
            if (dir5 != null) allScripts.AddRange(ListScripts(dir5));
            if (includeRollback && dir3 != null) allScripts.AddRange(ListScripts(dir3));
        }

        // DEBUG: listar scripts a ejecutar
        Console.WriteLine("[INF] Scripts a ejecutar:");
        if (allScripts.Count == 0)
            Console.WriteLine("  (ninguno)");
        else
            foreach (var s in allScripts) Console.WriteLine("  - " + s.Name);

        // === Builder / Upgrader ===
        var builder = DeployChanges.To
            .SqlDatabase(effectiveCs)
            .JournalToSqlTable("dbo", "SchemaVersions")
            .WithTransactionPerScript()
            .LogToConsole();

        if (allScripts.Count > 0)
            builder = builder.WithScripts(allScripts);

        var upgrader = builder.Build();
        var result = upgrader.PerformUpgrade();

        if (!result.Successful)
        {
            Console.ForegroundColor = ConsoleColor.Red;
            Console.WriteLine("[FAIL] Upgrade failed: " + result.Error.Message);
            Console.ResetColor();
            if (!ciMode)
            {
                Console.WriteLine();
                Console.WriteLine("Fin de prueba. Presiona una tecla para salir...");
                Console.ReadKey();
            }
            return -1;
        }

        // Prueba de conexión
        ProbarConexion(effectiveCs);

        if (!ciMode)
        {
            Console.WriteLine();
            Console.WriteLine("Fin de prueba. Presiona una tecla para salir...");
            Console.ReadKey();
        }
        return 0;
    }

    // ===== Helpers =====

    static string BuildMasterConnectionString(string csTarget)
    {
        var b = new SqlConnectionStringBuilder(csTarget) { InitialCatalog = "master" };
        return b.ToString();
    }

    static string MaskPassword(string cs)
    {
        var b = new SqlConnectionStringBuilder(cs);
        if (b.ContainsKey("Password") || b.ContainsKey("Pwd")) b.Password = "******";
        return b.ToString();
    }

    // Busca carpeta en bin y en la raíz del proyecto y la loguea
    static string? FindDir(string name)
    {
        var candidates = new[]
        {
            Path.Combine(AppContext.BaseDirectory, name),                               // bin
            Path.GetFullPath(Path.Combine(AppContext.BaseDirectory, @"..\..\..", name)) // raíz proyecto
        };
        foreach (var p in candidates)
        {
            if (Directory.Exists(p))
            {
                Console.WriteLine($"[INF] Usando carpeta '{name}': {p}");
                return p;
            }
        }
        Console.WriteLine($"[ERR] No encuentro carpeta: {name}");
        return null;
    }

    // Enumera *.sql (con subcarpetas), los ordena y los imprime
    static IEnumerable<SqlScript> ListScripts(string dir)
    {
        var files = Directory.GetFiles(dir, "*.sql", SearchOption.AllDirectories)
                             .OrderBy(f => f, StringComparer.OrdinalIgnoreCase)
                             .ToList();

        Console.WriteLine($"[INF] {dir} -> {files.Count} archivos .sql");
        foreach (var f in files)
            Console.WriteLine($"[INF]   + {Path.GetFileName(f)}");

        return files.Select(f => new SqlScript(Path.GetFileName(f), File.ReadAllText(f)));
    }

    static void ProbarConexion(string connectionString)
    {
        try
        {
            var sw = Stopwatch.StartNew();
            using var conn = new SqlConnection(connectionString);
            conn.Open();
            sw.Stop();

            using var cmd = new SqlCommand("SELECT @@SERVERNAME, DB_NAME()", conn);
            using var r = cmd.ExecuteReader();
            r.Read();
            var servidor = r.GetString(0);
            var baseDatos = r.GetString(1);

            Console.WriteLine();
            Console.WriteLine("Conexión OK");
            Console.WriteLine($"Servidor : {servidor}");
            Console.WriteLine($"Base     : {baseDatos}");
            Console.WriteLine($"Versión  : {conn.ServerVersion}");
            Console.WriteLine($"Tiempo   : {sw.ElapsedMilliseconds} ms");
        }
        catch (SqlException ex)
        {
            Console.ForegroundColor = ConsoleColor.Red;
            Console.WriteLine($"Error de conexión SQL ({ex.Number}): {ex.Message}");
            Console.ResetColor();
        }
        catch (Exception ex)
        {
            Console.ForegroundColor = ConsoleColor.Red;
            Console.WriteLine($"Error inesperado: {ex.Message}");
            Console.ResetColor();
        }
    }
}
