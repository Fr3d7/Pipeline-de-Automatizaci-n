using System;
using MigradorDbUp.Models;


namespace MigradorDbUp.Models
{
    public sealed class Pedido
    {
        public int PedidoId { get; init; }              // IDENTITY
        public int ClienteId { get; set; }               // FK a Clientes
        public DateTime Fecha { get; set; } = DateTime.UtcNow; // DEFAULT en BD
        public decimal Monto { get; set; }               // CHECK (>=0)
        public string Estado { get; set; } = "Pendiente";
        public override string ToString()
            => $"Pedido {PedidoId} -> Cliente {ClienteId} | {Fecha:u} | Q{Monto:0.00} | {Estado}";
    }
}
