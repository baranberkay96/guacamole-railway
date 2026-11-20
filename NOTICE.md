# Notice

## Upstream software

This repository contains Railway configuration and a small database bootstrap script only. Guacamole and guacd are pulled from their official images; they are not stored in this repository.

| Software | License | Source (publisher) |
|---|---|---|
| Apache Guacamole 1.6.0 web application (Tomcat 9, Java 21, PostgreSQL JDBC, TOTP and ban extensions as shipped in the image) | Apache-2.0 (Guacamole); bundled components under their own licenses | `guacamole/guacamole:1.6.0@sha256:f344085e618bb05e22b964b0208dbd06d3468275bac70206f93805245e067b40` (Apache Guacamole project) |
| guacd 1.6.0 (guacamole-server) | Apache-2.0; bundled libraries (FreeRDP, libvncserver, libssh2 and others) under their own licenses | `guacamole/guacd:1.6.0@sha256:8974eaa9ba32f713daf311e7cc8cd7e4cdfba1edea39eed75524e78ef4b08f4f` (Apache Guacamole project) |
| PostgreSQL client (psql) | PostgreSQL License | Ubuntu 24.04 package `postgresql-client`, installed at build time |
| PostgreSQL 18 | PostgreSQL License | `ghcr.io/railwayapp-templates/postgres-ssl:18.6@sha256:4fc833b43d2aaf6ecc9b18615f5533602b723a32d0e2efe2dae8ca0f7217c863` (Railway; MIT-licensed image repository) |

Apache Guacamole's license: https://github.com/apache/guacamole-client/blob/1.6.0/LICENSE.

## Verified against

| What | Upstream file | Ref | Checked |
|---|---|---|---|
| Latest release | `apache/guacamole-server` and `guacamole-client` tags (`1.6.0`) | `1.6.0` | 2026-11-20 |
| Image layout (Tomcat on Ubuntu 24.04, user `guacamole`, `entrypoint.sh` sourcing `entrypoint.d/*.sh`, `WEBAPP_CONTEXT`, `enable-environment-properties`, feature switches `*_ENABLED`) | `Dockerfile`, `guacamole-docker/bin/entrypoint.sh`, `guacamole-docker/entrypoint.d/*.sh` | `1.6.0` | 2026-11-20 |
| Schema files and location (`/opt/guacamole/extensions/guacamole-auth-jdbc/postgresql/schema/*.sql`) | `guacamole-docker/bin/initdb.sh`, `extensions/guacamole-auth-jdbc/modules/guacamole-auth-jdbc-postgresql/schema/` | `1.6.0` | 2026-11-20 |
| Seeded `guacadmin` salt and hash; password scheme SHA-256(password + uppercase hex salt) | `002-create-admin-user.sql`, `SHA256PasswordEncryptionService` | `1.6.0` | 2026-11-20 |
| Remote IP valve variables | `guacamole-docker/environment/REMOTE_IP_VALVE_/configure.sh` | `1.6.0` | 2026-11-20 |
| guacd binary path and options (`/opt/guacamole/sbin/guacd -f -b -l -L`) | `guacamole-server` `Dockerfile` | `1.6.0` | 2026-11-20 |

## Adapted code

| Our file | Source | Changes |
|---|---|---|
| `services/guacamole/railway-guacamole-db`, `050-railway-db.sh` | Written for this template; loads the schema files the image ships, as `initdb.sh` prints them | — |

## Trademarks

Apache, Apache Guacamole and the Guacamole logo are trademarks of the Apache Software Foundation. This community template is not affiliated with or endorsed by the Apache Software Foundation. "Railway" and "PostgreSQL" belong to their respective owners.
