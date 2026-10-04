#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""EzanAI — gömülü (offline) veri varlıklarını üretir.

Girdi:   tools/data/raw/**   (bkz. fetch_sources.sh)
Çıktı:   assets/data/**

Çalıştırma:  python3 tools/data/build_assets.py
"""
from __future__ import annotations

import html
import json
import os
import re
import sys
import unicodedata
from collections import Counter, defaultdict
from datetime import date, timedelta

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
RAW = os.path.join(ROOT, 'tools', 'data', 'raw')
OUT = os.path.join(ROOT, 'assets', 'data')


def read_json(path):
    with open(path, encoding='utf-8') as fh:
        return json.load(fh)


def write_json(name, payload, pretty=False):
    os.makedirs(OUT, exist_ok=True)
    path = os.path.join(OUT, name)
    with open(path, 'w', encoding='utf-8') as fh:
        if pretty:
            json.dump(payload, fh, ensure_ascii=False, indent=2)
        else:
            json.dump(payload, fh, ensure_ascii=False, separators=(',', ':'))
    size = os.path.getsize(path) / 1024.0
    print(f'  ✓ {name:<34} {size:8.1f} KB')


# --------------------------------------------------------------------------- #
# 1) Hicri takvim (Umm al-Qura) — 1343-1500 H / 1924-2077 M
# --------------------------------------------------------------------------- #
def _greg_date(hijri_date):
    gregorian = hijri_date.to_gregorian()
    return date(gregorian.year, gregorian.month, gregorian.day)


def build_hijri():
    from hijri_converter import Hijri
    import hijri_converter.ummalqura as uq

    base_year, base_month = uq.HIJRI_RANGE[0][0], uq.HIJRI_RANGE[0][1]
    base_greg = _greg_date(Hijri(base_year, base_month, 1))
    lengths, y, m = [], base_year, base_month
    for _ in range(len(uq.MONTH_STARTS) - 1):
        ny, nm = (y + 1, 1) if m == 12 else (y, m + 1)
        a = _greg_date(Hijri(y, m, 1))
        try:
            b = _greg_date(Hijri(ny, nm, 1))
            lengths.append((b - a).days)
        except OverflowError:  # aralığın son ayı
            lengths.append(30)
        y, m = ny, nm
    # 28->'1', 29->'2', 30->'3', 31->'4'
    encoded = ''.join(chr(ord('0') + (le - 27)) for le in lengths)
    write_json('hijri_ummalqura.json', {
        'calendar': 'Umm al-Qura',
        'baseHijriYear': base_year,
        'baseHijriMonth': base_month,
        'baseGregorian': base_greg.isoformat(),
        'monthCount': len(lengths),
        'monthLengths': encoded,
        'range': '1343-1500 H (1924-2077 M)',
        'source': 'Umm al-Qura takvimi (hijri-converter veri kümesi)',
    })
    return encoded


# --------------------------------------------------------------------------- #
# 2) Kur'an-ı Kerim: Arapça (Uthmani) + Türkçe meal, sure bazlı dosyalar
# --------------------------------------------------------------------------- #
SURAH_TR = """Fatiha|Açılış
Bakara|İnek
Âl-i İmrân|İmrân Ailesi
Nisâ|Kadınlar
Mâide|Sofra
En'âm|Davarlar
A'râf|Yüksek Yerler
Enfâl|Savaş Ganimetleri
Tevbe|Tevbe
Yûnus|Yûnus
Hûd|Hûd
Yûsuf|Yûsuf
Ra'd|Gök Gürültüsü
İbrâhîm|İbrahim
Hicr|Hicr
Nahl|Balarısı
İsrâ|Gece Yürüyüşü
Kehf|Mağara
Meryem|Meryem
Tâhâ|Tâhâ
Enbiyâ|Peygamberler
Hac|Hac
Mü'minûn|Mü'minler
Nûr|Nur
Furkân|Furkan
Şuarâ|Şairler
Neml|Karınca
Kasas|Kıssalar
Ankebût|Örümcek
Rûm|Rum
Lokmân|Lokman
Secde|Secde
Ahzâb|Birleşik Ordular
Sebe|Sebe
Fâtır|Yaratan
Yâsîn|Yâsîn
Sâffât|Saf Tutanlar
Sâd|Sâd
Zümer|Bölükler
Mü'min|Mü'min
Fussilet|Ayrıntılı Açıklanmış
Şûrâ|Danışma
Zuhruf|Süs
Duhân|Duman
Câsiye|Diz Çökenler
Ahkâf|Kum Tepeleri
Muhammed|Muhammed
Fetih|Fetih
Hucurât|Odalar
Kâf|Kâf
Zâriyât|Savurup Atanlar
Tûr|Tûr Dağı
Necm|Yıldız
Kamer|Ay
Rahmân|Rahmân
Vâkıa|Vuku Bulan Olay
Hadîd|Demir
Mücâdele|Tartışma
Haşr|Sürgün
Mümtehine|İmtihan Edilen Kadın
Saff|Saf
Cum'a|Cuma
Münâfikûn|Münafıklar
Tegâbün|Aldanma
Talâk|Boşanma
Tahrîm|Haram Kılma
Mülk|Mülk
Kalem|Kalem
Hâkka|Gerçekleşen
Meâric|Yükselme Yolları
Nûh|Nûh
Cin|Cin
Müzzemmil|Örtünen
Müddessir|Bürünen
Kıyâmet|Kıyamet
İnsân|İnsan
Mürselât|Gönderilenler
Nebe|Haber
Nâziât|Söküp Çıkaranlar
Abese|Yüzünü Ekşitti
Tekvîr|Dürülme
İnfitâr|Yarılma
Mutaffifîn|Ölçüde Hile Yapanlar
İnşikâk|Çatlayıp Yarılma
Bürûc|Burçlar
Târık|Sabah Yıldızı
A'lâ|En Yüce
Gâşiye|Kaplayan
Fecr|Tan Vakti
Beled|Şehir
Şems|Güneş
Leyl|Gece
Duhâ|Kuşluk Vakti
İnşirâh|Genişletmek
Tîn|İncir
Alak|Asılıp Tutunan
Kadir|Kadir Gecesi
Beyyine|Apaçık Delil
Zilzâl|Sarsıntı
Âdiyât|Koşan Atlar
Kâria|Çarpacak Olan
Tekâsür|Çokluk Yarışı
Asr|Zaman
Hümeze|Arkadan Çekiştiren
Fîl|Fil
Kureyş|Kureyş
Mâûn|Yardım
Kevser|Bolluk
Kâfirûn|İnkâr Edenler
Nasr|Yardım
Tebbet|Alev
İhlâs|Samimi İnanç
Felak|Sabah Aydınlığı
Nâs|İnsanlar""".strip().split('\n')

# Cüz (juz) başlangıç ayetleri — standart mushaf tertibi
JUZ_STARTS = [(1, 1), (2, 142), (2, 253), (3, 93), (4, 24), (4, 148), (5, 27), (6, 111),
              (7, 88), (8, 41), (9, 93), (11, 6), (12, 53), (15, 1), (17, 1), (18, 75),
              (21, 1), (23, 1), (25, 21), (27, 56), (29, 46), (33, 31), (36, 28), (39, 32),
              (41, 47), (46, 1), (51, 31), (58, 1), (67, 1), (78, 1)]


def clean_text(value: str) -> str:
    value = re.sub(r'<br\s*/?>', '\n', value)
    value = re.sub(r'<[^>]+>', '', value)
    value = html.unescape(value).replace('\u00a0', ' ')
    return re.sub(r'[ \t]+', ' ', value).strip()


