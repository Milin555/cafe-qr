# -*- coding: utf-8 -*-
"""Turn a folder of dish photos into menu thumbnails.

Drop the cafe's photos into  cafes/<id>/photos/  named after the item —
"Loaded Hummus" -> loaded-hummus.jpg (any of .jpg .jpeg .png .heic).
Then:  python3 build/photos.py sorriso

Produces a centre-cropped square thumb and a wider detail image per item in
assets/items/. The renderer picks them up automatically; no config to edit.
"""
import os, re, subprocess, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
THUMB, DETAIL = 220, 640

def slug(s):
    return re.sub(r"[^a-z0-9]+", "-", s.lower()).strip("-")

def sips(src, dst, size, crop_square, quality):
    subprocess.run(["sips", "-s", "format", "jpeg", "-s", "formatOptions", str(quality),
                    "-Z", str(size), src, "--out", dst],
                   check=True, capture_output=True)
    if crop_square:
        subprocess.run(["sips", "-c", str(size), str(size), dst],
                       check=True, capture_output=True)

def build(cafe_id):
    src_dir = os.path.join(ROOT, "cafes", cafe_id, "photos")
    out_dir = os.path.join(ROOT, "cafes", cafe_id, "assets", "items")
    if not os.path.isdir(src_dir):
        os.makedirs(src_dir, exist_ok=True)
        print("created %s — drop dish photos in, named after the item" % src_dir)
        return
    os.makedirs(out_dir, exist_ok=True)
    n = 0
    for f in sorted(os.listdir(src_dir)):
        stem, ext = os.path.splitext(f)
        if ext.lower() not in (".jpg", ".jpeg", ".png", ".heic", ".webp"):
            continue
        src = os.path.join(src_dir, f)
        s = slug(stem)
        sips(src, os.path.join(out_dir, s + ".jpg"), THUMB, True, 72)
        sips(src, os.path.join(out_dir, s + "-lg.jpg"), DETAIL, False, 68)
        n += 1
        print("  %-34s -> %s.jpg" % (f, s))
    print("%d photo(s) prepared in assets/items/" % n)
    print("now run: python3 build/render.py %s" % cafe_id)

if __name__ == "__main__":
    build(sys.argv[1] if len(sys.argv) > 1 else "sorriso")
