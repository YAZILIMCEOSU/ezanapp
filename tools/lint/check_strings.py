"""Dart dosyalarında dize değişmezlerini tarayan basit bir denetleyici.

Amaç: tek tırnaklı dizelerde kaçırılmamış kesme işareti (') kaynaklı
sözdizimi hatalarını CI'ya gitmeden yakalamak.
"""
import pathlib
import sys


def scan(path: pathlib.Path) -> list[tuple[int, int, str]]:
    text = path.read_text()
    problems: list[tuple[int, int, str]] = []
    index = 0
    line = 1
    length = len(text)
    while index < length:
        char = text[index]
        if char == '\n':
            line += 1
            index += 1
            continue
        if char == '/' and index + 1 < length and text[index + 1] == '/':
            while index < length and text[index] != '\n':
                index += 1
            continue
        if char == '/' and index + 1 < length and text[index + 1] == '*':
            index += 2
            while index + 1 < length and not (text[index] == '*' and text[index + 1] == '/'):
                if text[index] == '\n':
                    line += 1
                index += 1
            index += 2
            continue
        if char in ('"', "'"):
            quote = char
            # üçlü tırnak mı?
            triple = text[index:index + 3] == quote * 3
            start_line = line
            index += 3 if triple else 1
            closed = False
            while index < length:
                current = text[index]
                if current == '\\':
                    index += 2
                    continue
                if current == '\n':
                    line += 1
                    if not triple:
                        break
                    index += 1
                    continue
                if triple:
                    if text[index:index + 3] == quote * 3:
                        index += 3
                        closed = True
                        break
                elif current == quote:
                    index += 1
                    closed = True
                    break
                # dize içinde kaçırılmamış kesme işareti şüphesi:
                # tek tırnaklı dize içinde çift tırnak serbest, tersi de öyle.
                index += 1
            if not closed:
                problems.append((start_line, index, 'kapatılmamış dize'))
            continue
        index += 1
    return problems


def main() -> int:
    roots = sys.argv[1:] or ['lib', 'test', 'integration_test']
    total = 0
    for root in roots:
        base = pathlib.Path(root)
        if not base.exists():
            continue
        for path in sorted(base.rglob('*.dart')):
            for line, column, message in scan(path):
                total += 1
                print(f'{path}:{line}:{column}: {message}')
    print(f'denetlenen dosya sorunu: {total}')
    return 1 if total else 0


if __name__ == '__main__':
    sys.exit(main())
