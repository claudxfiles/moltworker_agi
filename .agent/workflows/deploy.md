---
description: Desplegar Moltworker en Cloudflare Workers
---

Este workflow te guiará paso a paso para desplegar Moltworker de forma segura y exitosa.

### Pre-requisitos
- **Docker Desktop:** DEBE estar abierto y funcionando. El proceso de construcción del Sandbox lo utiliza.
- **Plan Paid de Workers:** Necesario para D1, R2 y el Sandbox SDK.
- **Wrangler Login:** Asegúrate de haber iniciado sesión con `npx wrangler login`.

### 0. 🚨 CRÍTICO: Convertir Line Endings (Primera vez)
**ANTES del primer deployment**, ejecuta esto para evitar exit code 126:

// turbo
```powershell
Get-Content start-moltbot.sh -Raw | ForEach-Object { $_ -replace "`r`n","`n" } | Set-Content -NoNewline start-moltbot.sh
```

**Nota:** Solo necesitas hacer esto una vez.

### 1. Creación de Recursos (Paso Manual)
Para evitar errores de validación durante el despliegue, crea estos recursos primero:

```powershell
# 1. Crear Base de Datos D1
npx wrangler d1 create moltbot_db
# COPIA el database_id en tu wrangler.jsonc

# 2. Crear Buckets R2
npx wrangler r2 bucket create moltbot-data
npx wrangler r2 bucket create moltbot-storage
```

### 2. Configuración de Secretos
Configura las claves necesarias para que el agente funcione:

```powershell
# Clave de Anthropic (Obligatorio)
npx wrangler secret put ANTHROPIC_API_KEY

# ID de Cuenta (Para R2)
npx wrangler secret put CF_ACCOUNT_ID

# Token de Acceso (Opcional pero recomendado)
npx wrangler secret put MOLTBOT_GATEWAY_TOKEN
```

### 3. Despliegue Final
Con los recursos creados y el archivo `wrangler.jsonc` actualizado con el ID de D1:

```powershell
npm run deploy
```

### 4. Acceso a la Interfaz
Accede a tu agente en la URL generada. Si configuraste un `MOLTBOT_GATEWAY_TOKEN`, úsalo así:
`https://tu-worker.workers.dev/?token=TU_TOKEN`
