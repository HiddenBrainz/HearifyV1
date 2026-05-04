#!/usr/bin/env python3
"""Pre-render every audiology stimulus to MP3 with Kokoro FP16.

Reads the bundled CSVs, collects the unique normalized stimulus texts,
and synthesizes one MP3 per (voice, text) pair using the Kokoro v0_19
FP16 model (validated by hand via ``tools/kokoro_repl.py``). Output
layout matches what ``lib/services/tts/prerendered_lookup.dart``
expects:

    assets/audio/tts/
      manifest.json
      af_bella/<sha1>.mp3
      af_sarah/<sha1>.mp3
      am_adam/<sha1>.mp3
      am_michael/<sha1>.mp3

The 16-char SHA-1 of the *normalized* text is the canonical key — Dart
side reconstructs the path as ``assets/audio/tts/$voiceId/$key.mp3``.

Why pre-render: audiology test scoring depends on stimulus
reproducibility. Live neural TTS even with the same model is not
byte-identical run-to-run on different CPUs. A pre-rendered file is.

Setup (one-time):
  python3 -m venv tools/.venv
  tools/.venv/bin/pip install kokoro-onnx soundfile numpy imageio-ffmpeg
  tools/.venv/bin/python tools/kokoro_download.py    # caches FP16 model + voices

Run from the flutter/ directory:
  tools/.venv/bin/python tools/prerender_tts.py
  tools/.venv/bin/python tools/prerender_tts.py --voice af_bella --jobs 4

The script is idempotent — existing MP3s are skipped unless --force.
Parallelization uses ``ProcessPoolExecutor`` (each worker loads its
own Kokoro instance) because Python TTS inference holds the GIL,
which would defeat ThreadPoolExecutor.
"""
from __future__ import annotations

import argparse
import csv
import hashlib
import io
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import time
import urllib.request
from concurrent.futures import ProcessPoolExecutor, as_completed
from dataclasses import dataclass
from pathlib import Path

# ── Config ────────────────────────────────────────────────────────────

VOICES = [
    {"id": "af_bella",   "displayName": "Bella",   "gender": "female"},
    {"id": "af_sarah",   "displayName": "Sarah",   "gender": "female"},
    {"id": "am_adam",    "displayName": "Adam",    "gender": "male"},
    {"id": "am_michael", "displayName": "Michael", "gender": "male"},
]
DEFAULT_VOICE_ID = "af_bella"

MP3_BITRATE = "64k"  # mono 64 kbps — clinical-grade speech, ~25 KB/sec

REPO_ROOT = Path(__file__).resolve().parent.parent
ASSETS_DIR = REPO_ROOT / "assets"
TTS_OUT_DIR = ASSETS_DIR / "audio" / "tts"
KOKORO_CACHE = REPO_ROOT / ".prerender_cache" / "kokoro"
MODEL_PATH = KOKORO_CACHE / "model_fp16.onnx"
VOICES_PATH = KOKORO_CACHE / "voices.bin"
MANIFEST_PATH = TTS_OUT_DIR / "manifest.json"

