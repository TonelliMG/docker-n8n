# CLAUDE.md — Docker n8n

Project-specific instructions. Inherits the global CLAUDE.md; on conflict, this file wins.
Document only the **non-obvious** — facts the model cannot infer by reading the repo.

## 1. What this is

Self-hosted **n8n** (automation/workflow tool) stack for Raphael Tonelli, packaged with Docker
Compose to run identically on a Windows dev machine (Docker Desktop) and on a Linux server.
No application source code — this repo is **infra/config only**: it orchestrates the official
`n8nio/n8n` image plus a PostgreSQL backend, fully driven by `.env`.

## 2. Stack & versions

- **n8n 2.28.3** — pinned in [Dockerfile](Dockerfile) (`FROM n8nio/n8n:2.28.3`), built by Compose.
- **PostgreSQL 15.18** — official image, used as n8n's database (`DB_TYPE=postgresdb`).
- **Docker Compose** ([docker-compose.yml](docker-compose.yml)) — two services (`n8n`, `postgres`),
  one bridge network (`n8n_network`), two named volumes.
- Host: **Windows 11 + Docker Desktop** for dev; Linux server for prod. PowerShell by default.

## 3. Commands / workflow

- Up (build + run): `docker compose up -d --build`
- Logs: `docker compose logs -f n8n`
- Status: `docker compose ps`
- Stop (keeps data): `docker compose down`
- Validate config: `docker compose config`
- Access UI: http://localhost:5678 (create the **owner user** on first load).

## 4. Architecture / layout

Flat repo — every file is config:

- **[docker-compose.yml](docker-compose.yml)** — the orchestration. `n8n` builds from the local
  Dockerfile; `postgres` runs the stock image. `n8n` `depends_on` postgres `service_healthy`.
- **[Dockerfile](Dockerfile)** — thin wrapper over `n8nio/n8n:2.10.3` that pins the version and
  bakes timezone via build arg. Extend here if community nodes/packages are ever needed.
- **[.env](.env)** — the single source of all config (gitignored). **[.env.example](.env.example)** is
  the committed template with inline docs.
- Persistence is via **named volumes** `n8n_data` (`/home/node/.n8n`) and `postgres_data`
  (`/var/lib/postgresql/data`), prefixed by `COMPOSE_PROJECT_NAME` → e.g. `n8n_stack_n8n_data`.

## 5. Conventions

- **Everything is env-driven.** Never hardcode ports, hosts, credentials, or paths in compose —
  add a variable to `.env` + `.env.example` instead.
- Keep `.env.example` in sync with `.env` (same keys, placeholder values + comments).
- Image/version pinning is intentional — bump `n8nio/n8n` and `postgres` tags deliberately,
  in both the Dockerfile/compose and the README.
- Container/volume names derive from `COMPOSE_PROJECT_NAME`; don't hardcode the prefix.

## 6. Gotchas

- **`N8N_ENCRYPTION_KEY` is permanent.** It encrypts stored credentials; changing it after
  workflows exist makes every saved credential unrecoverable. Generate once, never rotate.
- **Basic auth is gone.** `N8N_BASIC_AUTH_*` was removed in n8n 1.0+ and does nothing on 2.x —
  access control is n8n's native user management (owner account created on first access).
- **HTTP login needs `N8N_SECURE_COOKIE=false`** for localhost/http. On a real domain set it
  `true` and switch `N8N_PROTOCOL=https`, plus update `N8N_HOST`/`WEBHOOK_URL`.
- **`docker compose down -v` deletes the volumes** (all workflows + DB). Never use `-v` unless
  intentionally wiping. Plain `down`/restart/reboot all preserve data.
- **`.env` is gitignored** — it does NOT travel with the repo. When moving to the server, copy
  `.env` manually and keep the **same `N8N_ENCRYPTION_KEY`** to retain existing credentials.
- The `n8n` healthcheck hits `/healthz`; postgres uses `pg_isready`. n8n won't start until
  postgres is healthy.

## 7. Scope / do-not-touch

- Never commit `.env` (secrets). Edit `.env.example` when adding new variables.
- Don't manage data inside the running containers by hand — treat the volumes as the data of
  record; back them up with the `tar` commands in the README.

## 8. Important

Completely ignore anything related to .agents or AGENTS.md, since you already use .claude and CLAUDE.md.
