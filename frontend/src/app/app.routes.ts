import { Routes } from '@angular/router';
import { LoginComponent } from './components/login/login.component';
import { DashboardComponent } from './components/dashboard/dashboard.component';
import { DashboardNewComponent } from './components/dashboard-new/dashboard-new.component';
import { IncidentsListComponent } from './components/incidents-list/incidents-list.component';
import { IncidentDetailComponent } from './components/incident-detail/incident-detail.component';
import { authGuard } from './core/auth.guard';
import { MainLayoutComponent } from './components/layout/main-layout.component';

export const routes: Routes = [
  { path: 'login', component: LoginComponent },
  { 
    path: '', 
    component: MainLayoutComponent,
    canActivate: [authGuard],
    children: [
      { 
        path: 'dashboard', 
        redirectTo: 'dashboard/proposals',
        pathMatch: 'full'
      },
      { 
        path: 'dashboard/:section', 
        component: DashboardComponent 
      },
      { 
        path: 'admin-dashboard', 
        component: DashboardNewComponent 
      },
      {
        path: 'incidents',
        component: IncidentsListComponent
      },
      {
        path: 'incidents/:id',
        component: IncidentDetailComponent
      },
      { path: '', redirectTo: 'dashboard/proposals', pathMatch: 'full' }
    ]
  },
  { path: '**', redirectTo: '/dashboard/proposals' }
];
