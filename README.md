# Proyecto de Administración de Redes - Plataforma Ciudadana

Este proyecto consiste en una plataforma full-stack diseñada para la participación ciudadana, desplegada sobre una arquitectura distribuida y segura en Google Cloud Platform (GCP).

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

## Credenciales de prueba (desarrollo)

Para facilidad en entornos locales se ha creado un usuario admin de prueba. Úsalas solo en desarrollo.

- email: admin@example.com
- password: Password123!

Por seguridad, cambia estas credenciales y el JWT_SECRET antes de desplegar a un entorno público.

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
cd ~/ProyectoAdminRedes && git pull origin <tu-rama>
cd backend
npm install   # Solo si agregaste librerías
npm run build
npx pm2 restart backend
```

### 3. En la VM de Frontend (`instancia-app`)
```bash
cd ~/ProyectoAdminRedes && git pull origin <tu-rama>
cd frontend
npm install   # Solo si agregaste librerías
npm run build -- --configuration production
sudo cp -r dist/frontend/browser/* /var/www/frontend/
```

---
Proyecto desarrollado por **zKase**.
