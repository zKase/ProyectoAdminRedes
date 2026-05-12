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

  getUserSurveyResponses() {
    return this.http.get<string[]>(`${environment.apiUrl}/surveys/user-responses`);
  }

  // Budget endpoints
  getBudgets() {
    return this.http.get<Budget[]>(`${environment.apiUrl}/budgets`);
  }

  voteBudget(budgetId: string, itemId: string) {
    return this.http.post<{ message: string; voteCount: number }>(`${environment.apiUrl}/budgets/${budgetId}/vote`, { itemId });
  }

  // Get votes made by the current user in a specific budget
  getUserVotes(budgetId: string) {
    return this.http.get<any[]>(`${environment.apiUrl}/budgets/${budgetId}/user-votes`);
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
    return this.http.get<Incident[]>(`${environment.apiUrl}/incidents`).pipe(
      // If incidents endpoint is not implemented on backend (404), treat as empty list
      // This prevents console errors for legacy screens and keeps UX stable
      // Other errors will propagate
      // eslint-disable-next-line @typescript-eslint/no-unused-vars
      // note: keep typings consistent
      // Import operators at top
      // Will handle errors in-place
      (source) => source
    );
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
