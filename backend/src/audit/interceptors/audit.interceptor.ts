import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { tap, catchError } from 'rxjs/operators';
import { AuditService } from '../audit.service';

/**
 * Interceptor que registra todas las acciones administrativas
 * Se aplica a endpoints específicos que modifiquen datos
 */
@Injectable()
export class AuditInterceptor implements NestInterceptor {
  constructor(private auditService: AuditService) {}

  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const request = context.switchToHttp().getRequest();
    const { method, path, user, ip, headers } = request;

    const startTime = Date.now();

    return next.handle().pipe(
      tap((response) => {
        // Registrar la acción exitosa
        const duration = Date.now() - startTime;

        // Determinar action y entityType del path y method
        const action = this.getActionFromMethod(method);
        const entityType = this.getEntityTypeFromPath(path);
        const entityId = this.getEntityIdFromPath(path);

        this.auditService.log({
          userId: user?.userId ?? null,
          action,
          entityType,
          entityId,
          ipAddress: ip,
          userAgent: headers['user-agent'],
          statusCode: 200,
          changes: {
            method,
            path,
            duration,
            responseSize: JSON.stringify(response).length,
          },
        });
      }),
      catchError((error) => {
        // Registrar errores
        const action = this.getActionFromMethod(method);
        const entityType = this.getEntityTypeFromPath(path);
        const entityId = this.getEntityIdFromPath(path);

        this.auditService.log({
          userId: user?.userId ?? null,
          action,
          entityType,
          entityId,
          ipAddress: ip,
          userAgent: headers['user-agent'],
          statusCode: error.status || 500,
          errorMessage: error.message,
          changes: {
            method,
            path,
          },
        });

        throw error;
      }),
    );
  }

  private getActionFromMethod(method: string): string {
    const actions = {
      POST: 'CREATE',
      GET: 'READ',
      PATCH: 'UPDATE',
      PUT: 'UPDATE',
      DELETE: 'DELETE',
    };
    return actions[method] || method;
  }

  private getEntityTypeFromPath(path: string): string {
    const parts = path.split('/').filter((p) => p);
    const entityIndex = parts[0] === 'api' ? 1 : 0;
    return parts[entityIndex] ? parts[entityIndex].toUpperCase() : 'UNKNOWN';
  }

  private getEntityIdFromPath(path: string): string | undefined {
    const parts = path.split('/').filter((p) => p);
    // Buscar UUID o ID numérico
    const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
    for (const part of parts) {
      if (uuidRegex.test(part) || !isNaN(parseInt(part))) {
        return part;
      }
    }
    return undefined;
  }
}
