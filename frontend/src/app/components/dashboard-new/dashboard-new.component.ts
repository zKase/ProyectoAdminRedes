import { CommonModule } from '@angular/common';
import { Component, OnInit, inject, signal } from '@angular/core';
import { Router, RouterModule } from '@angular/router';
import { AuthService } from '../../services/auth.service';
import { PlatformService } from '../../services/platform.service';
import { Incident, Issue, Survey, Budget } from '../../models/platform.model';
import { Proposal } from '../../models/proposal.model';
import { ProposalService } from '../../services/proposal.service';
import { StaticMapComponent } from '../static-map/static-map.component';

@Component({
  selector: 'app-dashboard-new',
  standalone: true,
  imports: [CommonModule, RouterModule],
  template: `
<div class="animate-fade-in flex flex-col gap-lg lg:gap-xl">
  <div class="flex flex-col sm:flex-row justify-between items-start sm:items-end gap-md">
    <div>
      <p class="font-caption text-caption uppercase tracking-[0.2em] text-primary font-bold mb-xs">Panel de administración</p>
      <h2 class="font-heading-lg text-heading-lg text-on-surface">Resumen Ejecutivo</h2>
      <p class="font-body text-body text-on-surface-variant mt-xs">Métricas en tiempo real y estado de la red municipal.</p>
    </div>
    <div class="flex gap-sm">
      <button class="btn btn-secondary">
        <span class="material-symbols-outlined text-[18px]">calendar_today</span>
        Últimos 30 días
      </button>
      <button class="btn btn-primary" (click)="loadIncidents()">
        <span class="material-symbols-outlined">refresh</span>
      </button>
    </div>
  </div>
  
  <!-- Metrics Grid -->
  <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-md lg:gap-lg">
    <div class="glass-card p-lg flex flex-col gap-sm border-primary/5">
      <div class="flex justify-between items-start">
        <span class="font-label text-xs text-on-surface-variant uppercase tracking-wider">Usuarios totales</span>
        <span class="material-symbols-outlined text-primary bg-primary/10 p-2 rounded-xl">group</span>
      </div>
      <div class="font-heading-lg text-heading-lg text-on-surface">12,450</div>
      <div class="font-caption text-caption text-success flex items-center gap-xs">
        <span class="material-symbols-outlined text-[14px]">trending_up</span>
        +5.2% este mes
      </div>
    </div>
    
    <div class="glass-card p-lg flex flex-col gap-sm border-error/5">
      <div class="flex justify-between items-start">
        <span class="font-label text-xs text-on-surface-variant uppercase tracking-wider">Incidentes abiertos</span>
        <span class="material-symbols-outlined text-error bg-error/10 p-2 rounded-xl">warning</span>
      </div>
      <div class="font-heading-lg text-heading-lg text-on-surface">{{ openIncidents() }}</div>
      <div class="font-caption text-caption text-error flex items-center gap-xs">
        <span class="material-symbols-outlined text-[14px]">arrow_upward</span>
        +2 desde ayer
      </div>
    </div>
    
    <div class="glass-card p-lg flex flex-col gap-sm border-secondary/5">
      <div class="flex justify-between items-start">
        <span class="font-label text-xs text-on-surface-variant uppercase tracking-wider">Resueltos</span>
        <span class="material-symbols-outlined text-secondary bg-secondary/10 p-2 rounded-xl">check_circle</span>
      </div>
      <div class="font-heading-lg text-heading-lg text-on-surface">1,204</div>
      <div class="font-caption text-caption text-on-surface-variant flex items-center gap-xs">
        94% tasa de resolución
      </div>
    </div>
    
    <div class="glass-card p-lg flex flex-col gap-sm border-accent/5">
      <div class="flex justify-between items-start">
        <span class="font-label text-xs text-on-surface-variant uppercase tracking-wider">Respuesta prom.</span>
        <span class="material-symbols-outlined text-accent bg-accent/10 p-2 rounded-xl">timer</span>
      </div>
      <div class="font-heading-lg text-heading-lg text-on-surface">1.2h</div>
      <div class="font-caption text-caption text-accent flex items-center gap-xs">
        <span class="material-symbols-outlined text-[14px]">trending_down</span>
        -15m de mejora
      </div>
    </div>
  </div>
  
  <!-- Main Content Grid -->
  <div class="grid grid-cols-1 lg:grid-cols-3 gap-lg lg:gap-xl">
    <!-- Chart Area -->
    <div class="lg:col-span-2 glass-card p-lg flex flex-col gap-md">
      <div class="flex justify-between items-center mb-md">
        <h3 class="font-heading-md text-heading-md text-on-surface">Estado por categoría</h3>
        <button class="material-symbols-outlined text-on-surface-variant hover:text-primary transition-colors">more_vert</button>
      </div>
      
      <div class="flex-1 min-h-[300px] flex items-end gap-sm md:gap-md pt-xl border-b border-outline-variant relative">
        <div class="absolute left-0 top-0 h-full flex flex-col justify-between text-[10px] font-bold text-on-surface-variant/50 pb-md uppercase tracking-tighter">
          <span>100</span>
          <span>75</span>
          <span>50</span>
          <span>25</span>
          <span>0</span>
        </div>
        
        <div class="flex-1 h-full flex items-end justify-around pl-10 pb-xs">
          <!-- Conectividad -->
          <div class="flex gap-xs items-end h-full w-full max-w-[50px] group">
            <div class="w-full bg-primary/40 rounded-t-lg h-[60%] group-hover:bg-primary group-hover:shadow-neon transition-all relative">
              <div class="opacity-0 group-hover:opacity-100 absolute -top-10 left-1/2 -translate-x-1/2 bg-surface-container-highest text-primary font-bold px-2 py-1 rounded shadow-xl text-[10px] whitespace-nowrap transition-opacity border border-primary/20 z-10">60% Conect.</div>
            </div>
            <div class="w-full bg-secondary/20 rounded-t-lg h-[20%] group-hover:bg-secondary transition-all"></div>
          </div>
          <!-- Hardware -->
          <div class="flex gap-xs items-end h-full w-full max-w-[50px] group">
            <div class="w-full bg-primary/40 rounded-t-lg h-[85%] group-hover:bg-primary group-hover:shadow-neon transition-all relative">
              <div class="opacity-0 group-hover:opacity-100 absolute -top-10 left-1/2 -translate-x-1/2 bg-surface-container-highest text-primary font-bold px-2 py-1 rounded shadow-xl text-[10px] whitespace-nowrap transition-opacity border border-primary/20 z-10">85% Hardw.</div>
            </div>
            <div class="w-full bg-secondary/20 rounded-t-lg h-[15%] group-hover:bg-secondary transition-all"></div>
          </div>
          <!-- Seguridad -->
          <div class="flex gap-xs items-end h-full w-full max-w-[50px] group">
            <div class="w-full bg-primary/40 rounded-t-lg h-[40%] group-hover:bg-primary group-hover:shadow-neon transition-all relative">
               <div class="opacity-0 group-hover:opacity-100 absolute -top-10 left-1/2 -translate-x-1/2 bg-surface-container-highest text-primary font-bold px-2 py-1 rounded shadow-xl text-[10px] whitespace-nowrap transition-opacity border border-primary/20 z-10">40% Segur.</div>
            </div>
            <div class="w-full bg-secondary/20 rounded-t-lg h-[45%] group-hover:bg-secondary transition-all"></div>
          </div>
          <!-- Cuenta -->
          <div class="flex gap-xs items-end h-full w-full max-w-[50px] group">
            <div class="w-full bg-primary/40 rounded-t-lg h-[30%] group-hover:bg-primary group-hover:shadow-neon transition-all relative">
               <div class="opacity-0 group-hover:opacity-100 absolute -top-10 left-1/2 -translate-x-1/2 bg-surface-container-highest text-primary font-bold px-2 py-1 rounded shadow-xl text-[10px] whitespace-nowrap transition-opacity border border-primary/20 z-10">30% Cuent.</div>
            </div>
            <div class="w-full bg-secondary/20 rounded-t-lg h-[10%] group-hover:bg-secondary transition-all"></div>
          </div>
        </div>
      </div>
      
      <div class="flex justify-around pl-10 font-label text-[10px] text-on-surface-variant pt-sm uppercase tracking-wider">
        <span>Conectividad</span>
        <span>Hardware</span>
        <span>Seguridad</span>
        <span>Cuenta</span>
      </div>
      
      <div class="flex justify-center gap-md mt-md font-caption text-xs text-on-surface">
        <div class="flex items-center gap-xs"><div class="w-2 h-2 bg-primary/60 rounded-full shadow-neon"></div> Reportado</div>
        <div class="flex items-center gap-xs"><div class="w-2 h-2 bg-secondary/40 rounded-full"></div> Resuelto</div>
      </div>
    </div>
    
    <!-- Recent Incidents -->
    <div class="glass-card flex flex-col overflow-hidden border-primary/5">
      <div class="p-lg border-b border-outline-variant flex justify-between items-center bg-surface-container-low/30">
        <h3 class="font-heading-md text-heading-md text-on-surface">Recientes</h3>
        <button [routerLink]="['/incidents']" class="btn btn-secondary text-xs py-1 px-3 min-w-0">Ver todo</button>
      </div>
      
      <div class="flex-1 overflow-y-auto max-h-[400px]">
        <div *ngFor="let incident of incidents()" class="p-md border-b border-outline-variant/50 hover:bg-white/[0.02] transition-colors flex flex-col gap-sm cursor-pointer" [routerLink]="['/incidents', incident.id]">
          <div class="flex justify-between items-start">
            <span class="font-mono text-xs text-primary">{{ incident.id.substring(0,8) }}</span>
            <span [ngClass]="getPriorityClass(incident.priority)" class="px-2 py-0.5 font-bold text-[10px] rounded-full border uppercase tracking-wider flex items-center gap-1">
              <span class="w-1 h-1 rounded-full" [ngClass]="getPriorityDotClass(incident.priority)"></span>
              {{ displayPriority(incident.priority) }}
            </span>
          </div>
          <p class="font-body text-sm text-on-surface line-clamp-1">{{ incident.title }}</p>
          <div class="flex justify-between items-center mt-xs">
            <span class="font-caption text-[10px] text-on-surface-variant opacity-60">{{ incident.dateReported | date:'shortDate' }}</span>
            <span [ngClass]="getStatusClass(incident.status)" class="px-2 py-0.5 font-bold text-[9px] rounded-full uppercase tracking-tighter bg-surface-container-high border border-outline-variant text-on-surface-variant">
              {{ displayStatus(incident.status) }}
            </span>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
  `,
  styles: []
})
export class DashboardNewComponent implements OnInit {
  private authService = inject(AuthService);
  private platformService = inject(PlatformService);
  private proposalService = inject(ProposalService);
  private router = inject(Router);

