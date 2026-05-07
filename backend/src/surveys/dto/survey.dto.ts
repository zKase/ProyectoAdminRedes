import {
  IsString,
  IsArray,
  IsOptional,
  IsEnum,
  IsDateString,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';

export class ConditionalLogicDto {
  @IsString()
  dependsOn: string;

  @IsEnum(['equals', 'notEquals', 'contains', 'greaterThan', 'lessThan'])
  condition: 'equals' | 'notEquals' | 'contains' | 'greaterThan' | 'lessThan';

  value: string | number;
}

export class CreateQuestionDto {
  @IsString()
  text: string;

  @IsEnum([
    'TEXT',
    'MULTIPLE_CHOICE',
    'SINGLE_CHOICE',
    'RATING',
    'CHECKBOX',
    'TEXTAREA',
  ])
  type: string;

  @IsOptional()
  @IsArray()
  options?: string[];

  @IsOptional()
  isRequired?: boolean;

  @IsOptional()
  order?: number;

  @IsOptional()
  @ValidateNested()
  @Type(() => ConditionalLogicDto)
  conditionalLogic?: ConditionalLogicDto;
}

export class CreateSurveyDto {
  @IsString()
  title: string;

  @IsString()
  description: string;

  @IsOptional()
  @IsDateString()
  startDate?: Date;

  @IsOptional()
  @IsDateString()
  endDate?: Date;

  @IsOptional()
  @ValidateNested({ each: true })
  @Type(() => CreateQuestionDto)
  questions?: CreateQuestionDto[];
}

export class UpdateSurveyDto {
  @IsOptional()
  @IsString()
  title?: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsEnum(['DRAFT', 'ACTIVE', 'CLOSED', 'ARCHIVED'])
  status?: string;

  @IsOptional()
  @IsDateString()
  startDate?: Date;

  @IsOptional()
  @IsDateString()
  endDate?: Date;
}
