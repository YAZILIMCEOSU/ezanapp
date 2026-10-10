#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""EzanAI — telifsiz bildirim tonları, ezan makamları ve dini/ilahi ezgileri üretir.

Çalınan sesler geleneksel makam dizilerine (Hicaz, Saba, Segâh, Uşşak, Hüseynî)
dayalı telifsiz enstrümantal kompozisyonlardır; hiçbir telifli kayıt kullanılmaz.
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


def note(
    freq: float,
    duration: float,
    amplitude: float = 0.6,
    decay: float = 3.0,
    harmonics: tuple[float, ...] = (1.0, 0.35, 0.18, 0.08),
    vibrato_hz: float = 0.0,
    vibrato_depth: float = 0.003,
) -> list[float]:
    """Üstel sönümlü, harmonik ve hafif vibratolu bir nota üretir."""
    samples = int(SAMPLE_RATE * duration)
    out: list[float] = []
    h_sum = sum(harmonics)
    for i in range(samples):
        t = i / SAMPLE_RATE
        env = math.exp(-decay * t / max(duration, 1e-6))
        attack = min(1.0, t / 0.025)
        release = min(1.0, (duration - t) / 0.03) if duration > 0.06 else 1.0
        inst_freq = freq * (1.0 + vibrato_depth * math.sin(2 * math.pi * vibrato_hz * t)) if vibrato_hz > 0 else freq
        value = 0.0
        for index, weight in enumerate(harmonics, start=1):
            value += weight * math.sin(2 * math.pi * inst_freq * index * t)
        out.append(amplitude * env * attack * release * value / h_sum)
    return out


def silence(duration: float) -> list[float]:
    return [0.0] * int(SAMPLE_RATE * duration)


def reverb(track: list[float], delay: float = 0.11, decay: float = 0.35, taps: int = 4) -> list[float]:
    """Çoklu gecikmeli yankı — cami/kubbe akustiği hissi verir."""
    out = list(track) + [0.0] * int(SAMPLE_RATE * delay * (taps + 1))
    for tap in range(1, taps + 1):
        offset = int(SAMPLE_RATE * delay * tap)
        gain = decay ** tap
        for i in range(len(track)):
            target = i + offset
            if target < len(out):
                out[target] += track[i] * gain
    return out


def normalize(track: list[float], peak: float = 0.92) -> list[float]:
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


# Makam perdeleri (Hz)
NOTES = {
    'D3': 146.83, 'G3': 196.00, 'A3': 220.00, 'Bb3': 233.08, 'B3': 246.94,
    'C4': 261.63, 'C#4': 277.18, 'D4': 293.66, 'Eb4': 311.13, 'E4': 329.63,
    'F4': 349.23, 'F#4': 369.99, 'G4': 392.00, 'Ab4': 415.30, 'A4': 440.00,
    'Bb4': 466.16, 'B4': 493.88, 'C5': 523.25, 'D5': 587.33, 'E5': 659.25,
    'F5': 698.46, 'G5': 783.99, 'A5': 880.00,
}

NEY_HARMONICS = (1.0, 0.48, 0.28, 0.14, 0.07)
UD_HARMONICS = (1.0, 0.55, 0.30, 0.18, 0.10, 0.05)


def tone_soft_bell() -> list[float]:
    """Huzurlu, yumuşak çan dizesi."""
    track: list[float] = []
    for name, duration, amp in (('A4', 0.9, 0.55), ('E5', 0.9, 0.5), ('C5', 1.5, 0.45)):
        track += note(NOTES[name], duration, amplitude=amp, decay=2.2)
        track += silence(0.05)
    return reverb(track, delay=0.13, decay=0.3)


def tone_deep() -> list[float]:
    """Derin, sakin uyarı."""
    track: list[float] = []
    for name, duration, amp in (('D4', 1.1, 0.6), ('A4', 1.6, 0.5)):
        track += note(NOTES[name], duration, amplitude=amp, decay=1.8,
                      harmonics=(1.0, 0.25, 0.12, 0.05))
        track += silence(0.04)
    return reverb(track, delay=0.16, decay=0.34)


