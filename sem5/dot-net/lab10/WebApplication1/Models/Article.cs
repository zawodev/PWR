using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace WebApplication1.Models {
    public class Article {
        public int Id { get; set; }
        [Required]
        [StringLength(100)]
        public string Name { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        [Range(0, double.MaxValue, ErrorMessage = "test")]
        public decimal Price { get; set; }
        public string? ImagePath { get; set; }
        public int CategoryId { get; set; }
        public Category Category { get; set; } = new Category();
    }
}
