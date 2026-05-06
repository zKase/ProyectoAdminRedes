export interface Proposal {
  id: string;
  title: string;
  description: string;
  votes: number;
  category: string;
  createdAt: Date;
}

export interface CreateProposalDto {
  title: string;
  description: string;
  category: string;
}