def build_quran():
    arabic = read_json(os.path.join(RAW, 'quran_uthmani.json'))
    turkish = read_json(os.path.join(RAW, 'quran_turkish_meal.json'))
    chapters = read_json(os.path.join(RAW, 'quran_chapters.json'))['chapters']
    assert len(SURAH_TR) == 114, len(SURAH_TR)

    quran_dir = os.path.join(OUT, 'quran')
    os.makedirs(quran_dir, exist_ok=True)
    meta = []
    total_bytes = 0
    for idx, chapter in enumerate(chapters):
        number = chapter['id']
        name_tr, meaning_tr = SURAH_TR[idx].split('|')
        verses_ar = [v['text'] for v in arabic[str(number)]]
        verses_tr = [clean_text(v['text']) for v in turkish[str(number)]]
        assert len(verses_ar) == len(verses_tr) == chapter['total_verses'], (number, len(verses_ar))
        path = os.path.join(quran_dir, f'{number}.json')
        payload = {'n': number, 'ar': verses_ar, 'tr': verses_tr}
        with open(path, 'w', encoding='utf-8') as fh:
            json.dump(payload, fh, ensure_ascii=False, separators=(',', ':'))
        total_bytes += os.path.getsize(path)
        meta.append({
            'n': number,
            'nameAr': chapter['name'],
            'nameTr': name_tr,
            'meaningTr': meaning_tr,
            'translit': chapter['transliteration'],
            'verses': chapter['total_verses'],
            'revelation': 'Mekke' if chapter['type'] == 'meccan' else 'Medine',
            'juzStart': next((i + 1 for i, (c, _) in enumerate(JUZ_STARTS) if c == number and number != 1), None),
        })
    write_json('surah_meta.json', {
        'sources': {
            'arabic': 'Tanzil.net — Uthmani metni (CC BY-ND 4.0 / serbest dağıtım)',
            'translation': 'Türkçe meal — Dr. Ali Özek ve arkadaşları (QuranEnc, yeniden yayın izinli)',
            'audio': 'EveryAyah.com / QuranicAudio — ayet ve sure bazlı tilavet CDN adresleri',
        },
        'juzStarts': [{'juz': i + 1, 'surah': c, 'ayah': a} for i, (c, a) in enumerate(JUZ_STARTS)],
        'surahs': meta,
    })
    print(f'  ✓ quran/*.json ({len(meta)} sure, {total_bytes / 1024 / 1024:.2f} MB)')


