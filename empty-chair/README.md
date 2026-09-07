# Empty Chair

Win-back for appointment businesses. Answers one question: **who was supposed to
come back and hasn't?**

Built for Surat salons first. The engine is business-type agnostic — a salon's
"overdue for a haircut", a gym's "membership lapsing", a clinic's "recall due"
and a coaching class's "fee overdue" are the same query with a different
interval. `business_id` is on every row from line one. Never fork this per
vertical.

## Run it

    python3 -m http.server 8899
    open http://localhost:8899/app.html

No build step, no dependencies, no account. Open the Add tab and press
**Load demo salon** to see 70 customers with realistic drift.

## Why it sends WhatsApp the way it does

v1 uses `wa.me` click-to-send links. The owner taps a name, their own WhatsApp
opens with the message already written, and they press send.

This is deliberate, not a shortcut:

- WABA verification takes **2–10 business days**, so an API product cannot be
  live this week.
- A human sending from their own number needs no template approval, no DLT
  registration and no opt-in capture.
- The message arrives from a number the customer already knows, so it reads as
  the salon, not as a marketing blast.

Start WABA verification in parallel. Automated sending is the v2 upgrade and
only touches `Store.addNudge` and one send path.

## The one computation

Each customer's cadence comes from their own history — the **median** gap
between their visits, not a flat rule and not the mean, so a single long absence
doesn't permanently reset someone who is otherwise regular. Someone who comes
every 24 days and was last seen 40 days ago is overdue; someone who comes every
90 is not. This is the thing a paper register cannot do.

The overdue list is ranked by `overdue_days × average_spend`, so the most
valuable lapsed customer is the first name the owner sees.

## Attribution is the product

`nudges.returned_visit_id` links a message to the visit it produced. Without it
the owner renews on faith. With it, week one ends with *"you messaged 22 people,
9 came back, that's ₹11,400 you would not have taken"* — and ₹999/month becomes
arithmetic.

Nobody is nudged twice inside 14 days.

## Files

| | |
|---|---|
| `app.html` | The whole app. Self-contained, phone-first, works offline. |
| `schema.sql` | Supabase schema + RLS + the `overdue_customers` view. |

## Swapping in Supabase

Everything goes through the `Store` adapter in `app.html`. Reimplement its
methods against `schema.sql` and nothing else changes. Data currently lives in
`localStorage` — one browser, one device. **Export before switching phones**
(Settings → Export).

RLS is written so one business can never read another's customer list. Under the
DPDP Act the salon is the data fiduciary and we process on its behalf. Never
reuse one business's list for another — not once.

## Not built, on purpose

No bookings calendar, no POS, no payments, no staff logins, no inventory. The
incumbent salon tools are widely disliked for the weight of exactly those
features. This competes on one number, not on surface area.
