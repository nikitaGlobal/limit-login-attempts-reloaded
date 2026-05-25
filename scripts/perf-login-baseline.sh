#!/usr/bin/env bash
# Record wall time for N failed login POSTs (performance baseline).
set -euo pipefail

BASE_URL="${LLAR_SMOKE_BASE_URL:-https://new.ru.tuna.am}"
LOGIN_URL="${BASE_URL%/}/wp-login.php"
USER="${LLAR_SMOKE_USER:-admin}"
PASS="${LLAR_SMOKE_PASS:-wrong-password-perf}"
N="${LLAR_PERF_ATTEMPTS:-10}"

echo "Perf baseline: ${N} POSTs to ${LOGIN_URL}"
start=$(date +%s)
for i in $(seq 1 "${N}"); do
  curl -sS -o /dev/null --max-time 30 \
    -d "log=${USER}&pwd=${PASS}&wp-submit=Log+In" \
    "${LOGIN_URL}" 2>/dev/null || true
done
end=$(date +%s)
echo "Total seconds: $(( end - start ))"
