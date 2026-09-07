# Cafe QR — build

    python3 build/photos.py <cafe-id>     # optional: prepare dish photos
    python3 build/render.py <cafe-id>     # build the page
    python3 build/print.py  <cafe-id>     # QR + print-ready standee

Outputs both `dist/<id>.artifact.html` (fragment, for publishing) and
`dist/<id>/index.html` (standalone doc, for GitHub Pages). Assets are inlined as
data URIs, so a built page has zero external requests except Google Fonts.

    build/render.py     the engine — one renderer, every cafe
    build/page.html     the template (tokens: @@NAME@@, @@T_INK@@, …)
    build/icons.py      46 line-art item icons + 14 UI icons, shared
    build/photos.py     crops dish photos to thumbnails
    build/print.py      QR + standee (build/standee.swift does the drawing)
    cafes/<id>/cafe.json    brand, contact, hours, theme  ← config, not code
    cafes/<id>/menu.json    sections and items            ← the reviewable artifact
    cafes/<id>/assets/      logo, pattern, photos
    cafes/<id>/photos/      drop dish photos here, named after the item
    cafes/<id>/print/       qr.png and standee-a5.pdf, generated
    cafes/<id>/REVIEW.md    sources + what still needs the owner's confirmation

Adding a cafe means adding a folder under `cafes/`. The renderer is never edited per cafe.
