import { CommonModule } from '@angular/common';
import { Component, OnInit, computed, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { ProposalFormComponent } from '../proposal-form/proposal-form.component';
import { Proposal, ProposalComment } from '../../models/proposal.model';
import { Budget, CreateBudgetDto, CreateSurveyQuestionDto, CreateSurveyDto, Issue, ReportSummary, Survey, SurveyResponse, SubmitSurveyResponseDto } from '../../models/platform.model';
import { AuthService } from '../../services/auth.service';
import { PlatformService } from '../../services/platform.service';
import { ProposalService } from '../../services/proposal.service';

type Section = 'proposals' | 'surveys' | 'budgets' | 'issues' | 'reports' | 'chatbot';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule, FormsModule, ProposalFormComponent],
  template: `
    <div class="bg-background text-on-background font-body min-h-screen flex">
      <nav class="hidden md:flex flex-col h-screen w-64 fixed left-0 top-0 py-lg px-md gap-md border-r border-outline-variant bg-surface-container-low z-40">
        <div class="flex items-center gap-sm pb-md">
          <div class="w-10 h-10 rounded-full bg-gradient-to-br from-primary to-primary-container flex items-center justify-center">
            <span class="material-symbols-outlined text-on-primary text-[20px]">groups</span>
          </div>
          <div>
            <h1 class="font-heading-md text-heading-md text-primary">ProyectoAdminRedes</h1>
            <p class="font-caption text-caption text-on-surface-variant mt-xs">Participación ciudadana</p>
          </div>
        </div>

        <button (click)="section.set('proposals')" class="bg-primary-container text-on-primary font-label text-label py-md px-lg rounded-lg flex items-center justify-center gap-sm hover:bg-secondary transition-all mb-md shadow-sm">
          <span class="material-symbols-outlined">add</span>
          Nueva propuesta
        </button>

        <ul class="flex flex-col gap-xs flex-1">
          <li><a (click)="section.set('proposals')" [ngClass]="navClass('proposals')"><span class="material-symbols-outlined">forum</span> Propuestas</a></li>
          <li><a (click)="section.set('surveys')" [ngClass]="navClass('surveys')"><span class="material-symbols-outlined">fact_check</span> Encuestas</a></li>
          <li><a (click)="section.set('budgets')" [ngClass]="navClass('budgets')"><span class="material-symbols-outlined">account_balance_wallet</span> Presupuestos</a></li>
          <li><a (click)="section.set('issues')" [ngClass]="navClass('issues')"><span class="material-symbols-outlined">map</span> Mapeo</a></li>
          <li *ngIf="canViewReports()"><a (click)="section.set('reports')" [ngClass]="navClass('reports')"><span class="material-symbols-outlined">assessment</span> Reportes</a></li>
          <li><a (click)="section.set('chatbot')" [ngClass]="navClass('chatbot')"><span class="material-symbols-outlined">smart_toy</span> Asistente IA</a></li>
        </ul>

        <div class="mt-auto pt-md border-t border-outline-variant flex flex-col gap-xs">
          <a (click)="navigate('/admin-dashboard')" class="flex items-center gap-md px-md py-sm rounded-lg font-label text-label text-on-surface-variant hover:bg-surface-container-high transition-all cursor-pointer">
            <span class="material-symbols-outlined">admin_panel_settings</span>
            Panel admin
          </a>
          <a (click)="logout()" class="flex items-center gap-md px-md py-sm rounded-lg font-label text-label text-on-surface-variant hover:bg-surface-container-high transition-all cursor-pointer">
            <span class="material-symbols-outlined">logout</span>
            Cerrar sesión
          </a>
        </div>
      </nav>

      <div class="flex-1 flex flex-col md:ml-64 w-full">
        <header class="sticky top-0 z-50 flex items-center justify-between px-lg py-sm w-full bg-surface border-b border-outline-variant">
          <div class="flex items-center gap-md flex-1">
            <div class="md:hidden">
              <span class="font-heading-md text-heading-md text-primary font-bold">ProyectoAdminRedes</span>
            </div>
            <div class="hidden md:flex relative w-full max-w-md items-center">
              <span class="material-symbols-outlined absolute left-sm text-on-surface-variant">search</span>
              <input class="w-full pl-xl pr-sm py-sm rounded-sm border border-outline-variant focus:border-primary-container focus:ring-1 focus:ring-primary-container bg-surface-container-lowest font-body text-body text-on-surface outline-none transition-shadow" placeholder="Buscar procesos, propuestas o reportes..." type="text"/>
            </div>
          </div>
          <div class="flex items-center gap-md">
            <button class="text-on-surface-variant hover:bg-surface-container-low p-sm rounded-full transition-colors cursor-pointer active:scale-95 transition-transform">
              <span class="material-symbols-outlined">notifications</span>
            </button>
            <div class="w-8 h-8 rounded-full bg-gradient-to-br from-primary to-primary-container flex items-center justify-center cursor-pointer border border-outline-variant text-on-primary font-bold text-[12px]">
              {{ userInitials }}
            </div>
          </div>
        </header>

        <main class="flex-1 p-md md:p-lg lg:p-xl overflow-y-auto">
          <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-md mb-xl">
            <div>
              <p class="font-caption text-caption uppercase tracking-[0.14em] text-primary font-bold mb-xs">Plataforma ciudadana segura</p>
              <h2 class="font-heading-lg text-heading-lg text-on-background">Participación ciudadana</h2>
              <p class="font-body text-body text-on-surface-variant mt-xs">Propuestas, encuestas, presupuestos y problemáticas territoriales conectadas a la API local.</p>
            </div>
            <button (click)="loadAll()" class="bg-primary-container text-on-primary font-label text-label py-sm px-md rounded-lg flex items-center gap-xs hover:bg-secondary transition-colors whitespace-nowrap shadow-sm">
              <span class="material-symbols-outlined">refresh</span>
              Actualizar datos
            </button>
          </div>

          <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-md lg:gap-lg mb-xl">
            <article class="metric-card"><span>Propuestas</span><strong>{{ proposals().length }}</strong><p>{{ totalVotes() }} votos registrados</p></article>
            <article class="metric-card"><span>Encuestas</span><strong>{{ surveys().length }}</strong><p>{{ totalSurveyResponses() }} respuestas</p></article>
            <article class="metric-card"><span>Presupuestos</span><strong>{{ budgets().length }}</strong><p>{{ totalParticipants() }} participantes</p></article>
            <article class="metric-card"><span>Problemáticas</span><strong>{{ issues().length }}</strong><p>{{ openIssues() }} abiertas</p></article>
          </div>

          <div class="md:hidden bg-surface-bright border border-outline-variant rounded-lg p-sm mb-lg grid grid-cols-2 gap-xs">
            <button *ngFor="let item of mobileSections" (click)="section.set(item.key)" [ngClass]="section() === item.key ? 'bg-primary-container text-on-primary' : 'bg-surface-container-lowest text-on-surface'" class="font-label text-label rounded-sm py-sm px-sm">{{ item.label }}</button>
          </div>

          <section class="section-card" *ngIf="section() === 'proposals'">
            <div class="section-heading"><div><p>RF03</p><h3>Propuestas ciudadanas</h3></div></div>
            <div class="grid grid-cols-1 xl:grid-cols-3 gap-lg">
              <div class="xl:col-span-1"><app-proposal-form (proposalCreated)="loadAll()"></app-proposal-form></div>
              <div class="xl:col-span-2 grid grid-cols-1 lg:grid-cols-2 gap-md">
                @for (proposal of proposals(); track proposal.id) {
                  <article class="item-card">
                    <div class="meta-row"><span>{{ proposal.category }}</span><time>{{ proposal.createdAt | date:'shortDate' }}</time></div>
                    <h4>{{ proposal.title }}</h4>
                    <p>{{ proposal.description }}</p>
                    <div class="flex justify-between items-center mt-md"><strong>{{ proposal.votes }} votos</strong><button class="secondary-btn" (click)="voteProposal(proposal.id)">Votar</button></div>
                    <div class="mt-md pt-md border-t border-outline-variant">
                      <strong class="font-label text-label">Comentarios</strong>
                      @for (comment of proposalComments()[proposal.id] || []; track comment.id) {
                        <p class="bg-surface-container-lowest border border-outline-variant rounded-sm p-sm mt-sm text-on-surface-variant">{{ comment.content }}</p>
                      } @empty {
                        <p class="text-on-surface-variant mt-sm">Sin comentarios todavía.</p>
                      }
                      <div class="flex gap-sm mt-sm">
                        <input [(ngModel)]="commentDrafts[proposal.id]" [name]="'comment-' + proposal.id" class="input-field" placeholder="Escribe un comentario...">
                        <button class="primary-btn shrink-0" (click)="addProposalComment(proposal.id)">Comentar</button>
                      </div>
                    </div>
                  </article>
                } @empty { <p class="empty-state">No hay propuestas registradas.</p> }
              </div>
            </div>
          </section>

          <section class="section-card" *ngIf="section() === 'surveys'">
            <div class="section-heading"><div><p>RF01</p><h3>Consultas y encuestas</h3></div><div class="flex gap-sm"><button *ngIf="isAdmin()" class="primary-btn" (click)="showSurveyForm.set(!showSurveyForm())">{{ showSurveyForm() ? 'Cancelar' : 'Crear encuesta' }}</button><button class="secondary-btn" (click)="loadSurveys()">Actualizar</button></div></div>

            @if (showSurveyForm()) {
              <form class="form-panel mb-lg" (ngSubmit)="createSurvey()">
                <h4 class="font-heading-md text-heading-md mb-md">Nueva encuesta</h4>
                <input class="input-field" name="surveyTitle" [(ngModel)]="surveyForm.title" placeholder="Título de la encuesta" required>
                <textarea class="input-field min-h-20" name="surveyDescription" [(ngModel)]="surveyForm.description" placeholder="Descripción de la encuesta"></textarea>
                <div class="flex flex-col gap-sm mb-md">
                  @for (q of surveyForm.questions; track $index; let idx = $index) {
                    <div class="flex gap-sm items-start bg-surface-container-lowest p-sm rounded-sm border border-outline-variant">
                      <div class="flex-1 flex flex-col gap-xs">
                        <input class="input-field" name="qText{{idx}}" [(ngModel)]="q.text" placeholder="Pregunta" required>
                        <select class="input-field" name="qType{{idx}}" [(ngModel)]="q.type">
                          <option value="TEXT">Texto libre</option>
                          <option value="SINGLE_CHOICE">Opción única</option>
                          <option value="MULTIPLE_CHOICE">Opción múltiple</option>
                          <option value="RATING">Calificación</option>
                          <option value="TEXTAREA">Texto largo</option>
                        </select>
                        <label class="flex items-center gap-xs font-caption text-caption"><input type="checkbox" name="qReq{{idx}}" [(ngModel)]="q.isRequired"> Obligatoria</label>
                      </div>
                      <button type="button" class="secondary-btn text-error" (click)="removeSurveyQuestion(idx)"><span class="material-symbols-outlined">delete</span></button>
                    </div>
                  }
                </div>
                <button type="button" class="secondary-btn mb-md" (click)="addSurveyQuestion()">+ Agregar pregunta</button>
                <button class="primary-btn" type="submit">Crear encuesta</button>
              </form>
            }

            @if (selectedSurvey()) {
              <form class="form-panel mb-lg" (ngSubmit)="submitSurveyResponse(selectedSurvey()!.id)">
                <div class="flex justify-between items-center mb-md">
                  <h4 class="font-heading-md text-heading-md">Responder: {{ selectedSurvey()!.title }}</h4>
                  <button type="button" class="secondary-btn" (click)="cancelSurveyResponse()">Cancelar</button>
                </div>
                @for (q of selectedSurvey()!.questions; track q.id; let idx = $index) {
                  <div class="mb-md">
                    <label class="font-label text-label mb-xs block">{{ q.text }} <span *ngIf="q.isRequired" class="text-error">*</span></label>
                    @switch (q.type) {
                      @case ('TEXT') { <input class="input-field" [name]="'resp-' + q.id" [(ngModel)]="surveyResponses[q.id]" required> }
                      @case ('TEXTAREA') { <textarea class="input-field min-h-20" [name]="'resp-' + q.id" [(ngModel)]="surveyResponses[q.id]" required></textarea> }
                      @case ('RATING') { <input type="number" class="input-field" min="1" max="5" [name]="'resp-' + q.id" [(ngModel)]="surveyResponses[q.id]" required> }
                      @case ('SINGLE_CHOICE') {
                        <select class="input-field" [name]="'resp-' + q.id" [(ngModel)]="surveyResponses[q.id]" required>
                          <option value="">Selecciona una opción</option>
                          @for (opt of q.options || []; track opt) { <option [value]="opt">{{ opt }}</option> }
                        </select>
                      }
                      @case ('MULTIPLE_CHOICE') {
                        @for (opt of q.options || []; track opt) {
                          <label class="flex items-center gap-xs mb-xs"><input type="checkbox" [name]="'resp-' + q.id" [value]="opt" (change)="toggleMultiChoice(q.id, opt, $any($event).target.checked)">{{ opt }}</label>
                        }
                      }
                    }
                  </div>
                }
                <button class="primary-btn" type="submit">Enviar respuesta</button>
              </form>
            }

            <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-md">
              @for (survey of surveys(); track survey.id) {
                <article class="item-card">
                  <div class="meta-row"><span>{{ survey.status }}</span><time>{{ survey.createdAt | date:'shortDate' }}</time></div>
                  <h4>{{ survey.title }}</h4>
                  <p>{{ survey.description }}</p>
                  <div class="chip-row"><span>{{ survey.questions.length || 0 }} preguntas</span><span>{{ survey.responseCount }} respuestas</span></div>
                  <button *ngIf="survey.status === 'ACTIVE'" class="primary-btn mt-md" (click)="respondSurvey(survey)">Responder</button>
                </article>
              } @empty { <p class="empty-state">No hay encuestas disponibles.</p> }
            </div>
          </section>

          <section class="section-card" *ngIf="section() === 'budgets'">
            <div class="section-heading"><div><p>RNF01</p><h3>Presupuestos participativos</h3></div><div class="flex gap-sm"><button *ngIf="isAdmin()" class="primary-btn" (click)="showBudgetForm.set(!showBudgetForm())">{{ showBudgetForm() ? 'Cancelar' : 'Crear presupuesto' }}</button><button class="secondary-btn" (click)="loadBudgets()">Actualizar</button></div></div>

            @if (showBudgetForm()) {
              <form class="form-panel mb-lg" (ngSubmit)="createBudget()">
                <h4 class="font-heading-md text-heading-md mb-md">Nuevo presupuesto participativo</h4>
                <input class="input-field" name="budgetTitle" [(ngModel)]="budgetForm.title" placeholder="Título del presupuesto" required>
                <textarea class="input-field min-h-20" name="budgetDescription" [(ngModel)]="budgetForm.description" placeholder="Descripción del presupuesto"></textarea>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-sm mb-md">
                  <input class="input-field" name="budgetTotal" type="number" [(ngModel)]="budgetForm.totalAmount" placeholder="Monto total" required>
                  <label class="flex items-center gap-sm font-label text-label"><input type="checkbox" name="budgetMulti" [(ngModel)]="budgetForm.allowMultipleVotes"> Permitir voto múltiple</label>
                </div>
                <div class="flex flex-col gap-sm mb-md">
                  <label class="font-label text-label">Ítems del presupuesto</label>
                  @for (item of budgetForm.items || []; track $index; let idx = $index) {
                    <div class="bg-surface-container-lowest p-sm rounded-sm border border-outline-variant flex flex-col gap-xs">
                      <input class="input-field" name="itemTitle{{idx}}" [(ngModel)]="item.title" placeholder="Título del ítem" required>
                      <textarea class="input-field min-h-16" name="itemDesc{{idx}}" [(ngModel)]="item.description" placeholder="Descripción"></textarea>
                      <input class="input-field" name="itemCost{{idx}}" type="number" [(ngModel)]="item.estimatedCost" placeholder="Costo estimado" required>
                      <button type="button" class="secondary-btn text-error text-xs" (click)="removeBudgetItem(idx)">Eliminar ítem</button>
                    </div>
                  }
                </div>
                <button type="button" class="secondary-btn mb-md" (click)="addBudgetItem()">+ Agregar ítem</button>
                <button class="primary-btn" type="submit">Crear presupuesto</button>
              </form>
            }

            <div class="grid grid-cols-1 md:grid-cols-2 gap-md">
              @for (budget of budgets(); track budget.id) {
                <article class="item-card">
                  <div class="meta-row"><span>{{ budget.status }}</span><time>{{ budget.createdAt | date:'shortDate' }}</time></div>
                  <h4>{{ budget.title }}</h4>
                  <p>{{ budget.description }}</p>
                  <div class="chip-row"><span>{{ budget.totalAmount | currency }}</span><span>{{ budget.participantsCount }} participantes</span><span>{{ budget.allowMultipleVotes ? 'Voto múltiple' : 'Voto único' }}</span></div>
                  <div class="mt-md pt-md border-t border-outline-variant grid gap-sm">
                    @for (item of budget.items || []; track item.id) {
                      <div class="flex justify-between gap-sm items-center"><span>{{ item.title }} - {{ item.voteCount }} votos</span><button class="secondary-btn" [disabled]="budget.status !== 'ACTIVE'" (click)="voteBudget(budget.id, item.id)">Votar</button></div>
                    }
                  </div>
                </article>
              } @empty { <p class="empty-state">No hay presupuestos disponibles.</p> }
            </div>
          </section>

          <section class="section-card" *ngIf="section() === 'issues'">
            <div class="section-heading"><div><p>RF02</p><h3>Mapeo participativo</h3></div><button class="secondary-btn" (click)="loadIssues()">Actualizar</button></div>
            <div class="grid grid-cols-1 xl:grid-cols-3 gap-lg">
              <form class="form-panel" (ngSubmit)="createIssue()">
                <input class="input-field" name="issueTitle" [(ngModel)]="issueForm.title" placeholder="Título de la problemática" required>
                <input class="input-field" name="issueCategory" [(ngModel)]="issueForm.category" placeholder="Categoría" required>
                <input class="input-field" name="issueAddress" [(ngModel)]="issueForm.address" placeholder="Dirección o referencia">
                <div class="grid grid-cols-2 gap-sm"><input class="input-field" name="issueLatitude" type="number" step="0.0000001" [(ngModel)]="issueForm.latitude" placeholder="Latitud" required><input class="input-field" name="issueLongitude" type="number" step="0.0000001" [(ngModel)]="issueForm.longitude" placeholder="Longitud" required></div>
                <textarea class="input-field min-h-28" name="issueDescription" [(ngModel)]="issueForm.description" placeholder="Describe la necesidad territorial" required></textarea>
                <button class="primary-btn" type="submit">Reportar problemática</button>
              </form>
              <div class="xl:col-span-2 grid grid-cols-1 md:grid-cols-2 gap-md">
                @for (issue of issues(); track issue.id) {
                  <article class="item-card"><div class="meta-row"><span>{{ displayIssueStatus(issue.status) }}</span><time>{{ issue.createdAt | date:'shortDate' }}</time></div><h4>{{ issue.title }}</h4><p>{{ issue.description }}</p><div class="chip-row"><span>{{ issue.category }}</span><span>{{ issue.address || 'Sin dirección' }}</span><span>{{ issue.latitude }}, {{ issue.longitude }}</span></div></article>
                } @empty { <p class="empty-state">No hay problemáticas territoriales registradas.</p> }
              </div>
            </div>
          </section>

          <section class="section-card" *ngIf="section() === 'reports' && canViewReports()">
            <div class="section-heading"><div><p>RF05</p><h3>Reportes integrales</h3></div><button class="secondary-btn" (click)="loadReportSummary()">Actualizar</button></div>
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-md mb-lg" *ngIf="reportSummary() as summary"><article class="metric-card"><span>Propuestas</span><strong>{{ summary.totals.proposals }}</strong><p>Total</p></article><article class="metric-card"><span>Encuestas</span><strong>{{ summary.totals.surveys }}</strong><p>Total</p></article><article class="metric-card"><span>Presupuestos</span><strong>{{ summary.totals.budgets }}</strong><p>Total</p></article><article class="metric-card"><span>Problemáticas</span><strong>{{ summary.totals.issues }}</strong><p>Total</p></article></div>
            <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-md" *ngIf="reportSummary() as summary">@for (proposal of summary.topProposals; track proposal.id) {<article class="item-card"><h4>{{ proposal.title }}</h4><p>{{ proposal.votes }} votos</p></article>} @empty { <p class="empty-state">No hay datos suficientes para reportes.</p> }</div>
          </section>

          <section class="section-card" *ngIf="section() === 'chatbot'">
            <div class="section-heading"><div><p>Funcionalidad deseada</p><h3>Asistente ciudadano</h3></div></div>
            <form class="flex flex-col md:flex-row gap-sm" (ngSubmit)="askChatbot()"><input class="input-field flex-1" name="chatMessage" [(ngModel)]="chatMessage" placeholder="Pregunta sobre propuestas, encuestas o presupuestos..." required><button class="primary-btn" type="submit" [disabled]="chatLoading()">{{ chatLoading() ? 'Consultando...' : 'Preguntar' }}</button></form>
            <article class="item-card mt-lg" *ngIf="chatAnswer()"><div class="meta-row"><span>Modo {{ chatMode() }}</span></div><p>{{ chatAnswer() }}</p></article>
          </section>

          <p class="mt-lg p-md rounded-lg bg-error-container text-on-error-container font-label text-label" *ngIf="errorMessage()">{{ errorMessage() }}</p>
        </main>
      </div>
    </div>
  `,
