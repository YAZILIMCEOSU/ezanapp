#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Yasal Markdown belgelerini GitHub Pages için HTML sayfalarına dönüştürür.

Kaynaklar: docs/legal/*.md
Çıktılar:  docs/*.html

Kullanım:
    python3 tools/build_legal_pages.py

Gereksinim: markdown (pip install markdown)
"""
from __future__ import annotations

import html
import re
import sys
from pathlib import Path

try:
    import markdown
except ImportError:  # pragma: no cover
    sys.exit('markdown paketi yok: python3 -m pip install markdown')

ROOT = Path(__file__).resolve().parent.parent
LEGAL = ROOT / 'docs' / 'legal'
OUT = ROOT / 'docs'

# (kaynak markdown, çıktı html, <title>, açıklama)
PAGES = [
    ('KVKK_AYDINLATMA_METNI.md', 'privacy.html',
     'Gizlilik Politikası — Ezan Vaktim Pro',
     'Ezan Vaktim Pro gizlilik politikası ve KVKK aydınlatma metni.'),
    ('KVKK_AYDINLATMA_METNI.md', 'kvkk.html',
     'KVKK Aydınlatma Metni — Ezan Vaktim Pro',
     '6698 sayılı KVKK kapsamında aydınlatma metni.'),
    ('ACIK_RIZA_METINLERI.md', 'acik-riza.html',
     'Açık Rıza Metinleri — Ezan Vaktim Pro',
     'Yapay zekâ, bulut yedekleme ve reklam için açık rıza metinleri.'),
    ('KULLANIM_KOSULLARI.md', 'terms.html',
     'Kullanım Koşulları — Ezan Vaktim Pro',
     'Ezan Vaktim Pro kullanım koşulları (EULA).'),
    ('ABONELIK_VE_IADE.md', 'abonelik.html',
     'Abonelik ve İade — Ezan Vaktim Pro',
     'Premium abonelik, otomatik yenileme, cayma ve iade bilgileri.'),
    ('VERI_SILME_VE_BASVURU.md', 'veri-silme.html',
     'Veri Silme ve Başvuru — Ezan Vaktim Pro',
     'Cihaz ve sunucu verilerini silme yolları, KVKK başvurusu.'),
    ('SIBER_GUVENLIK_PROTOKOLU.md', 'guvenlik.html',
     'Siber Güvenlik — Ezan Vaktim Pro',
     'Güvenlik açığı bildirimi, olay müdahale ve KVKK 72 saat süreci.'),
    ('VERI_ENVANTERI_ROPA.md', 'ropa.html',
     'Veri İşleme Envanteri (ROPA) — Ezan Vaktim Pro',
     'Kişisel veri işleme envanteri ve saklama takvimi.'),
    ('UCUNCU_TARAF_SDK_VE_AKTARIMLAR.md', 'ucuncu-taraflar.html',
     'Üçüncü Taraf SDK ve Aktarımlar — Ezan Vaktim Pro',
     'SDK envanteri, yurt dışı aktarım ve tedarikçi listesi.'),
    ('SES_VE_ICERIK_LISANSLARI.md', 'lisanslar.html',
     'Ses ve İçerik Lisansları — Ezan Vaktim Pro',
     'Ezan, ilahi, Kur’an ve görsel içerik lisansları.'),
    ('GOOGLE_PLAY_UYUM.md', 'google-play.html',
     'Google Play Uyum — Ezan Vaktim Pro',
     'Data safety, izinler ve Google Play politika uyumu.'),
    ('APPLE_APP_STORE_UYUM.md', 'app-store.html',
     'Apple App Store Uyum — Ezan Vaktim Pro',
     'App Privacy, privacy manifest ve App Store gereksinimleri.'),
    ('TEKNIK_DUZELTME_PLANI.md', 'teknik-plan.html',
     'Teknik Düzeltme Planı — Ezan Vaktim Pro',
     'Uyum için yapılan ve kalan teknik düzeltmeler.'),
    ('YAYIN_UYUMLULUK_KONTROL_LISTESI.md', 'yayin-kontrol.html',
     'Yayın Uyumluluk Kontrol Listesi — Ezan Vaktim Pro',
     'Yayın öncesi P0/P1 uyum kontrol listesi.'),
]

NAV = [
    ('privacy.html', 'Gizlilik'),
    ('kvkk.html', 'KVKK'),
    ('acik-riza.html', 'Açık Rıza'),
    ('terms.html', 'Koşullar'),
    ('abonelik.html', 'Abonelik'),
    ('veri-silme.html', 'Veri Silme'),
    ('guvenlik.html', 'Güvenlik'),
]

TEMPLATE = """<!DOCTYPE html>
<html lang="tr">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="description" content="{description}">
<meta name="robots" content="index,follow">
<title>{title}</title>
<style>
:root {{
  --bg: #f6f8f7;
  --card: #ffffff;
  --ink: #14211d;
  --muted: #5b6b65;
  --brand: #0f766e;
  --brand-soft: #e6f4f1;
  --line: #dbe5e1;
  --warn: #92400e;
}}
* {{ box-sizing: border-box; }}
html {{ scroll-behavior: smooth; }}
body {{
  margin: 0;
  background: var(--bg);
  color: var(--ink);
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto,
    "Helvetica Neue", Arial, sans-serif;
  line-height: 1.65;
  font-size: 16px;
}}
a {{ color: var(--brand); text-decoration-thickness: 1px; }}
a:hover {{ text-decoration-thickness: 2px; }}
header {{
  background: linear-gradient(135deg, #0f766e, #115e59);
  color: #fff;
  padding: 22px 20px 18px;
}}
header .wrap {{
  max-width: 980px; margin: 0 auto;
  display: flex; flex-wrap: wrap; align-items: center; gap: 12px;
  justify-content: space-between;
}}
.brand {{ font-weight: 800; letter-spacing: .2px; font-size: 18px; }}
.brand small {{ display: block; font-weight: 500; opacity: .85; font-size: 12px; }}
nav {{ display: flex; flex-wrap: wrap; gap: 6px; }}
nav a {{
  color: #fff; text-decoration: none; font-size: 13px;
  padding: 5px 9px; border-radius: 999px; background: rgba(255,255,255,.12);
}}
nav a:hover {{ background: rgba(255,255,255,.24); }}
main {{
  max-width: 980px; margin: 26px auto 60px; padding: 0 18px;
}}
.card {{
  background: var(--card); border: 1px solid var(--line);
  border-radius: 16px; padding: 28px 30px;
  box-shadow: 0 8px 24px rgba(15, 118, 110, .06);
}}
h1 {{ font-size: 30px; line-height: 1.2; margin: 0 0 8px; }}
h2 {{ font-size: 22px; margin: 34px 0 10px; padding-top: 8px; }}
h3 {{ font-size: 17px; margin: 24px 0 8px; }}
p, li {{ color: #24332e; }}
ul, ol {{ padding-left: 22px; }}
li {{ margin: 4px 0; }}
blockquote {{
  margin: 18px 0; padding: 12px 16px;
  background: var(--brand-soft); border-left: 4px solid var(--brand);
  border-radius: 8px; color: #164e47;
}}
code {{
  background: #eef3f1; padding: 1px 5px; border-radius: 5px;
  font-size: 13px;
}}
pre {{
  background: #0f172a; color: #e2e8f0; padding: 16px;
  border-radius: 10px; overflow-x: auto; font-size: 13px;
}}
pre code {{ background: transparent; color: inherit; padding: 0; }}
table {{
  width: 100%; border-collapse: collapse; margin: 16px 0;
  font-size: 14px; display: block; overflow-x: auto;
}}
th, td {{ border: 1px solid var(--line); padding: 8px 10px; text-align: left; vertical-align: top; }}
th {{ background: #f0f6f4; font-weight: 700; }}
hr {{ border: 0; border-top: 1px solid var(--line); margin: 30px 0; }}
.meta {{
  color: var(--muted); font-size: 13px; margin-bottom: 18px;
}}
.notice {{
  background: #fff7ed; border: 1px solid #fed7aa; color: var(--warn);
  padding: 12px 16px; border-radius: 10px; font-size: 13.5px;
  margin: 18px 0;
}}
footer {{
  max-width: 980px; margin: 0 auto 40px; padding: 0 18px;
  color: var(--muted); font-size: 13px;
}}
footer .links {{ display: flex; flex-wrap: wrap; gap: 10px; margin-bottom: 8px; }}
@media (max-width: 640px) {{
  .card {{ padding: 20px 16px; }}
  h1 {{ font-size: 24px; }}
  h2 {{ font-size: 19px; }}
}}
@media print {{
  header, nav, footer {{ display: none; }}
  body {{ background: #fff; }}
  .card {{ border: 0; box-shadow: none; padding: 0; }}
}}
</style>
</head>
<body>
<header>
  <div class="wrap">
    <div class="brand">Ezan Vaktim Pro<small>Yasal ve uyum belgeleri</small></div>
    <nav>{nav}</nav>
  </div>
</header>
<main>
  <article class="card">
    <div class="meta">YazılımCeosu · İstanbul, Türkiye · destek@ezanai.app</div>
    {body}
    <div class="notice">
      Bu sayfa bilgilendirme amaçlıdır ve hukuki görüş yerine geçmez.
      Yürürlükteki sürüm bu sayfadır; önemli değişiklikler uygulama içinde
      duyurulur.
    </div>
  </article>
</main>
<footer>
  <div class="links">{footer_links}</div>
  <div>© 2026 YazılımCeosu · Ezan Vaktim Pro · <code>com.yazilimceosu.ezanai</code></div>
</footer>
</body>
</html>
"""


def linkify(text: str) -> str:
    """Markdown içi .md bağlantılarını yayınlanan .html adreslerine çevirir."""
    mapping = {
        'KVKK_AYDINLATMA_METNI.md': 'kvkk.html',
        'ACIK_RIZA_METINLERI.md': 'acik-riza.html',
        'KULLANIM_KOSULLARI.md': 'terms.html',
        'ABONELIK_VE_IADE.md': 'abonelik.html',
        'VERI_SILME_VE_BASVURU.md': 'veri-silme.html',
        'SIBER_GUVENLIK_PROTOKOLU.md': 'guvenlik.html',
        'UCUNCU_TARAF_SDK_VE_AKTARIMLAR.md': 'ucuncu-taraflar.html',
        'SES_VE_ICERIK_LISANSLARI.md': 'lisanslar.html',
        'TEKNIK_DUZELTME_PLANI.md': 'teknik-plan.html',
        'YAYIN_UYUMLULUK_KONTROL_LISTESI.md': 'yayin-kontrol.html',
        'GOOGLE_PLAY_UYUM.md': 'google-play.html',
        'APPLE_APP_STORE_UYUM.md': 'app-store.html',
        'VERI_ENVANTERI_ROPA.md': 'ropa.html',
    }
    for old, new in mapping.items():
        text = text.replace(f']({old})', f']({new})')
    text = re.sub(r'\]\(\.\./legal/([A-Z0-9_]+)\.md\)', r'](\1)', text)
    return text


def build_page(src: Path, out_name: str, title: str, description: str) -> None:
    raw = src.read_text(encoding='utf-8')
    raw = linkify(raw)
    body = markdown.markdown(
        raw,
        extensions=['tables', 'fenced_code', 'sane_lists', 'toc'],
        output_format='html5',
    )
    nav_html = ''.join(
        f'<a href="{href}">{html.escape(label)}</a>' for href, label in NAV
    )
    footer = ''.join(
        f'<a href="{href}">{html.escape(label)}</a>' for href, label in NAV
    )
    page = TEMPLATE.format(
        title=html.escape(title),
        description=html.escape(description),
        nav=nav_html,
        footer_links=footer,
        body=body,
    )
    (OUT / out_name).write_text(page, encoding='utf-8')
    print(f'  {out_name:22s} <- docs/legal/{src.name}')


def build_index() -> None:
    nav_html = ''.join(
        f'<a href="{href}">{html.escape(label)}</a>' for href, label in NAV
    )
    cards = []
    for href, label in NAV:
        cards.append(
            f'<li><a href="{href}"><strong>{html.escape(label)}</strong></a></li>'
        )
    body = (
        '<h1>Yasal Belgeler</h1>'
        '<p>Ezan Vaktim Pro uygulamasının gizlilik, KVKK, kullanım koşulları, '
        'abonelik, veri silme ve güvenlik belgeleri.</p>'
        '<ul>' + ''.join(cards) + '</ul>'
        '<h2>İletişim</h2>'
        '<p>Destek: <a href="mailto:destek@ezanai.app">destek@ezanai.app</a><br>'
        'Güvenlik bildirimi: konu satırı “GÜVENLİK”</p>'
    )
    page = TEMPLATE.format(
        title='Yasal Belgeler — Ezan Vaktim Pro',
        description='Ezan Vaktim Pro yasal belgeler dizini.',
        nav=nav_html,
        footer_links=nav_html,
        body=body,
    )
    (OUT / 'yasal.html').write_text(page, encoding='utf-8')
    print('  yasal.html             <- dizin')


def main() -> int:
    if not LEGAL.is_dir():
        print('docs/legal bulunamadı', file=sys.stderr)
        return 1
    print('Yasal sayfalar üretiliyor:')
    for src_name, out_name, title, description in PAGES:
        src = LEGAL / src_name
        if not src.exists():
            print(f'  ATLANDI (yok): {src_name}', file=sys.stderr)
            continue
        build_page(src, out_name, title, description)
    build_index()
    print('Tamamlandı.')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
