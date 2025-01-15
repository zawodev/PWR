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

namespace WebApplication2Razor.Pages.Categories
{
    [Authorize(Policy = "AdminOnly")]
    public class DeleteModel : PageModel {
        private readonly ShopDbContext _context;

        public DeleteModel(ShopDbContext context) {
            _context = context;
        }

        [BindProperty]
        public Category Category { get; set; } = default!;

        public async Task<IActionResult> OnGetAsync(int? id) {
            if (id == null) {
                return NotFound();
            }

            Category = await _context.Categories
                .Include(c => c.Articles)
                .FirstOrDefaultAsync(m => m.Id == id);

            if (Category == null) {
                return NotFound();
            }

            return Page();
        }

        public async Task<IActionResult> OnPostAsync(int? id) {
            if (id == null) {
                return NotFound();
            }

            Category = await _context.Categories
                .Include(c => c.Articles)
                .FirstOrDefaultAsync(m => m.Id == id);

            if (Category == null) {
                return NotFound();
            }

            if (Category.Articles != null && Category.Articles.Any()) {
                TempData["Error"] = "Nie mozna usunac kategorii, bo ma jeszcze artykuły, zmień ich kategorie lub usuń je aby kontynuować.";
                return Page();
            }

            _context.Categories.Remove(Category);
            await _context.SaveChangesAsync();

            return RedirectToPage("./Index");
        }
    }
}
