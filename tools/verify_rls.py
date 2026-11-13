#!/usr/bin/env python3
"""Supabase RLS politikalarını statik olarak denetler.

Canlı veritabanına bağlanmaz; `supabase/schema.sql` içindeki politikaların
varlığını ve sahiplik koşullarını doğrular. Amaç, yanlışlıkla `using (true)`
gibi herkese açık bir politika eklenmesini veya bir CRUD politikasının
silinmesini CI'da yakalamaktır.

Çıkış kodu 0 = tüm kontroller geçti, 1 = en az bir kontrol başarısız.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SCHEMA = ROOT / "supabase" / "schema.sql"

CHECKS: list[tuple[str, bool]] = []


def check(name: str, condition: bool, detail: str = "") -> None:
    CHECKS.append((name, condition))
    mark = "OK  " if condition else "FAIL"
    print(f"[{mark}] {name}{(' — ' + detail) if detail and not condition else ''}")


def strip_comments(sql: str) -> str:
    return "\n".join(line.split("--", 1)[0] for line in sql.splitlines())


def policy_blocks(sql: str) -> list[tuple[str, str]]:
    """(başlık, gövde) çiftlerini döner."""
    blocks: list[tuple[str, str]] = []
    pattern = re.compile(
        r"create\s+policy\s+(\"[^\"]+\"|\w+)\s+on\s+public\.user_data\s+"
        r"for\s+(select|insert|update|delete)\s+(.*?);",
        re.IGNORECASE | re.DOTALL,
    )
    for match in pattern.finditer(sql):
        blocks.append((match.group(2).lower(), match.group(3).strip()))
    return blocks


def main() -> int:
    if not SCHEMA.exists():
        print(f"Şema bulunamadı: {SCHEMA}")
        return 1

    raw = SCHEMA.read_text(encoding="utf-8")
    sql = strip_comments(raw)
    lower = sql.lower()

    check("user_data tablosu tanımlı", "create table if not exists public.user_data" in lower)
    check("RLS etkin", "alter table public.user_data enable row level security" in lower)
    check(
        "RLS zorunlu (force)",
        "alter table public.user_data force row level security" in lower,
    )
    check(
        "auth.users'a cascade silme",
        re.search(
            r"references\s+auth\.users\s*\(\s*id\s*\)\s+on\s+delete\s+cascade",
            lower,
        )
        is not None,
    )
    check(
        "payload boyut sınırı (10 MB)",
        "user_data_payload_size" in lower and "10 * 1024 * 1024" in lower,
    )

    policies = policy_blocks(sql)
    by_command: dict[str, list[str]] = {}
    for command, body in policies:
        by_command.setdefault(command, []).append(body)

    for command in ("select", "insert", "update", "delete"):
        bodies = by_command.get(command, [])
        check(f"{command.upper()} politikası var", len(bodies) == 1, f"{len(bodies)} adet")
        if len(bodies) == 1:
            check(
                f"{command.upper()} politikası sahiplik kontrolü içeriyor",
                "auth.uid()=user_id" in bodies[0].lower().replace(" ", ""),
            )
            if command == "insert":
                check("INSERT with check içeriyor", "with check" in bodies[0].lower())
            if command == "update":
                check(
                    "UPDATE using + with check içeriyor",
                    "using" in bodies[0].lower() and "with check" in bodies[0].lower(),
                )

    risky = [
        match.group(0)
        for match in re.finditer(r"(using|with check)\s*\(\s*true\s*\)", lower)
    ]
    check("Herkese açık (true) politika yok", not risky, "; ".join(risky))

    failed = [name for name, ok in CHECKS if not ok]
    print(f"\n{len(CHECKS) - len(failed)}/{len(CHECKS)} kontrol geçti.")
    if failed:
        print("Başarısız:", ", ".join(failed))
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