# Each corpus_def's `extract` returns a list of texts for one CSV row.
# Single-utterance corpora yield one entry; matched-pair corpora yield
# two so both sides of "Ball / Dinosaur" get rendered.
CORPORA = [
    {"corpus": "bkbsin",     "csv": "BKBSINData.csv",              "has_header": False, "extract": lambda row: [row[0]]},
    {"corpus": "win",        "csv": "WINData.csv",                 "has_header": False, "extract": lambda row: [row[0]]},
    {"corpus": "azbio",      "csv": "AzBioData.csv",               "has_header": False, "extract": lambda row: [row[0]]},
    {"corpus": "wordrec",    "csv": "WordRecognitionData.csv",     "has_header": True,  "extract": lambda row: [row[0]]},
    {"corpus": "sentcomp",   "csv": "SentenceComprehensionData.csv","has_header": True,  "extract": lambda row: [row[0]]},
    {"corpus": "sentnoise",  "csv": "SentencesInNoiseData.csv",    "has_header": True,  "extract": lambda row: [row[0]]},
    {"corpus": "diag",       "csv": "DiagnosticTestData.csv",      "has_header": True,  "extract": lambda row: [row[0]]},
    {"corpus": "matched",    "csv": "MatchedPairsData.csv",        "has_header": True,  "extract": lambda row: [row[0], row[1]]},
    {"corpus": "syllables",  "csv": "SyllablesData.csv",           "has_header": False, "extract": lambda row: [row[0], row[1]]},
    {"corpus": "pd",         "csv": "PDData.csv",                  "has_header": False, "extract": lambda row: [row[0], row[1]]},
    {"corpus": "vowels",     "csv": "Vowels.csv",                  "has_header": False, "extract": lambda row: [row[0], row[1]]},
    {"corpus": "consonants", "csv": "Consonants.csv",              "has_header": False, "extract": lambda row: [row[0], row[1]]},
    {"corpus": "finalcons",  "csv": "FinalConsonants.csv",         "has_header": False, "extract": lambda row: [row[0], row[1]]},
]


# ── Helpers ───────────────────────────────────────────────────────────


def normalize(text: str) -> str:
    """Same normalization the Dart side uses for runtime lookup.

    Lowercases, strips everything that isn't a letter or apostrophe,
    collapses whitespace. Keep this in sync with
    `_normalizeForLookup` in `lib/services/tts/prerendered_lookup.dart`.
    """
    s = text.lower()
    s = re.sub(r"[^a-z']", " ", s)
    return " ".join(s.split())


def text_key(text: str) -> str:
    """Stable key for the manifest — short hash so JSON stays compact."""
    return hashlib.sha1(normalize(text).encode("utf-8")).hexdigest()[:16]


def find_ffmpeg() -> str:
    """ffmpeg via imageio-ffmpeg (bundled binary) when system ffmpeg is absent."""
    override = os.environ.get("FFMPEG_BIN")
    if override and os.path.isfile(override):
        return override
    found = shutil.which("ffmpeg")
    if found:
        return found
    try:
        import imageio_ffmpeg  # type: ignore[import-not-found]

        return imageio_ffmpeg.get_ffmpeg_exe()
    except ImportError:
        sys.exit(
            "[error] ffmpeg not found and imageio-ffmpeg not installed. "
            "Install with: pip install imageio-ffmpeg"
        )


# ── Driver ────────────────────────────────────────────────────────────


@dataclass
class Stimulus:
    text: str
    key: str


def iter_corpus_rows(csv_path: Path, has_header: bool):
    with csv_path.open(newline="", encoding="utf-8") as f:
        reader = csv.reader(f)
        rows = list(reader)
    if has_header and rows:
        rows = rows[1:]
    for row in rows:
        if not row or not row[0].strip():
            continue
        yield row


def collect_stimuli() -> list[Stimulus]:
    """One Stimulus per unique normalized text across every corpus."""
    seen: dict[str, Stimulus] = {}
    for corpus_def in CORPORA:
        csv_path = ASSETS_DIR / "csv" / corpus_def["csv"]
        if not csv_path.exists():
            print(f"  ⚠ skipping {corpus_def['corpus']}: {csv_path.name} not found")
            continue
        for row in iter_corpus_rows(csv_path, corpus_def["has_header"]):
            for raw in corpus_def["extract"](row):
                text = (raw or "").strip()
                if not text:
                    continue
                norm = normalize(text)
                if not norm:
                    continue
                key = text_key(text)
                if key in seen:
                    continue
                seen[key] = Stimulus(text=text, key=key)
    return list(seen.values())


# ── Worker (runs in a child process) ──────────────────────────────────
#
# Each worker loads its own Kokoro instance (~700 MB RAM, ~700 ms init)
# once, then processes the chunk of jobs the main process hands it.
# Loading per-job would dominate the wall time.

