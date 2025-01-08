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
            var cart = Request.Cookies["cart"];
            var cartItems = cart == null ? new Dictionary<int, int>() : DeserializeCart(cart);

            var productIds = cartItems.Keys.ToList();
            var productsInCart = _context.Articles
                .Where(a => productIds.Contains(a.Id))
                .ToList();

            // usuñ te produkty z koszyka, które zosta³y usuniête z bazy w miêdzyczasie
            var validCartItems = cartItems.Where(ci => productsInCart.Any(p => p.Id == ci.Key)).ToDictionary(ci => ci.Key, ci => ci.Value);
            SaveCart(validCartItems);

            CartItems = productsInCart.Select(p => new CartItemViewModel {
                Product = p,
                Quantity = validCartItems[p.Id]
            }).ToList();
        }

        private void ModifyCart(int id, int change) {
            var cart = Request.Cookies["cart"];
            var cartItems = cart == null ? new Dictionary<int, int>() : DeserializeCart(cart);

            if (change == 0) {
                cartItems.Remove(id); // remove item if change is zero (obviously)
            } else {
                if (!cartItems.ContainsKey(id)) { // jak nie ma w koszyku jeszcze
                    if (_context.Articles.Any(a => a.Id == id)) // ale jak jest w bazie
                    {
                        cartItems[id] = change; // add as new item
                    }
                } else {
                    cartItems[id] += change; // update iloœæ produktu
                    if (cartItems[id] <= 0) {
                        cartItems.Remove(id); // remove if quantity is zero
                    }
                }
            }

            SaveCart(cartItems);
        }

        private void SaveCart(Dictionary<int, int> cartItems) {
            var cart = string.Join(";", cartItems.Select(ci => $"{ci.Key}-{ci.Value}"));
            Response.Cookies.Append("cart", cart, new CookieOptions {
                Expires = DateTime.Now.AddDays(7)
            });
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

    public class CartItemViewModel {
        public Article Product { get; set; }
        public int Quantity { get; set; }
    }
}
