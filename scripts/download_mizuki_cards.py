#!/usr/bin/env python3
"""Download Akiyama Mizuki high-resolution card PNGs.

Default usage from this repo:

    python3 scripts/download_mizuki_cards.py

Files are saved to ./download by default. The script uses PJSK master card
data to find Mizuki cards, then downloads card_normal.png and
card_after_training.png from public asset storage when those files exist.
"""

from __future__ import annotations

import argparse
import json
import shutil
import sys
import time
from pathlib import Path
from typing import Any
from urllib.error import HTTPError, URLError
from urllib.parse import quote
from urllib.request import Request, urlopen


DEFAULT_CHARACTER_ID = 25
DEFAULT_CARDS_URL = "https://sekai-world.github.io/sekai-master-db-diff/cards.json"
DEFAULT_ASSET_BASES = (
    "https://storage.pjsk.moe/sekai-jp-assets",
    "https://storage.sekai.best/sekai-jp-assets",
)
PNG_MAGIC = b"\x89PNG\r\n\x1a\n"


class DownloadError(RuntimeError):
    pass


def request_url(url: str, timeout: int) -> bytes:
    req = Request(url, headers={"User-Agent": "mizuki-card-downloader/1.0"})
    with urlopen(req, timeout=timeout) as response:
        return response.read()


def fetch_json(url: str, timeout: int) -> Any:
    data = request_url(url, timeout)
    return json.loads(data.decode("utf-8"))


def read_json_file(path: Path) -> Any:
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def normalize_asset_base(base: str) -> str:
    return base.rstrip("/")


def build_card_url(asset_base: str, assetbundle_name: str, image_name: str) -> str:
    safe_bundle = quote(assetbundle_name.strip("/"))
    return f"{normalize_asset_base(asset_base)}/character/member/{safe_bundle}/{image_name}"


def card_label(card: dict[str, Any]) -> str:
    prefix = str(card.get("prefix", "")).strip()
    if prefix:
        return prefix
    return str(card.get("cardId") or card.get("id") or "card")


def output_name(card: dict[str, Any], variant: str) -> str:
    card_id = int(card.get("id") or card.get("cardId") or 0)
    assetbundle = str(card["assetbundleName"])
    safe_assetbundle = "".join(
        ch if ch.isalnum() or ch in ("-", "_") else "_" for ch in assetbundle
    )
    return f"{card_id:04d}_{safe_assetbundle}_{variant}.png"


def is_missing_error(exc: BaseException) -> bool:
    return isinstance(exc, HTTPError) and exc.code in {403, 404}


def download_png(
    urls: list[str],
    dest: Path,
    timeout: int,
    overwrite: bool,
    dry_run: bool,
) -> tuple[str, str | None]:
    if dest.exists() and not overwrite:
        return "exists", None

    if dry_run:
        return "dry-run", urls[0]

    last_error: BaseException | None = None
    for url in urls:
        try:
            req = Request(url, headers={"User-Agent": "mizuki-card-downloader/1.0"})
            with urlopen(req, timeout=timeout) as response:
                tmp = dest.with_suffix(dest.suffix + ".part")
                tmp.parent.mkdir(parents=True, exist_ok=True)
                with tmp.open("wb") as handle:
                    shutil.copyfileobj(response, handle)

            with tmp.open("rb") as handle:
                if handle.read(len(PNG_MAGIC)) != PNG_MAGIC:
                    tmp.unlink(missing_ok=True)
                    raise DownloadError(f"not a PNG: {url}")

            tmp.replace(dest)
            return "downloaded", url
        except (HTTPError, URLError, TimeoutError, DownloadError) as exc:
            last_error = exc
            dest.with_suffix(dest.suffix + ".part").unlink(missing_ok=True)
            if isinstance(exc, DownloadError):
                continue
            if is_missing_error(exc):
                continue
            time.sleep(0.5)

    if last_error is None or is_missing_error(last_error):
        return "missing", None
    return "failed", str(last_error)


