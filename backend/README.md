# Backend - ProyectoAdminRedes (NestJS)

Esta es la API del proyecto, construida con el framework **NestJS**. Maneja la lógica de negocio, la autenticación y la persistencia de datos.

## 🛠️ Tecnologías
- **Framework:** [NestJS](https://nestjs.com/)
- **ORM:** TypeORM
- **Base de Datos:** PostgreSQL
- **Seguridad:** Passport JWT

## ⚙️ Configuración

Para correr este backend en producción, se requiere un archivo `.env` en la raíz de esta carpeta con las siguientes variables:

```env
DATABASE_URL=postgresql://usuario:password@localhost:5432/nombre_db
JWT_SECRET=tu_clave_secreta
NODE_ENV=production
```

## 🚀 Despliegue (En VM Privada)

1. **Instalación:**
   ```bash
   npm install
   ```

2. **Compilación:**
   ```bash
   npm run build
   ```

3. **Ejecución con PM2:**
   ```bash
   npx pm2 start dist/main.js --name backend
   ```

## 📚 Documentación API
Una vez encendido, puedes acceder a la documentación de Swagger en:
`http://<IP_INTERNA>:3000/api/docs`