_KOKORO = None  # set by _worker_init, read by _worker_render
_FFMPEG_BIN = None
_INTRA_OP_THREADS = 2


def _worker_init(model_path: str, voices_path: str, ffmpeg_bin: str, intra_op_threads: int) -> None:
    global _KOKORO, _FFMPEG_BIN, _INTRA_OP_THREADS
    _FFMPEG_BIN = ffmpeg_bin
    _INTRA_OP_THREADS = intra_op_threads

    # Force onnxruntime to use the requested intra-op thread count even
    # though kokoro-onnx doesn't expose this directly. Setting these env
    # vars before the first onnxruntime import respects the request on
    # CPU EP.
    os.environ.setdefault("OMP_NUM_THREADS", str(intra_op_threads))
    os.environ.setdefault("MKL_NUM_THREADS", str(intra_op_threads))

    from kokoro_onnx import Kokoro  # type: ignore[import-not-found]

    _KOKORO = Kokoro(model_path, voices_path)


def _worker_render(args: tuple[str, str, str, str]) -> tuple[str, bool, str]:
    """Render one (voice, stimulus) pair to MP3.

    args: (voice_id, stimulus_key, stimulus_text, mp3_path)
    returns: (label, success, info)
    """
    import numpy as np  # type: ignore[import-not-found]
    import soundfile as sf  # type: ignore[import-not-found]

    voice_id, key, text, mp3_path = args
    try:
        samples, sample_rate = _KOKORO.create(  # type: ignore[union-attr]
            text, voice=voice_id, speed=1.0, lang="en-us"
        )
    except Exception as e:
        return (f"{voice_id}/{key}", False, f"synth: {e}")

    # WAV → ffmpeg → MP3 in-memory; only the final MP3 hits disk.
    Path(mp3_path).parent.mkdir(parents=True, exist_ok=True)
    wav_buf = io.BytesIO()
    try:
        sf.write(wav_buf, samples.astype(np.float32), sample_rate, format="WAV", subtype="PCM_16")
    except Exception as e:
        return (f"{voice_id}/{key}", False, f"wav: {e}")
    wav_buf.seek(0)

    try:
        ff = subprocess.run(
            [
                _FFMPEG_BIN,
                "-y",
                "-loglevel", "error",
                "-f", "wav",
                "-i", "pipe:0",
                "-codec:a", "libmp3lame",
                "-b:a", MP3_BITRATE,
                "-ac", "1",
                str(mp3_path),
            ],
            input=wav_buf.read(),
            capture_output=True,
            check=False,
        )
    except Exception as e:
        return (f"{voice_id}/{key}", False, f"ffmpeg launch: {e}")
    if ff.returncode != 0 or not Path(mp3_path).exists():
        return (
            f"{voice_id}/{key}",
            False,
            f"ffmpeg rc={ff.returncode}: {ff.stderr.decode(errors='replace')[:200]}",
        )
    return (f"{voice_id}/{key}", True, text)


