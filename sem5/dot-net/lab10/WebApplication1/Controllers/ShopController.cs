using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using WebApplication1.Data;

namespace WebApplication1.Controllers {
    public class ShopController : Controller {
        private readonly ShopDbContext _context;

        public ShopController(ShopDbContext context) {
            _context = context;
        }

        public IActionResult Index() {
            var categories = _context.Categories.ToList();
            return View(categories);
        }

        public async Task<IActionResult> Products(int categoryId) {
            if (categoryId == 0) {
                return RedirectToAction(nameof(Index));
            }

            var products = await _context.Articles
                .Include(a => a.Category)
                .Where(a => a.CategoryId == categoryId)
                .ToListAsync();

            var categoryName = _context.Categories
                .Where(c => c.Id == categoryId)
                .Select(c => c.Name)
                .FirstOrDefault();

            ViewData["CategoryName"] = categoryName;
            return View(products);
        }
    }
}
