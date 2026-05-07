export interface AuthUser {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  role: 'CITIZEN' | 'ADMIN' | 'MODERATOR';
}

export interface AuthResponse {
  message: string;
  user: AuthUser;
  token: string;
}

export interface SurveyQuestion {
  id: string;
  text: string;
  type: string;
  options?: string[];
  order: number;
  isRequired: boolean;
}

export interface Survey {
  id: string;
  title: string;
  description: string;
  status: string;
  responseCount: number;
  questions: SurveyQuestion[];
  createdAt: string;
}

export interface BudgetItem {
  id: string;
  title: string;
  description: string;
  estimatedCost: number;
  voteCount: number;
}

export interface Budget {
  id: string;
  title: string;
  description: string;
  status: string;
  totalAmount: number;
  allocatedAmount: number;
  participantsCount: number;
  allowMultipleVotes: boolean;
  items: BudgetItem[];
  createdAt: string;
}

export interface Incident {
  id: string;
  title: string;
  description: string;
  status: 'Open' | 'In Progress' | 'Resolved' | 'Closed';
  priority: 'Critical' | 'High' | 'Medium' | 'Low';
  severity?: 'Critical' | 'High' | 'Medium' | 'Low';
  category?: string;
  reporterId: string;
  reporterName?: string;
  reporterRole?: string;
  location?: string;
  dateReported: string;
  createdAt?: string;
  updatedAt?: string;
  resolvedAt?: string;
}
