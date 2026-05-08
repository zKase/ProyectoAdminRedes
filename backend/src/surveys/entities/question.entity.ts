import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  ManyToOne,
  JoinColumn,
  OneToMany,
  Index,
} from 'typeorm';
import { Survey } from './survey.entity';
import { SurveyResponse } from './survey-response.entity';

export enum QuestionType {
  TEXT = 'TEXT',
  MULTIPLE_CHOICE = 'MULTIPLE_CHOICE',
  SINGLE_CHOICE = 'SINGLE_CHOICE',
  RATING = 'RATING',
  CHECKBOX = 'CHECKBOX',
  TEXTAREA = 'TEXTAREA',
}

@Entity('questions')
@Index(['surveyId'])
export class Question {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  surveyId: string;

  @ManyToOne(() => Survey, (survey) => survey.questions, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'surveyId' })
  survey: Survey;

  @Column()
  text: string;

  @Column({ type: 'enum', enum: QuestionType, default: QuestionType.TEXT })
  type: QuestionType;

  @Column({ type: 'int', default: 0 })
  order: number;

  @Column({ default: true })
  isRequired: boolean;

  // Para MULTIPLE_CHOICE, SINGLE_CHOICE, CHECKBOX
  @Column({ type: 'json', nullable: true })
  options: string[]; // ["Opción 1", "Opción 2", ...]

  // Lógica condicional: mostrar esta pregunta si...
  @Column({ type: 'json', nullable: true })
  conditionalLogic: {
    dependsOn: string; // ID de la pregunta de la que depende
    condition: 'equals' | 'notEquals' | 'contains' | 'greaterThan' | 'lessThan';
    value: string | number;
  };

  @Column({ default: false })
  isConditional: boolean;

  @OneToMany(() => SurveyResponse, (response) => response.question)
  responses: SurveyResponse[];
}
