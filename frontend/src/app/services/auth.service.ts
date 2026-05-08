import { Injectable, computed, inject, signal } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { tap } from 'rxjs/operators';
import { environment } from '../../environments/environment';
import { AuthResponse, AuthUser } from '../models/platform.model';

const TOKEN_KEY = 'participacion_token';
const USER_KEY = 'participacion_user';

@Injectable({ providedIn: 'root' })
export class AuthService {
  private http = inject(HttpClient);
  private userState = signal<AuthUser | null>(this.readStoredUser());

  user = this.userState.asReadonly();
  isAuthenticated = computed(() => !!this.userState() && !!this.token);

  get token(): string | null {
    return localStorage.getItem(TOKEN_KEY);
  }

  login(email: string, password: string) {
    return this.http.post<AuthResponse>(`${environment.apiUrl}/auth/login`, { email, password }).pipe(
      tap((response) => this.persistSession(response)),
    );
  }

  register(firstName: string, lastName: string, email: string, password: string) {
    return this.http.post<AuthResponse>(`${environment.apiUrl}/auth/register`, {
      firstName,
      lastName,
      email,
      password,
    }).pipe(tap((response) => this.persistSession(response)));
  }

  logout() {
    localStorage.removeItem(TOKEN_KEY);
    localStorage.removeItem(USER_KEY);
    this.userState.set(null);
  }

  private persistSession(response: AuthResponse) {
    localStorage.setItem(TOKEN_KEY, response.token);
    localStorage.setItem(USER_KEY, JSON.stringify(response.user));
    this.userState.set(response.user);
  }

  private readStoredUser(): AuthUser | null {
    const stored = localStorage.getItem(USER_KEY);
    if (!stored) return null;

    try {
      return JSON.parse(stored) as AuthUser;
    } catch {
      localStorage.removeItem(USER_KEY);
      return null;
    }
  }
}
