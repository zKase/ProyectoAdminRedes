import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Proposal } from './entities/proposal.entity';
import { CreateProposalDto } from './dto/create-proposal.dto';

@Injectable()
export class ProposalsService {
  constructor(
    @InjectRepository(Proposal)
    private proposalsRepository: Repository<Proposal>,
  ) {}

  async create(createProposalDto: CreateProposalDto): Promise<Proposal> {
    const proposal = this.proposalsRepository.create(createProposalDto);
    return this.proposalsRepository.save(proposal);
  }

  async findAll(): Promise<Proposal[]> {
    return this.proposalsRepository.find({ order: { createdAt: 'DESC' } });
  }

  async vote(id: string): Promise<Proposal> {
    const proposal = await this.proposalsRepository.findOneBy({ id });
    if (!proposal) {
      throw new NotFoundException(`Proposal with ID "${id}" not found`);
    }
    proposal.votes += 1;
    return this.proposalsRepository.save(proposal);
  }
}
