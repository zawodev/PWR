using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace WebApplication2Razor.Models {
    public class Order {
        public int Id { get; set; }
        public string FullName { get; set; }
        public string Address { get; set; }
        public string PaymentMethod { get; set; }
        public DateTime OrderDate { get; set; }
        public List<OrderItem> Items { get; set; } = new List<OrderItem>();
    }
}
