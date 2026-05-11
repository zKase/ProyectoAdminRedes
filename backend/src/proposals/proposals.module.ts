import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ProposalsService } from './proposals.service';
import { ProposalsController } from './proposals.controller';
import { Proposal } from './entities/proposal.entity';
import { ProposalComment } from './entities/proposal-comment.entity';
import { ProposalVote } from './entities/proposal-vote.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Proposal, ProposalComment, ProposalVote])],
  controllers: [ProposalsController],
  providers: [ProposalsService],
  exports: [ProposalsService],
})
export class ProposalsModule {}
