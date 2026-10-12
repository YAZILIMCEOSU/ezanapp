#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Ezan Vaktim Pro — harici kütüphane gerektirmeyen (saf Python + SDF yumuşatma)
akılda kalıcı launcher/store ikon üreticisi.

Çalıştırma: python3 tools/design/make_icons.py
"""
from __future__ import annotations

import math
import os
import struct
import zlib

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
RES = os.path.join(ROOT, 'android', 'app', 'src', 'main', 'res')
STORE = os.path.join(ROOT, 'store')
IMAGES = os.path.join(ROOT, 'assets', 'images')

EMERALD_DARK = (6, 36, 31)
EMERALD_MID = (11, 62, 52)
EMERALD_LIGHT = (19, 98, 82)
GOLD_BRIGHT = (244, 208, 128)
GOLD = (226, 186, 106)
CREAM = (252, 248, 238)


def clamp(v: float, lo: float = 0.0, hi: float = 1.0) -> float:
    return lo if v < lo else (hi if v > hi else v)


def smoothstep(edge0: float, edge1: float, x: float) -> float:
    t = clamp((x - edge0) / (edge1 - edge0)) if edge1 != edge0 else 0.0
    return t * t * (3.0 - 2.0 * t)


def blend_rgba(dst, src_rgb, src_a: float):
    if src_a <= 0.0:
        return dst
    if src_a >= 1.0:
        return (src_rgb[0], src_rgb[1], src_rgb[2], 1.0)
    dr, dg, db, da = dst
    out_a = src_a + da * (1.0 - src_a)
    if out_a <= 1e-6:
        return (0.0, 0.0, 0.0, 0.0)
    r = (src_rgb[0] * src_a + dr * da * (1.0 - src_a)) / out_a
    g = (src_rgb[1] * src_a + dg * da * (1.0 - src_a)) / out_a
    b = (src_rgb[2] * src_a + db * da * (1.0 - src_a)) / out_a
    return (r, g, b, out_a)


def sd_box(px: float, py: float, bx: float, by: float) -> float:
    dx = abs(px) - bx
    dy = abs(py) - by
    return math.hypot(max(dx, 0.0), max(dy, 0.0)) + min(max(dx, dy), 0.0)


def sd_rounded_box(px: float, py: float, bx: float, by: float, r: float) -> float:
    return sd_box(px, py, bx - r, by - r) - r


def sd_star5(px: float, py: float, r: float, rf: float = 0.44) -> float:
    ang = math.atan2(px, -py)
    sector = math.pi / 5.0
    a = ((ang + math.pi) % (2.0 * sector)) - sector
    a = abs(a)
    # 5 köşeli yıldız kenarına mesafe
    p0x, p0y = 0.0, -r
    p1x, p1y = r * rf * math.sin(sector), -r * rf * math.cos(sector)
    qx, qy = math.hypot(px, py) * math.sin(a), -math.hypot(px, py) * math.cos(a)
    ex, ey = p1x - p0x, p1y - p0y
    wx, wy = qx - p0x, qy - p0y
    t = clamp((wx * ex + wy * ey) / (ex * ex + ey * ey))
    dx, dy = wx - ex * t, wy - ey * t
    sgn = 1.0 if (wx * ey - wy * ex) > 0.0 else -1.0
    return math.hypot(dx, dy) * sgn


def sample_emblem(nx: float, ny: float, aa: float, scale: float = 1.0):
    """Normalized coordinate (-0.5..0.5, -0.5..0.5) üzerinde Ezan Vaktim Pro
    armasını (Selçuklu 8 köşeli yıldız + altın hilal + zarif minare ve kubbe +
    5 köşeli yıldız + ezan ses dalgası yayları) SDF ile hesaplar.
    """
    x = nx / scale
    y = ny / scale
    eps = aa / scale
    col = (0.0, 0.0, 0.0, 0.0)

    # 1. Selçuklu 8 köşeli yıldızı (iki kare: 0° ve 45° döndürülmüş)
    s_half = 0.275
    d_sq1 = sd_rounded_box(x, y, s_half, s_half, 0.018)
    rx = (x - y) * 0.70710678
    ry = (x + y) * 0.70710678
    d_sq2 = sd_rounded_box(rx, ry, s_half, s_half, 0.018)
    d_rub = min(d_sq1, d_sq2)

    # Selçuklu yıldızı iç dolgusu ve altın çerçevesi
    fill_a = 1.0 - smoothstep(-eps, eps, d_rub)
    if fill_a > 0.0:
        col = blend_rgba(col, EMERALD_MID, fill_a * 0.88)

    border_d = abs(d_rub) - 0.0085
    border_a = 1.0 - smoothstep(-eps, eps, border_d)
    if border_a > 0.0:
        col = blend_rgba(col, GOLD_BRIGHT, border_a * 0.88)

    # İç dairesel altın halka
    r_center = math.hypot(x, y)
    ring_d = abs(r_center - 0.238) - 0.0045
    ring_a = 1.0 - smoothstep(-eps, eps, ring_d)
    if ring_a > 0.0:
        col = blend_rgba(col, GOLD, ring_a * 0.55)

    # 2. Büyük Altın Hilal (sol-merkez odak)
    mcx, mcy = -0.025, -0.008
    mr = 0.168
    ccx, ccy = mcx + 0.066, mcy - 0.012
    cr = 0.152
    d_outer = math.hypot(x - mcx, y - mcy) - mr
    d_cut = math.hypot(x - ccx, y - ccy) - cr
    d_crescent = max(d_outer, -d_cut)
    cres_a = 1.0 - smoothstep(-eps, eps, d_crescent)
    if cres_a > 0.0:
        # Hilal üzerinde hafif dikey altın parlaklık geçişi
        gt = clamp((0.18 - y) / 0.36)
        c_rgb = (
            GOLD[0] + (GOLD_BRIGHT[0] - GOLD[0]) * gt,
            GOLD[1] + (GOLD_BRIGHT[1] - GOLD[1]) * gt,
            GOLD[2] + (GOLD_BRIGHT[2] - GOLD[2]) * gt,
        )
        col = blend_rgba(col, c_rgb, cres_a)

    # 3. Kubbe (alt-merkez) ve Minare (sağ-iç) silüeti
    base_y = 0.125
    # Kubbe yarım dairesi
    dcx, dcy = 0.005, base_y
    dr = 0.078
    d_dome = max(math.hypot(x - dcx, (y - dcy) * 1.12) - dr, y - dcy)
    dome_a = 1.0 - smoothstep(-eps, eps, d_dome)
    if dome_a > 0.0:
        col = blend_rgba(col, GOLD, dome_a)

    # Alt kaide çizgisi
    d_base = sd_rounded_box(x - 0.015, y - (base_y + 0.005), 0.135, 0.010, 0.005)
    base_a = 1.0 - smoothstep(-eps, eps, d_base)
    if base_a > 0.0:
        col = blend_rgba(col, GOLD_BRIGHT, base_a)

    # Zarif Minare (sağ taraf)
    min_x = 0.098
    d_shaft = sd_rounded_box(x - min_x, y - 0.012, 0.016, 0.112, 0.004)
    shaft_a = 1.0 - smoothstep(-eps, eps, d_shaft)
    if shaft_a > 0.0:
        col = blend_rgba(col, CREAM, shaft_a)

    # Minare şerefesi
    d_balcony = sd_rounded_box(x - min_x, y - (-0.072), 0.026, 0.008, 0.003)
    balc_a = 1.0 - smoothstep(-eps, eps, d_balcony)
    if balc_a > 0.0:
        col = blend_rgba(col, GOLD_BRIGHT, balc_a)

    # Minare külahı (üçgen tepe)
    spire_top = -0.148
    spire_bot = -0.095
    if spire_top - eps <= y <= spire_bot + eps:
        t_spire = clamp((y - spire_top) / (spire_bot - spire_top))
        half_w = 0.017 * t_spire
        d_spire = max(abs(x - min_x) - half_w, spire_top - y, y - spire_bot)
        spire_a = 1.0 - smoothstep(-eps, eps, d_spire)
        if spire_a > 0.0:
            col = blend_rgba(col, GOLD_BRIGHT, spire_a)

    # 4. Hilal kucağında parlak 5 köşeli yıldız
    sx, sy = 0.022, -0.055
    d_star = sd_star5(x - sx, y - sy, 0.046, 0.43)
    star_a = 1.0 - smoothstep(-eps, eps, d_star)
    if star_a > 0.0:
        col = blend_rgba(col, CREAM, star_a)

    # 5. Minare tepesinden yayılan 2 altın Ezan ses dalgası yayı
    ax = x - (min_x + 0.012)
    ay = y - (-0.125)
    ar = math.hypot(ax, ay)
    a_ang = math.atan2(ay, ax)
    if -1.15 <= a_ang <= 0.45:
        for arc_r, alpha_mul in ((0.048, 0.92), (0.076, 0.65)):
            d_arc = abs(ar - arc_r) - 0.0055
            arc_a = 1.0 - smoothstep(-eps, eps, d_arc)
            if arc_a > 0.0:
                col = blend_rgba(col, GOLD_BRIGHT, arc_a * alpha_mul)

    return col


def render_image(size: int, with_background: bool, rounded_corners: bool, scale: float) -> bytes:
    aa = 1.25 / size
    rows = []
    for py in range(size):
        ny = (py + 0.5) / size - 0.5
        row = bytearray()
        row.append(0)  # PNG filter type 0
        for px in range(size):
            nx = (px + 0.5) / size - 0.5
            if with_background:
                dist = math.hypot(nx, ny) / 0.70710678
                t = clamp(dist ** 1.35)
                bg = (
                    EMERALD_LIGHT[0] + (EMERALD_DARK[0] - EMERALD_LIGHT[0]) * t,
                    EMERALD_LIGHT[1] + (EMERALD_DARK[1] - EMERALD_LIGHT[1]) * t,
                    EMERALD_LIGHT[2] + (EMERALD_DARK[2] - EMERALD_LIGHT[2]) * t,
                    1.0,
                )
                em = sample_emblem(nx, ny, aa, scale)
                col = blend_rgba(bg, (em[0], em[1], em[2]), em[3])
                if rounded_corners:
                    d_rr = sd_rounded_box(nx, ny, 0.5, 0.5, 0.22)
                    mask_a = 1.0 - smoothstep(-aa, aa, d_rr)
                    col = (col[0], col[1], col[2], col[3] * mask_a)
            else:
                col = sample_emblem(nx, ny, aa, scale)

            r = int(clamp(col[0], 0.0, 255.0) + 0.5)
            g = int(clamp(col[1], 0.0, 255.0) + 0.5)
            b = int(clamp(col[2], 0.0, 255.0) + 0.5)
            a = int(clamp(col[3], 0.0, 1.0) * 255.0 + 0.5)
            row.extend((r, g, b, a))
        rows.append(bytes(row))
    return write_png(size, size, b''.join(rows))


def write_png(width: int, height: int, raw_scanlines: bytes) -> bytes:
    def chunk(tag: bytes, data: bytes) -> bytes:
        crc = zlib.crc32(tag + data) & 0xFFFFFFFF
        return struct.pack('>I', len(data)) + tag + data + struct.pack('>I', crc)

    ihdr = struct.pack('>IIBBBBB', width, height, 8, 6, 0, 0, 0)
    idat = zlib.compress(raw_scanlines, level=9)
    return b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', ihdr) + chunk(b'IDAT', idat) + chunk(b'IEND', b'')


def save_file(path: str, data: bytes) -> None:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'wb') as f:
        f.write(data)


def main() -> None:
    densities = {
        'mdpi': 48,
        'hdpi': 72,
        'xhdpi': 96,
        'xxhdpi': 144,
        'xxxhdpi': 192,
    }
    for name, size in densities.items():
        out_dir = os.path.join(RES, f'mipmap-{name}')
        save_file(
            os.path.join(out_dir, 'ic_launcher.png'),
            render_image(size, with_background=True, rounded_corners=False, scale=1.0),
        )
        save_file(
            os.path.join(out_dir, 'ic_launcher_round.png'),
            render_image(size, with_background=True, rounded_corners=True, scale=1.0),
        )
        save_file(
            os.path.join(out_dir, 'ic_launcher_foreground.png'),
            render_image(size, with_background=False, rounded_corners=False, scale=0.66),
        )

    # Splash ve Play Store ikonu (512x512)
    icon_512 = render_image(512, with_background=True, rounded_corners=False, scale=1.0)
    save_file(os.path.join(RES, 'drawable', 'splash_logo.png'), icon_512)
    save_file(os.path.join(STORE, 'play_icon_512.png'), icon_512)

    # Arayüz içi şeffaf zeminli logo işareti
    save_file(
        os.path.join(IMAGES, 'logo_mark.png'),
        render_image(512, with_background=False, rounded_corners=False, scale=0.92),
    )
    save_file(
        os.path.join(IMAGES, 'logo_mark_small.png'),
        render_image(256, with_background=False, rounded_corners=False, scale=0.92),
    )
    print('Ezan Vaktim Pro ikonları başarıyla üretildi.')


if __name__ == '__main__':
    main()
