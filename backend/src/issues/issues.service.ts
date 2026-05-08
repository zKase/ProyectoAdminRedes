import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CreateIssueDto, UpdateIssueDto } from './dto/issue.dto';
import { Issue, IssueStatus } from './entities/issue.entity';

@Injectable()
export class IssuesService {
  constructor(
    @InjectRepository(Issue)
    private issuesRepository: Repository<Issue>,
  ) {}

  async create(createIssueDto: CreateIssueDto, userId: string): Promise<Issue> {
    const issue = this.issuesRepository.create({
      ...createIssueDto,
      createdBy: userId,
    });
    return this.issuesRepository.save(issue);
  }

  async findAll(status?: IssueStatus): Promise<Issue[]> {
    const query = this.issuesRepository.createQueryBuilder('issue');

    if (status) {
      query.where('issue.status = :status', { status });
    }

    return query.orderBy('issue.createdAt', 'DESC').getMany();
  }

  async findById(id: string): Promise<Issue> {
    const issue = await this.issuesRepository.findOne({ where: { id }, relations: ['creator'] });
    if (!issue) {
      throw new NotFoundException('Problemática territorial no encontrada');
    }
    return issue;
  }

  async update(id: string, updateIssueDto: UpdateIssueDto): Promise<Issue> {
    const issue = await this.findById(id);
    Object.assign(issue, updateIssueDto);
    await this.issuesRepository.save(issue);
    return this.findById(id);
  }

  async updateStatus(id: string, status: IssueStatus): Promise<Issue> {
    return this.update(id, { status });
  }
}
