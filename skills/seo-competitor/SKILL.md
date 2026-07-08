---
name: seo-competitor
description: Compare your page head-to-head against a competitor's ranking page and get a prioritized plan to beat them — point-by-point scores, content/schema/speed gaps, and the backlink gap. Use when a rival outranks you for a query and you want to know exactly why and what to change. For your own near-page-1 pushes use seo-striking-distance; for a full site audit use seo-audit.
trigger: /seo-competitor
---

# /seo-competitor

The head-to-head. Given your page and a competitor's page (the one outranking you
for a query you care about), this skill runs the comparison workflow and turns the
diff into a concrete "beat them" plan — what to add, fix, and earn.

**First, read `FOUNDATIONS.md` in this skill's folder.** This skill is driven by a
**workflow** (`Competitor Page Comparison`), so follow the FOUNDATIONS §4 workflow
pattern (list → match by name → run → poll) and its **diagnose-vs-produce** consent
rule — the comparison drives crawl + AI and (with backlinks) cloud credits.

## When to use

- A competitor outranks you for a target query and you want to know **why**.
- "What does <rival page> have that mine doesn't?" / "how do I beat this page?".
- You have (or can name) the specific competitor URL to compare against.

Reach for a sibling instead when: the goal is pushing your own pos-8–20 pages and
links are only part of it → `/seo-striking-distance`; you want a full site health
check → `/seo-audit`; you need the backlink profile of *your* site alone →
`/seo-audit` (off-page dimension).

## Procedure

1. **Scope** (FOUNDATIONS §1). Confirm the project.
2. **Get the two URLs.** `urlA` = your page, `urlB` = the competitor's page.
   - If the user only gives a query ("who beats me for `<query>`"), pull *your*
     ranking page from `get_gsc_import_top_queries` / `get_high_traffic_at_risk`,
     and ask the user for the competitor URL that outranks it (the skill compares
     two specific pages — it does not discover competitors).
3. **Run the comparison** (FOUNDATIONS §4 workflow pattern):
   - `list_workflows` → find **"Competitor Page Comparison"**, read its `id`.
   - `run_workflow { workflowId: <that id>, input: { urlA, urlB, fetchBacklinks: true } }`.
     `fetchBacklinks:true` adds the off-page gap (referring domains / authority) —
     it uses cloud credits, so name that and run on the user's go-ahead; pass
     `false` to skip off-page.
   - Poll `get_workflow_run { runId }` until `completed`; read the verdict + diff.
4. **Translate the diff into a prioritized plan.** The workflow returns a
   point-by-point comparison (scores, title/meta, headings, keywords, schema,
   links, images, page speed, and — if requested — backlinks). Convert each gap
   where the competitor wins into a concrete move, ranked by
   `impact × ease` (FOUNDATIONS §5):
   - **Content/intent gaps** → the H2s / entities / questions their page answers
     that yours doesn't.
   - **Schema** → structured data they have and you don't (promise a *rich result*
     only for types Google still renders — FOUNDATIONS §6).
   - **Speed / Core Web Vitals** → where their page is faster.
   - **Backlink gap** → referring-domain / authority difference (this is a
     campaign, not a same-day fix — flag it as such).
5. **Write the paste-ready fixes** (FOUNDATIONS §6) for the on-page gaps, and a
   short "earn these links / this authority" note for the off-page gap.

## Output template

```
# Competitor Comparison — <project>
You: <urlA>   vs   Competitor: <urlB>
Overall: you <n>/100 · them <m>/100   ·   backlinks: you <x> refdomains · them <y>

## Why they win (ranked by ROI)
1. <gap> — them: <their value> · you: <your value> — <one-line fix>
…

## Beat-them plan
### Ship now (on-page, paste-ready)
- Content → add H2s: <list>; cover entities/questions: <list>
- Schema → <JSON-LD block they have and you don't>
- Speed → <the specific CWV gap to close>
### Campaign (off-page)
- Backlink gap: them <y> vs you <x> referring domains → <how to close: digital PR,
  the specific sources linking to them worth pursuing>

## Verify after shipping: re-crawl your page → /seo-progress-report; re-run /seo-competitor to confirm the gap closed.
```

## Worked example

> User: `/seo-competitor` — "example.com/pricing is beaten by rival.com/pricing for `<service> cost`"

1. Scope confirmed.
2. `urlA = example.com/pricing`, `urlB = rival.com/pricing` (user supplied the rival).
3. `list_workflows` → "Competitor Page Comparison" id; `run_workflow { input:
   { urlA, urlB, fetchBacklinks:true } }`; poll → completed.
4. Diff: rival has a pricing table + `Offer`/`Product` schema + an FAQ; loads 0.8s
   faster (LCP); and has 3× the referring domains.
5. Plan — Ship now: add a comparable pricing table, add `Product` + `Offer`
   JSON-LD, add the 4 FAQ questions their page answers, defer/lazy-load the hero
   image to close the LCP gap. Campaign: the rival earns links from 3 industry
   directories + 2 review sites — pursue those. Expected: close the on-page gap
   this week, chip the backlink gap over the quarter.
