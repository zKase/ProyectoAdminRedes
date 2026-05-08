import {
  IsString,
  IsNumber,
  IsArray,
  IsOptional,
  IsEnum,
  IsDateString,
  IsBoolean,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';

export class CreateBudgetDto {
  @IsString()
  title: string;

  @IsString()
  description: string;

  @IsNumber()
  totalAmount: number;

  @IsOptional()
  @IsDateString()
  startDate?: Date;

  @IsOptional()
  @IsDateString()
  endDate?: Date;

  @IsOptional()
  @IsBoolean()
  allowMultipleVotes?: boolean;

  @IsOptional()
  @ValidateNested({ each: true })
  @Type(() => CreateBudgetItemDto)
  items?: CreateBudgetItemDto[];
}

export class CreateBudgetItemDto {
  @IsString()
  title: string;

  @IsString()
  description: string;

  @IsNumber()
  estimatedCost: number;
}

export class UpdateBudgetDto {
  @IsOptional()
  @IsString()
  title?: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsEnum(['DRAFT', 'ACTIVE', 'VOTING_CLOSED', 'COMPLETED', 'ARCHIVED'])
  status?: string;

  @IsOptional()
  @IsNumber()
  totalAmount?: number;

  @IsOptional()
  @IsDateString()
  startDate?: Date;

  @IsOptional()
  @IsDateString()
  endDate?: Date;
}

export class VoteBudgetItemDto {
  @IsString()
  itemId: string;
}
