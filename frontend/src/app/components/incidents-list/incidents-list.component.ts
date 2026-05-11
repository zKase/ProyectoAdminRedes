import { CommonModule } from '@angular/common';
import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router, RouterModule } from '@angular/router';
import { AuthService } from '../../services/auth.service';
import { PlatformService } from '../../services/platform.service';
import { Incident } from '../../models/platform.model';

@Component({
  selector: 'app-incidents-list',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule],
  template: `
    <div class="animate-fade-in">
      <!-- Header Section -->
      <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-md mb-xl">
        <div>
          <p class="font-caption text-caption uppercase tracking-[0.2em] text-primary font-bold mb-xs">Gestión de red</p>
          <h2 class="font-heading-lg text-heading-lg text-on-background">Incidentes técnicos</h2>
          <p class="font-body text-body text-on-surface-variant mt-xs">Administración y seguimiento de incidencias registradas en la plataforma.</p>
        </div>
        <button class="btn btn-primary">
          <span class="material-symbols-outlined">add</span>
          Nuevo incidente
        </button>
      </div>
      
      <!-- Filters & Search Bar -->
      <div class="glass-card p-md mb-lg flex flex-col md:flex-row gap-md items-end md:items-center border-primary/10">
        <div class="flex-1 w-full">
           <label class="font-label text-xs text-on-surface-variant block mb-2 px-1">Buscar por ID o título</label>
           <div class="relative group">
             <span class="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-on-surface-variant group-focus-within:text-primary transition-colors">search</span>
             <input class="input-glass pl-12" placeholder="Ej: INC-123..." type="text" [(ngModel)]="searchTerm" name="search"/>
          </div>
        </div>
        
        <div class="w-full md:w-48">
           <label class="font-label text-xs text-on-surface-variant block mb-2 px-1">Estado</label>
          <select class="input-glass" [(ngModel)]="selectedStatus" name="status">
             <option value="">Todos</option>
             <option value="Open">Abierto</option>
             <option value="In Progress">En progreso</option>
             <option value="Resolved">Resuelto</option>
             <option value="Closed">Cerrado</option>
          </select>
        </div>
        
        <div class="w-full md:w-48">
           <label class="font-label text-xs text-on-surface-variant block mb-2 px-1">Severidad</label>
          <select class="input-glass" [(ngModel)]="selectedSeverity" name="severity">
             <option value="">Todas</option>
             <option value="Critical">Crítica</option>
             <option value="High">Alta</option>
             <option value="Medium">Media</option>
             <option value="Low">Baja</option>
          </select>
        </div>
        
        <button (click)="loadIncidents()" class="btn btn-secondary h-[46px] px-md">
          <span class="material-symbols-outlined">refresh</span>
        </button>
      </div>
      
      <!-- Data Table -->
      <div class="glass-card overflow-hidden">
        <div class="overflow-x-auto">
          <table class="w-full text-left border-collapse">
             <thead>
              <tr class="bg-surface-container/50 border-b border-outline-variant">
                 <th class="font-label text-xs uppercase tracking-wider text-on-surface-variant py-4 px-6">ID</th>
                 <th class="font-label text-xs uppercase tracking-wider text-on-surface-variant py-4 px-6">Título</th>
                 <th class="font-label text-xs uppercase tracking-wider text-on-surface-variant py-4 px-6">Estado</th>
                 <th class="font-label text-xs uppercase tracking-wider text-on-surface-variant py-4 px-6">Prioridad</th>
                 <th class="font-label text-xs uppercase tracking-wider text-on-surface-variant py-4 px-6">Reportado</th>
                 <th class="font-label text-xs uppercase tracking-wider text-on-surface-variant py-4 px-6 text-right">Acciones</th>
              </tr>
            </thead>
            <tbody class="font-body text-sm">
              <tr *ngFor="let incident of filteredIncidents()" class="border-b border-outline-variant/50 hover:bg-white/[0.02] transition-colors">
                <td class="py-4 px-6 text-primary font-mono text-xs">{{ incident.id.substring(0,8) }}...</td>
                <td class="py-4 px-6 font-semibold text-on-surface">{{ incident.title }}</td>
                <td class="py-4 px-6">
                    <span [ngClass]="getStatusBadgeClass(incident.status)" class="inline-flex items-center gap-2 px-3 py-1 rounded-full text-[11px] font-bold uppercase tracking-wider">
                      <span class="w-1.5 h-1.5 rounded-full" [ngClass]="getStatusDotClass(incident.status)"></span>
                    {{ displayStatus(incident.status) }}
                  </span>
                </td>
                <td class="py-4 px-6">
                  <span [ngClass]="getSeverityClass(incident.priority || incident.severity)" class="font-semibold">{{ displayPriority(incident.priority || incident.severity) || 'N/A' }}</span>
                </td>
                <td class="py-4 px-6 text-on-surface-variant opacity-80">{{ incident.dateReported | date:'shortDate' }}</td>
                <td class="py-4 px-6 text-right">
                  <div class="flex justify-end gap-2">
                    <button [routerLink]="['/incidents', incident.id]" class="btn btn-secondary p-2 min-w-0" title="Ver detalles">
                      <span class="material-symbols-outlined text-[20px]">visibility</span>
                    </button>
                  </div>
                </td>
              </tr>
              <tr *ngIf="filteredIncidents().length === 0">
                <td colspan="6" class="py-12 text-center text-on-surface-variant italic opacity-60">No se encontraron incidentes registradas</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  `,
  styles: []
})
export class IncidentsListComponent implements OnInit {
  private platformService = inject(PlatformService);
  private router = inject(Router);

