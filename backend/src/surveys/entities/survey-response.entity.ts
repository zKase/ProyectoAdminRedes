import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import { Survey } from './survey.entity';
import { Question } from './question.entity';
import { User } from '../../users/entities/user.entity';

@Entity('survey_responses')
@Index(['surveyId', 'questionId', 'userId'], { unique: true })
@Index(['questionId'])
export class SurveyResponse {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  surveyId: string;

  @ManyToOne(() => Survey, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'surveyId' })
  survey: Survey;

  @Column()
  questionId: string;

  @ManyToOne(() => Question, (question) => question.responses, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'questionId' })
  question: Question;

  @Column()
  userId: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column({ type: 'json' })
  response: string | string[] | number; // Puede ser texto, array de opciones o número

  @CreateDateColumn()
  createdAt: Date;
}
