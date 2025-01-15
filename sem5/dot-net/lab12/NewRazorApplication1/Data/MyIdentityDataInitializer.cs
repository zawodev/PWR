using Microsoft.AspNetCore.Identity;

namespace NewRazorApplication1.Data {
    public class MyIdentityDataInitializer {
        public static void SeedData(UserManager<IdentityUser> userManager, RoleManager<IdentityRole> roleManager) {
            SeedRoles(roleManager);
            SeedUsers(userManager);
        }
        public static void SeedRoles(RoleManager<IdentityRole> roleManager) {
            if (!roleManager.RoleExistsAsync("Admin").Result) {
                IdentityRole role = new IdentityRole {
                    Name = "Admin",
                };
                IdentityResult roleResult = roleManager.CreateAsync(role).Result;
            }
            if (!roleManager.RoleExistsAsync("Dean").Result){
                IdentityRole role = new IdentityRole {
                    Name = "Dean",
                };
                IdentityResult roleResult = roleManager.CreateAsync(role).Result;
            }
        }
        public static void SeedOneUser(UserManager<IdentityUser> userManager, string name, string password, string role = null) {
            if (userManager.FindByNameAsync(name).Result == null) {
                IdentityUser user = new IdentityUser {
                    UserName = name,
                    Email = name
                };
                IdentityResult result = userManager.CreateAsync(user, password).Result;
                if (result.Succeeded && role != null) {
                    userManager.AddToRoleAsync(user, role).Wait();
                }
            }
        }
        public static void SeedUsers(UserManager<IdentityUser> userManager) {
            SeedOneUser(userManager, "normaluser@localhost", "nUpass1!");
            SeedOneUser(userManager, "adminuser@localhost", "aUpass1!", "Admin");
            SeedOneUser(userManager, "deanuser@localhost", "dUpass1!", "Dean");
        }
    }
}