styles: [`
    .metric-card { @apply bg-[#f1f5f9] border border-[#e2e8f0] rounded-[18px] p-lg flex flex-col gap-sm; }
    .metric-card span { @apply font-label text-label text-on-surface-variant; }
    .metric-card strong { @apply font-heading-lg text-heading-lg text-on-surface; }
    .metric-card p { @apply font-caption text-caption text-tertiary-container m-0; }
    .section-card { @apply bg-[#f8f9ff] rounded-[18px] border border-[#e2e8f0] p-md md:p-lg mb-lg; }
    .section-heading { @apply flex flex-col sm:flex-row justify-between items-start sm:items-center gap-md mb-lg; }
    .section-heading p { @apply font-caption text-on-surface-variant uppercase tracking-[0.14em] text-[#003594] font-bold mb-xs; }
    .section-heading h3 { @apply font-heading-md text-heading-md text-on-background m-0; }
    .item-card { @apply bg-[#f1f5f9] border border-[#e2e8f0] rounded-[18px] p-lg flex flex-col gap-sm; }
    .item-card h4 { @apply font-heading-md text-heading-md text-on-surface m-0; }
    .item-card p { @apply font-body text-body text-on-surface-variant m-0; }
    .meta-row { @apply flex justify-between items-center gap-sm font-caption text-caption text-on-surface-variant; }
    .meta-row span, .chip-row span { @apply rounded-full px-sm py-xs bg-surface-container-lowest border border-outline-variant; }
    .chip-row { @apply flex flex-wrap gap-xs mt-sm font-caption text-caption text-on-surface-variant; }
    .input-field { @apply w-full px-sm py-sm rounded-sm border border-outline-variant focus:border-[#004ac6] focus:ring-1 focus:ring-[#004ac6] bg-surface-container-lowest font-body text-body text-on-surface outline-none transition-shadow; }
    .primary-btn { @apply bg-[#004ac6] text-white font-label text-label py-sm px-md rounded-[18px] hover:bg-[#003594] transition-colors disabled:opacity-50 disabled:cursor-not-allowed; }
    .secondary-btn { @apply bg-surface-container-lowest text-on-surface border border-outline-variant font-label text-label py-sm px-md rounded-sm hover:bg-[#eff4ff] transition-colors disabled:opacity-50 disabled:cursor-not-allowed; }
    .form-panel { @apply bg-[#f1f5f9] border border-[#e2e8f0] rounded-[18px] p-lg flex flex-col gap-sm; }
    .empty-state { @apply text-on-surface-variant font-body text-body; }
  `]
})
export class DashboardComponent implements OnInit {
  auth = inject(AuthService);
  private platformService = inject(PlatformService);
  private proposalService = inject(ProposalService);
  private router = inject(Router);

