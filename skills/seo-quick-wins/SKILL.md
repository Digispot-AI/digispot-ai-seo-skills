---
name: seo-quick-wins
description: Find the highest-impact, lowest-effort SEO fixes to ship this week — ROI-ranked quick wins with paste-ready remediations. Use when the user wants fast results or a "what should I fix first" shortlist. For a full graded audit use seo-audit; for ranking gains near page 1 use seo-striking-distance.
trigger: /seo-quick-wins
---

# /seo-quick-wins

A tight, ship-this-week shortlist. Maximize `traffic-at-risk × severity × ease`
while filtering hard for **high ease** (edits done in minutes, not sprints).

**First, read `FOUNDATIONS.md` in this skill's folder** and follow its scope +
crawl-freshness protocol.

## When to use

- "What should I fix first?" / "give me fast wins".
- Limited time or a stakeholder who needs visible movement quickly.

Reach for a sibling instead when: the user wants the *complete* picture →
`/seo-audit`; the wins require new content → `/seo-content-strategy`.

## Procedure

1. **Scope + crawl** (FOUNDATIONS §1–2).
2. **Pull the win lists:**
   - `get_quick_wins { crawlId, limit: 20 }` — Digispot's own ROI ranking. Core.
   - GSC connected → also `get_issues_with_traffic { crawlId }` and
     `get_high_traffic_at_risk { crawlId, minClicks: 10 }` to weight by real
     traffic.
3. **Filter for ease.** Keep only fixes that are genuinely cheap: title/meta
   edits, a canonical tag, one redirect, an alt text, a missing H1, an internal
   link. Drop anything needing new content or template/re-architecture work
   (that belongs in `/seo-audit` Plan/Backlog or `/seo-content-strategy`).
   To pinpoint these precisely instead of eyeballing, use `list_pages` filters:
   `{ hasMissingMetaDesc:true }`, `{ titleStatus:"missing,duplicate" }`,
   `{ h1Status:"missing" }` — each returns the exact paste-target pages, and
   `sortBy:"inboundLinkCount"` floats the highest-value ones first.
4. **Rank** the survivors by `priority_score` (FOUNDATIONS §5).
5. **Write the exact fix** for each (FOUNDATIONS §6). Quick wins are only quick
   if the user can paste them — no "consider revising".
6. **Optional — GENERATE the fix, don't just recommend it** (FOUNDATIONS §4
   Workflows). For the top title/meta or heading wins, offer to produce the exact
   new copy with AI instead of hand-writing it:
   - Title or meta on a page → **`Title & Meta Refresh`** (`input: { url }`) —
     returns an AI-written, keyword-informed title + meta.
   - Broken/duplicate heading hierarchy → **`Heading Structure Cleanup`**
     (`input: { url }`) — returns a clean H1–H6 outline.
   These are **actions** (AI + cloud credits): name that, run only on the user's
   go-ahead, then poll `get_workflow_run` and paste the result into the fix line.
   If workflows aren't licensed / no AI model, skip this and hand-write the fix.

## Output template

```
# SEO Quick Wins — <project> — crawl <date>
Ranked by ROI · all shippable this week · GSC signal: <on/off>

1. <issue> · <sev> · ~<clicks>/mo · ease HIGH — <url>
   Fix: <exact title/meta/canonical/redirect/anchor — paste-ready>
2. …

## Est. total traffic at stake: ~<clicks>/mo across <n> fixes
## Verify after shipping: re-crawl → /seo-progress-report
```

## Worked example

> User: `/seo-quick-wins`

1. `get_mcp_scope` → confirms project. `list_crawls` → reuse 1-day-old crawl.
2. `get_quick_wins {limit:20}` → 14 wins. `get_high_traffic_at_risk` → the FAQ
   page (600 clicks) is missing a meta description.
3. Filter: keep 9 (6 meta/title edits, 1 canonical, 1 redirect, 1 alt text);
   drop 5 that need new sections.
4. Rank: FAQ meta first (600 clicks, trivial), then the duplicate title on the
   contact page, etc.
5. Output #1:
   `Fix: <meta name="description" content="Answers to common questions about our
   services, pricing, booking and what to expect — straight from our team."> (142 chars)`
