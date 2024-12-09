using WebApplication1.Models.Interfaces;

namespace WebApplication1.Models.Contexts {
    public class ArticlesListContext : IArticlesContext {
        private readonly List<Article> _articles = new();

        public IEnumerable<Article> GetAll() {
            return _articles;
        } 

        public Article GetById(int id) {
            return _articles.FirstOrDefault(a => a.Id == id);
        }

        public void Add(Article article) {
            article.Id = _articles.Any() ? _articles.Max(a => a.Id) + 1 : 1;
            _articles.Add(article);
        }

        public void Update(Article article) {
            var existing = GetById(article.Id);
            if (existing != null) {
                existing.Name = article.Name;
                existing.Price = article.Price;
                existing.ExpiryDate = article.ExpiryDate;
                existing.Category = article.Category;
            }
        }

        public void Delete(int id) {
            var article = GetById(id);
            if (article != null) {
                _articles.Remove(article);
            }
        }
    }

}
