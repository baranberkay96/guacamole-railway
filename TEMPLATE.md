# Apache Guacamole 1.6 Remote Desktop Gateway: composer spec

Listing name: **Apache Guacamole 1.6 Remote Desktop Gateway**
Description (68 chars): Browser access to RDP, VNC and SSH hosts, with Postgres and TOTP 2FA
Category: Other. Icon: `https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/guacamole.svg`
Repository: `baranberkay96/guacamole-railway` (this folder is the repo root).

## Services

| Service | Source | Public | Volume | Healthcheck |
|---|---|---|---|---|
| Guacamole | repo `/services/guacamole` (`FROM guacamole/guacamole:1.6.0@sha256:f344…7b40` + `postgresql-client` + DB bootstrap) | domain → 8080 | none | `/`, 1200 s |
| guacd | image `guacamole/guacd:1.6.0@sha256:8974…8f4f`, start `guacd -f -b :: -l 4822 -L info` | no | none | — |
| Postgres | image `ghcr.io/railwayapp-templates/postgres-ssl:18.6@sha256:4fc8…c863` (= `:18`, checked 2026-11-20) | no | `/var/lib/postgresql/data` | — |

Pinned 2026-11-20: Apache Guacamole 1.6.0 (current release).

## Boot sequence (Guacamole)

The image's `entrypoint.sh` sources `entrypoint.d/*.sh` in order; ours is `050-railway-db.sh`, before the properties (100), Tomcat base (500), features (700) and Tomcat start (999):

1. `railway-guacamole-db` waits for Postgres (15 min), loads the image's schema files in one transaction if `guacamole_entity` is missing, and renames `guacadmin` to `GUACAMOLE_ADMIN_USERNAME` (first boot only).
2. Any `guacamole_user` row still holding the seeded salt/hash gets `GUACAMOLE_ADMIN_PASSWORD` (SHA-256(pw + HEX(salt)), fresh 32-byte salt); a password < 8 chars or `guacadmin` gets a random one instead (locked, log line). `GUACAMOLE_ADMIN_PASSWORD_RESET=true` sets the named account's password.
3. Helper exit ≠ 0 (database unreachable/unverifiable) → `POSTGRESQL_ENABLED=false`: Guacamole starts without database auth, nobody can sign in, no default login (fail closed without failing the deploy, 8.29).

Feature variables: `POSTGRESQL_*` (JDBC auth), `TOTP_ENABLED`, `BAN_*` (on by default in the image), `REMOTE_IP_VALVE_*` (client IP from `x-real-ip`, HTTPS from `x-forwarded-proto`). `WEBAPP_CONTEXT=ROOT` serves Guacamole at `/`.

## Improvements over market templates

Market (2026-11): "Apache Guacamole" (third-party repo) ≈47 active / 27 recent deploys; a 2-project variant with an unpinned build.

- Official images pinned by tag + digest (market: `guacamole/guacd` without tag, a third-party repo for the web app).
- Schema created automatically, default `guacadmin/guacadmin` replaced before Tomcat starts, admin renamed (market leader relies on a third-party init; default credentials risk).
- guacd addressed by its private Railway name and bound dual-stack (market leader uses `GUACD_HOSTNAME=guacd`).
- Postgres 18, TOTP switch, ban extension and real client IPs behind Railway's proxy.
- Deploy-form values never fail the deploy (8.29).

## Resources

Measured on Railway, test project, 2026-11-20 (Guacamole 1.6.0, Postgres 18.6), 40 min incl. logins and one telnet session:

| Service | RAM | CPU idle |
|---|---|---|
| Guacamole | 0.33-0.46 GB (JVM) | ~0.001 vCPU (peaks 0.04) |
| guacd | 0.011 GB idle, 0.05 GB after one text session (graphical RDP/VNC sessions use more, not measured) | ~0 |
| Postgres | 0.07-0.10 GB | ~0 |

Estimate: ~0.6 GB RAM ≈ $6/month + CPU and volume ≈ **$6-8/month**. Trial and Hobby; Free (0.5 GB per service) is tight for the JVM.

Railway prices: RAM $10/GB-month, vCPU $20/vCPU-month, volume $0.15/GB-month.

## Verification checklist

1. All services SUCCESS; `GET /` 200.
2. Log lines `first boot: creating the Guacamole schema`, `administrator renamed to 'admin'`, `default guacadmin password replaced`.
3. `POST /api/tokens` with `guacadmin/guacadmin` → 403; with the variables → 200 token; the token lists the `postgresql` data source.
4. Create an SSH connection through the API to a host and open it (tunnel handshake through guacd).
5. `GUACAMOLE_ADMIN_PASSWORD=abc` + `RESET=true` → warning, service healthy; valid password + reset → login works.

## Open questions

- No bundled target desktop: a private RDP/VNC desktop service would add an image of 1+ GB and 0.5+ GB RAM; users connect their own hosts.
- Session recordings are not configured (they would need storage shared between guacd and the web app, which Railway volumes cannot provide).
