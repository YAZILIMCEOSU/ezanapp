#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Ezan Vaktim Pro — harici kütüphane gerektirmeyen (saf Python + SDF yumuşatma)
Altın Mihrap Kemeri + Gün Batımı Cami Silüeti + Hilal & Yıldız launcher/store ikon üreticisi.

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

NAVY_DEEP = (6, 20, 39)
NAVY_MID = (12, 34, 61)
GOLD_LIGHT = (248, 214, 138)
GOLD_MID = (218, 172, 92)
GOLD_DARK = (158, 114, 48)
SUNSET_CORE = (255, 196, 98)
SUNSET_ORANGE = (224, 132, 54)
SILHOUETTE = (7, 22, 40)


def clamp(v: float, lo: float = 0.0, hi: float = 1.0) -> float:
    return lo if v < lo else (hi if v > hi else v)


def smoothstep(edge0: float, edge1: float, x: float) -> float:
    t = clamp((x - edge0) / (edge1 - edge0)) if edge1 != edge0 else 0.0
    return t * t * (3.0 - 2.0 * t)


def lerp_rgb(c1, c2, t: float):
    t = clamp(t)
    return (
        c1[0] + (c2[0] - c1[0]) * t,
        c1[1] + (c2[1] - c1[1]) * t,
        c1[2] + (c2[2] - c1[2]) * t,
    )


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


def arch_half_width(y: float, top_peak: float = -0.355, shoulder_y: float = -0.020, col_hw: float = 0.258) -> float:
    """Klasik İslami sivri mihrap kemerinin y koordinatına göre yarı genişliği."""
    if y < top_peak:
        return -1.0
    if y >= 0.025:
        return col_hw
    if y >= shoulder_y:
        t = (y - shoulder_y) / (0.025 - shoulder_y)
        return (col_hw - 0.022) + 0.022 * smoothstep(0.0, 1.0, t)
    # Sivri kemer (top_peak tepe noktasında tam 0'a kavuşur, omuzda col_hw - 0.022 olur)
    t = clamp((y - top_peak) / (shoulder_y - top_peak))
    return (col_hw - 0.022) * math.sin(t * math.pi * 0.5) ** 0.78


