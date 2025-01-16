using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.AspNetCore.Mvc;
using NewRazorApplication1.Data;
using WebApplication2Razor.Models;
using WebApplication2Razor.Data;
using Microsoft.AspNetCore.Authorization;

namespace NewRazorApplication1.Pages.Shop {
    [Authorize(Policy = "BlockCartForAdmin")]
    public class OrderConfirmationModel : PageModel {
        private readonly ShopDbContext _context;

        public OrderConfirmationModel(ShopDbContext context) {
            _context = context;
        }

        public string FullName { get; set; }
        public string Address { get; set; }
        public string PaymentMethod { get; set; }

        public void OnGet() {
            FullName = TempData["FullName"]?.ToString();
            Address = TempData["Address"]?.ToString();
            PaymentMethod = TempData["PaymentMethod"]?.ToString();

            // Wyczyszczenie koszyka
            foreach (var key in Request.Cookies.Keys.Where(k => k.StartsWith("cart_"))) {
                Response.Cookies.Delete(key);
            }
        }
    }
}
