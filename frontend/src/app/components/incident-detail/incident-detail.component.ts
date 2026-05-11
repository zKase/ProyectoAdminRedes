import { CommonModule } from '@angular/common';
import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, Router, RouterModule } from '@angular/router';
import { AuthService } from '../../services/auth.service';
import { PlatformService } from '../../services/platform.service';
import { Incident } from '../../models/platform.model';

interface TimelineItem {
  action: string;
  author: string;
  timestamp: string;
  comment?: string;
}

@Component({
  selector: 'app-incident-detail',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule],
  template: `
    <div class="animate-fade-in flex flex-col gap-lg pb-10">
      <!-- Header Actions -->
      <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-md">
          <button [routerLink]="['/incidents']" class="btn btn-secondary py-2 px-4">
            <span class="material-symbols-outlined">arrow_back</span>
            Volver
          </button>
        <div class="flex gap-md w-full sm:w-auto">
             <button class="btn btn-secondary flex-1 sm:flex-none">
              <span class="material-symbols-outlined text-[20px]">edit</span>
              Editar
            </button>
           <button (click)="resolveIncident()" class="btn btn-primary flex-1 sm:flex-none">
              <span class="material-symbols-outlined text-[20px]">check_circle</span>
              Resolver
            </button>
          </div>
        </div>
      
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-lg">
        <!-- Left Column: Main Content (2/3 width) -->
        <div class="lg:col-span-2 flex flex-col gap-lg">
          <!-- Title & Description Card -->
          <div class="glass-card p-lg">
            <div class="flex items-center gap-sm mb-6">
                <span [ngClass]="getPriorityBadgeClass(incident()?.priority)" class="font-bold text-[10px] uppercase tracking-widest px-3 py-1 rounded-full border">
                {{ displayPriority(incident()?.priority) || 'N/A' }}
              </span>
              <span class="text-on-surface-variant font-mono text-xs opacity-50">{{ incident()?.id }}</span>
            </div>
            <h1 class="font-heading-lg text-heading-lg text-on-background mb-4">{{ incident()?.title }}</h1>
            <p class="font-body text-body text-on-surface-variant leading-relaxed">
              {{ incident()?.description }}
            </p>
          </div>
          
          <!-- Timeline/History -->
          <div class="glass-card p-lg">
             <h2 class="font-heading-md text-heading-md text-on-background mb-6">Actividad Reciente</h2>
            <div class="relative border-l border-outline-variant ml-3 space-y-8 pb-4">
              <div *ngFor="let item of timeline()" class="relative pl-8">
                <div class="absolute w-2.5 h-2.5 bg-primary shadow-neon rounded-full -left-[5px] top-1.5"></div>
                <div>
                  <span class="font-label text-sm text-on-background">{{ item.action }}</span>
                  <div class="font-caption text-xs text-on-surface-variant mt-1 opacity-70">por {{ item.author }} • {{ item.timestamp }}</div>
                </div>
                <div *ngIf="item.comment" class="bg-surface-container-low/40 p-4 rounded-xl mt-3 border border-white/5 font-body text-sm text-on-surface-variant">
                  {{ item.comment }}
                </div>
              </div>
            </div>
            
            <!-- Add Comment Input -->
             <div class="mt-8 border-t border-outline-variant/30 pt-6">
               <label class="font-label text-xs text-on-surface-variant uppercase tracking-wider mb-2 block">Agregar nota técnica</label>
               <textarea class="input-glass min-h-24 mb-4" placeholder="Escriba una actualización..." [(ngModel)]="newNote" name="note"></textarea>
               <div class="flex justify-end">
                 <button (click)="addNote()" class="btn btn-secondary">Publicar nota</button>
               </div>
             </div>
          </div>
        </div>
        
        <!-- Right Column: Info Panel (1/3 width) -->
        <div class="flex flex-col gap-lg">
          <!-- Metadata Card -->
          <div class="glass-card p-lg">
             <h3 class="font-heading-md text-heading-md text-on-background mb-6 border-b border-outline-variant/30 pb-3">Detalles</h3>
            <div class="space-y-6">
              <div>
                 <span class="font-label text-[10px] text-on-surface-variant uppercase tracking-widest block mb-1">Estado</span>
                <span class="bg-primary/10 text-primary border border-primary/20 font-bold text-[11px] px-3 py-1 rounded-full uppercase tracking-tighter">{{ displayStatus(incident()?.status) }}</span>
              </div>
              <div>
                 <span class="font-label text-[10px] text-on-surface-variant uppercase tracking-widest block mb-1">Fecha de reporte</span>
                <span class="font-body text-sm text-on-surface">{{ incident()?.createdAt | date:'mediumDate' }}</span>
              </div>
              <div>
                 <span class="font-label text-[10px] text-on-surface-variant uppercase tracking-widest block mb-1">Categoría</span>
                <span class="font-body text-sm text-on-surface">{{ incident()?.category || 'General' }}</span>
              </div>
            </div>
          </div>
          
          <!-- Reporter Details Card -->
          <div class="glass-card p-lg">
             <h3 class="font-heading-md text-heading-md text-on-background mb-6 border-b border-outline-variant/30 pb-3">Reportado por</h3>
           <div class="flex items-center gap-4">
              <div class="w-12 h-12 rounded-2xl bg-gradient-to-br from-primary/20 to-accent/20 border border-white/10 flex items-center justify-center text-primary">
                <span class="material-symbols-outlined">person</span>
              </div>
              <div>
                <div class="font-label text-sm text-on-background">{{ incident()?.reporterName || 'Funcionario Municipal' }}</div>
                <div class="font-caption text-xs text-on-surface-variant opacity-60">ID: {{ incident()?.reporterId?.substring(0,8) || 'USR-...' }}</div>
              </div>
            </div>
          </div>
          
          <!-- Location Card -->
          <div class="glass-card p-lg h-64 flex flex-col">
             <h3 class="font-heading-md text-heading-md text-on-background mb-4">Ubicación</h3>
            <div class="flex-1 bg-surface-container-low rounded-xl border border-white/5 overflow-hidden relative flex items-center justify-center">
              <span class="material-symbols-outlined text-primary/30 text-[64px]">location_on</span>
              <div class="absolute bottom-4 left-4 right-4 bg-background/80 backdrop-blur-md p-3 rounded-lg border border-white/10 font-caption text-[11px] text-on-surface-variant text-center truncate">
                 {{ incident()?.location || 'Coordenadas: -33.41, -70.58' }}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  `,
  styles: []
})
export class IncidentDetailComponent implements OnInit {
  private platformService = inject(PlatformService);
  private authService = inject(AuthService);
  private router = inject(Router);
  private route = inject(ActivatedRoute);

