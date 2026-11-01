#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Ezan Vaktim Pro — harici kütüphane gerektirmeyen (saf Python + SDF yumuşatma)
Turkuvaz Işık Hüzmeli Zemin + Beyaz Kubbeli Çift Minareli Cami + Hilal Alemi + Altın/Beyaz PRO Rozetli
launcher ve Play Store ikon üreticisi.

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

TURQ_DEEP = (0, 68, 82)       # #004452
TURQ_MID = (0, 134, 152)     # #008698
TURQ_BRIGHT = (28, 194, 212) # #1CC2D4
TURQ_GLOW = (142, 238, 248)  # #8EEEF8
WHITE_PURE = (255, 255, 255)
WHITE_SOFT = (232, 247, 250)
GOLD_LIGHT = (255, 224, 130)
GOLD_MID = (242, 184, 72)


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


def sd_arch(px: float, py: float, hw: float, hh: float) -> float:
    """Üstü yarım daire kemerli, altı dikdörtgen pencere/kapı SDF fonksiyonu."""
    if py < 0.0:
        return math.hypot(px, py) - hw
    return sd_box(px, py - hh * 0.5, hw, hh * 0.5)


def sample_mosque_emblem(nx: float, ny: float, aa: float, scale: float = 1.0):
    """Beyaz Cami Silüeti (Ana kubbe + hilal alem + 2 yan kubbe + 2 çift şerefeli minare +
    kemerli pencereler + telefon/tablette net okunaklı büyük altın PRO rozeti) üretir.
    """
    x = nx / scale
    y = (ny / scale) + 0.045  # Camiyi hafif yukarı al ki alttaki büyük PRO rozeti tam otursun
    eps = aa / scale
    ax = abs(x)
    col = (0.0, 0.0, 0.0, 0.0)

    # 1. Cami ana beyaz silüeti SDF birleşimi
    # Alt mermer kaide ve ana gövde
    plinth = sd_rounded_box(x, y - 0.235, 0.318, 0.022, 0.010)
    body = sd_rounded_box(x, y - 0.155, 0.258, 0.072, 0.012)
    # Kubbe kasnağı (ana gövde ile kubbeyi kesintisiz birleştirir)
    drum = sd_rounded_box(x, y - 0.064, 0.162, 0.040, 0.008)

    # Ana kubbe (merkez: 0.0, 0.042 — kasnağa tam oturur)
    main_dome = max(math.hypot(x * 0.95, (y - 0.042) * 1.02) - 0.156, y - 0.045)

    # Yan kubbeler (±0.188, y = 0.092 — gövdeye tam oturur)
    side_dome = max(math.hypot(ax - 0.188, (y - 0.092) * 1.05) - 0.066, y - 0.095)

    # Ana kubbe üstü hilal alemi (direk + yukarı bakan zarif hilal)
    finial_pole = sd_box(x, y - (-0.132), 0.006, 0.028)
    finial_ball = math.hypot(x, y - (-0.128)) - 0.011
    c_outer = math.hypot(x, y - (-0.172)) - 0.028
    c_inner = math.hypot(x, y - (-0.182)) - 0.022
    finial_crescent = max(c_outer, -c_inner)

    mosque_d = min(
        plinth,
        body,
        drum,
        main_dome,
        side_dome,
        finial_pole,
        finial_ball,
        finial_crescent,
    )

    # Çift Minare (±0.286)
    min_x = 0.286
    min_base = sd_box(ax - min_x, y - 0.138, 0.026, 0.090)
    min_shaft = sd_box(ax - min_x, y - (-0.035), 0.019, 0.180)
    balc1 = sd_rounded_box(ax - min_x, y - (-0.025), 0.033, 0.009, 0.004)
    balc2 = sd_rounded_box(ax - min_x, y - (-0.125), 0.031, 0.009, 0.004)
    mosque_d = min(mosque_d, min_base, min_shaft, balc1, balc2)

    # Minare sivri külahı (y: -0.315 .. -0.215)
    if -0.325 <= y <= -0.210:
        t_sp = clamp((y - (-0.315)) / 0.100)
        cone_hw = 0.019 * t_sp + 0.0015
        cone_d = max(abs(ax - min_x) - cone_hw, -0.315 - y, y - (-0.215))
        mosque_d = min(mosque_d, cone_d)
    min_finial = sd_box(ax - min_x, y - (-0.332), 0.004, 0.018)
    mosque_d = min(mosque_d, min_finial)

    # 2. Gövde içi kemerli kapı ve pencere boşlukları (kesintisiz kemer SDF)
    door_arch = sd_arch(x, y - 0.148, 0.036, 0.074)
    win1 = sd_arch(ax - 0.105, y - 0.155, 0.020, 0.048)
    win2 = sd_arch(ax - 0.188, y - 0.160, 0.018, 0.044)
    uwin0 = math.hypot(x, y - 0.065) - 0.011
    uwin1 = math.hypot(ax - 0.052, y - 0.065) - 0.010
    uwin2 = math.hypot(ax - 0.104, y - 0.065) - 0.010
    cutout_d = min(door_arch, win1, win2, uwin0, uwin1, uwin2)

    final_mosque_d = max(mosque_d, -cutout_d)

    mosque_a = 1.0 - smoothstep(-eps, eps, final_mosque_d)
    if mosque_a > 0.0:
        w_t = clamp((y - (-0.32)) / 0.62)
        w_rgb = lerp_rgb(WHITE_PURE, WHITE_SOFT, w_t * 0.35)
        col = blend_rgba(col, w_rgb, mosque_a)

    # 3. Alt merkezde telefon ve tablette %100 okunaklı büyük "PRO" rozeti
    by_center = 0.350
    badge_outer = sd_rounded_box(x, y - by_center, 0.285, 0.086, 0.042)
    badge_outer_a = 1.0 - smoothstep(-eps, eps, badge_outer)
    if badge_outer_a > 0.0:
        # Koyu turkuvaz dış kontur + parlak altın rozet dolgusu
        col = blend_rgba(col, TURQ_DEEP, badge_outer_a)
        badge_inner = sd_rounded_box(x, y - by_center, 0.268, 0.070, 0.034)
        badge_inner_a = 1.0 - smoothstep(-eps, eps, badge_inner)
        if badge_inner_a > 0.0:
            b_rgb = lerp_rgb((255, 232, 138), (245, 178, 42), clamp((y - (by_center - 0.07)) / 0.14))
            col = blend_rgba(col, b_rgb, badge_inner_a)

        # Kalın ve yüksek kontrastlı "P R O" blok harfleri
        px_b = x
        py_b = y - by_center
        # P harfi (merkez x = -0.148)
        px_p = px_b - (-0.148)
        p_stem = sd_box(px_p - (-0.032), py_b, 0.012, 0.044)
        p_bowl_out = sd_rounded_box(px_p - 0.004, py_b - (-0.016), 0.036, 0.028, 0.014)
        p_bowl_in = sd_rounded_box(px_p - 0.002, py_b - (-0.016), 0.016, 0.010, 0.004)
        p_d = min(p_stem, max(p_bowl_out, -p_bowl_in))

        # R harfi (merkez x = -0.002)
        px_r = px_b - (-0.002)
        r_stem = sd_box(px_r - (-0.032), py_b, 0.012, 0.044)
        r_bowl_out = sd_rounded_box(px_r - 0.004, py_b - (-0.016), 0.036, 0.028, 0.014)
        r_bowl_in = sd_rounded_box(px_r - 0.002, py_b - (-0.016), 0.016, 0.010, 0.004)
        # R sağ alt çapraz bacağı
        r_leg = sd_box(px_r - 0.010 - max(py_b, 0.0) * 0.52, py_b - 0.022, 0.012, 0.022)
        r_d = min(r_stem, max(r_bowl_out, -r_bowl_in), r_leg)

        # O harfi (merkez x = +0.146)
        px_o = px_b - 0.146
        o_out = sd_rounded_box(px_o, py_b, 0.042, 0.044, 0.022)
        o_in = sd_rounded_box(px_o, py_b, 0.018, 0.022, 0.010)
        o_d = max(o_out, -o_in)

        txt_d = min(p_d, r_d, o_d)
        txt_a = 1.0 - smoothstep(-eps, eps, txt_d)
        if txt_a > 0.0:
            col = blend_rgba(col, (0, 48, 60), txt_a)

    return col


