#!/usr/bin/env python3
"""Query Wolfram Alpha to verify a math expression or compute its result.

Usage:
    verify.py --app-id-file <path> [--llm] <expression...>

Two endpoints, one flag:

    default (no --llm)   /v1/result            Short Answers API.
                                               One-line plaintext, e.g. "3 x^2".
                                               Cheap and fast. Loses alternate
                                               forms and input interpretation.

    --llm                /api/v1/llm-api       LLM API.
                                               Multi-section plaintext: input
                                               echo, primary result, alternate
                                               forms, plot URL, related facts.
                                               Preferred for verification — the
                                               input echo catches misparses and
                                               the alternate-forms section lets
                                               you string-match equivalent
                                               answers (1/2 vs 0.5) instead of
                                               reasoning about equivalence.

Both endpoints use the same Wolfram AppID. They count against the same quota.

App ID handling:
    The AppID is read from --app-id-file and sent directly to Wolfram. It is
    never printed, logged, or exposed to the caller. The file is expected to
    be chmod 600. The script refuses to run if the file contains the literal
    placeholder string "REPLACE_*".

Exit codes:
    0   success — Wolfram response printed to stdout
    1   missing/placeholder app id file, or HTTP/network error
    2   bad CLI usage (argparse)

Extending:
    - Batch mode (stdin JSON of {id, expr, claimed}) would amortize process
      spawn cost across many problems and let the script return verdicts
      ({match: true/false}) instead of raw text. Not implemented; add a
      --batch flag and branch in main() if you need it.
    - For programmatic re-verification offline, the LLM API includes a
      "Wolfram Language code" snippet that can be fed to a local Wolfram
      Engine. Out of scope here.
    - Rate limit / retry-on-429: Wolfram's free tier is 2000 calls/month
      across endpoints. If you hit it, add urllib retry-with-backoff around
      urlopen() rather than dropping the script.
"""
import argparse
import sys
import urllib.parse
import urllib.request
from pathlib import Path

SHORT_URL = "https://api.wolframalpha.com/v1/result"
LLM_URL = "https://www.wolframalpha.com/api/v1/llm-api"


def load_app_id(path: Path) -> str:
    if not path.exists():
        sys.exit(f"error: app id file not found: {path}")
    app_id = path.read_text().strip()
    if not app_id or app_id.startswith("REPLACE_"):
        sys.exit(f"error: placeholder app id in {path}; write your real one")
    return app_id


def query(expr: str, app_id: str, llm: bool) -> str:
    base = LLM_URL if llm else SHORT_URL
    url = base + "?" + urllib.parse.urlencode({"input" if llm else "i": expr, "appid": app_id})
    with urllib.request.urlopen(url, timeout=20) as resp:
        return resp.read().decode("utf-8")


def main() -> None:
    p = argparse.ArgumentParser()
    p.add_argument("--app-id-file", required=True, type=Path,
                   help="path to a file containing the Wolfram App ID")
    p.add_argument("--llm", action="store_true",
                   help="use the LLM API endpoint for richer structured output")
    p.add_argument("expression", nargs="+", help="math expression to evaluate")
    args = p.parse_args()
    print(query(" ".join(args.expression), load_app_id(args.app_id_file), args.llm))


if __name__ == "__main__":
    main()
