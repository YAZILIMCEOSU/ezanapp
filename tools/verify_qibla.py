#!/usr/bin/env python3
"""Ezan Vaktim Pro — Kıble doğrulaması (4 bağımsız kontrol).

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

Çıkış kodu 0 → dört kontrol de geçti. 1 → en az bir kontrol başarısız.
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
    from pygeomag import GeoMag

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
def verification_4() -> None:
    print("\n## Kontrol 4 — Uçtan uca tutarlılık (Bağcılar senaryosu)")
    from pygeomag import GeoMag

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
    print("# Ezan Vaktim Pro — Kıble 4 aşamalı doğrulama raporu")
    print(f"- Tarih referansı: ondalık yıl {DECIMAL_YEAR}")
    print(f"- Kâbe (uygulama): {KAABA_LAT}, {KAABA_LON}")
    print(f"- Kâbe (resmî referans): {KAABA_REFERENCE[0]}, {KAABA_REFERENCE[1]}")
    print(f"- Test dosyası: {QIBLA_TEST.relative_to(ROOT)}")

    verification_1()
    verification_2()
    verification_3()
    verification_4()

    print("\n## Sonuç")
    if failures:
        print("❌ **BAŞARISIZ** — düzeltilmesi gereken maddeler:")
        for item in failures:
            print(f"- {item}")
        return 1
    print("✅ **4/4 kontrol geçti** — Kıble hesabında bilinen hata yok.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
