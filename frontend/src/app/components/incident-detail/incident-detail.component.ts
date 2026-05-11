import { CommonModule } from '@angular/common';
import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
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
  imports: [CommonModule, FormsModule],
  template: `
    <div class="bg-background text-on-background font-body min-h-screen flex h-screen overflow-hidden">
      <!-- SideNavBar -->
      <nav class="hidden md:flex flex-col h-full py-lg px-md gap-md bg-surface-container-low text-primary border-r border-outline-variant w-64 fixed left-0 top-0 transition-all duration-200 ease-in-out">
        <div class="flex items-center gap-sm mb-lg">
          <span class="font-heading-md text-heading-md text-[#0052b5]">Municipalidad de Las Condes</span>
        </div>
        
        <div class="flex flex-col gap-sm flex-grow">
          <a (click)="navigate('/dashboard')" class="flex items-center gap-md px-md py-sm rounded-lg text-on-surface-variant hover:bg-surface-variant transition-all cursor-pointer">
            <span class="material-symbols-outlined">dashboard</span>
            <span class="font-label text-label">Tablero</span>
          </a>
          
          <a class="flex items-center gap-md px-md py-sm rounded-lg bg-primary-container text-on-primary-container font-bold transition-all cursor-pointer">
            <span class="material-symbols-outlined" style="font-variation-settings: 'FILL' 1;">report_problem</span>
            <span class="font-label text-label">Incidentes</span>
          </a>
          
          <a class="flex items-center gap-md px-md py-sm rounded-lg text-on-surface-variant hover:bg-surface-variant transition-all cursor-pointer">
            <span class="material-symbols-outlined">assessment</span>
            <span class="font-label text-label">Informes</span>
          </a>
        </div>
        
        <button class="flex items-center justify-center gap-sm bg-primary-container text-on-primary-container py-sm px-md rounded-lg font-label text-label hover:bg-surface-container-high transition-all mb-lg">
          <span class="material-symbols-outlined">add</span>
           Nuevo incidente
        </button>
        
        <div class="flex flex-col gap-sm border-t border-outline-variant pt-md">
          <a class="flex items-center gap-md px-md py-sm rounded-lg text-on-surface-variant hover:bg-surface-variant transition-all cursor-pointer">
            <span class="material-symbols-outlined">settings</span>
            <span class="font-label text-label">Ajustes</span>
          </a>
          <a (click)="logout()" class="flex items-center gap-md px-md py-sm rounded-lg text-on-surface-variant hover:bg-surface-variant transition-all cursor-pointer">
            <span class="material-symbols-outlined">logout</span>
            <span class="font-label text-label">Cerrar sesión</span>
          </a>
        </div>
      </nav>
      
      <!-- Main Content Area -->
      <div class="flex flex-col flex-1 md:ml-64 h-screen overflow-hidden">
        <!-- TopNavBar -->
        <header class="sticky top-0 z-50 flex items-center justify-between px-lg py-sm w-full bg-surface border-b border-outline-variant">
          <div class="flex items-center gap-md">
            <button class="md:hidden text-on-surface-variant cursor-pointer active:scale-95 transition-transform">
              <span class="material-symbols-outlined">menu</span>
            </button>
            <div class="md:hidden font-heading-md text-heading-md text-[#0052b5]">Municipalidad de Las Condes</div>
            
              <div class="hidden md:flex items-center bg-surface-container-low rounded-lg px-md py-xs border border-outline-variant focus-within:border-primary-container focus-within:ring-1 focus-within:ring-primary-container transition-all">
              <span class="material-symbols-outlined text-on-surface-variant mr-sm">search</span>
              <input class="bg-transparent border-none focus:ring-0 text-body font-body text-on-background placeholder-on-surface-variant outline-none w-64" placeholder="Buscar..." type="text"/>
            </div>
          </div>
          
          <div class="flex items-center gap-md text-primary">
            <button class="hover:bg-surface-container-low p-sm rounded-full transition-colors cursor-pointer active:scale-95 transition-transform">
              <span class="material-symbols-outlined">notifications</span>
            </button>
            <div class="h-8 w-8 rounded-full bg-gradient-to-br from-primary to-primary-container flex items-center justify-center cursor-pointer active:scale-95 transition-transform border border-outline-variant text-on-primary font-bold text-[12px]">
              {{ userInitials }}
            </div>
          </div>
        </header>
        
        <!-- Scrollable Content Canvas -->
        <main class="flex-1 overflow-y-auto p-md md:p-xl bg-background">
          <!-- Header Actions -->
          <div class="flex justify-between items-center mb-xl">
              <a (click)="navigate('/incidents')" class="flex items-center gap-xs text-on-surface-variant hover:text-primary transition-colors font-label text-label cursor-pointer">
                <span class="material-symbols-outlined text-[20px]">arrow_back</span>
              Volver a incidentes
              </a>
            <div class="flex gap-md">
                 <button class="px-md py-sm rounded-lg border border-outline-variant text-on-surface font-label text-label hover:bg-surface-variant transition-colors flex items-center gap-xs">
                  <span class="material-symbols-outlined text-[18px]">edit</span>
                  Editar
                </button>
               <button (click)="resolveIncident()" class="px-md py-sm rounded-lg bg-primary-container text-on-primary font-label text-label hover:bg-primary transition-colors flex items-center gap-xs">
                  <span class="material-symbols-outlined text-[18px]" style="font-variation-settings: 'FILL' 1;">check_circle</span>
                Resolver
                </button>
              </div>
            </div>
          
          <div class="grid grid-cols-1 lg:grid-cols-3 gap-lg">
            <!-- Left Column: Main Content (2/3 width) -->
            <div class="lg:col-span-2 flex flex-col gap-lg">
              <!-- Title & Description Card -->
              <div class="bg-surface-bright rounded-xl border border-outline-variant p-lg">
                <div class="flex items-center gap-sm mb-md">
                    <span [ngClass]="getPriorityBadgeClass(incident()?.priority)" class="font-label text-label px-sm py-xs rounded-full inline-flex items-center gap-xs">
                      <span class="material-symbols-outlined text-[16px]">priority_high</span>
                    {{ displayPriority(incident()?.priority) || 'N/A' }}
                  </span>
                  <span class="text-on-surface-variant font-caption text-caption">{{ incident()?.id }}</span>
                </div>
                <h1 class="font-heading-lg text-heading-lg text-on-background mb-md">{{ incident()?.title }}</h1>
                <p class="font-body text-body text-on-surface-variant mb-lg">
                  {{ incident()?.description }}
                </p>
              </div>
              
              <!-- Evidence Gallery -->
              <div class="bg-surface-bright rounded-xl border border-outline-variant p-lg">
                 <h2 class="font-heading-md text-heading-md text-on-background mb-md">Galería de evidencias</h2>
                <div class="grid grid-cols-2 md:grid-cols-3 gap-md">
                  <div class="aspect-video bg-surface-variant rounded-lg overflow-hidden border border-outline-variant relative group flex items-center justify-center">
                    <span class="material-symbols-outlined text-on-surface-variant text-[48px]">image</span>
                  </div>
                  <div class="aspect-video bg-surface-variant rounded-lg overflow-hidden border border-outline-variant relative group flex items-center justify-center">
                    <span class="material-symbols-outlined text-on-surface-variant text-[48px]">image</span>
                  </div>
                </div>
              </div>
              
              <!-- Timeline/History -->
              <div class="bg-surface-bright rounded-xl border border-outline-variant p-lg">
                 <h2 class="font-heading-md text-heading-md text-on-background mb-md">Línea de actividad</h2>
                <div class="relative border-l border-outline-variant ml-sm space-y-lg pb-md">
                  <div *ngFor="let item of timeline()" class="relative pl-lg">
                    <div class="absolute w-3 h-3 bg-primary-container rounded-full -left-[6px] top-1"></div>
                    <div class="flex justify-between items-start mb-xs">
                      <div>
                        <span class="font-label text-label text-on-background">{{ item.action }}</span>
                        <div class="font-caption text-caption text-on-surface-variant mt-xs">by {{ item.author }} • {{ item.timestamp }}</div>
                      </div>
                    </div>
                    <div *ngIf="item.comment" class="bg-surface-container-low p-sm rounded-lg mt-sm border border-outline-variant font-body text-body text-on-surface-variant">
                      {{ item.comment }}
                    </div>
                  </div>
                </div>
                
                <!-- Add Comment Input -->
                 <div class="mt-md border-t border-outline-variant pt-md">
                   <label class="font-label text-label text-on-background mb-xs block">Agregar nota</label>
                   <textarea class="w-full bg-surface rounded-lg border border-outline-variant p-sm font-body text-body text-on-background focus:ring-1 focus:ring-primary-container focus:border-primary-container outline-none" placeholder="Escriba una nota interna o actualización..." rows="3" [(ngModel)]="newNote" name="note"></textarea>
                   <div class="flex justify-end mt-sm">
                     <button (click)="addNote()" class="px-md py-sm rounded-lg bg-surface-container-low text-primary-container font-label text-label hover:bg-surface-variant transition-colors border border-outline-variant">Publicar nota</button>
                   </div>
                 </div>
              </div>
            </div>
            
            <!-- Right Column: Info Panel (1/3 width) -->
            <div class="flex flex-col gap-lg">
              <!-- Metadata Card -->
              <div class="bg-surface-bright rounded-xl border border-outline-variant p-lg">
                 <h3 class="font-heading-md text-heading-md text-on-background mb-md border-b border-outline-variant pb-sm">Detalles</h3>
                <div class="space-y-md">
                  <div>
                     <span class="font-caption text-caption text-on-surface-variant block mb-xs">Estado</span>
                    <span class="bg-surface-container-highest text-on-surface font-label text-label px-sm py-xs rounded-full inline-block">{{ incident()?.status }}</span>
                  </div>
                  <div>
                     <span class="font-caption text-caption text-on-surface-variant block mb-xs">Creado</span>
                    <span class="font-body text-body text-on-background">{{ incident()?.createdAt || incident()?.dateReported }}</span>
                  </div>
                  <div>
                     <span class="font-caption text-caption text-on-surface-variant block mb-xs">Categoría</span>
                    <span class="font-body text-body text-on-background">{{ incident()?.category || 'N/A' }}</span>
                  </div>
                </div>
              </div>
              
              <!-- Reporter Details Card -->
              <div class="bg-surface-bright rounded-xl border border-outline-variant p-lg">
                 <h3 class="font-heading-md text-heading-md text-on-background mb-md border-b border-outline-variant pb-sm">Reportante</h3>
               <div class="flex items-center gap-md">
                  <div class="w-12 h-12 rounded-full bg-surface-variant border border-outline-variant flex items-center justify-center text-on-surface-variant">
                    <span class="material-symbols-outlined">person</span>
                  </div>
                  <div>
                    <div class="font-label text-label text-on-background">{{ incident()?.reporterName || 'Desconocido' }}</div>
                    <div class="font-caption text-caption text-on-surface-variant">{{ incident()?.reporterRole || 'Ciudadano' }}</div>
                    <a class="font-caption text-caption text-primary hover:underline mt-xs inline-block cursor-pointer">Ver perfil</a>
                  </div>
                </div>
              </div>
              
              <!-- Location Card -->
              <div class="bg-surface-bright rounded-xl border border-outline-variant p-lg flex flex-col h-64">
                 <h3 class="font-heading-md text-heading-md text-on-background mb-md">Ubicación</h3>
                <div class="flex-1 bg-surface-variant rounded-lg border border-outline-variant overflow-hidden relative flex items-center justify-center">
                  <span class="material-symbols-outlined text-on-surface-variant text-[48px]">location_on</span>
                  <div class="absolute bottom-sm left-sm right-sm bg-surface-bright/90 backdrop-blur-sm p-sm rounded border border-outline-variant font-caption text-caption text-on-background truncate">
                     {{ incident()?.location || 'Ubicación no especificada' }}
                  </div>
                </div>
              </div>
            </div>
          </div>
        </main>
      </div>
    </div>
  `,
  styles: []
})
export class IncidentDetailComponent implements OnInit {
  private authService = inject(AuthService);
  private platformService = inject(PlatformService);
  private router = inject(Router);
  private route = inject(ActivatedRoute);

