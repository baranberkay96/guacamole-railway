# Apache Guacamole web application for Railway: the official image plus a boot step that
# creates the PostgreSQL schema on the first boot and replaces the default guacadmin/guacadmin
# login with your own administrator before Tomcat starts.
#
# Pinned by tag and digest. To upgrade, change both to a newer release (and guacd to the same
# version): https://hub.docker.com/r/guacamole/guacamole/tags
FROM guacamole/guacamole:1.6.0@sha256:f344085e618bb05e22b964b0208dbd06d3468275bac70206f93805245e067b40

USER root

# psql for the schema/admin step (Ubuntu 24.04 archive; psql 16 talks to Postgres 18 fine).
RUN apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends postgresql-client \
 && rm -rf /var/lib/apt/lists/*

COPY --chmod=755 railway-guacamole-db /opt/railway/railway-guacamole-db
# Sourced by the image's entrypoint before the guacamole.properties/Tomcat steps (100-999).
COPY --chmod=644 050-railway-db.sh /opt/guacamole/entrypoint.d/050-railway-db.sh

# Fail the build early if the schema files, psql or our scripts are missing.
RUN ls /opt/guacamole/extensions/guacamole-auth-jdbc/postgresql/schema/*.sql >/dev/null \
 && psql --version >/dev/null \
 && bash -n /opt/railway/railway-guacamole-db && bash -n /opt/guacamole/entrypoint.d/050-railway-db.sh

USER guacamole
