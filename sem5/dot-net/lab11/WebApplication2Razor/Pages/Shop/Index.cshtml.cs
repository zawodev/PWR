using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using WebApplication2Razor.Data;
using WebApplication2Razor.Models;

namespace WebApplication2Razor.Pages.Shop {
    public class IndexModel : PageModel {
        private readonly ShopDbContext _context;

        public IndexModel(ShopDbContext context) {
            _context = context;
        }

        public List<Category> Categories { get; set; }

        public void OnGet() {
            Categories = _context.Categories.ToList();
        }
    }
}
