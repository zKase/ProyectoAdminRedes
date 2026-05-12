export interface Proposal {
  id: string;
  title: string;
  description: string;
  votes: number;
  category: string;
  votedBy?: string[];
  createdAt: Date;
}

export interface ProposalComment {
  id: string;
  proposalId: string;
  content: string;
  status: 'VISIBLE' | 'HIDDEN';
  createdAt: string;
  user?: {
    firstName: string;
    lastName: string;
  };
}

export interface CreateProposalDto {
  title: string;
  description: string;
  category: string;
}
