# Pricing decisions — Uys Prop brief

Recorded 2026-09-01. Applies to the Uys Prop managing-agent brief and sets
defaults for future clients.

## Rate

- **Standard rate: R850/h** (ex VAT). Up from R700.
- Existing contract clients stay at R700 until renewal. New clients start at R850.
- Never discount the rate. Discount the total, visibly, once. A lowered rate
  becomes the new floor forever.
- SA benchmark used: junior freelancer R350–500, mid R500–750, senior solo
  R800–1 200, agency senior R1 200–1 800.

## Step 1 — Discovery

- **R12 000 fixed.**
- Realistic effort 25–35h (host, one mailbox, one form, manual owner import,
  demo, written roadmap). 16h was too optimistic.
- Framed in the brief as a first-client price; standard estimate ≈ R21 000
  (25h × R850). Stated once in the step note, not as a struck-through price.
- **Track every hour in Step 1.** It is the calibration for Step 2 and the
  retainer.

## Step 2 — Go live

- Not priced until Step 1 is done.
- Formula: **estimated hours × R850 × 1.25 contingency**, then an optional
  visible discount.
- Inputs to estimate:
  - Mailboxes: 12 × ~1.5h (aliases, DNS/SPF, routing, test)
  - Forms: per complaint type × ~1.5h
  - Teams / stages / SLA config: 4–6h
  - Owner data load + scheduled refresh: 8–40h — **biggest variable**;
    depends on WeConnectU export method (CSV vs scraping vs API). Find out
    in Step 1.
  - Templates, auto-replies, signatures: 3–5h
  - Training + docs: 4–8h
  - Migration of open Zoho tickets: ask the client
- Expected band R35k–R60k.

## Ongoing retainer

- **R4 200/month**, ex VAT, billed monthly in advance.
- Built cost-plus, not matched to Zoho+JotForm: 4h × R850 = R3 400 plus
  hosting, daily backups, Odoo updates, monitoring. Comparison to current
  spend (R3 800) is a consequence, and is presented that way in the brief.
- Includes **4 support hours/month**: bugs, questions, config tweaks under
  ~30 min, adding users. Hours do not roll over (max one month if we relent).
- **Quoted separately:** any new form, workflow, module, or anything over 2h.
- Extra hours beyond the four: **R750/h**.
- Unlimited users. Trustees, owners, contractors are never on the bill.
- **Schemes: tiered, not per-scheme.**
  - Up to 15 schemes: R4 200
  - 16–30: R5 400
  - 31+: negotiated before it happens
  - New scheme onboarding: **once-off R850** (mailbox setup)
  - Rationale: marginal cost per scheme is ~zero; per-scheme pricing invites
    comparison with WeConnectU's per-unit fee and contradicts the "fee
    doesn't move" promise.
- Leniency option, if needed: time-boxed — first 3 months at R2 999, R4 200
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