# --------------------------------------------------------------------------- #
# 3) Hadis — Riyâzü's-sâlihîn (1900 hadis, Arapça + Türkçe + kaynak)
# --------------------------------------------------------------------------- #
TOPIC_RULES = [
    ('Namaz', r'\bnamaz|secde|mescid|cemaat|kıl(mak|dı|ın)|vakit|kamet|ezan|sabah namazı|cuma'),
    ('Oruç ve Ramazan', r'\boru[çc]|ramazan|sahur|iftar|kadir gecesi|teravih'),
    ('Zikir ve Dua', r'\bzikir|zikr|dua|tesbih|isti[ğg]far|salavat|kur.?an oku|fatiha|ayetel'),
    ('Ahlak ve Edep', r'\bahlak|edep|g[üu]zel s[öo]z|yalan|g[ıi]ybet|kibir|öfke|sab[ıi]r|haya|utanma|tevazu|merhamet'),
    ('İlim ve Öğrenme', r'\bilim|ö[ğg]ren|\bâlim|alim|bilgi|okumak|hoca'),
    ('Aile ve Akrabalık', r'\banne|baba|eş|çocuk|nik[âa]h|aile|s[ıi]la-i rahim|kız kardeş|kardeşlik|evlat|zevce'),
    ('Helal Kazanç ve Ticaret', r'\bticaret|alı[şs]veri[şs]|faiz|r[ıi]z[ıi]k|kazanç|bor[çc]|emanet|ölç|tartı|ortaklık'),
    ('İhlas ve Kalp', r'\bihl[âa]s|niyet|kalp|riya|tevbe|samimi|gizli sadaka'),
    ('Ahiret ve Hesap', r'\bcennet|cehennem|k[ıi]yamet|kabir|hesap|mizan|sırat|ha[şs]ir'),
    ('Komşuluk ve Muamelat', r'\bkom[şs]u|selam|hediye|sadaka|infak|yetim|misafir|i[yi]lik|yardım'),
    ('Temizlik ve Sağlık', r'\btemiz|abdest|gus[üu]l|hastalık|[şs]ifa|yemek|uyku|taharet|misvak'),
    ('Fazilet ve İbadet', r'\bfazilet|sevap|hayır|farz|s[üu]nnet|nafile|hac|zekat|kurban'),
]
NAMED_SOURCES = ['Buhârî', 'Müslim', 'Tirmizî', 'Nesâî', 'Ebû Dâvûd', 'İbni Mâce', 'Ahmed İbni Hanbel',
                 'Dârimî', 'Mâlik', 'Hâkim', 'Beyhakî', 'Taberânî', 'İbn Hibbân', 'İbn Huzeyme']


