import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Proposal, CreateProposalDto } from '../models/proposal.model';
import { environment } from '../../environments/environment';

@Injectable({
  providedIn: 'root'
})
export class ProposalService {
  private http = inject(HttpClient);
  private apiUrl = `${environment.apiUrl}/proposals`;

  getProposals(): Observable<Proposal[]> {
    return this.http.get<Proposal[]>(this.apiUrl);
  }

  createProposal(proposal: CreateProposalDto): Observable<Proposal> {
    return this.http.post<Proposal>(this.apiUrl, proposal);
  }

  vote(id: string): Observable<Proposal> {
    return this.http.patch<Proposal>(`${this.apiUrl}/${id}/vote`, {});
  }
}
