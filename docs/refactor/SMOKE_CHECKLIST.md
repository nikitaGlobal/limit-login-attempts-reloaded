# Smoke checklist — split LimitLoginAttempts

Base URL (local): `https://new.ru.tuna.am/` (override via `LLAR_SMOKE_BASE_URL`).

## Local app (`active_app` = local)

- [ ] 4 failed logins → 5th shows lockout message
- [ ] 5th attempt while locked → still blocked (ACL-equivalent local lockout)
- [ ] After lockout expires → successful login works
- [ ] Successful login does not leave spurious lockout state

## Custom cloud app

- [ ] ACL deny before login when limit exceeded
- [ ] Lockout API after failed attempts

## MFA (if enabled)

- [ ] Pre-authenticated user with MFA role → redirect to MFA flow
- [ ] Cancel returns to login

## Admin

- [ ] All plugin tabs load
- [ ] Settings save (general tab)
- [ ] Dashboard widget renders

## Automated

```bash
./scripts/smoke-local-lockout.sh
```

## Performance baseline

```bash
./scripts/perf-login-baseline.sh
```

Record wall time for 10 failed POSTs to `wp-login.php`; repeat after stages 2 and 6 (target: ≤ +10%).