def tone_short() -> list[float]:
    """Kısa, dikkat çekici iki nota."""
    track: list[float] = []
    track += note(NOTES['E5'], 0.32, amplitude=0.6, decay=5.0)
    track += silence(0.06)
    track += note(NOTES['A5'], 0.55, amplitude=0.55, decay=3.4)
    return reverb(track, delay=0.09, decay=0.28, taps=3)


def adhan_melody() -> list[float]:
    """Hicaz makamında uzun ezan çağrı melodisi (~45 sn)."""
    sequence: list[tuple[str, float, float]] = [
        ('A3', 1.6, 0.62), ('A3', 1.2, 0.55), ('Bb3', 1.4, 0.55), ('C#4', 1.6, 0.6),
        ('D4', 2.0, 0.62), ('C#4', 1.2, 0.52), ('Bb3', 1.4, 0.52), ('A3', 2.2, 0.6),
        ('D4', 1.5, 0.58), ('E4', 1.6, 0.58), ('F4', 1.8, 0.6), ('E4', 1.4, 0.52),
        ('D4', 2.4, 0.6),
        ('A3', 1.4, 0.55), ('Bb3', 1.3, 0.52), ('C#4', 1.5, 0.55), ('D4', 1.7, 0.58),
        ('F4', 1.9, 0.58), ('E4', 1.3, 0.52), ('C#4', 1.5, 0.52), ('Bb3', 2.4, 0.58),
        ('A3', 2.4, 0.55), ('Bb3', 1.4, 0.5), ('A3', 3.0, 0.62),
    ]
    track: list[float] = []
    for name, duration, amp in sequence:
        track += note(NOTES[name], duration, amplitude=amp, decay=1.4,
                      harmonics=NEY_HARMONICS, vibrato_hz=4.5, vibrato_depth=0.003)
        track += silence(0.1)
    track += silence(1.0)
    return reverb(track, delay=0.19, decay=0.38, taps=5)


def saba_melody() -> list[float]:
    """Saba makamında sabah/imsak ezan ve seher ezgisi (~22 sn)."""
    sequence: list[tuple[str, float, float]] = [
        ('D4', 1.5, 0.58), ('E4', 1.2, 0.54), ('F4', 1.8, 0.62), ('Gb', 1.4, 0.56),
        ('F4', 1.6, 0.58), ('E4', 1.1, 0.52), ('D4', 2.0, 0.60),
        ('A4', 1.5, 0.58), ('Bb4', 1.3, 0.55), ('A4', 1.4, 0.56), ('F4', 1.8, 0.60),
        ('E4', 1.3, 0.52), ('D4', 2.6, 0.62),
    ]
    notes = dict(NOTES, Gb=369.99)
    track: list[float] = []
    for name, duration, amp in sequence:
        track += note(notes[name], duration, amplitude=amp, decay=1.35,
                      harmonics=NEY_HARMONICS, vibrato_hz=4.2, vibrato_depth=0.003)
        track += silence(0.08)
    return reverb(track, delay=0.20, decay=0.40, taps=5)


def segah_melody() -> list[float]:
    """Segâh makamında akşam/yatsı ezan ve salâvat ezgisi (~22 sn)."""
    sequence: list[tuple[str, float, float]] = [
        ('B3', 1.6, 0.58), ('C4', 1.2, 0.54), ('D4', 1.7, 0.60), ('Eb4', 1.5, 0.58),
        ('D4', 1.4, 0.56), ('C4', 1.3, 0.54), ('B3', 2.1, 0.62),
        ('D4', 1.4, 0.58), ('F4', 1.6, 0.60), ('E4', 1.3, 0.55), ('D4', 1.6, 0.58),
        ('C4', 1.3, 0.52), ('B3', 2.5, 0.62),
    ]
    track: list[float] = []
    for name, duration, amp in sequence:
        track += note(NOTES[name], duration, amplitude=amp, decay=1.4,
                      harmonics=NEY_HARMONICS, vibrato_hz=4.0, vibrato_depth=0.0025)
        track += silence(0.08)
    return reverb(track, delay=0.18, decay=0.38, taps=5)


