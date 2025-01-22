import { Injectable } from '@angular/core';

export interface Article {
  id: number;
  name: string;
  category: string;
  price: number;
}

@Injectable({
  providedIn: 'root',
})
export class ArticleService {
  private articles: Article[] = [
    { id: 1, name: 'Article 1', category: 'Category A', price: 10 },
    { id: 2, name: 'Article 2', category: 'Category B', price: 15 },
    { id: 3, name: 'Article 3', category: 'Category A', price: 20 },
  ];

  private categories: string[] = ['Category A', 'Category B', 'Category C'];

  getArticles(): Article[] {
    return this.articles;
  }

  getCategories(): string[] {
    return this.categories;
  }

  addArticle(article: Article): void {
    article.id = this.articles.length + 1;
    this.articles.push(article);
  }

  deleteArticle(articleId: number): void {
    this.articles = this.articles.filter((article) => article.id !== articleId);
  }
}
