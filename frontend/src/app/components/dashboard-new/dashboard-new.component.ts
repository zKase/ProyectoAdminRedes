import { CommonModule } from '@angular/common';
import { Component, OnInit, inject, signal } from '@angular/core';
import { Router } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { AuthService } from '../../services/auth.service';
import { PlatformService } from '../../services/platform.service';
import { Incident, Issue, Survey, Budget } from '../../models/platform.model';
import { Proposal } from '../../models/proposal.model';
import { ProposalService } from '../../services/proposal.service';
import { StaticMapComponent } from '../static-map/static-map.component';

@Component({
  selector: 'app-dashboard-new',
  standalone: true,
  imports: [CommonModule, FormsModule, StaticMapComponent],
  templateUrl: './dashboard-new.component.html',
  styleUrl: './dashboard-new.component.css'
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