def mizuki_cards(cards: list[dict[str, Any]], character_id: int) -> list[dict[str, Any]]:
    filtered = [
        card
        for card in cards
        if int(card.get("characterId", -1)) == character_id
        and card.get("assetbundleName")
    ]
    return sorted(filtered, key=lambda card: int(card.get("id") or card.get("cardId") or 0))


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Download all Akiyama Mizuki card PNGs to ./download."
    )
    parser.add_argument(
        "--output",
        default="download",
        type=Path,
        help="Output directory. Defaults to ./download.",
    )
    parser.add_argument(
        "--character-id",
        default=DEFAULT_CHARACTER_ID,
        type=int,
        help="PJSK characterId to download. Mizuki is 25.",
    )
    parser.add_argument(
        "--cards-url",
        default=DEFAULT_CARDS_URL,
        help="Master cards.json URL.",
    )
    parser.add_argument(
        "--cards-file",
        type=Path,
        help="Read master cards JSON from a local file instead of downloading it.",
    )
    parser.add_argument(
        "--asset-base",
        action="append",
        help=(
            "Asset base URL. Can be passed more than once. Defaults to "
            "storage.pjsk.moe first, then storage.sekai.best as fallback."
        ),
    )
    parser.add_argument(
        "--overwrite",
        action="store_true",
        help="Overwrite existing PNG files.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print planned downloads without writing PNG files.",
    )
    parser.add_argument(
        "--limit",
        type=int,
        default=0,
        help="Only process the first N cards. Useful for testing.",
    )
    parser.add_argument(
        "--timeout",
        type=int,
        default=30,
        help="Network timeout in seconds.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    asset_bases = args.asset_base or list(DEFAULT_ASSET_BASES)

    if args.cards_file:
        print(f"Reading card master data: {args.cards_file}", file=sys.stderr)
        cards = read_json_file(args.cards_file)
    else:
        print(f"Fetching card master data: {args.cards_url}", file=sys.stderr)
        cards = fetch_json(args.cards_url, args.timeout)
    if not isinstance(cards, list):
        raise DownloadError("cards.json did not contain a list")

    target_cards = mizuki_cards(cards, args.character_id)
    if args.limit > 0:
        target_cards = target_cards[: args.limit]

    args.output.mkdir(parents=True, exist_ok=True)
    print(
        f"Found {len(target_cards)} cards for characterId={args.character_id}. "
        f"Saving to {args.output}",
        file=sys.stderr,
    )

    stats = {"downloaded": 0, "exists": 0, "missing": 0, "failed": 0, "dry-run": 0}
    variants = {
        "normal": "card_normal.png",
        "trained": "card_after_training.png",
    }

    for card in target_cards:
        assetbundle = str(card["assetbundleName"])
        for variant, image_name in variants.items():
            dest = args.output / output_name(card, variant)
            urls = [
                build_card_url(asset_base, assetbundle, image_name)
                for asset_base in asset_bases
            ]
            status, detail = download_png(
                urls=urls,
                dest=dest,
                timeout=args.timeout,
                overwrite=args.overwrite,
                dry_run=args.dry_run,
            )
            stats[status] += 1
            if status in {"downloaded", "dry-run"}:
                print(f"{status:10} {dest} <- {detail}")
            elif status == "exists":
                print(f"{status:10} {dest}")
            elif status == "missing":
                print(f"{status:10} {assetbundle}/{image_name}")
            else:
                print(f"{status:10} {assetbundle}/{image_name}: {detail}", file=sys.stderr)

    print(
        "Summary: "
        + ", ".join(f"{key}={value}" for key, value in stats.items())
        + f", cards={len(target_cards)}",
        file=sys.stderr,
    )
    return 1 if stats["failed"] else 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except KeyboardInterrupt:
        raise SystemExit("\nInterrupted")
