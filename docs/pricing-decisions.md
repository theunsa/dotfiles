# Pricing decisions — Uys Prop brief

Recorded 2026-09-01. Applies to the Uys Prop managing-agent brief and sets
defaults for future clients.

## Rate

- **Standard rate: R1 000/h** (ex VAT). Up from R700 (briefly R850).
- Existing contract clients stay at R700 until renewal. New clients start at
  R1 000.
- AI does not lower the rate: it raises output per hour. It punishes hourly
  billing and rewards fixed pricing — so R1 000 is the anchor for quotes and
  overflow hours; sell fixed prices wherever possible.
- Discounts never deeper than ~50%; beyond that the standard number looks
  fake.
- Never discount the rate. Discount the total, visibly, once. A lowered rate
  becomes the new floor forever.
- SA benchmark used: junior freelancer R350–500, mid R500–750, senior solo
  R800–1 200, agency senior R1 200–1 800. Peer data point: another senior solo
  dev was charging R1 000 two to three years ago.

## Step 1 — Discovery

- **R12 000 fixed.**
- Realistic effort 25–35h (host, one mailbox, one form, manual owner import,
  demo, written roadmap). 16h was too optimistic.
- Framed in the brief as a first-client price; standard estimate ≈ R25 000
  (25h × R1 000), so ≈50% off. Stated once in the step note, not as a struck-through price.
- **Track every hour in Step 1.** It is the calibration for Step 2 and the
  retainer.

## Step 2 — Go live

- Not priced until Step 1 is done.
- Formula: **estimated hours × R1 000 × 1.25 contingency**, then an optional
  visible discount.
- Estimate only what Step 1 does **not** already deliver (install, first
  mailbox, first form, team/stage setup, import method are all done by then):
  - 11 more mailboxes, 0.5–1h each once the pattern exists: 6–11h
  - 3–5 more complaint forms, ~1h each: 3–5h
  - Stages / SLA polish: 2–3h
  - **Scheduled owner-data refresh** — the only real build. CSV import +
    cron ≈ 6–8h; scraping/API ≈ 15–20h. Step 1 finds out which.
  - Templates, signatures, auto-replies: 2–3h
  - Training + short docs: 4–6h
  - Zoho ticket migration, if wanted: 0–8h — quote as its own line
  - Total ~24–55h; × 1.25 → 30–70h → R30k–R70k raw.
- Indicative range printed in the brief: **R30 000 – R55 000**. Fixed
  number goes in the Step 1 roadmap.

## Ongoing retainer

- **R3 899/month**, ex VAT, billed monthly in advance.
- Built cost-plus, not matched to Zoho+JotForm: 3h × R1 000 = R3 000 plus
  hosting, daily backups, Odoo updates, monitoring. Comparison to current
  spend (R3 800) is a consequence, and is presented that way in the brief.
- Includes **3 support hours/month**: bugs, questions, config tweaks under
  ~30 min, adding users. Hours do not roll over (max one month if we relent).
- **Quoted separately:** any new form, workflow, module, or anything over 2h.
- Extra hours beyond the three: **R900/h**.
- Unlimited users. Trustees, owners, contractors are never on the bill.
- **Schemes: tiered, not per-scheme.**
  - Up to 15 schemes: R3 899
  - 16–30: R4 999
  - 31+: negotiated before it happens
  - New scheme onboarding: **once-off R1 000** (mailbox setup)
  - Rationale: marginal cost per scheme is ~zero; per-scheme pricing invites
    comparison with WeConnectU's per-unit fee and contradicts the "fee
    doesn't move" promise.
- Leniency option, if needed: time-boxed — first 3 months at R2 999, R3 899
  from month 4. Ends by itself, no renegotiation.

## SLA (if asked)

- Support hours: Mon–Fri 08:00–17:00 SAST.
- Critical (queue down): 4 business-hour response, same/next-business-day
  fix target.
- Normal: 1 business day response, 3 business days resolution.
- Feature requests: next planning cycle.
- Uptime: no 99.9% promise. "Monitored, daily backups, restore tested
  quarterly, target 99.5%."

## Paperwork

- Each step gets a **one-page Statement of Work (SOW)**. The SOW *is* the
  quote; a signed SOW is an accepted quote. No separate quote document.
- SOW contents: scope (incl. exclusions), deliverables, price, payment terms,
  time window, IP ownership (custom modules → client; own tooling → Albertec),
  POPIA/data line, signature.
- Payment: Step 1 50% upfront / 50% on demo. Retainer monthly in advance.

## Platform (retainer depends on this)

- **Odoo Community + OCA `helpdesk_mgmt`.** Enterprise is a last resort — its Helpdesk
  app is per-seat (~€20–30/user/month), which would break the "unlimited
  users" promise and the COGS below. Community + OCA + custom modules covers
  the roadmap for the foreseeable future.
- The retainer buys the platform, not a ticketing app: contacts, DMS,
  calendar, projects, surveys, knowledge base, reporting — all Community/OCA,
  no licence. The brief says so explicitly.
- Enterprise is not sold per app: it is one per-user subscription for the
  whole instance. A single Enterprise feature cannot be quoted as a one-off.
  If the client asks for something Enterprise-shaped (Sign, Studio, Planning,
  Documents…), in order:
  1. OCA equivalent (`sign_oca`, `dms`, `web_timeline`, …) — quote install +
     config as a one-off.
  2. Build the module — one-off fixed price, hours × R1 000 × 1.25.
  3. Enterprise migration only if the client accepts per-seat pricing
     explicitly; it changes the monthly and ends the unlimited-users promise.

## COGS (per month, ex VAT, rough 2026)

| Item | Est. |
|---|---|
| VPS 4 vCPU / 8 GB (Hetzner ≈ R250, local ≈ R500) | R250–500 |
| Offsite backups (storage box / B2) | R50–100 |
| Domain, DNS, SSL (Cloudflare + LE) | ~R20 |
| Outbound email (SES/Postmark) | R0–300 |
| Uptime monitoring (free tiers) | R0–100 |
| Odoo licence | R0 |
| **Cash COGS** | **≈ R500** |

Labour on top: ~1.5h/month patching/upgrades/monitoring (≈ R1 500 at rate)
plus the 3 included support hours. At R3 899 that leaves ≈ R1 900 for the
3h (≈ R630/h effective). Cash-positive; if the hours are fully used every
month, drop to 2h at renewal.

## Context

- WeConnectU pricing is not public; estimate R15–R30/unit/month → likely
  R10k–R25k/month for 12 schemes. Ask the client for the real number — it's
  a useful anchor.
- Zoho + JotForm currently ≈ R3 800/month, unused.

## Principles

- Price is not a judgement of the client's wallet; guessing their position
  and pre-discounting decides for them.
- Cheap signals doubt. Fair price + calm delivery signals competence.
- Charge for outcome, not hours. Fixed price where possible.
- Underpricing hurts the client long-term (resentment, corners, churn).
- Be generous with attention, honesty and named, finite discounts — not
  with the rate.
- If nobody ever says "expensive", the price is too low.

Reading: Jonathan Stark *Hourly Billing Is Nuts*; Blair Enns *Win Without
Pitching Manifesto*, *Pricing Creativity*; Alan Weiss *Value-Based Fees*;
Mike Michalowicz *Profit First*; Chris Voss *Never Split the Difference*.
