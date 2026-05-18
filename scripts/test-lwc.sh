#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-all}"
PATTERN="${2:-}"

command -v node >/dev/null || { echo "Node.js is required."; exit 1; }
command -v npm >/dev/null || { echo "npm is required."; exit 1; }

if [[ ! -d node_modules ]]; then
  echo "Installing npm dependencies..."
  npm install
fi

case "${MODE}" in
  all)
    npm test
    ;;
  coverage)
    npm run test:coverage
    ;;
  watch)
    npm run test:watch
    ;;
  debug)
    npm run test:debug
    ;;
  pattern)
    if [[ -z "${PATTERN}" ]]; then
      echo "Usage: scripts/test-lwc.sh pattern <test-name-pattern>"
      exit 1
    fi
    npm test -- --testNamePattern="${PATTERN}"
    ;;
  *)
    cat <<'EOF'
Usage: scripts/test-lwc.sh [all|coverage|watch|debug|pattern <test-name-pattern>]
EOF
    exit 1
    ;;
esac
