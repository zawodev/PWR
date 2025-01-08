using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.EntityFrameworkCore;
using WebApplication2Razor.Data;
using WebApplication2Razor.Models;

namespace WebApplication2Razor.Pages.Articles
{
    public class IndexModel : PageModel {
        private readonly ShopDbContext _context;

        public IndexModel(ShopDbContext context) {
            _context = context;
        }

        public IList<Article> Articles { get; set; }

        public async Task OnGetAsync() {
            Articles = await _context.Articles.Include(a => a.Category).ToListAsync();
        }
    }
}
