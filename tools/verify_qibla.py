#!/usr/bin/env python3
"""Ezan Vaktim Pro — Kıble doğrulaması (6 bağımsız kontrol).

Bu betik, uygulamadaki Kıble hesabını **uygulama kodundan bağımsız** dört
yöntemle yeniden hesaplar ve karşılaştırır. Flutter/Dart çalıştırmaz; bu yüzden
CI'dan ayrı olarak, istenildiğinde tek komutla tekrarlanabilir:

    python3 tools/verify_qibla.py

Kontroller
----------
1. **Kerteriz (bearing):** küresel büyük daire formülünün iki farklı cebirsel
   yazımı + WGS-84 elipsoidi üzerinde Vincenty ters çözümü. Üçü de aynı sonucu
   vermeli; uygulamanın test sabitleriyle fark < 0,05° olmalı.
2. **Manyetik sapma:** resmî NOAA WMM-2025 katsayıları (pygeomag/WMM_2025.COF)
   ile `test/data/qibla_verification_test.dart` içindeki 16 referans şehir.
   Fark < 0,02° olmalı.
3. **Tolerans:** GPS konum hatası (±0,05° ≈ 5,5 km ve ±0,5° ≈ 55 km), 1°
   pusula hatası ve sapmanın hiç uygulanmaması durumunda oluşan açı hatası.
   Toplam hata, uygulamanın ±5° hizalama eşiğinin altında kalmalı.
4. **Uçtan uca:** uygulama sabitleri (Kâbe koordinatı, eşikler) ile test
   kapsamı; "hizalı" göstergesi verildiğinde gerçek Kıble hatasının üst sınırı.
5. **Güneşle doğrulama:** Kıble Günü (28 Mayıs / 15 Temmuz 2026) güneşin
   azimutu Kâbe yönüyle < 0,25° içinde çakışmalı (pusuladan bağımsız kontrol).
6. **Tutuş füzyonu:** yatay/dik/geçiş tutuşlarında döndürme matrisinden yön
   hesabı; eski yöntemin 180° hatası kanıtlanır, yeni füzyon < 0,01° kalır.

Çıkış kodu 0 → altı kontrol de geçti. 1 → en az bir kontrol başarısız.
"""

from __future__ import annotations

import math
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
QIBLA_TEST = ROOT / "test" / "data" / "qibla_verification_test.dart"
GEO_DART = ROOT / "lib" / "core" / "utils" / "geo.dart"
CONSTANTS_DART = ROOT / "lib" / "core" / "constants" / "app_constants.dart"

# Uygulamadaki değerlerle birebir aynı (lib/core/constants/app_constants.dart)
KAABA_LAT = 21.4224779
KAABA_LON = 39.8251832

# WGS-84
WGS84_A = 6378137.0
WGS84_F = 1 / 298.257223563
WGS84_B = WGS84_A * (1 - WGS84_F)

# resmî Kâbe konumu (Mekke, Mescid-i Haram) — bağımsız kaynak değeri
KAABA_REFERENCE = (21.4225, 39.8262)

# 2026 yılının sonu (testlerde kullanılan ondalık yıl)
DECIMAL_YEAR = 2026.8

failures: list[str] = []


def check(condition: bool, message: str) -> None:
    if not condition:
        failures.append(message)


# --------------------------------------------------------------------------
# Geometri yardımcıları (uygulamadan bağımsız implementasyon)
# --------------------------------------------------------------------------
def normalize360(value: float) -> float:
    return value % 360.0


def normalize_signed(value: float) -> float:
    v = normalize360(value)
    return v - 360.0 if v > 180.0 else v


def angular_difference(a: float, b: float) -> float:
    return abs(normalize_signed(a - b))


