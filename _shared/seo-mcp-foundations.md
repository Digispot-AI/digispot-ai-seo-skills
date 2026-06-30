# SEO MCP Foundations

The shared operating procedure for every `digispot-seo` skill. Read this first.
It encodes how an experienced SEO consultant runs an engagement against the
Digispot AI Spider, so the skill that loaded it can act like one.

The `digispot-seo` MCP is **locked to one project per repo** (bound via
`--project` in `.mcp.json`). Every tool acts only on that project.

---

## 0. Operating principles

1. **ROI first.** Rank every finding by `traffic-at-risk × severity × ease`.
   Never present findings in crawl order. The first thing you ship is the page
   that bleeds the most traffic for the least effort.
2. **Diagnose + propose, never silently edit.** Default output is a
   *paste-ready* fix plan. Touch the site repo only if the user says "apply".
3. **Cite everything.** Each finding = URL + traffic/impressions + severity +
   the exact fix. No vague "improve your titles" advice.
4. **Spend quota wisely.** `get_mcp_scope`, `get_mcp_status`,
   `list_issue_definitions`, `get_issue_definition` are **free**. Crawls cost.
   Reuse the latest completed crawl unless it's stale.
5. **Portable.** Never hardcode a project ID or crawlId. Resolve both at
   runtime, every run.

---

## 1. Scope resolution (always step 1)

```
get_mcp_scope            → confirm which project this repo is bound to
```

