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

        // POST: api/articles
        [HttpPost]
        public async Task<ActionResult<Article>> CreateArticle(Article article) {
            _context.Articles.Add(article);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetArticle), new { id = article.Id }, article);
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
