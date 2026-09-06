# -*- coding: utf-8 -*-
"""Cafe QR — static menu renderer.

One engine, many cafes. Reads cafes/<id>/cafe.json + menu.json + assets/,
emits a self-contained page (assets inlined as data URIs, so it works from
GitHub Pages, a file:// URL, or an Artifact with no external requests).

    python3 build/render.py sorriso
"""
import base64, json, mimetypes, os, re, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "build"))
from icons import ICONS, UI

# ---------------------------------------------------------------- helpers
def esc(s):
    return (str(s).replace("&", "&amp;").replace("<", "&lt;")
            .replace(">", "&gt;").replace('"', "&quot;"))

def data_uri(path):
    mime = mimetypes.guess_type(path)[0] or "application/octet-stream"
    with open(path, "rb") as f:
        return "data:%s;base64,%s" % (mime, base64.b64encode(f.read()).decode())

def icon(key, cls="ico", sw="1.4"):
    body = ICONS.get(key) or UI.get(key) or UI["sparkle"]
    return ('<svg class="%s" viewBox="0 0 24 24" fill="none" stroke="currentColor" '
            'stroke-width="%s" stroke-linecap="round" stroke-linejoin="round" '
            'aria-hidden="true">%s</svg>' % (cls, sw, body))

def slug(s):
    return re.sub(r"[^a-z0-9]+", "-", s.lower()).strip("-")