State the project name back to the user in one line. If it's clearly the wrong
project for what they asked, stop and tell them to open the correct repo (each
repo's `.mcp.json` binds one project).

---

## 2. Crawl freshness (always step 2)

A "crawl" is one audit snapshot. Most tools need a `crawlId`.

```
list_crawls { status: "completed", limit: 5 }   → newest completed crawl
```

Decide freshness:

- **Fresh enough** (crawl ≤ 7 days old, or the user didn't ask for new data):
  use that `crawlId`. Tell the user the crawl date you're using.
- **Stale / none / user asked for fresh data:**
  ```
  start_crawl { }                 → returns device group + crawl IDs
  wait_for_crawl { crawlId }      → blocks until done (raise timeoutSec for big sites)
  ```
  `start_crawl` device modes (desktop/mobile/tablet) come from project config.
  For Core Web Vitals / JS-rendered sites add `useBrowserFetcher: true`.
  For full indexation coverage add `wideSitemapDiscovery: true`.

Never invent a crawlId. If `list_crawls` is empty and the user won't authorize a
crawl, stop and say so.

---

## 3. The three levels of SEO data (read before picking tools)

Digispot data lives at **three levels**. Knowing which level a question lives at
tells you which tool to call and how many times — and stops you wasting crawl
quota fanning out a call that returns the same answer every time.

| Level | Scope | What lives here | How to read it |
|---|---|---|---|
| **Site-wide** | Shared by every device; computed **once per group** on the lead device | robots.txt, sitemap.xml, SSL, llms.txt, the link graph, sitemap coverage. The **Site Score** = `SSL 30% + Robots 25% + Sitemap 30% + llms 15%`. | Call **once** with **any one** device's `crawlId`. The answer is group-shared — never loop devices for these. |
| **Device-specific** | Per device mode (mobile / tablet / desktop) | Page scores, the 9 category scores, Core Web Vitals, mobile usability, content parity. The **Device Audit Score** = mean of that device's page scores. | **Compare across** the device crawls in the group. |
| **Page-wise** | Per page, **per device** | One URL's 9 category scores, its sections (metadata/headings/content/…), and its issues. The **Page Score** is indexability-aware. | Drill **one** URL on **one chosen device's** `crawlId` + `pageId`. |

**The rule:** site = read once (any crawlId); device = compare across device
crawls; page = drill one URL on one device.

- "Is my sitemap/robots/SSL/llms healthy?" → **site** (one call).
- "Is mobile worse than desktop?" → **device** (`get_device_comparison`, then
  `get_device_url_gaps`).
- "What's wrong with /pricing?" → **page** (pick the device crawl → `list_pages`
  to get `pageId` → `get_page_issues` / `get_page_section`).
- "What's broadly broken / the fix-list?" → **device-crawl aggregate**
  (`get_crawl_summary`, `list_issues`, `get_critical_issues`).

**Wiring gotchas — these bite if you don't know them:**

1. **Site-level tools take a device `crawlId` but return group-shared data**
   (`get_site_analysis`, `get_sitemap_coverage`, `get_robots_blocked_urls`,
   `get_site_graph`). Call once; do **not** run them per device.
2. **`get_device_url_gaps` takes `deviceGroup`, not `crawlId`** — it's the one
   exception. Get the `deviceGroup` from `get_device_comparison`'s response or
   from `start_crawl`.
3. **Issue tools are per-device-crawl** (`list_issues`, `get_critical_issues`,
   `get_issues_with_traffic`). To compare issues across devices, call once per
   device `crawlId`.
4. **The `list_pages` / `get_page_category_detail` category enum is a display
   projection, not the score model.** `category:"technical"` and
   `category:"metadata"` both surface `indexabilityScore` — there is no separate
   `technicalScore`. The canonical per-page number is `pageAuditScore`; the
   per-device average is `avgPageAuditScore`.

---

## 4. Tool-selection map

Reach for the **most specific** tool first; fall back to the broad ones.

### Orientation (free / cheap, no crawlId)
| Need | Tool |
|---|---|
| Confirm project binding | `get_mcp_scope` |
| Letter-grade health snapshot | `get_project_health` |
| Score trend across crawls | `get_project_trends` |
| The full issue rubric (what Digispot can detect) | `list_issue_definitions` (→ `detail:true` per category) |
| One issue's what/why/fix | `get_issue_definition` |
| Crawl history & status | `list_crawls`, `get_crawl_status_summary`, `list_active_crawls` |

### Per-crawl audit
| Need | Tool |
|---|---|
| Site-wide scores + CWV distribution | `get_crawl_summary` |
| **Size-up: page counts per status bucket** | `get_crawl_status_summary` |
| **Filter/target pages by any attribute** | `list_pages` (20+ filters — see below) |
| **Fix-first, traffic-weighted** issue ranking | `get_issues_with_traffic` *(needs GSC)* |
| Critical/high issues by urgency | `get_critical_issues` |
| High-ROI low-effort wins | `get_quick_wins` |
| All issues of one type, page list | `list_issues`, `get_issue_pages` |
| Everything wrong on one page | `get_page_issues` |
| robots.txt / sitemap.xml / SSL / **llms.txt** compliance | `get_site_analysis { type }` |
| Full single-page report | `get_page_report`, `get_page_section`, `get_page_category_detail` |
| Visual proof of a page | `get_page_screenshot` |
| Duplicate titles/meta/content | `get_duplicates` |
| Redirects per URL (status, `finalUrl`, chain length, loop flag) | `get_redirects` |
| Broken internal/external links | `get_broken_links` |
| Robots-blocked URLs | `get_robots_blocked_urls` |
| Sitemap coverage gaps | `get_sitemap_coverage` |
| Site structure / orphans / depth | `get_site_graph` |
| Device parity (mobile vs desktop) | `get_device_comparison`, `get_device_url_gaps` |

**Size-up → filter → drill (the efficient per-page path).** Before fanning out
`get_page_issues` page-by-page, narrow the set first:

1. `get_crawl_status_summary` → page counts per bucket (title/meta/h1/canonical/
   CWV/indexability). Tells you *which* problem is biggest before you spend calls.
2. `list_pages` → pull exactly the pages in the worst bucket. It takes 20+
   filters — `titleStatus`, `metaDescStatus`, `h1Status`, `cwvStatus`,
   `indexabilityStatus`, `isThinContent`, `isSoft404`, `orphanPage`,
   `hasMissingTitle/MetaDesc/H1`, `minScore`/`maxScore`, `minIssueCount` — plus
   `sortBy` (`lcp`, `cls`, `inp`, `linkDepth`, `inboundLinkCount`, `pageWeight`,
   `issueCount`, …) and a `category` projection. Example: every thin, indexable
   page sorted by inbound links — `list_pages { isThinContent:true,
   indexabilityStatus:"indexable", sortBy:"inboundLinkCount" }`.
3. Only then fan out `get_page_issues` / `get_page_category_detail` over that
   targeted list (§7). This turns a blind page-by-page sweep into a precise one.

**Site-level checks** (one call each, no page loop): `get_site_analysis { type }`
with `type` = `robots` (robots.txt), `sitemap` (sitemap.xml), `ssl` (cert), or
`llms` (**llms.txt** — the LLM/AEO discoverability file). Run the `llms` check in
any audit that claims AEO coverage.

### Content & links (latest run)
| Need | Tool |
|---|---|
| New pages to write, topic clusters, cannibalization | `get_content_opportunities` (`section: gaps\|clusters\|cannibalization`) |
| Internal links to add, hubs, anchor profiles | `get_link_insights` (`section: suggestions\|hubs\|anchors`, `reason: orphan\|low-inbound\|deep`) |
| Broader content opportunity list | `get_content_opportunities`, `get_quick_wins` |

### Google (GSC / GA4 — need the integration connected)
| Need | Tool |
|---|---|
| GSC × audit, ranked by combined opportunity | `get_google_opportunities` |
| High-traffic pages that also have issues | `get_high_traffic_at_risk` |
| Striking-distance queries (pos 8-20) | `get_gsc_import_top_queries { strikingDistance: true }` |
| Top pages by clicks/impressions | `get_gsc_import_top_pages` |
| GA4 section/traffic data | `get_ga4_sections`, `get_google_metrics` |
| Live single-URL index status | `get_url_inspection` |
| Imports available | `list_gsc_imports` |

### Comparison (verifying fixes worked)
| Need | Tool |
|---|---|
| Two crawls side-by-side | `compare_audits { baselineCrawlId, comparisonCrawlId }` |
| What changed since baseline | `get_audit_deltas` |

If a Google-dependent tool returns "no GSC data", say so plainly and fall back
to crawl-only severity (you lose the traffic weight but can still rank by
severity × ease). Tell the user connecting GSC unlocks traffic-weighted ranking.

---

## 5. Prioritization formula

```
priority_score  =  traffic_at_risk  ×  severity_weight  ×  ease
```

- **traffic_at_risk** — GSC clicks/impressions on the affected URL(s).
  Sources: `get_issues_with_traffic`, `get_high_traffic_at_risk`,
  `get_google_opportunities`. No GSC → treat as 1 and note the blind spot.
- **severity_weight** — critical=4, high=3, medium=2, low=1
  (from the issue's severity in `list_issue_definitions` / the issue rows).
- **ease** — inverse effort: a title/meta/canonical/redirect edit = high ease (3);
  template/schema change = medium (2); new content / re-architecture = low (1).

Always present findings **sorted by `priority_score` descending**, grouped into
**Ship now (this week) / Plan (this sprint) / Backlog**.

When GSC is connected, `get_issues_with_traffic` and `get_google_opportunities`
already bake most of this in — lead with them and you've done 80% of the ranking.

---

## 6. Output conventions

Every finding follows this schema:

```
### <Issue title>  ·  <severity>  ·  ~<N> clicks/mo at risk  ·  ease: high|med|low
**Where:** <url(s)>  (N pages affected)
**Why it matters:** <one line — the ranking/traffic consequence>
**Fix:**
<paste-ready remediation — see formats below>
```

Paste-ready fix formats:

- **Title tag** — give the exact replacement string, ≤60 chars, note char count.
- **Meta description** — exact string, ≤155 chars, note char count.
- **Canonical** — the exact `<link rel="canonical" href="…">` and which URL wins.
- **Redirect** — a `from → to (301)` map, ready for the host's redirect config.
- **Schema/AEO** — a complete, valid JSON-LD `<script type="application/ld+json">`
  block, filled with the page's real data (not placeholders). **Promise a Google
  *rich result* only for types Google still renders** — Product, Review/
  AggregateRating, Article, Recipe, Video, Organization, LocalBusiness, Event,
  Breadcrumb. **FAQPage / HowTo no longer earn a rich result** (FAQ rich results
  deprecated, HowTo removed) — but they remain valuable for **AEO/LLM
  extraction** (answer engines parse FAQ markup to pull direct answers), so still
  recommend them as AEO/content wins, just don't sell them as a rich-result gain.
- **Internal link** — `source URL → target URL`, exact anchor text, and where on
  the source page it should sit.
- **Content gap** — title, search intent, target keywords, H2 outline, and which
  existing pages it should interlink with.

Close every report with a **"Verify after shipping"** line: re-crawl, then run
`/seo-progress-report` (or `compare_audits`) to confirm the issue cleared.

---

## 7. Parallelism

When a workflow needs per-page detail across many pages (e.g. pulling
`get_page_issues` for the top 20 at-risk pages), **dispatch parallel subagents**
(one per page or per batch) rather than reading them serially. Each subagent
returns a compact structured finding; you synthesize and rank. Keep the
ranking/synthesis in the main thread so the ROI model stays consistent.

---

## 8. Failure handling

- Tool says wrong/locked project → stop, tell the user to open the right repo.
- Empty `list_crawls` and no crawl authorized → stop, explain.
- Google tool with no GSC → degrade to severity×ease, note the lost traffic signal.
- Crawl still running (`list_active_crawls`) → offer to `wait_for_crawl` or read
  the previous completed crawl meanwhile.
- Crawl failed / suspiciously thin / weird coverage → `get_crawl_logs { crawlId,
  limit }` to see what the crawler hit (blocked paths, timeouts, redirects, the
  per-entry `type`) before re-running. Filter by entry type yourself in the
  result — the tool returns all log types and takes only `crawlId` + `limit`.
