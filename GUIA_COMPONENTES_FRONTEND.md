# Guía de Uso de Componentes - ProyectoAdminRedes

## Cómo Usar los Componentes Implementados

### 1. Importar en app.routes.ts

```typescript
import { LoginComponent } from './components/login/login.component';
import { DashboardNewComponent } from './components/dashboard-new/dashboard-new.component';
import { IncidentsListComponent } from './components/incidents-list/incidents-list.component';
import { IncidentDetailComponent } from './components/incident-detail/incident-detail.component';

export const routes: Routes = [
  { path: '', component: LoginComponent },
  { path: 'login', component: LoginComponent },
  { path: 'dashboard', component: DashboardNewComponent },
  { path: 'incidents', component: IncidentsListComponent },
  { path: 'incidents/:id', component: IncidentDetailComponent },
  // ... otras rutas
];
```

### 2. Actualizar app.html

Reemplaza el contenido actual con:

```html
<router-outlet></router-outlet>
```

### 3. Login Component

**Ubicación**: `src/app/components/login/login.component.ts`

**Propiedades públicas**:
- `email: string` - Email ingresado
- `password: string` - Contraseña
- `rememberMe: boolean` - Opción "recuérdame"
- `isLoading: Signal<boolean>` - Estado de carga
- `errorMessage: Signal<string | null>` - Mensaje de error

**Métodos**:
- `onLogin()` - Maneja el submit del formulario

**Ejemplo de uso personalizado**:

```typescript
@Component({
  selector: 'app-custom-login',
  standalone: true,
  imports: [LoginComponent],
  template: `<app-login></app-login>`
})
export class CustomLoginComponent { }
```

### 4. Dashboard Component

**Ubicación**: `src/app/components/dashboard-new/dashboard-new.component.ts`

**Propiedades públicas**:
- `openIncidents: number` - Número de incidentes abiertos
- `incidents: Signal<Incident[]>` - Lista de incidentes recientes

**Personalización**:

```typescript
// Cambiar número de incidentes abiertos
this.openIncidents = 25;

// Actualizar lista de incidentes
this.incidents.set([
  {
    id: '#INC-8492',
    title: 'Main router offline',
    priority: 'High',
    status: 'Open',
    date: 'Oct 24, 10:30 AM',
    description: 'Main router offline in Zone B'
  },
  // ... más incidentes
]);
```

### 5. Incidents List Component

**Ubicación**: `src/app/components/incidents-list/incidents-list.component.ts`

**Propiedades públicas**:
- `searchTerm: string` - Término de búsqueda
- `selectedStatus: string` - Estado seleccionado
- `selectedSeverity: string` - Severidad seleccionada
- `incidents: Signal<ListIncident[]>` - Lista de incidentes

**Personalización**:

```typescript
// Actualizar lista de incidentes
this.incidents.set([
  {
    id: 'INC-001',
    title: 'Core Router Failure',
    status: 'Open',
    severity: 'Critical',
    dateReported: 'Oct 24, 10:30 AM'
  },
  // ... más incidentes
]);
```

**Métodos auxiliares**:
- `getStatusBadgeClass(status: string)` - Retorna clases CSS según estado
- `getStatusDotClass(status: string)` - Retorna clases para punto de estado
- `getSeverityClass(severity: string)` - Retorna clases para severidad

### 6. Incident Detail Component

**Ubicación**: `src/app/components/incident-detail/incident-detail.component.ts`

**Propiedades públicas**:
- `incidentId: string` - ID del incidente
- `incidentTitle: string` - Título del incidente
- `incidentDescription: string` - Descripción
- `createdAt: string` - Fecha de creación
- `category: string` - Categoría
- `reporterName: string` - Nombre del reportero
- `reporterRole: string` - Rol del reportero
- `location: string` - Ubicación
- `newNote: string` - Nueva nota siendo editada
- `timeline: Signal<TimelineItem[]>` - Historial de actividad

**Métodos**:
- `addNote()` - Agrega una nota al timeline

**Personalización**:

```typescript
// Establecer detalles del incidente
this.incidentId = 'INC-2023-0850';
this.incidentTitle = 'Database Connection Timeout';
this.incidentDescription = 'Database connection is timing out...';
this.category = 'Infrastructure / Database';
this.createdAt = 'Nov 01, 2023 10:15';

// Actualizar timeline
this.timeline.set([
  {
    action: 'Incident Reported',
    author: 'Jane Smith',
    timestamp: '30 minutes ago'
  },
  // ... más eventos
]);
```

## Integración con Servicios

### Ejemplo: Conectar Login con AuthService

```typescript
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-login',
  // ...
})
export class LoginComponent {
  constructor(private authService: AuthService) {}

  onLogin() {
    if (!this.email || !this.password) {
      this.errorMessage.set('Please fill in all fields');
      return;
    }

    this.isLoading.set(true);
    this.errorMessage.set(null);

    this.authService.login(this.email, this.password).subscribe({
      next: () => {
        this.isLoading.set(false);
        // Navegar a dashboard
        window.location.href = '/dashboard';
      },
      error: (err) => {
        this.isLoading.set(false);
        this.errorMessage.set(err.error.message || 'Login failed');
      }
    });
  }
}
```

### Ejemplo: Conectar Incidents List con PlatformService

```typescript
import { PlatformService } from '../../services/platform.service';

@Component({
  selector: 'app-incidents-list',
  // ...
})
export class IncidentsListComponent implements OnInit {
  constructor(private platformService: PlatformService) {}

  ngOnInit() {
    this.loadIncidents();
  }

  loadIncidents() {
    this.platformService.getIncidents().subscribe({
      next: (data) => {
        this.incidents.set(data);
      },
      error: (err) => {
        console.error('Error loading incidents:', err);
      }
    });
  }
}
```

## Estilos Personalizados

### Cambiar Colores Primarios

Editar `tailwind.config.js`:

```javascript
theme: {
  extend: {
    colors: {
      "primary": "#003594", // Cambiar a tu color
      "primary-container": "#004ac6",
      // ... más colores
    }
  }
}
```

### Agregar Temas Adicionales

```javascript
// tailwind.config.js
darkMode: "class", // Ya está configurado para soportar modo oscuro
```

## Troubleshooting

### Problema: Los estilos de Tailwind no se aplican

**Solución**: 
1. Verificar que `tailwind.config.js` está en la raíz del proyecto
2. Asegurar que `styles.css` tiene las directivas `@tailwind`
3. Limpiar node_modules y reinstalar: `rm -rf node_modules && npm install`

### Problema: Material Symbols no se cargan

**Solución**: Verificar que `styles.css` importa correctamente:
```css
@import url('https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap');
```

### Problema: Layout no es responsivo en mobile

**Solución**: Verificar que las clases de breakpoint se apliquen correctamente:
- `md:` para medium screens
- `lg:` para large screens
- `sm:` para small screens

## Performance Tips

1. **Lazy load** los componentes en las rutas cuando sea posible
2. **Change detection OnPush** para componentes sin cambios frecuentes
3. **Usar trackBy** en `*ngFor` para listas grandes
4. **Memoizar** métodos de cálculo con `computed()`

## Próximos Pasos

- [ ] Conectar componentes con API real
- [ ] Implementar autenticación JWT
- [ ] Agregar lazy loading de imágenes
- [ ] Optimizar bundle size
- [ ] Agregar tests unitarios
- [ ] Implementar PWA
- [ ] Agregar animations con Angular