# ── Main ──────────────────────────────────────────────────────────────


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--force", action="store_true", help="regenerate even if MP3 exists"
    )
    parser.add_argument(
        "--voice",
        choices=[v["id"] for v in VOICES] + ["all"],
        default="all",
        help="render only one voice (default: all)",
    )
    parser.add_argument(
        "--jobs",
        "-j",
        type=int,
        default=min(os.cpu_count() or 4, 6),
        help="parallel worker processes (default: min(cpu_count, 6))",
    )
    parser.add_argument(
        "--intra-op-threads",
        type=int,
        default=2,
        help="onnxruntime intra-op threads inside each worker (default: 2)",
    )
    args = parser.parse_args()

    if not MODEL_PATH.exists() or not VOICES_PATH.exists():
        sys.exit(
            f"[error] Kokoro model or voices missing in "
            f"{KOKORO_CACHE.relative_to(REPO_ROOT)}/.\n"
            f"  Run: tools/.venv/bin/python tools/kokoro_download.py"
        )
    ffmpeg_bin = find_ffmpeg()

    target_voices = (
        VOICES if args.voice == "all"
        else [v for v in VOICES if v["id"] == args.voice]
    )

    print(f"[1/3] Collecting stimuli from {len(CORPORA)} CSVs…")
    stimuli = collect_stimuli()
    print(f"  {len(stimuli)} unique normalized texts")

    print(
        f"[2/3] Synthesizing into {TTS_OUT_DIR.relative_to(REPO_ROOT)}/ "
        f"with {args.jobs} workers × {args.intra_op_threads} intra-op threads"
    )

    # Build the full job list up front; ProcessPoolExecutor distributes
    # them across workers so all four voices fill in roughly together.
    jobs: list[tuple[str, str, str, str]] = []
    skipped = 0
    for v in target_voices:
        out_dir = TTS_OUT_DIR / v["id"]
        out_dir.mkdir(parents=True, exist_ok=True)
        for s in stimuli:
            mp3_path = out_dir / f"{s.key}.mp3"
            if mp3_path.exists() and not args.force:
                skipped += 1
                continue
            jobs.append((v["id"], s.key, s.text, str(mp3_path)))

    written = 0
    failed: list[str] = []
    total = len(jobs)
    t_start = time.perf_counter()

    if jobs:
        with ProcessPoolExecutor(
            max_workers=args.jobs,
            initializer=_worker_init,
            initargs=(
                str(MODEL_PATH),
                str(VOICES_PATH),
                ffmpeg_bin,
                args.intra_op_threads,
            ),
        ) as pool:
            futures = [pool.submit(_worker_render, j) for j in jobs]
            for fut in as_completed(futures):
                label, ok, info = fut.result()
                if ok:
                    written += 1
                    if written % 50 == 0 or written == total:
                        elapsed = time.perf_counter() - t_start
                        rate = written / elapsed if elapsed > 0 else 0
                        eta = (total - written) / rate if rate > 0 else 0
                        print(
                            f"    [{written}/{total}] "
                            f"{rate:5.1f}/s  ETA {eta:5.0f}s  "
                            f"♪ {label}"
                        )
                else:
                    failed.append(f"{label}: {info}")
                    print(f"    ✗ {label}: {info}")

    print(f"  done: {written} written, {skipped} cached, {len(failed)} failed")
    if failed:
        sys.exit(f"[error] {len(failed)} renders failed; first: {failed[0]}")

    print(f"[3/3] Writing manifest → {MANIFEST_PATH.relative_to(REPO_ROOT)}")
    manifest = {
        "version": 2,
        "bitrateKbps": int(MP3_BITRATE.rstrip("k")),
        "model": "kokoro-v0_19-fp16",
        "defaultVoice": DEFAULT_VOICE_ID,
        "voices": [
            {
                "id": v["id"],
                "displayName": v["displayName"],
                "gender": v["gender"],
            }
            for v in VOICES
        ],
        "keys": {s.key: s.text for s in stimuli},
    }
    MANIFEST_PATH.parent.mkdir(parents=True, exist_ok=True)
    with MANIFEST_PATH.open("w", encoding="utf-8") as f:
        json.dump(manifest, f, ensure_ascii=False, indent=2, sort_keys=True)
        f.write("\n")

    total_bytes = 0
    for v in VOICES:
        for s in stimuli:
            p = TTS_OUT_DIR / v["id"] / f"{s.key}.mp3"
            if p.exists():
                total_bytes += p.stat().st_size
    print(
        f"\n✓ {len(stimuli)} stimuli × {len(VOICES)} voices = "
        f"{len(stimuli) * len(VOICES)} clips · "
        f"{total_bytes / (1024 * 1024):.1f} MB total · "
        f"{time.perf_counter() - t_start:.1f}s wall"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
