import { IsEnum, IsNotEmpty, IsOptional, IsString, MinLength } from 'class-validator';
import { ProposalCommentStatus } from '../entities/proposal-comment.entity';

export class CreateProposalCommentDto {
  @IsString()
  @IsNotEmpty()
  @MinLength(3)
  content: string;
}

export class UpdateProposalCommentDto {
  @IsString()
  @IsOptional()
  @MinLength(3)
  content?: string;

  @IsEnum(ProposalCommentStatus)
  @IsOptional()
  status?: ProposalCommentStatus;
}
