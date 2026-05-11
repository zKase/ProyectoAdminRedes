import { CommonModule } from '@angular/common';
import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div class="bg-background text-on-background min-h-screen flex items-center justify-center p-md selection:bg-primary selection:text-white">
      <div class="w-full max-w-md animate-fade-in">
        <div class="glass-card p-xl flex flex-col items-center gap-lg">
          <!-- Icon -->
          <div class="w-20 h-20 rounded-2xl bg-gradient-to-br from-primary to-accent flex items-center justify-center mb-sm shadow-neon">
            <span class="material-symbols-outlined text-[40px] text-white" style="font-variation-settings: 'FILL' 1;">shield_person</span>
          </div>
          
          <!-- Title -->
          <div class="text-center w-full">
            <h1 class="font-heading-lg text-heading-lg text-primary drop-shadow-[0_0_10px_rgba(0,240,255,0.3)]">Las Condes</h1>
            <p class="font-body text-body text-on-surface-variant mt-2">Portal de Participación Ciudadana</p>
          </div>
          
          <!-- Form -->
          <form class="w-full flex flex-col gap-md" (ngSubmit)="onLogin()">
            <!-- Email Field -->
            <div class="flex flex-col gap-xs">
              <label class="font-label text-label text-on-surface-variant" for="email">Correo electrónico</label>
              <div class="relative group">
                <span class="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-on-surface-variant group-focus-within:text-primary transition-colors">mail</span>
                <input 
                  class="input-glass pl-12" 
                  id="email" 
                  placeholder="funcionario@lascondes.cl" 
                  type="email"
                  [(ngModel)]="email"
                  name="email"
                  required
                />
              </div>
            </div>
            
            <!-- Password Field -->
            <div class="flex flex-col gap-xs">
              <label class="font-label text-label text-on-surface-variant" for="password">Contraseña</label>
              <div class="relative group">
                <span class="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-on-surface-variant group-focus-within:text-primary transition-colors">lock</span>
                <input 
                  class="input-glass pl-12" 
                  id="password" 
                  placeholder="••••••••" 
                  type="password"
                  [(ngModel)]="password"
                  name="password"
                  required
                />
              </div>
            </div>
            
            <!-- Remember Me & Forgot Password -->
            <div class="flex justify-between items-center w-full">
              <div class="flex items-center gap-xs">
                <input class="rounded border-outline-variant bg-surface-container text-primary focus:ring-primary/50" id="remember" type="checkbox" [(ngModel)]="rememberMe" name="rememberMe"/>
                <label class="font-caption text-caption text-on-surface-variant" for="remember">Recuérdame</label>
              </div>
              <a class="font-label text-caption text-primary hover:underline transition-all cursor-pointer">¿Olvidó su contraseña?</a>
            </div>
            
            <!-- Sign In Button -->
            <button class="btn btn-primary w-full py-4 mt-2" type="submit" [disabled]="isLoading()" [class.is-loading]="isLoading()">
              <span class="material-symbols-outlined text-[20px]">{{ isLoading() ? '' : 'login' }}</span>
              {{ isLoading() ? 'Iniciando...' : 'Iniciar sesión' }}
            </button>
          </form>
          
          <!-- Error Message -->
          <div *ngIf="errorMessage()" class="w-full bg-error-container/20 border border-error/30 rounded-xl p-md text-error animate-fade-in text-center text-sm">
            {{ errorMessage() }}
          </div>
          
          <!-- Footer -->
          <div class="w-full pt-md border-t border-outline-variant/50 text-center">
            <p class="font-caption text-xs text-on-surface-variant opacity-60">
              Personal autorizado únicamente. Acceso monitoreado.
            </p>
          </div>
        </div>
      </div>
    </div>
  `,
  styles: []
})
export class LoginComponent {
  private authService = inject(AuthService);
  private router = inject(Router);

  email = '';
  password = '';
  rememberMe = false;
  isLoading = signal(false);
  errorMessage = signal<string | null>(null);

  onLogin() {
    if (!this.email || !this.password) {
      this.errorMessage.set('Por favor, complete todos los campos');
      return;
    }

    this.isLoading.set(true);
    this.errorMessage.set(null);

    this.authService.login(this.email, this.password).subscribe({
      next: () => {
        this.isLoading.set(false);
        this.router.navigate(['/dashboard']);
      },
      error: (err) => {
        this.isLoading.set(false);
        const errorMsg = err?.error?.message || 'Error al iniciar sesión. Compruebe sus credenciales.';
        this.errorMessage.set(errorMsg);
        console.error('Error de inicio de sesión:', err);
      }
    });
  }
}
