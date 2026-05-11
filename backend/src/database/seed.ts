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
      { title: 'Renovación Biblioteca Municipal', description: 'Ampliación de espacios de estudio y nuevo material bibliográfico.', category: 'Cultura', votes: 320 },
      { title: 'Feria de Emprendedores Locales', description: 'Espacio quincenal para que pymes de la comuna ofrezcan sus productos.', category: 'Economía', votes: 112 },
      { title: 'Clínica Veterinaria Móvil', description: 'Atención veterinaria gratuita que recorre distintos barrios.', category: 'Salud', votes: 450 },
      { title: 'Zonas de Reciclaje Avanzado', description: 'Puntos limpios con separación de orgánicos y electrónicos.', category: 'Sustentabilidad', votes: 275 },
      { title: 'Mejora de Paraderos', description: 'Paraderos con techo inteligente y pantallas de información de buses.', category: 'Transporte', votes: 198 },
      { title: 'Cámaras de Seguridad Inteligentes', description: 'Integración de IA para detectar situaciones anómalas en parques.', category: 'Seguridad', votes: 380 },
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
      },
      {
        title: 'Consulta sobre Plan Regulador',
        description: 'Buscamos tu opinión sobre las alturas máximas de edificios comerciales.',
        status: SurveyStatus.ACTIVE,
        createdBy: admin.id,
        responseCount: 345,
        questions: [
          { text: '¿Está de acuerdo con limitar la altura a 12 pisos?', type: QuestionType.SINGLE_CHOICE, options: ['Sí', 'No', 'Me es indiferente'], order: 1 },
          { text: 'Comentarios adicionales', type: QuestionType.TEXTAREA, options: [], order: 2 }
        ]
      },
      {
        title: 'Uso de Áreas Verdes',
        description: 'Queremos mejorar los parques. ¿Cómo los usas?',
        status: SurveyStatus.ACTIVE,
        createdBy: admin.id,
        responseCount: 512,
        questions: [
          { text: '¿Con qué frecuencia visita los parques comunales?', type: QuestionType.SINGLE_CHOICE, options: ['Diario', 'Semanal', 'Mensual', 'Casi nunca'], order: 1 },
          { text: '¿Qué instalaciones faltan?', type: QuestionType.MULTIPLE_CHOICE, options: ['Juegos infantiles', 'Máquinas de ejercicio', 'Zonas de picnic', 'Baños públicos'], order: 2 }
        ]
      },
      {
        title: 'Satisfacción Atención Ciudadana',
        description: 'Evalúa tu última interacción con los servicios municipales.',
        status: SurveyStatus.ACTIVE,
        createdBy: admin.id,
        responseCount: 78,
        questions: [
          { text: '¿Resolvieron su problema?', type: QuestionType.SINGLE_CHOICE, options: ['Sí', 'No', 'Parcialmente'], order: 1 }
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
      },
      {
        title: 'Fondo de Cultura y Artes 2026',
        description: 'Decide cómo distribuir los fondos para actividades culturales de la comuna.',
        status: BudgetStatus.ACTIVE,
        totalAmount: 150000000,
        allocatedAmount: 0,
        createdBy: admin.id,
        participantsCount: 890,
        items: [
          { title: 'Festival de Teatro al Aire Libre', description: 'Obras gratuitas durante el verano.', estimatedCost: 60000000, voteCount: 450 },
          { title: 'Talleres de Música Juvenil', description: 'Instrumentos y profesores para colegios municipales.', estimatedCost: 40000000, voteCount: 210 },
          { title: 'Exposición de Arte Local', description: 'Galería itinerante de artistas comunales.', estimatedCost: 50000000, voteCount: 230 }
        ]
      },
      {
        title: 'Mejoras en Infraestructura Escolar',
        description: 'Presupuesto destinado a arreglos estructurales en colegios.',
        status: BudgetStatus.VOTING_CLOSED,
        totalAmount: 300000000,
        allocatedAmount: 300000000,
        createdBy: admin.id,
        participantsCount: 1200,
        items: [
          { title: 'Renovación de Techumbres', description: 'Cambio de techos en Liceo A.', estimatedCost: 150000000, voteCount: 800 },
          { title: 'Nuevos Laboratorios de Computación', description: 'Equipos modernos para 3 colegios.', estimatedCost: 150000000, voteCount: 400 }
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
      { title: 'Grafiti en muro público', description: 'Limpieza requerida en frontis municipal.', status: IssueStatus.RESOLVED, category: 'Limpieza', latitude: -33.418, longitude: -70.568 },
      { title: 'Semáforo desincronizado', description: 'Genera mucho taco en la intersección principal.', status: IssueStatus.OPEN, category: 'Tránsito', latitude: -33.410, longitude: -70.582 },
      { title: 'Árbol a punto de caer', description: 'Ramas secas muy pesadas sobre paso peatonal.', status: IssueStatus.IN_REVIEW, category: 'Áreas Verdes', latitude: -33.409, longitude: -70.578 },
      { title: 'Basura acumulada', description: 'No ha pasado el camión recolector en tres días.', status: IssueStatus.OPEN, category: 'Limpieza', latitude: -33.414, longitude: -70.585 },
      { title: 'Fuga de agua en matriz', description: 'Agua escurriendo por la cuneta desde la mañana.', status: IssueStatus.OPEN, category: 'Infraestructura', latitude: -33.417, longitude: -70.580 },
      { title: 'Vehículo abandonado', description: 'Auto sin patente estacionado hace meses.', status: IssueStatus.RESOLVED, category: 'Seguridad', latitude: -33.420, longitude: -70.575 },
      { title: 'Paradero vandalizado', description: 'Vidrios rotos y asiento desprendido.', status: IssueStatus.IN_REVIEW, category: 'Mobiliario', latitude: -33.411, longitude: -70.572 },
      { title: 'Plaza sin riego', description: 'El pasto se secó completamente en la zona este.', status: IssueStatus.OPEN, category: 'Áreas Verdes', latitude: -33.413, longitude: -70.560 },
      { title: 'Señalética oculta', description: 'El disco Pare está tapado por las ramas de un árbol.', status: IssueStatus.OPEN, category: 'Tránsito', latitude: -33.408, longitude: -70.569 },
      { title: 'Cruce peatonal borrado', description: 'Se necesita repintar las líneas de paso de cebra.', status: IssueStatus.RESOLVED, category: 'Vialidad', latitude: -33.416, longitude: -70.577 },
      { title: 'Ruidos molestos recurrentes', description: 'Construcción trabajando fuera de horario permitido.', status: IssueStatus.OPEN, category: 'Seguridad', latitude: -33.407, longitude: -70.576 }
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
