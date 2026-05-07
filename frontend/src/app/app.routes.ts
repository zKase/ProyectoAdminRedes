import { Routes } from '@angular/router';
import { LoginComponent } from './components/login/login.component';
import { DashboardNewComponent } from './components/dashboard-new/dashboard-new.component';
import { IncidentsListComponent } from './components/incidents-list/incidents-list.component';
import { IncidentDetailComponent } from './components/incident-detail/incident-detail.component';
import { authGuard } from './core/auth.guard';

export const routes: Routes = [
  { path: 'login', component: LoginComponent },
  { 
    path: 'dashboard', 
    component: DashboardNewComponent,
    canActivate: [authGuard]
  },
  {
    path: 'incidents',
    component: IncidentsListComponent,
    canActivate: [authGuard]
  },
  {
    path: 'incidents/:id',
    component: IncidentDetailComponent,
    canActivate: [authGuard]
  },
  { path: '', redirectTo: '/dashboard', pathMatch: 'full' },
  { path: '**', redirectTo: '/dashboard' }
];
