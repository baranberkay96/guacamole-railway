# Deploy and Host Apache Guacamole with Railway

Apache Guacamole is a clientless remote desktop gateway: it gives you RDP, VNC, SSH and Telnet sessions in a web browser, with no plugin or client software. This community template runs Guacamole 1.6.0 with its guacd proxy daemon and PostgreSQL 18, creates the database schema for you, and replaces the well-known guacadmin/guacadmin login before Guacamole goes online.

## About Hosting Apache Guacamole

Guacamole has two parts: a Java web application that users sign in to, and guacd, a native daemon that speaks RDP, VNC, SSH and Telnet to your machines and streams the screen to the browser. A database stores users, connections, permissions and session history. Setting it up by hand means running the schema script and changing the default administrator password before anyone else finds the login page. This template does both automatically on the first boot, before Tomcat starts: the schema is loaded in one transaction, the seeded guacadmin account is renamed and given your generated password. guacd and Postgres stay on Railway's private network; only the web application is public. Failed logins are rate-limited by Guacamole's ban extension, and TOTP two-factor authentication is one variable away.

## Common Use Cases

- A browser-based bastion for servers and VMs: SSH and RDP without VPN clients
- Remote access to home-lab or office machines from any device, including tablets and Chromebooks
- Giving contractors or support staff access to specific desktops without sharing credentials
- Central, audited access with per-user connection permissions and session history
- Teaching labs and workshops where students only need a browser

## Dependencies for Apache Guacamole Hosting

- Apache Guacamole 1.6.0 web application (`guacamole/guacamole`, official image, pinned by digest)
- guacd 1.6.0 (`guacamole/guacd`, official image, pinned by digest)
- PostgreSQL 18 (Railway's `postgres-ssl` image)

### Deployment Dependencies

- Apache Guacamole: https://guacamole.apache.org/
- Manual (Docker images, database authentication, TOTP): https://guacamole.apache.org/doc/gug/
- Source code: https://github.com/apache/guacamole-client and https://github.com/apache/guacamole-server

### Implementation Details

| Service | Role | Public |
|---|---|---|
| Guacamole | Web application (Tomcat): login, connection management, the remote desktop in the browser | **yes** |
| guacd | Proxy daemon that connects to your RDP, VNC, SSH and Telnet hosts | no (private network) |
| Postgres | Users, connections, permissions and history; private only, with a volume | no |

**First login**

1. Wait until the Guacamole service is healthy. The first deploy builds a thin image on top of the official one; the deploy log shows `[railway] first boot: creating the Guacamole schema` and `default guacadmin password replaced`.
2. Copy `GUACAMOLE_ADMIN_USERNAME` (default `admin`) and `GUACAMOLE_ADMIN_PASSWORD` (generated) from the Guacamole service's Variables.
3. Open the Guacamole service's public domain and sign in. `guacadmin`/`guacadmin` does not work.
4. Go to Settings → Connections → New Connection, choose the protocol (RDP, VNC, SSH or Telnet) and enter your host's address and credentials.

**Which hosts can it reach?** guacd connects from Railway to your machines, so they must be reachable from the internet (a public IP or a port forward, ideally restricted by firewall), or run in the same Railway project and be addressed by their private name (`{service}.railway.internal`). Railway has no UDP, which does not matter here: guacd uses TCP for RDP, VNC and SSH.

**Administrator password.** `GUACAMOLE_ADMIN_PASSWORD` replaces the default password on the first boot; afterwards manage passwords in Guacamole. Every boot also checks that no account still has the published default password. Forgot it? Set a new `GUACAMOLE_ADMIN_PASSWORD` and `GUACAMOLE_ADMIN_PASSWORD_RESET=true`, redeploy, then set it back to `false`. Invalid values never break the deploy: an unusable user name keeps `guacadmin`, and a password shorter than 8 characters replaces the default with a random one, so the login stays locked until you set a valid password with the reset flag (the deploy log says so). If the database cannot be checked, Guacamole starts with database logins disabled rather than risk the default login.

**Two-factor authentication.** Set `TOTP_ENABLED=true` and redeploy: at the next login every user enrolls an authenticator app (Google Authenticator, Aegis, 1Password and others).

**Brute-force protection.** Guacamole's ban extension blocks an address for 5 minutes after 5 failed logins (`BAN_*` variables). Tomcat reads the real client address from Railway's proxy header, so bans hit the attacker, not the proxy.

**Custom domain.** Add it in the Guacamole service's Settings → Networking. Nothing else needs to change.

**Resources and plans.** Guacamole is a Java application: plan for about 0.3-0.5 GB of RAM for the web application, a few MB for an idle guacd plus roughly 50-150 MB per active graphical session, and about 0.1 GB for Postgres. That is roughly $5-8 a month at Railway's usage prices for a few users. Trial and Hobby work; on the Free plan (0.5 GB per service) the web application may be too tight.

**Scaling.** guacd does the heavy lifting during sessions; raise its CPU and memory for many simultaneous desktops. The web application keeps active sessions in memory, so keep it at one replica.

**Upgrading Guacamole.** The web application's version is pinned in `services/guacamole/Dockerfile`, guacd's in the service's image tag; always upgrade both to the same version. Newer Guacamole releases may need database upgrade scripts (shipped in the image under `postgresql/schema/upgrade`); read the release notes and back up Postgres first.

**License.** Apache Guacamole is licensed under the Apache License 2.0. This is a community template, not affiliated with or endorsed by the Apache Software Foundation.

### Why Deploy Apache Guacamole on Railway?

Railway runs the Guacamole web application, guacd and Postgres in one project with a private network, an HTTPS domain, logs and usage-based pricing. This template gives you a browser-based remote desktop gateway in a few minutes, with the database prepared, no default credentials left behind, and two-factor authentication ready to switch on.