  incidents = signal<Incident[]>([]);
  openIncidents = signal(0);
  
  issues = signal<Issue[]>([]);
  proposals = signal<Proposal[]>([]);
  surveys = signal<Survey[]>([]);
  budgets = signal<Budget[]>([]);
  
  activeTab = signal<'incidents' | 'mod_proposals' | 'mod_surveys' | 'mod_budgets' | 'mod_issues'>('incidents');

  get userInitials(): string {
    const user = this.authService.user();
    if (user) {
      return (user.firstName[0] + user.lastName[0]).toUpperCase();
    }
    return 'AD';
  }

  ngOnInit() {
    this.loadIncidents();
    this.loadModerationData();
  }

  loadModerationData() {
    this.platformService.getIssues().subscribe({
      next: (data) => this.issues.set(data),
      error: (err) => console.error(err)
    });
    this.proposalService.getProposals().subscribe({
      next: (data) => this.proposals.set(data),
      error: (err) => console.error(err)
    });
    this.platformService.getSurveys().subscribe({
      next: (data) => this.surveys.set(data),
      error: (err) => console.error(err)
    });
    this.platformService.getBudgets().subscribe({
      next: (data) => this.budgets.set(data),
      error: (err) => console.error(err)
    });
  }

  deleteIssue(id: string) {
    if (confirm('¿Estás seguro de eliminar esta problemática?')) {
      this.platformService.deleteIssue(id).subscribe({
        next: () => this.issues.update(list => list.filter(i => i.id !== id)),
        error: (err) => console.error(err)
      });
    }
  }

