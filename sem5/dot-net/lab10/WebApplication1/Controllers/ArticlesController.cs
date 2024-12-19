using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.AspNetCore.Mvc;
using WebApplication1.Data;
using WebApplication1.Models;
using Microsoft.EntityFrameworkCore;

namespace WebApplication1.Controllers {
    public class ArticlesController : Controller {
        private readonly ShopDbContext _context;
        private readonly IWebHostEnvironment _environment;

        public ArticlesController(ShopDbContext context, IWebHostEnvironment environment) {
            _context = context;
            _environment = environment;
        }

        public async Task<IActionResult> Index() {
            var articles = _context.Articles.Include(a => a.Category);
            return View(await articles.ToListAsync());
        }

        public IActionResult Create() {
            ViewData["Categories"] = new SelectList(_context.Categories, "Id", "Name");
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(Article article, IFormFile imageFile) {
            if (imageFile == null) { //image file is not required, if not present we do a deafault image
                //article.ImagePath = "placeholder.png";
                article.ImagePath = null;
            } 
            else {
                var fileName = $"{Guid.NewGuid()}_{imageFile.FileName}";
                var filePath = Path.Combine(_environment.WebRootPath, "uploads", fileName);
                using (var stream = new FileStream(filePath, FileMode.Create)) {
                    await imageFile.CopyToAsync(stream);
                }
                article.ImagePath = $"{fileName}";
            }
            article.Category = await _context.Categories.FindAsync(article.CategoryId);
            _context.Add(article);
            await _context.SaveChangesAsync();
            return RedirectToAction(nameof(Index));

            /*
            foreach (var error in ModelState.Values.SelectMany(v => v.Errors)) {
                Console.WriteLine(error.ErrorMessage);
            }
            */
        }

        public async Task<IActionResult> Edit(int? id) {
            if (id == null) return NotFound();

            var article = await _context.Articles.FindAsync(id);
            if (article == null) return NotFound();

            ViewData["Categories"] = new SelectList(_context.Categories, "Id", "Name", article.CategoryId);
            return View(article);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, Article article, IFormFile imageFile) {
            if (id != article.Id) return NotFound();

            try {
                var existingArticle = await _context.Articles.Include(a => a.Category).FirstOrDefaultAsync(a => a.Id == id);
                if (existingArticle == null) {
                    return NotFound();
                }

                existingArticle.Name = article.Name;
                existingArticle.Price = article.Price;
                existingArticle.CategoryId = article.CategoryId;

                if (imageFile != null && imageFile.Length > 0) {
                    var fileName = $"{Guid.NewGuid()}_{imageFile.FileName}";
                    var filePath = Path.Combine(_environment.WebRootPath, "uploads", fileName);
                    using (var stream = new FileStream(filePath, FileMode.Create)) {
                        await imageFile.CopyToAsync(stream);
                    }
                    existingArticle.ImagePath = $"uploads/{fileName}";
                }

                _context.Update(existingArticle);
                await _context.SaveChangesAsync();
            } catch (DbUpdateConcurrencyException) {
                if (!ArticleExists(article.Id)) {
                    return NotFound();
                } else {
                    throw;
                }
            }

            return RedirectToAction(nameof(Index));

            /*
            foreach (var error in ModelState.Values.SelectMany(v => v.Errors)) {
                Console.WriteLine(error.ErrorMessage);
            }
            */
        }

        public async Task<IActionResult> Details(int? id) {
            var article = await _context.Articles.FindAsync(id);
            if (article == null) return NotFound();
            article.Category = await _context.Categories.FindAsync(article.CategoryId);
            return View(article);
        }

        public async Task<IActionResult> Delete(int? id) {
            var article = await _context.Articles.FindAsync(id);
            if (article == null) return NotFound();
            article.Category = await _context.Categories.FindAsync(article.CategoryId);
            return View(article);
        }

        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id) {
            var article = await _context.Articles.FindAsync(id);
            if (article != null) {
                if (!string.IsNullOrEmpty(article.ImagePath) && article.ImagePath != "placeholder.png") {
                    var imagePath = Path.Combine(_environment.WebRootPath, "uploads", article.ImagePath);
                    if (System.IO.File.Exists(imagePath)) System.IO.File.Delete(imagePath);
                }
                _context.Articles.Remove(article);
                await _context.SaveChangesAsync();
            }
            return RedirectToAction(nameof(Index));
        }

        private bool ArticleExists(int id) {
            return _context.Articles.Any(e => e.Id == id);
        }
    }
}
