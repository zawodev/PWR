using Microsoft.AspNetCore.Mvc;

using WebApplication1.Models.Interfaces;
using WebApplication1.Models;

namespace WebApplication1.Controllers {
    public class ArticlesController : Controller {
        private readonly IArticlesContext _articlesContext;

        public ArticlesController(IArticlesContext articlesContext) {
            _articlesContext = articlesContext;
        }

        public IActionResult Index() {
            var articles = _articlesContext.GetAll();
            return View(articles);
        }

        public IActionResult Details(int id) {
            var article = _articlesContext.GetById(id);
            if (article == null) return NotFound();
            return View(article);
        }

        public IActionResult Create() {
            return View();
        }

        [ValidateAntiForgeryToken, HttpPost]
        public IActionResult Create(Article article) {
            try {
                if (ModelState.IsValid) {
                    _articlesContext.Add(article);
                    return RedirectToAction(nameof(Index));
                }
                return View(article);
            }
            catch {
                return View();
            }
        }

        public IActionResult Edit(int id) {
            var article = _articlesContext.GetById(id);
            if (article == null) return NotFound();
            return View(article);
        }

        [HttpPost]
        public IActionResult Edit(Article article) {
            if (ModelState.IsValid) {
                _articlesContext.Update(article);
                return RedirectToAction(nameof(Index));
            }
            return View(article);
        }

        public IActionResult Delete(int id) {
            var article = _articlesContext.GetById(id);
            if (article == null) return NotFound();
            return View(article);
        }

        [HttpPost, ActionName("Delete")]
        public IActionResult DeleteConfirmed(int id) {
            _articlesContext.Delete(id);
            return RedirectToAction(nameof(Index));
        }
    }
}
