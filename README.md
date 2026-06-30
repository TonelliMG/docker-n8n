# Docker n8n Setup

Stack pronta para produzir/desenvolver com n8n:

- **n8n 2.28.3** (via Dockerfile fixando a versao)
- **PostgreSQL 15.18** como banco
- Volumes persistentes (dados sobrevivem a restart/reboot)
- Network isolada
- Healthcheck no n8n e no Postgres
- 100% configurado por variaveis no `.env`

## Pre-requisitos

- Docker Desktop (Windows) ou Docker Engine (servidor)

## Como rodar

1. Copie o exemplo de variaveis:
   ```powershell
   Copy-Item .env.example .env
   ```
2. Edite o `.env`:
   - Troque `DB_POSTGRESDB_PASSWORD`
   - Gere uma `N8N_ENCRYPTION_KEY` unica: `openssl rand -hex 32`
     (essa chave NUNCA pode mudar depois, senao perde acesso as credenciais)
   - Para servidor com dominio: ajuste `N8N_HOST`, `N8N_PROTOCOL=https`, `WEBHOOK_URL` e `N8N_SECURE_COOKIE=true`
3. Suba:
   ```powershell
   docker compose up -d --build
   ```
4. Acesse: http://localhost:5678 e crie o usuario owner no primeiro acesso.

## Comandos uteis

```powershell
docker compose logs -f n8n      # acompanhar logs
docker compose ps               # status
docker compose down             # para (dados ficam preservados nos volumes)
docker compose up -d --build    # sobe novamente
docker compose pull             # atualizar imagem do postgres
```

## Persistencia de dados

Os dados ficam em volumes nomeados do Docker:

- `n8n_stack_n8n_data` -> workflows, credenciais e settings do n8n
- `n8n_stack_postgres_data` -> banco PostgreSQL

Eles **sobrevivem** a `docker compose down`, restart do container e reboot da maquina.
So sao apagados com `docker compose down -v` (NAO use a menos que queira zerar tudo).

### Backup

```powershell
docker run --rm -v n8n_stack_postgres_data:/data -v ${PWD}/backups:/backup alpine tar czf /backup/postgres_data.tar.gz -C /data .
docker run --rm -v n8n_stack_n8n_data:/data -v ${PWD}/backups:/backup alpine tar czf /backup/n8n_data.tar.gz -C /data .
```
