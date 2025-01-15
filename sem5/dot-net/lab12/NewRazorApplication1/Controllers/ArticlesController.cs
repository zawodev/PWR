using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using WebApplication2Razor.Data;
using WebApplication2Razor.Models;

namespace NewRazorApplication1.Controllers {
    [ApiController]
    [Route("api/[controller]")]
    public class ArticlesController : ControllerBase {
        private readonly ShopDbContext _context;

        public ArticlesController(ShopDbContext context) {
            _context = context;
        }

        // GET: api/articles
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Article>>> GetArticles() {
            return await _context.Articles.ToListAsync();
        }

        // GET: api/articles/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<Article>> GetArticle(int id) {
            var article = await _context.Articles.FindAsync(id);

            if (article == null) {
                return NotFound();
            }

            return article;
        }

        // GET: api/articles/ByCategory?categoryId=1&skip=0&take=5
        [HttpGet("ByCategory")]
        public async Task<IActionResult> GetProductsByCategory(int categoryId, int skip, int take) {
            var products = await _context.Articles
                .Where(a => a.CategoryId == categoryId)
                .Skip(skip)
                .Take(take)
                .ToListAsync();

            if (!products.Any()) {
                return NoContent();
            }

            return Ok(products);
        }


        // POST: api/articles
        [HttpPost]
        public async Task<ActionResult<Article>> CreateArticle(Article article) {
            _context.Articles.Add(article);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetArticle), new { id = article.Id, }, article);
        }

        // POST: api/articles/AddToCart?productId=1
        [HttpPost("AddToCart")]
        public IActionResult AddToCart([FromQuery] int productId) {
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
                return Ok(new { success = true, quantity });
            }

            return BadRequest(new { success = false, message = "Product not found" });
        }

        // PUT: api/articles/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateArticle(int id, Article article) {
            if (id != article.Id) {
                return BadRequest();
            }

            _context.Entry(article).State = EntityState.Modified;

            try {
                await _context.SaveChangesAsync();
            } catch (DbUpdateConcurrencyException) {
                if (!ArticleExists(id)) {
                    return NotFound();
                } else {
                    throw;
                }
            }

            return NoContent();
        }

        // DELETE: api/articles/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteArticle(int id) {
            var article = await _context.Articles.FindAsync(id);
            if (article == null) {
                return NotFound();
            }

            _context.Articles.Remove(article);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        private bool ArticleExists(int id) {
            return _context.Articles.Any(e => e.Id == id);
        }
    }
}
