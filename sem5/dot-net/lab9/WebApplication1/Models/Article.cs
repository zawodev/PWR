using System.ComponentModel.DataAnnotations;

namespace WebApplication1.Models {
    public enum Category {
        Electronic,
        Food,
        Clothing,
        Toy,
        Book,
        Other
    }

    public class Article {
        public int Id { get; set; }

        [Required]
        [StringLength(100)]
        public string Name { get; set; }

        [Range(0.01, 10000)]
        public decimal Price { get; set; }

        [DataType(DataType.Date)]
        public DateTime ExpiryDate { get; set; }
        public Category Category { get; set; }

        public Article DeepCopy() {
            return new Article {
                Id = Id,
                Name = Name,
                Price = Price,
                ExpiryDate = ExpiryDate,
                Category = Category
            };
        }
    }
}
