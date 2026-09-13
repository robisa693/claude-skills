---
name: bokio-swedish-ab-bookkeeping
description: >
  Answer Swedish bookkeeping/tax/VAT questions about how to do something in Bokio, and verify
  SIE-4 exports from Bokio, for a single-shareholder Swedish IT-konsult aktiebolag. Use this
  skill whenever the user asks "how do I book X in Bokio", asks to double-check their Bokio
  bookkeeping, or uploads a .SE/.SI/SIE-4 file for review.
---

# Bokio bookkeeping verification (Swedish IT-konsult AB)

This skill packages a recurring workflow: answering "how do I do X in Bokio" questions and
double-checking SIE-4 exports, for a single-shareholder Swedish aktiebolag doing IT
consulting (SNI 62.0x). It is a thin wrapper that always defers to a live, external
reference repo rather than baking in accounting rules that go stale.

## Reference source (always check for updates first)

The authoritative reference material lives at:

`https://github.com/erp-mafia/accounted` — path `.claude/skills`

This repo contains a large set of Claude skills for Swedish bookkeeping compliance,
written for an accounting-software company. Relevant subset for this workflow:

- `industry/konsult-it/` — IT-konsult-specific patterns (reverse charge on foreign SaaS,
  EU/non-EU service invoicing, 3:12 for IT consultants, software capitalization)
- `modifier/single-shareholder-ab-fmb/` — fåmansbolag mechanics for a one-owner AB
  (marked as POC/test content in the repo itself — treat its figures as provisional and
  prefer `swedish-tax-planning` for anything load-bearing)
- `swedish-tax-planning/`, `swedish-vat/`, `swedish-invoice-compliance/`,
  `swedish-year-end-closing/`, `swedish-payroll/`, `swedish-financial-reporting/`,
  `swedish-asset-accounting/`, `swedish-accounting-compliance/` — horizontal skills
- `swedish-sie-import-export/` — SIE-4 record types, validation rules, encoding handling
- `swedish-project-accounting/`, `swedish-sru-filing/`, `swedish-e-invoicing/` — lower
  priority for a solo consultant AB (mostly aimed at people building accounting software),
  but load if the question is specifically about SRU filing, e-invoicing, or WIP/project
  accounting

### Step 0: check for updates, every time

Before answering, clone or re-fetch the repo (shallow, sparse-checkout on `.claude/skills`
is enough) and compare against what you last read in this conversation or prior sessions:

```bash
cd /tmp && rm -rf accounted-check && git clone --depth 1 --filter=blob:none --sparse \
  https://github.com/erp-mafia/accounted.git accounted-check
cd accounted-check && git sparse-checkout set .claude/skills
git log -1 --format=%H
```

If you have a previously recorded commit hash for this repo, diff against it
(`git log <old>..<new> --oneline -- .claude/skills`) and re-read any changed files before
proceeding. If this is the first time in a session, just read the relevant SKILL.md files
fresh — don't assume training data or an old cached read is current. Note the commit hash
you used so a future check can diff against it.

If the repo is unreachable (network restrictions), say so plainly and proceed with
whatever version of the skills you already have loaded, flagging that you couldn't confirm
it's current.

### Step 0b: Skatteverket outranks everything else

The `accounted` skills repo is a secondary source — someone's write-up of the rules, which
can lag or contain errors (it explicitly flags some of its own content as provisional, e.g.
`single-shareholder-ab-fmb`). **Skatteverket's own current published material is the primary
source and wins whenever the two conflict**, as long as it's genuinely the latest version.

For any figure or rule that actually matters to the answer (a threshold, a rate, a deadline,
a form field, a ställningstagande), search skatteverket.se and web-search generally for the
current position before finalizing the answer:

- Prefer skatteverket.se pages, current-year broschyrer/blanketter, and ställningstaganden
  over the repo's summary of them.
- Check the publication/last-updated date on whatever you find — an old cached SKV page or
  a ställningstagande that's since been replaced is not "the latest version." If you can't
  tell whether it's current, say so.
- When Skatteverket's own text and the `accounted` repo agree, cite Skatteverket's version
  (dnr/paragraph) as the primary reference and treat the repo as corroboration.
- When they disagree, go with Skatteverket, tell the user there was a discrepancy, and note
  it (in your response, not silently) so they know the repo may need updating upstream.
- Skip this live-verification step only for background/framework material that isn't
  time-sensitive (e.g. the general definition of an elektronisk tjänst) — not for anything
  with a number, date, or threshold attached.

## Workflow A: "How do I do X in Bokio?"

1. Identify the accounting/tax topic (VAT treatment, invoicing, payroll, year-end, asset
   capitalization, etc.) and load the matching skill(s) from the table above.
2. Answer with concrete BAS account numbers, the relevant law reference (ML/IL/BFL/ÅRL
   paragraph), and — since the question is "how do I do this in Bokio" specifically —
   translate the bookkeeping answer into what to actually click/enter in Bokio (which
   account, which VAT code, which document type) where you can infer it; flag clearly when
   you're inferring Bokio's UI behavior rather than citing it directly.
3. Flag when a figure is time-dependent (IBB/PBB, momssatser, thresholds) and verify the
   current-year value against skatteverket.se per Step 0b rather than trusting the repo's
   cached table alone.

## Workflow B: verify a SIE-4 export

1. Confirm the file is SIE type 4 (ideally 4E — full verifications, not just balances).
   If given a different format (TSV/CSV extract), explain that SIE-4 is preferred because
   it preserves per-verification structure, and ask for that instead if double-checking is
   the goal.
2. Detect encoding (declared `#FORMAT PC8`/CP437 is common from Bokio; verify it decodes
   cleanly, watch for mojibake) and convert to UTF-8 for readability.
3. Parse the file and check, per `swedish-sie-import-export`:
   - Every `#VER` block's `#TRANS` amounts sum to exactly 0.00
   - `#IB`/`#UB` continuity across periods, and that result accounts (3xxx-8xxx) have zero IB
   - Verification numbering is sequential with no gaps within each series
   - `#UB`/`#RES` balances reconcile against the sum of the verifications that feed them
4. Check account usage against the `konsult-it` patterns where applicable: foreign SaaS
   purchases (4531/4535 with matching 2614/2645), EU/non-EU service sales (3308/3305),
   owner salary (7210/7220) and its 3:12 implications, software capitalization (1010/1012 +
   2089 fond), and flag anything that looks like a common error pattern documented in that
   skill (e.g. domestic VAT charged on an EU B2B invoice, one-sided reverse charge entries).
5. Report per-verification: what it books, whether it balances, whether the account choice
   and any VAT/tax treatment look correct, and flag anything time-dependent (fiscal year
   length, deadlines implied by `#RAR`) worth confirming was a deliberate choice.
6. Summarize findings in a table or short list — verification-by-verification for a small
   file, or grouped by pattern for a large one — rather than restating every line of the raw
   file.

## What NOT to do

- Don't rely on memorized Swedish tax figures without checking the reference repo first —
  IBB, PBB, momssatser, and 3:12 parameters change yearly and mid-year.
- Don't treat `single-shareholder-ab-fmb` figures as final — it's explicitly marked POC/test
  content in the repo; cross-check against `swedish-tax-planning/references/312-regler.md`
  for anything the user will act on.
- Don't quietly skip the update check because "it was probably fine last time" — that's the
  entire point of this skill.
- Don't treat the `accounted` repo as the final word on any figure or rule that matters —
  it's a convenient cache of Skatteverket's position, not a replacement for it.
