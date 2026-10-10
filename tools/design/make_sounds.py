#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Ezan — telifsiz makam ezan tilavetleri ve İslami ilahi/ney bildirim sesleri üretir.

Kesinlikle çan/metalik vuruş zarfı (hızlı atak + üstel sönüm) KULLANILMAZ.
Tüm sesler sürekli nefes/vokal legato cümleleri, ses yolu formant filtreleri
(A, U, E, İ ünlü tınıları), portamento perde geçişleri ve cami kubbe akustiğiyle
üretilir.

Çıktılar:
  assets/audio/adhan/*.wav           → uygulama içi oynatma (ezan ve ilahi kataloğu)
  android/app/src/main/res/raw/*.wav → Android bildirim kanalı sesleri
"""
from __future__ import annotations

import math
import os
import struct
import wave

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
ASSETS = os.path.join(ROOT, 'assets', 'audio', 'adhan')
RAW = os.path.join(ROOT, 'android', 'app', 'src', 'main', 'res', 'raw')
SAMPLE_RATE = 22050

# Bariton/tenor insan sesi ve ney karar perdeleri (Hz) — tiz/çan frekansları yok
NOTES: dict[str, float] = {
    'G2': 98.00,
    'A2': 110.00,
    'Bb2': 116.54,
    'B2': 123.47,
    'C3': 130.81,
    'C#3': 138.59,
    'D3': 146.83,
    'Eb3': 155.56,
    'E3': 164.81,
    'F3': 174.61,
    'F#3': 185.00,
    'G3': 196.00,
    'Ab3': 207.65,
    'A3': 220.00,
    'Bb3': 233.08,
    'B3': 246.94,
    'C4': 261.63,
    'C#4': 277.18,
    'D4': 293.66,
    'Eb4': 311.13,
    'E4': 329.63,
    'F4': 349.23,
    'F#4': 369.99,
    'G4': 392.00,
    'A4': 440.00,
}

# İnsan ses yolu (formant) merkez frekansları ve bant genişlikleri: (F1, F2, F3)
VOWEL_FORMANTS: dict[str, tuple[tuple[float, float, float], ...]] = {
    'A': ((720.0, 140.0, 1.00), (1150.0, 180.0, 0.55), (2450.0, 260.0, 0.22)),
    'U': ((340.0, 110.0, 1.00), (780.0, 150.0, 0.48), (2200.0, 240.0, 0.18)),
    'E': ((520.0, 125.0, 1.00), (1720.0, 195.0, 0.45), (2480.0, 250.0, 0.20)),
    'I': ((310.0, 105.0, 1.00), (2080.0, 210.0, 0.40), (2750.0, 270.0, 0.18)),
    'O': ((460.0, 120.0, 1.00), (880.0, 160.0, 0.52), (2350.0, 250.0, 0.20)),
    # Ahşap ney + vokal dem tınısı
    'NEY': ((420.0, 160.0, 1.00), (960.0, 210.0, 0.50), (1850.0, 280.0, 0.18)),
}


def _formant_gain(freq_hz: float, vowel: str) -> float:
    formants = VOWEL_FORMANTS.get(vowel, VOWEL_FORMANTS['A'])
    gain = 0.12
    for center, bw, weight in formants:
        diff = (freq_hz - center) / bw
        gain += weight * math.exp(-0.5 * diff * diff)
    return gain


# Formant kazançlarını 1 Hz çözünürlükle önbelleğe al (hızlı sentez için)
_FORMANT_TABLE: dict[str, list[float]] = {}
for _v in VOWEL_FORMANTS:
    _FORMANT_TABLE[_v] = [_formant_gain(float(_f), _v) for _f in range(4001)]


def render_legato_phrase(
    segments: list[tuple[str, float, str, float]],
    vibrato_hz: float = 5.0,
    vibrato_depth: float = 0.0065,
    glide_sec: float = 0.085,
    drone_note: str | None = None,
    drone_amp: float = 0.10,
) -> list[float]:
    """Bir nefes cümlesini kesintisiz faz, portamento geçiş ve vokal formantlarla üretir.

    segments: [(nota_adı, süre_sn, ünlü_kodu, genlik), ...]
    Hiçbir notada çan/vuruş zarfı yoktur; tüm cümle yumuşak bir nefesle başlar,
    sürdürülür ve yumuşakça kapanır.
    """
    total_duration = sum(seg[1] for seg in segments)
    total_samples = int(SAMPLE_RATE * total_duration)
    if total_samples <= 0:
        return []

    freqs: list[float] = []
    amps: list[float] = []
    vowels: list[str] = []
    note_local_t: list[float] = []

    prev_freq = NOTES[segments[0][0]]
    for note_name, dur, vowel, amp in segments:
        target_freq = NOTES[note_name]
        n_samp = int(SAMPLE_RATE * dur)
        glide_samp = max(1, min(int(SAMPLE_RATE * glide_sec), n_samp // 2))
        for i in range(n_samp):
            if i < glide_samp:
                alpha = 0.5 * (1.0 - math.cos(math.pi * i / glide_samp))
                f = prev_freq + (target_freq - prev_freq) * alpha
            else:
                f = target_freq
            freqs.append(f)
            amps.append(amp)
            vowels.append(vowel)
            note_local_t.append(i / SAMPLE_RATE)
        prev_freq = target_freq

    n = len(freqs)
    out: list[float] = [0.0] * n
    attack_sec = min(0.32, total_duration * 0.18)
    release_sec = min(0.42, total_duration * 0.22)

    phases = [0.0] * 9
    tilts = [0.0] + [1.0 / (k ** 0.88) for k in range(1, 9)]
    drone_freq = NOTES[drone_note] if drone_note else 0.0
    two_pi = 2.0 * math.pi
    inv_sr = 1.0 / SAMPLE_RATE
    sin = math.sin
    cos = math.cos
    pi = math.pi

    for i in range(n):
        t = i * inv_sr
        if t < attack_sec:
            breath_env = 0.5 * (1.0 - cos(pi * t / max(attack_sec, 1e-4)))
        elif t > total_duration - release_sec:
            rem = max(0.0, total_duration - t)
            breath_env = 0.5 * (1.0 - cos(pi * rem / max(release_sec, 1e-4)))
        else:
            breath_env = 0.90 + 0.10 * sin(two_pi * 1.1 * t)

        vib_ramp = min(1.0, note_local_t[i] * 4.0)
        vib = 1.0 + (vibrato_depth * vib_ramp) * sin(two_pi * vibrato_hz * t)
        f0 = freqs[i] * vib
        v_table = _FORMANT_TABLE[vowels[i]]

        sample_val = 0.0
        weight_sum = 0.0
        for k in range(1, 9):
            fk = f0 * k
            idx = int(fk)
            if idx >= 3600:
                break
            phases[k] += two_pi * fk * inv_sr
            w = tilts[k] * v_table[idx]
            sample_val += w * sin(phases[k])
            weight_sum += w

        if weight_sum > 0.0:
            sample_val /= weight_sum

        if drone_freq > 0.0:
            drone_val = (
                0.65 * sin(two_pi * drone_freq * t)
                + 0.35 * sin(two_pi * drone_freq * 2.0 * t)
            )
            sample_val = sample_val * (1.0 - drone_amp) + drone_val * drone_amp

        out[i] = amps[i] * breath_env * sample_val

    return out


def silence(duration: float) -> list[float]:
    return [0.0] * int(SAMPLE_RATE * duration)


def reverb(track: list[float], delay: float = 0.13, decay: float = 0.36, taps: int = 5) -> list[float]:
    """Çoklu gecikmeli kubbe akustiği."""
    out = list(track) + [0.0] * int(SAMPLE_RATE * delay * (taps + 1))
    for tap in range(1, taps + 1):
        offset = int(SAMPLE_RATE * delay * tap)
        gain = decay ** tap
        for i in range(len(track)):
            target = i + offset
            if target < len(out):
                out[target] += track[i] * gain
    return out


def normalize(track: list[float], peak: float = 0.90) -> list[float]:
    maximum = max((abs(v) for v in track), default=0.0)
    if maximum < 1e-9:
        return track
    scale = peak / maximum
    return [max(-1.0, min(1.0, v * scale)) for v in track]


def write_wav(path: str, track: list[float]) -> None:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    data = normalize(track)
    with wave.open(path, 'wb') as handle:
        handle.setnchannels(1)
        handle.setsampwidth(2)
        handle.setframerate(SAMPLE_RATE)
        handle.writeframes(b''.join(struct.pack('<h', int(v * 32767)) for v in data))
    print(f'  ✓ {os.path.relpath(path, ROOT)}  ({os.path.getsize(path) / 1024:.0f} KB)')


# ---------------------------------------------------------------------------
# Telifsiz İslami İlahi & Ney Bildirim Sesleri (Kesinlikle çan sesi içermez)
# ---------------------------------------------------------------------------

def notification_ilahi_ussak() -> list[float]:
    """ezan_ton_1: Uşşak makamında sıcak ney ve ilahi bildirimi (~5.5 sn)."""
    phrase1 = render_legato_phrase(
        [
            ('A2', 0.65, 'U', 0.56),
            ('B2', 0.55, 'NEY', 0.58),
            ('C3', 0.65, 'A', 0.62),
            ('D3', 0.95, 'A', 0.66),
            ('E3', 0.85, 'E', 0.64),
            ('D3', 0.65, 'A', 0.60),
            ('C3', 0.55, 'U', 0.56),
            ('B2', 0.50, 'U', 0.54),
            ('A2', 1.10, 'A', 0.64),
        ],
        vibrato_hz=4.8,
        vibrato_depth=0.0055,
        drone_note='A2',
        drone_amp=0.14,
    )
    return reverb(phrase1, delay=0.14, decay=0.34, taps=4)


def notification_ilahi_rast() -> list[float]:
    """ezan_ton_2: Rast makamında huzurlu ilahi ve tefekkür bildirimi (~5.4 sn)."""
    phrase = render_legato_phrase(
        [
            ('G2', 0.70, 'A', 0.58),
            ('A2', 0.55, 'A', 0.58),
            ('B2', 0.65, 'E', 0.60),
            ('C3', 0.75, 'U', 0.62),
            ('D3', 1.05, 'A', 0.66),
            ('C3', 0.55, 'U', 0.58),
            ('B2', 0.50, 'E', 0.55),
            ('A2', 0.55, 'A', 0.55),
            ('G2', 1.15, 'U', 0.64),
        ],
        vibrato_hz=4.6,
        vibrato_depth=0.005,
        drone_note='G2',
        drone_amp=0.14,
    )
    return reverb(phrase, delay=0.15, decay=0.35, taps=4)


def notification_ilahi_huseyni() -> list[float]:
    """ezan_ton_3: Hüseynî makamında kısa ilahi vakit hatırlatması (~4.2 sn)."""
    phrase = render_legato_phrase(
        [
            ('A2', 0.55, 'A', 0.58),
            ('C3', 0.55, 'U', 0.60),
            ('D3', 0.65, 'A', 0.62),
            ('E3', 0.95, 'E', 0.66),
            ('D3', 0.55, 'A', 0.60),
            ('C3', 0.45, 'U', 0.56),
            ('A2', 0.95, 'A', 0.64),
        ],
        vibrato_hz=4.8,
        vibrato_depth=0.005,
        drone_note='A2',
        drone_amp=0.12,
    )
    return reverb(phrase, delay=0.13, decay=0.32, taps=4)


# ---------------------------------------------------------------------------
# Telifsiz Makam Ezan Tilavetleri (Vokal Formant + Legato Müezzin Seyri)
# ---------------------------------------------------------------------------

def adhan_hicaz_recitation() -> list[float]:
    """ezan_melodi: Hicaz makamında vokal formantlı uzun ezan tilaveti (~45 sn)."""
    phrases: list[list[tuple[str, float, str, float]]] = [
        # 1. Allâhu Ekber — Allâhu Ekber (Karar ve Hicaz giriş)
        [
            ('A2', 1.1, 'A', 0.64), ('A2', 1.4, 'A', 0.66), ('Bb2', 0.8, 'U', 0.60),
            ('C#3', 1.2, 'E', 0.64), ('D3', 1.8, 'E', 0.68),
            ('C#3', 0.9, 'A', 0.60), ('Bb2', 0.9, 'U', 0.58), ('A2', 2.0, 'E', 0.65),
        ],
        # 2. Allâhu Ekber — Allâhu Ekber (Nevâya yükseliş)
        [
            ('A2', 0.9, 'A', 0.62), ('C#3', 1.1, 'A', 0.64), ('D3', 1.5, 'U', 0.68),
            ('E3', 1.2, 'E', 0.66), ('F3', 1.4, 'A', 0.68), ('E3', 1.0, 'E', 0.64),
            ('D3', 1.3, 'A', 0.64), ('C#3', 1.1, 'E', 0.60), ('D3', 2.1, 'E', 0.66),
        ],
        # 3. Eşhedü en lâ ilâhe illallâh
        [
            ('D3', 1.0, 'E', 0.64), ('E3', 1.1, 'E', 0.64), ('F3', 1.3, 'A', 0.66),
            ('E3', 1.0, 'I', 0.62), ('D3', 1.4, 'A', 0.66), ('C#3', 1.2, 'E', 0.62),
            ('Bb2', 1.1, 'I', 0.60), ('C#3', 1.0, 'A', 0.62), ('A2', 2.2, 'A', 0.66),
        ],
        # 4. Eşhedü enne Muhammeden Resûlullâh
        [
            ('D3', 1.1, 'E', 0.64), ('F3', 1.4, 'A', 0.68), ('G3', 1.3, 'E', 0.68),
            ('F3', 1.2, 'A', 0.66), ('E3', 1.1, 'U', 0.64), ('D3', 1.4, 'U', 0.66),
            ('C#3', 1.1, 'A', 0.62), ('Bb2', 1.0, 'A', 0.58), ('A2', 2.2, 'A', 0.66),
        ],
        # 5. Hayye ale's-salâh — Hayye ale'l-felâh — Allâhu Ekber — Lâ ilâhe illallâh
        [
            ('C#3', 1.0, 'A', 0.64), ('D3', 1.4, 'A', 0.68), ('E3', 1.2, 'A', 0.66),
            ('D3', 1.2, 'A', 0.64), ('C#3', 1.0, 'E', 0.62), ('Bb2', 1.1, 'A', 0.60),
            ('A2', 1.4, 'I', 0.62), ('Bb2', 0.9, 'A', 0.58), ('A2', 2.4, 'A', 0.68),
        ],
    ]
    track: list[float] = []
    for p in phrases:
        track += render_legato_phrase(
            p,
            vibrato_hz=5.1,
            vibrato_depth=0.007,
            glide_sec=0.095,
            drone_note='A2',
            drone_amp=0.08,
        )
        track += silence(0.45)
    return reverb(track, delay=0.18, decay=0.40, taps=6)


def adhan_saba_recitation() -> list[float]:
    """ezan_saba: Saba makamında sabah/imsak vokal formantlı ezan tilaveti (~24 sn)."""
    phrases: list[list[tuple[str, float, str, float]]] = [
        # Sabah ezanı Saba girişi: Allâhu Ekber
        [
            ('D3', 1.2, 'A', 0.62), ('E3', 1.0, 'A', 0.62), ('F3', 1.5, 'U', 0.66),
            ('F#3', 1.2, 'E', 0.64), ('F3', 1.3, 'A', 0.64), ('E3', 1.0, 'E', 0.60),
            ('D3', 2.1, 'A', 0.66),
        ],
        # Es-salâtü hayrun mine'n-nevm
        [
            ('F3', 1.2, 'E', 0.64), ('G3', 1.3, 'A', 0.66), ('F#3', 1.3, 'A', 0.66),
            ('F3', 1.4, 'U', 0.64), ('E3', 1.1, 'I', 0.60), ('Eb3', 1.0, 'E', 0.58),
            ('D3', 2.3, 'O', 0.66),
        ],
        # Allâhu Ekber — Lâ ilâhe illallâh
        [
            ('D3', 1.1, 'A', 0.62), ('F3', 1.3, 'A', 0.64), ('E3', 1.1, 'I', 0.60),
            ('Eb3', 1.0, 'A', 0.58), ('D3', 2.5, 'A', 0.66),
        ],
    ]
    track: list[float] = []
    for p in phrases:
        track += render_legato_phrase(
            p,
            vibrato_hz=4.9,
            vibrato_depth=0.0065,
            glide_sec=0.095,
            drone_note='D3',
            drone_amp=0.09,
        )
        track += silence(0.40)
    return reverb(track, delay=0.19, decay=0.40, taps=6)


def adhan_segah_recitation() -> list[float]:
    """ezan_segah: Segâh makamında akşam/yatsı vokal formantlı ezan tilaveti (~24 sn)."""
    phrases: list[list[tuple[str, float, str, float]]] = [
        [
            ('B2', 1.3, 'A', 0.64), ('C3', 1.0, 'A', 0.62), ('D3', 1.5, 'U', 0.66),
            ('Eb3', 1.3, 'E', 0.66), ('D3', 1.2, 'A', 0.64), ('C3', 1.0, 'E', 0.60),
            ('B2', 2.0, 'A', 0.66),
        ],
        [
            ('D3', 1.2, 'E', 0.64), ('E3', 1.3, 'A', 0.66), ('F3', 1.4, 'A', 0.68),
            ('E3', 1.1, 'I', 0.64), ('D3', 1.4, 'A', 0.64), ('C3', 1.1, 'U', 0.60),
            ('B2', 2.1, 'A', 0.66),
        ],
        [
            ('D3', 1.1, 'A', 0.64), ('C3', 1.1, 'I', 0.60), ('B2', 1.2, 'A', 0.62),
            ('A2', 1.0, 'E', 0.58), ('B2', 2.4, 'A', 0.68),
        ],
    ]
    track: list[float] = []
    for p in phrases:
        track += render_legato_phrase(
            p,
            vibrato_hz=5.0,
            vibrato_depth=0.0065,
            glide_sec=0.09,
            drone_note='B2',
            drone_amp=0.09,
        )
        track += silence(0.40)
    return reverb(track, delay=0.18, decay=0.38, taps=5)


def tekbir_recitation() -> list[float]:
    """ezan_tekbir: Itri Segâh Tekbir ve Salâvat vokal çağrısı (~16 sn)."""
    phrases: list[list[tuple[str, float, str, float]]] = [
        [
            ('B2', 1.1, 'A', 0.64), ('D3', 1.0, 'A', 0.64), ('D3', 1.4, 'U', 0.68),
            ('E3', 1.1, 'E', 0.66), ('D3', 1.2, 'A', 0.64), ('C3', 1.0, 'E', 0.60),
            ('B2', 1.9, 'E', 0.66),
        ],
        [
            ('D3', 1.2, 'A', 0.64), ('E3', 1.1, 'A', 0.66), ('D3', 1.1, 'U', 0.64),
            ('C3', 1.1, 'I', 0.60), ('B2', 2.4, 'A', 0.68),
        ],
    ]
    track: list[float] = []
    for p in phrases:
        track += render_legato_phrase(
            p,
            vibrato_hz=4.8,
            vibrato_depth=0.006,
            glide_sec=0.09,
            drone_note='B2',
            drone_amp=0.12,
        )
        track += silence(0.35)
    return reverb(track, delay=0.17, decay=0.38, taps=5)


def ilahi_ussak_full() -> list[float]:
    """ilahi_ussak: Yunus Emre geleneği Uşşak ilahi ve ney taksimi (~26 sn)."""
    phrases: list[list[tuple[str, float, str, float]]] = [
        [
            ('A2', 1.2, 'U', 0.60), ('B2', 1.0, 'NEY', 0.60), ('C3', 1.3, 'A', 0.64),
            ('D3', 1.6, 'A', 0.66), ('E3', 1.4, 'E', 0.66), ('D3', 1.1, 'A', 0.62),
            ('C3', 1.1, 'U', 0.60), ('B2', 1.2, 'NEY', 0.58), ('A2', 2.1, 'A', 0.66),
        ],
        [
            ('D3', 1.2, 'A', 0.64), ('E3', 1.3, 'E', 0.66), ('F3', 1.5, 'A', 0.68),
            ('E3', 1.2, 'U', 0.64), ('D3', 1.4, 'A', 0.64), ('C3', 1.2, 'NEY', 0.60),
            ('B2', 1.1, 'U', 0.58), ('A2', 2.5, 'A', 0.68),
        ],
    ]
    track: list[float] = []
    for p in phrases:
        track += render_legato_phrase(
            p,
            vibrato_hz=4.7,
            vibrato_depth=0.006,
            glide_sec=0.09,
            drone_note='A2',
            drone_amp=0.14,
        )
        track += silence(0.40)
    return reverb(track, delay=0.18, decay=0.38, taps=5)


def ilahi_huseyni_full() -> list[float]:
    """ilahi_huseyni: Hüseynî makamında zikir ve tesbih ilahisi (~25 sn)."""
    phrases: list[list[tuple[str, float, str, float]]] = [
        [
            ('A2', 1.1, 'A', 0.60), ('C3', 1.1, 'U', 0.62), ('D3', 1.3, 'A', 0.64),
            ('E3', 1.8, 'E', 0.68), ('F3', 1.2, 'A', 0.66), ('E3', 1.4, 'U', 0.66),
            ('D3', 1.2, 'A', 0.62), ('C3', 1.3, 'NEY', 0.60),
        ],
        [
            ('E3', 1.5, 'E', 0.66), ('D3', 1.3, 'A', 0.64), ('C3', 1.2, 'U', 0.62),
            ('B2', 1.2, 'NEY', 0.58), ('A2', 2.6, 'A', 0.68),
        ],
    ]
    track: list[float] = []
    for p in phrases:
        track += render_legato_phrase(
            p,
            vibrato_hz=4.6,
            vibrato_depth=0.006,
            glide_sec=0.09,
            drone_note='A2',
            drone_amp=0.14,
        )
        track += silence(0.40)
    return reverb(track, delay=0.17, decay=0.37, taps=5)


def main() -> None:
    print('Telifsiz vokal-formant ezan ve İslami ilahi ses varlıkları üretiliyor…')
    both_outputs = {
        'ezan_ton_1.wav': notification_ilahi_ussak(),
        'ezan_ton_2.wav': notification_ilahi_rast(),
        'ezan_ton_3.wav': notification_ilahi_huseyni(),
        'ezan_melodi.wav': adhan_hicaz_recitation(),
        'ezan_saba.wav': adhan_saba_recitation(),
        'ezan_segah.wav': adhan_segah_recitation(),
        'ezan_tekbir.wav': tekbir_recitation(),
    }
    for name, track in both_outputs.items():
        write_wav(os.path.join(ASSETS, name), track)
        write_wav(os.path.join(RAW, name), track)

    asset_only = {
        'ilahi_ussak.wav': ilahi_ussak_full(),
        'ilahi_huseyni.wav': ilahi_huseyni_full(),
    }
    for name, track in asset_only.items():
        write_wav(os.path.join(ASSETS, name), track)
    print('Tamamlandı.')


if __name__ == '__main__':
    main()
