import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
  Unique,
} from 'typeorm';
import { Budget } from './budget.entity';
import { BudgetItem } from './budget-item.entity';
import { User } from '../../users/entities/user.entity';

@Entity('budget_votes')
@Index(['budgetId', 'userId'])
@Unique(['budgetId', 'itemId', 'userId']) // Un voto por usuario por item en un presupuesto
export class BudgetVote {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  budgetId: string;

  @ManyToOne(() => Budget, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'budgetId' })
  budget: Budget;

  @Column()
  itemId: string;

  @ManyToOne(() => BudgetItem, (item) => item.votes, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'itemId' })
  item: BudgetItem;

  @Column()
  userId: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: User;

  @CreateDateColumn()
  createdAt: Date;
}
