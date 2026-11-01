#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Diyanet temkin (düzeltme) değerlerini resmî vakitlerle kalibre eder.

Amaç
----
`lib/data/prayer/prayer_calculator.dart` içindeki `Temkin.diyanet` sabitleri,
Türkiye Cumhuriyeti Diyanet İşleri Başkanlığı'nın yayımladığı resmî vakitlerle
uyuşacak şekilde en küçük kareler yöntemiyle fit edilir.

Girdi
-----
* ``tools/data/raw/official_diyanet_sample.json`` — ``"<ilceID>|<YYYY-MM-DD>"``
  anahtarı ve ``{imsak, gunes, ogle, ikindi, aksam, yatsi}`` değerleri.
  Yoksa: ``python3 tools/data/fetch_official_times.py --months 2`` ile indirin.
* ``assets/data/cities_turkey.json`` — 81 ilin plaka kodu → enlem/boylam
  eşlemesi (resmî örneklem il plakasıyla anahtarlanır: ``"1|2023-01-13"``).
  Alternatif olarak ``--coords`` ile ilçe kimliği tabanlı bir eşleme verilebilir.

Çıktı
-----
Fit edilen tamsayı dakika düzeltmeleri, hata istatistikleri ve Dart kodu bloğu.
``--check`` verilirse kodda yazan değerlerden farklı olanlar işaretlenir ve fark
varsa çıkış kodu 1 olur (CI'da kullanılabilir).

Bu betik, Dart tarafındaki hesap motorunun **birebir aynısını** uygular; iki
tarafın ayrışmaması için formül değişikliklerinde burada da güncelleme gerekir.
"""
from __future__ import annotations

import argparse
import json
import math
import os
import statistics
import sys

PRAYERS = ("imsak", "gunes", "ogle", "ikindi", "aksam", "yatsi")
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
RAW = os.path.join(ROOT, "tools", "data", "raw")
CALCULATOR = os.path.join(ROOT, "lib", "data", "prayer", "prayer_calculator.dart")

D2R = math.pi / 180.0
R2D = 180.0 / math.pi


def _sin(d: float) -> float:
    return math.sin(d * D2R)


def _cos(d: float) -> float:
    return math.cos(d * D2R)


def _tan(d: float) -> float:
    return math.tan(d * D2R)


def _asin(v: float) -> float:
    return math.asin(max(-1.0, min(1.0, v))) * R2D


def _acos(v: float) -> float:
    return math.acos(max(-1.0, min(1.0, v))) * R2D


def _atan(v: float) -> float:
    return math.atan(v) * R2D


def _normalize(degrees: float) -> float:
    value = degrees % 360.0
    return value + 360.0 if value < 0 else value


def _fix_hour(hours: float) -> float:
    value = hours % 24.0
    return value + 24.0 if value < 0 else value


def julian_day(year: int, month: int, day: int) -> float:
    if month <= 2:
        year -= 1
        month += 12
    a = year // 100
    b = 2 - a + a // 4
    return (
        math.floor(365.25 * (year + 4716))
        + math.floor(30.6001 * (month + 1))
        + day
        + b
        - 1524.5
    )


def sun_position(jd: float) -> tuple[float, float]:
    d = jd - 2451545.0
    g = _normalize(357.529 + 0.98560028 * d)
    q = _normalize(280.459 + 0.98564736 * d)
    l = _normalize(q + 1.915 * _sin(g) + 0.020 * _sin(2 * g))
    e = 23.439 - 0.00000036 * d
    declination = _asin(_sin(e) * _sin(l))
    right_ascension = _fix_hour(
        math.atan2(math.cos(e * D2R) * _sin(l), _cos(l)) * R2D / 15.0
    )
    equation_of_time = _fix_hour(q / 15.0 - right_ascension)
    eqt = equation_of_time - 24.0 if equation_of_time > 12.0 else equation_of_time
    return declination, eqt


def hour_angle_depression(angle: float, latitude: float, declination: float) -> float:
    numerator = -_sin(angle) - _sin(latitude) * _sin(declination)
    denominator = _cos(latitude) * _cos(declination)
    if abs(denominator) < 1e-9:
        return float("nan")
    return _acos(numerator / denominator) / 15.0


def hour_angle_altitude(altitude: float, latitude: float, declination: float) -> float:
    numerator = _sin(altitude) - _sin(latitude) * _sin(declination)
    denominator = _cos(latitude) * _cos(declination)
    if abs(denominator) < 1e-9:
        return float("nan")
    return _acos(numerator / denominator) / 15.0


def asr_altitude(latitude: float, declination: float, factor: float) -> float:
    return _atan(1.0 / (factor + _tan(abs(latitude - declination))))


def raw_times(
    year: int,
    month: int,
    day: int,
    latitude: float,
    longitude: float,
    time_zone: float = 3.0,
    fajr_angle: float = 18.0,
    isha_angle: float = 17.0,
    asr_factor: float = 1.0,
) -> dict[str, float]:
    """Temkin uygulanmamış ham astronomik vakitler (saat cinsinden)."""
    jd0 = julian_day(year, month, day)
    declination, eqt = sun_position(jd0 + (12.0 - time_zone) / 24.0)
    dhuhr = 12.0 + time_zone - longitude / 15.0 - eqt
    for _ in range(3):
        dhuhr = 12.0 + time_zone - longitude / 15.0 - eqt
        declination, eqt = sun_position(jd0 + (dhuhr - time_zone) / 24.0)
    dhuhr = 12.0 + time_zone - longitude / 15.0 - eqt

    sunrise_ha = hour_angle_depression(0.833, latitude, declination)
    maghrib_ha = hour_angle_depression(0.833, latitude, declination)
    fajr_ha = hour_angle_depression(fajr_angle, latitude, declination)
    isha_ha = hour_angle_depression(isha_angle, latitude, declination)
    asr_ha = hour_angle_altitude(
        asr_altitude(latitude, declination, asr_factor), latitude, declination
    )

    return {
        "imsak": dhuhr - fajr_ha,
        "gunes": dhuhr - sunrise_ha,
        "ogle": dhuhr,
        "ikindi": dhuhr + asr_ha,
        "aksam": dhuhr + maghrib_ha,
        "yatsi": dhuhr + isha_ha,
    }


def load_json(path: str):
    with open(path, "r", encoding="utf-8") as handle:
        return json.load(handle)


def parse_hhmm(value: str) -> float:
    hours, minutes = value.split(":")[:2]
    return int(hours) + int(minutes) / 60.0


def coordinates(coords_source) -> dict[str, tuple[float, float]]:
    """Anahtar → (enlem, boylam) eşlemesi üretir.

    * ``cities_turkey.json`` (uygulama varlığı): il plakası ve ilçe kimliği
      anahtarları birlikte tanımlanır.
    * ``city_lookup.json`` (ham veri): ``IlceID`` anahtarı kullanılır.
    """
    coords: dict[str, tuple[float, float]] = {}
    if isinstance(coords_source, dict) and "provinces" in coords_source:
        for province in coords_source["provinces"]:
            coords[str(province["plate"])] = (province["lat"], province["lon"])
            if province.get("id"):
                coords[str(province["id"])] = (province["lat"], province["lon"])
        for district in coords_source.get("districts", []):
            if district.get("id"):
                coords[str(district["id"])] = (district["lat"], district["lon"])
    elif isinstance(coords_source, list):
        for item in coords_source:
            if item.get("IlceID") is not None:
                coords[str(item["IlceID"])] = (item["lat"], item["lon"])
    return coords


def collect_deviations(sample: dict, coords_source) -> dict[str, list[float]]:
    """Resmî vakit ile ham hesap arasındaki farkı dakika cinsinden toplar."""
    coords = coordinates(coords_source)

    deviations: dict[str, list[float]] = {name: [] for name in PRAYERS}
    for key, times in sample.items():
        if "|" not in key:
            continue
        district, date = key.split("|", 1)
        if district not in coords:
            continue
        year, month, day = (int(part) for part in date.split("-"))
        latitude, longitude = coords[district]
        raw = raw_times(year, month, day, latitude, longitude)
        for name in PRAYERS:
            if name not in times:
                continue
            diff = (parse_hhmm(times[name]) - raw[name]) * 60.0
            diff -= 1440.0 * round(diff / 1440.0)
            deviations[name].append(diff)
    return deviations


def best_offset(
    values: list[float], tolerance: float = 10.0
) -> tuple[int, float, float, int]:
    """Tamsayı dakika cinsinden en iyi düzeltmeyi döner.

    Dönen değer: ``(düzeltme, en kötü sapma, ortalama sapma, ayıklanan ölçüm)``.

    Kaynak veri kümesinde tek tük hatalı ilçe kayıtları bulunabildiği için
    (ör. yanlış koordinatla eşlenmiş bir il), medyandan [tolerance] dakikadan
    fazla sapan ölçümler ayıklanır ve raporlanır. Bu ölçümler uygulamaya değil,
    kalibrasyon girdisine aittir.

    Ölçüt: ortalama mutlak sapmayı en küçükleyen tamsayı düzeltme (medyan
    tabanlı, en küçük karelerden uç değerlere karşı daha dayanıklıdır). En kötü
    durum bilgi amaçlı raporlanır.
    """
    center = statistics.median(values)
    kept = [value for value in values if abs(value - center) <= tolerance]
    if not kept:
        kept = list(values)
    scored = []
    for candidate in range(-30, 31):
        mean = sum(abs(value - candidate) for value in kept) / len(kept)
        worst = max(abs(value - candidate) for value in kept)
        scored.append((mean, round(worst, 3), candidate))
    mean, _, chosen = min(scored, key=lambda item: (item[0], item[1]))
    worst = max(abs(value - chosen) for value in kept)
    return chosen, worst, mean, len(values) - len(kept)


def read_current_temkin() -> dict[str, int]:
    """Koddaki mevcut `Temkin.diyanet` değerlerini okur."""
    current = {name: 0 for name in PRAYERS}
    try:
        with open(CALCULATOR, "r", encoding="utf-8") as handle:
            source = handle.read()
    except OSError:
        return current
    block = source.split("static const Temkin diyanet", 1)[-1]
    for name in PRAYERS:
        marker = f"{name}:"
        if marker in block:
            tail = block.split(marker, 1)[1].lstrip()
            number = ""
            for char in tail:
                if char in "-0123456789":
                    number += char
                else:
                    break
            if number:
                current[name] = int(number)
    return current


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--sample",
        default=os.path.join(RAW, "official_diyanet_sample.json"),
        help="resmî vakit örneklemi (JSON)",
    )
    parser.add_argument(
        "--coords",
        default=os.path.join(ROOT, "assets", "data", "cities_turkey.json"),
        help="il plakası/ilçe kimliği → koordinat kaynağı",
    )
    parser.add_argument(
        "--check",
        action="store_true",
        help="koddaki değerlerden farklıysa çıkış kodu 1 ver",
    )
    args = parser.parse_args()

    if not os.path.exists(args.sample):
        print(
            "Örneklem bulunamadı: "
            f"{args.sample}\n"
            "İndirmek için: python3 tools/data/fetch_official_times.py --months 6",
            file=sys.stderr,
        )
        return 2

    sample = load_json(args.sample)
    coords_source = load_json(args.coords)
    deviations = collect_deviations(sample, coords_source)

    print("vakit     ölçüm   ortalama   en küçük   en büyük    en iyi temkin")
    fitted: dict[str, int] = {}
    total_worst = 0.0
    for name in PRAYERS:
        values = deviations[name]
        if not values:
            continue
        chosen, worst, mean, dropped = best_offset(values)
        fitted[name] = chosen
        total_worst = max(total_worst, worst)
        dropped_note = f", {dropped} uç değer ayıklandı" if dropped else ""
        print(
            f"{name:9s} {len(values):5d} {statistics.mean(values):10.2f} "
            f"{min(values):10.2f} {max(values):10.2f}   {chosen:+3d} dk "
            f"(en kötü {worst:.2f}, ort {mean:.2f}{dropped_note})"
        )

    print("\nDart kodu (lib/data/prayer/prayer_calculator.dart):\n")
    print("  static const Temkin diyanet = Temkin(")
    for name in PRAYERS:
        if name in fitted:
            print(f"    {name}: {fitted[name]},")
    print("  );")
    print(
        f"\nAyıklama sonrası en büyük sapma: {total_worst:.2f} dk\n"
        "Ayıklanan uç değerler kaynak veri kümesindeki hatalı kayıtlardan "
        "kaynaklanır (bkz. tools/data/README.md)."
    )

    if args.check:
        current = read_current_temkin()
        differences = {
            name: (current.get(name), fitted[name])
            for name in fitted
            if current.get(name) != fitted[name]
        }
        material = {
            name: pair for name, pair in differences.items()
            if abs(pair[0] - pair[1]) > 1
        }
        for name, (code, fit) in differences.items():
            note = "" if name in material else " (1 dk tolerans içinde)"
            print(f"  {name}: kod {code}, fit {fit}{note}")
        if material:
            print("\nKod değerleri fit ile uyuşmuyor: güncelleyin.")
            return 1
        print("\nKod değerleri fit ile uyumlu ✓")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
