# SECURITY / Hardening minimo

## 1) Superficie esposta
- Inbound AWS: aprire solo TCP 80/443.
- NON esporre 8080 (Keycloak) e 5432 (PostgreSQL).
- Mantenere Keycloak bindato su 127.0.0.1 tramite compose.

## 2) TLS
- Abilitare HTTPS (Let's Encrypt o certificato aziendale).
- Forzare redirect HTTP->HTTPS.
- Valutare HSTS dopo stabilizzazione.

## 3) Segreti
- Non committare `.env`.
- Preferire un Secret Manager (AWS Secrets Manager) e provisioning controllato.
- Ruotare password DB/admin periodicamente.

## 4) Backup e DR
- Backup DB giornaliero + retention.
- Test periodico restore in ambiente di staging.

## 5) Aggiornamenti
- Pin delle versioni (no :latest).
- Update con change log, finestra manutenzione, backup prima dell'upgrade.

## 6) Admin access
- Limitare accesso alla Admin Console (IP allow-list / VPN / WAF).
- Abilitare MFA/Conditional Access se disponibile.
