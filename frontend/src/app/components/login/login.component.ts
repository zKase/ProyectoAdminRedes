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
    <div class="bg-background text-on-background min-h-screen flex items-center justify-center p-6 selection:bg-primary selection:text-white transition-colors duration-500">
      <div class="w-full max-w-md animate-fade-in">
          <div class="glass-card p-10 flex flex-col items-center gap-8 border border-outline-variant/30 shadow-elevated">
          <!-- Icon Circle -->
          <div class="w-16 h-16 rounded-full bg-primary flex items-center justify-center shadow-lg">
            <span class="material-symbols-outlined text-[32px] text-on-primary" style="font-variation-settings: 'FILL' 1;">shield_person</span>
          </div>
          
          <!-- Title Section -->
          <div class="text-center w-full">
            <h1 class="text-2xl font-bold text-primary tracking-tight">ProyectoAdminRedes</h1>
            <p class="text-sm text-on-surface-variant font-medium mt-1">Administrative Secure Login</p>
          </div>
          
          <!-- Form -->
          <form class="w-full flex flex-col gap-6" (ngSubmit)="onLogin()">
            <!-- Email Field -->
            <div class="flex flex-col gap-2">
              <label class="text-xs font-bold text-on-surface tracking-wide" for="email">Email Address</label>
              <div class="relative">
                <span class="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-on-surface-variant text-[18px]">mail</span>
                <input 
                  class="w-full pl-11 pr-4 py-3 rounded-lg border border-outline-variant/50 focus:border-primary focus:ring-1 focus:ring-primary/10 bg-surface-container-low text-sm text-on-surface outline-none transition-all" 
                  id="email" 
                  placeholder="admin@proyectoredes.gov" 
                  type="email"
                  [(ngModel)]="email"
                  name="email"
                  required
                />
              </div>
            </div>
            
            <!-- Password Field -->
            <div class="flex flex-col gap-2">
              <label class="text-xs font-bold text-on-surface tracking-wide" for="password">Password</label>
              <div class="relative">
                <span class="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-on-surface-variant text-[18px]">lock</span>
                <input 
                  class="w-full pl-11 pr-4 py-3 rounded-lg border border-outline-variant/50 focus:border-primary focus:ring-1 focus:ring-primary/10 bg-surface-container-low text-sm text-on-surface outline-none transition-all" 
                  id="password" 
                  placeholder="••••••••" 
                  type="password"
                  [(ngModel)]="password"
                  name="password"
                  required
                />
              </div>
            </div>
            
            <!-- Extra Options -->
            <div class="flex justify-between items-center w-full">
              <div class="flex items-center gap-2">
                <input class="w-4 h-4 rounded border-outline-variant/50 text-primary focus:ring-primary/20" id="remember" type="checkbox" [(ngModel)]="rememberMe" name="rememberMe"/>
                <label class="text-[11px] font-medium text-on-surface-variant" for="remember">Remember me</label>
              </div>
              <a class="text-[11px] font-bold text-primary hover:underline transition-all cursor-pointer">Forgot password?</a>
            </div>
            
            <!-- Action Button -->
            <button class="w-full bg-primary text-on-primary font-bold text-sm py-3.5 rounded-lg flex items-center justify-center gap-2 hover:bg-primary-hover transition-all duration-200 shadow-md active:scale-[0.98]" type="submit" [disabled]="isLoading()" [class.is-loading]="isLoading()">
              <span class="material-symbols-outlined text-[18px]">{{ isLoading() ? '' : 'login' }}</span>
              <span>{{ isLoading() ? 'Signing In...' : 'Sign In Securely' }}</span>
            </button>
          </form>
          
          <!-- Message Section -->
          <div *ngIf="errorMessage()" class="w-full bg-error-container/10 border border-error/20 rounded-lg p-3 text-error text-center text-xs font-medium">
            {{ errorMessage() }}
          </div>
          
          <!-- Secure Footer -->
          <div class="w-full pt-4 border-t border-outline-variant/10 text-center">
            <p class="text-[10px] text-on-surface-variant/60 font-medium tracking-wide">
              Authorized personnel only. Access is monitored.
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
