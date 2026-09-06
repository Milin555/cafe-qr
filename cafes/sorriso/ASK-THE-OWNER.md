# Ask the owner — 22 dish descriptions

One line each. These are the only items on the menu a customer cannot guess
from the name, and they include the most expensive things Sorriso sells —
which is exactly where hesitation costs an order.

The other 74 items need nothing: 18 are coffee preparations already described,
and 56 state their own contents (Nutella Shake, Cheese Garlic Bread, Margherita).
Putting a description on all 96 would make every row tappable and the little
chevron would stop meaning anything.

Sorted by price — start at the top.

| ₹ | Item | Section | Their words |
|---:|---|---|---|
| 565 | Organic Farm Pizza | Neapolitan Pizza | |
| 385 | Triple Thread Nachos | Appetizers | |
| 380 | Ferrero Rocher Cheesecake | Desserts | |
| 375 | Sundried Tomato Garlic Bread | Appetizers | |
| 375 | Modern Indian Aglio Olio | Pasta Bowls | |
| 375 | Herbs Rice With Queso Sauce | Rice Bowls | |
| 365 | Cheese Chilli Garlic Bread | Appetizers | |
| 355 | Tanisia Salad | Salads | |
| 350 | Heven Hummus | Hummus Special | |
| 345 | Loaded Hummus | Hummus Special | |
| 330 | Avocado Dilight Focaccia | Sandwich / Open Toast | |
| 330 | Green With Avocado Salad | Salads | |
| 320 | Godfather | Iced Beverages | |
| 320 | Cucumber Twist Hummus | Hummus Special | |
| 315 | Avocado Collegian Bhel | Appetizers | |
| 300 | Tropical Heatwave | Signature Mocktail | |
| 300 | Barry Gingar Twist | Signature Mocktail | |
| 280 | Twilight Jamun | Signature Mocktail | |
| 270 | Cranberry Passionfruit Splash | Mocktails | |
| 270 | Sunset Bliss | Mocktails | |
| 270 | Litchi Lover | Mocktails | |
| 260 | Cranberry Kaffira | Signature Mocktail | |

## Adding them

Put a `desc` on the item in `cafes/sorriso/menu.json`, then rebuild:

    python3 build/render.py sorriso

Ask about allergens while you are there — nuts and dairy especially. Those
become tags on the same row and are the thing premium cafes get asked most.
