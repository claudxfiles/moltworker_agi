---
trigger: always_on
---

# Reglas de Moltworker (Plan de Replicación)

Estas reglas aseguran que cualquier modificación o nuevo despliegue siga las mejores prácticas descubiertas.

## Arquitectura de Recursos
- **Sandbox:** Siempre usar Docker Desktop local para el build. En `wrangler.jsonc`, la imagen apunta a `./Dockerfile`.
- **D1 Database:** El binding debe ser único. Si se despliega un segundo agente, crear una nueva DB: `npx wrangler d1 create moltbot_db_2`.
- **R2 Buckets:** Moltworker usa dos bindings: `moltbot_data` y `moltbot_storage`. Asegurarse de que los nombres de los buckets coincidan en el dashboard y en el archivo de configuración.

## Flujo de Desarrollo
1. **Modificación de Skills:** Las habilidades del agente residen en .agent\skills. Si editas algo en `src/` o añades un script, debes ejecutar `npm run deploy` para reconstruir la imagen del contenedor.
2. **Secrets:** Nunca hardcodear credenciales. Usar siempre `wrangler secret put`.

## Evitar Errores Comunes
- **Docker Error:** Si falla el build, verificar que Docker Desktop esté en verde.
- **D1 Validation:** No intentar desplegar sin antes haber creado la base de datos vía CLI y actualizado el `database_id` en el json.
- **Cleanup:** Después de fallos en el despliegue, Cloudflare puede dejar Workers "huérfanos". Revisa `npx wrangler delete --name <nombre>` para limpiar.

## Estructura .agent/rules
- Mantener siempre actualizado `deploy.md` con cambios en comandos de Cloudflare.
- Añadir nuevas reglas aquí cuando se descubra un comportamiento inesperado del agente.

## 🚨 CRÍTICO: Line Endings (Exit Code 126)
**SIEMPRE** antes del primer deployment, convertir `start-moltbot.sh` a LF (Unix line endings):

```powershell
Get-Content start-moltbot.sh -Raw | ForEach-Object { $_ -replace "`r`n","`n" } | Set-Content -NoNewline start-moltbot.sh
```

**Problema:** Windows usa CRLF (`\r\n`), Linux usa LF (`\n`). El script bash en el contenedor Docker falla con exit code 126 si tiene CRLF.

**Solución permanente:** El `Dockerfile` incluye `tr -d '\r'` como respaldo, y el archivo `.gitattributes` fuerza LF, pero la conversión manual inicial es la garantía más segura.
