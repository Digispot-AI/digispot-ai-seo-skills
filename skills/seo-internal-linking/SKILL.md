---
name: seo-internal-linking
description: Fix internal link architecture — surface orphan pages, too-deep pages, and weak anchors, then output an exact internal-link plan (source → target, anchor text) from the site graph. Use to spread link equity, rescue orphans, or strengthen a target page. For external backlinks or content gaps use other skills.
trigger: /seo-internal-linking
---

# /seo-internal-linking

Internal links are the cheapest ranking lever you fully control. This skill
reads the site graph, finds pages that are orphaned / buried / under-linked, and
produces a precise `source → target` link plan with anchor text.

**First, read `FOUNDATIONS.md` in this skill's folder** and resolve scope + crawl.

## When to use

- Pages aren't getting crawled/ranked because nothing links to them.
- You just published new pages and need to wire them into the site.
- You want to push equity toward a money/target page.

Reach for a sibling instead when: the need is *new content* →
`/seo-content-strategy`; the page just needs a rank push and links are only one
part → `/seo-striking-distance` (which also calls link insights).

## Procedure

1. **Scope + crawl** (FOUNDATIONS §1–2).
2. **Read the structure:** `get_site_graph { crawlId }` — page/link counts,
   crawl depth, orphan pages, indexability. This frames the problem.
3. **Get linking suggestions by failure reason:**
   - `get_link_insights { section:"suggestions", reason:"orphan" }` — pages with
     no inbound internal links.
   - `{ reason:"low-inbound" }` — under-linked pages.
   - `{ reason:"deep" }` — buried >3 clicks from home.
   Each suggestion includes relevance, confidence, shared keywords, and a
   suggested anchor.
4. **Identify the hubs:** `get_link_insights { section:"hubs" }` — your
   authority pages. Prefer adding links *from* hubs to lift targets fastest.
5. **Check anchor health:** `get_link_insights { section:"anchors" }` — avoid
   over-optimized exact-match repetition; diversify anchors.
6. **Prioritize targets by value.** If GSC is connected, weight targets by
   `get_high_traffic_at_risk` / striking-distance pages so links flow to pages
   that convert demand, not random orphans.
7. **Output the link plan** — concrete `source URL → target URL`, exact anchor,
   and where on the source page the link belongs.

## Output template

```
# Internal Linking Plan — <project> — crawl <date>
Pages: <n> · orphans: <n> · pages >3 clicks deep: <n> · hub pages: <list>

## Rescue orphans (no inbound links)
- <target url>  ← from <source url>, anchor "<text>", in <section/paragraph>

## Strengthen priority targets (traffic-weighted)
- <target url> (<clicks>/mo, pos <x>)  ← from <hub url>, anchor "<text>"
  ← from <url>, anchor "<text>"   (diversified anchors)

## Reduce depth
- <deep url> (depth <n>)  ← add link from <shallow url> anchor "<text>"

## Anchor cleanup
- <url>: <N> exact-match "<anchor>" inbound → vary to "<a>", "<b>"

## Verify after shipping: re-crawl → /seo-progress-report (orphans should drop)
```

## Worked example

> User: `/seo-internal-linking`

1. Scope + crawl confirmed.
2. `get_site_graph` → 64 pages, 5 orphans, 9 pages deeper than 3 clicks.
3. `get_link_insights {section:"suggestions",reason:"orphan"}` → the new
   "staging" page has 0 inbound; suggested anchor "oral cancer stages",
   confidence 0.9, from the symptoms page.
4. `section:"hubs"` → the treatments page is the top hub (28 inbound).
5. Plan: link staging ← symptoms (anchor "oral cancer stages") and ← treatments
   hub (anchor "cancer staging"); pull the cost page from depth 4 to 2 by
   linking it from the treatments hub.
