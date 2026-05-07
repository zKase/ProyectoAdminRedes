import {
  Injectable,
  NotFoundException,
  ConflictException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Survey, SurveyStatus } from './entities/survey.entity';
import { Question } from './entities/question.entity';
import { SurveyResponse } from './entities/survey-response.entity';
import { CreateSurveyDto, UpdateSurveyDto, CreateQuestionDto } from './dto/survey.dto';
import { SubmitSurveyResponseDto } from './dto/survey-response.dto';

@Injectable()
export class SurveysService {
  constructor(
    @InjectRepository(Survey)
    private surveysRepository: Repository<Survey>,
    @InjectRepository(Question)
    private questionsRepository: Repository<Question>,
    @InjectRepository(SurveyResponse)
    private responsesRepository: Repository<SurveyResponse>,
  ) {}

  /**
   * Crear una nueva encuesta
   */
  async create(createSurveyDto: CreateSurveyDto, userId: string): Promise<Survey> {
    const { questions, ...surveyData } = createSurveyDto;

    const survey = this.surveysRepository.create({
      ...surveyData,
      createdBy: userId,
    });

    const savedSurvey = await this.surveysRepository.save(survey);

    // Crear preguntas si existen
    if (questions && questions.length > 0) {
      for (const questionDto of questions) {
        await this.addQuestion(savedSurvey.id, questionDto);
      }
    }

    return this.findById(savedSurvey.id);
  }

  /**
   * Obtener todas las encuestas
   */
  async findAll(status?: SurveyStatus): Promise<Survey[]> {
    const query = this.surveysRepository.createQueryBuilder('survey');

    if (status) {
      query.where('survey.status = :status', { status });
    }

    return query.orderBy('survey.createdAt', 'DESC').getMany();
  }

  /**
   * Obtener encuesta por ID
   */
  async findById(id: string): Promise<Survey> {
    const survey = await this.surveysRepository
      .createQueryBuilder('survey')
      .leftJoinAndSelect('survey.questions', 'question')
      .leftJoinAndSelect('survey.creator', 'creator')
      .where('survey.id = :id', { id })
      .orderBy('question.order', 'ASC')
      .getOne();

    if (!survey) {
      throw new NotFoundException('Survey not found');
    }

    return survey;
  }

  /**
   * Actualizar encuesta
   */
  async update(id: string, updateSurveyDto: UpdateSurveyDto): Promise<Survey> {
    const survey = await this.findById(id);

    Object.assign(survey, updateSurveyDto);

    await this.surveysRepository.save(survey);

    return this.findById(id);
  }

  /**
   * Cambiar estado de la encuesta
   */
  async updateStatus(id: string, status: SurveyStatus): Promise<Survey> {
    const survey = await this.findById(id);

    survey.status = status;

    await this.surveysRepository.save(survey);

    return this.findById(id);
  }

  /**
   * Agregar pregunta a encuesta
   */
  async addQuestion(
    surveyId: string,
    createQuestionDto: CreateQuestionDto,
  ): Promise<Question> {
    await this.findById(surveyId);

    const { type, conditionalLogic, ...questionData } = createQuestionDto;

    const question = this.questionsRepository.create({
      ...questionData,
      surveyId,
      type: type as any,
      conditionalLogic: conditionalLogic ? {
        ...conditionalLogic,
        condition: conditionalLogic.condition as any,
      } : null,
      isConditional: !!conditionalLogic,
    } as any);

    const savedQuestion = await this.questionsRepository.save(question);
    return Array.isArray(savedQuestion) ? savedQuestion[0] : savedQuestion;
  }

  /**
   * Obtener preguntas de una encuesta
   */
  async getQuestions(surveyId: string): Promise<Question[]> {
    return this.questionsRepository.find({
      where: { surveyId },
      order: { order: 'ASC' },
    });
  }