  incident = signal<Incident | null>(null);
  timeline = signal<TimelineItem[]>([]);
  newNote = '';

  ngOnInit() {
    const id = this.route.snapshot.paramMap.get('id');
    if (id) {
      this.loadIncident(id);
    }
  }

  loadIncident(id: string) {
    this.platformService.getIncidentById(id).subscribe({
      next: (data) => {
        this.incident.set(data);
        this.initializeTimeline(data);
      },
      error: (err) => {
        console.error('Error loading incident:', err);
        this.router.navigate(['/incidents']);
      }
    });
  }

  initializeTimeline(incident: Incident) {
    const timeline: TimelineItem[] = [
      {
        action: `Incidente reportado`,
        author: incident.reporterName || 'Sistema',
        timestamp: 'hace 1 día'
      },
      {
        action: 'Analizando arquitectura de red',
        author: 'Admin Central',
        timestamp: 'hace 2 horas'
      }
    ];
    this.timeline.set(timeline);
  }

  addNote() {
    if (this.newNote.trim()) {
      const user = this.authService.user();
      const newTimelineItem: TimelineItem = {
        action: 'Nota añadida',
        author: user ? `${user.firstName} ${user.lastName}` : 'Usuario',
        timestamp: 'ahora',
        comment: this.newNote
      };
      
      this.timeline.update(items => [newTimelineItem, ...items]);
      this.newNote = '';
    }
  }

  resolveIncident() {
    const incident = this.incident();
    if (incident) {
      this.platformService.resolveIncident(incident.id).subscribe({
        next: (updated) => {
          this.incident.set(updated);
        },
        error: (err) => {
          console.error('Error resolving incident:', err);
        }
      });
    }
  }

  getPriorityBadgeClass(priority: string | undefined): string {
    switch (priority) {
      case 'Critical': return 'bg-error/10 text-error border-error/20';
      case 'High': return 'bg-accent/10 text-accent border-accent/20';
      case 'Medium': return 'bg-secondary/10 text-secondary border-secondary/20';
      case 'Low': return 'bg-surface-container-high text-on-surface-variant border-outline-variant';
      default: return 'bg-surface-container text-on-surface';
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

  displayStatus(status: string | undefined): string | undefined {
    if (!status) return undefined;
    switch (status) {
      case 'Open': return 'Abierto';
      case 'In Progress': return 'En progreso';
      case 'Resolved': return 'Resuelto';
      case 'Closed': return 'Cerrado';
      default: return status;
    }
  }
}
