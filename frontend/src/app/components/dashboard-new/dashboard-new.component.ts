import { CommonModule } from '@angular/common';
import { Component, OnInit, inject, signal } from '@angular/core';
import { Router } from '@angular/router';
import { AuthService } from '../../services/auth.service';
import { PlatformService } from '../../services/platform.service';
import { Incident } from '../../models/platform.model';

@Component({
  selector: 'app-dashboard-new',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './dashboard-new.component.html',
  styleUrl: './dashboard-new.component.css'
})
export class DashboardNewComponent implements OnInit {
  private authService = inject(AuthService);
  private platformService = inject(PlatformService);
  private router = inject(Router);

  incidents = signal<Incident[]>([]);
  openIncidents = signal(0);

  get userInitials(): string {
    const user = this.authService.user();
    if (user) {
      return (user.firstName[0] + user.lastName[0]).toUpperCase();
    }
    return 'AD';
  }

  ngOnInit() {
    this.loadIncidents();
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
        return 'bg-secondary-fixed/30 text-primary-container border-secondary-fixed';
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
        return 'bg-surface-variant text-on-surface-variant';
      case 'In Progress':
        return 'bg-tertiary-fixed/30 text-tertiary-container';
      case 'Resolved':
      case 'Closed':
        return 'bg-tertiary-fixed/30 text-tertiary-container';
      default:
        return '';
    }
  }
}