  /**
   * Actualizar pregunta
   */
  async updateQuestion(
    questionId: string,
    updateData: Partial<CreateQuestionDto>,
  ): Promise<Question> {
    const question = await this.questionsRepository.findOneBy({ id: questionId });

    if (!question) {
      throw new NotFoundException('Question not found');
    }

    Object.assign(question, updateData);

    return this.questionsRepository.save(question);
  }

  /**
   * Eliminar pregunta
   */
  async deleteQuestion(questionId: string): Promise<void> {
    const question = await this.questionsRepository.findOneBy({ id: questionId });

    if (!question) {
      throw new NotFoundException('Question not found');
    }

    await this.questionsRepository.remove(question);
  }

  /**
   * Enviar respuestas a encuesta
   * RNF03: Manejo de concurrencia sin bloqueos
   */
  async submitResponse(
    submitDto: SubmitSurveyResponseDto,
    userId: string,
  ): Promise<{ message: string; responseCount: number }> {
    const survey = await this.findById(submitDto.surveyId);

    if (survey.status !== SurveyStatus.ACTIVE) {
      throw new BadRequestException('Survey is not active');
    }

    // Verificar que el usuario no haya respondido antes a esta encuesta.
    const existingResponse = await this.responsesRepository.findOne({
      where: {
        surveyId: submitDto.surveyId,
        userId,
      },
    });

    if (existingResponse) {
      throw new ConflictException('User has already responded to this survey');
    }

    // Guardar todas las respuestas
    for (const response of submitDto.responses) {
      const surveyResponse = this.responsesRepository.create({
        surveyId: submitDto.surveyId,
        questionId: response.questionId,
        userId,
        response: response.response,
      });

      await this.responsesRepository.save(surveyResponse);
    }

    // Incrementar contador de respuestas
    survey.responseCount += 1;
    await this.surveysRepository.save(survey);

    return {
      message: 'Survey response submitted successfully',
      responseCount: survey.responseCount,
    };
  }

  /**
   * Obtener respuestas de una encuesta (para análisis)
   */
  async getSurveyResults(surveyId: string): Promise<any> {
    const survey = await this.findById(surveyId);
    const questions = survey.questions;

    const results = {
      surveyId,
      title: survey.title,
      totalResponses: survey.responseCount,
      questions: await Promise.all(
        questions.map(async (question) => ({
          id: question.id,
          text: question.text,
          type: question.type,
          responses: await this.responsesRepository.find({
            where: { questionId: question.id },
          }),
        })),
      ),
    };

    return results;
  }

  /**
   * Evaluar lógica condicional
   * Determina si una pregunta debe mostrarse basada en condiciones
   */
  evaluateConditionalLogic(
    question: Question,
    userResponses: Record<string, string | string[] | number>,
  ): boolean {
    if (!question.isConditional || !question.conditionalLogic) {
      return true;
    }

    const { dependsOn, condition, value } = question.conditionalLogic;
    const dependencyResponse = userResponses[dependsOn];

    if (!dependencyResponse) {
      return false;
    }

    switch (condition) {
      case 'equals':
        return dependencyResponse === value;
      case 'notEquals':
        return dependencyResponse !== value;
      case 'contains':
        if (Array.isArray(dependencyResponse)) {
          return dependencyResponse.includes(value as string);
        }
        return String(dependencyResponse).includes(String(value));
      case 'greaterThan':
        return Number(dependencyResponse) > Number(value);
      case 'lessThan':
        return Number(dependencyResponse) < Number(value);
      default:
        return true;
    }
  }

  /**
   * Obtener preguntas visibles para el usuario (considerando lógica condicional)
   */
  async getVisibleQuestions(
    surveyId: string,
    userResponses: Record<string, string | string[] | number> = {},
  ): Promise<Question[]> {
    const questions = await this.getQuestions(surveyId);

    return questions.filter((question) =>
      this.evaluateConditionalLogic(question, userResponses),
    );
  }

  /**
   * Eliminar encuesta
   */
  async delete(id: string): Promise<void> {
    const survey = await this.findById(id);

    await this.surveysRepository.remove(survey);
  }
}
