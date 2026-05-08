# Análisis Técnico de la Arquitectura - ProyectoAdminRedes

Este documento detalla el estado final de la infraestructura desplegada en Google Cloud Platform (GCP) al día 06 de mayo de 2026.

## 1. Topología de Red y Cómputo

La arquitectura se basa en una separación de capas (Tiered Architecture) para maximizar la seguridad de los datos.

| Componente | Nombre Instancia | IP Interna | IP Externa | Rol |
| :--- | :--- | :--- | :--- | :--- |
| **Frontend** | `instancia-app` | `10.128.0.4` | `34.123.60.18` | Nginx (Proxy Reverso) + Angular |
| **Backend/DB** | `instancia-db-backend` | `10.128.0.5` | *(Ninguna)* | NestJS + PostgreSQL |

- **Red VPC:** `default`
- **Subred Regional:** `us-central1` (Rango: `10.128.0.0/20`)

## 2. Flujo de Comunicación y Seguridad

### Acceso Externo (Ingress)
1.  **Tráfico Web:** Los usuarios acceden a través de la IP `34.123.60.18` por el puerto **80 (HTTP)**. Nginx recibe la petición.
2.  **Mantenimiento (SSH):** El acceso administrativo se realiza mediante **IAP (Identity-Aware Proxy)**, restringido al rango de Google `35.235.240.0/20`, lo que elimina la necesidad de exponer el puerto 22 a todo internet.

### Comunicación Interna
- El Frontend redirige las peticiones `/api` a `http://10.128.0.5:3000`.
- Gracias a la regla `default-allow-internal`, el tráfico entre las dos VMs fluye sin restricciones internas por el puerto 3000 y 5432.

### Salida a Internet (Egress - Cloud NAT)
- La instancia `instancia-db-backend` utiliza el gateway **`nat-backend-router`** para descargar paquetes y actualizaciones.
- **Beneficio:** La base de datos puede actualizarse pero sigue siendo inalcanzable desde internet, reduciendo la superficie de ataque casi a cero.

## 3. Reglas de Firewall Destacadas

- **`allow-web-traffic` / `default-allow-http`**: Permite el tráfico público al frontend (Puerto 80).
- **`ssh-acceso-google`**: Permite la administración segura vía consola de GCP.
- **`default-allow-internal`**: Facilita la conexión entre el proxy y el servidor de aplicaciones.

## 4. Estado de los Servicios

- **Frontend:** Angular servido por Nginx.
- **Backend:** NestJS corriendo bajo el gestor de procesos **PM2** (Nombre: `backend`).
- **Base de Datos:** PostgreSQL escuchando localmente en el puerto 5432.

## 5. Mantenimiento y Actualizaciones

Para actualizar el sistema después de cambios en el código (rama deseada):

1. **Backend:** Ejecutar `git pull origin <rama>`, `npm run build` y `npx pm2 restart backend` en `instancia-db-backend`.
2. **Frontend:** Ejecutar `git pull origin <rama>`, `npm run build` y copiar el contenido de `dist/` a `/var/www/frontend/` en `instancia-app`.

---
**Documentación generada automáticamente para el respaldo del Proyecto de Administración de Redes.**
