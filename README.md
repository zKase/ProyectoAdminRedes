# Proyecto de Administración de Redes - Plataforma Ciudadana

Este proyecto consiste en una plataforma full-stack diseñada para la participación ciudadana, desplegada sobre una arquitectura distribuida y segura en Google Cloud Platform (GCP).

> Nota actual: el desarrollo funcional se está alineando primero para ejecución local. La migración a Google Cloud queda como fase posterior.

## 🚀 Arquitectura del Sistema

La aplicación está separada en dos niveles de infraestructura para garantizar la seguridad de los datos:

- **Capa de Presentación (Frontend):** VM con IP pública ejecutando **Nginx** como servidor web y proxy reverso. Sirve el build de **Angular**.
- **Capa de Aplicación y Datos (Backend/DB):** VM privada (sin IP pública) accesible solo internamente. Ejecuta **NestJS** y **PostgreSQL**.

### Características Principales:
- **Seguridad:** Aislamiento de base de datos y backend mediante VPC interna.
- **Acceso Remoto:** Administración segura vía **IAP (Identity-Aware Proxy)**.
- **Salida Segura:** Salida a internet para actualizaciones mediante **Cloud NAT**.
- **Alta Disponibilidad Local:** Gestión de procesos con **PM2**.

## 📂 Estructura del Repositorio

- `/frontend`: Aplicación cliente desarrollada en Angular.
- `/backend`: API REST desarrollada con NestJS y TypeORM.
- `/infraestructura`: Scripts de despliegue automatizado y documentación técnica de la red.

## 🛠️ Tecnologías Utilizadas

- **Frontend:** Angular, Nginx.
- **Backend:** Node.js, NestJS, JWT Auth.
- **Base de Datos:** PostgreSQL.
- **Infraestructura:** Google Cloud Platform (VPC, Cloud NAT, Cloud Router, IAP).

## 📖 Documentación de Despliegue

Para replicar este entorno o ver los detalles técnicos, consulta la carpeta `/infraestructura`:
- [Guía Paso a Paso](infraestructura/analisis_arquitectura_final.md)
- [Scripts de Configuración](infraestructura/)
- [Alineación Local con Requisitos](ALINEACION_LOCAL_REQUISITOS.md)

## 💻 Ejecución Local (Para Desarrollo)

Para probar los cambios en tu computadora antes de subirlos a GCP:

### 1. Requisitos
- Node.js v20+
- PostgreSQL corriendo localmente.

### 2. Levantar el Backend
```bash
cd backend
npm install
# Asegúrate de tener un .env con tus credenciales de Postgres local
npm run start:dev
```

### 3. Levantar el Frontend
```bash
cd frontend
npm install
npm run start
```
La aplicación se abrirá en `http://localhost:4200` y se conectará automáticamente al backend en `localhost:3000`.

## Credenciales de prueba (Seeded Data)

La plataforma viene pre-poblada con datos de prueba para facilitar la evaluación de roles:

### Usuarios Administrativos (Acceso a Reportes y Gestión)
- **Admin**: `admin@lascondes.cl` / `admin123`
- **Moderador**: `moderador@lascondes.cl` / `admin123`

### Usuarios Ciudadanos (Votación y Mapeo)
- **Juan Pérez**: `juan.perez@gmail.com` / `user123`
- **Ana Silva**: `ana.silva@gmail.com` / `user123` (y otros vecinos)

*Nota: Por seguridad, cambia estas credenciales y el `JWT_SECRET` en el archivo `.env` antes de un despliegue real a producción.*

## 🔄 Cómo actualizar los cambios en producción

Cuando realices cambios en el código localmente, sigue estos pasos para reflejarlos en las VMs de GCP:

### 1. En tu PC Local
```bash
git add .
git commit -m "Descripción del cambio"
git push origin <tu-rama>
```

### 2. En la VM de Backend (`instancia-db-backend`)
```bash
cd ~/ProyectoAdminRedes && git fetch --all && git reset --hard origin/<tu-rama> && git pull origin <tu-rama>
cd backend
npm install
npm run build
npx pm2 restart backend -i max || npx pm2 start dist/main.js --name backend -i max

# Para poblar/actualizar los datos de prueba en la DB (Opcional):
npm run seed
```

