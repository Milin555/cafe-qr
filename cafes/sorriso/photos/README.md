# Dish photos

Drop the cafe's photos here, named after the item exactly as it appears in
`menu.json`. Case and punctuation don't matter — spaces become hyphens.

    Loaded Hummus            ->  loaded-hummus.jpg
    Barrel Aged Cold Brew    ->  barrel-aged-cold-brew.jpg
    Cafè Latte               ->  cafe-latte.jpg   (accents are stripped)

Accepts .jpg .jpeg .png .heic .webp — straight off a phone is fine.

Then:

    python3 build/photos.py sorriso     # crops + compresses
    python3 build/render.py sorriso     # rebuilds the page

Every item with a matching photo gets it as its thumbnail and shows a larger
version when the row is expanded. Items without one keep the line-art icon,
so a half-finished shoot still looks deliberate.

## Shooting notes for the cafe

- One dish per frame, shot from directly above or at 45°, on the same surface
  each time. Consistency matters more than styling.
- Daylight near a window beats any indoor lighting. No flash.
- Leave space around the dish — the thumbnail is a centre square crop.
- Portrait or landscape both work; 1000px on the short edge is plenty.

Fifteen dishes shot in one sitting covers every item worth photographing.
