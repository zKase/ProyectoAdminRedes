import { Controller, Get, Query } from '@nestjs/common';
import { ApiBearerAuth, ApiTags, ApiOperation } from '@nestjs/swagger';
import { AuditService } from './audit.service';
import { Roles } from '../guards/roles.decorator';
import { UserRole } from '../users/entities/user.entity';

@ApiTags('audit')
@Controller('audit')
@ApiBearerAuth()
@Roles(UserRole.ADMIN)
export class AuditController {
  constructor(private auditService: AuditService) {}

  @ApiOperation({ summary: 'Get all audit logs (Admin only)' })
  @Get('logs')
  async getLogs(
    @Query('page') page: number = 1,
    @Query('limit') limit: number = 50,
  ) {
    return this.auditService.findAll(page, limit);
  }

  @ApiOperation({ summary: 'Get logs by user (Admin only)' })
  @Get('logs/user/:userId')
  async getLogsByUser(
    @Query('userId') userId: string,
    @Query('limit') limit: number = 50,
  ) {
    return this.auditService.findByUser(userId, limit);
  }

  @ApiOperation({ summary: 'Get logs by entity type (Admin only)' })
  @Get('logs/entity/:entityType')
  async getLogsByEntity(
    @Query('entityType') entityType: string,
    @Query('limit') limit: number = 50,
  ) {
    return this.auditService.findByEntity(entityType, limit);
  }

  @ApiOperation({ summary: 'Get logs by action (Admin only)' })
  @Get('logs/action/:action')
  async getLogsByAction(
    @Query('action') action: string,
    @Query('limit') limit: number = 50,
  ) {
    return this.auditService.findByAction(action, limit);
  }

  @ApiOperation({ summary: 'Get action statistics (Admin only)' })
  @Get('statistics')
  async getStatistics(@Query('days') days: number = 7) {
    return this.auditService.getActionStats(days);
  }
}
