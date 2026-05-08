# Alineación Local con Requisitos de Licitación

Este documento resume los cambios implementados para alinear el proyecto local con el Documento de Análisis Inicial. La migración a Google Cloud queda como una fase posterior.

## Estado Implementado

| Requisito | Implementación local |
|---|---|
| RF01 | Backend de encuestas y presupuestos ya existente; dashboard ciudadano lista encuestas y presupuestos. |
| RF02 | Nuevo módulo `issues` para problemáticas territoriales con latitud, longitud, dirección, categoría y estado. |
| RF03 | Comentarios en propuestas mediante `proposal_comments`, con moderación básica visible/oculto. |
| RF04 | Preparado para local; escalabilidad cloud queda postergada para migración a GCP. |
| RF05 | Nuevo módulo `reports` con resumen agregado de propuestas, encuestas, presupuestos y problemáticas. |
| RF06 | Dashboard ciudadano activado como ruta principal `/dashboard`; dashboard visual anterior queda en `/admin-dashboard`. |
| RNF01 | Votos de presupuestos mantienen índices únicos; respuestas de encuestas mantienen índice único por encuesta/pregunta/usuario. |
| RNF02 | Login/registro con JWT, bcrypt y email único. |
| RNF03 | Comentarios persistidos sin locks explícitos; colaboración local inicial. |
| RNF04 | Pendiente para fase Cloud Run / balanceador. |
| RNF05 | Auditoría global existente mediante `AuditInterceptor`. |

## Nuevos Endpoints Locales

### Problemáticas territoriales

- `POST /api/issues`
- `GET /api/issues`
- `GET /api/issues/:id`
- `PATCH /api/issues/:id`
- `PATCH /api/issues/:id/status/:status`

### Comentarios de propuestas

- `POST /api/proposals/:id/comments`
- `GET /api/proposals/:id/comments`
- `PATCH /api/proposals/comments/:commentId`

### Reportes

- `GET /api/reports/summary`

### Asistente ciudadano

- `POST /api/chatbot/ask`

Si `OPENROUTER_API_KEY` no está configurado, el chatbot responde en modo local con reglas simples. Si se configura, usa OpenRouter.

## Rutas Frontend

- `/dashboard`: experiencia local de participación ciudadana.
- `/admin-dashboard`: dashboard administrativo visual previo.
- `/incidents` y `/incidents/:id`: pantallas heredadas de incidentes, disponibles para futura reutilización o eliminación.

## Pendiente para Fase Cloud

- Migrar backend a Cloud Run.
- Migrar PostgreSQL a Cloud SQL.
- Configurar balanceador/HTTPS administrado.
- Ajustar variables secretas con Secret Manager.
- Actualizar documentación de infraestructura final.
