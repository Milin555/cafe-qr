# Cafe QR — multi-tenant ordering & loyalty SaaS

Building a QR menu + table ordering + loyalty product for independent cafes in Surat,
Gujarat. Solo developer. This folder is the **product build**; the sales strategy that
produced these requirements lives in `docs/SALES_KIT.md`.

Published field kit: https://claude.ai/code/artifact/43664c50-b4f1-47cd-a9f7-6d6c8a45b047

---

## What we're building

Three paid tiers. Every tier has a one-time setup fee plus a recurring charge.

| | **Menu** | **Orders** | **Complete** |
|---|---|---|---|
| Setup | ₹1,500 | ₹6,000 | ₹10,000 |
| Monthly | ₹499 | ₹1,499 | ₹2,999 |
| Annual | ₹4,999 | ₹14,999 *(setup waived)* | ₹29,999 *(setup waived)* |

All three annuals are exactly **two months free** — keep that invariant if prices change.

**Menu** — photo → digital menu, QR, printed standee PDF, unlimited edits, veg/non-veg/Jain
tags, sold-out toggle, no badge.
**Orders** — + custom domain, per-table QRs, cart, checkout, orders to a counter screen with
Web Push and sound, dynamic UPI QR, daily WhatsApp sales summary, scan/order analytics.
**Complete** — + loyalty, customer list (phone, last visit, lifetime spend, favourite item),
WhatsApp win-back at 30 days idle (2,000 msgs/mo), full brand-matched website, item-level
reports, review routing (1–3★ private to owner, 4–5★ nudged to Google).

---

## Build order — do not reorder

1. **Photo → QR, end to end.** Upload → vision model parses to structured JSON → **mandatory
   human review screen** → publish → QR + print-ready standee PDF. ~1–2 weeks.
   This is the highest-value thing in the project: it is simultaneously the walk-in demo,
   the free-sample mechanism, and the reason onboarding takes 15 minutes instead of 6 hours.
2. **One demo cafe** — fictional, Surat-flavoured, complete and *premium-looking*. It is the
   only sales asset. Premium cafes judge it in four seconds.
3. **Theme layer** — fonts, colours, logo as per-cafe **config, not code**. This is what
   justifies ₹2,999 over ₹1,499.
4. **Counter dashboard** — web page on a cheap Android tablet (the cafe buys it, not us).
   Orders list, Web Push, sound alert, mark-ready. Nothing else.
5. **Loyalty** — phone signup, points ledger, redeem at counter, 90-day expiry.
6. **Daily WhatsApp summary at close** — the single feature that makes an owner feel he's
   getting his money. Build before anything clever.

---

## Hard constraints

**Multi-tenant from line one.** `cafe_id` on every row. **Never fork the codebase per cafe** —
two forks and this is a job, not a product. Single most important decision here.

**Onboarding a paying cafe must take under 45 minutes; generating a demo under 2.** If
onboarding takes six hours this isn't a SaaS, and the business can never leave Surat.

**Never handle the cafe's money.** Dynamic UPI QR paying **directly into the owner's VPA**,
or pay-at-counter. No payment gateway in our name — that means settlement disputes, refunds
and KYC liability we're not set up for.

**No billing or GST invoicing in v1.** Restaurant service is 5% GST with no input credit;
invoices need the owner's GSTIN and correct SAC codes. Their existing bill stays. We are the
ordering layer only.

**Never auto-publish OCR output.** Indian cafe menus are laminated (glare), multi-column,
mixed English/Gujarati, decorative fonts, size variants stacked oddly. Vision models land at
~85–95%, which is fine for drafting and unacceptable for prices. Review screen shows every
price editable beside the source photo.

**Customer data is per-cafe and never shared.** Consent checkbox at loyalty signup
("I agree to receive offers from [Cafe] on WhatsApp"). Under the DPDP Act the cafe is the
data fiduciary and we process on its behalf. Never reuse one cafe's list for another — not
once.

**No native app.** Web Push + sound on an always-open tablet page.

---

## Loyalty spec — exact numbers, these matter

The naive scheme (₹200 = 20 pts, 100 pts = a free ₹200 item) is a 20% discount against ~60%
gross margin. Owners reject it instantly. Implement this instead:

| Rule | Value |
|---|---|
| Earn | 1 point per ₹10 spent (so ₹200 → 20 points) |
| Redeem | 1 point = ₹0.50, minimum 100 points, in ₹50 blocks |
| Cap per bill | ₹100 |
| Expiry | 90 days from last visit |
| Signup bonus | 25 points |
| Birthday | one free regular coffee |
| No points on | discounted items, or the redeemed portion of a bill |

Effective cost 5%, or 3–4% after breakage. Alternative mode for coffee-led cafes: stamp card,
buy 9 get the 10th free, one nominated item, max one free per week. **Never** offer
buy-5-get-6th-free (16.7%).

---

## Stack

- Menu pages: static, GitHub Pages (same pattern as `../demo_builds`)
- Backend: Supabase — free tier carries ~20 cafes, then ~₹2,100/mo on Pro
- Menu parsing: vision model, ~₹3 per menu
- Counter dashboard: web page, Web Push + audio
- Payments to cafes: dynamic UPI QR into the owner's own VPA
- WhatsApp: Business app initially (broadcast lists cap at 256 and only reach people who
  saved the cafe's number). At scale needs Business API via a BSP (Interakt/AiSensy),
  ~₹1,500–3,000/mo + per-message — hence the per-tier message caps. Price this in.

Three paying cafes cover all infrastructure.

---

## Context worth keeping

- **Market segments** drive the product: A = no QR (sell everything), B = friend-built free
  QR (sell ordering + loyalty, never the menu), C = premium/specialty (the beachhead — will
  reject anything that looks cheap), D = already on Petpooja (loyalty layer only, or skip).
- **Petpooja dominates Gujarat** and has its own QR add-on. We are not a POS and never
  replace billing. We're the customer-facing layer.
- **Every price is an untested hypothesis.** They come from one real data point (Surat cafes
  quoting ₹5,000 for a website+QR, ₹15–20k for a good one) plus reasoning. Validate with the
  flinch test in `docs/SALES_KIT.md` before treating any of them as settled.
- **Cafes are the worst-paying vertical this engine will run on.** Salons/spas pay 2–3× for
  the identical feature (rebooking reminders = win-back). Keep the loyalty engine
  business-type agnostic so it ports without a rewrite.

## Don't

- Promise more revenue — no baseline, no attribution. Promise scans, orders, phone numbers
  captured, repeat visits identified.
- Build inventory, staff management, or table reservations. Out of scope.
- Add a "powered by" badge to a paying cafe's page.
