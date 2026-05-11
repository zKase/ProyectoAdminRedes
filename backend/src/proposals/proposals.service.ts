import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Proposal } from './entities/proposal.entity';
import { CreateProposalDto } from './dto/create-proposal.dto';
import { CreateProposalCommentDto, UpdateProposalCommentDto } from './dto/proposal-comment.dto';
import { ProposalComment, ProposalCommentStatus } from './entities/proposal-comment.entity';

@Injectable()
export class ProposalsService {
  constructor(
    @InjectRepository(Proposal)
    private proposalsRepository: Repository<Proposal>,
    @InjectRepository(ProposalComment)
    private commentsRepository: Repository<ProposalComment>,
  ) {}

  async create(createProposalDto: CreateProposalDto): Promise<Proposal> {
    const proposal = this.proposalsRepository.create(createProposalDto);
    return this.proposalsRepository.save(proposal);
  }

  async findAll(): Promise<Proposal[]> {
    return this.proposalsRepository.find({ order: { createdAt: 'DESC' } });
  }

  async vote(id: string, userId: string): Promise<Proposal> {
    const proposal = await this.proposalsRepository.findOneBy({ id });
    if (!proposal) {
      throw new NotFoundException(`Proposal with ID "${id}" not found`);
    }
    
    if (!proposal.votedBy) proposal.votedBy = [];
    if (proposal.votedBy.includes(userId)) {
      throw new ConflictException('Ya has votado por esta propuesta');
    }

    proposal.votes += 1;
    proposal.votedBy.push(userId);
    return this.proposalsRepository.save(proposal);
  }

  async addComment(
    proposalId: string,
    dto: CreateProposalCommentDto,
    userId: string,
  ): Promise<ProposalComment> {
    await this.findById(proposalId);

    const comment = this.commentsRepository.create({
      proposalId,
      userId,
      content: dto.content,
    });

    return this.commentsRepository.save(comment);
  }

  async findComments(proposalId: string, includeHidden = false): Promise<ProposalComment[]> {
    await this.findById(proposalId);

    const where = includeHidden
      ? { proposalId }
      : { proposalId, status: ProposalCommentStatus.VISIBLE };

    return this.commentsRepository.find({
      where,
      relations: ['user'],
      order: { createdAt: 'DESC' },
    });
  }

  async updateComment(id: string, dto: UpdateProposalCommentDto): Promise<ProposalComment> {
    const comment = await this.commentsRepository.findOneBy({ id });
    if (!comment) {
      throw new NotFoundException('Comentario no encontrado');
    }

    Object.assign(comment, dto);
    return this.commentsRepository.save(comment);
  }

  private async findById(id: string): Promise<Proposal> {
    const proposal = await this.proposalsRepository.findOneBy({ id });
    if (!proposal) {
      throw new NotFoundException(`Proposal with ID "${id}" not found`);
    }
    return proposal;
  }

  async remove(id: string): Promise<void> {
    const proposal = await this.findById(id);
    await this.proposalsRepository.remove(proposal);
  }
}
