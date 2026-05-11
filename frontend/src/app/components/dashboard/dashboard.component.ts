import { CommonModule } from '@angular/common';
import { Component, OnInit, computed, inject, signal, effect } from '@angular/core';
import { FormsModule } from '@angular/forms';
import * as L from 'leaflet';
import { Router, ActivatedRoute } from '@angular/router';
import { ProposalFormComponent } from '../proposal-form/proposal-form.component';
import { Proposal, ProposalComment } from '../../models/proposal.model';
import { Budget, CreateBudgetDto, CreateSurveyQuestionDto, CreateSurveyDto, Issue, ReportSummary, Survey, SurveyResponse, SubmitSurveyResponseDto } from '../../models/platform.model';
import { AuthService } from '../../services/auth.service';
import { PlatformService } from '../../services/platform.service';
import { ProposalService } from '../../services/proposal.service';
import { ToastService } from '../../services/toast.service';

type Section = 'proposals' | 'surveys' | 'budgets' | 'issues' | 'reports';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule, FormsModule, ProposalFormComponent],
  template: `
    <div class="h-full">
      <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-md mb-xl">
            <div>
              <p class="font-caption text-caption uppercase tracking-[0.2em] text-primary font-bold mb-xs">Plataforma ciudadana segura</p>
              <h2 class="font-heading-lg text-heading-lg text-on-background">Participación ciudadana</h2>
              <p class="font-body text-body text-on-surface-variant mt-xs">Propuestas, encuestas y presupuestos conectados a la API local.</p>
            </div>
            <button (click)="loadAll()" class="btn btn-secondary">
              <span class="material-symbols-outlined">refresh</span>
              Actualizar
            </button>
          </div>

          <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-lg mb-xl">
            <article class="glass-card p-xl flex flex-col gap-md">
              <div class="flex justify-between items-start">
                <div class="w-12 h-12 rounded-full bg-primary/10 flex items-center justify-center text-primary shadow-sm">
                  <span class="material-symbols-outlined text-[24px]">groups</span>
                </div>
                <span class="text-xs font-bold text-success flex items-center gap-1">
                  <span class="material-symbols-outlined text-xs">trending_up</span>
                  +5.2%
                </span>
              </div>
              <div class="flex flex-col">
                <span class="text-sm font-medium text-on-surface-variant">Propuestas Activas</span>
                <strong class="text-3xl font-bold text-on-surface mt-1">{{ proposals().length }}</strong>
                <p class="text-[11px] text-on-surface-variant/70 mt-2">{{ totalVotes() }} votos registrados</p>
              </div>
            </article>

            <article class="glass-card p-xl flex flex-col gap-md">
              <div class="flex justify-between items-start">
                <div class="w-12 h-12 rounded-full bg-secondary/10 flex items-center justify-center text-secondary shadow-sm">
                  <span class="material-symbols-outlined text-[24px]">fact_check</span>
                </div>
                <span class="text-xs font-bold text-primary flex items-center gap-1">
                  <span class="material-symbols-outlined text-xs">update</span>
                  En curso
                </span>
              </div>
              <div class="flex flex-col">
                <span class="text-sm font-medium text-on-surface-variant">Encuestas</span>
                <strong class="text-3xl font-bold text-on-surface mt-1">{{ surveys().length }}</strong>
                <p class="text-[11px] text-on-surface-variant/70 mt-2">{{ totalSurveyResponses() }} respuestas</p>
              </div>
            </article>

            <article class="glass-card p-xl flex flex-col gap-md">
              <div class="flex justify-between items-start">
                <div class="w-12 h-12 rounded-full bg-tertiary/10 flex items-center justify-center text-tertiary shadow-sm">
                  <span class="material-symbols-outlined text-[24px]">account_balance_wallet</span>
                </div>
                <span class="text-xs font-bold text-on-surface-variant flex items-center gap-1">
                  Meta 90%
                </span>
              </div>
              <div class="flex flex-col">
                <span class="text-sm font-medium text-on-surface-variant">Presupuestos</span>
                <strong class="text-3xl font-bold text-on-surface mt-1">{{ budgets().length }}</strong>
                <p class="text-[11px] text-on-surface-variant/70 mt-2">{{ totalParticipants() }} participantes</p>
              </div>
            </article>

            <article class="glass-card p-xl flex flex-col gap-md">
              <div class="flex justify-between items-start">
                <div class="w-12 h-12 rounded-full bg-error/10 flex items-center justify-center text-error shadow-sm">
                  <span class="material-symbols-outlined text-[24px]">warning</span>
                </div>
                <span class="text-xs font-bold text-error flex items-center gap-1">
                  {{ openIssues() }} Críticas
                </span>
              </div>
              <div class="flex flex-col">
                <span class="text-sm font-medium text-on-surface-variant">Problemáticas</span>
                <strong class="text-3xl font-bold text-on-surface mt-1">{{ issues().length }}</strong>
                <p class="text-[11px] text-on-surface-variant/70 mt-2">{{ openIssues() }} en revisión</p>
              </div>
            </article>
          </div>

          <section class="animate-fade-in" *ngIf="section() === 'proposals'">
            <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-md mb-lg">
              <div><h3>Propuestas ciudadanas</h3></div>
            </div>
            <div class="grid grid-cols-1 xl:grid-cols-3 gap-lg">
              <div class="xl:col-span-1"><app-proposal-form (proposalCreated)="loadAll()"></app-proposal-form></div>
              <div class="xl:col-span-2 grid grid-cols-1 lg:grid-cols-2 gap-md">
                @for (proposal of proposals(); track proposal.id) {
                  <article class="glass-card p-0 overflow-hidden flex flex-col group border-outline-variant/30">
                    <div class="p-6 flex flex-col gap-4">
                      <div class="flex justify-between items-center">
                        <span class="text-[10px] font-bold uppercase tracking-widest text-primary px-2.5 py-1 bg-primary/10 rounded-full">#PROP-{{ proposal.id.substring(0, 4) }}</span>
                        <span class="text-[11px] font-medium text-on-surface-variant flex items-center gap-1">
                          <span class="material-symbols-outlined text-[14px]">calendar_today</span>
                          {{ proposal.createdAt | date:'MMM d, y' }}
                        </span>
                      </div>
                      
                      <div class="flex flex-col gap-1">
                        <h4 class="text-lg font-bold text-on-surface leading-tight group-hover:text-primary transition-colors">{{ proposal.title }}</h4>
                        <p class="text-sm text-on-surface-variant line-clamp-2">{{ proposal.description }}</p>
                      </div>

                      <div class="flex items-center gap-2">
                        <span class="px-2.5 py-1 bg-surface-container-low text-primary text-[10px] font-bold rounded-lg border border-primary/10">{{ proposal.category }}</span>
                        <div class="h-1 w-1 bg-outline-variant rounded-full"></div>
                        <span class="text-[10px] font-bold text-success">{{ proposal.votes }} Votos</span>
                      </div>
                    </div>

                    <div class="mt-auto p-4 bg-surface-container-low/50 border-t border-outline-variant/20 flex justify-end gap-3">
                      <button class="text-xs font-bold text-on-surface-variant hover:text-primary transition-all flex items-center gap-1">
                        <span class="material-symbols-outlined text-[16px]">chat_bubble</span>
                        {{ (proposalComments()[proposal.id] || []).length }}
                      </button>
                      <button class="btn btn-primary !py-1.5 !px-4 !text-xs !rounded-lg" [disabled]="hasVotedOnProposal(proposal.id)" (click)="voteProposal(proposal.id)">
                        {{ hasVotedOnProposal(proposal.id) ? 'Votado' : 'Votar' }}
                      </button>
                    </div>
                  </article>
                } @empty { <p class="text-on-surface-variant font-body text-body opacity-70 italic">No hay propuestas registradas.</p> }
              </div>
            </div>
          </section>

          <section class="animate-fade-in" *ngIf="section() === 'surveys'">
            <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-md mb-lg">
              <div><h3>Consultas y encuestas</h3></div>
              <div class="flex gap-sm">
                <button *ngIf="isAdmin()" class="btn btn-primary" (click)="showSurveyForm.set(!showSurveyForm())">{{ showSurveyForm() ? 'Cancelar' : 'Crear encuesta' }}</button>
                <button class="btn btn-secondary" (click)="loadSurveys()">Actualizar</button>
              </div>
            </div>

            @if (showSurveyForm()) {
              <form class="glass-card p-lg flex flex-col gap-md mb-lg" (ngSubmit)="createSurvey()">
                <h4 class="font-heading-md text-heading-md mb-md">Nueva encuesta</h4>
                <input class="input-glass" name="surveyTitle" [(ngModel)]="surveyForm.title" placeholder="Título" required>
                <textarea class="input-glass min-h-20" name="surveyDescription" [(ngModel)]="surveyForm.description" placeholder="Descripción"></textarea>
                <div class="flex flex-col gap-sm mb-md">
                  @for (q of surveyForm.questions; track $index; let idx = $index) {
                    <div class="flex gap-sm items-start bg-surface-container-lowest p-sm rounded-xl border border-outline-variant">
                      <div class="flex-1 flex flex-col gap-xs">
                        <input class="input-glass" name="qText{{idx}}" [(ngModel)]="q.text" placeholder="Pregunta" required>
                        <select class="input-glass" name="qType{{idx}}" [(ngModel)]="q.type">
                          <option value="TEXT">Texto libre</option>
                          <option value="SINGLE_CHOICE">Opción única</option>
                          <option value="MULTIPLE_CHOICE">Opción múltiple</option>
                          <option value="RATING">Calificación</option>
                          <option value="TEXTAREA">Texto largo</option>
                        </select>
                        <label class="flex items-center gap-xs font-caption text-caption"><input type="checkbox" name="qReq{{idx}}" [(ngModel)]="q.isRequired"> Obligatoria</label>
                      </div>
                      <button type="button" class="btn btn-danger px-sm" (click)="removeSurveyQuestion(idx)"><span class="material-symbols-outlined">delete</span></button>
                    </div>
                  }
                </div>
                <button type="button" class="btn btn-secondary mb-md" (click)="addSurveyQuestion()">+ Agregar pregunta</button>
                <button class="btn btn-primary" type="submit" [disabled]="isSubmitting()" [class.is-loading]="isSubmitting()">Crear encuesta</button>
              </form>
            }

            @if (selectedSurvey()) {
              <form class="glass-card p-lg flex flex-col gap-md mb-lg" (ngSubmit)="submitSurveyResponse(selectedSurvey()!.id)">
                <div class="flex justify-between items-center mb-md">
                  <h4 class="font-heading-md text-heading-md">{{ selectedSurvey()!.title }}</h4>
                  <button type="button" class="btn btn-secondary" (click)="cancelSurveyResponse()">Cerrar</button>
                </div>
                @for (q of selectedSurvey()!.questions; track q.id; let idx = $index) {
                  <div class="mb-md">
                    <label class="font-label text-label mb-xs block text-on-surface-variant">{{ q.text }} <span *ngIf="q.isRequired" class="text-error">*</span></label>
                    @switch (q.type) {
                      @case ('TEXT') { <input class="input-glass" [name]="'resp-' + q.id" [(ngModel)]="surveyResponses[q.id]" required> }
                      @case ('TEXTAREA') { <textarea class="input-glass min-h-20" [name]="'resp-' + q.id" [(ngModel)]="surveyResponses[q.id]" required></textarea> }
                      @case ('RATING') { <input type="number" class="input-glass" min="1" max="5" [name]="'resp-' + q.id" [(ngModel)]="surveyResponses[q.id]" required> }
                      @case ('SINGLE_CHOICE') {
                        <select class="input-glass" [name]="'resp-' + q.id" [(ngModel)]="surveyResponses[q.id]" required>
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
                <button class="btn btn-primary" type="submit" [disabled]="isSubmitting()" [class.is-loading]="isSubmitting()">Enviar respuesta</button>
              </form>
            }

            <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-md">
              @for (survey of surveys(); track survey.id) {
                <article class="glass-card p-lg flex flex-col gap-sm">
                  <div class="flex justify-between items-center gap-sm font-caption text-caption text-on-surface-variant">
                    <span class="rounded-full px-sm py-xs bg-surface-container-lowest border border-white/5">{{ survey.status }}</span>
                    <time>{{ survey.createdAt | date:'shortDate' }}</time>
                  </div>
                  <h4 class="font-heading-md text-heading-md text-on-surface m-0">{{ survey.title }}</h4>
                  <p class="font-body text-body text-on-surface-variant m-0">{{ survey.description }}</p>
                  <div class="flex flex-wrap gap-xs mt-sm font-caption text-caption text-on-surface-variant">
                    <span class="rounded-full px-sm py-xs bg-surface-container-lowest border border-white/5">{{ survey.questions?.length || 0 }} preguntas</span>
                    <span class="rounded-full px-sm py-xs bg-surface-container-lowest border border-white/5">{{ (survey.responseCount || 0) }} respuestas</span>
                  </div>
                  <button *ngIf="survey.status === 'ACTIVE'" class="btn btn-primary mt-md" [disabled]="hasRespondedToSurvey(survey.id)" (click)="respondSurvey(survey)">
                    {{ hasRespondedToSurvey(survey.id) ? 'Respondida' : 'Responder' }}
                  </button>
                </article>
              } @empty { <p class="text-on-surface-variant font-body text-body opacity-70 italic">No hay encuestas disponibles.</p> }
            </div>
          </section>

          <section class="animate-fade-in" *ngIf="section() === 'budgets'">
            <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-md mb-lg">
              <div><h3>Presupuestos participativos</h3></div>
              <div class="flex gap-sm">
                <button *ngIf="isAdmin()" class="btn btn-primary" (click)="showBudgetForm.set(!showBudgetForm())">{{ showBudgetForm() ? 'Cancelar' : 'Crear' }}</button>
                <button class="btn btn-secondary" (click)="loadBudgets()">Actualizar</button>
              </div>
            </div>

            @if (showBudgetForm()) {
              <form class="glass-card p-lg flex flex-col gap-md mb-lg" (ngSubmit)="createBudget()">
                <h4 class="font-heading-md text-heading-md mb-md">Nuevo presupuesto</h4>
                <input class="input-glass" name="budgetTitle" [(ngModel)]="budgetForm.title" placeholder="Título" required>
                <textarea class="input-glass min-h-20" name="budgetDescription" [(ngModel)]="budgetForm.description" placeholder="Descripción"></textarea>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-sm mb-md">
                  <input class="input-glass" name="budgetTotal" type="number" [(ngModel)]="budgetForm.totalAmount" placeholder="Monto total" required>
                  <label class="flex items-center gap-sm font-label text-label"><input type="checkbox" name="budgetMulti" [(ngModel)]="budgetForm.allowMultipleVotes"> Voto múltiple</label>
                </div>
                <div class="flex flex-col gap-sm mb-md">
                  <label class="font-label text-label text-on-surface-variant">Ítems</label>
                  @for (item of budgetForm.items || []; track $index; let idx = $index) {
                    <div class="bg-surface-container-lowest p-sm rounded-xl border border-outline-variant flex flex-col gap-xs">
                      <input class="input-glass" name="itemTitle{{idx}}" [(ngModel)]="item.title" placeholder="Nombre ítem" required>
                      <input class="input-glass" name="itemCost{{idx}}" type="number" [(ngModel)]="item.estimatedCost" placeholder="Costo" required>
                      <button type="button" class="btn btn-danger text-xs py-xs" (click)="removeBudgetItem(idx)">Eliminar</button>
                    </div>
                  }
                </div>
                <button type="button" class="btn btn-secondary mb-md" (click)="addBudgetItem()">+ Agregar ítem</button>
                <button class="btn btn-primary" type="submit" [disabled]="isSubmitting()" [class.is-loading]="isSubmitting()">Crear presupuesto</button>
              </form>
            }

            <div class="grid grid-cols-1 md:grid-cols-2 gap-md">
              @for (budget of budgets(); track budget.id) {
                <article class="glass-card p-lg flex flex-col gap-sm">
                  <div class="flex justify-between items-center gap-sm font-caption text-caption text-on-surface-variant">
                    <span class="rounded-full px-sm py-xs bg-surface-container-lowest border border-white/5">{{ budget.status }}</span>
                    <time>{{ budget.createdAt | date:'shortDate' }}</time>
                  </div>
                  <h4 class="font-heading-md text-heading-md text-on-surface m-0">{{ budget.title }}</h4>
                  <p class="font-body text-body text-on-surface-variant m-0">{{ budget.description }}</p>
                  <div class="flex flex-wrap gap-xs mt-sm font-caption text-caption text-on-surface-variant">
                    <span class="rounded-full px-sm py-xs bg-surface-container-lowest border border-white/5">{{ budget.totalAmount | currency }}</span>
                    <span class="rounded-full px-sm py-xs bg-surface-container-lowest border border-white/5">{{ budget.participantsCount }} participantes</span>
                  </div>
                  <div class="mt-md pt-md border-t border-outline-variant grid gap-sm">
                    @for (item of budget.items || []; track item.id) {
                      <div class="flex justify-between gap-sm items-center">
                        <span class="text-sm">{{ item.title }} ({{ item.voteCount }} v)</span>
                        <button class="btn btn-secondary text-xs px-sm py-xs" [disabled]="budget.status !== 'ACTIVE' || hasVotedOnBudget(budget.id)" (click)="voteBudget(budget.id, item.id)">
                          {{ hasVotedOnItem(budget.id, item.id) ? 'Votado' : (hasVotedOnBudget(budget.id) ? 'Ya votaste' : 'Votar') }}
                        </button>
                      </div>
                    }
                  </div>
                </article>
              } @empty { <p class="text-on-surface-variant font-body text-body opacity-70 italic">No hay presupuestos disponibles.</p> }
            </div>
          </section>

          <section class="animate-fade-in" *ngIf="section() === 'issues'">
            <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-md mb-lg">
              <div><h3>Mapeo territorial</h3></div>
              <button class="btn btn-secondary" (click)="loadIssues()">Actualizar</button>
            </div>
            
            <div class="glass-card mb-lg w-full h-[400px] overflow-hidden relative rounded-xl">
               <div id="map" class="w-full h-full z-0" style="filter: grayscale(100%) sepia(20%) hue-rotate(180deg) contrast(1.1);"></div>
            </div>

            <div class="grid grid-cols-1 xl:grid-cols-3 gap-lg">
              <form name="issueForm" class="glass-card p-lg flex flex-col gap-md" (ngSubmit)="createIssue()">
                <h4 class="font-heading-md text-heading-md mb-xs">Reportar</h4>
                <input class="input-glass" name="issueTitle" [(ngModel)]="issueForm.title" placeholder="Título" required>
                <input class="input-glass" name="issueCategory" [(ngModel)]="issueForm.category" placeholder="Categoría" required>
                <div class="grid grid-cols-2 gap-sm"><input class="input-glass" name="issueLatitude" type="number" step="0.0000001" [(ngModel)]="issueForm.latitude" placeholder="Latitud" required><input class="input-glass" name="issueLongitude" type="number" step="0.0000001" [(ngModel)]="issueForm.longitude" placeholder="Longitud" required></div>
                <textarea class="input-glass min-h-28" name="issueDescription" [(ngModel)]="issueForm.description" placeholder="Descripción" required></textarea>
                <button class="btn btn-primary" type="submit" [disabled]="isSubmitting()" [class.is-loading]="isSubmitting()">Reportar</button>
              </form>
              <div class="xl:col-span-2 grid grid-cols-1 md:grid-cols-2 gap-md">
                @for (issue of issues(); track issue.id) {
                  <article class="glass-card p-lg flex flex-col gap-sm">
                    <div class="flex justify-between items-center gap-sm font-caption text-caption text-on-surface-variant">
                      <span class="rounded-full px-sm py-xs bg-surface-container-lowest border border-white/5">{{ displayIssueStatus(issue.status) }}</span>
                      <time>{{ issue.createdAt | date:'shortDate' }}</time>
                    </div>
                    <h4 class="font-heading-md text-heading-md text-on-surface m-0">{{ issue.title }}</h4>
                    <p class="font-body text-body text-on-surface-variant m-0">{{ issue.description }}</p>
                    <div class="flex flex-wrap gap-xs mt-sm font-caption text-caption text-on-surface-variant">
                      <span class="rounded-full px-sm py-xs bg-surface-container-lowest border border-white/5">{{ issue.category }}</span>
                      <span class="rounded-full px-sm py-xs bg-surface-container-lowest border border-white/5">{{ issue.latitude }}, {{ issue.longitude }}</span>
                    </div>
                  </article>
                } @empty { <p class="text-on-surface-variant font-body text-body opacity-70 italic">No hay problemáticas registradas.</p> }
              </div>
            </div>
          </section>



          <section class="animate-fade-in" *ngIf="section() === 'reports' && canViewReports()">
            <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-md mb-lg">
              <div><h3>Reportes Administrativos</h3></div>
              <button class="btn btn-secondary" (click)="loadReportSummary()">Actualizar</button>
            </div>
            
            @if (reportSummary()) {
              <div class="grid grid-cols-1 lg:grid-cols-3 gap-lg mb-lg">
                <!-- Totals -->
                <div class="glass-card p-lg flex flex-col gap-md">
                  <h4 class="font-heading-md text-heading-md text-primary">Totales Generales</h4>
                  <ul class="flex flex-col gap-sm">
                    <li class="flex justify-between border-b border-outline-variant pb-xs"><span>Propuestas</span> <strong>{{ reportSummary()!.totals.proposals }}</strong></li>
                    <li class="flex justify-between border-b border-outline-variant pb-xs"><span>Encuestas</span> <strong>{{ reportSummary()!.totals.surveys }}</strong></li>
                    <li class="flex justify-between border-b border-outline-variant pb-xs"><span>Presupuestos</span> <strong>{{ reportSummary()!.totals.budgets }}</strong></li>
                    <li class="flex justify-between border-b border-outline-variant pb-xs"><span>Problemáticas</span> <strong>{{ reportSummary()!.totals.issues }}</strong></li>
                  </ul>
                </div>
                
                <!-- Status Breakdown -->
                <div class="glass-card p-lg flex flex-col gap-md lg:col-span-2">
                  <h4 class="font-heading-md text-heading-md text-primary">Desglose por Estado</h4>
                  <div class="grid grid-cols-1 md:grid-cols-3 gap-md">
                    <div>
                      <strong class="text-sm text-on-surface-variant block mb-xs">Encuestas</strong>
                      <ul class="text-sm">
                        @for (s of reportSummary()!.statuses['surveys']; track s.status) {
                          <li class="flex justify-between"><span>{{ s.status }}</span> <strong>{{ s.count }}</strong></li>
                        } @empty { <li class="opacity-50">Sin datos</li> }
                      </ul>
                    </div>
                    <div>
                      <strong class="text-sm text-on-surface-variant block mb-xs">Presupuestos</strong>
                      <ul class="text-sm">
                        @for (s of reportSummary()!.statuses['budgets']; track s.status) {
                          <li class="flex justify-between"><span>{{ s.status }}</span> <strong>{{ s.count }}</strong></li>
                        } @empty { <li class="opacity-50">Sin datos</li> }
                      </ul>
                    </div>
                    <div>
                      <strong class="text-sm text-on-surface-variant block mb-xs">Problemáticas</strong>
                      <ul class="text-sm">
                        @for (s of reportSummary()!.statuses['issues']; track s.status) {
                          <li class="flex justify-between"><span>{{ s.status }}</span> <strong>{{ s.count }}</strong></li>
                        } @empty { <li class="opacity-50">Sin datos</li> }
                      </ul>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Top Proposals -->
              <div class="glass-card p-lg flex flex-col gap-md">
                <h4 class="font-heading-md text-heading-md text-primary">Propuestas más votadas</h4>
                <div class="overflow-x-auto">
                  <table class="w-full text-left border-collapse">
                    <thead>
                      <tr class="border-b border-outline-variant">
                        <th class="p-sm font-label text-label text-on-surface-variant">Título</th>
                        <th class="p-sm font-label text-label text-on-surface-variant">Categoría</th>
                        <th class="p-sm font-label text-label text-on-surface-variant text-right">Votos</th>
                      </tr>
                    </thead>
                    <tbody>
                      @for (p of reportSummary()!.topProposals; track p.id) {
                        <tr class="border-b border-outline-variant/50 hover:bg-surface-container-low transition-colors">
                          <td class="p-sm">{{ p.title }}</td>
                          <td class="p-sm"><span class="bg-surface-container-high px-xs py-1 rounded text-xs">{{ p.category }}</span></td>
                          <td class="p-sm text-right font-bold text-primary">{{ p.votes }}</td>
                        </tr>
                      } @empty {
                        <tr><td colspan="3" class="p-sm text-center opacity-50">Sin propuestas</td></tr>
                      }
                    </tbody>
                  </table>
                </div>
              </div>
            } @else {
              <div class="flex flex-col items-center justify-center p-xl opacity-50">
                <span class="material-symbols-outlined text-4xl mb-sm animate-spin">sync</span>
                <p>Cargando datos...</p>
              </div>
            }
          </section>

          <p class="mt-lg p-md rounded-xl bg-error-container text-on-error-container font-label text-sm" *ngIf="errorMessage()">{{ errorMessage() }}</p>
    </div>
  `,
  styles: []
})
export class DashboardComponent implements OnInit {
  auth = inject(AuthService);
  private platformService = inject(PlatformService);
  private proposalService = inject(ProposalService);
  private router = inject(Router);
  private route = inject(ActivatedRoute);
  private toast = inject(ToastService);

