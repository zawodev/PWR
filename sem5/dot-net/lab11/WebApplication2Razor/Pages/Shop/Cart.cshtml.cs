using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.EntityFrameworkCore;
using WebApplication2Razor.Data;
using WebApplication2Razor.Models;
using System;
using System.Linq;
using Microsoft.AspNetCore.Mvc;

namespace WebApplication2Razor.Pages.Shop {
    public class CartModel : PageModel {
        private readonly ShopDbContext _context;

        public CartModel(ShopDbContext context) {
            _context = context;
        }

        public List<CartItemViewModel> CartItems { get; set; }

        public void OnGet() {
            LoadCart();
        }

        public IActionResult OnGetIncrease(int id) {
            ModifyCart(id, 1);
            return RedirectToPage();
        }

        public IActionResult OnGetDecrease(int id) {
            ModifyCart(id, -1);
            return RedirectToPage();
        }

        public IActionResult OnGetRemove(int id) {
            ModifyCart(id, 0); // remove item
            return RedirectToPage();
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

            // remove cookies for products that no longer exist in the database
            foreach (var id in productIds.Except(productsInCart.Select(p => p.Id))) {
                Response.Cookies.Delete($"cart_{id}");
                cartItems.Remove(id);
            }

            CartItems = productsInCart.Select(p => new CartItemViewModel {
                Product = p,
                Quantity = cartItems[p.Id]
            }).ToList();
        }

        private void ModifyCart(int id, int change) {
            var key = $"cart_{id}";
            if (change == 0) {
                // remove item if change is zero
                Response.Cookies.Delete(key);
            } else {
                int newQuantity = change;
                if (Request.Cookies.ContainsKey(key)) {
                    newQuantity += int.Parse(Request.Cookies[key]);
                }

                if (newQuantity <= 0) {
                    Response.Cookies.Delete(key); // remove if quantity is zero
                } else if (_context.Articles.Any(a => a.Id == id)) {
                    Response.Cookies.Append(key, newQuantity.ToString(), new CookieOptions {
                        Expires = DateTime.Now.AddDays(7)
                    });
                }
            }
        }
    }

    public class CartItemViewModel {
        public Article Product { get; set; }
        public int Quantity { get; set; }
    }
}