  updateIssueStatus(id: string, status: string) {
    this.platformService.updateIssueStatus(id, status).subscribe({
      next: (updated) => this.issues.update(list => list.map(i => i.id === id ? updated : i)),
      error: (err) => console.error(err)
    });
  }

  deleteProposal(id: string) {
    if (confirm('¿Estás seguro de eliminar esta propuesta?')) {
      this.proposalService.deleteProposal(id).subscribe({
        next: () => this.proposals.update(list => list.filter(p => p.id !== id)),
        error: (err) => console.error(err)
      });
    }
  }

  updateSurveyStatus(id: string, status: string) {
    this.platformService.updateSurveyStatus(id, status).subscribe({
      next: (updated) => this.surveys.update(list => list.map(s => s.id === id ? updated : s)),
      error: (err) => console.error(err)
    });
  }

  deleteSurvey(id: string) {
    if (confirm('¿Estás seguro de eliminar esta encuesta?')) {
      this.platformService.deleteSurvey(id).subscribe({
        next: () => this.surveys.update(list => list.filter(s => s.id !== id)),
        error: (err) => console.error(err)
      });
    }
  }

  updateBudgetStatus(id: string, status: string) {
    this.platformService.updateBudgetStatus(id, status).subscribe({
      next: (updated) => this.budgets.update(list => list.map(b => b.id === id ? updated : b)),
      error: (err) => console.error(err)
    });
  }

