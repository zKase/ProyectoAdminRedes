import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Budget } from './entities/budget.entity';
import { BudgetItem } from './entities/budget-item.entity';
import { BudgetVote } from './entities/budget-vote.entity';
import { BudgetsService } from './budgets.service';
import { BudgetsController } from './budgets.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Budget, BudgetItem, BudgetVote])],
  controllers: [BudgetsController],
  providers: [BudgetsService],
})
export class BudgetsModule {}