def tekbir_melody() -> list[float]:
    """Itri Segâh Tekbir ve Salâ çağrısı esintili telifsiz ezgi (~14 sn)."""
    sequence: list[tuple[str, float, float]] = [
        ('B3', 1.2, 0.62), ('D4', 1.1, 0.60), ('D4', 1.4, 0.64),
        ('E4', 1.1, 0.58), ('D4', 1.2, 0.58), ('C4', 1.1, 0.55), ('B3', 1.8, 0.62),
        ('D4', 1.2, 0.60), ('C4', 1.1, 0.55), ('B3', 2.2, 0.64),
    ]
    track: list[float] = []
    for name, duration, amp in sequence:
        track += note(NOTES[name], duration, amplitude=amp, decay=1.5,
                      harmonics=UD_HARMONICS, vibrato_hz=3.8, vibrato_depth=0.002)
        track += silence(0.06)
    return reverb(track, delay=0.17, decay=0.36, taps=4)


def ilahi_ussak() -> list[float]:
    """Uşşak makamında Yunus Emre ilahi geleneği esintili tefekkür ezgisi (~25 sn)."""
    sequence: list[tuple[str, float, float]] = [
        ('A3', 1.2, 0.56), ('B3', 1.0, 0.52), ('C4', 1.4, 0.58), ('D4', 1.6, 0.62),
        ('E4', 1.5, 0.60), ('D4', 1.1, 0.55), ('C4', 1.2, 0.54), ('B3', 1.4, 0.52),
        ('A3', 2.0, 0.60),
        ('D4', 1.3, 0.58), ('E4', 1.3, 0.58), ('F4', 1.5, 0.60), ('E4', 1.2, 0.56),
        ('D4', 1.4, 0.58), ('C4', 1.2, 0.54), ('B3', 1.2, 0.52), ('A3', 2.4, 0.62),
    ]
    track: list[float] = []
    for name, duration, amp in sequence:
        track += note(NOTES[name], duration, amplitude=amp, decay=1.45,
                      harmonics=NEY_HARMONICS, vibrato_hz=4.4, vibrato_depth=0.003)
        track += silence(0.07)
    return reverb(track, delay=0.18, decay=0.38, taps=5)


def ilahi_huseyni() -> list[float]:
    """Hüseynî makamında zikir ve tesbih halkası ezgisi (~24 sn)."""
    sequence: list[tuple[str, float, float]] = [
        ('A3', 1.1, 0.55), ('C4', 1.1, 0.55), ('D4', 1.3, 0.58), ('E4', 1.8, 0.62),
        ('F4', 1.2, 0.58), ('E4', 1.4, 0.60), ('D4', 1.2, 0.56), ('C4', 1.3, 0.54),
        ('E4', 1.5, 0.60), ('D4', 1.2, 0.56), ('C4', 1.1, 0.54), ('B3', 1.2, 0.52),
        ('A3', 2.5, 0.62),
    ]
    track: list[float] = []
    for name, duration, amp in sequence:
        track += note(NOTES[name], duration, amplitude=amp, decay=1.5,
                      harmonics=UD_HARMONICS, vibrato_hz=4.0, vibrato_depth=0.0025)
        track += silence(0.07)
    return reverb(track, delay=0.17, decay=0.36, taps=5)


def main() -> None:
    print('Ses varlıkları üretiliyor…')
    both_outputs = {
        'ezan_ton_1.wav': tone_soft_bell(),
        'ezan_ton_2.wav': tone_deep(),
        'ezan_ton_3.wav': tone_short(),
        'ezan_melodi.wav': adhan_melody(),
        'ezan_saba.wav': saba_melody(),
        'ezan_segah.wav': segah_melody(),
        'ezan_tekbir.wav': tekbir_melody(),
    }
    for name, track in both_outputs.items():
        write_wav(os.path.join(ASSETS, name), track)
        write_wav(os.path.join(RAW, name), track)

    asset_only = {
        'ilahi_ussak.wav': ilahi_ussak(),
        'ilahi_huseyni.wav': ilahi_huseyni(),
    }
    for name, track in asset_only.items():
        write_wav(os.path.join(ASSETS, name), track)
    print('Tamamlandı.')


if __name__ == '__main__':
    main()
