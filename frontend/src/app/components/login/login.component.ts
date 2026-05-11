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
    <div class="bg-background text-on-background min-h-screen flex items-center justify-center p-md">
      <div class="w-full max-w-md">
        <div class="bg-surface-container-low rounded-[18px] border border-outline-variant p-xl shadow-sm flex flex-col items-center gap-lg">
          <!-- Icon -->
          <div class="w-24 h-24 rounded-full bg-primary-container flex items-center justify-center mb-sm">
            <span class="material-symbols-outlined text-[48px] text-on-primary" style="font-variation-settings: 'FILL' 1;">shield_person</span>
          </div>
          
          <!-- Title -->
          <div class="text-center space-y-sm w-full">
            <h1 class="font-heading-lg text-heading-lg text-[#0052b5]">Municipalidad de Las Condes</h1>
            <p class="font-body text-body text-on-surface-variant">Portal de participación ciudadana</p>
          </div>
          
          <!-- Form -->
          <form class="w-full space-y-md flex flex-col mt-sm" (ngSubmit)="onLogin()">
            <!-- Email Field -->
            <div class="flex flex-col gap-xs">
                <label class="font-label text-label text-on-surface" for="email">Correo electrónico</label>
              <div class="relative">
                <span class="material-symbols-outlined absolute left-sm top-1/2 -translate-y-1/2 text-outline">mail</span>
                <input 
                  class="w-full pl-xl pr-sm py-sm bg-surface-container-lowest border border-outline-variant rounded-lg font-body text-body focus:ring-2 focus:ring-primary-container focus:border-primary-container transition-all outline-none" 
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
                <label class="font-label text-label text-on-surface" for="password">Contraseña</label>
              <div class="relative">
                <span class="material-symbols-outlined absolute left-sm top-1/2 -translate-y-1/2 text-outline">lock</span>
                <input 
                  class="w-full pl-xl pr-sm py-sm bg-surface-container-lowest border border-outline-variant rounded-lg font-body text-body focus:ring-2 focus:ring-primary-container focus:border-primary-container transition-all outline-none" 
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
            <div class="flex justify-between items-center w-full pt-xs pb-sm">
              <div class="flex items-center gap-xs">
                <input class="rounded text-primary focus:ring-primary border-outline-variant" id="remember" type="checkbox" [(ngModel)]="rememberMe" name="rememberMe"/>
                <label class="font-caption text-caption text-on-surface-variant" for="remember">Recuérdame</label>
              </div>
              <a class="font-label text-label text-primary hover:text-primary-container transition-colors cursor-pointer" href="#">¿Olvidó su contraseña?</a>
            </div>
            
            <!-- Sign In Button -->
            <button class="w-full bg-primary-container text-on-primary font-label text-label py-md rounded-[18px] hover:bg-primary transition-colors flex justify-center items-center gap-xs disabled:opacity-50 disabled:cursor-not-allowed" type="submit" [disabled]="isLoading()">
              <span class="material-symbols-outlined text-[20px]">{{ isLoading() ? 'hourglass_empty' : 'login' }}</span>
              {{ isLoading() ? 'Iniciando sesión...' : 'Iniciar sesión' }}
            </button>
          </form>
          
          <!-- Error Message -->
          <div *ngIf="errorMessage()" class="w-full bg-error-container border border-error rounded-lg p-md text-error">
            <p class="font-body text-body">{{ errorMessage() }}</p>
          </div>
          
          <!-- Footer -->
          <div class="w-full pt-md border-t border-outline-variant text-center">
            <p class="font-caption text-caption text-outline">
              Personal autorizado únicamente. El acceso está monitoreado.
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
