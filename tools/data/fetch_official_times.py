#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Resmî namaz vakitlerini (Diyanet) açık API'den indirir.

Amaç
-----
`calibrate_diyanet.py` için doğrulama verisi üretmek ve gömülü doğrulama
fikstürünü (`assets/data/diyanet_validation_sample.json`) güncelleyebilmek.

Kaynak
------
``https://ezanvakti.imsakiyem.com/api/prayer-times/{ilceID}/{period}``

* ``period``: ``weekly`` | ``monthly`` | ``yearly`` | ``range``
* ``range`` için ``startDate`` ve ``endDate`` (YYYY-MM-DD) zorunludur.
* Yanıt zarfı: ``{success, code, message, data, meta}``; kayıtlar
  ``{district_id, date, hijri_date, times{imsak…yatsi}}`` biçimindedir.

Kullanım
--------
    # Varsayılan: kalibrasyonda kullanılan 11 ilin son 6 ayı
    python3 tools/data/fetch_official_times.py

    # Belirli ilçeler ve aralık
    python3 tools/data/fetch_official_times.py --districts 9146,9153 --months 12

Çıktı: ``tools/data/raw/official_diyanet_sample.json``
(``"<ilceID>|<YYYY-MM-DD>" → {imsak, gunes, ogle, ikindi, aksam, yatsi}``)
"""
from __future__ import annotations

import argparse
import calendar
import datetime as dt
import json
import os
import sys
import time
import urllib.error
import urllib.parse
import urllib.request

API = "https://ezanvakti.imsakiyem.com/api/prayer-times"
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
RAW = os.path.join(ROOT, "tools", "data", "raw")

# Kalibrasyon örnekleminde kullanılan iller (kuzey-güney, doğu-batı, kıyı-iç
# bölge dağılımını temsil eder).
DEFAULT_DISTRICTS = [
    "9146",  # Adana
    "9153",  # Ankara
    "9171",  # Antalya
    "9193",  # Bursa
    "9218",  # Diyarbakır
    "9225",  # Erzurum
    "9239",  # Gaziantep
    "9282",  # İstanbul
    "9302",  # Kayseri
    "9330",  # Samsun
    "9369",  # Trabzon
]

PRAYER_KEYS = {
    "imsak": ("imsak", "İmsak"),
    "gunes": ("gunes", "güneş", "Güneş"),
    "ogle": ("ogle", "öğle", "Öğle"),
    "ikindi": ("ikindi", "İkindi"),
    "aksam": ("aksam", "akşam", "Akşam"),
    "yatsi": ("yatsi", "yatsı", "Yatsı"),
}


def fetch(district: str, period: str, query: dict[str, str] | None = None) -> list[dict]:
    url = f"{API}/{district}/{period}"
    if query:
        url = f"{url}?{urllib.parse.urlencode(query)}"
    request = urllib.request.Request(
        url,
        headers={"Accept": "application/json", "User-Agent": "EzanAI-data/1.0"},
    )
    with urllib.request.urlopen(request, timeout=30) as response:
        payload = json.loads(response.read().decode("utf-8"))
    if isinstance(payload, dict):
        if payload.get("success") is False:
            raise RuntimeError(payload.get("message") or "API hatası")
        data = payload.get("data")
    else:
        data = payload
    if isinstance(data, dict):
        for key in ("times", "items", "records", "days"):
            if isinstance(data.get(key), list):
                return data[key]
        return [data]
    return data if isinstance(data, list) else []


def normalize(record: dict) -> dict[str, str] | None:
    nested = record.get("times")
    times = nested if isinstance(nested, dict) else record
    out: dict[str, str] = {}
    for canonical, aliases in PRAYER_KEYS.items():
        for alias in aliases:
            value = times.get(alias)
            if value:
                out[canonical] = str(value)[:5]
                break
    return out if len(out) == len(PRAYER_KEYS) else None


def month_ranges(months: int) -> list[tuple[dt.date, dt.date]]:
    today = dt.date.today().replace(day=1)
    ranges: list[tuple[dt.date, dt.date]] = []
    cursor = today
    for _ in range(months):
        last_day = calendar.monthrange(cursor.year, cursor.month)[1]
        ranges.append((cursor, cursor.replace(day=last_day)))
        cursor = (cursor - dt.timedelta(days=1)).replace(day=1)
    return list(reversed(ranges))


def collect(district: str, months: int, pause: float) -> dict[str, dict[str, str]]:
    collected: dict[str, dict[str, str]] = {}
    for start, end in month_ranges(months):
        try:
            records = fetch(
                district,
                "range",
                {"startDate": start.isoformat(), "endDate": end.isoformat()},
            )
        except (urllib.error.URLError, RuntimeError, TimeoutError) as error:
            print(f"! {district} {start:%Y-%m}: {error}", file=sys.stderr)
            continue
        for record in records:
            times = normalize(record)
            date = str(record.get("date", ""))[:10]
            if not times or len(date) != 10:
                continue
            collected[f"{district}|{date}"] = times
        print(f"→ {district} {start:%Y-%m}: {len(records)} kayıt")
        time.sleep(pause)
    return collected


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--districts",
        default=",".join(DEFAULT_DISTRICTS),
        help="virgülle ayrılmış Diyanet ilçe kimlikleri",
    )
    parser.add_argument("--months", type=int, default=6, help="geriye dönük ay sayısı")
    parser.add_argument(
        "--out",
        default=os.path.join(RAW, "official_diyanet_sample.json"),
        help="çıktı dosyası",
    )
    parser.add_argument(
        "--pause",
        type=float,
        default=0.4,
        help="istekler arası bekleme (saniye)",
    )
    args = parser.parse_args()

    os.makedirs(RAW, exist_ok=True)
    sample: dict[str, dict[str, str]] = {}
    if os.path.exists(args.out):
        with open(args.out, "r", encoding="utf-8") as handle:
            sample = json.load(handle)

    districts = [item.strip() for item in args.districts.split(",") if item.strip()]
    for district in districts:
        sample.update(collect(district, args.months, args.pause))

    with open(args.out, "w", encoding="utf-8") as handle:
        json.dump(sample, handle, ensure_ascii=False, indent=1, sort_keys=True)

    print(
        f"\nToplam {len(sample)} kayıt yazıldı: "
        f"{os.path.relpath(args.out, ROOT)}\n"
        "Kalibrasyon: python3 tools/data/calibrate_diyanet.py"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
