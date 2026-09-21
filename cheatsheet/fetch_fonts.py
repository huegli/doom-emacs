#!/usr/bin/env python3
"""Download the fonts the cheat-sheet builders embed.

build.py and build_by_task.py register five TTFs from FONT_DIR (/tmp/fonts by
default) and will raise if they are missing. Run this once first.

  python3 fetch_fonts.py            # -> /tmp/fonts
  python3 fetch_fonts.py ~/.fonts   # -> custom directory

JetBrains Mono is fetched straight from its GitHub repo. DM Sans has to go
through the Google Fonts CSS API: the predictable-looking direct gstatic URLs
404, so we ask the API for a stylesheet and parse the real TTF URLs out of the
@font-face blocks it returns.
"""

from __future__ import annotations

import re
import sys
import urllib.request
from pathlib import Path

# A browser UA is required; the CSS API serves woff2-only stylesheets to
# clients it recognises as modern, and we specifically want the TTF fallbacks.
UA = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)"

DM_SANS_CSS = (
    "https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;700"
)

JETBRAINS_BASE = (
    "https://github.com/JetBrains/JetBrainsMono/raw/master/fonts/ttf/"
)

# weight -> output filename
DM_SANS_WEIGHTS = {
    "400": "DMSans-Regular.ttf",
    "500": "DMSans-Medium.ttf",
    "700": "DMSans-Bold.ttf",
}

JETBRAINS_FILES = [
    "JetBrainsMono-Regular.ttf",
    "JetBrainsMono-Bold.ttf",
]


def get(url: str) -> bytes:
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    with urllib.request.urlopen(req, timeout=60) as resp:
        return resp.read()


def dm_sans_urls() -> dict[str, str]:
    """Map font-weight -> TTF url by parsing the CSS API response."""
    css = get(DM_SANS_CSS).decode("utf-8", "replace")

    found: dict[str, str] = {}
    # Each @font-face block carries one font-weight and one src url.
    for block in css.split("@font-face"):
        weight = re.search(r"font-weight:\s*(\d+)", block)
        url = re.search(r"url\((https://[^)]+?\.ttf)\)", block)
        if weight and url:
            found.setdefault(weight.group(1), url.group(1))

    missing = set(DM_SANS_WEIGHTS) - set(found)
    if missing:
        raise SystemExit(
            f"DM Sans: CSS API returned no TTF for weight(s) {sorted(missing)}.\n"
            f"Got weights: {sorted(found)}. The API response format may have "
            f"changed; inspect it with:\n  curl -A '{UA}' '{DM_SANS_CSS}'"
        )
    return found


def main() -> int:
    dest = Path(sys.argv[1]).expanduser() if len(sys.argv) > 1 else Path("/tmp/fonts")
    dest.mkdir(parents=True, exist_ok=True)

    print(f"Fetching fonts into {dest}")

    urls = dm_sans_urls()
    for weight, filename in DM_SANS_WEIGHTS.items():
        out = dest / filename
        out.write_bytes(get(urls[weight]))
        print(f"  DM Sans {weight:>3}  -> {filename}  ({out.stat().st_size:,} bytes)")

    for filename in JETBRAINS_FILES:
        out = dest / filename
        out.write_bytes(get(JETBRAINS_BASE + filename))
        print(f"  JetBrains Mono  -> {filename}  ({out.stat().st_size:,} bytes)")

    print("\nDone. Now run:  python3 build.py && python3 build_by_task.py")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