def sample_emblem(nx: float, ny: float, aa: float, scale: float = 1.0):
    """Fotoğraf 1'deki Altın Mihrap Kemeri + Gün Batımı Işıltısı +
    Çift Minareli Cami Silüeti + Altın Hilal & 4 Köşeli Yıldız tasarımını üretir.
    """
    x = nx / scale
    y = ny / scale
    eps = aa / scale
    ax = abs(x)
    col = (0.0, 0.0, 0.0, 0.0)

    top_y = -0.355
    top_outer = -0.405
    bot_y = 0.340
    frame_thick = 0.036

    inner_hw = arch_half_width(y, top_peak=top_y, shoulder_y=-0.020, col_hw=0.256)
    outer_hw = arch_half_width(y, top_peak=top_outer, shoulder_y=-0.032, col_hw=0.256 + frame_thick)

    # İç kemer alanı
    in_inner = (top_y <= y <= bot_y) and (ax <= inner_hw)
    d_inner = max(ax - inner_hw, top_y - y, y - bot_y)
    inner_a = 1.0 - smoothstep(-eps, eps, d_inner)

    if inner_a > 0.0:
        # 1. Gece gökyüzü + Cami arkası sıcak gün batımı ışıltısı
        sky_t = clamp((y - top_y) / (bot_y - top_y))
        sky_rgb = lerp_rgb(NAVY_DEEP, NAVY_MID, sky_t)

        # Gün batımı radyal parlaması (merkez: 0.0, +0.16)
        glow_d = math.hypot(x * 1.15, (y - 0.165) * 1.35)
        glow_core = clamp(1.0 - glow_d / 0.26) ** 1.6
        glow_wide = clamp(1.0 - glow_d / 0.42) ** 2.0
        sky_rgb = lerp_rgb(sky_rgb, SUNSET_ORANGE, glow_wide * 0.82)
        sky_rgb = lerp_rgb(sky_rgb, SUNSET_CORE, glow_core * 0.92)

        # 2. Uzak tepeler (silüet katmanı)
        hill_y = 0.215 + 0.025 * math.sin(x * 9.0 + 0.6) - 0.045 * (ax / 0.26)
        if y >= hill_y - eps:
            hill_a = smoothstep(hill_y - eps, hill_y + eps, y)
            sky_rgb = lerp_rgb(sky_rgb, (26, 42, 62), hill_a * 0.68)

        # 3. Cami silüeti (Ana kubbe + 2 yan kubbe + 2 omuz kubbesi + 2 ince minare + alem)
        mosque_d = 1.0
        base_floor = 0.255
        # Alt gövde
        mosque_d = min(mosque_d, sd_box(x, y - 0.295, 0.24, 0.050))
        # Ana kubbe
        main_dome = max(math.hypot(x, (y - 0.242) * 1.08) - 0.074, y - 0.255)
        mosque_d = min(mosque_d, main_dome)
        # Ana kubbe alemi (ince direk + minik hilal)
        finial_d = sd_box(x, y - 0.156, 0.0028, 0.016)
        mosque_d = min(mosque_d, finial_d)
        # Yan kubbeler (±0.088)
        side_dome = max(math.hypot(ax - 0.088, (y - 0.252) * 1.12) - 0.036, y - 0.265)
        mosque_d = min(mosque_d, side_dome)
        # Dış küçük kubbeler (±0.168)
        outer_dome = max(math.hypot(ax - 0.168, (y - 0.268) * 1.15) - 0.022, y - 0.280)
        mosque_d = min(mosque_d, outer_dome)

        # Çift minare (±0.140)
        min_x = 0.140
        # Minare gövdesi
        min_shaft = sd_box(ax - min_x, y - 0.178, 0.0095, 0.095)
        # Şerefeler (2 adet)
        balc1 = sd_box(ax - min_x, y - 0.125, 0.0145, 0.0045)
        balc2 = sd_box(ax - min_x, y - 0.168, 0.0135, 0.0045)
        mosque_d = min(mosque_d, min_shaft, balc1, balc2)
        # Minare külahı (sivri tepe: 0.055 .. 0.095)
        if 0.048 <= y <= 0.095:
            t_sp = clamp((y - 0.052) / 0.043)
            sp_d = abs(ax - min_x) - (0.0095 * t_sp + 0.001)
            mosque_d = min(mosque_d, sp_d)

        mosque_a = 1.0 - smoothstep(-eps, eps, mosque_d)
        if mosque_a > 0.0:
            sky_rgb = lerp_rgb(sky_rgb, SILHOUETTE, mosque_a)

        # 4. Gökyüzünde zarif Altın Hilal + 4 köşeli parlak yıldız
        mcx, mcy = -0.004, -0.105
        mr = 0.102
        ccx, ccy = mcx + 0.032, mcy - 0.022
        cr = 0.091
        d_cresc = max(math.hypot(x - mcx, y - mcy) - mr, -(math.hypot(x - ccx, y - ccy) - cr))
        cresc_a = 1.0 - smoothstep(-eps, eps, d_cresc)
        if cresc_a > 0.0:
            gt = clamp((-0.02 - y) / 0.18)
            c_rgb = lerp_rgb(GOLD_MID, GOLD_LIGHT, gt)
            sky_rgb = lerp_rgb(sky_rgb, c_rgb, cresc_a)

        # 4 köşeli ışıltı yıldızı (hilalin ortasında)
        sx, sy = abs(x - 0.002), abs(y - (-0.112))
        d_star4 = (sx ** 0.55 + sy ** 0.55) - (0.017 ** 0.55)
        star_a = 1.0 - smoothstep(-eps, eps, d_star4)
        if star_a > 0.0:
            sky_rgb = lerp_rgb(sky_rgb, GOLD_LIGHT, star_a)

        col = blend_rgba(col, sky_rgb, inner_a)

    # 5. 3B Altın Mihrap Kemeri Çerçevesi
    d_outer = max(ax - outer_hw, top_outer - y, y - bot_y)
    d_frame = max(d_outer, -d_inner)
    frame_a = 1.0 - smoothstep(-eps, eps, d_frame)
    if frame_a > 0.0:
        # 3B bevel / altın ışık-gölge geçişi
        bevel = clamp(0.5 + (inner_hw + frame_thick * 0.5 - ax) / frame_thick)
        vert_shine = clamp(1.0 - (y - top_outer) / (bot_y - top_outer))
        gold_col = lerp_rgb(GOLD_DARK, GOLD_MID, bevel)
        gold_col = lerp_rgb(gold_col, GOLD_LIGHT, vert_shine * 0.55 + (1.0 - abs(bevel - 0.5) * 2.0) * 0.35)
        col = blend_rgba(col, gold_col, frame_a)

    return col


def render_image(size: int, with_background: bool, rounded_corners: bool, scale: float) -> bytes:
    aa = 1.25 / size
    rows = []
    for py in range(size):
        ny = (py + 0.5) / size - 0.5
        row = bytearray()
        row.append(0)
        for px in range(size):
            nx = (px + 0.5) / size - 0.5
            if with_background:
                dist = math.hypot(nx, ny) / 0.70710678
                t = clamp(dist ** 1.35)
                bg = (
                    NAVY_MID[0] + (NAVY_DEEP[0] - NAVY_MID[0]) * t,
                    NAVY_MID[1] + (NAVY_DEEP[1] - NAVY_MID[1]) * t,
                    NAVY_MID[2] + (NAVY_DEEP[2] - NAVY_MID[2]) * t,
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
            render_image(size, with_background=False, rounded_corners=False, scale=0.68),
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
    print('Ezan Vaktim Pro mihrap ikonları başarıyla üretildi.')


if __name__ == '__main__':
    main()
