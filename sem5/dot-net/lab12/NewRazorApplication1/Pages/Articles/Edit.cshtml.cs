using System;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Hosting;
using WebApplication2Razor.Data;
using WebApplication2Razor.Models;

namespace WebApplication2Razor.Pages.Articles {
    [Authorize(Policy = "AdminOnly")]
    public class EditModel : PageModel {
        private readonly ShopDbContext _context;
        private readonly IWebHostEnvironment _environment;

        public EditModel(ShopDbContext context, IWebHostEnvironment environment) {
            _context = context;
            _environment = environment;
        }

        [BindProperty]
        public Article Article { get; set; }

        [BindProperty]
        public IFormFile ImageFile { get; set; }

        public SelectList Categories { get; set; }

        public async Task<IActionResult> OnGetAsync(int id) {
            Article = await _context.Articles.Include(a => a.Category)
                                             .FirstOrDefaultAsync(a => a.Id == id);
            if (Article == null) {
                return NotFound();
            }

            Categories = new SelectList(_context.Categories, "Id", "Name");

            System.Console.WriteLine("D");

            return Page();
        }

        public async Task<IActionResult> OnPostAsync(int id) {
            try {
                var existingArticle = await _context.Articles.Include(a => a.Category)
                                                             .FirstOrDefaultAsync(a => a.Id == id);
                if (existingArticle == null) {
                    return NotFound();
                }

                existingArticle.Name = Article.Name;
                existingArticle.Price = Article.Price;
                existingArticle.CategoryId = Article.CategoryId;

                if (ImageFile != null && ImageFile.Length > 0) {
                    var fileName = $"{Guid.NewGuid()}_{ImageFile.FileName}";
                    var filePath = Path.Combine(_environment.WebRootPath, "uploads", fileName);
                    using (var stream = new FileStream(filePath, FileMode.Create)) {
                        await ImageFile.CopyToAsync(stream);
                    }
                    existingArticle.ImagePath = $"uploads/{fileName}";
                }
                _context.Articles.Update(existingArticle);
                await _context.SaveChangesAsync();
            } catch (DbUpdateConcurrencyException) {
                if (!ArticleExists(Article.Id)) {
                    return NotFound();
                } else {
                    throw;
                }
            }

            System.Console.WriteLine("Article updated successfully!");  
            return RedirectToPage("./Index");
        }

        private bool ArticleExists(int id) {
            return _context.Articles.Any(a => a.Id == id);
        }
    }
}
