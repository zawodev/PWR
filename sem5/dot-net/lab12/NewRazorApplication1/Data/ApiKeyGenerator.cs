using Microsoft.EntityFrameworkCore;
using NewRazorApplication1.Models;
using System.Security.Cryptography;
using WebApplication2Razor.Data;

namespace NewRazorApplication1.Data {
    public static class ApiKeyGenerator {
        public static void Initialize(ShopDbContext context) {
            if (!context.ApiKeys.Any()) {
                context.ApiKeys.Add(new ApiKey {
                    Key = GenerateApiKey(),
                    Owner = "AdminUser",
                    CreatedAt = DateTime.UtcNow,
                    IsActive = true
                });
                context.SaveChanges();
            }
        }
        public static string GenerateApiKey() {
            return Convert.ToBase64String(RandomNumberGenerator.GetBytes(32));
        }
    }

}
