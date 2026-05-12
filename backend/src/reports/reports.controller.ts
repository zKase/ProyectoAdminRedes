import { Controller, Get, Param, Res } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import * as express from 'express';
import { Roles } from '../guards/roles.decorator';
import { UserRole } from '../users/entities/user.entity';
import { ReportsService } from './reports.service';

@ApiTags('reports')
@Controller('reports')
@ApiBearerAuth()
export class ReportsController {
  constructor(private reportsService: ReportsService) {}

  @ApiOperation({ summary: 'Resumen agregado de participación (Admin/Moderador)' })
  @Roles(UserRole.ADMIN, UserRole.MODERATOR)
  @Get('summary')
  async getSummary() {
    return this.reportsService.getSummary();
  }

  @ApiOperation({ summary: 'Exportar datos a CSV (Admin/Moderador)' })
  @Roles(UserRole.ADMIN, UserRole.MODERATOR)
  @Get('export/csv/:type')
  async exportCsv(@Param('type') type: string, @Res() res: express.Response) {
    const csv = await this.reportsService.exportToCsv(type);
    res.header('Content-Type', 'text/csv');
    res.attachment(`reporte-${type}-${new Date().getTime()}.csv`);
    return res.send(csv);
  }
}
