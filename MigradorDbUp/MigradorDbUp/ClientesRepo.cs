using System;
using MigradorDbUp.Models;


namespace MigradorDbUp.Models
{
    public sealed class Cliente
    {
        public int ClienteId { get; init; }              // IDENTITY
        public string Nombre { get; set; } = string.Empty;
        public string? Email { get; set; }
        public string? Telefono { get; set; }
        public DateTime CreadoEn { get; init; }              // lo pone la BD (DEFAULT)
        public override string ToString()
            => $"{ClienteId} - {Nombre} ({Email ?? "sin email"})";
    }
}
