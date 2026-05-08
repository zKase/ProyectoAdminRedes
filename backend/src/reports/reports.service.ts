import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Parser } from 'json2csv';
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

  async exportToCsv(type: string) {
    let data: any[] = [];
    let fields: string[] = [];

    switch (type) {
      case 'proposals':
        data = await this.proposalsRepository.find();
        fields = ['id', 'title', 'description', 'votes', 'category', 'createdAt'];
        break;
      case 'issues':
        data = await this.issuesRepository.find({
          relations: ['creator'],
        });
        fields = [
          'id',
          'title',
          'description',
          'category',
          'status',
          'latitude',
          'longitude',
          'creator.email',
          'createdAt',
        ];
        break;
      case 'surveys':
        data = await this.surveysRepository.find();
        fields = ['id', 'title', 'description', 'status', 'startDate', 'endDate', 'createdAt'];
        break;
      default:
        throw new Error('Tipo de reporte no válido');
    }

    const parser = new Parser({ fields, delimiter: ';' });
    const csv = parser.parse(data);
    // Añadimos el BOM para que Excel reconozca UTF-8 (tildes, etc)
    return '\ufeff' + csv;
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
