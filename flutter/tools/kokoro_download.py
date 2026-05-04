#!/usr/bin/env python3
"""Download the Kokoro v0_19 FP16 model + voices bundle.

Both files are pulled from the canonical
``thewh1teagle/kokoro-onnx`` GitHub release ``model-files`` and cached
under ``.prerender_cache/kokoro/`` (gitignored). Re-runs only fetch
what's missing.

These two are everything ``tools/prerender_tts.py`` needs to render
every clinical stimulus across all four voices into MP3s.

Setup (one-time):
  python3 -m venv tools/.venv
  tools/.venv/bin/pip install kokoro-onnx soundfile numpy imageio-ffmpeg

Run from the flutter/ directory:
  tools/.venv/bin/python tools/kokoro_download.py
  tools/.venv/bin/python tools/prerender_tts.py

Output:
  .prerender_cache/kokoro/
    voices.bin                  ~5.5 MB
    model_fp16.onnx            ~169 MB
"""
from __future__ import annotations

import sys
import urllib.request
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
CACHE_DIR = REPO_ROOT / ".prerender_cache" / "kokoro"

RELEASE_BASE = (
    "https://github.com/thewh1teagle/kokoro-onnx/releases/download/model-files"
)

# (local_filename, source_url, friendly_label)
ARTIFACTS = [
    ("voices.bin",      f"{RELEASE_BASE}/voices.bin",             "voices bundle"),
    ("model_fp16.onnx", f"{RELEASE_BASE}/kokoro-v0_19.fp16.onnx", "FP16"),
]


def human_bytes(n: float) -> str:
    for unit in ("B", "KB", "MB", "GB"):
        if n < 1024:
            return f"{n:.1f} {unit}"
        n /= 1024
    return f"{n:.1f} TB"


def download(name: str, url: str, label: str) -> Path:
    target = CACHE_DIR / name
    if target.exists() and target.stat().st_size > 0:
        print(f"  ✓ {name:20s} cached  ({human_bytes(target.stat().st_size)}, {label})")
        return target

    print(f"  ↓ {name:20s} …  {url}")
    tmp = target.with_suffix(target.suffix + ".part")
    try:
        with urllib.request.urlopen(url, timeout=60) as resp, tmp.open("wb") as f:
            total = int(resp.headers.get("Content-Length") or 0)
            chunk = 1024 * 1024
            read = 0
            while True:
                buf = resp.read(chunk)
                if not buf:
                    break
                f.write(buf)
                read += len(buf)
                if total:
                    pct = read * 100 / total
                    print(
                        f"    {pct:5.1f}%  {human_bytes(read)} / {human_bytes(total)}",
                        end="\r",
                        flush=True,
                    )
        tmp.rename(target)
        print(f"    saved {human_bytes(target.stat().st_size)} ({label}){' ' * 30}")
        return target
    except Exception as e:
        if tmp.exists():
            tmp.unlink()
        sys.exit(f"[error] failed to download {name}: {e}")


def main() -> int:
    CACHE_DIR.mkdir(parents=True, exist_ok=True)
    print(f"Cache dir: {CACHE_DIR.relative_to(REPO_ROOT)}/")
    for name, url, label in ARTIFACTS:
        download(name, url, label)

    total = sum(p.stat().st_size for p in CACHE_DIR.iterdir() if p.is_file())
    files = sorted(p.name for p in CACHE_DIR.iterdir() if p.is_file())
    print(f"\n✓ {len(files)} files ready · {human_bytes(total)} total")
    print(f"  {', '.join(files)}")
    print(f"\nNext step:  tools/.venv/bin/python tools/prerender_tts.py")
    return 0


if __name__ == "__main__":
    sys.exit(main())
