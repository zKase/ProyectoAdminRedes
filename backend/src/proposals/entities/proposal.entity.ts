import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, OneToMany } from 'typeorm';
import { ProposalVote } from './proposal-vote.entity';

@Entity('proposals')
export class Proposal {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  title: string;

  @Column('text')
  description: string;

  @Column({ default: 0 })
  votes: number;

  @Column()
  category: string;

  @OneToMany(() => ProposalVote, (vote) => vote.proposal)
  votes_relation: ProposalVote[];

  @Column('simple-array', { default: '' })
  votedBy: string[] = [];

  @CreateDateColumn()
  createdAt: Date;
}