def build_hadith():
    raw = read_json(os.path.join(RAW, 'riyazus_salihin.json'))
    items, topic_counts = [], Counter()
    for entry in raw:
        paragraphs = [clean_text(p) for p in re.findall(r'<p>(.*?)</p>', entry['turkish'], flags=re.S)]
        paragraphs = [p for p in paragraphs if p]
        if not paragraphs:
            continue
        reference = ''
        if len(paragraphs) > 1 and re.search(r'(' + '|'.join(NAMED_SOURCES) + r')', paragraphs[-1]):
            reference = paragraphs[-1]
            body = paragraphs[:-1]
        else:
            body = paragraphs
        text = '\n\n'.join(body).strip()
        if not text:
            continue
        arabic = clean_text(entry['arabic'])
        primary = next((s for s in NAMED_SOURCES if s in reference), '')
        haystack = text.lower()
        topics = [name for name, pattern in TOPIC_RULES if re.search(pattern, haystack, flags=re.I)]
        if not topics:
            topics = ['Genel']
        topic_counts.update(topics[:2])
        items.append({
            'id': int(entry['hadith_id']),
            'ar': arabic,
            'tr': text,
            'ref': reference,
            'src': primary,
            'topics': topics[:3],
        })
    items.sort(key=lambda x: x['id'])
    write_json('hadith_riyazus_salihin.json', {
        'collection': 'Riyâzü\'s-sâlihîn',
        'author': 'İmâm Nevevî (ö. 676/1277)',
        'translator': 'HadisKitaplari.com Türkçe çevirisi (açık kaynak)',
        'count': len(items),
        'note': 'Konu etiketleri metin içeriğine göre otomatik sınıflandırılmıştır; '
                'hadis metinleri ve kaynak künyeleri orijinal çeviriden aynen alınmıştır.',
        'topics': sorted(topic_counts.keys()),
        'hadiths': items,
    })
    print('  ✓ hadis konu dağılımı:', dict(topic_counts.most_common(12)))


# --------------------------------------------------------------------------- #
# 4) Şehir veritabanı — Türkiye (il/ilçe) + dünya şehirleri
# --------------------------------------------------------------------------- #
PLATE_PROVINCES = (
    "Adana Adıyaman Afyonkarahisar Ağrı Amasya Ankara Antalya Artvin Aydın Balıkesir Bilecik Bingöl "
    "Bitlis Bolu Burdur Bursa Çanakkale Çankırı Çorum Denizli Diyarbakır Edirne Elazığ Erzincan Erzurum "
    "Eskişehir Gaziantep Giresun Gümüşhane Hakkari Hatay Isparta Mersin İstanbul İzmir Kars Kastamonu "
    "Kayseri Kırklareli Kırşehir Kocaeli Konya Kütahya Malatya Manisa Kahramanmaraş Mardin Muğla Muş "
    "Nevşehir Niğde Ordu Rize Sakarya Samsun Siirt Sinop Sivas Tekirdağ Tokat Trabzon Tunceli Şanlıurfa "
    "Uşak Van Yozgat Zonguldak Aksaray Bayburt Karaman Kırıkkale Batman Şırnak Bartın Ardahan Iğdır "
    "Yalova Karabük Kilis Osmaniye Düzce"
).split()

TR_UPPER = str.maketrans({'İ': 'I', 'Ş': 'S', 'Ğ': 'G', 'Ü': 'U', 'Ö': 'O', 'Ç': 'C', 'Â': 'A', 'Î': 'I', 'Û': 'U'})


def norm_tr(value: str) -> str:
    return value.upper().translate(TR_UPPER).replace(' ', '').strip()


def title_tr(value: str) -> str:
    """TR/EN karışık şehir adlarını okunabilir başlığa çevirir."""
    value = value.strip()
    if not value:
        return value
    if value.isupper():
        parts = re.split(r'([ \-/\'])', value.lower())
        out = []
        for token in parts:
            if token in ('-', ' ', '/', "'", ''):
                out.append(token)
            else:
                out.append(token[:1].translate({'i': 'İ'}) + token[1:])
        return ''.join(out)
    return value


