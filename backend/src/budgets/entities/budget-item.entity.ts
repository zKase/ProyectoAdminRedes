import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  ManyToOne,
  JoinColumn,
  OneToMany,
  Index,
} from 'typeorm';
import { Budget } from './budget.entity';
import { BudgetVote } from './budget-vote.entity';

@Entity('budget_items')
@Index(['budgetId'])
export class BudgetItem {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  budgetId: string;

  @ManyToOne(() => Budget, (budget) => budget.items, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'budgetId' })
  budget: Budget;

  @Column()
  title: string;

  @Column('text')
  description: string;

  @Column({ type: 'decimal', precision: 12, scale: 2 })
  estimatedCost: number;

  @Column({ type: 'int', default: 0 })
  voteCount: number;

  @Column({ default: true })
  isActive: boolean;

  @OneToMany(() => BudgetVote, (vote) => vote.item)
  votes: BudgetVote[];
}
