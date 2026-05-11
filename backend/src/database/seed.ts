import { DataSource } from 'typeorm';
import { User, UserRole } from '../users/entities/user.entity';
import { Proposal } from '../proposals/entities/proposal.entity';
import { ProposalVote } from '../proposals/entities/proposal-vote.entity';
import { ProposalComment } from '../proposals/entities/proposal-comment.entity';
import { Survey, SurveyStatus } from '../surveys/entities/survey.entity';
import { Question, QuestionType } from '../surveys/entities/question.entity';
import { SurveyResponse } from '../surveys/entities/survey-response.entity';
import { Budget, BudgetStatus } from '../budgets/entities/budget.entity';
import { BudgetItem } from '../budgets/entities/budget-item.entity';
import { BudgetVote } from '../budgets/entities/budget-vote.entity';
import { Issue, IssueStatus } from '../issues/entities/issue.entity';
import { Incident } from '../incidents/entities/incident.entity';
import { AuditLog } from '../audit/entities/audit-log.entity';
import * as bcrypt from 'bcrypt';
import * as dotenv from 'dotenv';

dotenv.config();

const AppDataSource = new DataSource({
  type: 'postgres',
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432'),
  username: process.env.DB_USERNAME || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
  database: process.env.DB_NAME || 'proyecto_db',
  entities: [
    User, 
    Proposal, ProposalVote, ProposalComment,
    Survey, Question, SurveyResponse,
    Budget, BudgetItem, BudgetVote,
    Issue, Incident, AuditLog
  ],
  synchronize: true,
});

async function seed() {
  try {
    await AppDataSource.initialize();
    console.log('Data Source has been initialized!');

    const userRepository = AppDataSource.getRepository(User);
    const proposalRepository = AppDataSource.getRepository(Proposal);
    const surveyRepository = AppDataSource.getRepository(Survey);
    const budgetRepository = AppDataSource.getRepository(Budget);
    const issueRepository = AppDataSource.getRepository(Issue);

    // 1. Create Users
    console.log('Seeding users...');
    const hashedPassword = await bcrypt.hash('admin123', 10);
    
    let admin = await userRepository.findOneBy({ email: 'admin@lascondes.cl' });
    if (!admin) {
      admin = userRepository.create({
        firstName: 'Administrador',
        lastName: 'Sistema',
        email: 'admin@lascondes.cl',
        password: hashedPassword,
        role: UserRole.ADMIN,
      });
      admin = await userRepository.save(admin);
    }

    // 2. Create Proposals
    console.log('Seeding proposals...');
    const proposalsData = [
      { title: 'Nueva Ciclovía en Apoquindo', description: 'Implementación de ciclovía de alto estándar para conectar con el centro.', category: 'Transporte', votes: 150 },
      { title: 'Parque Canino en Los Dominicos', description: 'Espacio cercado y equipado para el esparcimiento de mascotas.', category: 'Áreas Verdes', votes: 85 },
      { title: 'Iluminación LED Peatonal', description: 'Refuerzo de luminarias en calles residenciales para mayor seguridad.', category: 'Seguridad', votes: 210 },
      { title: 'Huertos Comunitarios', description: 'Talleres y espacios para agricultura urbana en plazas municipales.', category: 'Sustentabilidad', votes: 45 },
    ];

    for (const p of proposalsData) {
      const exists = await proposalRepository.findOneBy({ title: p.title });
      if (!exists) {
        await proposalRepository.save(proposalRepository.create(p));
      }
    }

    // 3. Create Surveys
    console.log('Seeding surveys...');
    const surveyData = [
      {
        title: 'Prioridades de Seguridad 2026',
        description: 'Ayúdanos a definir dónde invertir más recursos de seguridad este año.',
        status: SurveyStatus.ACTIVE,
        createdBy: admin.id,
        responseCount: 124,
        questions: [
          { text: '¿Cuál es su mayor preocupación?', type: QuestionType.MULTIPLE_CHOICE, options: ['Robos', 'Iluminación', 'Vandalismo'], order: 1 }
        ]
      },
      {
        title: 'Evaluación de Talleres Deportivos',
        description: '¿Qué te parecieron las actividades del verano?',
        status: SurveyStatus.CLOSED,
        createdBy: admin.id,
        responseCount: 89,
        questions: [
          { text: 'Califique su satisfacción', type: QuestionType.RATING, options: [], order: 1 }
        ]
      }
    ];

    for (const s of surveyData) {
      const exists = await surveyRepository.findOneBy({ title: s.title });
      if (!exists) {
        const survey = surveyRepository.create(s);
        await surveyRepository.save(survey);
      }
    }

    // 4. Create Budgets
    console.log('Seeding budgets...');
    const budgetData = [
      {
        title: 'Presupuesto Participativo Vecinal 2026',
        description: 'Fondo concursable para proyectos de mejora barrial.',
        status: BudgetStatus.ACTIVE,
        totalAmount: 500000000,
        allocatedAmount: 120000000,
        createdBy: admin.id,
        participantsCount: 450,
        items: [
          { title: 'Remodelación Plaza Perú', description: 'Nuevos juegos y pavimentos.', estimatedCost: 45000000, voteCount: 120 },
          { title: 'Cámaras de vigilancia', description: 'Sistema de monitoreo 4K.', estimatedCost: 75000000, voteCount: 330 }
        ]
      }
    ];

    for (const b of budgetData) {
      const exists = await budgetRepository.findOneBy({ title: b.title });
      if (!exists) {
        const budget = budgetRepository.create(b);
        await budgetRepository.save(budget);
      }
    }

    // 5. Create Issues (Map)
    console.log('Seeding issues...');
    const issuesData = [
      { title: 'Bache en calzada', description: 'Hoyo de gran tamaño pone en riesgo a conductores.', status: IssueStatus.OPEN, category: 'Vialidad', latitude: -33.412, longitude: -70.565 },
      { title: 'Luminaria apagada', description: 'Calle oscura hace dos noches.', status: IssueStatus.IN_REVIEW, category: 'Seguridad', latitude: -33.415, longitude: -70.570 },
      { title: 'Grafiti en muro público', description: 'Limpieza requerida en frontis municipal.', status: IssueStatus.RESOLVED, category: 'Limpieza', latitude: -33.418, longitude: -70.568 }
    ];

    for (const i of issuesData) {
      const exists = await issueRepository.findOneBy({ title: i.title });
      if (!exists) {
        await issueRepository.save(issueRepository.create(i));
      }
    }

    console.log('Seeding completed successfully!');
    await AppDataSource.destroy();
  } catch (error) {
    console.error('Error during seeding:', error);
    process.exit(1);
  }
}

seed();
