# TROUBLESHOOTING

## 1) Keycloak non risponde su 127.0.0.1:8080
- `docker compose ps`
- `docker logs --tail=200 keycloak`
- verificare DB healthy: `docker logs --tail=200 kc-postgres`

## 2) Da Internet timeout su auth.example.com
- Security Group inbound 80/443
- Public IP / subnet pubblica / route verso IGW
- NACL (se presenti) non bloccanti

## 3) Redirect strani http/https
- assicurarsi che Nginx invii `X-Forwarded-Proto`
- Keycloak con `--proxy-headers=xforwarded` e `KC_PROXY=edge`
- `KC_HOSTNAME` coerente con dominio pubblico

## 4) Certbot fallisce
- DNS non propagato / record A errato
- porta 80 chiusa (ACME HTTP-01)
- firewall locale/ufw

## 5) Comandi rapidi
- Healthcheck: `./scripts/healthcheck.sh`
- Logs: `./scripts/logs.sh`
