import { Component, OnInit, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ProposalService } from '../../services/proposal.service';
import { Proposal } from '../../models/proposal.model';
import { ProposalFormComponent } from '../proposal-form/proposal-form.component';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule, ProposalFormComponent],
  template: `
    <div class="dashboard-container">
      <header class="header">
        <h1>Participación Ciudadana</h1>
        <p>Tu voz, nuestra ciudad.</p>
      </header>

      <main class="content">
        <section class="form-section">
          <h2>Crear Nueva Propuesta</h2>
          <app-proposal-form (proposalCreated)="loadProposals()"></app-proposal-form>
        </section>

        <section class="proposals-section">
          <h2>Propuestas Recientes</h2>
          <div class="proposals-grid">
            @for (proposal of proposals(); track proposal.id) {
              <div class="proposal-card">
                <div class="card-header">
                  <span class="category">{{ proposal.category }}</span>
                  <span class="date">{{ proposal.createdAt | date:'shortDate' }}</span>
                </div>
                <h3>{{ proposal.title }}</h3>
                <p>{{ proposal.description }}</p>
                
                <div class="card-footer">
                  <div class="votes-badge">
                    <span class="vote-count">{{ proposal.votes }}</span> votos
                  </div>
                  <button class="vote-btn" (click)="vote(proposal.id)">
                    <span class="icon">👍</span> Votar
                  </button>
                </div>
              </div>
            } @empty {
              <p class="empty-state">No hay propuestas aún. ¡Sé el primero en participar!</p>
            }
          </div>
        </section>
      </main>
    </div>
  `,
  styles: [`
    :host {
      --primary: #3b82f6;
      --primary-hover: #2563eb;
      --bg: #f8fafc;
      --card-bg: #ffffff;
      --text: #0f172a;
      --text-muted: #64748b;
      --border: #e2e8f0;
      
      display: block;
      min-height: 100vh;
      background-color: var(--bg);
      color: var(--text);
      font-family: 'Inter', system-ui, sans-serif;
    }

    .dashboard-container {
      max-width: 1200px;
      margin: 0 auto;
      padding: 2rem 1rem;
    }

    .header {
      text-align: center;
      margin-bottom: 3rem;
    }

    .header h1 {
      font-size: 2.5rem;
      font-weight: 800;
      letter-spacing: -0.025em;
      margin-bottom: 0.5rem;
      color: var(--primary);
    }

    .header p {
      font-size: 1.1rem;
      color: var(--text-muted);
    }

    .content {
      display: grid;
      grid-template-columns: 1fr;
      gap: 3rem;
    }

    @media (min-width: 768px) {
      .content {
        grid-template-columns: 350px 1fr;
        align-items: start;
      }
    }

    h2 {
      font-size: 1.5rem;
      font-weight: 700;
      margin-bottom: 1.5rem;
      padding-bottom: 0.5rem;
      border-bottom: 2px solid var(--border);
    }

    .proposals-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
      gap: 1.5rem;
    }

    .proposal-card {
      background: var(--card-bg);
      border-radius: 16px;
      padding: 1.5rem;
      box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1);
      transition: transform 0.2s, box-shadow 0.2s;
      display: flex;
      flex-direction: column;
    }

    .proposal-card:hover {
      transform: translateY(-4px);
      box-shadow: 0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1);
    }

    .card-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 1rem;
      font-size: 0.875rem;
    }

    .category {
      background: #eff6ff;
      color: var(--primary);
      padding: 0.25rem 0.75rem;
      border-radius: 9999px;
      font-weight: 600;
      text-transform: uppercase;
      letter-spacing: 0.05em;
    }

    .date {
      color: var(--text-muted);
    }

    .proposal-card h3 {
      font-size: 1.25rem;
      font-weight: 700;
      margin-bottom: 0.75rem;
      line-height: 1.4;
    }

    .proposal-card p {
      color: var(--text-muted);
      line-height: 1.6;
      margin-bottom: 1.5rem;
      flex-grow: 1;
    }

    .card-footer {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding-top: 1rem;
      border-top: 1px solid var(--border);
    }

    .votes-badge {
      font-size: 0.875rem;
      color: var(--text-muted);
      font-weight: 500;
    }

    .vote-count {
      font-size: 1.25rem;
      font-weight: 800;
      color: var(--text);
    }

    .vote-btn {
      background: var(--primary);
      color: white;
      border: none;
      padding: 0.5rem 1rem;
      border-radius: 8px;
      font-weight: 600;
      cursor: pointer;
      display: flex;
      align-items: center;
      gap: 0.5rem;
      transition: background-color 0.2s, transform 0.1s;
    }

    .vote-btn:hover {
      background: var(--primary-hover);
    }

    .vote-btn:active {
      transform: scale(0.95);
    }

    .empty-state {
      grid-column: 1 / -1;
      text-align: center;
      padding: 3rem;
      background: var(--card-bg);
      border-radius: 16px;
      color: var(--text-muted);
      border: 2px dashed var(--border);
    }
  `]
})
export class DashboardComponent implements OnInit {
  private proposalService = inject(ProposalService);
  proposals = signal<Proposal[]>([]);

  ngOnInit() {
    this.loadProposals();
  }

  loadProposals() {
    this.proposalService.getProposals().subscribe(
      (data) => this.proposals.set(data)
    );
  }

  vote(id: string) {
    this.proposalService.vote(id).subscribe(() => {
      // Optimistic or real reload
      this.loadProposals();
    });
  }
}
