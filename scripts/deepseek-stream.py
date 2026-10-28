#!/usr/bin/env python3
"""Client CLI per l'API DeepSeek (formato OpenAI-compatibile).

Equivalente DeepSeek di scripts/nvidia-nemotron-stream.py.

Endpoint : POST https://api.deepseek.com/chat/completions
Modelli  : deepseek-flash (default, V4.1-Flash) | deepseek-v4-pro
Auth     : header  Authorization: Bearer $DEEPSEEK_API_KEY

Differenze rispetto alla versione NVIDIA, dettate dalle API DeepSeek:
  * niente "chat_template_kwargs": il thinking si attiva con
    "thinking": {"type": "enabled" | "disabled"}
  * "reasoning_effort": none | low | high | max  (default: high)
  * niente "seed" e niente "parallel_tool_calls" (non supportati)
  * in thinking mode "temperature" non ha effetto e "top_p" e' fissato a 1.0

Lo stream SSE e' parsato davvero: i token di ragionamento arrivano in
delta.reasoning_content e vanno su stderr, la risposta finale in
delta.content va su stdout (cosi' `| tee risposta.txt` cattura solo
l'output utile).

Uso:
    $env:DEEPSEEK_API_KEY = "sk-..."          # PowerShell
    export DEEPSEEK_API_KEY="sk-..."          # bash

    python scripts/deepseek-stream.py
    python scripts/deepseek-stream.py "Spiega le chiusure in Triad"
    python scripts/deepseek-stream.py --model deepseek-v4-pro --reasoning-effort max "..."
    python scripts/deepseek-stream.py --no-thinking --no-stream "..."
"""

from __future__ import annotations

import argparse
import json
import os
import sys

import requests

DEFAULT_BASE_URL = "https://api.deepseek.com"
DEFAULT_MODEL = "deepseek-flash"
MODELS = ("deepseek-flash", "deepseek-v4-pro")
EFFORTS = ("none", "low", "high", "max")
DEFAULT_PROMPT = "Which number is larger, 9.11 or 9.8?"

EXIT_USAGE = 2
EXIT_HTTP = 1


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Chiamata streaming all'API DeepSeek.",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument("prompt", nargs="?", default=DEFAULT_PROMPT,
                        help="messaggio utente da inviare")
    parser.add_argument("--model", default=os.environ.get("DEEPSEEK_MODEL", DEFAULT_MODEL),
                        choices=MODELS, help="modello da usare")
    parser.add_argument("--base-url", default=os.environ.get("DEEPSEEK_BASE_URL", DEFAULT_BASE_URL),
                        help="base URL dell'API")
    parser.add_argument("--no-thinking", action="store_true",
                        help="disattiva il thinking mode (thinking.type=disabled)")
    parser.add_argument("--reasoning-effort", default="high", choices=EFFORTS,
                        help="sforzo di ragionamento in thinking mode")
    parser.add_argument("--no-stream", action="store_true",
                        help="richiesta non-streaming, stampa la risposta completa")
    parser.add_argument("--temperature", type=float, default=1.0,
                        help="0..2 (ignorata in thinking mode)")
    parser.add_argument("--top-p", type=float, default=0.95,
                        help="0..1 (in thinking mode l'intervallo effettivo e' 0.95-1.0)")
    parser.add_argument("--max-tokens", type=int, default=4096,
                        help="token massimi generati")
    parser.add_argument("--hide-thinking", action="store_true",
                        help="non mostrare i token di ragionamento su stderr")
    return parser.parse_args(argv)


def build_payload(args: argparse.Namespace, stream: bool) -> dict:
    payload: dict = {
        "model": args.model,
        "messages": [{"role": "user", "content": args.prompt}],
        "stream": stream,
        "max_tokens": args.max_tokens,
    }
    if args.no_thinking:
        payload["thinking"] = {"type": "disabled"}
        payload["temperature"] = args.temperature
        payload["top_p"] = 1.0
    else:
        payload["thinking"] = {"type": "enabled"}
        payload["reasoning_effort"] = args.reasoning_effort
        payload["top_p"] = args.top_p
    if stream:
        payload["stream_options"] = {"include_usage": True}
    return payload


def iter_events(lines) -> "Iterator[dict]":
    """Genera i chunk JSON da un flusso SSE.

    `lines` e' l'iteratore di response.iter_lines(); ogni evento e' una riga
    'data: <json>' e il flusso termina con 'data: [DONE]'. Le righe che non
    iniziano con 'data:' (heartbeat, commenti ':') vengono ignorate.
    """
    for raw in lines:
        if not raw:
            continue
        try:
            text = raw.decode("utf-8") if isinstance(raw, bytes) else raw
        except UnicodeDecodeError:
            continue
        text = text.strip()
        if not text.startswith("data:"):
            continue
        data = text[len("data:"):].strip()
        if not data:
            continue
        if data == "[DONE]":
            return
        try:
            yield json.loads(data)
        except json.JSONDecodeError:
            continue


def call(args: argparse.Namespace) -> int:
    api_key = os.environ.get("DEEPSEEK_API_KEY", "").strip()
    if not api_key:
        print("Errore: DEEPSEEK_API_KEY non impostata.\n"
              "  PowerShell: $env:DEEPSEEK_API_KEY = \"sk-...\"\n"
              "  bash:       export DEEPSEEK_API_KEY=\"sk-...\"",
              file=sys.stderr)
        return EXIT_USAGE

    stream = not args.no_stream
    url = args.base_url.rstrip("/") + "/chat/completions"
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json",
        "Accept": "text/event-stream" if stream else "application/json",
    }
    payload = build_payload(args, stream)

    try:
        response = requests.post(url, headers=headers, json=payload,
                                 stream=stream, timeout=(15, 600))
    except requests.RequestException as exc:
        print(f"Errore di rete: {exc}", file=sys.stderr)
        return EXIT_HTTP

    if response.status_code != 200:
        print(f"HTTP {response.status_code}: {response.text[:800]}", file=sys.stderr)
        return EXIT_HTTP

    if not stream:
        try:
            message = response.json()["choices"][0]["message"]
        except (ValueError, KeyError, IndexError) as exc:
            print(f"Risposta inattesa: {exc}", file=sys.stderr)
            return EXIT_HTTP
        reasoning = message.get("reasoning_content")
        if reasoning and not args.hide_thinking:
            print(reasoning, file=sys.stderr)
        print(message.get("content") or "")
        return 0

    finish_reason = None
    saw_output = False
    for event in iter_events(response.iter_lines()):
        for choice in event.get("choices") or []:
            delta = choice.get("delta") or {}
            reasoning = delta.get("reasoning_content")
            if reasoning and not args.hide_thinking:
                sys.stderr.write(reasoning)
                sys.stderr.flush()
            content = delta.get("content")
            if content:
                saw_output = True
                sys.stdout.write(content)
                sys.stdout.flush()
            if choice.get("finish_reason"):
                finish_reason = choice["finish_reason"]
        usage = event.get("usage")
        if usage and not args.hide_thinking:
            print(f"\n[tokens] prompt={usage.get('prompt_tokens')} "
                  f"completion={usage.get('completion_tokens')} "
                  f"total={usage.get('total_tokens')}", file=sys.stderr)

    if sys.stdout.isatty() or saw_output:
        print()
    if finish_reason and finish_reason not in ("stop",):
        print(f"[finish_reason: {finish_reason}]", file=sys.stderr)
    return 0


def main(argv: list[str] | None = None) -> int:
    return call(parse_args(argv))


if __name__ == "__main__":
    raise SystemExit(main())