  searchTerm = '';
  selectedStatus = '';
  selectedSeverity = '';
  incidents = signal<Incident[]>([]);

  get filteredIncidents(): () => Incident[] {
    return () => {
      return this.incidents().filter(incident => {
        const matchesSearch = !this.searchTerm || 
          incident.id.toLowerCase().includes(this.searchTerm.toLowerCase()) ||
          incident.title.toLowerCase().includes(this.searchTerm.toLowerCase());
        
        const matchesStatus = !this.selectedStatus || incident.status === this.selectedStatus;
        const matchesSeverity = !this.selectedSeverity || 
          (incident.priority === this.selectedSeverity || incident.severity === this.selectedSeverity);
        
        return matchesSearch && matchesStatus && matchesSeverity;
      });
    };
  }

  ngOnInit() {
    this.loadIncidents();
  }

  loadIncidents() {
    this.platformService.getIncidents().subscribe({
      next: (data) => this.incidents.set(data),
      error: (err) => console.error('Error loading incidents:', err)
    });
  }

  getStatusBadgeClass(status: string): string {
    switch (status) {
      case 'Open': return 'bg-error-container text-error border border-error/20';
      case 'In Progress': return 'bg-primary-container text-primary border border-primary/20';
      case 'Resolved': return 'bg-success/10 text-success border border-success/20';
      case 'Closed': return 'bg-surface-container-high text-on-surface-variant border border-outline-variant';
      default: return 'bg-surface-container text-on-surface';
    }
  }

  getStatusDotClass(status: string): string {
    switch (status) {
      case 'Open': return 'bg-error';
      case 'In Progress': return 'bg-primary';
      case 'Resolved': return 'bg-success';
      case 'Closed': return 'bg-on-surface-variant';
      default: return 'bg-on-surface';
    }
  }

  getSeverityClass(severity: string | undefined): string {
    switch (severity) {
      case 'Critical': return 'text-error';
      case 'High': return 'text-accent';
      case 'Medium': return 'text-secondary';
      case 'Low': return 'text-on-surface-variant';
      default: return 'text-on-surface';
    }
  }

  displayStatus(status: string): string {
    switch (status) {
      case 'Open': return 'Abierto';
      case 'In Progress': return 'En progreso';
      case 'Resolved': return 'Resuelto';
      case 'Closed': return 'Cerrado';
      default: return status;
    }
  }

  displayPriority(priority: string | undefined): string | undefined {
    if (!priority) return undefined;
    switch (priority) {
      case 'Critical': return 'Crítica';
      case 'High': return 'Alta';
      case 'Medium': return 'Media';
      case 'Low': return 'Baja';
      default: return priority;
    }
  }
}
