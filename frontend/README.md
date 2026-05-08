# Frontend - ProyectoAdminRedes (Angular)

Interfaz de usuario de la plataforma ciudadana, desarrollada con **Angular**.

## 🚀 Despliegue en Producción

El frontend está diseñado para ser servido por **Nginx** y actuar como cliente del backend a través de un proxy.

### 1. Compilación
Desde la carpeta `frontend/`:
```bash
npm install
npm run build -- --configuration production
```

### 2. Configuración de Nginx
El build generado (en `dist/frontend/browser/`) debe moverse a la carpeta raíz del servidor web (ej: `/var/www/frontend`).

Nginx debe estar configurado para redirigir las peticiones `/api` al backend interno:

```nginx
location /api {
    proxy_pass http://<IP_INTERNA_BACKEND>:3000;
}
```

## 🛠️ Desarrollo
Para correr en modo desarrollo local:
```bash
ng serve
```
La aplicación estará disponible en `http://localhost:4200`.

---
**Nota:** El archivo `src/environments/environment.ts` está configurado para usar rutas relativas (`/api`), lo que facilita el despliegue con proxy reverso.
