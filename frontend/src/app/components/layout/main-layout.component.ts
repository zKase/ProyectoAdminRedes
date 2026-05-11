import { Component, inject, signal, effect } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, RouterModule } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { of, forkJoin } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { AuthService } from '../../services/auth.service';
import { PlatformService } from '../../services/platform.service';
import { ProposalService } from '../../services/proposal.service';
import { ToastComponent } from '../toast/toast.component';
import { ChatComponent } from '../chat/chat.component';

interface SearchGroup {
  label: string;
  items: SearchItem[];
}

interface SearchItem {
  id: string;
  title: string;
  subtitle: string;
  icon: string;
  iconColor?: string;
  badge: string;
  route: string[];
}

@Component({
  selector: 'app-main-layout',
  standalone: true,
  imports: [CommonModule, RouterModule, FormsModule, ToastComponent, ChatComponent],
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
        <header class="sticky top-0 z-30 flex items-center justify-between px-8 py-4 w-full bg-surface/60 backdrop-blur-md border-b border-outline-variant transition-all duration-500" style="isolation:isolate">
           <!-- Search Bar Area -->
          <div class="flex items-center gap-4 flex-1 relative">
             <div class="hidden md:flex relative w-full max-w-lg flex-col">
              <div class="relative">
                <span class="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-on-surface-variant">search</span>
                <input
                  class="w-full pl-12 pr-4 py-2.5 rounded-lg border border-outline-variant/50 focus:border-primary focus:ring-1 focus:ring-primary/10 bg-surface-container-low font-body text-sm text-on-surface outline-none transition-all"
                  placeholder="Buscar propuestas, reportes o incidencias..." type="text"
                  [(ngModel)]="searchQuery" name="search"
                  (input)="onSearchInput()"
                  (keydown.escape)="showResults.set(false)"
                  (blur)="onSearchBlur()"
                  (focus)="onSearchFocus()"/>
                <button *ngIf="searchQuery()" (click)="clearSearch()" class="absolute right-3 top-1/2 -translate-y-1/2 text-on-surface-variant hover:text-on-surface transition-colors p-0.5">
                  <span class="material-symbols-outlined text-[18px]">close</span>
                </button>
              </div>
                <div *ngIf="showResults() && searchQuery().trim().length >= 2" class="absolute top-full left-0 mt-1 w-full bg-surface-container-lowest border border-outline-variant rounded-xl shadow-elevated overflow-hidden z-50 animate-fade-in search-dropdown" (mousedown)="$event.preventDefault()">
                <ng-template [ngIf]="isSearching()">
                  <div class="flex items-center gap-3 px-5 py-4 text-on-surface-variant text-sm">
                    <span class="material-symbols-outlined animate-spin text-[18px]">sync</span>
                    Buscando...
                  </div>
                </ng-template>
                <ng-template [ngIf]="!isSearching() && searchResults().length === 0">
                  <div class="px-5 py-6 text-center text-on-surface-variant text-sm">
                    <span class="material-symbols-outlined text-[32px] block mb-2 opacity-40">search_off</span>
                    Sin resultados para "{{ searchQuery() }}"
                  </div>
                </ng-template>
                <ng-template [ngIf]="!isSearching() && searchResults().length > 0">
                  <div class="max-h-[360px] overflow-y-auto">
                    <ng-container *ngFor="let group of searchResults()">
                      <div class="px-4 pt-3 pb-1">
                        <span class="text-[10px] font-bold uppercase tracking-widest text-on-surface-variant/60">{{ group.label }}</span>
                      </div>
                      <button *ngFor="let item of group.items" (click)="navigateToResult(item)" class="w-full flex items-start gap-3 px-4 py-2.5 hover:bg-surface-container-high transition-colors text-left">
                        <span class="material-symbols-outlined text-[18px] mt-0.5" [class.text-primary]="!item.iconColor" [style.color]="item.iconColor">{{ item.icon }}</span>
                        <div class="flex-1 min-w-0">
                          <div class="text-sm font-medium text-on-surface truncate">{{ item.title }}</div>
                          <div class="text-xs text-on-surface-variant truncate">{{ item.subtitle }}</div>
                        </div>
                        <span class="text-[10px] font-bold uppercase tracking-wider text-on-surface-variant/50 mt-1">{{ item.badge }}</span>
                      </button>
                    </ng-container>
                  </div>
                </ng-template>
              </div>
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
  private platformService = inject(PlatformService);
  private proposalService = inject(ProposalService);

  isDark = signal<boolean>(false);

  searchQuery = signal('');
  searchResults = signal<SearchGroup[]>([]);
  showResults = signal(false);
  isSearching = signal(false);
  private searchDebounce: any;

  // Cache for searchable data
  private cache = {
    proposals: signal<any[] | null>(null),
    surveys: signal<any[] | null>(null),
    budgets: signal<any[] | null>(null),
    issues: signal<any[] | null>(null),
    incidents: signal<any[] | null>(null),
  };

  constructor() {
    const savedTheme = localStorage.getItem('theme');
    this.isDark.set(savedTheme === 'dark');

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

  clearSearch() {
    this.searchQuery.set('');
    this.searchResults.set([]);
    this.showResults.set(false);
  }

  onSearchBlur() {
    setTimeout(() => this.showResults.set(false), 200);
  }

  onSearchFocus() {
    const q = this.searchQuery().trim();
    if (q.length >= 2) this.showResults.set(true);
  }

  onSearchInput() {
    clearTimeout(this.searchDebounce);
    this.searchDebounce = setTimeout(() => this.performSearch(), 250);
  }

  private performSearch() {
    const q = this.searchQuery().trim().toLowerCase();
    if (q.length < 2) {
      this.searchResults.set([]);
      this.showResults.set(false);
      return;
    }

    this.isSearching.set(true);
    this.showResults.set(true);

    this.loadAndSearch(q);
  }

  private loadAndSearch(q: string) {
    const needsFetch = (cache: any) => cache() === null;

    const fetchProposals = needsFetch(this.cache.proposals)
      ? this.proposalService.getProposals().pipe(catchError(() => of([])))
      : of(this.cache.proposals()!);

    const fetchSurveys = needsFetch(this.cache.surveys)
      ? this.platformService.getSurveys().pipe(catchError(() => of([])))
      : of(this.cache.surveys()!);

    const fetchBudgets = needsFetch(this.cache.budgets)
      ? this.platformService.getBudgets().pipe(catchError(() => of([])))
      : of(this.cache.budgets()!);

    const fetchIssues = needsFetch(this.cache.issues)
      ? this.platformService.getIssues().pipe(catchError(() => of([])))
      : of(this.cache.issues()!);

    const fetchIncidents = needsFetch(this.cache.incidents)
      ? this.platformService.getIncidents().pipe(catchError(() => of([])))
      : of(this.cache.incidents()!);

    forkJoin({
      proposals: fetchProposals,
      surveys: fetchSurveys,
      budgets: fetchBudgets,
      issues: fetchIssues,
      incidents: fetchIncidents,
    }).subscribe({
      next: (data) => {
        this.cache.proposals.set(data.proposals as any[]);
        this.cache.surveys.set(data.surveys as any[]);
        this.cache.budgets.set(data.budgets as any[]);
        this.cache.issues.set(data.issues as any[]);
        this.cache.incidents.set(data.incidents as any[]);
        this.filterResults(q, data);
      },
      error: () => {
        this.isSearching.set(false);
      },
    });
  }

  private filterResults(q: string, data: any) {
    const groups: SearchGroup[] = [];

    // Normalize function to strip diacritics (tildes) and lowercase for accent-insensitive matching
    const stripDiacritics = (s: string) => {
      if (!s) return '';
      // Use Unicode NFD normalization to separate base characters and combining marks,
      // then remove the combining diacritic marks in the U+0300..U+036F range.
      // This makes matching accent-insensitive (e.g. 'á' -> 'a').
      return s.normalize('NFD').replace(/[\u0300-\u036F]/g, '').toLowerCase();
    };

    const nq = stripDiacritics(q);
    const match = (text: string) => stripDiacritics(text || '').includes(nq);

    // Proposals
    const proposals = (data.proposals as any[] || []).filter(
      (p: any) => match(p.title) || match(p.description) || match(p.category)
    ).slice(0, 5);
    if (proposals.length) {
      groups.push({
        label: 'Propuestas',
        items: proposals.map((p: any) => ({
          id: p.id,
          title: p.title,
          subtitle: p.description?.substring(0, 80) + (p.description?.length > 80 ? '...' : ''),
          icon: 'forum',
          badge: p.category || 'Propuesta',
          route: ['/dashboard', 'proposals'],
        })),
      });
    }

    // Surveys
    const surveys = (data.surveys as any[] || []).filter(
      (s: any) => match(s.title) || match(s.description)
    ).slice(0, 5);
    if (surveys.length) {
      groups.push({
        label: 'Encuestas',
        items: surveys.map((s: any) => ({
          id: s.id,
          title: s.title,
          subtitle: s.description?.substring(0, 80) + (s.description?.length > 80 ? '...' : ''),
          icon: 'fact_check',
          badge: s.status,
          route: ['/dashboard', 'surveys'],
        })),
      });
    }

    // Budgets
    const budgets = (data.budgets as any[] || []).filter(
      (b: any) => match(b.title) || match(b.description)
    ).slice(0, 5);
    if (budgets.length) {
      groups.push({
        label: 'Presupuestos',
        items: budgets.map((b: any) => ({
          id: b.id,
          title: b.title,
          subtitle: b.description?.substring(0, 80) + (b.description?.length > 80 ? '...' : ''),
          icon: 'account_balance_wallet',
          badge: b.status,
          route: ['/dashboard', 'budgets'],
        })),
      });
    }

    // Issues
    const issues = (data.issues as any[] || []).filter(
      (i: any) => match(i.title) || match(i.description) || match(i.category)
    ).slice(0, 5);
    if (issues.length) {
      groups.push({
        label: 'Problemas Territoriales',
        items: issues.map((i: any) => ({
          id: i.id,
          title: i.title,
          subtitle: i.category,
          icon: 'map',
          iconColor: '#ef4444',
          badge: i.status,
          route: ['/dashboard', 'issues'],
        })),
      });
    }

    // Incidents
    const incidents = (data.incidents as any[] || []).filter(
      (i: any) => match(i.title) || match(i.description) || match(i.id)
    ).slice(0, 5);
    if (incidents.length) {
      groups.push({
        label: 'Incidencias Técnicas',
        items: incidents.map((i: any) => ({
          id: i.id,
          title: i.title,
          subtitle: i.id.substring(0, 8) + '...',
          icon: 'warning',
          iconColor: '#f59e0b',
          badge: i.priority || i.severity || '',
          route: ['/incidents', i.id],
        })),
      });
    }

    this.searchResults.set(groups);
    this.isSearching.set(false);
  }

  navigateToResult(item: SearchItem) {
    this.clearSearch();
    this.router.navigate(item.route);
  }
}
