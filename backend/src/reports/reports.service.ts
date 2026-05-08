import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Budget } from '../budgets/entities/budget.entity';
import { Issue } from '../issues/entities/issue.entity';
import { Proposal } from '../proposals/entities/proposal.entity';
import { Survey } from '../surveys/entities/survey.entity';

@Injectable()
export class ReportsService {
  constructor(
    @InjectRepository(Proposal)
    private proposalsRepository: Repository<Proposal>,
    @InjectRepository(Survey)
    private surveysRepository: Repository<Survey>,
    @InjectRepository(Budget)
    private budgetsRepository: Repository<Budget>,
    @InjectRepository(Issue)
    private issuesRepository: Repository<Issue>,
  ) {}

  async getSummary() {
    const [proposals, surveys, budgets, issues] = await Promise.all([
      this.proposalsRepository.count(),
      this.surveysRepository.count(),
      this.budgetsRepository.count(),
      this.issuesRepository.count(),
    ]);

    const [surveyStatuses, budgetStatuses, issueStatuses, topProposals] = await Promise.all([
      this.countByStatus('surveys', 'status'),
      this.countByStatus('budgets', 'status'),
      this.countByStatus('issues', 'status'),
      this.proposalsRepository.find({ order: { votes: 'DESC' }, take: 5 }),
    ]);

    return {
      totals: { proposals, surveys, budgets, issues },
      statuses: {
        surveys: surveyStatuses,
        budgets: budgetStatuses,
        issues: issueStatuses,
      },
      topProposals,
    };
  }

  private async countByStatus(table: string, column: string) {
    return this.proposalsRepository.manager
      .createQueryBuilder()
      .select(column, 'status')
      .addSelect('COUNT(*)', 'count')
      .from(table, table)
      .groupBy(column)
      .getRawMany();
  }
}
