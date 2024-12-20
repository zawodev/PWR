using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using WebApplication1.Data;
using WebApplication1.Models;

namespace WebApplication1.Controllers {
    public class CategoriesController : Controller {
        private readonly ShopDbContext _context;

        public CategoriesController(ShopDbContext context) {
            _context = context;
        }

        public async Task<IActionResult> Index() {
            return View(await _context.Categories.ToListAsync());
        }

        public IActionResult Create() {
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(Category category) {
            if (ModelState.IsValid) {
                _context.Add(category);
                await _context.SaveChangesAsync();
                return RedirectToAction(nameof(Index));
            }
            return View(category);
        }

        public async Task<IActionResult> Edit(int? id) {
            if (id == null) return NotFound();

            var category = await _context.Categories.FindAsync(id);
            if (category == null) return NotFound();

            return View(category);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, Category category) {
            if (id != category.Id) return NotFound();

            if (ModelState.IsValid) {
                try {
                    _context.Update(category);
                    await _context.SaveChangesAsync();
                } catch (DbUpdateConcurrencyException) {
                    if (!CategoryExists(category.Id)) return NotFound();
                    else throw;
                }
                return RedirectToAction(nameof(Index));
            }
            return View(category);
        }

        public async Task<IActionResult> Details(int? id) {
            if (id == null) return NotFound();

            var category = await _context.Categories
                .Include(c => c.Articles)
                .FirstOrDefaultAsync(m => m.Id == id);

            if (category == null) return NotFound();

            return View(category);
        }

        public async Task<IActionResult> Delete(int? id) {
            if (id == null) return NotFound();

            var category = await _context.Categories.Include(c => c.Articles).FirstOrDefaultAsync(c => c.Id == id);
            if (category == null) return NotFound();

            return View(category);
        }

        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id) {
            var category = await _context.Categories.Include(c => c.Articles).FirstOrDefaultAsync(c => c.Id == id);
            if (category != null) {
                // usuwanie wszystkich artykułów
                /*
                foreach (var article in category.Articles) {
                    if (!string.IsNullOrEmpty(article.ImagePath) && article.ImagePath != "placeholder.png") {
                        var imagePath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads", article.ImagePath);
                        if (System.IO.File.Exists(imagePath)) System.IO.File.Delete(imagePath);
                    }
                }
                _context.Categories.Remove(category);
                await _context.SaveChangesAsync();
                */

                var hasArticles = _context.Articles.Any(a => a.CategoryId == category.Id);

                if (hasArticles) {
                    TempData["Error"] = "Nie mozna usunac kategorii, bo ma jeszcze artykuły, zmień ich kategorie lub usuń je aby kontynuować.";
                    return View(category);
                }

                _context.Categories.Remove(category);
                await _context.SaveChangesAsync();
            }
            return RedirectToAction(nameof(Index));
        }

        private bool CategoryExists(int id) {
            return _context.Categories.Any(e => e.Id == id);
        }
    }
}