  deleteBudget(id: string) {
    if (confirm('¿Estás seguro de eliminar este presupuesto?')) {
      this.platformService.deleteBudget(id).subscribe({
        next: () => this.budgets.update(list => list.filter(b => b.id !== id)),
        error: (err) => console.error(err)
      });
    }
  }

  loadIncidents() {
    this.platformService.getIncidents().subscribe({
      next: (data) => {
        this.incidents.set(data);
        const openCount = data.filter(i => i.status === 'Open' || i.status === 'In Progress').length;
        this.openIncidents.set(openCount);
      },
      error: (err) => {
        console.error('Error loading incidents:', err);
      }
    });
  }

  navigate(path: string) {
    this.router.navigate([path]);
  }

  logout() {
    this.authService.logout();
    this.router.navigate(['/login']);
  }

  getPriorityClass(priority: string): string {
    switch (priority) {
      case 'High':
      case 'Critical':
        return 'bg-error-container/20 text-error border-error/20';
      case 'Medium':
        return 'bg-secondary-container text-on-secondary-container border-secondary/20';
      case 'Low':
        return 'bg-surface-variant text-on-surface-variant border-outline-variant';
      default:
        return '';
    }
  }

  getPriorityDotClass(priority: string): string {
    switch (priority) {
      case 'High':
      case 'Critical':
        return 'bg-error';
      case 'Medium':
        return 'bg-primary-container';
      case 'Low':
        return 'bg-outline';
      default:
        return '';
    }
  }

  getStatusClass(status: string): string {
    switch (status) {
      case 'Open':
        return 'bg-surface-container-high text-on-surface-variant border border-outline-variant';
      case 'In Progress':
        return 'bg-primary-container text-primary border border-primary/20';
      case 'Resolved':
      case 'Closed':
        return 'bg-success/10 text-success border border-success/20';
      default:
        return '';
    }
  }

  // Spanish display for priority
  displayPriority(priority: string): string {
    switch (priority) {
      case 'Critical':
        return 'Crítica';
      case 'High':
        return 'Alta';
      case 'Medium':
        return 'Media';
      case 'Low':
        return 'Baja';
      default:
        return priority;
    }
  }

  // Spanish display for status
  displayStatus(status: string): string {
    switch (status) {
      case 'Open':
        return 'Abierto';
      case 'In Progress':
        return 'En progreso';
      case 'Resolved':
        return 'Resuelto';
      case 'Closed':
        return 'Cerrado';
      default:
        return status;
    }
  }

  displayIssueStatus(status: string): string {
    switch (status) {
      case 'OPEN': return 'Abierta';
      case 'IN_REVIEW': return 'En revisión';
      case 'RESOLVED': return 'Resuelta';
      case 'CLOSED': return 'Cerrada';
      default: return status;
    }
  }

  displaySurveyBudgetStatus(status: string): string {
    switch (status) {
      case 'DRAFT': return 'Borrador';
      case 'ACTIVE': return 'Activo';
      case 'CLOSED': return 'Cerrado';
      default: return status;
    }
  }

  getStatusBadgeClass(status: string): string {
    const base = 'rounded-full px-sm py-xs border font-bold text-xs uppercase tracking-wider ';
    switch (status) {
      case 'OPEN':
      case 'ACTIVE':
        return base + 'bg-[#dcfce7] text-[#166534] border-[#bbf7d0]'; // green
      case 'IN_REVIEW':
        return base + 'bg-[#dbeafe] text-[#1e40af] border-[#bfdbfe]'; // blue
      case 'DRAFT':
        return base + 'bg-[#fef9c3] text-[#854d0e] border-[#fef08a]'; // yellow
      case 'RESOLVED':
        return base + 'bg-[#ccfbf1] text-[#115e59] border-[#99f6e4]'; // teal
      case 'CLOSED':
        return base + 'bg-[#fee2e2] text-[#991b1b] border-[#fca5a5]'; // red
      default:
        return base + 'bg-surface-container-lowest text-on-surface-variant border-outline-variant';
    }
  }
}
