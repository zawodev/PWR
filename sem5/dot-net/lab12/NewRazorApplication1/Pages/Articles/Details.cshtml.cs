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
    public class DetailsModel : PageModel {
        private readonly ShopDbContext _context;

        public DetailsModel(ShopDbContext context) {
            _context = context;
        }

        public Article Article { get; set; }

        public async Task<IActionResult> OnGetAsync(int id) {
            Article = await _context.Articles
                .Include(a => a.Category)
                .FirstOrDefaultAsync(m => m.Id == id);

            if (Article == null) {
                return NotFound();
            }

            return Page();
        }
    }
}
