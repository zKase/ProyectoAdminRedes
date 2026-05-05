import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable, throwError } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { environment } from '../../../environments/environment';

/**
 * SERVICIO BASE GENÉRICO
 * Utilizando polimorfismo, evita duplicar las peticiones HTTP CRUD en cada servicio.
 */
export abstract class GenericHttpService<T, ID> {
  protected readonly baseUrl: string;

  constructor(
    protected http: HttpClient,
    protected endpoint: string
  ) {
    this.baseUrl = `${environment.apiUrl}/${endpoint}`;
  }

  getAll(params?: HttpParams): Observable<T[]> {
    return this.http.get<T[]>(this.baseUrl, { params })
      .pipe(catchError(this.handleError));
  }

  getById(id: ID): Observable<T> {
    return this.http.get<T>(`${this.baseUrl}/${id}`)
      .pipe(catchError(this.handleError));
  }

  create(item: T): Observable<T> {
    return this.http.post<T>(this.baseUrl, item)
      .pipe(catchError(this.handleError));
  }

  update(id: ID, item: Partial<T>): Observable<T> {
    return this.http.put<T>(`${this.baseUrl}/${id}`, item)
      .pipe(catchError(this.handleError));
  }

  delete(id: ID): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/${id}`)
      .pipe(catchError(this.handleError));
  }

  protected handleError(error: any) {
    console.error(`[GenericHttpService Error] at ${this.endpoint}:`, error);
    return throwError(() => new Error('Ha ocurrido un error en la comunicación con el servidor.'));
  }
}
