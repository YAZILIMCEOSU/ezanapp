#!/usr/bin/env bash
# EzanAI kalite kapısı — her istekte çalıştırılır (bkz. AGENTS.md).
#
# Flutter SDK varsa biçim, analiz, test ve kıble kontrollerini sırayla koşar.
# SDK yoksa yeşil sonuç uydurmaz: hangi kontrollerin yalnızca CI'da
# yapılabildiğini yazar ve 2 ile çıkar.
set -uo pipefail

cd "$(dirname "$0")/.." || exit 2

fail=0
step() {
  local name="$1"
  shift
  printf '\n=== %s ===\n' "$name"
  if "$@"; then
    printf 'OK: %s\n' "$name"
  else
    printf 'HATA: %s\n' "$name"
    fail=1
  fi
}

if ! command -v flutter >/dev/null 2>&1; then
  cat <<'EOF'
Flutter SDK bu ortamda yok.
Bu durumda kalite kapısı yalnızca GitHub Actions'ta koşar:
  - analyze.yml: format + analyze + test + uzak AI + kıble 6/6 + APK + AAB
  - sonuç: .ci/report.md ve dene-apk sürümü
Yeşil CI görülmeden "düzeldi" veya "sorunsuz" denmez.
EOF
  exit 2
fi

step "flutter pub get" flutter pub get
step "biçim" dart format --output=none --set-exit-if-changed lib test
step "analiz" flutter analyze --no-pub
step "testler" flutter test --no-pub
step "kıble (6 kontrol)" python3 tools/verify_qibla.py

if [ "$fail" -ne 0 ]; then
  printf '\nKALİTE KAPISI KIRMIZI\n'
  exit 1
fi
printf '\nKALİTE KAPISI YEŞİL\n'
