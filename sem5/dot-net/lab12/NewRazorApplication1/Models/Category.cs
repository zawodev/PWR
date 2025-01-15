using System.ComponentModel.DataAnnotations.Schema;

namespace WebApplication2Razor.Models {
    public class Category {
        public int Id { get; set; }
        public string Name { get; set; }
        public ICollection<Article> Articles { get; set; } = new List<Article>();
    }

}
