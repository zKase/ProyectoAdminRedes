import { CommonModule } from '@angular/common';
import { Component, OnInit, computed, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ProposalFormComponent } from '../proposal-form/proposal-form.component';
import { Proposal } from '../../models/proposal.model';
import { Budget, Survey } from '../../models/platform.model';
import { AuthService } from '../../services/auth.service';
import { PlatformService } from '../../services/platform.service';
import { ProposalService } from '../../services/proposal.service';

type Section = 'proposals' | 'surveys' | 'budgets';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule, FormsModule, ProposalFormComponent],
  template: `
    <div class="page-shell">
      <header class="hero">
        <div>
          <p class="eyebrow">Plataforma ciudadana segura</p>
          <h1>Participacion Ciudadana</h1>
          <p class="lead">Propuestas, encuestas y presupuestos participativos conectados a la API protegida con JWT y PostgreSQL.</p>
        </div>

        <section class="auth-card" *ngIf="!auth.isAuthenticated(); else profileCard">
          <div class="auth-tabs">
            <button [class.active]="authMode() === 'login'" (click)="authMode.set('login')">Ingresar</button>
            <button [class.active]="authMode() === 'register'" (click)="authMode.set('register')">Registrarse</button>
          </div>

          <form (ngSubmit)="submitAuth()">
            <div class="name-grid" *ngIf="authMode() === 'register'">
              <input name="firstName" [(ngModel)]="authForm.firstName" placeholder="Nombre" required>
              <input name="lastName" [(ngModel)]="authForm.lastName" placeholder="Apellido" required>
            </div>
            <input name="email" type="email" [(ngModel)]="authForm.email" placeholder="correo@ejemplo.com" required>
            <input name="password" type="password" [(ngModel)]="authForm.password" placeholder="Contraseña" required minlength="8">
            <button type="submit" [disabled]="authLoading()">{{ authLoading() ? 'Procesando...' : authMode() === 'login' ? 'Entrar' : 'Crear cuenta' }}</button>
          </form>
          <p class="form-error" *ngIf="authError()">{{ authError() }}</p>
        </section>

        <ng-template #profileCard>
          <section class="auth-card profile">
            <span class="role">{{ auth.user()?.role }}</span>
            <h2>{{ auth.user()?.firstName }} {{ auth.user()?.lastName }}</h2>
            <p>{{ auth.user()?.email }}</p>
            <button type="button" class="secondary" (click)="logout()">Cerrar sesión</button>
          </section>
        </ng-template>
      </header>

      <section class="status-grid">
        <article>
          <strong>{{ proposals().length }}</strong>
          <span>Propuestas</span>
        </article>
        <article>
          <strong>{{ surveys().length }}</strong>
          <span>Encuestas</span>
        </article>
        <article>
          <strong>{{ budgets().length }}</strong>
          <span>Presupuestos</span>
        </article>
        <article>
          <strong>JWT</strong>
          <span>Autenticación</span>
        </article>
      </section>

      <div class="notice" *ngIf="!auth.isAuthenticated()">
        Inicia sesión o crea una cuenta para consultar y participar en los módulos protegidos por los requisitos de seguridad.
      </div>

      <nav class="section-tabs">
        <button [class.active]="section() === 'proposals'" (click)="section.set('proposals')">Propuestas</button>
        <button [class.active]="section() === 'surveys'" (click)="section.set('surveys')">Encuestas</button>
        <button [class.active]="section() === 'budgets'" (click)="section.set('budgets')">Presupuestos</button>
      </nav>

      <main class="content" *ngIf="auth.isAuthenticated()">
        <section class="panel" *ngIf="section() === 'proposals'">
          <div class="panel-heading">
            <div>
              <p class="eyebrow">Participacion abierta</p>
              <h2>Propuestas ciudadanas</h2>
            </div>
          </div>

          <div class="proposal-layout">
            <app-proposal-form (proposalCreated)="loadAll()"></app-proposal-form>

            <div class="cards">
              @for (proposal of proposals(); track proposal.id) {
                <article class="card">
                  <div class="meta">
                    <span>{{ proposal.category }}</span>
                    <time>{{ proposal.createdAt | date:'shortDate' }}</time>
                  </div>
                  <h3>{{ proposal.title }}</h3>
                  <p>{{ proposal.description }}</p>
                  <div class="card-actions">
                    <strong>{{ proposal.votes }} votos</strong>
                    <button type="button" (click)="voteProposal(proposal.id)">Votar</button>
                  </div>
                </article>
              } @empty {
                <p class="empty">No hay propuestas registradas.</p>
              }
            </div>
          </div>
        </section>

        <section class="panel" *ngIf="section() === 'surveys'">
          <div class="panel-heading">
            <div>
              <p class="eyebrow">RF01 y RF03</p>
              <h2>Consultas y encuestas</h2>
            </div>
            <button type="button" class="secondary" (click)="loadSurveys()">Actualizar</button>
          </div>

          <div class="cards wide">
            @for (survey of surveys(); track survey.id) {
              <article class="card">
                <div class="meta">
                  <span>{{ survey.status }}</span>
                  <time>{{ survey.createdAt | date:'shortDate' }}</time>
                </div>
                <h3>{{ survey.title }}</h3>
                <p>{{ survey.description }}</p>
                <div class="requirements">
                  <span>{{ survey.questions.length }} preguntas</span>
                  <span>{{ survey.responseCount }} respuestas</span>
                </div>
              </article>
            } @empty {
              <p class="empty">No hay encuestas disponibles.</p>
            }
          </div>
        </section>

        <section class="panel" *ngIf="section() === 'budgets'">
          <div class="panel-heading">
            <div>
              <p class="eyebrow">RNF01 integridad de votos</p>
              <h2>Presupuestos participativos</h2>
            </div>
            <button type="button" class="secondary" (click)="loadBudgets()">Actualizar</button>
          </div>

          <div class="cards wide">
            @for (budget of budgets(); track budget.id) {
              <article class="card budget-card">
                <div class="meta">
                  <span>{{ budget.status }}</span>
                  <time>{{ budget.createdAt | date:'shortDate' }}</time>
                </div>
                <h3>{{ budget.title }}</h3>
                <p>{{ budget.description }}</p>
                <div class="requirements">
                  <span>{{ budget.totalAmount | currency }}</span>
                  <span>{{ budget.participantsCount }} participantes</span>
                  <span>{{ budget.allowMultipleVotes ? 'Voto multiple' : 'Voto unico' }}</span>
                </div>

                <div class="budget-items">
                  @for (item of budget.items; track item.id) {
                    <div>
                      <span>{{ item.title }} - {{ item.voteCount }} votos</span>
                      <button type="button" [disabled]="budget.status !== 'ACTIVE'" (click)="voteBudget(budget.id, item.id)">Votar</button>
                    </div>
                  }
                </div>
              </article>
            } @empty {
              <p class="empty">No hay presupuestos disponibles.</p>
            }
          </div>
        </section>
      </main>

      <p class="form-error page-error" *ngIf="errorMessage()">{{ errorMessage() }}</p>
    </div>
  `,
  styles: [`
    :host {
      display: block;
      min-height: 100vh;
      background: #0f172a;
      color: #0f172a;
      font-family: Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
    }

    .page-shell {
      max-width: 1180px;
      margin: 0 auto;
      padding: 32px 16px 56px;
    }

    .hero {
      display: grid;
      grid-template-columns: minmax(0, 1fr);
      gap: 24px;
      align-items: center;
      color: white;
      padding: 34px;
      border-radius: 28px;
      background: radial-gradient(circle at top left, #38bdf8 0, transparent 34%), linear-gradient(135deg, #1e3a8a, #0f172a 62%);
      box-shadow: 0 24px 80px rgb(2 6 23 / 0.42);
    }

    @media (min-width: 860px) {
      .hero {
        grid-template-columns: 1fr 360px;
      }
    }

    h1, h2, h3, p {
      margin-top: 0;
    }

    h1 {
      max-width: 760px;
      margin-bottom: 14px;
      font-size: clamp(2.4rem, 6vw, 5rem);
      line-height: 0.95;
      letter-spacing: -0.06em;
    }

    .lead {
      max-width: 700px;
      margin-bottom: 0;
      color: #cbd5e1;
      font-size: 1.08rem;
      line-height: 1.7;
    }

    .eyebrow {
      margin-bottom: 10px;
      color: #38bdf8;
      font-size: 0.78rem;
      font-weight: 800;
      letter-spacing: 0.14em;
      text-transform: uppercase;
    }

    .auth-card, .status-grid article, .panel, .notice {
      background: rgb(255 255 255 / 0.96);
      border: 1px solid rgb(255 255 255 / 0.18);
      border-radius: 22px;
      box-shadow: 0 18px 44px rgb(2 6 23 / 0.18);
    }

    .auth-card {
      padding: 20px;
      color: #0f172a;
    }

    .auth-tabs {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 8px;
      margin-bottom: 14px;
    }

    .auth-tabs button, button {
      border: 0;
      border-radius: 12px;
      padding: 11px 14px;
      font-weight: 800;
      cursor: pointer;
      color: white;
      background: #2563eb;
    }

    .auth-tabs button {
      color: #334155;
      background: #e2e8f0;
    }

    .auth-tabs button.active, .section-tabs button.active {
      color: white;
      background: #2563eb;
    }

    button:disabled {
      cursor: not-allowed;
      opacity: 0.55;
    }

    .secondary {
      color: #0f172a;
      background: #e2e8f0;
    }

    form {
      display: grid;
      gap: 10px;
    }

    input {
      width: 100%;
      box-sizing: border-box;
      border: 1px solid #cbd5e1;
      border-radius: 12px;
      padding: 12px;
      font: inherit;
    }

    .name-grid, .proposal-layout {
      display: grid;
      gap: 14px;
    }

    @media (min-width: 900px) {
      .proposal-layout {
        grid-template-columns: 360px 1fr;
        align-items: start;
      }
    }

    .profile h2 {
      margin-bottom: 6px;
    }

    .role {
      display: inline-flex;
      margin-bottom: 12px;
      border-radius: 999px;
      padding: 5px 10px;
      color: #1e40af;
      background: #dbeafe;
      font-size: 0.78rem;
      font-weight: 800;
    }

    .status-grid {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 14px;
      margin: 18px 0;
    }

    @media (min-width: 780px) {
      .status-grid {
        grid-template-columns: repeat(4, 1fr);
      }
    }

    .status-grid article {
      padding: 18px;
    }

    .status-grid strong {
      display: block;
      font-size: 1.8rem;
    }

    .status-grid span, .meta, .requirements {
      color: #64748b;
      font-size: 0.9rem;
      font-weight: 700;
    }

    .notice {
      margin-bottom: 18px;
      padding: 18px;
      color: #334155;
    }

    .section-tabs {
      display: flex;
      flex-wrap: wrap;
      gap: 10px;
      margin-bottom: 18px;
    }

    .section-tabs button {
      color: #cbd5e1;
      background: #1e293b;
    }

    .panel {
      padding: clamp(18px, 4vw, 28px);
    }

    .panel-heading, .meta, .card-actions, .requirements, .budget-items div {
      display: flex;
      gap: 12px;
      align-items: center;
      justify-content: space-between;
    }

    .panel-heading {
      margin-bottom: 20px;
    }

    .panel-heading h2 {
      margin-bottom: 0;
      font-size: clamp(1.5rem, 3vw, 2rem);
    }

    .cards {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
      gap: 14px;
    }

    .cards.wide {
      grid-template-columns: repeat(auto-fill, minmax(290px, 1fr));
    }

    .card {
      display: grid;
      gap: 12px;
      padding: 18px;
      border: 1px solid #e2e8f0;
      border-radius: 18px;
      background: white;
    }

    .card h3 {
      margin-bottom: 0;
    }

    .card p {
      color: #475569;
      line-height: 1.55;
    }

    .requirements {
      flex-wrap: wrap;
      justify-content: flex-start;
    }

    .requirements span, .meta span {
      border-radius: 999px;
      padding: 5px 10px;
      background: #f1f5f9;
    }

    .budget-items {
      display: grid;
      gap: 10px;
      padding-top: 10px;
      border-top: 1px solid #e2e8f0;
    }

    .budget-items div {
      align-items: center;
    }

    .budget-items button {
      padding: 8px 10px;
    }

    .empty, .form-error {
      color: #b91c1c;
      font-weight: 700;
    }

    .page-error {
      margin-top: 16px;
      padding: 14px 16px;
      border-radius: 14px;
      background: #fee2e2;
    }
  `]
})
export class DashboardComponent implements OnInit {
  auth = inject(AuthService);
  private platformService = inject(PlatformService);
  private proposalService = inject(ProposalService);

