using WebApplication1.Models.Interfaces;

namespace WebApplication1.Models.Contexts {
    public class ArticlesDictionaryContext : IArticlesContext {
        private readonly Dictionary<int, Article> _articles = new();

        public IEnumerable<Article> GetAll() {
            return _articles.Values;
        }

        public Article GetById(int id) {
            return _articles.ContainsKey(id) ? _articles[id] : null;
        }

        public void Add(Article article) {
            article.Id = _articles.Keys.Any() ? _articles.Keys.Max() + 1 : 1;
            _articles[article.Id] = article;
        }

        public void Update(Article article) {
            if (_articles.ContainsKey(article.Id)) {
                _articles[article.Id] = article;
            }
        }

        public void Delete(int id) {
            _articles.Remove(id);
        }
    }

}
