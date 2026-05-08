import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Budget } from '../budgets/entities/budget.entity';
import { Issue } from '../issues/entities/issue.entity';
import { Proposal } from '../proposals/entities/proposal.entity';
import { Survey } from '../surveys/entities/survey.entity';
import { ReportsController } from './reports.controller';
import { ReportsService } from './reports.service';

@Module({
  imports: [TypeOrmModule.forFeature([Proposal, Survey, Budget, Issue])],
  controllers: [ReportsController],
  providers: [ReportsService],
})
export class ReportsModule {}
