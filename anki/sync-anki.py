#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.10"
# dependencies = ["genanki"]
# ///
"""
将 JSON 文件同步为 Anki APKG 卡包

JSON 格式：
{
  "deck_name": "颉斌斌66句长难句",
  "notes": [
    {
      "sentence": "66句第1句  Of all the changes...",
      "qa": [
        {"q": "问题内容", "a": "答案内容"},
        {"q": "问题2", "a": "答案2"}
      ]
    }
  ]
}

用法：
  uv run sync-anki.py                          # 默认读取同目录下 anki-data.json
  uv run sync-anki.py input.json output.apkg   # 指定输入输出
"""

import json
import sys
import os
import random

def ensure_genanki():
    import genanki
    return genanki

def build_deck(data):
    genanki = ensure_genanki()

    num_slots = max(len(n.get("qa", [])) for n in data["notes"]) if data["notes"] else 5
    num_slots = max(num_slots, 1)

    fields = [{"name": "句子"}]
    for i in range(1, num_slots + 1):
        fields.append({"name": "问题" + str(i)})
        fields.append({"name": "答案" + str(i)})

    templates = []
    for i in range(1, num_slots + 1):
        qf = "问题" + str(i)
        af = "答案" + str(i)
        templates.append({
            "name": "问题" + str(i),
            "qfmt": (
                '<div style="font-size:16px;line-height:1.8;padding:12px;background:#e8e8e8;border-radius:8px;margin-bottom:16px;color:#000;">{{句子}}</div>'
                '<div style="font-size:18px;font-weight:bold;color:#000;">问题' + str(i) + '：{{' + qf + '}}</div>'
            ),
            "afmt": (
                '{{FrontSide}}<hr id="answer">'
                '<div style="font-size:18px;color:#000;margin-top:12px;">{{' + af + '}}</div>'
            ),
        })

    model = genanki.Model(
        random.randrange(1 << 30, 1 << 31),
        "长难句多问题",
        fields=fields,
        templates=templates,
    )

    deck = genanki.Deck(
        random.randrange(1 << 30, 1 << 31),
        data.get("deck_name", "未命名卡包")
    )

    for note_data in data["notes"]:
        sentence = note_data["sentence"]
        qa_list = note_data.get("qa", [])
        fields_data = [sentence]
        for i in range(num_slots):
            if i < len(qa_list):
                fields_data.append(qa_list[i].get("q", ""))
                fields_data.append(qa_list[i].get("a", ""))
            else:
                fields_data.append("")
                fields_data.append("")
        note = genanki.Note(model=model, fields=fields_data)
        deck.add_note(note)

    return deck

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))

    if len(sys.argv) >= 3:
        input_file = sys.argv[1]
        output_file = sys.argv[2]
    elif len(sys.argv) == 2:
        input_file = sys.argv[1]
        output_file = os.path.join(os.path.expanduser("~"), "anki-output.apkg")
    else:
        input_file = os.path.join(script_dir, "anki-data.json")
        output_file = os.path.join(os.path.expanduser("~"), "anki-output.apkg")

    if not os.path.exists(input_file):
        print(f"Error: {input_file} not found")
        sys.exit(1)

    with open(input_file, "r", encoding="utf-8") as f:
        data = json.load(f)

    genanki = ensure_genanki()
    deck = build_deck(data)
    genanki.Package(deck).write_to_file(output_file)

    total_cards = sum(1 for n in data["notes"] for _ in n.get("qa", []))
    print(f"Done: {output_file}")
    print(f"  {len(data['notes'])} sentences, {total_cards} cards")

if __name__ == "__main__":
    main()
