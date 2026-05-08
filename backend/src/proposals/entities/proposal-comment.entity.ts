import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { Proposal } from './proposal.entity';

export enum ProposalCommentStatus {
  VISIBLE = 'VISIBLE',
  HIDDEN = 'HIDDEN',
}

@Entity('proposal_comments')
@Index(['proposalId', 'createdAt'])
export class ProposalComment {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  proposalId: string;

  @ManyToOne(() => Proposal, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'proposalId' })
  proposal: Proposal;

  @Column({ nullable: true })
  userId: string;

  @ManyToOne(() => User, { onDelete: 'SET NULL', nullable: true })
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column('text')
  content: string;

  @Column({ type: 'enum', enum: ProposalCommentStatus, default: ProposalCommentStatus.VISIBLE })
  status: ProposalCommentStatus;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
