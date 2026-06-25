---
name: seo-striking-distance
description: Turn near-page-1 rankings (position 8-20 / striking distance) and high-traffic pages that have on-page issues into a concrete rank-gain plan. Use when GSC is connected and the goal is more organic traffic from queries you almost rank for. For cheap fixes regardless of rank use seo-quick-wins; for a full audit use seo-audit.
trigger: /seo-striking-distance
---

# /seo-striking-distance

The biggest growth lever on an established site: pages already ranking 8–20
need a nudge, not a rewrite. This skill marries GSC rank data with on-page
audit problems and outputs the specific moves to push them onto page 1.

**First, read `FOUNDATIONS.md` in this skill's folder.** This skill **requires
GSC connected** — if `list_gsc_imports` / the GSC tools return no data, say so
and suggest connecting GSC, then offer `/seo-audit` as the non-GSC fallback.

## When to use

- GSC is connected and the user wants traffic growth, not just hygiene.
- "Which pages are about to break into page 1?" / "where's the easy traffic?".

## Procedure

1. **Scope + crawl** (FOUNDATIONS §1–2) and confirm GSC data exists
   (`list_gsc_imports`).
2. **Find striking-distance demand:**
   - `get_gsc_import_top_queries { strikingDistance: true, limit: 30 }` —
     position 8–20 queries: high impressions, low clicks, close to page 1.
   - `get_high_traffic_at_risk { crawlId, minClicks: 10 }` — pages with real
     traffic that *also* carry issues (fixing these protects + grows).
3. **Correlate rank × on-page problem:**
   - `get_google_opportunities { crawlId, limit: 20 }` — the unified score
     (traffic × severity × rank proximity). This is the master list; lead here.
4. **Diagnose each target page in parallel.** For the top ~15 opportunity pages,
   **dispatch parallel subagents** running `get_page_issues { crawlId, pageId }`
   (+ `get_page_report` for content depth) to find *why* it's stuck at 8–20:
   thin content vs the query, missing intent coverage, weak title match, missing
   schema, slow LCP, few internal links.
5. **For each page, prescribe the rank-gain move(s):**
   - **Title/meta** rewritten to match the striking-distance query intent.
   - **Content** — the H2s / entities to add to fully answer the query (pull the
     query from step 2; outline what's missing).
   - **Internal links** — anchor-rich links *to* this page (cross-check with
     `get_link_insights { section:"suggestions" }`).
   - **Schema** — the JSON-LD that earns rich results for the query type.
6. **Rank** by combined opportunity score; group **Ship now / Plan**.

## Output template

```
# Striking-Distance Plan — <project> — crawl <date>
GSC window: <dates> · queries pos 8-20: <n> · opportunity pages: <n>

## Page: <url>  ·  ~<impressions>/mo  ·  avg pos <x.x>  ·  opp score <n>
**Target queries (pos 8-20):** "<q1>" (pos <x>, <imp>), "<q2>" …
**Why it's stuck:** <diagnosis from page issues>
**Moves:**
- Title → "<exact new title>" (<chars>)
- Content → add H2s: <list>; cover entities: <list>
- Links → from <url> anchor "<text>"; from <url> anchor "<text>"
- Schema → <JSON-LD block>
**Expected:** push "<q1>" from pos <x> toward page 1.

## Verify after shipping: re-crawl + watch GSC position → /seo-progress-report
```

## Worked example

> User: `/seo-striking-distance`

1. Scope confirmed; `list_gsc_imports` → GSC present.
2. `get_gsc_import_top_queries {strikingDistance:true}` → "oral cancer surgery
   cost" sits pos 11, 2,400 imp/mo, 40 clicks.
3. `get_google_opportunities` → the cost page tops the list (high imp × thin
   content × pos 11).
4. Subagent `get_page_issues` on that page → no pricing schema, title is generic
   ("Treatments"), only 1 internal link.
5. Plan: title → "Oral Cancer Surgery Cost in <city> — Transparent Pricing"
   (57 chars); add H2s "What affects the cost", "Insurance & EMI"; add 3
   internal links with anchor "oral cancer surgery cost"; add `MedicalProcedure`
   + `Offer` JSON-LD. Expected: pos 11 → page 1 for the head query.
