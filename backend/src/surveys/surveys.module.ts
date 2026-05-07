import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Survey } from './entities/survey.entity';
import { Question } from './entities/question.entity';
import { SurveyResponse } from './entities/survey-response.entity';
import { SurveysService } from './surveys.service';
import { SurveysController } from './surveys.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Survey, Question, SurveyResponse])],
  controllers: [SurveysController],
  providers: [SurveysService],
})
export class SurveysModule {}
