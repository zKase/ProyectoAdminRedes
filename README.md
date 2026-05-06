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

---
Proyecto desarrollado por **zKase**.
