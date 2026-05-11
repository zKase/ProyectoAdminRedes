import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, ManyToOne } from 'typeorm';
import { User } from '../../users/entities/user.entity';

@Entity('incidents')
export class Incident {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  title: string;

  @Column({ type: 'text' })
  description: string;

  @Column({
    type: 'enum',
    enum: ['Open', 'In Progress', 'Resolved', 'Closed'],
    default: 'Open',
  })
  status: string;

  @Column({
    type: 'enum',
    enum: ['Critical', 'High', 'Medium', 'Low'],
    default: 'Medium',
  })
  priority: string;

  @Column({ nullable: true })
  category: string;

  @Column({ nullable: true })
  location: string;

  @ManyToOne(() => User, { eager: true })
  reporter: User;

  @Column()
  dateReported: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @Column({ nullable: true })
  resolvedAt: Date;
}
