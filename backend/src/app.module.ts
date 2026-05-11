import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { APP_GUARD, APP_INTERCEPTOR } from '@nestjs/core';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { DatabaseModule } from './database/database.module';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { ProposalsModule } from './proposals/proposals.module';
import { SurveysModule } from './surveys/surveys.module';
import { BudgetsModule } from './budgets/budgets.module';
import { AuditModule } from './audit/audit.module';
import { IssuesModule } from './issues/issues.module';
import { ReportsModule } from './reports/reports.module';
import { ChatbotModule } from './chatbot/chatbot.module';
import { IncidentsModule } from './incidents/incidents.module';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { RolesGuard } from './guards/roles.guard';
import { AuditInterceptor } from './audit/interceptors/audit.interceptor';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    DatabaseModule,
    AuthModule,
    UsersModule,
    ProposalsModule,
    SurveysModule,
    BudgetsModule,
    AuditModule,
    IssuesModule,
    ReportsModule,
    ChatbotModule,
    IncidentsModule,
  ],
  controllers: [AppController],
  providers: [
    AppService,
    {
      provide: APP_GUARD,
      useClass: JwtAuthGuard,
    },
    {
      provide: APP_GUARD,
      useClass: RolesGuard,
    },
    {
      provide: APP_INTERCEPTOR,
      useClass: AuditInterceptor,
    },
  ],
})
export class AppModule {}
