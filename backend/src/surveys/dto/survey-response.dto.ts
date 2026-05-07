import { IsString, IsArray, IsUUID, IsEnum } from 'class-validator';

export class SubmitSurveyResponseDto {
  @IsUUID()
  surveyId: string;

  @IsArray()
  responses: {
    questionId: string;
    response: string | string[] | number;
  }[];
}
