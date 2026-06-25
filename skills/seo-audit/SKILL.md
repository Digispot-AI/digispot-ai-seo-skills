---
name: seo-audit
description: Run a full graded SEO audit of the Digispot-bound site and return an ROI-ranked, paste-ready fix plan. Use for a complete health check or baseline. Covers technical, duplicates/canonical, schema/AEO, mobile parity, and indexation as dimensions. For just the cheap wins use seo-quick-wins; for near-page-1 ranking gains use seo-striking-distance.
trigger: /seo-audit
---

# /seo-audit

The entry-point audit. Produces a graded baseline and a fix plan ranked by
`traffic-at-risk × severity × ease`, with paste-ready remediations.

**First, read `FOUNDATIONS.md` in this skill's folder** and follow its scope +
crawl-freshness protocol — every step below assumes it.

## When to use

- A new site / first engagement (establish the baseline).
- A periodic full health check.
- The user asks "audit the site" / "what's wrong with my SEO".

Reach for a sibling instead when: only cheap wins matter → `/seo-quick-wins`;
chasing rankings already near page 1 → `/seo-striking-distance`; the question is
content → `/seo-content-strategy`; verifying past fixes → `/seo-progress-report`.

## Procedure

1. **Scope + crawl** (FOUNDATIONS §1–2). Confirm project; get the latest
   completed crawl or run one. State the crawl date you're auditing.
2. **Grade.** `get_project_health` (letter grade + trend) and
   `get_crawl_summary { crawlId }` (site scores + Core Web Vitals). Open with
   this snapshot.
3. **Get the traffic-weighted spine of the audit:**
   - GSC connected → `get_issues_with_traffic { crawlId }` and
     `get_high_traffic_at_risk { crawlId }`. These ARE your ranking — lead here.
   - No GSC → `get_critical_issues { crawlId }` + `get_quick_wins { crawlId }`,
     rank by severity × ease, and note the missing traffic signal.
4. **Sweep the audit dimensions** (these replace separate skills). Pull each,
   keep only material findings:
   - **Technical/crawl:** `get_critical_issues`, `get_broken_links`,
     `get_redirects`, `get_robots_blocked_urls`.
   - **Duplicates/canonical:** `get_duplicates`.
   - **Indexation/sitemap:** `get_sitemap_coverage`; spot-check key URLs with
     `get_url_inspection` if GSC is connected.
   - **Mobile parity:** `get_device_comparison { crawlId }` and
     `get_device_url_gaps`.
   - **Schema/AEO + on-page:** `list_issue_definitions { category: "schema" }`
     / `{ category: "aeo" }` to learn the rubric, then `get_issue_pages` for the
     ones flagged on this crawl.
5. **Drill the top at-risk pages in parallel.** Take the top ~15–20 pages from
   step 3 and **dispatch parallel subagents**, each running
   `get_page_issues { crawlId, pageId }` (and `get_page_report` if needed) for
   one page, returning a compact finding list. Synthesize in the main thread.
6. **Rank + group** every finding by `priority_score` (FOUNDATIONS §4) into
   **Ship now / Plan / Backlog**.
7. **Write paste-ready fixes** (FOUNDATIONS §5) for at least every "Ship now"
   item — exact title/meta strings, canonical tags, redirect maps, JSON-LD.

## Output template

```
# SEO Audit — <project> — crawl <date>
**Grade:** <A–F> (<trend>)   **Site score:** <n>/100   **CWV:** <pass/fail mix>
**Pages crawled:** <n>   **GSC traffic signal:** <on/off>

## Top 5 fixes by ROI
1. <issue> · <sev> · ~<clicks>/mo · ease <h/m/l> — <url> — <one-line fix>
…

## Ship now (this week)
<finding blocks per FOUNDATIONS §5>

## Plan (this sprint)
…

## Backlog
…

## Verify after shipping
Re-crawl, then /seo-progress-report against crawl <date> to confirm fixes cleared.
```

## Worked example

> User: `/seo-audit`

1. `get_mcp_scope` → "Auditing **Acme Clinic**."
2. `list_crawls {status:"completed",limit:5}` → newest is 2 days old → reuse it.
3. `get_project_health` → C+, improving. `get_crawl_summary` → 72/100, 18% LCP fail.
4. `get_issues_with_traffic` → "Missing meta description" tops it: 9 pages,
   ~340 clicks/mo. `get_high_traffic_at_risk {minClicks:10}` → the services
   page (1.2k clicks) has a duplicate H1 + no schema.
5. Sweep: `get_duplicates` (4 dup titles), `get_redirects` (1 chain),
   `get_device_comparison` (mobile LCP 3.1s vs 1.9s desktop).
6. Fan out `get_page_issues` over the top 15 pages via subagents.
7. Output: services page → exact 58-char title, 152-char meta, a `Service`
   JSON-LD block, and the redirect chain collapsed to a single 301.
