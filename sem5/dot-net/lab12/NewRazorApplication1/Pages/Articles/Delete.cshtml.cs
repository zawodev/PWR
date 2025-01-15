using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.EntityFrameworkCore;
using WebApplication2Razor.Data;
using WebApplication2Razor.Models;

namespace WebApplication2Razor.Pages.Articles
{
    [Authorize(Policy = "AdminOnly")]
    public class DeleteModel : PageModel {
        private readonly ShopDbContext _context;

        public DeleteModel(ShopDbContext context) {
            _context = context;
        }

        public Article Article { get; set; }

        public async Task<IActionResult> OnGetAsync(int id) {
            Article = await _context.Articles.Include(a => a.Category).FirstOrDefaultAsync(m => m.Id == id);

            if (Article == null) {
                return NotFound();
            }

            return Page();
        }

        public async Task<IActionResult> OnPostAsync(int id) {
            var article = await _context.Articles.FindAsync(id);

            if (article == null) {
                return NotFound();
            }

            if (!string.IsNullOrEmpty(article.ImagePath) && article.ImagePath != "placeholder.png") {
                var imagePath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot/uploads", article.ImagePath);
                if (System.IO.File.Exists(imagePath)) {
                    System.IO.File.Delete(imagePath);
                }
            }

            _context.Articles.Remove(article);
            await _context.SaveChangesAsync();

            return RedirectToPage("./Index");
        }
    }
}
