import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpErrorResponse } from '@angular/common/http';
import { Observable, throwError } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { Proposal, CreateProposalDto, ProposalComment } from '../models/proposal.model';
import { environment } from '../../environments/environment';

@Injectable({
  providedIn: 'root'
})
export class ProposalService {
  private http = inject(HttpClient);
  private apiUrl = `${environment.apiUrl}/proposals`;

  getProposals(): Observable<Proposal[]> {
    return this.http.get<Proposal[]>(this.apiUrl).pipe(
      catchError((err: HttpErrorResponse) => {
        console.error('Error al obtener propuestas', err);
        const payload = { message: err.message || 'Error al obtener propuestas', status: err.status };
        return throwError(() => payload);
      })
    );
  }

  createProposal(proposal: CreateProposalDto): Observable<Proposal> {
    return this.http.post<Proposal>(this.apiUrl, proposal).pipe(
      catchError((err: HttpErrorResponse) => {
        console.error('Error al crear propuesta', err);
        const payload = { message: err.message || 'Error al crear propuesta', status: err.status };
        return throwError(() => payload);
      })
    );
  }

  vote(id: string): Observable<Proposal> {
    return this.http.patch<Proposal>(`${this.apiUrl}/${id}/vote`, {}).pipe(
      catchError((err: HttpErrorResponse) => {
        console.error('Error al votar propuesta', err);
        const payload = { message: err.message || 'Error al votar propuesta', status: err.status };
        return throwError(() => payload);
      })
    );
  }

  getComments(proposalId: string): Observable<ProposalComment[]> {
    return this.http.get<ProposalComment[]>(`${this.apiUrl}/${proposalId}/comments`);
  }

  addComment(proposalId: string, content: string): Observable<ProposalComment> {
    return this.http.post<ProposalComment>(`${this.apiUrl}/${proposalId}/comments`, { content });
  }

  deleteProposal(id: string): Observable<any> {
    return this.http.delete(`${this.apiUrl}/${id}`).pipe(
      catchError((err: HttpErrorResponse) => {
        console.error('Error al eliminar propuesta', err);
        return throwError(() => ({ message: err.message || 'Error al eliminar propuesta', status: err.status }));
      })
    );
  }
}