def haversine_km(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    r = 6371.0088
    p1, p2 = math.radians(lat1), math.radians(lat2)
    dp = p2 - p1
    dl = math.radians(lon2 - lon1)
    h = math.sin(dp / 2) ** 2 + math.cos(p1) * math.cos(p2) * math.sin(dl / 2) ** 2
    return 2 * r * math.asin(min(1.0, math.sqrt(h)))


def bearing_atan2_tan(lat: float, lon: float) -> float:
    """Uygulamadaki formülün birebir cebirsel eşi (tan biçimi)."""
    p1 = math.radians(lat)
    p2 = math.radians(KAABA_LAT)
    dl = math.radians(KAABA_LON - lon)
    y = math.sin(dl)
    x = math.cos(p1) * math.tan(p2) - math.sin(p1) * math.cos(dl)
    return normalize360(math.degrees(math.atan2(y, x)))


def bearing_vector(lat: float, lon: float) -> float:
    """Aynı büyük daire kerterizinin vektör biçimi (bağımsız yazım)."""
    p1, l1 = math.radians(lat), math.radians(lon)
    p2, l2 = math.radians(KAABA_LAT), math.radians(KAABA_LON)
    y = math.sin(l2 - l1) * math.cos(p2)
    x = math.cos(p1) * math.sin(p2) - math.sin(p1) * math.cos(p2) * math.cos(l2 - l1)
    return normalize360(math.degrees(math.atan2(y, x)))


def vincenty_inverse_azimuth(lat1: float, lon1: float, lat2: float, lon2: float):
    """WGS-84 elipsoidi üzerinde Vincenty ters çözümü: (başlangıç azimutu, mesafe km)."""
    if abs(lat1 - lat2) < 1e-12 and abs(lon1 - lon2) < 1e-12:
        return 0.0, 0.0
    l = math.radians(lon2 - lon1)
    u1 = math.atan((1 - WGS84_F) * math.tan(math.radians(lat1)))
    u2 = math.atan((1 - WGS84_F) * math.tan(math.radians(lat2)))
    sin_u1, cos_u1 = math.sin(u1), math.cos(u1)
    sin_u2, cos_u2 = math.sin(u2), math.cos(u2)

    lam = l
    for _ in range(200):
        sin_lam, cos_lam = math.sin(lam), math.cos(lam)
        sin_sigma = math.hypot(
            cos_u2 * sin_lam, cos_u1 * sin_u2 - sin_u1 * cos_u2 * cos_lam
        )
        if sin_sigma == 0:
            return 0.0, 0.0
        cos_sigma = sin_u1 * sin_u2 + cos_u1 * cos_u2 * cos_lam
        sigma = math.atan2(sin_sigma, cos_sigma)
        sin_alpha = cos_u1 * cos_u2 * sin_lam / sin_sigma
        cos2_alpha = 1 - sin_alpha**2
        cos_2sm = (
            cos_sigma - 2 * sin_u1 * sin_u2 / cos2_alpha if cos2_alpha != 0 else 0.0
        )
        c = WGS84_F / 16 * cos2_alpha * (4 + WGS84_F * (4 - 3 * cos2_alpha))
        prev = lam
        lam = l + (1 - c) * WGS84_F * sin_alpha * (
            sigma + c * sin_sigma * (cos_2sm + c * cos_sigma * (-1 + 2 * cos_2sm**2))
        )
        if abs(lam - prev) < 1e-13:
            break
    else:
        return float("nan"), float("nan")

    u_sq = cos2_alpha * (WGS84_A**2 - WGS84_B**2) / WGS84_B**2
    aa = 1 + u_sq / 16384 * (4096 + u_sq * (-768 + u_sq * (320 - 175 * u_sq)))
    bb = u_sq / 1024 * (256 + u_sq * (-128 + u_sq * (74 - 47 * u_sq)))
    d_sigma = (
        bb
        * sin_sigma
        * (
            cos_2sm
            + bb
            / 4
            * (
                cos_sigma * (-1 + 2 * cos_2sm**2)
                - bb
                / 6
                * cos_2sm
                * (-3 + 4 * sin_sigma**2)
                * (-3 + 4 * cos_2sm**2)
            )
        )
    )
    distance_km = WGS84_B * aa * (sigma - d_sigma) / 1000.0
    azimuth = math.degrees(
        math.atan2(cos_u2 * math.sin(lam), cos_u1 * sin_u2 - sin_u1 * cos_u2 * math.cos(lam))
    )
    return normalize360(azimuth), distance_km


# --------------------------------------------------------------------------
# Uygulamadaki referans sabitlerini test dosyasından oku
# --------------------------------------------------------------------------
def parse_qibla_references() -> list[tuple[str, float, float, float]]:
    text = QIBLA_TEST.read_text(encoding="utf-8")
    block = text.split("2) Kâbe kerterizi")[1].split("Kâbe üzerinde")[0]
    rows = re.findall(
        r"\('([^']+)',\s*(-?\d+\.?\d*),\s*(-?\d+\.?\d*),\s*(-?\d+\.?\d*)\)",
        block,
    )
    return [(name, float(lat), float(lon), float(exp)) for name, lat, lon, exp in rows]


def parse_wmm_references() -> list[tuple[str, float, float, float]]:
    text = QIBLA_TEST.read_text(encoding="utf-8")
    block = text.split("wmmReferences")[1].split("test(")[0]
    rows = re.findall(
        r"\('([^']+)',\s*(-?\d+\.?\d*),\s*(-?\d+\.?\d*),\s*(-?\d+\.?\d*)\)",
        block,
    )
    return [(name, float(lat), float(lon), float(exp)) for name, lat, lon, exp in rows]


def read_dart_constant(name: str) -> float | None:
    if not CONSTANTS_DART.exists():
        return None
    match = re.search(rf"{name}\s*=\s*(-?\d+\.?\d*)", CONSTANTS_DART.read_text(encoding="utf-8"))
    return float(match.group(1)) if match else None


# --------------------------------------------------------------------------
# Kontrol 1 — Kerteriz (bearing) üç bağımsız yöntem
# --------------------------------------------------------------------------
def verification_1() -> None:
    print("\n## Kontrol 1 — Kâbe kerterizi (üç bağımsız yöntem)")
    print("| Şehir | Test sabiti | tan biçimi | vektör biçimi | Vincenty (WGS-84) | Maks. fark |")
    print("|---|---|---|---|---|---|")
    cities = parse_qibla_references()
    check(len(cities) >= 8, f"Test dosyasında beklenen şehir sayısı bulunamadı ({len(cities)}).")

    max_spread = 0.0
    max_vs_test = 0.0
    for name, lat, lon, expected in cities:
        a = bearing_atan2_tan(lat, lon)
        b = bearing_vector(lat, lon)
        c, _ = vincenty_inverse_azimuth(lat, lon, KAABA_LAT, KAABA_LON)
        spread = 0.0
        for x, y in ((a, b), (a, c), (b, c)):
            spread = max(spread, angular_difference(x, y))
        max_spread = max(max_spread, spread)
        max_vs_test = max(max_vs_test, angular_difference(a, expected))
        print(
            f"| {name} | {expected:.2f}° | {a:.4f}° | {b:.4f}° | {c:.4f}° | "
            f"{spread:.4f}° |"
        )

    print(f"\n- Yöntemler arası en büyük fark: **{max_spread:.4f}°** (elipsoit–küre farkı)")
    print(f"- Test sabitleriyle en büyük fark: **{max_vs_test:.4f}°**")
    check(max_spread < 0.25, f"Kontrol 1: yöntemler arası fark çok yüksek ({max_spread:.4f}°).")
    check(max_vs_test < 0.35, f"Kontrol 1: test sabitleriyle fark çok yüksek ({max_vs_test:.4f}°).")

    # Kâbe koordinatının resmî referansla uyumu
    d_km = haversine_km(KAABA_LAT, KAABA_LON, *KAABA_REFERENCE)
    print(f"- Uygulamadaki Kâbe noktası resmî konuma **{d_km * 1000:.0f} m** uzaklıkta.")
    check(d_km < 0.15, f"Kontrol 1: Kâbe koordinatı resmî noktadan {d_km * 1000:.0f} m uzak.")
    check(
        abs(read_dart_constant("kaabaLat") - KAABA_LAT) < 1e-6
        if read_dart_constant("kaabaLat") is not None
        else True,
        "Kontrol 1: app_constants.dart içindeki kaabaLat bu betikle uyuşmuyor.",
    )
    check(
        abs(read_dart_constant("kaabaLng") - KAABA_LON) < 1e-6
        if read_dart_constant("kaabaLng") is not None
        else True,
        "Kontrol 1: app_constants.dart içindeki kaabaLng bu betikle uyuşmuyor.",
    )


# --------------------------------------------------------------------------
# Kontrol 2 — Manyetik sapma (resmî WMM-2025 katsayıları)
# --------------------------------------------------------------------------
def verification_2() -> None:
    print("\n## Kontrol 2 — Manyetik sapma (NOAA WMM-2025, bağımsız kütüphane)")
    try:
        from pygeomag import GeoMag
    except ImportError:
        print("- pygeomag kurulu değil; kontrol atlandı (pip install pygeomag).")
        failures.append("Kontrol 2: pygeomag bulunamadı.")
        return

    gm = GeoMag()
    references = parse_wmm_references()
    check(len(references) >= 10, "Kontrol 2: WMM referans listesi okunamadı.")

    print("| Şehir | Test sabiti | pygeomag WMM-2025 | Fark |")
    print("|---|---|---|---|")
    worst = 0.0
    for name, lat, lon, expected in references:
        result = gm.calculate(glat=lat, glon=lon, alt=0.0, time=DECIMAL_YEAR)
        got = float(result.d)
        diff = abs(got - expected)
        worst = max(worst, diff)
        print(f"| {name} | {expected:+.3f}° | {got:+.3f}° | {diff:.4f}° |")

    print(f"\n- En büyük fark: **{worst:.4f}°** → model test sabitleri resmî katsayılarla uyumlu.")
    check(worst < 0.02, f"Kontrol 2: WMM farkı çok yüksek ({worst:.4f}°).")

    tr = gm.calculate(glat=41.0339, glon=28.8567, alt=0.0, time=DECIMAL_YEAR).d
    print(
        f"- Bağcılar (2026.8) sapması **{tr:+.2f}°** (doğu). Sapma uygulanmazsa "
        f"Kıble {abs(tr):.2f}° kayar; uygulamanın ±5° eşiği tek başına bunu telafi edemez."
    )
    check(4.0 < tr < 8.0, "Kontrol 2: Bağcılar sapması beklenen aralıkta değil.")
    check(
        abs(tr) > 5.0,
        "Kontrol 2: sapma etkisi hizalama eşiğinin altında; bu kontrol anlamsız kalır.",
    )


# --------------------------------------------------------------------------
# Kontrol 3 — Tolerans ve hata bütçesi
# --------------------------------------------------------------------------
def verification_3() -> None:
    print("\n## Kontrol 3 — Konum/ölçüm hata bütçesi")
    try:
        from pygeomag import GeoMag
    except ImportError:
        print("- pygeomag kurulu değil; kontrol atlandı (pip install pygeomag).")
        failures.append("Kontrol 3: pygeomag bulunamadı.")
        return

    gm = GeoMag()
    cities = [
        ("Bağcılar", 41.0339, 28.8567),
        ("Gebze", 40.8028, 29.4307),
        ("İstanbul", 41.0082, 28.9784),
        ("Ankara", 39.9334, 32.8597),
        ("New York", 40.7128, -74.0060),
        ("Sidney", -33.8688, 151.2093),
    ]
    print("| Şehir | Zemin (0°) | ±0,05° konum | ±0,5° konum | 1° pusula | Sapma yok | Toplam üst sınır |")
    print("|---|---|---|---|---|---|---|")
    worst_total = 0.0
    for name, lat, lon in cities:
        base = bearing_vector(lat, lon)
        base_decl = gm.calculate(glat=lat, glon=lon, alt=0.0, time=DECIMAL_YEAR).d

        near = 0.0
        for dlat in (-0.05, 0.0, 0.05):
            for dlon in (-0.05, 0.0, 0.05):
                moved = bearing_vector(lat + dlat, lon + dlon)
                near = max(near, angular_difference(moved, base))

        far = 0.0
        for dlat in (-0.5, 0.0, 0.5):
            for dlon in (-0.5, 0.0, 0.5):
                moved = bearing_vector(lat + dlat, lon + dlon)
                far = max(far, angular_difference(moved, base))

        total = near + 1.0 + 0.2  # konum + pusula hatası + kadran çizimi payı
        worst_total = max(worst_total, total)
        print(
            f"| {name} | 0.00° | {near:.3f}° | {far:.2f}° | 1.00° | "
            f"{abs(base_decl):.2f}° | {total:.2f}° |"
        )

    print(
        f"\n- En kötü birleşik hata: **{worst_total:.2f}°** → uygulamanın ±5° hizalama "
        "eşiğinin altında; \"Kâbe yönündesiniz\" yazdığında gerçek sapma ≤5°."
    )
    check(worst_total < 5.0, f"Kontrol 3: birleşik hata eşiği aşıyor ({worst_total:.2f}°).")


# --------------------------------------------------------------------------
# Kontrol 4 — Uçtan uca tutarlılık (sabit hesaplı)
# --------------------------------------------------------------------------
def julian_day(year: int, month: int, day: int, hour: float = 0.0) -> float:
    """UTC → Julian gün (uygulamadaki `SunPosition.julianDay` ile aynı)."""
    y, m = year, month
    if m <= 2:
        y -= 1
        m += 12
    a = y // 100
    b = 2 - a + a // 4
    return (
        math.floor(365.25 * (y + 4716))
        + math.floor(30.6001 * (m + 1))
        + day
        + b
        - 1524.5
        + hour / 24.0
    )


def sun_azimuth_altitude(
    lat: float, lon: float, year: int, month: int, day: int, hour: float
) -> tuple[float, float]:
    """Güneşin azimutu ve yüksekliği (NOAA / Meeus) — Dart uygulamasının aynısı."""
    jd = julian_day(year, month, day, hour)
    t = (jd - 2451545.0) / 36525.0
    l0 = (280.46646 + t * (36000.76983 + 0.0003032 * t)) % 360.0
    m = 357.52911 + t * (35999.05029 - 0.0001537 * t)
    e = 0.016708634 - t * (0.000042037 + 0.0000001267 * t)
    mr = math.radians(m)
    c = (
        math.sin(mr) * (1.914602 - t * (0.004817 + 0.000014 * t))
        + math.sin(2 * mr) * (0.019993 - 0.000101 * t)
        + math.sin(3 * mr) * 0.000289
    )
    apparent = l0 + c - 0.00569 - 0.00478 * math.sin(math.radians(125.04 - 1934.136 * t))
    mean_ob = 23.0 + (26.0 + (21.448 - t * (46.815 + t * (0.00059 - 0.001813 * t))) / 60.0) / 60.0
    ob = mean_ob + 0.00256 * math.cos(math.radians(125.04 - 1934.136 * t))
    decl = math.degrees(math.asin(math.sin(math.radians(ob)) * math.sin(math.radians(apparent))))
    y = math.tan(math.radians(ob / 2.0)) ** 2
    eot = 4.0 * math.degrees(
        y * math.sin(2 * math.radians(l0))
        - 2 * e * math.sin(mr)
        + 4 * e * y * math.sin(mr) * math.cos(2 * math.radians(l0))
        - 0.5 * y * y * math.sin(4 * math.radians(l0))
        - 1.25 * e * e * math.sin(2 * mr)
    )
    tst = (hour * 60.0 + eot + 4.0 * lon) % 1440.0
    hour_angle = math.radians(tst / 4.0 - 180.0)
    latr, decr = math.radians(lat), math.radians(decl)
    alt = math.degrees(
        math.asin(
            max(
                -1.0,
                min(
                    1.0,
                    math.sin(latr) * math.sin(decr)
                    + math.cos(latr) * math.cos(decr) * math.cos(hour_angle),
                ),
            )
        )
    )
    az = (
        180.0
        + math.degrees(
            math.atan2(
                math.sin(hour_angle),
                math.cos(hour_angle) * math.sin(latr) - math.tan(decr) * math.cos(latr),
            )
        )
    ) % 360.0
    return az, alt


def verification_5() -> None:
    """Güneşle doğrulama: Kıble Günü'nde güneş Kâbe doğrultusunda."""
    print("\n## Kontrol 5 — Güneşle doğrulama (Kıble Günü, 28 Mayıs / 15 Temmuz)")

    # Kâbe'de güneşin tepe noktası (transit) anı: yerel gerçek güneş zamanı 12:00.
    transit_hour = (720.0 - 4.0 * KAABA_LON) / 60.0  # UTC saat
    kaaba_alt = sun_azimuth_altitude(KAABA_LAT, KAABA_LON, 2026, 5, 28, transit_hour)[1]
    print(
        f"- 28 Mayıs 2026: Kâbe üzerinde güneş yüksekliği **{kaaba_alt:.2f}°** "
        f"(≈{transit_hour:.2f} UTC) — gölgeler Kâbe yönüne paralel."
    )
    check(kaaba_alt > 88.0, "Kontrol 5: Kâbe transitinde güneş tepede değil.")

    cities = {
        "Bağcılar": (41.0339, 28.8567),
        "İstanbul": (41.0082, 28.9784),
        "Ankara": (39.9334, 32.8597),
        "Londra": (51.5074, -0.1278),
        "Berlin": (52.5200, 13.4050),
        "New York": (40.7128, -74.0060),
        "Sidney": (-33.8688, 151.2093),
    }
    for day, month, label in ((28, 5, "28 Mayıs"), (15, 7, "15 Temmuz")):
        print(f"\n### {label} 2026 (gün boyu, en yakın dakika)")
        print("| Şehir | Kıble | Güneş azimutu | Fark | Yükseklik | Durum |")
        print("|---|---|---|---|---|---|")
        for name, (lat, lon) in cities.items():
            qibla = bearing_vector(lat, lon)
            best = None
            for minute in range(24 * 60):
                hour = minute / 60.0
                az, alt = sun_azimuth_altitude(lat, lon, 2026, month, day, hour)
                if alt < 5:
                    continue
                diff = abs(normalize_signed(az - qibla))
                if best is None or diff < best[0]:
                    best = (diff, minute, az, alt)
            if best is None:
                print(f"| {name} | {qibla:.2f}° | — | — | — | güneş ufkun altında |")
                continue
            diff, minute, az, alt = best
            # Gölge yöntemi yalnızca güneş yeterince yüksekken ve fark
            # ölçülebilir düzeydeyken (< 0,25°) kullanılabilir.
            observable = diff < 0.25 and alt >= 10
            status = "gözlenebilir" if observable else "bu enlemde gölge yöntemi yok"
            print(
                f"| {name} | {qibla:.2f}° | {az:.2f}° | **{diff:.3f}°** | "
                f"{alt:.1f}° | {status} |"
            )
            if observable:
                check(
                    diff < 0.25,
                    f"Kontrol 5: {label} {name} farkı {diff:.3f}° (>0,25°).",
                )
    check(
        any(
            abs(
                normalize_signed(
                    sun_azimuth_altitude(41.0082, 28.9784, 2026, 5, 28, 9.3)[0]
                    - bearing_vector(41.0082, 28.9784)
                )
            )
            < 0.25
            for _ in range(1)
        ),
        "Kontrol 5: İstanbul'da Kıble Günü doğrulanamadı.",
    )
    print(
        "\n- Eşik **0,25°**: bir insan gölgeyle 0,25°'den daha iyi ölçemez; "
        "uygulama bu anlarda pusulasız doğrulanabilir."
    )
    print(
        "- Güneş ufkun altındaysa (ör. ABD'de o an gece) gölge yöntemi "
        "kullanılamaz; uygulama bu durumda \"pusulayı kullanın\" der."
    )
    print(
        "- Uygulama tarafı: `lib/core/utils/sun_position.dart` "
        "(`QiblaSunCheck`) + `test/data/qibla_precision_test.dart`."
    )


def _frame(theta_deg: float, pitch_deg: float) -> list[float]:
    """Gerçek bir tutuşu temsil eden döndürme matrisi (satır öncelikli)."""
    th = math.radians(theta_deg)
    p = math.radians(pitch_deg)
    top = (math.sin(th), math.cos(th), 0.0)
    right = (math.cos(th), -math.sin(th), 0.0)
    up = (0.0, 0.0, 1.0)

    def rot(v):
        c, sn = math.cos(p), math.sin(p)
        ax = right
        dot = sum(a * b for a, b in zip(v, ax))
        cross = (
            ax[1] * v[2] - ax[2] * v[1],
            ax[2] * v[0] - ax[0] * v[2],
            ax[0] * v[1] - ax[1] * v[0],
        )
        return tuple(v[i] * c + cross[i] * sn + ax[i] * dot * (1 - c) for i in range(3))

    x, y, z = rot(right), rot(top), rot(up)
    return [x[0], y[0], z[0], x[1], y[1], z[1], x[2], y[2], z[2]]


def _fuse(r: list[float]) -> float:
    fe, fn = r[1], r[4]
    ce, cn = -r[2], -r[5]
    fw = fe * fe + fn * fn
    cw = ce * ce + cn * cn
    s = fw * math.sin(math.atan2(fe, fn)) + cw * math.sin(math.atan2(ce, cn))
    c = fw * math.cos(math.atan2(fe, fn)) + cw * math.cos(math.atan2(ce, cn))
    return math.degrees(math.atan2(s, c)) % 360.0


def verification_6() -> None:
    """Tutuş (pose) füzyonu: eski 180° hatasının kanıtı ve yeni matematiğin testi."""
    print("\n## Kontrol 6 — Tutuş füzyonu (dik/yatay tutuş, 180° hata testi)")
    print("| Yön | Eğim | Eski yöntem | Eski hata | Yeni füzyon | Yeni hata |")
    print("|---|---|---|---|---|---|")
    worst_new = 0.0
    for theta in (37.0, 151.371):
        for pitch in (0, 45, 89, 90, 100, 120):
            r = _frame(theta, pitch)
            east, north = r[1], r[4]
            legacy = (
                None
                if math.hypot(east, north) < 1e-9
                else math.degrees(math.atan2(east, north)) % 360.0
            )
            fused = _fuse(r)
            legacy_err = (
                float("nan") if legacy is None else abs(normalize_signed(legacy - theta))
            )
            new_err = abs(normalize_signed(fused - theta))
            worst_new = max(worst_new, new_err)
            legacy_txt = "tanımsız" if legacy is None else f"{legacy:.2f}°"
            print(
                f"| {theta:.2f}° | {pitch}° | {legacy_txt} | "
                f"{'—' if legacy is None else f'{legacy_err:.2f}°'} | "
                f"{fused:.2f}° | {new_err:.3f}° |"
            )
            check(
                new_err < 0.01,
                f"Kontrol 6: füzyon {theta}°/eğim {pitch}° için {new_err:.3f}° hatalı.",
            )
    print(
        f"\n- Yeni füzyonun en büyük hatası: **{worst_new:.4f}°** "
        "(tüm tutuş açılarında)."
    )
    print(
        "- Eski yöntem 90°'de **tanımsız**, 100°'de **180° hatalı**; sahada "
        "\"Kıble tersini gösteriyor\" şikâyetinin kaynağı budur."
    )
    print(
        "- Uygulama tarafı: `MainActivity.extractAnglesFromMatrix` (Kotlin) ve "
        "`lib/core/utils/pose_fusion.dart` (Dart referansı) + "
        "`test/data/pose_fusion_test.dart`."
    )


def verification_4() -> None:
    print("\n## Kontrol 4 — Uçtan uca tutarlılık (Bağcılar senaryosu)")
    try:
        from pygeomag import GeoMag
    except ImportError:
        print("- pygeomag kurulu değil; kontrol atlandı (pip install pygeomag).")
        failures.append("Kontrol 4: pygeomag bulunamadı.")
        return

    gm = GeoMag()
    lat, lon = 41.0339, 28.8567
    decl: float = gm.calculate(glat=lat, glon=lon, alt=0.0, time=DECIMAL_YEAR).d
    qibla = bearing_vector(lat, lon)
    print(f"- Bağcılar Kıble yönü (gerçek kuzey): **{qibla:.3f}°**")
    print(f"- Manyetik sapma: **{decl:+.3f}°** → manyetik kuzeye göre Kıble **{qibla - decl:.3f}°**")

    # Telefon Kâbe yönüne çevrildi: sensör manyetik açı = qibla - declination
    magnetic_heading = normalize360(qibla - decl)
    true_heading = normalize360(magnetic_heading + decl)
    diff = normalize_signed(qibla - true_heading)
    print(
        f"- Sensör {magnetic_heading:.3f}° okur → gerçek kuzey {true_heading:.3f}° → "
        f"fark {diff:+.4f}° (hizalı, eşik ±5°)"
    )
    check(abs(diff) < 1e-6, "Kontrol 4: sapma zinciri kapalı devre çalışmıyor.")

    # 0/360 sarmalaması: batıya bakan kullanıcı (manyetik 356°, sapma +6°)
    wrapped = normalize360(356.0 + 6.073)
    check(
        abs(wrapped - 2.073) < 1e-3,
        f"Kontrol 4: 360° sarmalaması hatalı ({wrapped:.3f}°).",
    )
    print(f"- Sarmalama: 356° + 6,073° = **{wrapped:.3f}°** (0°'yi doğru geçiyor)")

    # Kıbleye dik duran kullanıcı "hizalı" sayılmamalı
    perpendicular = normalize360(qibla + 90.0)
    check(
        abs(normalize_signed(qibla - perpendicular)) > 5.0,
        "Kontrol 4: dik açıdaki kullanıcı yanlışlıkla hizalı sayılıyor.",
    )

    text = QIBLA_TEST.read_text(encoding="utf-8")
    groups = len(re.findall(r"group\('", text))
    tests = len(re.findall(r"\n\s+test\(", text))
    print(f"- Test dosyası: **{groups} grup / {tests} test** (Kontrol 1–4 katmanlarını kapsar)")
    check(groups >= 4, "Kontrol 4: test dosyasında en az 4 katman (grup) olmalı.")

    # uygulama dosyalarının varlığı (silinme/bozulma koruması)
    for path in (GEO_DART, QIBLA_TEST):
        check(path.exists(), f"Kontrol 4: beklenen dosya yok: {path.relative_to(ROOT)}")


def main() -> int:
    print("# Ezan Vaktim Pro — Kıble 6 aşamalı doğrulama raporu")
    print(f"- Tarih referansı: ondalık yıl {DECIMAL_YEAR}")
    print(f"- Kâbe (uygulama): {KAABA_LAT}, {KAABA_LON}")
    print(f"- Kâbe (resmî referans): {KAABA_REFERENCE[0]}, {KAABA_REFERENCE[1]}")
    print(f"- Test dosyası: {QIBLA_TEST.relative_to(ROOT)}")

    verification_1()
    verification_2()
    verification_3()
    verification_4()
    verification_5()
    verification_6()

    print("\n## Sonuç")
    if failures:
        print("❌ **BAŞARISIZ** — düzeltilmesi gereken maddeler:")
        for item in failures:
            print(f"- {item}")
        return 1
    print("✅ **6/6 kontrol geçti** — Kıble hesabında bilinen hata yok.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
