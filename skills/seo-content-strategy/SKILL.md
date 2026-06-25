---
name: seo-content-strategy
description: Build a content plan that grows topical authority — find content gaps (new pages to write), map topic clusters, and resolve keyword cannibalization. Use when the goal is what content to create or how to structure topics, not technical fixes. For technical/on-page issues use seo-audit; for near-page-1 rank pushes use seo-striking-distance.
trigger: /seo-content-strategy
---

# /seo-content-strategy

Plan the content that builds topical authority: which pages to write, how they
cluster into authoritative topics, and where existing pages cannibalize each
other. Output is a prioritized content roadmap with briefs.

**First, read `FOUNDATIONS.md` in this skill's folder** and resolve scope + crawl.

## When to use

- "What content should we create?" / "build our topical authority".
- The site has thin topic coverage or pages competing for the same term.

Reach for a sibling instead when: the page already ranks 8–20 and just needs a
push → `/seo-striking-distance`; the issue is technical/on-page → `/seo-audit`.

## Procedure

1. **Scope + crawl** (FOUNDATIONS §1–2).
2. **Content gaps — new pages to write:**
   `get_content_opportunities { section: "gaps", priority: "high" }` (then
   medium). Each gap returns title, why it matters, an outline, target keywords,
   the existing pages it extends, and priority/impact/intent.
3. **Topic clusters — the authority map:**
   `get_content_opportunities { section: "clusters" }`. Use this to group gaps
   into pillar → cluster structure and spot under-built topics.
4. **Cannibalization — pages fighting each other:**
   `get_content_opportunities { section: "cannibalization" }`. For each clash,
   decide: merge, differentiate intent, or canonicalize one to the other.
5. **Weight by demand (if GSC connected):** cross-reference gap keywords with
   `get_gsc_import_top_queries` to prioritize topics with proven impressions,
   and check `get_google_opportunities` so you don't propose content that
   duplicates a page already ranking.
6. **Rank** the roadmap by `impact × intent-value × ease-to-produce` and group
   **Write now / Next / Later**. For "Write now" items, produce a full brief.

## Output template

```
# Content Strategy — <project> — crawl <date>

## Topical authority map (pillars → clusters)
- Pillar: <topic> — existing: <urls> — gaps: <titles>
…

## Cannibalization to resolve
- "<keyword>": <urlA> vs <urlB> → <merge | differentiate | canonicalize A→B>

## Content roadmap (ranked)
### Write now
**<Working title>**  ·  intent: <informational/commercial>  ·  ~<imp>/mo
- Why: <one line>
- Target keywords: <list>
- Outline (H2s): <list>
- Interlink with: <existing urls>  (and from them, anchor "<text>")
### Next / Later: <titles>

## Verify after shipping: publish → re-crawl → /seo-progress-report
```

## Worked example

> User: `/seo-content-strategy`

1. Scope + crawl confirmed.
2. `get_content_opportunities {section:"gaps",priority:"high"}` → gap: "How <service>
   works, explained" — extends the overview page, target "<service> process".
3. `section:"clusters"` → the "How it works" pillar is thin (only 1 page).
4. `section:"cannibalization"` → two pages both target "<service>" → recommend
   merging the weaker into the stronger with a 301.
5. GSC: "<service> process" shows 1,800 imp with no ranking page → strong
   Write-now.
6. Brief for the new page: intent informational, step-by-step H2s, an FAQ block,
   interlink to the overview + services + the new pricing page.
