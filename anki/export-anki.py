#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.10"
# dependencies = []
# ///
"""
从 Anki 数据库导出笔记到 JSON 文件

用法：
  uv run export-anki.py                                    # 默认导出到同目录 anki-data.json
  uv run export-anki.py --output /path/to/anki-data.json   # 指定输出文件
  uv run export-anki.py --model-id 1230052262              # 指定模型ID
"""

import sqlite3
import json
import os
import sys
import re
import argparse
from pathlib import Path

def find_anki_db():
    """查找 Anki 数据库路径"""
    possible = [
        Path.home() / ".local/share/Anki2",
        Path.home() / "AppData/Roaming/Anki2",
        Path.home() / "Library/Application Support/Anki2",
    ]
    for base in possible:
        if base.exists():
            for profile in base.iterdir():
                db = profile / "collection.anki2"
                if db.exists():
                    return str(db)
    return None

def export_deck(db_path, model_id, output_path):
    conn = sqlite3.connect(db_path)
    c = conn.cursor()

    # 获取模型字段信息
    c.execute("SELECT models FROM col")
    row = c.fetchone()
    models = json.loads(row[0]) if row and row[0] else {}

    if str(model_id) in models:
        model = models[str(model_id)]
        num_fields = len(model["flds"])
    else:
        # 自动检测字段数
        c.execute("SELECT flds FROM notes WHERE mid = ? LIMIT 1", (model_id,))
        sample = c.fetchone()
        if not sample:
            print(f"Error: no notes found for model {model_id}")
            sys.exit(1)
        fields = sample[0].split("\x1f")
        num_fields = len(fields)

    # 导出笔记
    c.execute("SELECT flds FROM notes WHERE mid = ?", (model_id,))
    notes = []
    for r in c.fetchall():
        fields = r[0].split("\x1f")
        sentence = fields[0] if fields else ""
        qa = []
        for i in range(1, num_fields - 1, 2):
            q = fields[i] if i < len(fields) else ""
            a = fields[i + 1] if i + 1 < len(fields) else ""
            if q or a:
                qa.append({"q": q, "a": a})
        notes.append({"sentence": sentence, "qa": qa})

    # 按句子编号排序
    def sort_key(note):
        m = re.search(r'第(\d+)句', note["sentence"])
        return int(m.group(1)) if m else 0
    notes.sort(key=sort_key)

    data = {"deck_name": "颉斌斌66句长难句", "notes": notes}

    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    total_qa = sum(len(n["qa"]) for n in notes)
    print(f"Done: {output_path}")
    print(f"  {len(notes)} sentences, {total_qa} Q&A pairs exported")
    conn.close()

def main():
    parser = argparse.ArgumentParser(description="Export Anki notes to JSON")
    parser.add_argument("--model-id", type=int, default=1230052262, help="Note model ID")
    parser.add_argument("--output", default=None, help="Output JSON path")
    parser.add_argument("--db", default=None, help="Anki database path")
    args = parser.parse_args()

    db_path = args.db or find_anki_db()
    if not db_path or not os.path.exists(db_path):
        print("Error: Anki database not found")
        sys.exit(1)

    output = args.output or os.path.join(os.path.dirname(os.path.abspath(__file__)), "anki-data.json")
    export_deck(db_path, args.model_id, output)

if __name__ == "__main__":
    main()
