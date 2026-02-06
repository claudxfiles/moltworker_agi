# Guía de Replicación de Moltworker

Esta guía te permite replicar exactamente este deployment en otro proyecto o Worker.

## 📋 Resumen del Deployment

**Worker:** `moltbot-agi`  
**URL:** https://moltbot-agi.claudio-alcaman.workers.dev  
**Estado:** ✅ Funcional  

## 🗂️ Estructura del Proyecto

```
moltworker/
├── .agent/
│   ├── rules/
│   │   └── MOLTWORKER.md          # Reglas de deployment (INCLUYE FIX CRÍTICO)
│   ├── skills/
│   │   ├── cloudflare-browser/    # Skill para control de navegador vía CDP
│   │   └── system-info/           # Skill para info del sandbox
│   └── workflows/
│       └── deploy.md              # Workflow de deployment paso a paso
├── skills/
│   └── cloudflare-browser/        # Skills copiadas al contenedor Docker
├── src/
│   └── index.ts                   # Worker principal (Hono + Sandbox)
├── Dockerfile                     # Imagen del sandbox (Node 22 + Moltbot)
├── start-moltbot.sh              # Script de inicio (CRÍTICO: debe tener LF)
├── wrangler.jsonc                # Configuración de Cloudflare Worker
└── package.json
```

## 🚨 PASO CRÍTICO: Line Endings

**ANTES de cualquier deployment**, ejecuta:

```powershell
Get-Content start-moltbot.sh -Raw | ForEach-Object { $_ -replace "`r`n","`n" } | Set-Content -NoNewline start-moltbot.sh
```

**¿Por qué?** Windows usa CRLF (`\r\n`), pero el contenedor Linux necesita LF (`\n`). Si no haces esto, verás:
- `ProcessExitedBeforeReadyError: Process exited with code 126`

## 📝 Pasos de Replicación

### 1. Preparación

1. **Clonar o copiar** el proyecto
2. **Instalar dependencias:**
   ```powershell
   npm install
   ```
3. **Convertir line endings** (ver paso crítico arriba)

### 2. Crear Recursos en Cloudflare

```powershell
# R2 Buckets
npx wrangler r2 bucket create moltbot-data
npx wrangler r2 bucket create moltbot-storage

# D1 Database (opcional, actualmente usa Durable Objects)
# npx wrangler d1 create moltbot_db
# Actualiza el database_id en wrangler.jsonc si usas D1
```

### 3. Configurar Secrets

```powershell
npx wrangler secret put ANTHROPIC_API_KEY
npx wrangler secret put CF_ACCOUNT_ID
npx wrangler secret put MOLTBOT_GATEWAY_TOKEN  # Opcional
npx wrangler secret put CDP_SECRET             # Para cloudflare-browser skill
```

### 4. Deploy

```powershell
npm run deploy
```

**Nota:** Docker Desktop DEBE estar corriendo.

### 5. Verificación

1. Abre: `https://TU-WORKER.workers.dev/_admin/`
2. Si ves error de Durable Object reset, espera 10-15 segundos y refresca
3. La UI de admin debería mostrar "R2 storage is configured"

## ✅ Verificaciones Post-Deployment

- [ ] Admin UI carga sin error "exit code 126"
- [ ] `/api/status` responde HTTP 200
- [ ] Logs muestran "Processes listed... 68 processes"
- [ ] Puedes hacer pairing de dispositivos

## 🛠️ Skills Incluidas

### cloudflare-browser
Permite control de navegador headless vía CDP WebSocket. Ver `.agent/skills/cloudflare-browser/SKILL.md` para detalles.

**Uso:**
```bash
node /root/clawd/skills/cloudflare-browser/scripts/screenshot.js https://google.com output.png
```

### system-info
Muestra información del entorno del sandbox.

**Uso:**
```bash
bash /root/clawd/skills/system-info/scripts/info.sh
```

## 🔄 Para Replicar en Otro Worker

1. Cambia el `name` en `wrangler.jsonc`:
   ```json
   {
     "name": "moltbot-nuevo-nombre"
   }
   ```

2. Crea nuevos buckets R2 con el nuevo nombre:
   ```powershell
   npx wrangler r2 bucket create nuevo-nombre-data
   npx wrangler r2 bucket create nuevo-nombre-storage
   ```

3. Actualiza los bindings en `wrangler.jsonc`:
   ```json
   "r2_buckets": [
     { "binding": "moltbot_data", "bucket_name": "nuevo-nombre-data" },
     { "binding": "moltbot_storage", "bucket_name": "nuevo-nombre-storage" }
   ]
   ```

4. Vuelve a configurar los secrets (son por worker)
5. Deploy como siempre: `npm run deploy`

## 📚 Documentación Adicional

- **Reglas completas:** `.agent/rules/MOLTWORKER.md`
- **Workflow detallado:** `.agent/workflows/deploy.md`
- **Walkthrough de este deployment:** Ver artifact `walkthrough.md`

## 🐛 Troubleshooting

| Error | Solución |
|-------|----------|
| Exit code 126 | Convertir `start-moltbot.sh` a LF (ver paso crítico) |
| Docker build failed | Verificar que Docker Desktop está corriendo |
| Binding validation failed | Crear los buckets R2 antes del deploy |
| Sandbox timeout | Esperar 15 segundos, es cold start normal |

---

**Última actualización:** 2026-02-05  
**Estado:** ✅ Deployment exitoso verificado
