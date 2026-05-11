import { HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { AuthService } from './auth.service';
import { catchError, throwError } from 'rxjs';

export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const token = inject(AuthService).token;

  if (!token) {
    return next(req);
  }

  return next(req.clone({
    setHeaders: {
      Authorization: `Bearer ${token}`,
    },
  })).pipe(
    catchError((error) => {
      if (error.status === 401) {
        // Auto logout on 401 responses
        inject(AuthService).logout();
      }
      return throwError(() => error);
    })
  );
};