def sample_turquoise_background(nx: float, ny: float, aa: float):
    """Fotoğraf 1'deki canlı Turkuvaz gradyan + sol üstten diyagonal ışık hüzmeleri +
    parlak çerçeve efektini üretir.
    """
    # Sol üstten (-0.5, -0.5) sağ alta (+0.5, +0.5) diyagonal turkuvaz geçiş
    diag_t = clamp((nx + ny + 1.0) * 0.5)
    bg_rgb = lerp_rgb(TURQ_BRIGHT, TURQ_MID, clamp(diag_t * 1.15))
    bg_rgb = lerp_rgb(bg_rgb, TURQ_DEEP, clamp((diag_t - 0.35) * 1.35))

    # Sol üst köşeden yayılan zarif ışık hüzmeleri (sunbeams)
    dx = nx - (-0.48)
    dy = ny - (-0.48)
    dist = math.hypot(dx, dy)
    angle = math.atan2(dy, dx)
    rays = (math.sin(angle * 14.0) * 0.5 + 0.5) ** 2.2
    ray_fade = clamp(1.0 - dist / 1.15) ** 1.6
    bg_rgb = lerp_rgb(bg_rgb, TURQ_GLOW, rays * ray_fade * 0.28 + (ray_fade ** 2.2) * 0.25)

    # İnce iç çerçeve parıltısı
    d_inner_border = abs(sd_rounded_box(nx, ny, 0.455, 0.455, 0.165)) - 0.006
    border_a = (1.0 - smoothstep(-aa, aa, d_inner_border)) * 0.32
    bg_rgb = lerp_rgb(bg_rgb, TURQ_GLOW, border_a)

    return (bg_rgb[0], bg_rgb[1], bg_rgb[2], 1.0)


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
                bg = sample_turquoise_background(nx, ny, aa)
                em = sample_mosque_emblem(nx, ny, aa, scale)
                col = blend_rgba(bg, (em[0], em[1], em[2]), em[3])
                if rounded_corners:
                    d_rr = sd_rounded_box(nx, ny, 0.5, 0.5, 0.22)
                    mask_a = 1.0 - smoothstep(-aa, aa, d_rr)
                    col = (col[0], col[1], col[2], col[3] * mask_a)
            else:
                col = sample_mosque_emblem(nx, ny, aa, scale)

            r = int(clamp(col[0], 0.0, 255.0) + 0.5)
            g = int(clamp(col[1], 0.0, 255.0) + 0.5)
            b = int(clamp(col[2], 0.0, 255.0) + 0.5)
            a = int(clamp(col[3], 0.0, 1.0) * 255.0 + 0.5)
            row.extend((r, g, b, a))
        rows.append(bytes(row))
    return write_png(size, size, b''.join(rows))


