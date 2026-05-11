import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { Proposal } from './proposal.entity';

@Entity('proposal_votes')
@Index(['proposalId', 'userId'], { unique: true })
export class ProposalVote {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  proposalId: string;

  @Column()
  userId: string;

  @ManyToOne(() => Proposal, (proposal) => proposal.votes_relation, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'proposalId' })
  proposal: Proposal;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: User;

  @CreateDateColumn()
  createdAt: Date;
}
