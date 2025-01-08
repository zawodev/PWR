using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using WebApplication2Razor.Data;
using WebApplication2Razor.Models;

namespace WebApplication2Razor.Pages.Articles
{
    public class CreateModel : PageModel {
        private readonly ShopDbContext _context;
        private readonly IWebHostEnvironment _environment;

        public CreateModel(ShopDbContext context, IWebHostEnvironment environment) {
            _context = context;
            _environment = environment;
        }

        [BindProperty]
        public Article Article { get; set; } = new();

        [BindProperty]
        public IFormFile? ImageFile { get; set; }

        public SelectList Categories { get; set; }

        public async Task<IActionResult> OnGetAsync() {
            Categories = new SelectList(await _context.Categories.ToListAsync(), "Id", "Name");
            return Page();
        }

        public async Task<IActionResult> OnPostAsync() {
            if (ImageFile == null) {
                Article.ImagePath = null;
            } else {
                var fileName = $"{Guid.NewGuid()}_{ImageFile.FileName}";
                var filePath = Path.Combine(_environment.WebRootPath, "uploads", fileName);
                using (var stream = new FileStream(filePath, FileMode.Create)) {
                    await ImageFile.CopyToAsync(stream);
                }
                Article.ImagePath = $"{fileName}";
            }

            Article.Category = await _context.Categories.FindAsync(Article.CategoryId);

            _context.Articles.Add(Article);
            await _context.SaveChangesAsync();

            return RedirectToPage("./Index");
        }
    }
}
