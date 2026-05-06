import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ProposalsService } from './proposals.service';
import { ProposalsController } from './proposals.controller';
import { Proposal } from './entities/proposal.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Proposal])],
  controllers: [ProposalsController],
  providers: [ProposalsService],
})
export class ProposalsModule {}
