# Cafe QR — build

    python3 build/render.py <cafe-id>     # e.g. sorriso

Outputs both `dist/<id>.artifact.html` (fragment, for publishing) and
`dist/<id>/index.html` (standalone doc, for GitHub Pages). Assets are inlined as
data URIs, so a built page has zero external requests except Google Fonts.

    build/render.py     the engine — one renderer, every cafe
    build/page.html     the template (tokens: @@NAME@@, @@T_INK@@, …)
    build/icons.py      43 line-art item icons + 12 UI icons, shared
    cafes/<id>/cafe.json    brand, contact, hours, theme  ← config, not code
    cafes/<id>/menu.json    sections and items            ← the reviewable artifact
    cafes/<id>/assets/      logo, pattern, photos
    cafes/<id>/REVIEW.md    sources + what still needs the owner's confirmation

Adding a cafe means adding a folder under `cafes/`. The renderer is never edited per cafe.