# ---------------------------------------------------------------- build
def build(cafe_id):
    cdir = os.path.join(ROOT, "cafes", cafe_id)
    cafe = json.load(open(os.path.join(cdir, "cafe.json"), encoding="utf-8"))
    menu = json.load(open(os.path.join(cdir, "menu.json"), encoding="utf-8"))
    adir = os.path.join(cdir, "assets")
    names = {k: v for k, v in cafe["assets"].items() if isinstance(v, str)}
    A_data = {k: data_uri(os.path.join(adir, v)) for k, v in names.items()}
    A_rel = {k: "assets/" + v for k, v in names.items()}
    gal_data = [data_uri(os.path.join(adir, g)) for g in cafe["assets"]["gallery"]]
    gal_rel = ["assets/" + g for g in cafe["assets"]["gallery"]]
    A, gallery = A_data, gal_data

    t, c, addr, hrs = cafe["theme"], cafe["contact"], cafe["address"], cafe["hours"]
    cur = menu.get("currency", "₹")
    full_addr = ", ".join([addr["line1"], addr["line2"], addr["line3"],
                           addr["city"], addr["state"], addr["pin"]])

    all_items = [i for sec in menu["sections"] for i in sec["items"]]
    all_veg = all(i.get("veg") for i in all_items)

    # ---- picks (items flagged in the data, never invented here)
    picks = [(s, i) for s in menu["sections"] for i in s["items"] if i.get("tag")]

    # ---- nav
    nav = "".join(
        '<a class="pill" href="#s-%s" data-nav="%s">%s</a>' % (s["id"], s["id"], esc(s["name"]))
        for s in menu["sections"])

    # ---- picks rail
    pick_cards = "".join(
        '<a class="pick" href="#s-%s"><span class="pick-ico">%s</span>'
        '<span class="pick-tag">%s</span><span class="pick-name">%s</span>'
        '<span class="pick-price">%s%s</span></a>'
        % (s["id"], icon(i["icon"], "ico", "1.25"), esc(i["tag"]), esc(i["name"]), cur, i["price"])
        for s, i in picks)

    # ---- sections
    def item_row(i):
        veg = "" if all_veg else (
            '<span class="veg" title="Vegetarian" aria-label="Vegetarian"><i></i></span>'
            if i.get("veg") else "")
        tag = ('<span class="tag">%s</span>' % esc(i["tag"])) if i.get("tag") else ""
        note = ('<p class="note">%s</p>' % esc(i["note"])) if i.get("note") else ""
        desc = i.get("desc", "")
        search = esc((i["name"] + " " + i.get("note", "") + " " + desc).lower())
        if desc:
            body = ('<span class="body"><button class="line" type="button" aria-expanded="false">'
                    '<span class="name">%s%s%s<i class="chev"></i></span>'
                    '<span class="dots"></span>'
                    '<span class="price">%s%s</span></button>%s'
                    '<p class="desc" hidden>%s</p></span>'
                    % (esc(i["name"]), veg, tag, cur, i["price"], note, esc(desc)))
            cls = "item has-desc"
        else:
            body = ('<span class="body"><span class="line">'
                    '<span class="name">%s%s%s</span>'
                    '<span class="dots"></span>'
                    '<span class="price">%s%s</span></span>%s</span>'
                    % (esc(i["name"]), veg, tag, cur, i["price"], note))
            cls = "item"
        return ('<li class="%s" data-q="%s"><span class="tile">%s</span>%s</li>'
                % (cls, search, icon(i["icon"]), body))

    secs = "".join(
        '<section class="sec reveal" id="s-%s" data-sec="%s">'
        '<header class="sec-h"><p class="kicker">%s</p><h2>%s</h2>'
        '<span class="rule"></span></header><ul class="items">%s</ul></section>'
        % (s["id"], s["id"], esc(s.get("kicker", "")), esc(s["name"]),
           "".join(item_row(i) for i in s["items"]))
        for s in menu["sections"])

    # ---- add-ons
    ad = menu["addons"]
    addon_groups = "".join(
        '<div class="ag"><span class="tile sm">%s</span><div>'
        '<p class="ag-h">%s<span class="ag-p">%s%s</span></p>'
        '<p class="ag-o">%s</p></div></div>'
        % (icon(g["icon"], "ico", "1.3"), esc(g["label"]), cur, g["price"],
           esc(" · ".join(g["options"])))
        for g in ad["groups"])

    caps = cafe.get("galleryCaptions", [])
    shots = "".join(
        '<figure class="shot"><img src="%s" alt="%s at Sorriso" loading="lazy">'
        '<figcaption>%s</figcaption></figure>'
        % (g, esc(caps[n] if n < len(caps) else cafe["name"]),
           esc(caps[n] if n < len(caps) else ""))
        for n, g in enumerate(gallery))

    action = lambda href, ic, label, extra="": (
        '<a class="act" href="%s"%s><span>%s</span>%s</a>'
        % (href, extra, icon(ic, "ico", "1.5"), esc(label)))
    actions = (action(c["directions"], "directions", "Directions", ' target="_blank" rel="noopener"')
               + action(c["whatsapp"], "whatsapp", "WhatsApp", ' target="_blank" rel="noopener"')
               + action("tel:" + c["phone"], "phone", "Call")
               + action(c["instagram"], "instagram", "Instagram", ' target="_blank" rel="noopener"'))

    open_h, close_h = hrs["open"], hrs["close"]
    TPL = open(os.path.join(ROOT, "build", "page.html"), encoding="utf-8").read()
    rep = {
        "@@NAME@@": esc(cafe["name"]),
        "@@TAGLINE@@": esc(cafe["tagline"]),
        "@@BLURB@@": esc(cafe["blurb"]),
        "@@LOGO@@": A["logo"], "@@HERO@@": A["hero"],
        "@@PATTERN@@": A["pattern"], "@@ARTCUP@@": A["artCup"],
        "@@ARTSHAKE@@": A["artShake"],
        "@@RATING@@": str(cafe["meta"]["rating"]),
        "@@RATINGCOUNT@@": str(cafe["meta"]["ratingCount"]),
        "@@RATINGSRC@@": esc(cafe["meta"]["ratingSource"]),
        "@@PRICEBAND@@": esc(cafe["meta"]["priceBand"]),
        "@@CUISINES@@": esc(" · ".join(cafe["meta"]["cuisines"])),
        "@@HOURS@@": esc(hrs["label"]), "@@DAYS@@": esc(hrs["days"]),
        "@@OPENH@@": open_h, "@@CLOSEH@@": close_h,
        "@@ADDR1@@": esc(addr["line1"]),
        "@@ADDR2@@": esc(addr["line2"] + ", " + addr["line3"]),
        "@@ADDR3@@": esc("%s, %s %s" % (addr["city"], addr["state"], addr["pin"])),
        "@@FULLADDR@@": esc(full_addr),
        "@@PHONE@@": c["phone"], "@@PHONEDISP@@": esc(c["phoneDisplay"]),
        "@@WHATSAPP@@": c["whatsapp"], "@@INSTA@@": c["instagram"],
        "@@INSTAH@@": esc(c["instagramHandle"]),
        "@@REVIEW@@": c["googleReview"], "@@DIRECTIONS@@": c["directions"],
        "@@NAV@@": nav, "@@PICKS@@": pick_cards, "@@SECTIONS@@": secs,
        "@@ADDONTITLE@@": esc(ad["title"]), "@@ADDONS@@": addon_groups,
        "@@SHOTS@@": shots, "@@ACTIONS@@": actions,
        "@@ITEMCOUNT@@": str(sum(len(s["items"]) for s in menu["sections"])),
        "@@VEGNOTE@@": ('<p class="vegnote"><span class="veg"><i></i></span>'
                        'Pure vegetarian kitchen</p>') if all_veg else "",
        "@@SECCOUNT@@": str(len(menu["sections"])),
        "@@CAPTURED@@": esc(cafe["source"]["capturedOn"]),
        "@@ISTAR@@": icon("star", "ico", "1.3"),
        "@@ICLOCK@@": icon("clock", "ico", "1.4"),
        "@@IPIN@@": icon("pin", "ico", "1.4"),
        "@@ISEARCH@@": icon("search", "ico", "1.6"),
        "@@ICLOSE@@": icon("close", "ico", "1.8"),
        "@@IARROW@@": icon("arrow", "ico", "1.7"),
        "@@ISUN@@": icon("sun", "ico", "1.5"),
        "@@IMOON@@": icon("moon", "ico", "1.5"),
        "@@ILEAF@@": icon("leaf", "ico", "1.3"),
        "@@IREVIEW@@": icon("star", "ico", "1.4"),
        "@@IINSTA@@": icon("instagram", "ico", "1.4"),
        "@@IWA@@": icon("whatsapp", "ico", "1.4"),
        "@@IPHONE@@": icon("phone", "ico", "1.4"),
        "@@IDIR@@": icon("directions", "ico", "1.4"),
    }
    for k, v in t.items():
        rep["@@T_" + k.upper() + "@@"] = v
    def render(assets, gal):
        out = TPL
        local = dict(rep)
        local.update({"@@LOGO@@": assets["logo"], "@@HERO@@": assets["hero"],
                      "@@PATTERN@@": assets["pattern"], "@@ARTCUP@@": assets["artCup"],
                      "@@ARTSHAKE@@": assets["artShake"]})
        caps = cafe.get("galleryCaptions", [])
        local["@@SHOTS@@"] = "".join(
            '<figure class="shot"><img src="%s" alt="%s" loading="lazy" decoding="async">'
            '<figcaption>%s</figcaption></figure>'
            % (g, esc((caps[n] if n < len(caps) else cafe["name"]) + " at " + cafe["name"]),
               esc(caps[n] if n < len(caps) else ""))
            for n, g in enumerate(gal))
        for k, v in local.items():
            out = out.replace(k, v)
        return out

    os.makedirs(os.path.join(ROOT, "dist"), exist_ok=True)
    frag = os.path.join(ROOT, "dist", "%s.artifact.html" % cafe_id)
    with open(frag, "w", encoding="utf-8") as f:
        f.write(render(A_data, gal_data))

    site = os.path.join(ROOT, "docs", cafe_id)
    os.makedirs(site, exist_ok=True)
    import shutil
    sassets = os.path.join(site, "assets")
    if os.path.isdir(sassets):
        shutil.rmtree(sassets)
    shutil.copytree(adir, sassets)
    tpl = render(A_rel, gal_rel)
    doc = ('<!doctype html><html lang="en"><head><meta charset="utf-8">'
           '<meta name="viewport" content="width=device-width,initial-scale=1">'
           '<meta name="theme-color" content="%s">'
           '<meta name="description" content="%s — menu, hours and directions.">'
           '<link rel="icon" href="%s">'
           '<style>html,body{margin:0}img{max-width:100%%}</style>'
           '</head><body>%s</body></html>'
           % (t["ink"], esc(cafe["name"]), A_rel["logo"], tpl))
    with open(os.path.join(site, "index.html"), "w", encoding="utf-8") as f:
        f.write(doc)

    kb = lambda p: os.path.getsize(p) / 1024.0
    print("built %s  ->  dist/%s.artifact.html (%.0f KB)  docs/%s/index.html (%.0f KB)"
          % (cafe_id, cafe_id, kb(frag), cafe_id, kb(os.path.join(site, "index.html"))))
    print("       %s sections, %s items, %s picks"
          % (len(menu["sections"]), rep["@@ITEMCOUNT@@"], len(picks)))

if __name__ == "__main__":
    build(sys.argv[1] if len(sys.argv) > 1 else "sorriso")
