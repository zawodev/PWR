import { Component, inject } from '@angular/core';
import { ArticleService } from './services/article.service';
import { HeaderComponent } from './components/header/header.component';
import { FooterComponent } from './components/footer/footer.component';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [HeaderComponent, FooterComponent, CommonModule, FormsModule],
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  private articleService = inject(ArticleService);

  articles = this.articleService.articles;
  categories = this.articleService.categories;

  currentArticle = { name: '', price: 0, category: '', image_path: null as string | null };
  editedArticle: { id: number; name: string; price: number; category: string; image_path: string | null } | null = null;
  showAddArticle = false;

  toggleAddArticle() {
    this.showAddArticle = !this.showAddArticle;
    this.currentArticle = { name: '', price: 0, category: '', image_path: null };
    this.editedArticle = null;
  }

  addArticle() {
    this.articleService.addArticle(this.currentArticle);
    this.toggleAddArticle();
  }

  deleteArticle(id: number) {
    this.articleService.deleteArticle(id);
  }

  startEdit(article: { id: number; name: string; price: number; category: string; image_path: string | null }) {
    this.editedArticle = { ...article };
    this.currentArticle = { ...article };
    this.showAddArticle = true;
  }

  editArticle() {
    if (this.editedArticle) {
      this.articleService.editArticle(this.editedArticle.id, this.currentArticle);
      this.toggleAddArticle();
    }
  }

  getPlaceholderImage() {
    return '/assets/placeholder.png';
  }
}