def render_feature_graphic(width: int = 1024, height: int = 500) -> bytes:
    """Google Play Mağaza Özellik Grafiği (1024x500): Turkuvaz zemin üzerinde
    ortalanmış Cami + PRO amblemi ve sağ/sol İslami hilal/yıldız motifleri.
    """
    aa = 1.25 / height
    rows = []
    for py in range(height):
        ny = (py + 0.5) / height - 0.5
        row = bytearray()
        row.append(0)
        for px in range(width):
            nx = (px + 0.5) / width - 0.5
            bg = sample_turquoise_background(nx, ny, aa)
            # Merkezde (x: 0.0) kare oranlı cami + PRO amblemi
            mx = ((px + 0.5) - width * 0.5) / height
            my = ny
            if abs(mx) <= 0.48:
                em = sample_mosque_emblem(mx, my, aa, scale=0.88)
                col = blend_rgba(bg, (em[0], em[1], em[2]), em[3])
            else:
                col = bg
                # Yanlarda zarif altın hilal halkası süslemesi
                sx = abs(mx) - 0.72
                sy = my
                ring_d = abs(math.hypot(sx, sy) - 0.22) - 0.005
                ring_a = (1.0 - smoothstep(-aa, aa, ring_d)) * 0.35
                if ring_a > 0.0:
                    col = blend_rgba(col, GOLD_LIGHT, ring_a)
            r = int(clamp(col[0], 0.0, 255.0) + 0.5)
            g = int(clamp(col[1], 0.0, 255.0) + 0.5)
            b = int(clamp(col[2], 0.0, 255.0) + 0.5)
            row.extend((r, g, b, 255))
        rows.append(bytes(row))
    return write_png(width, height, b''.join(rows))


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

    # Splash ve Play Store ikonu (512x512) + Mağaza Özellik Grafiği (1024x500)
    icon_512 = render_image(512, with_background=True, rounded_corners=False, scale=1.0)
    save_file(os.path.join(RES, 'drawable', 'splash_logo.png'), icon_512)
    save_file(os.path.join(STORE, 'play_icon_512.png'), icon_512)
    save_file(
        os.path.join(STORE, 'play_feature_graphic_1024x500.png'),
        render_feature_graphic(1024, 500),
    )

    # Arayüz içi şeffaf zeminli logo işareti
    save_file(
        os.path.join(IMAGES, 'logo_mark.png'),
        render_image(512, with_background=True, rounded_corners=True, scale=0.96),
    )
    save_file(
        os.path.join(IMAGES, 'logo_mark_small.png'),
        render_image(256, with_background=True, rounded_corners=True, scale=0.96),
    )
    print('Ezan Vaktim Pro turkuvaz cami ikonları başarıyla üretildi.')


if __name__ == '__main__':
    main()