### 3. En la VM de Frontend (`instancia-app`)
```bash
cd ~/ProyectoAdminRedes && git fetch --all && git reset --hard origin/<tu-rama> && git pull origin <tu-rama>
cd frontend
npm install
npm run build -- --configuration production
sudo cp -r dist/frontend/browser/* /var/www/frontend/
sudo systemctl restart nginx
```

## ⚖️ Escalabilidad y Balanceo de Carga

Para mejorar el rendimiento y la disponibilidad, puedes implementar las siguientes estrategias:

### 1. Balanceo Vertical (PM2 Cluster Mode)
Ejecuta múltiples instancias del backend aprovechando todos los núcleos de la CPU:
```bash
# En la instancia de backend
npx pm2 delete backend
npx pm2 start dist/main.js --name backend -i max
npx pm2 save
```

### 2. Balanceo Horizontal (Nginx)
Si tienes múltiples instancias de backend, configura Nginx en la `instancia-app`:
1. Edita la configuración de Nginx: `sudo nano /etc/nginx/sites-available/default`
2. Define el grupo de servidores:
```nginx
upstream backend_servers {
    server 10.128.0.2:3000; # Backend A
    server 10.128.0.3:3000; # Backend B
}
```
3. Actualiza el `proxy_pass`:
```nginx
location /api/ {
    proxy_pass http://backend_servers/;
    # ... otras configuraciones
}
```
## 🗄️ Gestión de Backups (Base de Datos)

Para asegurar la integridad de los datos o realizar tareas de mantenimiento, sigue estas instrucciones dentro de la **VM de Backend**:

### 1. Crear un Backup (Exportar)
Antes de empezar, asegúrate de que la carpeta existe dentro del proyecto:
```bash
mkdir -p backend/backups
```
Ejecuta el siguiente comando para generar un volcado de la base de datos:
```bash
# Backup en formato SQL plano
pg_dump -h localhost -U postgres -d proyecto_db > backend/backups/backup_$(date +%Y%m%d_%H%M%S).sql
```
*Nota: Los archivos se guardarán en la carpeta `backend/backups/`.*

### 2. Restaurar un Backup (Importar)
Si necesitas limpiar la base de datos y cargar un backup existente:

1. **Detener el Backend** (para liberar conexiones):
   ```bash
   pm2 stop backend
   ```
2. **Borrar y Recrear la DB**:
   ```bash
   sudo -u postgres dropdb proyecto_db
   sudo -u postgres createdb proyecto_db
   ```
3. **Cargar el Backup**:
   ```bash
   sudo -u postgres psql proyecto_db < backend/backups/tu_archivo_backup.sql
   ```
4. **Reiniciar el Backend**:
   ```bash
   pm2 start backend
   ```

### 3. Uso de Scripts Automatizados (Windows Local)
Si estás trabajando localmente en Windows, puedes usar el script incluido en el repositorio:
```powershell
.\backend\scripts\backup-db.ps1
```

## ☁️ Acceso rápido desde Google Cloud Shell (Cualquier Rama)

Si prefieres actualizar todo desde la terminal de Google Cloud usando una rama específica, define primero la variable `BRANCH`:

```bash
# Define la rama a desplegar (ejemplo: main, dev, feature-x)
export BRANCH=main 
```

**Para el Backend (vía IAP):**
```bash
gcloud compute ssh instancia-db-backend --zone=us-central1-a --tunnel-through-iap --command="cd ~/ProyectoAdminRedes && git fetch --all && git reset --hard origin/$BRANCH && git checkout $BRANCH && git pull origin $BRANCH && cd backend && npm install && npm run build && (npx pm2 restart backend -i max || npx pm2 start dist/main.js --name backend -i max) && npm run seed"
```

**Para el Frontend:**
```bash
gcloud compute ssh instancia-app --zone=us-central1-a --command="cd ~/ProyectoAdminRedes && git fetch --all && git reset --hard origin/$BRANCH && git checkout $BRANCH && git pull origin $BRANCH && cd frontend && npm install && npm run build -- --configuration production && sudo cp -r dist/frontend/browser/* /var/www/frontend/ && sudo systemctl restart nginx"
```
