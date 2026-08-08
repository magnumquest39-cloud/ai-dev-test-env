#!/usr/bin/env bash
# Проверка тестовой среды разработки через ИИ-чат
set -euo pipefail

PASS=0
FAIL=0

check() {
  local name="$1"
  local result="$2"
  if [ "$result" = "0" ]; then
    PASS=$((PASS+1))
    echo "PASS: $name"
  else
    FAIL=$((FAIL+1))
    echo "FAIL: $name"
  fi
}

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "== Тест 1: структура среды =="
check "CONFIG существует" "$([ -d "$ROOT/CONFIG" ]; echo $?)"
check "tools существует" "$([ -d "$ROOT/tools" ]; echo $?)"
check "tests существует" "$([ -d "$ROOT/tests" ]; echo $?)"

echo "== Тест 2: валидность JSON конфигов =="
for f in "$ROOT"/CONFIG/*.json "$ROOT"/tools/*.json; do
  if command -v jq >/dev/null 2>&1; then
    check "JSON валиден: $(basename "$f")" "$(jq empty "$f" >/dev/null 2>&1; echo $?)"
  else
    check "JSON валиден (python3): $(basename "$f")" "$(python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$f" >/dev/null 2>&1; echo $?)"
  fi
done

echo "== Тест 3: бесплатные инструменты =="
for tool in gh curl; do
  check "инструмент $tool доступен" "$(command -v "$tool" >/dev/null 2>&1; echo $?)"
done

echo "== Тест 4: настройки автономности и бесплатности =="
if command -v jq >/dev/null 2>&1; then
  check "режим autonomic" "$(jq -e ".mode == \"autonomic\"" "$ROOT/CONFIG/autonomy.json" >/dev/null 2>&1; echo $?)"
  check "free_only = true" "$(jq -e ".free_policy.free_only == true" "$ROOT/CONFIG/autonomy.json" >/dev/null 2>&1; echo $?)"
  check "overrides включены" "$(jq -e ".overrides.enabled == true" "$ROOT/CONFIG/overrides.json" >/dev/null 2>&1; echo $?)"
  check "реестр функций не пуст" "$(jq -e ".functions | length > 0" "$ROOT/CONFIG/functions.json" >/dev/null 2>&1; echo $?)"
fi

echo "== Тест 5: документация и план =="
check "PLAN.md существует" "$([ -f "$ROOT/PLAN.md" ]; echo $?)"
check "README.md существует" "$([ -f "$ROOT/README.md" ]; echo $?)"

echo ""
echo "Итого: PASS=$PASS FAIL=$FAIL"
if [ "$FAIL" -eq 0 ]; then
  echo "СРЕДА ГОТОВА: автономная, бесплатная, протестирована"
else
  exit 1
fi
