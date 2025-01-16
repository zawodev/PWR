using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.EntityFrameworkCore;
using WebApplication2Razor.Data;
using WebApplication2Razor.Models;
using System;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;

namespace NewRazorApplication1.Pages.Shop {
    [Authorize(Policy = "BlockCartForAdmin")]
    public class ProductsModel : PageModel {
        private readonly ShopDbContext _context;

        public ProductsModel(ShopDbContext context) {
            _context = context;
        }

        public List<Article> Products { get; set; }
        public string CategoryName { get; set; }

        public async Task<IActionResult> OnGetAsync(int categoryId) {
            if (categoryId == 0) {
                return RedirectToPage("./Index");
            }

            Products = await _context.Articles
                .Include(a => a.Category)
                .Where(a => a.CategoryId == categoryId)
                .ToListAsync();

            CategoryName = _context.Categories
                .Where(c => c.Id == categoryId)
                .Select(c => c.Name)
                .FirstOrDefault();

            return Page();
        }

        public IActionResult OnPostAddToCart(int productId) {
            var key = $"cart_{productId}";

            int quantity = 1;
            if (Request.Cookies.ContainsKey(key)) {
                quantity += int.Parse(Request.Cookies[key]);
            }

            if (_context.Articles.Any(a => a.Id == productId)) {
                Response.Cookies.Append(key, quantity.ToString(), new CookieOptions {
                    Expires = DateTime.Now.AddDays(7),
                    HttpOnly = true,
                    SameSite = SameSiteMode.Lax
                });
            }

            return RedirectToPage();
        }
    }
}
