import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../environments/environment';
import { Budget, ChatbotResponse, CreateIssueDto, Issue, ReportSummary, Survey, Incident } from '../models/platform.model';

@Injectable({ providedIn: 'root' })
export class PlatformService {
  private http = inject(HttpClient);

  // Survey endpoints
  getSurveys() {
    return this.http.get<Survey[]>(`${environment.apiUrl}/surveys`);
  }

  // Budget endpoints
  getBudgets() {
    return this.http.get<Budget[]>(`${environment.apiUrl}/budgets`);
  }

  voteBudget(budgetId: string, itemId: string) {
    return this.http.post<{ message: string; voteCount: number }>(`${environment.apiUrl}/budgets/${budgetId}/vote`, { itemId });
  }

  // Participatory mapping endpoints
  getIssues() {
    return this.http.get<Issue[]>(`${environment.apiUrl}/issues`);
  }

  createIssue(issue: CreateIssueDto) {
    return this.http.post<Issue>(`${environment.apiUrl}/issues`, issue);
  }

  // Reports endpoints
  getReportSummary() {
    return this.http.get<ReportSummary>(`${environment.apiUrl}/reports/summary`);
  }

  // Chatbot endpoint
  askChatbot(message: string) {
    return this.http.post<ChatbotResponse>(`${environment.apiUrl}/chatbot/ask`, { message });
  }

  // Incident endpoints
  getIncidents() {
    return this.http.get<Incident[]>(`${environment.apiUrl}/incidents`);
  }

  getIncidentById(id: string) {
    return this.http.get<Incident>(`${environment.apiUrl}/incidents/${id}`);
  }

  createIncident(incident: Omit<Incident, 'id' | 'createdAt'>) {
    return this.http.post<Incident>(`${environment.apiUrl}/incidents`, incident);
  }

  updateIncident(id: string, incident: Partial<Incident>) {
    return this.http.put<Incident>(`${environment.apiUrl}/incidents/${id}`, incident);
  }

  resolveIncident(id: string) {
    return this.http.put<Incident>(`${environment.apiUrl}/incidents/${id}`, { status: 'Resolved' });
  }

  closeIncident(id: string) {
    return this.http.put<Incident>(`${environment.apiUrl}/incidents/${id}`, { status: 'Closed' });
  }
}
