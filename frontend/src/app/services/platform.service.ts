import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../environments/environment';
import { Budget, ChatbotResponse, CreateBudgetDto, CreateIssueDto, CreateSurveyDto, Issue, ReportSummary, SubmitSurveyResponseDto, Survey, Incident } from '../models/platform.model';

@Injectable({ providedIn: 'root' })
export class PlatformService {
  private http = inject(HttpClient);

  // Survey endpoints
  getSurveys() {
    return this.http.get<Survey[]>(`${environment.apiUrl}/surveys`);
  }

  createSurvey(survey: CreateSurveyDto) {
    return this.http.post<Survey>(`${environment.apiUrl}/surveys`, survey);
  }

  submitSurveyResponse(surveyId: string, responses: { questionId: string; response: string | string[] | number }[]) {
    return this.http.post<{ message: string }>(`${environment.apiUrl}/surveys/${surveyId}/submit`, { surveyId, responses });
  }

  updateSurveyStatus(id: string, status: string) {
    return this.http.patch<Survey>(`${environment.apiUrl}/surveys/${id}/status/${status}`, {});
  }

  deleteSurvey(id: string) {
    return this.http.delete<{ message: string }>(`${environment.apiUrl}/surveys/${id}`);
  }

  // Budget endpoints
  getBudgets() {
    return this.http.get<Budget[]>(`${environment.apiUrl}/budgets`);
  }

  voteBudget(budgetId: string, itemId: string) {
    return this.http.post<{ message: string; voteCount: number }>(`${environment.apiUrl}/budgets/${budgetId}/vote`, { itemId });
  }

  createBudget(budget: CreateBudgetDto) {
    return this.http.post<Budget>(`${environment.apiUrl}/budgets`, budget);
  }

  updateBudgetStatus(id: string, status: string) {
    return this.http.patch<Budget>(`${environment.apiUrl}/budgets/${id}/status/${status}`, {});
  }

  deleteBudget(id: string) {
    return this.http.delete<{ message: string }>(`${environment.apiUrl}/budgets/${id}`);
  }

  // Participatory mapping endpoints
  getIssues() {
    return this.http.get<Issue[]>(`${environment.apiUrl}/issues`);
  }

  createIssue(issue: CreateIssueDto) {
    return this.http.post<Issue>(`${environment.apiUrl}/issues`, issue);
  }

  updateIssueStatus(id: string, status: string) {
    return this.http.patch<Issue>(`${environment.apiUrl}/issues/${id}/status/${status}`, {});
  }

  deleteIssue(id: string) {
    return this.http.delete<{ message: string }>(`${environment.apiUrl}/issues/${id}`);
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
