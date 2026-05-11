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
  questions?: SurveyQuestion[];
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

export interface Issue {
  id: string;
  title: string;
  description: string;
  category: string;
  status: 'OPEN' | 'IN_REVIEW' | 'RESOLVED' | 'CLOSED';
  latitude: number;
  longitude: number;
  address?: string;
  createdAt: string;
}

export interface CreateIssueDto {
  title: string;
  description: string;
  category: string;
  latitude: number;
  longitude: number;
  address?: string;
}

export interface ReportSummary {
  totals: {
    proposals: number;
    surveys: number;
    budgets: number;
    issues: number;
  };
  statuses: Record<string, Array<{ status: string; count: string }>>;
  topProposals: Array<{ id: string; title: string; votes: number }>;
}

export interface ChatbotResponse {
  mode: 'local' | 'fallback' | 'openrouter';
  answer: string;
}

export interface CreateSurveyQuestionDto {
  text: string;
  type: 'TEXT' | 'MULTIPLE_CHOICE' | 'SINGLE_CHOICE' | 'RATING' | 'CHECKBOX' | 'TEXTAREA';
  options?: string[];
  isRequired?: boolean;
  order?: number;
}

export interface CreateSurveyDto {
  title: string;
  description: string;
  startDate?: string;
  endDate?: string;
  questions?: CreateSurveyQuestionDto[];
}

export interface SurveyResponse {
  questionId: string;
  response: string | string[] | number;
}

export interface SubmitSurveyResponseDto {
  surveyId: string;
  responses: SurveyResponse[];
}

export interface CreateBudgetItemDto {
  title: string;
  description: string;
  estimatedCost: number;
}

export interface CreateBudgetDto {
  title: string;
  description: string;
  totalAmount: number;
  startDate?: string;
  endDate?: string;
  allowMultipleVotes?: boolean;
  items?: CreateBudgetItemDto[];
}