  incident = signal<Incident | null>(null);
  timeline = signal<TimelineItem[]>([]);
  newNote = '';

  get userInitials(): string {
    const user = this.authService.user();
    if (user) {
      return (user.firstName[0] + user.lastName[0]).toUpperCase();
    }
    return 'AD';
  }

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
        author: incident.reporterName || 'Reportante',
        timestamp: 'hace 1 día'
      },
      {
        action: 'Estado cambiado a En progreso',
        author: 'Usuario admin',
        timestamp: 'hace 2 horas'
      }
    ];
    this.timeline.set(timeline);
  }

  addNote() {
    if (this.newNote.trim()) {
      const newTimelineItem: TimelineItem = {
        action: 'Nota añadida',
        author: this.authService.user()?.firstName + ' ' + this.authService.user()?.lastName || 'Usuario actual',
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
          alert('Incidente resuelto correctamente');
        },
        error: (err) => {
          console.error('Error resolving incident:', err);
          alert('No se pudo resolver el incidente');
        }
      });
    }
  }

  navigate(path: string) {
    this.router.navigate([path]);
  }

  logout() {
    this.authService.logout();
    this.router.navigate(['/login']);
  }

  getPriorityBadgeClass(priority: string | undefined): string {
    switch (priority) {
      case 'Critical':
      case 'High':
        return 'bg-error-container text-on-error-container';
      case 'Medium':
        return 'bg-secondary-fixed text-primary-container';
      case 'Low':
        return 'bg-surface-variant text-on-surface-variant';
      default:
        return 'bg-surface-variant text-on-surface-variant';
    }
  }

  // Helper to present priority in Spanish
  displayPriority(priority: string | undefined): string | undefined {
    if (!priority) return undefined;
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

  // Helper to present status in Spanish
  displayStatus(status: string | undefined): string | undefined {
    if (!status) return undefined;
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
}
