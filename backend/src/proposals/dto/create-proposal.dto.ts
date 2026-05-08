import { IsString, IsNotEmpty, MinLength } from 'class-validator';

export class CreateProposalDto {
  @IsString()
  @IsNotEmpty()
  @MinLength(10, { message: 'El título debe tener al menos 10 caracteres' })
  title: string;

  @IsString()
  @IsNotEmpty()
  @MinLength(30, { message: 'La descripción debe tener al menos 30 caracteres' })
  description: string;

  @IsString()
  @IsNotEmpty()
  category: string;
}
