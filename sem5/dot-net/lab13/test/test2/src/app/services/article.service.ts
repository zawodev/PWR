import { Injectable, WritableSignal, signal } from '@angular/core';

@Injectable({
  providedIn: 'root'
})
export class ArticleService {
  private _articles: WritableSignal<{ id: number; name: string; price: number; category: string; image_path: string | null }[]> = signal([
    { id: 1, name: 'Phone', price: 28.59, category: 'Electronics', image_path: null },
    { id: 2, name: 'Hobbit', price: 12.99, category: 'Books', image_path: null },
  ]);

  private _categories = ['Electronics', 'Books', 'Fruits', 'Clothing'];
  private _nextId = this._articles().length + 1;

  get articles() {
    return this._articles;
  }

  get categories() {
    return this._categories;
  }

  addArticle(article: { name: string; price: number; category: string; image_path: string | null }) {
    const newArticle = { id: this._nextId++, ...article };
    this._articles.update(articles => [...articles, newArticle]);
  }

  deleteArticle(id: number) {
    this._articles.update(articles => articles.filter(article => article.id !== id));
  }

  editArticle(id: number, updatedArticle: { name: string; price: number; category: string; image_path: string | null }) {
    this._articles.update(articles => 
      articles.map(article => 
        article.id === id ? { ...article, ...updatedArticle } : article
      )
    );
  }
}
