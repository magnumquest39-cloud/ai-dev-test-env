#!/usr/bin/env bash
# Точка входа тестовой среды
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
echo "=== AI Dev Test Environment ==="
echo "Запуск проверки окружения..."
bash "$ROOT/tests/test_env.sh"