  section = signal<Section>('proposals');
  proposals = signal<Proposal[]>([]);
  surveys = signal<Survey[]>([]);
  budgets = signal<Budget[]>([]);
  issues = signal<Issue[]>([]);
  proposalComments = signal<Record<string, ProposalComment[]>>({});
  reportSummary = signal<ReportSummary | undefined>(undefined);
  chatAnswer = signal<string | undefined>(undefined);
  chatMode = signal<string>('local');
  chatLoading = signal(false);
  errorMessage = signal<string | undefined>(undefined);
  totalVotes = computed(() => this.proposals().reduce((sum, proposal) => sum + proposal.votes, 0));
  totalSurveyResponses = computed(() => this.surveys().reduce((sum, survey) => sum + survey.responseCount, 0));
  totalParticipants = computed(() => this.budgets().reduce((sum, budget) => sum + budget.participantsCount, 0));
  openIssues = computed(() => this.issues().filter((issue) => issue.status === 'OPEN' || issue.status === 'IN_REVIEW').length);

  commentDrafts: Record<string, string> = {};
  chatMessage = '';
  issueForm = { title: '', description: '', category: '', address: '', latitude: 0, longitude: 0 };

  showSurveyForm = signal(false);
  showBudgetForm = signal(false);
  selectedSurvey = signal<Survey | null>(null);
  surveyForm = { title: '', description: '', questions: [] as CreateSurveyQuestionDto[] };
  budgetForm: CreateBudgetDto = { title: '', description: '', totalAmount: 0, items: [] };
  surveyResponses: Record<string, string | string[] | number> = {};

