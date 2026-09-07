# -*- coding: utf-8 -*-
"""Generate the QR and the print-ready standee for a cafe.

    python3 build/print.py sorriso [url]

Defaults to the cafe's own `liveUrl` in cafe.json. Writes cafes/<id>/print/
  qr.png          — for stickers, Instagram, WhatsApp
  standee-a5.pdf  — the table card, A5, print at 100%
"""
import json, os, subprocess, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def build(cafe_id, url=None):
    cdir = os.path.join(ROOT, "cafes", cafe_id)
    cafe = json.load(open(os.path.join(cdir, "cafe.json"), encoding="utf-8"))
    url = url or cafe.get("liveUrl")
    if not url:
        sys.exit("no url: pass one, or set liveUrl in cafe.json")
    out = os.path.join(cdir, "print")
    os.makedirs(out, exist_ok=True)
    a = cafe["address"]
    subprocess.run(["swift", os.path.join(ROOT, "build", "standee.swift"), url,
                    os.path.join(cdir, "assets", "logo.png"), out, cafe["name"],
                    "%s, %s" % (a["line1"], a["line2"]),
                    "%s, %s %s" % (a["line3"], a["city"], a["pin"]),
                    cafe["hours"]["label"].upper()], check=True)
    print("QR points at: %s" % url)

if __name__ == "__main__":
    build(sys.argv[1] if len(sys.argv) > 1 else "sorriso",
          sys.argv[2] if len(sys.argv) > 2 else None)
