# Keycloak Deploy (Docker Compose + Nginx)
Data: 2026-01-15

Repository “operativo” per installare **Keycloak** su **Ubuntu** con:
- **Docker Compose** (Keycloak + PostgreSQL)
- **Nginx** reverse proxy (80/443) + TLS (Let's Encrypt)
- **systemd** per avvio automatico
- script per **backup/restore** e **healthcheck**
- best practice DevOps (pin versioni, niente secret in Git, hardening minimo)

> Nota: i segreti NON vanno versionati. Usa `.env` locale (ignorato da git) oppure un secret manager.

---

## 0) Struttura del repo

```
keycloak-ec2-deploy/
├─ docker-compose.yml
├─ .env.example
├─ .gitignore
├─ README.md
├─ nginx/
│  └─ keycloak.conf
├─ systemd/
│  └─ keycloak-compose.service
├─ scripts/
│  ├─ backup_db.sh
│  ├─ restore_db.sh
│  ├─ update.sh
│  ├─ healthcheck.sh
│  └─ logs.sh
├─ backups/
│  └─ .gitkeep
└─ docs/
   ├─ SECURITY.md
   └─ TROUBLESHOOTING.md
```

---

## 1) Prerequisiti (AWS + VM)

### DNS
Crea un record A:
- `auth.example.com` → Public IP (o Load Balancer)

---

## 2) Installare Docker + Docker Compose (Ubuntu)
Se Docker è già presente, salta.

```bash
sudo apt update
sudo apt install -y ca-certificates curl gnupg

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker

docker --version
docker compose version
```

Opzionale (evita `sudo` per docker):
```bash
sudo usermod -aG docker $USER
# logout/login
```

---

## 3) Configurazione: creare `.env` (segreti)
1) Copia il template:
```bash
cp .env.example .env
chmod 600 .env
```

2) Modifica i valori (dominio e password):
```bash
nano .env
```

---

## 4) Avvio stack (Keycloak + Postgres)
Dalla root del repo:

```bash
docker compose pull
docker compose up -d
docker compose ps
```

Verifica locale dal server:
```bash
curl -I http://127.0.0.1:8080/
docker logs --tail=200 keycloak
```

> Il mapping è **solo** su `127.0.0.1:8080` per evitare esposizione pubblica diretta.

---

## 5) Nginx reverse proxy (porta 80)
Installa Nginx (se necessario):
```bash
sudo apt update
sudo apt install -y nginx
sudo systemctl enable --now nginx
```

Installa il vhost:
```bash
sudo cp nginx/keycloak.conf /etc/nginx/sites-available/keycloak
sudo ln -sf /etc/nginx/sites-available/keycloak /etc/nginx/sites-enabled/keycloak
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl reload nginx
```

> `nginx/keycloak.conf` usa `server_name auth.example.com;`.
> Cambialo se usi un altro dominio.

---

## 6) TLS con Let’s Encrypt (Certbot)
Prerequisiti:
- DNS ok
- inbound 80/443 ok

```bash
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d auth.example.com
sudo certbot renew --dry-run
```

---

## 7) Avvio automatico (systemd)
Copia il service file:
```bash
sudo cp systemd/keycloak-compose.service /etc/systemd/system/keycloak-compose.service
sudo systemctl daemon-reload
sudo systemctl enable --now keycloak-compose
sudo systemctl status keycloak-compose --no-pager
```

---

## 8) Primo accesso Keycloak (admin)
Apri:
- `https://auth.example.com`

Login admin usando:
- `KEYCLOAK_ADMIN`
- `KEYCLOAK_ADMIN_PASSWORD`

Post-install obbligatorio (produzione):
- cambia password admin
- limita accesso admin console
- configura SMTP (Realm settings → Email)
- crea un realm dedicato (es. `dens`) separato da `master`

Discovery OIDC:
- `https://auth.example.com/realms/<realm>/.well-known/openid-configuration`

---

## 9) Operatività DevOps

### Logs
```bash
./scripts/logs.sh
```

### Healthcheck
```bash
./scripts/healthcheck.sh
```

### Backup DB
```bash
./scripts/backup_db.sh
ls -lh backups/
```

### Restore DB
```bash
# ATTENZIONE: usa prima un ambiente di test
./scripts/restore_db.sh backups/keycloak_YYYY-MM-DD.sql
```

### Update controllato (pin versione)
- cambia il tag Keycloak in `docker-compose.yml`
- poi:
```bash
./scripts/update.sh
```

---

## 10) Hardening minimo
Vedi `docs/SECURITY.md`.

---

## 11) Troubleshooting
Vedi `docs/TROUBLESHOOTING.md`.
