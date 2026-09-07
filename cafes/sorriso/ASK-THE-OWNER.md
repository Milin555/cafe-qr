# Replace these 7 descriptions

Every item on the menu now shows a description. 89 of them are accurate:
they follow from the dish's own name or are true by definition of the
preparation (a cortado *is* espresso cut with warm milk).

**These 7 are placeholders.** Their names give nothing away and I will not
invent what is in someone's food — so they currently say "ask the counter".
That is honest, but it is not good enough to leave on a table tent.

| ₹ | Item | Section | Currently says |
|---:|---|---|---|
| 385 | Triple Thread Nachos | Appetizers | The larger loaded nachos. Ask the counter for the toppings. |
| 355 | Tanisia Salad | Salads | A house salad. Ask the counter for the composition. |
| 350 | Heven Hummus | Hummus Special | A house hummus plate. Ask the counter what is on it. |
| 345 | Loaded Hummus | Hummus Special | Hummus served loaded — ask the counter for today's toppings. |
| 320 | Godfather | Iced Beverages | A house iced coffee. Ask the counter how it is built. |
| 300 | Tropical Heatwave | Signature Mocktail | A house signature mocktail, tropical and served long. |
| 270 | Sunset Bliss | Mocktails | A house mocktail. Ask the counter for today's build. |

Get one line each from the owner, then in `cafes/sorriso/menu.json` replace
the `desc` and delete the `descPlaceholder: true` flag next to it.

    python3 build/render.py sorriso
