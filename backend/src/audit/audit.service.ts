import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { AuditLog } from './entities/audit-log.entity';

export interface AuditLogData {
  userId: string;
  action: string;
  entityType: string;
  entityId?: string;
  changes?: Record<string, any>;
  ipAddress?: string;
  userAgent?: string;
  statusCode?: number;
  errorMessage?: string;
}

@Injectable()
export class AuditService {
  constructor(
    @InjectRepository(AuditLog)
    private auditLogRepository: Repository<AuditLog>,
  ) {}

  /**
   * Registrar una acción en el log de auditoría
   */
  async log(data: AuditLogData): Promise<AuditLog> {
    const auditLog = this.auditLogRepository.create(data);
    return this.auditLogRepository.save(auditLog);
  }

  /**
   * Obtener todos los logs de auditoría con paginación
   */
  async findAll(
    page: number = 1,
    limit: number = 50,
  ): Promise<{ logs: AuditLog[]; total: number }> {
    const skip = (page - 1) * limit;

    const [logs, total] = await this.auditLogRepository.findAndCount({
      order: { createdAt: 'DESC' },
      skip,
      take: limit,
    });

    return { logs, total };
  }

  /**
   * Obtener logs por usuario
   */
  async findByUser(userId: string, limit: number = 50): Promise<AuditLog[]> {
    return this.auditLogRepository.find({
      where: { userId },
      order: { createdAt: 'DESC' },
      take: limit,
    });
  }

  /**
   * Obtener logs por tipo de entidad
   */
  async findByEntity(
    entityType: string,
    limit: number = 50,
  ): Promise<AuditLog[]> {
    return this.auditLogRepository.find({
      where: { entityType },
      order: { createdAt: 'DESC' },
      take: limit,
    });
  }

  /**
   * Obtener logs por acción
   */
  async findByAction(
    action: string,
    limit: number = 50,
  ): Promise<AuditLog[]> {
    return this.auditLogRepository.find({
      where: { action },
      order: { createdAt: 'DESC' },
      take: limit,
    });
  }

  /**
   * Obtener logs entre fechas
   */
  async findByDateRange(
    startDate: Date,
    endDate: Date,
    limit: number = 50,
  ): Promise<AuditLog[]> {
    return this.auditLogRepository
      .createQueryBuilder('log')
      .where('log.createdAt >= :startDate', { startDate })
      .andWhere('log.createdAt <= :endDate', { endDate })
      .orderBy('log.createdAt', 'DESC')
      .limit(limit)
      .getMany();
  }

  /**
   * Obtener estadísticas de acciones
   */
  async getActionStats(days: number = 7): Promise<any> {
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    return this.auditLogRepository
      .createQueryBuilder('log')
      .select('log.action', 'action')
      .addSelect('COUNT(*)', 'count')
      .where('log.createdAt >= :startDate', { startDate })
      .groupBy('log.action')
      .getRawMany();
  }
}
