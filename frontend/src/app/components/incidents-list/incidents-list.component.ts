import { CommonModule } from '@angular/common';
import { Component, OnInit, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../../services/auth.service';
import { PlatformService } from '../../services/platform.service';
import { Incident } from '../../models/platform.model';

@Component({
  selector: 'app-incidents-list',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div class="bg-background text-on-background font-body min-h-screen flex">
      <!-- SideNavBar -->
      <nav class="hidden md:flex flex-col h-screen w-64 fixed left-0 top-0 py-lg px-md gap-md border-r border-outline-variant bg-surface-container-low z-40 transition-all duration-200 ease-in-out">
        <div class="flex items-center gap-sm px-sm pb-md">
          <div class="w-10 h-10 rounded-full bg-gradient-to-br from-primary to-primary-container flex items-center justify-center">
            <span class="material-symbols-outlined text-on-primary text-[20px]">shield</span>
          </div>
          <div>
            <h1 class="font-heading-md text-heading-md text-[#0052b5]">Municipalidad de Las Condes</h1>
            <p class="font-caption text-caption text-on-surface-variant mt-xs">Gestión de participación</p>
          </div>
        </div>
        
        <button class="bg-primary-container text-on-primary font-label text-label py-md px-lg rounded-lg flex items-center justify-center gap-sm hover:bg-surface-container-high transition-all mb-md shadow-sm">
          <span class="material-symbols-outlined">add</span>
          Nuevo incidente
            </button>
        
        <ul class="flex flex-col gap-xs flex-1">
          <li>
              <a (click)="navigate('/dashboard')" class="flex items-center gap-md px-md py-sm rounded-lg font-label text-label text-on-surface-variant hover:bg-surface-variant hover:bg-surface-container-high transition-all cursor-pointer">
                <span class="material-symbols-outlined">dashboard</span>
              Tablero
              </a>
          </li>
          <li>
              <a class="flex items-center gap-md px-md py-sm rounded-lg font-label text-label bg-primary-container text-on-primary-container font-bold transition-all cursor-pointer">
                <span class="material-symbols-outlined">report_problem</span>
              Incidentes
              </a>
          </li>
          <li>
              <a class="flex items-center gap-md px-md py-sm rounded-lg font-label text-label text-on-surface-variant hover:bg-surface-variant hover:bg-surface-container-high transition-all cursor-pointer">
                <span class="material-symbols-outlined">assessment</span>
              Informes
              </a>
          </li>
        </ul>
        
        <div class="mt-auto pt-md border-t border-outline-variant flex flex-col gap-xs">
          <a class="flex items-center gap-md px-md py-sm rounded-lg font-label text-label text-on-surface-variant hover:bg-surface-variant hover:bg-surface-container-high transition-all cursor-pointer">
            <span class="material-symbols-outlined">settings</span>
            Ajustes
          </a>
          <a (click)="logout()" class="flex items-center gap-md px-md py-sm rounded-lg font-label text-label text-on-surface-variant hover:bg-surface-variant hover:bg-surface-container-high transition-all cursor-pointer">
            <span class="material-symbols-outlined">logout</span>
            Cerrar sesión
          </a>
        </div>
      </nav>
      
      <!-- Main Content Area -->
      <div class="flex-1 flex flex-col md:ml-64 w-full">
        <!-- TopNavBar -->
        <header class="sticky top-0 z-50 flex items-center justify-between px-lg py-sm w-full bg-surface border-b border-outline-variant">
          <div class="flex items-center gap-md flex-1">
            <div class="md:hidden">
              <span class="font-heading-md text-heading-md text-[#0052b5] font-bold">Municipalidad de Las Condes</span>
            </div>
               <div class="hidden md:flex relative w-full max-w-md items-center">
                <span class="material-symbols-outlined absolute left-sm text-on-surface-variant">search</span>
               <input class="w-full pl-xl pr-sm py-sm rounded-sm border border-outline-variant focus:border-primary-container focus:ring-1 focus:ring-primary-container bg-surface-container-lowest font-body text-body text-on-surface outline-none transition-shadow" placeholder="Buscar..." type="text"/>
              </div>
          </div>
          
          <div class="flex items-center gap-md">
            <button class="text-on-surface-variant hover:bg-surface-container-low p-sm rounded-full transition-colors cursor-pointer active:scale-95 transition-transform">
              <span class="material-symbols-outlined">notifications</span>
            </button>
            <div class="w-8 h-8 rounded-full bg-gradient-to-br from-primary to-primary-container flex items-center justify-center cursor-pointer active:scale-95 transition-transform border border-outline-variant text-on-primary font-bold text-[12px]">
              {{ userInitials }}
            </div>
          </div>
        </header>
        
        <!-- Page Content -->
        <main class="flex-1 p-md md:p-lg lg:p-xl overflow-y-auto">
          <!-- Header Section -->
          <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-md mb-xl">
              <div>
              <h2 class="font-heading-lg text-heading-lg text-on-background">Incidentes</h2>
              <p class="font-body text-body text-on-surface-variant mt-xs">Gestiona y rastrea problemas de la red.</p>
            </div>
              <button class="bg-primary-container text-on-primary font-label text-label py-sm px-md rounded-lg flex items-center gap-xs hover:bg-secondary transition-colors whitespace-nowrap shadow-sm">
                <span class="material-symbols-outlined" style="font-variation-settings: 'FILL' 1;">add</span>
              Nuevo incidente
              </button>
          </div>
          
          <!-- Filters & Search Bar -->
          <div class="bg-surface-bright rounded-lg border border-outline-variant p-md mb-lg flex flex-col md:flex-row gap-md items-end md:items-center">
            <div class="flex-1 w-full relative">
               <label class="font-label text-label text-on-surface-variant block mb-xs">Buscar incidentes</label>
               <div class="relative">
                 <span class="material-symbols-outlined absolute left-sm top-1/2 -translate-y-1/2 text-on-surface-variant">search</span>
                 <input class="w-full pl-xl pr-sm py-sm rounded-sm border border-outline-variant focus:border-primary-container focus:ring-1 focus:ring-primary-container bg-surface-container-lowest font-body text-body text-on-surface outline-none transition-shadow" placeholder="ID, título o asignado..." type="text" [(ngModel)]="searchTerm" name="search"/>
              </div>
            </div>
            
            <div class="w-full md:w-48">
               <label class="font-label text-label text-on-surface-variant block mb-xs">Estado</label>
              <select class="w-full py-sm px-sm rounded-sm border border-outline-variant focus:border-primary-container focus:ring-1 focus:ring-primary-container bg-surface-container-lowest font-body text-body text-on-surface outline-none appearance-none" [(ngModel)]="selectedStatus" name="status">
                 <option value="">Todos los estados</option>
                  <option value="Open">Abierto</option>
                  <option value="In Progress">En progreso</option>
                  <option value="Resolved">Resuelto</option>
                  <option value="Closed">Cerrado</option>
              </select>
            </div>
            
            <div class="w-full md:w-48">
               <label class="font-label text-label text-on-surface-variant block mb-xs">Severidad</label>
              <select class="w-full py-sm px-sm rounded-sm border border-outline-variant focus:border-primary-container focus:ring-1 focus:ring-primary-container bg-surface-container-lowest font-body text-body text-on-surface outline-none appearance-none" [(ngModel)]="selectedSeverity" name="severity">
                 <option value="">Todas las severidades</option>
                 <option value="Critical">Crítica</option>
                 <option value="High">Alta</option>
                 <option value="Medium">Media</option>
                 <option value="Low">Baja</option>
              </select>
            </div>
            
            <div class="w-full md:w-auto">
              <button class="w-full md:w-auto bg-surface-container-lowest text-on-surface border border-outline-variant font-label text-label py-sm px-md rounded-sm flex items-center justify-center gap-xs hover:bg-surface-container-low transition-colors h-[42px]">
                <span class="material-symbols-outlined text-[18px]">filter_list</span>
                Más filtros
              </button>
            </div>
          </div>
          
          <!-- Data Table -->
          <div class="bg-surface-bright rounded-xl border border-outline-variant overflow-hidden">
            <div class="overflow-x-auto">
              <table class="w-full text-left border-collapse">
                 <thead>
                  <tr class="bg-surface-container-low border-b border-outline-variant">
                     <th class="font-label text-label text-on-surface-variant py-md px-md whitespace-nowrap">ID</th>
                     <th class="font-label text-label text-on-surface-variant py-md px-md">Título</th>
                      <th class="font-label text-label text-on-surface-variant py-md px-md">Estado</th>
                     <th class="font-label text-label text-on-surface-variant py-md px-md">Severidad</th>
                     <th class="font-label text-label text-on-surface-variant py-md px-md">Fecha reportada</th>
                     <th class="font-label text-label text-on-surface-variant py-md px-md text-right">Acciones</th>
                  </tr>
                </thead>
                <tbody class="font-body text-body">
                  <tr *ngFor="let incident of filteredIncidents()" class="border-b border-outline-variant hover:bg-surface-container-lowest transition-colors">
                    <td class="py-md px-md text-on-surface-variant font-mono text-sm">{{ incident.id }}</td>
                    <td class="py-md px-md font-medium text-on-surface">{{ incident.title }}</td>
                    <td class="py-md px-md">
                        <span [ngClass]="getStatusBadgeClass(incident.status)" class="inline-flex items-center gap-xs px-sm py-xs rounded-lg font-label text-caption">
                          <span class="w-2 h-2 rounded-full" [ngClass]="getStatusDotClass(incident.status)"></span>
                        {{ displayStatus(incident.status) }}
                      </span>
                    </td>
                    <td class="py-md px-md">
                      <span [ngClass]="getSeverityClass(incident.priority || incident.severity)" class="font-medium">{{ displayPriority(incident.priority || incident.severity) || 'N/A' }}</span>
                    </td>
                    <td class="py-md px-md text-on-surface-variant">{{ incident.dateReported }}</td>
                    <td class="py-md px-md text-right">
                      <div class="flex justify-end gap-sm">
                          <button (click)="navigate('/incidents/' + incident.id)" class="text-primary hover:bg-surface-container-high p-xs rounded-full transition-colors" title="Ver detalles">
                           <span class="material-symbols-outlined text-[20px]">visibility</span>
                         </button>
                        <button class="text-on-surface-variant hover:bg-surface-container-high p-xs rounded-full transition-colors" title="Editar">
                          <span class="material-symbols-outlined text-[20px]">edit</span>
                        </button>
                      </div>
                    </td>
                  </tr>
                  <tr *ngIf="filteredIncidents().length === 0">
                    <td colspan="6" class="py-md px-md text-center text-on-surface-variant">No se encontraron incidentes</td>
                  </tr>
                </tbody>
              </table>
            </div>
            
            <!-- Pagination -->
            <div class="bg-surface-container-lowest border-t border-outline-variant p-md flex flex-col sm:flex-row justify-between items-center gap-md">
              <p class="font-caption text-caption text-on-surface-variant">Mostrando 1 a {{ filteredIncidents().length }} de {{ incidents().length }} entradas</p>
              <div class="flex items-center gap-xs">
                <button class="p-xs rounded-sm border border-outline-variant text-on-surface-variant hover:bg-surface-container-low disabled:opacity-50" [disabled]="true">
                  <span class="material-symbols-outlined text-[20px]">chevron_left</span>
                </button>
                <button class="w-8 h-8 rounded-sm bg-primary-container text-on-primary font-label text-label flex items-center justify-center">1</button>
                <button class="w-8 h-8 rounded-sm text-on-surface hover:bg-surface-container-low font-label text-label flex items-center justify-center">2</button>
                <button class="w-8 h-8 rounded-sm text-on-surface hover:bg-surface-container-low font-label text-label flex items-center justify-center">3</button>
                <span class="text-on-surface-variant px-xs">...</span>
                <button class="w-8 h-8 rounded-sm text-on-surface hover:bg-surface-container-low font-label text-label flex items-center justify-center">15</button>
                <button class="p-xs rounded-sm border border-outline-variant text-on-surface hover:bg-surface-container-low">
                  <span class="material-symbols-outlined text-[20px]">chevron_right</span>
                </button>
              </div>
            </div>
          </div>
        </main>
      </div>
    </div>
  `,
  styles: []
})
export class IncidentsListComponent implements OnInit {
  private authService = inject(AuthService);
  private platformService = inject(PlatformService);
  private router = inject(Router);

  searchTerm = '';
  selectedStatus = '';
  selectedSeverity = '';
  incidents = signal<Incident[]>([]);

  get userInitials(): string {
    const user = this.authService.user();
    if (user) {
      return (user.firstName[0] + user.lastName[0]).toUpperCase();
    }
    return 'AD';
  }

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
      next: (data) => {
        this.incidents.set(data);
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

  getStatusBadgeClass(status: string): string {
    switch (status) {
      case 'Open':
        return 'bg-error-container text-on-error-container bg-opacity-20 border border-error-container';
      case 'In Progress':
        return 'bg-tertiary-fixed text-on-tertiary-fixed bg-opacity-20 border border-tertiary-fixed-dim';
      case 'Resolved':
      case 'Closed':
        return 'bg-surface-variant text-on-surface-variant bg-opacity-40 border border-outline-variant';
      default:
        return '';
    }
  }

  getStatusDotClass(status: string): string {
    switch (status) {
      case 'Open':
        return 'bg-error';
      case 'In Progress':
        return 'bg-tertiary-container';
      case 'Resolved':
      case 'Closed':
        return 'bg-outline';
      default:
        return '';
    }
  }

  getSeverityClass(severity: string | undefined): string {
    switch (severity) {
      case 'Critical':
        return 'text-error';
      case 'High':
        return 'text-secondary';
      case 'Medium':
        return 'text-tertiary-container';
      case 'Low':
        return 'text-on-surface-variant';
      default:
        return '';
    }
  }

  // Map internal status values to Spanish display labels
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

  // Map priority/severity to Spanish labels
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
}
