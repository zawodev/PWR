using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.AspNetCore.Mvc;
using NewRazorApplication1.Data;
using WebApplication2Razor.Models;
using System.Collections.Generic;
using System.Linq;
using WebApplication2Razor.Data;
using Microsoft.AspNetCore.Authorization;

namespace NewRazorApplication1.Pages.Shop {
    [Authorize(Policy = "BlockCartForAdmin")]
    public class CheckoutModel : PageModel {
        private readonly ShopDbContext _context;

        public CheckoutModel(ShopDbContext context) {
            _context = context;
        }

        [BindProperty]
        public string FullName { get; set; }
        [BindProperty]
        public string Address { get; set; }
        [BindProperty]
        public string PaymentMethod { get; set; }

        public List<CartItemViewModel> CartItems { get; set; }

        public void OnGet() {
            LoadCart();
        }

        public IActionResult OnPost() {
            if (!ModelState.IsValid) {
                LoadCart();
                return Page();
            }

            LoadCart();

            var order = new Order {
                FullName = FullName,
                Address = Address,
                PaymentMethod = PaymentMethod,
                OrderDate = DateTime.Now,
                Items = new List<OrderItem>()
            };

            foreach (var cartItem in CartItems) {
                var orderItem = new OrderItem {
                    ProductId = cartItem.Product.Id,
                    Quantity = cartItem.Quantity,
                    Product = cartItem.Product
                };
                order.Items.Add(orderItem);
                _context.OrderItems.Add(orderItem);
            }

            _context.Orders.Add(order);
            _context.SaveChanges();

            foreach (var cartItem in CartItems) {
                Response.Cookies.Delete($"cart_{cartItem.Product.Id}");
            }

            TempData["FullName"] = FullName;
            TempData["Address"] = Address;
            TempData["PaymentMethod"] = PaymentMethod;

            return RedirectToPage("/Shop/OrderConfirmation");
        }

        private void LoadCart() {
            var cartItems = Request.Cookies.Keys
                .Where(key => key.StartsWith("cart_"))
                .ToDictionary(
                    key => int.Parse(key.Substring(5)),
                    key => int.Parse(Request.Cookies[key])
                );

            var productIds = cartItems.Keys.ToList();
            var productsInCart = _context.Articles
                .Where(a => productIds.Contains(a.Id))
                .ToList();

            CartItems = productsInCart.Select(p => new CartItemViewModel {
                Product = p,
                Quantity = cartItems[p.Id]
            }).ToList();
        }
    }
}
