#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""EzanAI — telifsiz bildirim tonları ve ezan melodisi üretir (saf Python, bağımlılıksız).

Çalınan sesler enstrümantal ton dizileridir; hiçbir telifli kayıt kullanılmaz.
Çıktılar:
  assets/audio/adhan/*.wav         → uygulama içi oynatma
  android/app/src/main/res/raw/*.wav → bildirim sesleri
"""
from __future__ import annotations

import math
import os
import struct
import wave

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
ASSETS = os.path.join(ROOT, 'assets', 'audio', 'adhan')
RAW = os.path.join(ROOT, 'android', 'app', 'src', 'main', 'res', 'raw')
SAMPLE_RATE = 22050  # bildirim sesleri için yeterli, dosya boyutunu yarıya indirir


def note(freq: float, duration: float, amplitude: float = 0.6, decay: float = 3.0,
         harmonics: tuple[float, ...] = (1.0, 0.35, 0.18, 0.08)) -> list[float]:
    """Üstel sönümlü, harmonik zenginleştirilmiş bir nota üretir."""
    samples = int(SAMPLE_RATE * duration)
    out: list[float] = []
    for i in range(samples):
        t = i / SAMPLE_RATE
        env = math.exp(-decay * t / max(duration, 1e-6))
        # yumuşak giriş (tık sesini engeller)
        attack = min(1.0, t / 0.012)
        value = 0.0
        for index, weight in enumerate(harmonics, start=1):
            value += weight * math.sin(2 * math.pi * freq * index * t)
        out.append(amplitude * env * attack * value / sum(harmonics))
    return out


def silence(duration: float) -> list[float]:
    return [0.0] * int(SAMPLE_RATE * duration)


def reverb(track: list[float], delay: float = 0.11, decay: float = 0.35, taps: int = 4) -> list[float]:
    """Basit çoklu gecikmeli yankı — mekân hissi verir."""
    out = list(track)
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


# Nota frekansları (A4 = 440)
NOTES = {
    'D4': 293.66, 'E4': 329.63, 'F4': 349.23, 'G4': 392.00, 'A4': 440.00, 'B4': 493.88,
    'C5': 523.25, 'D5': 587.33, 'E5': 659.25, 'F5': 698.46, 'G5': 783.99, 'A5': 880.00,
    'D3': 146.83, 'A3': 220.00, 'C4': 261.63,
}


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
    """Ezan vaktinde uygulama içi çalınan enstrümantal melodi (~45 sn).

    Telifli bir ezan kaydı değildir; çağrı hissini veren, sönümlü çan
    dizilerinden oluşan özgün bir kompozisyondur.
    """
    sequence: list[tuple[str, float, float]] = [
        ('A3', 1.6, 0.62), ('A3', 1.2, 0.55), ('C4', 1.4, 0.55), ('D4', 1.6, 0.6),
        ('E4', 2.0, 0.6), ('D4', 1.2, 0.5), ('C4', 1.4, 0.5), ('A3', 2.2, 0.6),
        ('D4', 1.5, 0.58), ('E4', 1.6, 0.58), ('F4', 1.8, 0.6), ('E4', 1.4, 0.52),
        ('D4', 2.4, 0.6),
        ('A3', 1.4, 0.55), ('C4', 1.3, 0.52), ('D4', 1.5, 0.55), ('E4', 1.7, 0.56),
        ('G4', 1.9, 0.58), ('E4', 1.3, 0.5), ('D4', 1.5, 0.5), ('C4', 2.6, 0.6),
        ('A3', 2.4, 0.55), ('C4', 1.4, 0.5), ('D4', 3.0, 0.6),
    ]
    track: list[float] = []
    for name, duration, amp in sequence:
        track += note(NOTES[name], duration, amplitude=amp, decay=1.5)
        track += silence(0.1)
    track += silence(1.2)
    return reverb(track, delay=0.19, decay=0.38, taps=5)


def main() -> None:
    print('Ses varlıkları üretiliyor…')
    outputs = {
        'ezan_ton_1.wav': tone_soft_bell(),
        'ezan_ton_2.wav': tone_deep(),
        'ezan_ton_3.wav': tone_short(),
        'ezan_melodi.wav': adhan_melody(),
    }
    for name, track in outputs.items():
        write_wav(os.path.join(ASSETS, name), track)
        write_wav(os.path.join(RAW, name), track)
    print('Tamamlandı.')


if __name__ == '__main__':
    main()