  isSubmitting = signal(false);

  section = signal<Section>('proposals');
  proposals = signal<Proposal[]>([]);
  proposalVotes = signal<string[]>([]);
  surveys = signal<Survey[]>([]);
  surveyResponsesList = signal<string[]>([]);
  budgets = signal<Budget[]>([]);
  userVotes = signal<Record<string, string[]>>({});
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
  ];

  private map: L.Map | undefined;
  private markersLayer = L.layerGroup();

  constructor() {
    effect(() => {
      const currentSection = this.section();
      if (currentSection === 'issues') {
        setTimeout(() => this.initMap(), 100);
      }
    });

    effect(() => {
      const issuesList = this.issues();
      if (this.map) {
         this.updateMapMarkers(issuesList);
      }
    });
  }

  get userInitials(): string {
    const user = this.auth.user();
    if (user) return (user.firstName[0] + user.lastName[0]).toUpperCase();
    return 'AD';
  }

  ngOnInit() {
    this.loadAll();
    this.route.paramMap.subscribe(params => {
      const sec = params.get('section') as Section;
      if (sec) {
        this.section.set(sec);
      }
    });
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
        this.loadUserProposalVotes();
      },
      error: (err) => this.setError('No se pudieron cargar las propuestas.', err),
    });
  }

  loadUserProposalVotes() {
    this.proposalService.getUserVotes().subscribe({
      next: (votes) => this.proposalVotes.set(votes),
      error: () => this.proposalVotes.set([]),
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
      next: (data) => {
        this.surveys.set(data);
        this.loadUserSurveyResponses();
      },
      error: (err) => this.setError('No se pudieron cargar las encuestas.', err),
    });
  }

  loadUserSurveyResponses() {
    this.platformService.getUserSurveyResponses().subscribe({
      next: (responses) => this.surveyResponsesList.set(responses),
      error: () => this.surveyResponsesList.set([]),
    });
  }

  loadBudgets() {
    this.platformService.getBudgets().subscribe({
      next: (data) => {
        this.budgets.set(data);
        this.refreshUserVotesForBudgets();
      },
      error: (err) => this.setError('No se pudieron cargar los presupuestos.', err),
    });
  }
    

  private refreshUserVotesForBudgets() {
    const budgets = this.budgets();
    budgets.forEach((b) => {
      this.platformService.getUserVotes(b.id).subscribe({
        next: (votes) => {
          const itemIds = (votes || []).map(v => v.item?.id || v.itemId).filter(Boolean);
          this.userVotes.update(curr => ({ ...curr, [b.id]: itemIds }));
        },
        error: () => {
          this.userVotes.update(curr => ({ ...curr, [b.id]: [] }));
        }
      });
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
      next: (updated) => {
        this.proposals.update((items) => items.map((item) => item.id === updated.id ? updated : item));
        this.loadUserProposalVotes();
        this.toast.success('Voto registrado exitosamente');
      },
      error: (err) => this.setError('No se pudo registrar el voto de propuesta.', err),
    });
  }

  voteBudget(budgetId: string, itemId: string) {
    this.platformService.voteBudget(budgetId, itemId).subscribe({
      next: () => {
        this.loadBudgets();
        this.toast.success('Voto registrado exitosamente');
      },
      error: (err) => this.setError('No se pudo registrar el voto de presupuesto.', err),
    });
  }

  hasVotedOnItem(budgetId: string, itemId: string) {
    const map = this.userVotes();
    return !!(map[budgetId] && map[budgetId].includes(itemId));
  }

  hasVotedOnBudget(budgetId: string) {
    const map = this.userVotes();
    return !!(map[budgetId] && map[budgetId].length > 0);
  }

  hasVotedOnProposal(proposalId: string) {
    return this.proposalVotes().includes(proposalId);
  }

  hasRespondedToSurvey(surveyId: string) {
    return this.surveyResponsesList().includes(surveyId);
  }

  addProposalComment(proposalId: string) {
    const content = this.commentDrafts[proposalId]?.trim();
    if (!content) return;
    this.proposalService.addComment(proposalId, content).subscribe({
      next: (comment) => {
        this.proposalComments.update((current) => ({ ...current, [proposalId]: [comment, ...(current[proposalId] || [])] }));
        this.commentDrafts[proposalId] = '';
        this.toast.success('Comentario agregado con éxito');
      },
      error: (err) => this.setError('No se pudo agregar el comentario.', err),
    });
  }

  createIssue() {
    this.isSubmitting.set(true);
    this.platformService.createIssue({ ...this.issueForm, latitude: Number(this.issueForm.latitude), longitude: Number(this.issueForm.longitude) }).subscribe({
      next: (issue) => {
        this.issues.update((items) => [issue, ...items]);
        this.issueForm = { title: '', description: '', category: '', address: '', latitude: 0, longitude: 0 };
        this.toast.success('Problemática reportada exitosamente');
        this.isSubmitting.set(false);
      },
      error: (err) => {
        this.setError('No se pudo registrar la problemática territorial.', err);
        this.isSubmitting.set(false);
      },
    });
  }

  initMap() {
    if (this.map) {
      this.map.invalidateSize();
      return;
    }
    const mapEl = document.getElementById('map');
    if (!mapEl) return;

    this.map = L.map('map').setView([-33.4116, -70.5794], 14);

    L.tileLayer('https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png', {
      attribution: '&copy; OpenStreetMap contributors &copy; CARTO',
      subdomains: 'abcd',
      maxZoom: 20
    }).addTo(this.map);

    this.markersLayer.addTo(this.map);
    this.updateMapMarkers(this.issues());

    this.map.on('click', (e: L.LeafletMouseEvent) => {
      this.issueForm.latitude = Number(e.latlng.lat.toFixed(7));
      this.issueForm.longitude = Number(e.latlng.lng.toFixed(7));
      this.toast.success('Ubicación capturada para nuevo reporte');
      document.querySelector('form[name="issueForm"]')?.scrollIntoView({ behavior: 'smooth' });
    });
  }

  updateMapMarkers(issues: Issue[]) {
    this.markersLayer.clearLayers();
    issues.forEach(issue => {
      if (issue.latitude && issue.longitude) {
        let statusColor = '#60a5fa'; // Default blue
        if (issue.status === 'OPEN') statusColor = '#ef4444'; // Red
        else if (issue.status === 'IN_REVIEW') statusColor = '#eab308'; // Yellow
        else if (issue.status === 'RESOLVED') statusColor = '#22c55e'; // Green

        const customIcon = L.divIcon({
          className: 'custom-leaflet-marker',
          html: `<div style="background-color: ${statusColor}; width: 18px; height: 18px; border-radius: 50%; border: 3px solid white; box-shadow: 0 0 6px rgba(0,0,0,0.4); cursor: pointer; transition: transform 0.2s;" onmouseover="this.style.transform='scale(1.2)'" onmouseout="this.style.transform='scale(1)'"></div>`,
          iconSize: [18, 18],
          iconAnchor: [9, 9],
          popupAnchor: [0, -9]
        });

        const marker = L.marker([issue.latitude, issue.longitude], { icon: customIcon });

        marker.bindPopup(`
          <div style="font-family: 'Inter', sans-serif; padding: 4px;">
            <strong style="display: block; color: #1e293b; font-size: 14px; margin-bottom: 4px;">${issue.title}</strong>
            <span style="display: inline-block; font-size: 11px; background: #e2e8f0; color: #1e293b; padding: 2px 8px; border-radius: 12px; margin-bottom: 8px;">${issue.category}</span>
            <p style="margin: 0; font-size: 13px; color: ${statusColor}; font-weight: 600;">${this.displayIssueStatus(issue.status)}</p>
          </div>
        `, {
          className: 'enterprise-popup'
        });
        
        this.markersLayer.addLayer(marker);
      }
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
    this.isSubmitting.set(true);
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
        this.toast.success('Encuesta creada exitosamente');
        this.isSubmitting.set(false);
      },
      error: (err) => {
        this.setError('No se pudo crear la encuesta.', err);
        this.isSubmitting.set(false);
      },
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
    this.isSubmitting.set(true);
    this.platformService.createBudget(this.budgetForm).subscribe({
      next: (budget) => {
        this.budgets.update(items => [budget, ...items]);
        this.showBudgetForm.set(false);
        this.budgetForm = { title: '', description: '', totalAmount: 0, items: [] };
        this.toast.success('Presupuesto creado con éxito');
        this.isSubmitting.set(false);
      },
      error: (err) => {
        this.setError('No se pudo crear el presupuesto.', err);
        this.isSubmitting.set(false);
      },
    });
  }

  respondSurvey(survey: Survey) {
    this.selectedSurvey.set(survey);
    this.surveyResponses = {};
  }

  submitSurveyResponse(surveyId: string) {
    const responses: { questionId: string; response: string | string[] | number }[] = Object.entries(this.surveyResponses).map(([questionId, response]) => ({ questionId, response }));
    this.isSubmitting.set(true);
    this.platformService.submitSurveyResponse(surveyId, responses).subscribe({
      next: () => {
        this.loadSurveys();
        this.loadUserSurveyResponses();
        this.selectedSurvey.set(null);
        this.toast.success('Respuesta enviada con éxito');
        this.isSubmitting.set(false);
      },
      error: (err) => {
        this.setError('No se pudo enviar la respuesta.', err);
        this.isSubmitting.set(false);
      },
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
    this.toast.error(message);
  }
}