  mobileSections: Array<{ key: Section; label: string }> = [
    { key: 'proposals', label: 'Propuestas' },
    { key: 'surveys', label: 'Encuestas' },
    { key: 'budgets', label: 'Presupuestos' },
    { key: 'issues', label: 'Mapeo' },
    { key: 'chatbot', label: 'Asistente' },
  ];

  get userInitials(): string {
    const user = this.auth.user();
    if (user) return (user.firstName[0] + user.lastName[0]).toUpperCase();
    return 'AD';
  }

  ngOnInit() {
    this.loadAll();
  }

  navClass(section: Section) {
    const base = 'flex items-center gap-md px-md py-sm rounded-lg font-label text-label transition-all cursor-pointer';
    return this.section() === section
      ? `${base} bg-primary-container text-on-primary-container font-bold`
      : `${base} text-on-surface-variant hover:bg-surface-container-high`;
  }

  navigate(path: string) {
    this.router.navigate([path]);
  }

  logout() {
    this.auth.logout();
    this.router.navigate(['/login']);
  }

  loadAll() {
    this.errorMessage.set(undefined);
    this.loadProposals();
    this.loadSurveys();
    this.loadBudgets();
    this.loadIssues();
    if (this.canViewReports()) this.loadReportSummary();
  }

  loadProposals() {
    this.proposalService.getProposals().subscribe({
      next: (data) => {
        this.proposals.set(data);
        data.forEach((proposal) => this.loadProposalComments(proposal.id));
      },
      error: (err) => this.setError('No se pudieron cargar las propuestas.', err),
    });
  }

