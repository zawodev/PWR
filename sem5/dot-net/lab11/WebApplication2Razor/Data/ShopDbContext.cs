using Microsoft.EntityFrameworkCore;
using WebApplication2Razor.Models;

namespace WebApplication2Razor.Data {
    public class ShopDbContext : DbContext {
        public DbSet<Category> Categories { get; set; }
        public DbSet<Article> Articles { get; set; }

        public ShopDbContext(DbContextOptions<ShopDbContext> options) : base(options) { }

        protected override void OnModelCreating(ModelBuilder modelBuilder) {
            base.OnModelCreating(modelBuilder);

            // relacja jeden-do-wielu między Category a Articles
            modelBuilder.Entity<Article>()
                .HasOne(a => a.Category)
                .WithMany(c => c.Articles)
                .HasForeignKey(a => a.CategoryId)
                .OnDelete(DeleteBehavior.Cascade); // usuwanie artykułów przy usunięciu kategorii
        }
    }

}
