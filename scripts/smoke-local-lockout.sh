#!/usr/bin/env bash
# Smoke: repeated failed wp-login attempts should eventually return lockout text.
set -euo pipefail

BASE_URL="${LLAR_SMOKE_BASE_URL:-https://new.ru.tuna.am}"
LOGIN_URL="${BASE_URL%/}/wp-login.php"
USER="${LLAR_SMOKE_USER:-admin}"
PASS="${LLAR_SMOKE_PASS:-wrong-password-smoke}"
ATTEMPTS="${LLAR_SMOKE_ATTEMPTS:-6}"

echo "Smoke local lockout: ${LOGIN_URL} (${ATTEMPTS} attempts)"

found_lockout=0
for i in $(seq 1 "${ATTEMPTS}"); do
  body=$(curl -sS -L --max-time 30 \
    -d "log=${USER}&pwd=${PASS}&wp-submit=Log+In" \
    "${LOGIN_URL}" 2>/dev/null || true)
  if echo "${body}" | grep -qiE 'too many failed|locked out|try again'; then
    echo "Attempt ${i}: lockout message detected"
    found_lockout=1
    break
  fi
  echo "Attempt ${i}: no lockout message yet"
done

if [ "${found_lockout}" -eq 1 ]; then
  echo "PASS"
  exit 0
fi

echo "FAIL: no lockout message after ${ATTEMPTS} attempts (check local mode and limits)"
exit 1
