---
name: seo-progress-report
description: Prove whether SEO fixes worked — compare two crawls (issues fixed vs new, score/page deltas) and overlay GSC/GA4 trends. Use after shipping fixes to verify gains, catch regressions, and report to stakeholders. For finding new problems use seo-audit; for the cheap-fix shortlist use seo-quick-wins.
trigger: /seo-progress-report
---

# /seo-progress-report

Close the loop. After fixes ship, this skill compares crawls and trends to show
what actually improved, what regressed, and what's still open — the report you
hand a stakeholder.

**First, read `FOUNDATIONS.md` in this skill's folder** and resolve scope.

## When to use

- After shipping fixes from `/seo-audit`, `/seo-quick-wins`, etc.
- Periodic stakeholder reporting ("are we winning?").
- Suspected regression after a deploy.

## Procedure

1. **Scope** (FOUNDATIONS §1). Confirm project.
2. **Pick the two crawls to compare:**
   `list_crawls { status:"completed", limit:10 }`. Default: newest vs the crawl
   just before the fixes shipped (ask the user if the baseline is ambiguous). If
   the newest crawl predates the fixes, offer to `start_crawl` + `wait_for_crawl`
   first so the comparison reflects shipped work.
3. **Diff the audits:**
   - `compare_audits { baselineCrawlId, comparisonCrawlId }` — score changes,
     pages added/removed, issues fixed vs newly introduced.
   - `get_audit_deltas` — the change detail.
4. **Overlay the trend:** `get_project_trends { limit: 10 }` — is the score line
   going up over several crawls, not just two points? Then `get_project_health`
   for the current **letter grade + direction** — this populates the
   `Grade <x>→<y>` headline (compare_audits/trends give the numeric score; the
   grade comes from here).
5. **Overlay real traffic (if GSC/GA4 connected):**
   - `get_gsc_import_top_pages` / `get_gsc_import_top_queries` — did clicks /
     positions move for the pages you fixed?
   - `get_ga4_sections` / `get_google_metrics` — sessions, **engagement rate**,
     and avg engagement duration trend (GA4 bounce = 1 − engagement, so lead with
     engagement rate; report bounce only if the stakeholder asks). These are UX
     signals, **not confirmed ranking factors** — don't credit a rank move to
     them, and pair engagement with conversion rate to stay interpretable.
   - **Judge the traffic's quality, not just its size** (see FOUNDATIONS §5.1).
     Rising sessions from the wrong **geography** isn't a win — a Chennai business
     gaining US sessions has a relevance problem, not progress; report the
     *serving-area* share and whether it grew. Read the **channel trend**: rising
     **Organic** is your strongest proof SEO worked — lead with it; sessions
     carried mostly by Paid is fragile, say so. Weigh **landing-page** behaviour
     (high sessions + high bounce = wrong-intent traffic, not a gain).
   - `get_url_inspection { url }` — confirm a specific fixed page is now indexed /
     its canonical resolved.
6. **Explain dips before blaming the site:** if clicks/sessions fell in the
   window, call `get_google_search_incidents` for that window. A dip aligned with
   a Google **core/spam update** is Google-side — report it as such, don't
   prescribe fixes for a regression the site didn't cause.
7. **Report:** what improved (tie each win to the fix that caused it), what
   regressed (flag as new "Ship now"), what's still open. Be honest — don't
   credit a fix the data doesn't support.

## Output template

```
# SEO Progress Report — <project>
Baseline: crawl <date>  →  Latest: crawl <date>

## Headline
Score <a> → <b> (<+/-n>) · Issues fixed: <n> · New issues: <n> · Grade <x>→<y>

## Wins (fix → result)
- "<issue>" on <url> → cleared; GSC pos <x>→<y>, clicks <a>→<b>
…

## Regressions / new issues  (→ next Ship-now)
- <issue> on <url> · <sev> · ~<clicks>/mo

## Still open from last plan
- <issue> on <url>

## Traffic trend (GSC/GA4)
- Clicks <a>→<b> · avg pos <x>→<y> · sessions <a>→<b>
- Quality: Organic <a>→<b> (channel trend <↑/→/↓>) · serving-area geo share <x%> · <relevance note if geo is off-target>
- <if a dip: "Aligns with <Month> Google <core/spam> update — Google-side, not a site regression">

## Next: <re-run /seo-quick-wins on regressions | continue /seo-striking-distance>
```

## Worked example

> User: `/seo-progress-report`

1. Scope confirmed.
2. `list_crawls` → baseline = the crawl from before last week's fixes; latest =
   today's.
3. `compare_audits {baselineCrawlId, comparisonCrawlId}` → score 72→79, 11
   issues fixed (all 6 meta fixes + the redirect chain), 2 new (a broken link
   from a new page).
4. `get_project_trends` → up 3 crawls running.
5. GSC: the FAQ page clicks 600→760, "<brand> faq" pos 9→6.
6. Report credits the meta fix for the FAQ lift, flags the 2 new broken links as
   the next Ship-now, notes the new "how it works" page still isn't indexed
   (`get_url_inspection` → "Discovered, not indexed" → needs internal links →
   route to `/seo-internal-linking`).