def build_cities():
    lookup = read_json(os.path.join(RAW, 'city_lookup.json'))
    districts_by_province = defaultdict(list)
    world_by_country = defaultdict(list)
    provinces = {}
    for row in lookup:
        country = row.get('UlkeAdi') or row.get('UlkeAdiEn') or ''
        province = (row.get('SehirAdi') or '').strip()
        name = (row.get('IlceAdi') or '').strip()
        lat, lon = row.get('lat'), row.get('lon')
        if lat is None or lon is None:
            continue
        if norm_tr(country) == 'TURKIYE':
            districts_by_province[norm_tr(province)].append((name, float(lat), float(lon)))
        else:
            world_by_country[country].append({
                'n': title_tr(name), 'lat': round(float(lat), 5), 'lon': round(float(lon), 5),
            })

    tr_provinces, tr_districts = [], []
    for index, plate_name in enumerate(PLATE_PROVINCES, start=1):
        key = norm_tr(plate_name)
        capital = next((d for d in districts_by_province.get(key, []) if norm_tr(d[0]) == key), None)
        if capital is None:
            candidates = districts_by_province.get(key, [])
            capital = max(candidates, key=lambda d: len(d[0])) if candidates else None
        if capital is None:
            print(f'  ! koordinat bulunamadı: {plate_name}', file=sys.stderr)
            continue
        provinces[plate_name] = capital
        tr_provinces.append({
            'id': index,
            'name': plate_name,
            'lat': round(capital[1], 5),
            'lon': round(capital[2], 5),
            'districts': sorted({title_tr(d[0]) for d in districts_by_province.get(key, [])}),
        })
        for name, lat, lon in districts_by_province.get(key, []):
            tr_districts.append({
                'name': title_tr(name), 'province': plate_name,
                'lat': round(lat, 5), 'lon': round(lon, 5),
            })

    countries = []
    for country, cities in world_by_country.items():
        unique = {c['n']: c for c in cities}
        countries.append({
            'name': title_tr(country),
            'cities': sorted(unique.values(), key=lambda c: c['n']),
        })
    countries.sort(key=lambda c: c['name'])

    write_json('cities_turkey.json', {
        'source': 'Diyanet tabanlı açık yer veri kümesi (EzanVaktiAPI — koordinatlar)',
        'provinces': tr_provinces,
        'districts': sorted(tr_districts, key=lambda d: (d['province'], d['name'])),
    })
    write_json('cities_world.json', {
        'source': 'Açık yer veri kümesi (Diyanet tabanlı, 90+ ülke)',
        'countries': countries,
    })
    print(f'  ✓ {len(tr_provinces)} il, {len(tr_districts)} ilçe, '
          f'{len(countries)} ülke / {sum(len(c["cities"]) for c in countries)} şehir')


# --------------------------------------------------------------------------- #
# 5) Diyanet kalibrasyon doğrulama verisi (test fixture)
# --------------------------------------------------------------------------- #
def build_validation_fixture():
    official = read_json(os.path.join(RAW, 'official_diyanet_sample.json'))
    cities = {1: 'Adana', 6: 'Ankara', 7: 'Antalya', 21: 'Diyarbakır', 34: 'İstanbul',
              35: 'İzmir', 42: 'Konya', 55: 'Samsun', 61: 'Trabzon', 63: 'Şanlıurfa', 68: 'Aksaray'}
    coords = {}
    for entry in read_json(os.path.join(RAW, 'city_lookup.json')):
        if norm_tr(entry.get('UlkeAdi', '')) != 'TURKIYE':
            continue
        key = norm_tr(entry.get('SehirAdi', ''))
        if norm_tr(entry.get('IlceAdi', '')) == key:
            coords.setdefault(key, (entry['lat'], entry['lon']))
    rows = []
    wanted_dates = {'2021-12-21', '2022-03-21', '2022-06-21', '2022-09-23', '2022-12-21', '2022-01-15'}
    for city_id, city_name in cities.items():
        key = norm_tr(city_name)
        if key not in coords:
            continue
        lat, lon = coords[key]
        for date_key, times in official.items():
            cid, day = date_key.split('|')
            if int(cid) != city_id or day not in wanted_dates:
                continue
            rows.append({
                'city': city_name, 'lat': round(lat, 5), 'lon': round(lon, 5), 'date': day,
                'tz': 3.0, **times,
            })
    write_json('diyanet_validation_sample.json', {
        'note': 'T.C. Diyanet İşleri Başkanlığı resmî namaz vakitleri — hesaplama motoru doğrulama verisi',
        'records': sorted(rows, key=lambda r: (r['city'], r['date'])),
    })
    print(f'  ✓ {len(rows)} doğrulama kaydı')


if __name__ == '__main__':
    print('EzanAI veri varlıkları üretiliyor →', OUT)
    build_hijri()
    build_quran()
    build_hadith()
    build_cities()
    build_validation_fixture()
    print('Tamamlandı.')
