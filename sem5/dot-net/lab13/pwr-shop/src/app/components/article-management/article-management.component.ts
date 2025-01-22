import { Component } from '@angular/core';
import { Article, ArticleService } from '../../services/article.service';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-article-management',
  templateUrl: './article-management.component.html',
  imports: [FormsModule],
  styleUrls: ['./article-management.component.css'],
})
export class ArticleManagementComponent {
  articles: Article[] = [];
  categories: string[] = [];
  newArticle: Partial<Article> = {
    name: '',
    category: '',
    price: 0,
  };

  constructor(private articleService: ArticleService) {
    this.articles = this.articleService.getArticles();
    this.categories = this.articleService.getCategories();
  }

  addArticle(): void {
    if (this.newArticle.name && this.newArticle.category) {
      this.articleService.addArticle(this.newArticle as Article);
      this.newArticle = { name: '', category: '', price: 0 };
    }
  }

  deleteArticle(articleId: number): void {
    this.articleService.deleteArticle(articleId);
    this.articles = this.articleService.getArticles();
  }
}
