import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  Query,
  Request,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags, ApiOperation } from '@nestjs/swagger';
import { SurveysService } from './surveys.service';
import { CreateSurveyDto, UpdateSurveyDto } from './dto/survey.dto';
import { SubmitSurveyResponseDto } from './dto/survey-response.dto';
import { Roles } from '../guards/roles.decorator';
import { UserRole } from '../users/entities/user.entity';
import { Public } from '../guards/public.decorator';

@ApiTags('surveys')
@Controller('surveys')
@ApiBearerAuth()
export class SurveysController {
  constructor(private surveysService: SurveysService) {}

  @ApiOperation({ summary: 'Create a new survey (Admin/Moderator only)' })
  @Roles(UserRole.ADMIN, UserRole.MODERATOR)
  @Post()
  async create(@Body() createSurveyDto: CreateSurveyDto, @Request() req) {
    return this.surveysService.create(createSurveyDto, req.user.userId);
  }

  @ApiOperation({ summary: 'Get all surveys' })
  @Get()
  async findAll(@Query('status') status?: string) {
    return this.surveysService.findAll(status as any);
  }

  @ApiOperation({ summary: 'Get survey by ID with visible questions' })
  @Get(':id')
  async findById(@Param('id') id: string, @Query('responses') responses?: string) {
    const survey = await this.surveysService.findById(id);

    // Si se proporciona respuestas previas, evaluar lógica condicional
    if (responses) {
      try {
        const userResponses = JSON.parse(responses);
        survey.questions = await this.surveysService.getVisibleQuestions(id, userResponses);
      } catch (e) {
        // Si no es JSON válido, retornar todas las preguntas
      }
    }

    return survey;
  }

  @ApiOperation({ summary: 'Update survey (Admin/Moderator only)' })
  @Roles(UserRole.ADMIN, UserRole.MODERATOR)
  @Patch(':id')
  async update(
    @Param('id') id: string,
    @Body() updateSurveyDto: UpdateSurveyDto,
  ) {
    return this.surveysService.update(id, updateSurveyDto);
  }

  @ApiOperation({ summary: 'Change survey status (Admin only)' })
  @Roles(UserRole.ADMIN)
  @Patch(':id/status/:status')
  async updateStatus(@Param('id') id: string, @Param('status') status: string) {
    return this.surveysService.updateStatus(id, status as any);
  }

  @ApiOperation({ summary: 'Delete survey (Admin only)' })
  @Roles(UserRole.ADMIN)
  @Delete(':id')
  async delete(@Param('id') id: string) {
    await this.surveysService.delete(id);
    return { message: 'Survey deleted successfully' };
  }

  @ApiOperation({ summary: 'Submit survey response' })
  @Post(':id/submit')
  async submitResponse(
    @Param('id') id: string,
    @Body() submitDto: SubmitSurveyResponseDto,
    @Request() req,
  ) {
    // Validar que el ID del parámetro coincida con el del body
    if (id !== submitDto.surveyId) {
      throw new Error('Survey ID mismatch');
    }

    return this.surveysService.submitResponse(submitDto, req.user.userId);
  }

  @ApiOperation({ summary: 'Get survey results (Admin/Moderator only)' })
  @Roles(UserRole.ADMIN, UserRole.MODERATOR)
  @Get(':id/results')
  async getSurveyResults(@Param('id') id: string) {
    return this.surveysService.getSurveyResults(id);
  }
}