  loadProposalComments(proposalId: string) {
    this.proposalService.getComments(proposalId).subscribe({
      next: (comments) => this.proposalComments.update((current) => ({ ...current, [proposalId]: comments })),
      error: (err) => this.setError('No se pudieron cargar los comentarios.', err),
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

  loadIssues() {
    this.platformService.getIssues().subscribe({
      next: (data) => this.issues.set(data),
      error: (err) => this.setError('No se pudieron cargar las problemáticas territoriales.', err),
    });
  }

  loadReportSummary() {
    this.platformService.getReportSummary().subscribe({
      next: (data) => this.reportSummary.set(data),
      error: (err) => this.setError('No se pudo cargar el resumen de reportes.', err),
    });
  }

  voteProposal(id: string) {
    this.proposalService.vote(id).subscribe({
      next: (updated) => this.proposals.update((items) => items.map((item) => item.id === updated.id ? updated : item)),
      error: (err) => this.setError('No se pudo registrar el voto de propuesta.', err),
    });
  }

  voteBudget(budgetId: string, itemId: string) {
    this.platformService.voteBudget(budgetId, itemId).subscribe({
      next: () => this.loadBudgets(),
      error: (err) => this.setError('No se pudo registrar el voto de presupuesto.', err),
    });
  }

  addProposalComment(proposalId: string) {
    const content = this.commentDrafts[proposalId]?.trim();
    if (!content) return;
    this.proposalService.addComment(proposalId, content).subscribe({
      next: (comment) => {
        this.proposalComments.update((current) => ({ ...current, [proposalId]: [comment, ...(current[proposalId] || [])] }));
        this.commentDrafts[proposalId] = '';
      },
      error: (err) => this.setError('No se pudo agregar el comentario.', err),
    });
  }

  createIssue() {
    this.platformService.createIssue({ ...this.issueForm, latitude: Number(this.issueForm.latitude), longitude: Number(this.issueForm.longitude) }).subscribe({
      next: (issue) => {
        this.issues.update((items) => [issue, ...items]);
        this.issueForm = { title: '', description: '', category: '', address: '', latitude: 0, longitude: 0 };
      },
      error: (err) => this.setError('No se pudo registrar la problemática territorial.', err),
    });
  }

  askChatbot() {
    const message = this.chatMessage.trim();
    if (!message) return;
    this.chatLoading.set(true);
    this.platformService.askChatbot(message).subscribe({
      next: (response) => {
        this.chatAnswer.set(response.answer);
        this.chatMode.set(response.mode);
        this.chatLoading.set(false);
      },
      error: (err) => {
        this.chatLoading.set(false);
        this.setError('No se pudo consultar el asistente.', err);
      },
    });
  }

  canViewReports() {
    const role = this.auth.user()?.role;
    return role === 'ADMIN' || role === 'MODERATOR';
  }

  isAdmin() {
    const role = this.auth.user()?.role;
    return role === 'ADMIN' || role === 'MODERATOR';
  }

  addSurveyQuestion() {
    this.surveyForm.questions.push({ text: '', type: 'TEXT', isRequired: false });
  }

  removeSurveyQuestion(index: number) {
    this.surveyForm.questions.splice(index, 1);
  }

  createSurvey() {
    if (!this.surveyForm.title.trim()) return;
    const dto: CreateSurveyDto = {
      title: this.surveyForm.title,
      description: this.surveyForm.description,
      questions: this.surveyForm.questions.filter(q => q.text.trim()),
    };
    this.platformService.createSurvey(dto).subscribe({
      next: (survey) => {
        this.surveys.update(items => [survey, ...items]);
        this.showSurveyForm.set(false);
        this.surveyForm = { title: '', description: '', questions: [] };
      },
      error: (err) => this.setError('No se pudo crear la encuesta.', err),
    });
  }

  addBudgetItem() {
    if (!this.budgetForm.items) this.budgetForm.items = [];
    this.budgetForm.items.push({ title: '', description: '', estimatedCost: 0 });
  }

  removeBudgetItem(index: number) {
    this.budgetForm.items?.splice(index, 1);
  }

  createBudget() {
    if (!this.budgetForm.title.trim() || !this.budgetForm.totalAmount) return;
    this.platformService.createBudget(this.budgetForm).subscribe({
      next: (budget) => {
        this.budgets.update(items => [budget, ...items]);
        this.showBudgetForm.set(false);
        this.budgetForm = { title: '', description: '', totalAmount: 0, items: [] };
      },
      error: (err) => this.setError('No se pudo crear el presupuesto.', err),
    });
  }

  respondSurvey(survey: Survey) {
    this.selectedSurvey.set(survey);
    this.surveyResponses = {};
  }

  submitSurveyResponse(surveyId: string) {
    const responses: { questionId: string; response: string | string[] | number }[] = Object.entries(this.surveyResponses).map(([questionId, response]) => ({ questionId, response }));
    this.platformService.submitSurveyResponse(surveyId, responses).subscribe({
      next: () => {
        this.loadSurveys();
        this.selectedSurvey.set(null);
      },
      error: (err) => this.setError('No se pudo enviar la respuesta.', err),
    });
  }

  cancelSurveyResponse() {
    this.selectedSurvey.set(null);
  }

  toggleMultiChoice(questionId: string, option: string, checked: boolean) {
    const current = this.surveyResponses[questionId] as string[] || [];
    if (checked) {
      if (!current.includes(option)) current.push(option);
    } else {
      const idx = current.indexOf(option);
      if (idx > -1) current.splice(idx, 1);
    }
    this.surveyResponses[questionId] = current;
  }

  displayIssueStatus(status: Issue['status']) {
    switch (status) {
      case 'OPEN': return 'Abierta';
      case 'IN_REVIEW': return 'En revisión';
      case 'RESOLVED': return 'Resuelta';
      case 'CLOSED': return 'Cerrada';
      default: return status;
    }
  }

  private setError(message: string, err: unknown) {
    console.error(message, err);
    this.errorMessage.set(message);
  }
}
