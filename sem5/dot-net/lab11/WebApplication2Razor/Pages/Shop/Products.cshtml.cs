using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.EntityFrameworkCore;
using WebApplication2Razor.Data;
using WebApplication2Razor.Models;
using System;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;

namespace WebApplication2Razor.Pages.Shop {
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

        // Handle adding item to cart
        public IActionResult OnPostAddToCart(int productId) {
            // Retrieve existing cart from cookies
            var cart = Request.Cookies["cart"];
            var cartItems = cart == null ? new Dictionary<int, int>() : DeserializeCart(cart);

            // Update the cart (increment quantity if the product already exists)
            if (cartItems.ContainsKey(productId)) {
                cartItems[productId]++;
            } else {
                cartItems[productId] = 1;
            }

            // Save the updated cart back to cookies
            Response.Cookies.Append("cart", SerializeCart(cartItems), new CookieOptions {
                Expires = DateTime.Now.AddDays(7), // Keep for 7 days
                HttpOnly = true,
                SameSite = SameSiteMode.Lax
            });

            return RedirectToPage(); // Redirect to the same page to update UI
        }

        private string SerializeCart(Dictionary<int, int> cart) {
            return string.Join(";", cart.Select(item => $"{item.Key}-{item.Value}"));
        }

        private Dictionary<int, int> DeserializeCart(string cart) {
            return cart.Split(';')
                .Select(item => item.Split('-'))
                .ToDictionary(
                    parts => int.Parse(parts[0]),
                    parts => int.Parse(parts[1])
                );
        }
    }
}
