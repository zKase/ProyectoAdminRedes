import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, RouterModule } from '@angular/router';
import { AuthService } from '../../services/auth.service';
import { ToastComponent } from '../toast/toast.component';

@Component({
  selector: 'app-main-layout',
  standalone: true,
  imports: [CommonModule, RouterModule, ToastComponent],
  template: `
    <div class="bg-background text-on-background font-body min-h-screen flex selection:bg-primary selection:text-white">
      <app-toast></app-toast>
      <nav class="hidden md:flex flex-col h-screen w-72 fixed left-0 top-0 py-8 px-6 gap-6 border-r border-outline-variant bg-surface-container z-40 shadow-sm transition-all">
        <div class="flex items-center gap-4 pb-4 border-b border-outline-variant/50">
          <div class="w-12 h-12 rounded-xl bg-gradient-to-br from-primary to-accent flex items-center justify-center shadow-md">
            <span class="material-symbols-outlined text-white text-[24px]">public</span>
          </div>
          <div>
            <h1 class="font-heading-md text-lg font-bold text-on-surface tracking-tight leading-tight">Las Condes</h1>
            <p class="font-caption text-xs text-on-surface-variant font-medium mt-1 uppercase tracking-wider">Participación</p>
          </div>
        </div>

        <button (click)="navigate('/dashboard/proposals')" class="group relative overflow-hidden bg-primary text-white font-label text-sm py-3 px-4 rounded-xl flex items-center justify-center gap-2 hover:bg-primary-hover transition-all duration-300 shadow-md hover:shadow-lg active:scale-[0.98]">
          <div class="absolute inset-0 bg-white/20 translate-y-full group-hover:translate-y-0 transition-transform duration-300 ease-out"></div>
          <span class="material-symbols-outlined text-[20px] relative z-10">add</span>
          <span class="relative z-10 font-semibold">Nueva Propuesta</span>
        </button>

        <ul class="flex flex-col gap-1 flex-1 mt-4">
          <li><a routerLink="/dashboard/proposals" routerLinkActive="active-nav" class="nav-item"><span class="material-symbols-outlined">forum</span> Propuestas</a></li>
          <li><a routerLink="/dashboard/surveys" routerLinkActive="active-nav" class="nav-item"><span class="material-symbols-outlined">fact_check</span> Encuestas</a></li>
          <li><a routerLink="/dashboard/budgets" routerLinkActive="active-nav" class="nav-item"><span class="material-symbols-outlined">account_balance_wallet</span> Presupuestos</a></li>
          <li><a routerLink="/dashboard/issues" routerLinkActive="active-nav" class="nav-item"><span class="material-symbols-outlined">map</span> Mapeo</a></li>
          <li *ngIf="isAdmin()"><a routerLink="/dashboard/reports" routerLinkActive="active-nav" class="nav-item"><span class="material-symbols-outlined">assessment</span> Reportes</a></li>
          <li><a routerLink="/dashboard/chatbot" routerLinkActive="active-nav" class="nav-item"><span class="material-symbols-outlined">smart_toy</span> Asistente IA</a></li>
        </ul>

        <div class="mt-auto pt-4 border-t border-outline-variant/50 flex flex-col gap-2">
          <a *ngIf="isAdmin()" routerLink="/admin-dashboard" class="nav-item"><span class="material-symbols-outlined">admin_panel_settings</span> Panel Admin</a>
          <a (click)="logout()" class="nav-item text-error hover:bg-error/10 hover:text-error"><span class="material-symbols-outlined">logout</span> Cerrar sesión</a>
        </div>
      </nav>

      <div class="flex-1 flex flex-col md:ml-72 w-full bg-surface-container-lowest min-h-screen">
        <header class="sticky top-0 z-30 flex items-center justify-between px-8 py-4 w-full bg-surface/80 backdrop-blur-md border-b border-outline-variant shadow-sm transition-all">
          <div class="flex items-center gap-4 flex-1">
            <div class="md:hidden flex items-center gap-3">
               <div class="w-8 h-8 rounded-lg bg-gradient-to-br from-primary to-accent flex items-center justify-center shadow-sm">
                <span class="material-symbols-outlined text-white text-[16px]">public</span>
              </div>
              <span class="font-heading-md text-md font-bold text-on-surface">Las Condes</span>
            </div>
            <div class="hidden md:flex relative w-full max-w-md items-center group">
              <span class="material-symbols-outlined absolute left-4 text-on-surface-variant group-focus-within:text-primary transition-colors">search</span>
              <input class="w-full pl-12 pr-4 py-2.5 rounded-full border border-outline-variant focus:border-primary focus:ring-2 focus:ring-primary/20 bg-surface-container hover:bg-surface-container-high font-body text-sm text-on-surface outline-none transition-all" placeholder="Buscar en la plataforma..." type="text"/>
            </div>
          </div>
          <div class="flex items-center gap-4">
            <button class="relative text-on-surface-variant hover:bg-surface-container-high hover:text-primary p-2.5 rounded-full transition-all cursor-pointer active:scale-95 group">
              <span class="material-symbols-outlined group-hover:animate-wiggle">notifications</span>
              <span class="absolute top-2 right-2.5 w-2 h-2 bg-error rounded-full border-2 border-surface"></span>
            </button>
            <div class="w-10 h-10 rounded-full bg-gradient-to-br from-primary to-accent flex items-center justify-center cursor-pointer shadow-sm hover:shadow-md transition-all border border-white/20 text-white font-bold text-sm tracking-wider">
              {{ userInitials }}
            </div>
          </div>
        </header>

        <main class="flex-1 p-6 md:p-8 lg:p-10 overflow-y-auto w-full max-w-[1600px] mx-auto">
          <router-outlet></router-outlet>
        </main>
      </div>

      <!-- Mobile Bottom Nav -->
      <div class="md:hidden fixed bottom-0 left-0 right-0 bg-surface border-t border-outline-variant shadow-[0_-4px_6px_-1px_rgba(0,0,0,0.05)] z-40 pb-safe">
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
      @apply flex items-center gap-3 px-4 py-3 rounded-xl font-medium text-sm text-on-surface-variant hover:bg-surface-container-high hover:text-on-surface transition-all duration-200 cursor-pointer;
    }
    .active-nav {
      @apply bg-primary/10 text-primary font-semibold;
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

  get userInitials(): string {
    const user = this.auth.user();
    if (user) return (user.firstName[0] + user.lastName[0]).toUpperCase();
    return 'AD';
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
