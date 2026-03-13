# PR: feature/mfa-core → master

## Summary

This PR adds a **2FA/MFA** tab with backup codes, rescue links, and an **MFA flow** with an external app (handshake, email send-code, callback, login after verification). Below is what exists in this branch and not in master.

## What this branch adds (vs master)

### 2FA tab and rescue links

* New **MFA tab** in the sidebar: role-based 2FA settings, backup codes, PDF export. Enabling “Enable 2FA” shows a rescue-links popup; “Activate” submits the form, closing the popup reloads the page.
* **Rescue links**: one-time links with configurable TTL (unlimited optional), atomic use, global cooldown (`LLA_MFA_RESCUE_USE_COOLDOWN`), path validation. Popup: Print and “Confirm and close”, PDF/Copy/Print in one row, PDF via jsPDF only (no html2canvas). Extended copy including a technical-issue example. Overridable constants, local libs (no CDN). OpenSSL warning when unavailable; PDF libs only on MFA tab and on demand. Privacy notice under “Enable 2FA”; popup only when MFA is enabled.

### MFA flow (external app)

* **Handshake** (MfaApiClient): call external API, store session (token, secret; send_email_secret from app), redirect to MFA app.
* **Send-code**: REST `llar/v1/mfa/send-code` (POST) and AJAX fallback; validate secret and session, send code by email (wp_mail), store OTP; secret in body only. Single handshake secret used for both verify and send_code.
* **Callback**: handle return with `token` (and optional `code`); verify OTP and API verify, then log in and redirect. CallbackHandler ignores send-code requests so that endpoint returns 403/200.
* **MfaRestApi** lives in `core/mfa-flow/`. Test mode: `LLA_MFA_FLOW_TEST_REDIRECT` and route `mfa/test-handshake-session` for curl-based send-code testing.

### Security and structure

* Rescue codes: encrypted in DB (AES-256-CBC or fallback), SHA-256 and constant-time comparison, timing-attack mitigations. SQL injection fixes in rescue cleanup. XSS fix in rescue output; dedicated rescue endpoint handler. Generic error messages; local jsPDF (no CDN). SSL/HTTPS recommended; “HTTPS recommended” notice only on Debug tab. Unified block reasons (`LLA_MFA_BLOCK_REASON_*`), deterministic rate-limit salt.
* New structure: `core/mfa/` (MfaManager, MfaSettings, MfaValidator, MfaBackupCodes, RescueCode, MfaEndpoint, interfaces) and `core/mfa-flow/` (CallbackHandler, SessionStore, MfaRestApi, MfaApiClient, MfaFlowSendCode, MfaProviderRegistry, LlarMfaProvider). **AdminNoticesController** and single view for options-page notices (auto-update, https-recommended, flash). HTTP transport init order: fopen → WP → curl. Plugin JS uses `let`/`const`; MFA disabled message in a separate script.

## Testing

* MFA login: handshake → redirect → return without code → verify → login.
* Send-code: curl with token/secret in POST body after handshake, or test route when `LLA_MFA_FLOW_TEST_REDIRECT` is set.
* Rescue: enable 2FA, save codes, use rescue link; check cooldown and single use.
* Enable 2FA → rescue popup → Activate (submit) or close (reload).

## Diff vs master

36 files changed, ~4,248 insertions, ~53 deletions. New: `core/mfa-flow/`, `core/mfa/`, MFA tab views and styles, AdminNoticesController and notices view.
