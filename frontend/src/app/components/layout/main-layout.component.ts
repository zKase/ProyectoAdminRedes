import { Component, inject, signal, effect } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, RouterModule } from '@angular/router';
import { AuthService } from '../../services/auth.service';
import { ToastComponent } from '../toast/toast.component';
import { ChatComponent } from '../chat/chat.component';

@Component({
  selector: 'app-main-layout',
  standalone: true,
  imports: [CommonModule, RouterModule, ToastComponent, ChatComponent],
  template: `
    <div class="bg-background text-on-background font-body min-h-screen flex selection:bg-primary selection:text-white transition-colors duration-500">
      <app-toast></app-toast>
      <app-chat></app-chat>
      
      <!-- Desktop Sidebar -->
      <nav class="hidden md:flex flex-col h-screen w-72 fixed left-0 top-0 py-8 px-6 gap-6 border-r border-outline-variant bg-surface/90 backdrop-blur-lg z-40 transition-all duration-500">
        <!-- Logo Section -->
        <div class="flex items-center gap-3 px-2 mb-2">
          <div class="w-10 h-10 rounded-full bg-primary flex items-center justify-center shadow-sm">
            <span class="material-symbols-outlined text-on-primary text-[22px]">public</span>
          </div>
          <div class="flex flex-col">
            <h1 class="font-heading-md text-[18px] font-bold text-on-surface leading-none">Las Condes</h1>
            <span class="text-[11px] text-on-surface-variant font-medium mt-1">Plataforma Ciudadana</span>
          </div>
        </div>

        <!-- Action Button -->
        <div class="px-2">
          <button (click)="navigate('/dashboard/proposals')" class="w-full bg-primary text-on-primary font-label text-sm py-3 px-4 rounded-lg flex items-center justify-center gap-2 hover:bg-primary-hover transition-all duration-200 shadow-sm active:scale-[0.98]">
            <span class="material-symbols-outlined text-[20px]">add</span>
            <span class="font-semibold">Nueva Propuesta</span>
          </button>
        </div>

        <!-- Nav Menu -->
        <ul class="flex flex-col gap-1 flex-1 px-1">
          <li>
            <a routerLink="/dashboard/proposals" routerLinkActive="active-nav" class="nav-item">
              <span class="material-symbols-outlined">dashboard</span> 
              <span>Resumen</span>
            </a>
          </li>
          <li>
            <a routerLink="/dashboard/surveys" routerLinkActive="active-nav" class="nav-item">
              <span class="material-symbols-outlined">fact_check</span> 
              <span>Encuestas</span>
            </a>
          </li>
          <li>
            <a routerLink="/dashboard/budgets" routerLinkActive="active-nav" class="nav-item">
              <span class="material-symbols-outlined">account_balance_wallet</span> 
              <span>Presupuestos</span>
            </a>
          </li>
          <li>
            <a routerLink="/dashboard/issues" routerLinkActive="active-nav" class="nav-item">
              <span class="material-symbols-outlined">map</span> 
              <span>Mapa de Problemas</span>
            </a>
          </li>
          <li *ngIf="isAdmin()">
            <a routerLink="/dashboard/reports" routerLinkActive="active-nav" class="nav-item">
              <span class="material-symbols-outlined">assessment</span> 
              <span>Reportes Admin</span>
            </a>
          </li>
        </ul>

        <!-- Bottom Menu -->
        <div class="mt-auto pt-6 border-t border-outline-variant/30 flex flex-col gap-1 px-1">
          <a class="nav-item opacity-80 hover:opacity-100"><span class="material-symbols-outlined">settings</span> Configuración</a>
          <a (click)="logout()" class="nav-item text-on-surface-variant hover:text-error">
            <span class="material-symbols-outlined">logout</span> 
            <span>Cerrar sesión</span>
          </a>
        </div>
      </nav>

      <div class="flex-1 flex flex-col md:ml-72 w-full bg-background min-h-screen transition-colors duration-500">
        <header class="sticky top-0 z-30 flex items-center justify-between px-8 py-4 w-full bg-surface/60 backdrop-blur-md border-b border-outline-variant transition-all duration-500">
          <!-- Search Bar Area -->
          <div class="flex items-center gap-4 flex-1">
             <div class="hidden md:flex relative w-full max-w-lg items-center group">
              <span class="material-symbols-outlined absolute left-4 text-on-surface-variant">search</span>
              <input class="w-full pl-12 pr-4 py-2.5 rounded-lg border border-outline-variant/50 focus:border-primary focus:ring-1 focus:ring-primary/10 bg-surface-container-low font-body text-sm text-on-surface outline-none transition-all" placeholder="Buscar propuestas, reportes o incidencias..." type="text"/>
            </div>
            
            <div class="md:hidden flex items-center gap-2">
               <div class="w-8 h-8 rounded-lg bg-primary flex items-center justify-center">
                <span class="material-symbols-outlined text-on-primary text-[16px]">public</span>
              </div>
              <span class="font-heading-md text-md font-bold text-on-surface">Las Condes</span>
            </div>
          </div>
          
          <!-- User Controls Area -->
          <div class="flex items-center gap-3">
            <button (click)="toggleTheme()" class="text-on-surface-variant hover:bg-surface-container-high p-2 rounded-lg transition-all" title="Cambiar tema">
              <span class="material-symbols-outlined">{{ isDark() ? 'light_mode' : 'dark_mode' }}</span>
            </button>

            <button class="relative text-on-surface-variant hover:bg-surface-container-high p-2 rounded-lg transition-all">
              <span class="material-symbols-outlined">notifications</span>
              <span class="absolute top-2 right-2.5 w-2 h-2 bg-error rounded-full border-2 border-surface"></span>
            </button>
            
            <div class="flex items-center gap-3 pl-2 ml-2 border-l border-outline-variant/30">
              <div class="flex flex-col items-end hidden sm:flex">
                <span class="text-xs font-bold text-on-surface">{{ auth.user()?.firstName }} {{ auth.user()?.lastName }}</span>
                <span class="text-[10px] text-on-surface-variant uppercase tracking-tighter">{{ auth.user()?.role }}</span>
              </div>
              <div class="w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center border border-primary/20 text-primary font-bold text-sm">
                {{ userInitials }}
              </div>
            </div>
          </div>
        </header>

        <main class="flex-1 p-8 lg:p-10 overflow-y-auto w-full max-w-[1600px] mx-auto bg-background/50">
          <router-outlet></router-outlet>
        </main>
      </div>

      <!-- Mobile Bottom Nav -->
      <div class="md:hidden fixed bottom-0 left-0 right-0 bg-surface border-t border-outline-variant shadow-[0_-4px_6px_-1px_rgba(0,0,0,0.05)] z-40 pb-safe transition-colors duration-500">
        <div class="flex justify-around items-center p-2">
          <a routerLink="/dashboard/proposals" routerLinkActive="text-primary bg-primary/10" class="flex flex-col items-center gap-1 p-2 rounded-xl text-on-surface-variant transition-colors min-w-[64px]">
            <span class="material-symbols-outlined text-[24px]">forum</span>
            <span class="text-[10px] font-medium">Propuestas</span>
          </a>
          <a routerLink="/dashboard/surveys" routerLinkActive="text-primary bg-primary/10" class="flex flex-col items-center gap-1 p-2 rounded-xl text-on-surface-variant transition-colors min-w-[64px]">
            <span class="material-symbols-outlined text-[24px]">fact_check</span>
            <span class="text-[10px] font-medium">Encuestas</span>
          </a>
          <a routerLink="/dashboard/budgets" routerLinkActive="text-primary bg-primary/10" class="flex flex-col items-center gap-1 p-2 rounded-xl text-on-surface-variant transition-colors min-w-[64px]">
            <span class="material-symbols-outlined text-[24px]">account_balance_wallet</span>
            <span class="text-[10px] font-medium">Presupuestos</span>
          </a>
          <a routerLink="/dashboard/issues" routerLinkActive="text-primary bg-primary/10" class="flex flex-col items-center gap-1 p-2 rounded-xl text-on-surface-variant transition-colors min-w-[64px]">
            <span class="material-symbols-outlined text-[24px]">map</span>
            <span class="text-[10px] font-medium">Mapeo</span>
          </a>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .nav-item {
      display: flex;
      align-items: center;
      gap: 1rem;
      padding: 0.875rem 1rem;
      border-radius: 0.5rem;
      font-weight: 500;
      font-size: 0.875rem;
      color: rgb(var(--on-surface-variant));
      transition: all 0.2s ease;
      cursor: pointer;
    }
    .nav-item:hover {
      background-color: rgb(var(--surface-container-high));
      color: rgb(var(--primary));
    }
    .active-nav {
      background-color: rgb(var(--primary)) !important;
      color: rgb(var(--on-primary)) !important;
      box-shadow: 0 4px 6px -1px rgba(var(--primary), 0.2);
    }
    .active-nav .material-symbols-outlined {
      font-variation-settings: 'FILL' 1;
    }
    @keyframes wiggle {
      0%, 100% { transform: rotate(-3deg); }
      50% { transform: rotate(3deg); }
    }
    .animate-wiggle {
      animation: wiggle 0.3s ease-in-out infinite;
    }
  `]
})
export class MainLayoutComponent {
  auth = inject(AuthService);
  router = inject(Router);

  isDark = signal<boolean>(false);

  constructor() {
    // Initialize theme from localStorage or system preference
    const savedTheme = localStorage.getItem('theme');
    this.isDark.set(savedTheme === 'dark');

    // Apply theme effect
    effect(() => {
      const dark = this.isDark();
      if (dark) {
        document.documentElement.classList.add('dark');
        localStorage.setItem('theme', 'dark');
      } else {
        document.documentElement.classList.remove('dark');
        localStorage.setItem('theme', 'light');
      }
    });
  }

  get userInitials(): string {
    const user = this.auth.user();
    if (user) return (user.firstName[0] + user.lastName[0]).toUpperCase();
    return 'AD';
  }

  toggleTheme() {
    this.isDark.update(v => !v);
  }

  navigate(path: string) {
    this.router.navigate([path]);
  }

  logout() {
    this.auth.logout();
    this.router.navigate(['/login']);
  }

  isAdmin() {
    const role = this.auth.user()?.role;
    return role === 'ADMIN' || role === 'MODERATOR';
  }
}
