#!/usr/bin/env python3
"""Genera il grafico SVG dei download delle release di Triad.

Legge i dati dalla GitHub API (somma dei download per ogni release, in
ordine cronologico) e produce un grafico a linee cumulativo salvato in
docs/assets/img/downloads.svg, usato in fondo al README.md.

Uso:
    python3 scripts/download_chart.py                 # usa i tag locali + API
    python3 scripts/download_chart.py --repo OWNER/REPO
    python3 scripts/download_chart.py --token $GITHUB_TOKEN   (consigliato in CI)

Il workflow .github/workflows/download-chart.yml esegue questo script
quotidianamente con l'API GitHub tramite il token GITHUB_TOKEN di Actions.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
import urllib.request
from datetime import datetime, timezone
from pathlib import Path

DEFAULT_REPO = "GPuntobit/triad2.0"
OUT_PATH = Path(__file__).resolve().parent.parent / "docs" / "assets" / "img" / "downloads.svg"

# Dimensioni del grafico
W, H = 720, 360
M_L, M_R, M_T, M_B = 70, 24, 44, 56


def fetch_releases(repo: str, token: str | None) -> list[dict]:
    """Scarica tutte le release del repository dalla GitHub API."""
    releases: list[dict] = []
    page = 1
    while True:
        url = f"https://api.github.com/repos/{repo}/releases?per_page=100&page={page}"
        req = urllib.request.Request(url, headers={
            "Accept": "application/vnd.github+json",
            "User-Agent": "triad-download-chart",
        })
        if token:
            req.add_header("Authorization", f"Bearer {token}")
        with urllib.request.urlopen(req, timeout=30) as resp:
            data = json.loads(resp.read().decode("utf-8"))
        if not data:
            break
        releases.extend(data)
        if len(data) < 100:
            break
        page += 1
    return releases


def load_releases_from_tags() -> list[dict]:
    """Fallback offline: usa i tag git locali come snapshot (conteggio 0).

    Serve solo per generare un segnaposto quando la API non ├¿ raggiungibile;
    il workflow in CI usa sempre la via API con GITHUB_TOKEN.
    """
    try:
        out = subprocess.run(
            ["git", "tag", "--sort=creatordate", "--format=%(refname:short)\t%(creatordate:iso)"],
            capture_output=True, text=True, check=True, cwd=Path(__file__).resolve().parent.parent,
        ).stdout
    except (subprocess.CalledProcessError, FileNotFoundError):
        return []
    releases = []
    for line in out.splitlines():
        if "\t" not in line:
            continue
        name, date = line.split("\t", 1)
        if not re.match(r"^v\d", name):
            continue
        releases.append({"tag_name": name, "published_at": date.strip(), "download_count": 0})
    return releases


def build_svg(points: list[tuple[datetime, int]], repo: str) -> str:
    """Costruisce l'SVG del grafico cumulativo dei download."""
    total = points[-1][1] if points else 0
    n = len(points)
    plot_w = W - M_L - M_R
    plot_h = H - M_T - M_B

    def x(i: int) -> float:
        return M_L + (plot_w * i / (n - 1) if n > 1 else plot_w / 2)

    max_y = max(total, 1)
    # arrotonda l'asse y al multiplo "bello" pi├╣ vicino
    step = 10 ** max(0, len(str(max_y)) - 2) if max_y >= 10 else 1
    top = ((max_y // step) + 1) * step

    def y(v: int) -> float:
        return M_T + plot_h * (1 - v / top)

    parts = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" '
        f'viewBox="0 0 {W} {H}" font-family="Segoe UI, Helvetica, Arial, sans-serif">',
        f'<rect width="{W}" height="{H}" fill="#ffffff"/>',
        f'<text x="{W / 2}" y="26" text-anchor="middle" font-size="16" font-weight="600" '
        f'fill="#1f2328">Download totali ÔÇö {repo}</text>',
    ]

    # griglia e assi y
    ticks = 5
    for t in range(ticks + 1):
        val = int(top * t / ticks)
        yy = y(val)
        parts.append(f'<line x1="{M_L}" y1="{yy:.1f}" x2="{W - M_R}" y2="{yy:.1f}" '
                     f'stroke="#d0d7de" stroke-width="1" stroke-dasharray="{"" if t == 0 else "3,3"}"/>')
        parts.append(f'<text x="{M_L - 8}" y="{yy + 4:.1f}" text-anchor="end" '
                     f'font-size="11" fill="#656d76">{val:,}</text>')

    # asse x: etichette alle date dei campioni (prima, met├á, ultima)
    if n:
        for idx in sorted({0, n // 2, n - 1}):
            d = points[idx][0].strftime("%d/%m/%Y")
            parts.append(f'<text x="{x(idx):.1f}" y="{H - M_B + 20}" text-anchor="middle" '
                         f'font-size="11" fill="#656d76">{d}</text>')

    if n >= 2:
        # area riempita sotto la linea
        area = [f"M {x(0):.1f} {y(points[0][1]):.1f}"]
        area += [f"L {x(i):.1f} {y(v):.1f}" for i, (_, v) in enumerate(points)]
        area.append(f"L {x(n - 1):.1f} {y(0):.1f} L {x(0):.1f} {y(0):.1f} Z")
        parts.append(f'<path d="{" ".join(area)}" fill="#0969da" fill-opacity="0.12"/>')
        line = " ".join(
            f"{'M' if i == 0 else 'L'} {x(i):.1f} {y(v):.1f}" for i, (_, v) in enumerate(points)
        )
        parts.append(f'<path d="{line}" fill="none" stroke="#0969da" stroke-width="2.5"/>')
    if n:
        parts.append(f'<circle cx="{x(n - 1):.1f}" cy="{y(points[-1][1]):.1f}" r="4" fill="#0969da"/>')
        parts.append(f'<text x="{x(n - 1) - 8:.1f}" y="{y(points[-1][1]) - 10:.1f}" '
                     f'text-anchor="end" font-size="13" font-weight="600" fill="#0969da">'
                     f'{total:,} download</text>')
    else:
        parts.append(f'<text x="{W / 2}" y="{H / 2}" text-anchor="middle" font-size="14" '
                     f'fill="#656d76">Nessuna release con download disponibili</text>')

    generated = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC")
    parts.append(f'<text x="{W - M_R}" y="{H - 10}" text-anchor="end" font-size="10" '
                 f'fill="#8b949e">Aggiornato: {generated} ┬À GitHub Releases API</text>')
    parts.append("</svg>")
    return "\n".join(parts) + "\n"


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--repo", default=os.environ.get("TRIAD_REPO", DEFAULT_REPO),
                    help="repository GitHub OWNER/REPO (default: %(default)s)")
    ap.add_argument("--token", default=os.environ.get("GITHUB_TOKEN"),
                    help="token API GitHub (in CI: secrets.GITHUB_TOKEN)")
    ap.add_argument("--out", default=str(OUT_PATH), help="percorso SVG di output")
    args = ap.parse_args()

    try:
        releases = fetch_releases(args.repo, args.token)
    except Exception as exc:  # rete/autenticazione non disponibile
        print(f"Avviso: API non raggiungibile ({exc}); uso i tag git locali.", file=sys.stderr)
        releases = load_releases_from_tags()

    # scarica cumulative nel tempo, escludendo draft e prerelease senza asset
    dated = []
    for r in releases:
        pub = r.get("published_at")
        if not pub:
            continue
        asset_downloads = sum(
            int(a.get("download_count", 0)) for a in (r.get("assets") or [])
        )
        dated.append((datetime.strptime(pub[:10], "%Y-%m-%d").replace(tzinfo=timezone.utc),
                      asset_downloads))
    dated.sort(key=lambda p: p[0])

    points: list[tuple[datetime, int]] = []
    cum = 0
    for d, cnt in dated:
        cum += cnt
        points.append((d, cum))
    if points and points[-1][1] == 0:
        points = []  # fallback da tag: mostra stato vuoto invece di una linea falsa a 0

    svg = build_svg(points, args.repo)
    out = Path(args.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(svg, encoding="utf-8")
    print(f"Grafico scritto in {out} ({len(points)} punti, totale {points[-1][1] if points else 0} download)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
