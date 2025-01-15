using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using WebApplication2Razor.Data;
using WebApplication2Razor.Models;

namespace NewRazorApplication1.Controllers {
    [ApiController]
    [Route("api/[controller]")]
    public class CategoriesController : ControllerBase {
        private readonly ShopDbContext _context;

        public CategoriesController(ShopDbContext context) {
            _context = context;
        }

        // GET: api/categories
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Category>>> GetCategories() {
            return await _context.Categories.ToListAsync();
        }

        // GET: api/categories/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<Category>> GetCategory(int id) {
            var category = await _context.Categories.FindAsync(id);
            if (category == null) {
                return NotFound();
            }
            return category;
        }

        // POST: api/categories
        [HttpPost]
        public async Task<ActionResult<Category>> CreateCategory(Category category) {
            _context.Categories.Add(category);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetCategory), new { id = category.Id }, category);
        }

        // PUT: api/categories/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateCategory(int id, Category category) {
            if (id != category.Id) {
                return BadRequest();
            }

            _context.Entry(category).State = EntityState.Modified;

            try {
                await _context.SaveChangesAsync();
            } catch (DbUpdateConcurrencyException) {
                if (!CategoryExists(id)) {
                    return NotFound();
                } else {
                    throw;
                }
            }

            return NoContent();
        }

        // DELETE: api/categories/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteCategory(int id) {
            var category = await _context.Categories.FindAsync(id);
            if (category == null) {
                return NotFound();
            }

            _context.Categories.Remove(category);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        private bool CategoryExists(int id) {
            return _context.Categories.Any(e => e.Id == id);
        }
    }
}