  authMode = signal<'login' | 'register'>('login');
  authLoading = signal(false);
  authError = signal<string | undefined>(undefined);
  section = signal<Section>('proposals');
  proposals = signal<Proposal[]>([]);
  surveys = signal<Survey[]>([]);
  budgets = signal<Budget[]>([]);
  errorMessage = signal<string | undefined>(undefined);
  totalVotes = computed(() => this.proposals().reduce((sum, proposal) => sum + proposal.votes, 0));

  authForm = {
    firstName: '',
    lastName: '',
    email: '',
    password: '',
  };

  ngOnInit() {
    if (this.auth.isAuthenticated()) {
      this.loadAll();
    }
  }

  submitAuth() {
    this.authLoading.set(true);
    this.authError.set(undefined);

    const request = this.authMode() === 'login'
      ? this.auth.login(this.authForm.email, this.authForm.password)
      : this.auth.register(this.authForm.firstName, this.authForm.lastName, this.authForm.email, this.authForm.password);

    request.subscribe({
      next: () => {
        this.authLoading.set(false);
        this.loadAll();
      },
      error: () => {
        this.authError.set('No se pudo completar la autenticacion. Revisa los datos e intenta de nuevo.');
        this.authLoading.set(false);
      },
    });
  }

  logout() {
    this.auth.logout();
    this.proposals.set([]);
    this.surveys.set([]);
    this.budgets.set([]);
  }

