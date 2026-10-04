#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""EzanAI — launcher/store ikonlarını üretir (Pillow).

Çalıştırma: python3 tools/design/make_icons.py
"""
from __future__ import annotations

import math
import os

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
RES = os.path.join(ROOT, 'android', 'app', 'src', 'main', 'res')
STORE = os.path.join(ROOT, 'store')

EMERALD = (8, 43, 38)
EMERALD_LIGHT = (14, 74, 63)
GOLD = (226, 186, 106)
GOLD_DEEP = (196, 150, 66)
CREAM = (247, 243, 233)


def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def radial_background(size: int) -> Image.Image:
    img = Image.new('RGB', (size, size), EMERALD)
    px = img.load()
    cx = cy = size / 2
    max_d = math.hypot(cx, cy)
    for y in range(size):
        for x in range(size):
            d = math.hypot(x - cx, y - cy) / max_d
            t = min(1.0, d ** 1.4)
            px[x, y] = lerp(EMERALD_LIGHT, EMERALD, t)
    return img


def draw_pattern(base: Image.Image, size: int, color=(255, 255, 255, 8)) -> None:
    """İnce geometrik (İslami yıldız) desen."""
    layer = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    step = size / 8
    for i in range(9):
        for j in range(9):
            cx, cy = i * step, j * step
            r = step * 0.46
            pts = []
            for k in range(8):
                ang = math.pi / 4 * k
                pts.append((cx + r * math.cos(ang), cy + r * math.sin(ang)))
            inner = []
            for k in range(8):
                ang = math.pi / 4 * k + math.pi / 8
                inner.append((cx + r * 0.5 * math.cos(ang), cy + r * 0.5 * math.sin(ang)))
            poly = []
            for k in range(8):
                poly.append(pts[k])
                poly.append(inner[k])
            d.polygon(poly, outline=color, width=max(1, int(size / 512)))
    base.paste(Image.alpha_composite(base.convert('RGBA'), layer).convert('RGB'), (0, 0))


def draw_logo(size: int, scale: float = 1.0) -> Image.Image:
    """Hilal + yıldız + ince halka (minimal, premium işaret)."""
    layer = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    cx, cy = size / 2, size / 2

    # --- ince halka ---
    ImageDraw.Draw(layer).ellipse(
        [cx - size * 0.315 * scale, cy - size * 0.315 * scale,
         cx + size * 0.315 * scale, cy + size * 0.315 * scale],
        outline=(226, 186, 106, 70), width=max(2, int(size * 0.0055)))

    # --- hilal ---
    r = size * 0.185 * scale
    moon_cx, moon_cy = cx - size * 0.045 * scale, cy
    moon = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    md = ImageDraw.Draw(moon)
    md.ellipse([moon_cx - r, moon_cy - r, moon_cx + r, moon_cy + r], fill=GOLD)
    cut_r = r * 1.12
    cut_cx = moon_cx + r * 0.38
    md.ellipse([cut_cx - cut_r, moon_cy - cut_r - r * 0.06,
                cut_cx + cut_r, moon_cy + cut_r - r * 0.06], fill=(0, 0, 0, 0))
    layer = Image.alpha_composite(layer, moon)

    # --- yıldız (hilal kucağında) ---
    star = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    sd = ImageDraw.Draw(star)
    star_r = r * 0.46
    sx, sy = moon_cx + r * 0.62, moon_cy - r * 0.02
    pts = []
    for k in range(10):
        ang = -math.pi / 2 + k * math.pi / 5
        rad = star_r if k % 2 == 0 else star_r * 0.42
        pts.append((sx + rad * math.cos(ang), sy + rad * math.sin(ang)))
    sd.polygon(pts, fill=CREAM)
    layer = Image.alpha_composite(layer, star)

    # optik dengeleme için hafif sağa kaydır
    return layer.transform(layer.size, Image.AFFINE, (1, 0, -size * 0.018, 0, 1, 0), resample=Image.BICUBIC)


def rounded(img: Image.Image, radius_ratio: float = 0.22) -> Image.Image:
    size = img.size[0]
    mask = Image.new('L', (size, size), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, size, size], radius=int(size * radius_ratio), fill=255)
    out = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    out.paste(img.convert('RGBA'), (0, 0), mask)
    return out


def make_icon(size: int, rounded_corners: bool) -> Image.Image:
    base = radial_background(size)
    draw_pattern(base, size)
    base = base.convert('RGBA')
    glow = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    glow.paste(draw_logo(size, 1.0), (0, 0))
    glow = glow.filter(ImageFilter.GaussianBlur(size * 0.03))
    base = Image.alpha_composite(base, glow)
    base = Image.alpha_composite(base, draw_logo(size, 1.0))
    return rounded(base, 0.22) if rounded_corners else base


def make_logo_mark(size: int) -> Image.Image:
    """Şeffaf zeminli uygulama işareti (arayüz içi kullanım)."""
    return draw_logo(size, 0.86)


def main() -> None:
    densities = {'mdpi': 48, 'hdpi': 72, 'xhdpi': 96, 'xxhdpi': 144, 'xxxhdpi': 192}
    for name, size in densities.items():
        out_dir = os.path.join(RES, f'mipmap-{name}')
        os.makedirs(out_dir, exist_ok=True)
        icon = make_icon(size, rounded_corners=False)
        icon.save(os.path.join(out_dir, 'ic_launcher.png'))
        # yuvarlatılmış varyant (bazı başlatıcılar için)
        make_icon(size, rounded_corners=True).save(os.path.join(out_dir, 'ic_launcher_round.png'))
        # adaptif ikon ön planı (güvenli alan: %60)
        fg = Image.new('RGBA', (size, size), (0, 0, 0, 0))
        logo = draw_logo(size, 0.62)
        fg = Image.alpha_composite(fg, logo)
        fg.save(os.path.join(out_dir, 'ic_launcher_foreground.png'))
    os.makedirs(os.path.join(RES, 'drawable'), exist_ok=True)
    make_icon(1024, rounded_corners=False).save(os.path.join(RES, 'drawable', 'splash_logo.png'))

    # Arayüz içi işaret (şeffaf zemin, tema renginden bağımsız kullanılır)
    images_dir = os.path.join(ROOT, 'assets', 'images')
    os.makedirs(images_dir, exist_ok=True)
    make_logo_mark(512).save(os.path.join(images_dir, 'logo_mark.png'))
    make_logo_mark(1024).resize((256, 256), Image.LANCZOS).save(
        os.path.join(images_dir, 'logo_mark_small.png'))
    print('logo işaretleri assets/images/ altına yazıldı')

    os.makedirs(STORE, exist_ok=True)
    make_icon(512, rounded_corners=False).save(os.path.join(STORE, 'play_icon_512.png'))

    # öne çıkan görsel 1024x500
    feature = Image.new('RGB', (1024, 1024), EMERALD)
    draw_pattern(feature, 1024)
    feature = feature.convert('RGBA')
    logo = draw_logo(500, 0.85)
    feature.paste(logo, (60, 262), logo)
    feature = feature.crop((0, 262, 1024, 762))
    d = ImageDraw.Draw(feature)
    try:
        font = ImageFont.truetype(os.path.join(ROOT, 'assets', 'fonts', 'PlusJakartaSans.ttf'), 74)
        small = ImageFont.truetype(os.path.join(ROOT, 'assets', 'fonts', 'PlusJakartaSans.ttf'), 34)
    except OSError:
        font = small = ImageFont.load_default()
    d.text((600, 150), 'EzanAI', fill=CREAM, font=font)
    d.text((604, 250), 'Namaz • Kıble • Kur\'an • İlahi', fill=GOLD, font=small)
    d.text((604, 300), 'Hadis • Tesbih • Ramazan • AI Asistan', fill=(180, 205, 197), font=small)
    feature.convert('RGB').save(os.path.join(STORE, 'play_feature_graphic_1024x500.png'))
    print('İkonlar üretildi →', RES, 've', STORE)


if __name__ == '__main__':
    main()
