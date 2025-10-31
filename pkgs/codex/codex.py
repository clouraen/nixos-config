#!/usr/bin/env python3
"""Minimal Codex CLI for interacting with the OpenAI Chat Completions API."""
from __future__ import annotations

import argparse
import json
import os
import sys
from typing import Any, Dict

try:  # Optional rich formatting
    from rich.console import Console
    from rich.markdown import Markdown
except ImportError:  # pragma: no cover - rich is optional at runtime
    Console = None  # type: ignore[assignment]
    Markdown = None  # type: ignore[assignment]


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="codex",
        description=(
            "Lightweight helper around the OpenAI Chat Completions API. "
            "Provide a prompt as arguments or via stdin."
        ),
    )
    parser.add_argument(
        "prompt",
        nargs="*",
        help="Prompt text. When omitted, the command reads from standard input.",
    )
    parser.add_argument(
        "-m",
        "--model",
        default=os.environ.get("CODEX_MODEL", "gpt-4o-mini"),
        help="Model identifier (defaults to gpt-4o-mini or $CODEX_MODEL).",
    )
    parser.add_argument(
        "-t",
        "--temperature",
        type=float,
        default=float(os.environ.get("CODEX_TEMPERATURE", "0.2")),
        help="Sampling temperature (defaults to 0.2 or $CODEX_TEMPERATURE).",
    )
    parser.add_argument(
        "--raw",
        action="store_true",
        help="Print raw JSON response instead of formatted Markdown.",
    )
    parser.add_argument(
        "--system",
        default=os.environ.get(
            "CODEX_SYSTEM",
            "You are Codex, a precise senior developer who returns focused, secure code.",
        ),
        help="System prompt (defaults to a secure coding assistant persona).",
    )
    return parser


def _resolve_prompt(parser: argparse.ArgumentParser, args: argparse.Namespace) -> str:
    text = " ".join(args.prompt).strip()
    if text:
        return text

    if sys.stdin.isatty():
        parser.error("no prompt provided - pass text as arguments or pipe content via stdin")

    piped = sys.stdin.read().strip()
    if not piped:
        parser.error("stdin was empty - unable to build a prompt")
    return piped


def _ensure_api_key(parser: argparse.ArgumentParser) -> str:
    api_key = os.environ.get("OPENAI_API_KEY")
    if not api_key:
        parser.error("OPENAI_API_KEY environment variable is required")
    return api_key


def _run_completion(
    *,
    api_key: str,
    model: str,
    system_prompt: str,
    prompt: str,
    temperature: float,
) -> Dict[str, Any]:
    try:
        from openai import OpenAI  # Lazy import for quicker CLI startup
    except ImportError as exc:  # pragma: no cover - dependency resolution issue
        raise SystemExit(
            "The python 'openai' package is required but missing from the runtime."
        ) from exc

    client = OpenAI(api_key=api_key)
    return client.chat.completions.create(
        model=model,
        temperature=temperature,
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": prompt},
        ],
    )  # type: ignore[return-value]


def _render_response(response: Dict[str, Any], raw: bool) -> None:
    if raw:
        json.dump(response, sys.stdout, indent=2)
        sys.stdout.write("\n")
        return

    message = response["choices"][0]["message"]["content"].strip()
    if Console and Markdown:
        Console().print(Markdown(message))
    else:
        sys.stdout.write(f"{message}\n")


def main() -> None:
    parser = _build_parser()
    args = parser.parse_args()

    api_key = _ensure_api_key(parser)
    prompt = _resolve_prompt(parser, args)

    try:
        response = _run_completion(
            api_key=api_key,
            model=args.model,
            system_prompt=args.system,
            prompt=prompt,
            temperature=args.temperature,
        )
    except Exception as exc:  # pragma: no cover - network or API failures
        raise SystemExit(f"codex request failed: {exc}") from exc

    _render_response(response, args.raw)


if __name__ == "__main__":
    main()