  loadAll() {
    this.errorMessage.set(undefined);
    this.loadProposals();
    this.loadSurveys();
    this.loadBudgets();
  }

  loadProposals() {
    this.proposalService.getProposals().subscribe({
      next: (data) => this.proposals.set(data),
      error: (err) => this.setError('No se pudieron cargar las propuestas.', err),
    });
  }

  loadSurveys() {
    this.platformService.getSurveys().subscribe({
      next: (data) => this.surveys.set(data),
      error: (err) => this.setError('No se pudieron cargar las encuestas.', err),
    });
  }

  loadBudgets() {
    this.platformService.getBudgets().subscribe({
      next: (data) => this.budgets.set(data),
      error: (err) => this.setError('No se pudieron cargar los presupuestos.', err),
    });
  }

  voteProposal(id: string) {
    this.proposalService.vote(id).subscribe({
      next: (updated) => {
        this.proposals.update((items) => items.map((item) => item.id === updated.id ? updated : item));
      },
      error: (err) => this.setError('No se pudo registrar el voto de propuesta.', err),
    });
  }

  voteBudget(budgetId: string, itemId: string) {
    this.platformService.voteBudget(budgetId, itemId).subscribe({
      next: () => this.loadBudgets(),
      error: (err) => this.setError('No se pudo registrar el voto de presupuesto.', err),
    });
  }

  private setError(message: string, err: unknown) {
    console.error(message, err);
    this.errorMessage.set(message);
  }
}
