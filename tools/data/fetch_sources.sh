#!/usr/bin/env bash
# EzanAI — gömülü veri varlıklarının ham kaynaklarını indirir.
#
# Kullanım:  bash tools/data/fetch_sources.sh
# Çıktı:     tools/data/raw/*.json   (git'e DAHİL EDİLMEZ)
#
# Tüm kaynaklar açık lisanslı / serbest dağıtımlı veri kümeleridir.
set -euo pipefail

RAW_DIR="$(cd "$(dirname "$0")" && pwd)/raw"
mkdir -p "$RAW_DIR"

# GitHub API üzerinden ham dosya indirir (token varsa rate-limit'e takılmaz).
gh_raw() { # repo path outfile
  local repo="$1" path="$2" out="$3"
  echo "→ $repo/$path"
  if command -v gh >/dev/null 2>&1; then
    gh api -H "Accept: application/vnd.github.raw" "repos/$repo/contents/$path" > "$out"
  else
    curl -sSL "https://raw.githubusercontent.com/$repo/HEAD/$path" -o "$out"
  fi
}

# --- Kur'an-ı Kerim: Arapça (Tanzil Uthmani), Türkçe meal (QuranEnc), sure listesi
gh_raw "risan/quran-json" "data/tanzil/uthmani.json"          "$RAW_DIR/quran_uthmani.json"
gh_raw "risan/quran-json" "data/quranenc/turkish_shahin.json" "$RAW_DIR/quran_turkish_meal.json"
gh_raw "risan/quran-json" "data/tanzil/chapters.json"         "$RAW_DIR/quran_chapters.json"

# --- Hadis: Riyâzü's-sâlihîn (Arapça + Türkçe + kaynak künyeleri)
gh_raw "HasanEksi/Riyazus-Salihin-Veritabani-HadisKitaplari.com" \
       "riyazus-salihin-hadisleri.json" "$RAW_DIR/riyazus_salihin.json"

# --- Şehir/koordinat veri kümesi (Diyanet tabanlı)
gh_raw "furkantektas/EzanVaktiAPI" "app/static/data/lookup.json" "$RAW_DIR/city_lookup.json"

# --- Diyanet resmî vakit doğrulama verisi (kalibrasyon/doğrulama için)
# Açık API'den indirilir; depoda tutulmaz.
python3 "$(dirname "$0")/fetch_official_times.py" --months 2 || \
  echo "! Resmî vakit örneklemi indirilemedi (ağ erişimi gerekir)." 

echo
echo "Ham veriler hazır: $RAW_DIR"
echo "Şimdi: python3 tools/data/build_assets.py"
