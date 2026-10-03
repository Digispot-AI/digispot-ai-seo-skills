# SEO MCP Foundations

The shared operating procedure for every `digispot-seo` skill. Read this first.
It encodes how an experienced SEO consultant runs an engagement against the
Digispot AI Spider — and, when connected, the Digispot Platform (cloud) — so the
skill that loaded it can act like one. Which servers are present and how to
route between them: §0.5. Platform credit rules: §0.6.

The `digispot-seo` (Spider) MCP is **locked to one project per repo** (bound via
`--project` in `.mcp.json`). Every Spider tool acts only on that project.
Sections §1–§8 are written against the Spider; in platform-only mode, follow
§0.5 and each skill's "Platform-only" notes instead.

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

## 0.5 Two servers, three modes

These skills run against up to two MCP servers. The names never collide, and
they complement rather than duplicate each other:

| | **Spider** (`digispot-seo`, local app) | **Platform** (cloud — every tool starts with `digispot_`) |
|---|---|---|
| Data | Local crawl DB + **live** Google OAuth | Cloud audit runs, live keyword/backlink market data, **cached** GSC/GA |
| Cost | Free reads; crawls use local quota | Free reads + **credit-metered** tools (real money — see §0.6) |
| Project | Bound per repo, injected — never pass it | Explicit UUID — resolve via `digispot_whoami` |

**Detect the mode once per session** (probe by tool availability — `get_mcp_scope`
= Spider present, `digispot_whoami` = Platform present), then operate in it:

- **Dual** — Spider leads; Platform upgrades slot in where this doc or the skill
  says so. Cloud numbers are always labeled separately (see the twins rule).
- **Spider-only** — exactly the classic behavior of this doc; silently skip
  anything Platform-flagged.
- **Platform-only** — cloud paths only. Call `digispot_whoami` first: it returns
  the tenant, plan, whether a subscription is active (the reason credit tools
  would otherwise refuse one at a time), and the reachable projects. Pick the
  project by matching the repo's site domain (compare hosts; ignore protocol /
  `www.` / trailing slash) and confirm the match in one line. Skills
  that need the local crawl degrade honestly: `/seo-internal-linking` requires
  the Spider — say so and stop; others follow their "Platform-only" notes.
  Page-level artifacts (screenshots, site graph, device comparison, `list_pages`
  filters) don't exist in the cloud — say so rather than improvising.

**When a server can't be used:**

- **No Digispot tools offered at all** — a server that is configured but down
  offers no tools, so you can't tell "not added" from "not reachable". Say both
  possibilities: Spider → is the app open? Platform → run `/mcp` and check the
  `digispot` server's status. Then stop.
- **A Platform call returns 401 / "Invalid … credentials"** — the `mcp_` key is
  wrong or revoked. Say so and link a new key:
  https://app.digispot.ai/settings/connected-apps/mcp. Retry at most once.

**Routing rules (which server answers which question):**

| Question lives in… | Server | Tools |
|---|---|---|
| Local crawl detail (pages, issues, links, devices, site graph) | Spider only | the §4 map |
| Who am I / what can this token reach | Platform | `digispot_whoami` (free) |
| Cloud audit history & diffs | Platform | `digispot_audit_runs`, `digispot_audit_overview`, `digispot_compare_audits`, `digispot_audit_deltas` |
| Letter-grade health snapshot | Platform | `digispot_project_health` (free) — same A+–F bands as the Spider's `get_project_health`, but see the caveat below |
| Score history across runs | Platform | `digispot_score_trend` (free) |
| Crawled-page inventory / worst-scoring pages | Platform | `digispot_audit_pages` (free) |
| Sitemap coverage | Platform | `digispot_sitemap_coverage` (free) |
| Screenshot of a crawled page | Platform | `digispot_page_screenshot` (free, 15-minute signed URL) |
| **Live keyword demand** (volume / CPC / difficulty / related) | Platform | `digispot_keyword_lookup`, `digispot_related_keywords` — the only live-market source; Spider's `get_keywords` is the *imported* universe |
| Backlink competitors / anchors | Platform | `digispot_backlinks_competitors`, `digispot_backlinks_anchors` (metered — §0.6) |
| Backlink history trend | Platform | `digispot_backlinks_trend` (free) — prefer over the credit-spending workflow |
| Field/lab performance of **any URL** — including a competitor's | Platform | `digispot_lookup_crux`, `digispot_lookup_pagespeed` (free); domain age: `digispot_lookup_site_age` |
| GSC / GA4 | **Spider first** (live OAuth, richer). Spider not connected → Platform's cached `digispot_gsc_analytics` / `digispot_ga_analytics` / `digispot_google_summary`, labeled "as of last daily sync" | |
| AI content draft | Spider's Page Writer workflow first; unlicensed / no model → Platform `digispot_content_generate` (§0.6) | |
| Cloud audit provisioning | Platform | `digispot_list_audit_configs`, `digispot_get_audit_config`, `digispot_create_audit_config`, `digispot_update_audit_config`, `digispot_run_audit`, `digispot_cancel_audit` |

`digispot_gsc_analytics` returns QUERY-dimension rows only. There is no
page-dimension option — the Platform never stores those rows for GSC, so don't
go looking for one.

**Grades are not comparable across the two servers.** `digispot_project_health`
uses the Spider's exact formula and bands, but a cloud audit only crawls
`crawlBudget` pages while the Spider crawls the site — so the issue load feeding
the grade is a sample. Never present a cloud grade as if it were the Spider's,
and never chart them on one line.

**HARD RULE — the twins are not the same data.** `compare_audits` (Spider) and
`digispot_compare_audits` (Platform) diff **different stores**: local crawls vs
cloud audit runs. A Spider `crawlId` means nothing to a Platform tool and vice
versa. Never mix IDs across servers, never merge the two into one timeline, and
label every reported number with its source (`crawl <date>` vs
`cloud audit <date>`).

**Session card — resolve once, reuse everywhere.** After scope resolution (and
crawl/run resolution), emit one line the rest of the session reuses:

```
[session] project: <name/domain> · mode: dual|spider-only|platform-only ·
          crawl: <date> (<id>) · platform project: <uuid or "—"> ·
          credits: <the metrics this session may spend, from digispot_usage_limits>
```

If a `[session]` card already exists in this conversation, **reuse it** — do not
re-probe servers or re-resolve scope/crawl. Re-resolve only if it's stale (new
crawl requested, project changed) and then emit an updated card.

**Handoff card — pass the shortlist to the next skill.** End every skill's
output with one line naming the natural next skill and what it should start from:

```
[handoff] from: /<this-skill> · next: /<next-skill> or — · chain: <chain name or —> ·
          pages: <≤10 urls> · queries: <≤10 "query" strings> · note: <one line or —>
```

- **Only URLs and query strings go in it** — never crawl IDs or cloud audit
  IDs; those live in the `[session]` card (twins rule above).
- **Receiving a handoff:** when the latest `[handoff]` names this skill as
  `next`, start from its pages/queries instead of re-discovering them. Still
  apply the freshness checks, and widen the search if the shortlist is thin.
  Ignore it if the user has since changed the subject.
- **Setting `chain:`** — only when the user's ask matched a multi-step plan in
  the `AGENTS.md` routing block. A single skill, named or routed, is `chain: —`.
- **Running a chain:** when `chain:` is set (the user asked for a multi-step
  plan — see the `AGENTS.md` routing block), give a one-line summary of this
  step and invoke `next` straight away, without asking the user to type it.
  Pause only for:
  - credit consent (§0.6), with real numbers;
  - a choice only the user can make (which competitor, which gap to write);
  - work the user has to ship first — `/seo-progress-report` needs fixes shipped
    and a newer crawl or cloud audit, so stop and say what will resume the chain.
- **No chain:** suggest `next` in one line and stop.
- **Platform-only:** if `next` is `/seo-internal-linking` (Spider only), skip
  that step, say why, and hand off to the step after it.

If this repo has no `AGENTS.md` routing block for these skills, offer once to
create it (a single file write) so future sessions get routing and mode
detection before any skill is invoked; continue either way.

---

## 0.6 Platform credits — the spend rules

The Platform meters real money out of **two credit pools**, plus a few
allowances that sit outside them. **Only the tools in the table below charge;
everything else is free.** Never ask consent for a free tool — consent fatigue kills the consent
that matters.

**The two pools are on unrelated scales. NEVER sum them, and never present a
combined "credits left" figure.**

| Pool | Feeds | Rough scale |
|---|---|---|
| **DATA** | keyword lookups, SERP, backlink intel, AI-mentions lookups | 1 credit ≈ one keyword lookup |
| **AI** | drafts, summaries, chat, images | 1 credit ≈ 1/10 of a page draft |

| Tool | Cost | Fine print |
|---|---|---|
| `digispot_keyword_lookup` | 1 DATA | Charged **even on cache hit** — repeats are never free |
| `digispot_related_keywords` | 1 DATA | Same — always charges |
| `digispot_backlinks_anchors` | 1 DATA | Only on a **fresh provider fetch that returns data**; 7-day cache hits and empty results are free |
| `digispot_backlinks_competitors` | 1 DATA | Same cache-aware rule |
| `digispot_mentions_lookup` | **Variable DATA** (typically ~1–24+) | Only on a real fetch; 24h cache hits are free. Read the live cost from `digispot_usage_limits` before quoting |
| `digispot_mentions_compare` | Same as `digispot_mentions_lookup` | Charged **once per call**, however many competitors |
| `digispot_mentions_timeseries_summary` | Same as `digispot_mentions_lookup` | 24h cache. `digispot_mentions_timeseries` (free) covers your own tracked window |
| `digispot_mentions_top_pages_refresh` | Same as `digispot_mentions_lookup` | 24h cache. `digispot_mentions_top_pages` (free) ranks from your own tracking history |
| `digispot_content_generate` | **12 AI** (2 planning + 10 draft) | **×3 on an advanced text model — a measured run cost 36.** A failed plan auto-restores the planning credits; don't panic-retry |
| `digispot_run_audit` | **1 SITE_AUDIT + crawlBudget × PAGE_AUDIT**, plus the config's add-ons | The crawl isn't pooled — read the config first. Add-ons, both on by default: **content opportunities** = 3 AI per topic cluster the run finds (×3 on an advanced model; a measured 50-page run found 6 clusters = 54 AI), **backlinks** = 2 DATA the first time the domain is fetched in a billing period |
| `digispot_create_project` | 1 project slot | Not pooled. Only when the user explicitly wants the site on the Platform |

Everything else — all audit/config/issue/insight reads, `digispot_backlinks_trend`,
`digispot_backlinks_overview`, `digispot_backlinks_referring_domains`, the other
`digispot_mentions_*` tools, CrUX/PageSpeed/WHOIS lookups,
cached GSC/GA, `digispot_content_generate_status` polling, config CRUD — is
**free**.

**Keep `digispot_audit_issues` small.** Always filter by `severity`, `category`
or `issueKey` and keep `limit` at 50 or less — page with `pageNumber` if you
need more. An unfiltered `limit: 200` returns ~200K characters and buries the
session.

**The spend protocol (extends "never silently spend"):**

1. `digispot_usage_limits` (free) → read `creditPools` for the pool that tool
   draws on, and `costPerCall` for what it costs. Never assume a cost: the tool
   reports the live weights, and they change. Zero remaining → relay the limit
   and the upgrade link (https://app.digispot.ai/settings/billing-subscription),
   don't retry, don't work around.
2. **Batched consent, priced from the pool.** One ask per batch with real
   numbers — *"validating 12 keywords = 12 DATA credits, you have 508 — go?"*
   — never 12 separate asks. For AI work, multiply: *"3 drafts = 36 AI credits
   (12 each), you have 3,010."*
3. **`digispot_run_audit` gets its own quote.** Read the config first
   (`digispot_get_audit_config`) and quote actual numbers, add-ons included:
   *"this run = 1 site audit + up to <crawlBudget> page audits (you have <n> and
   <m> left), plus 3 AI per topic cluster for content opportunities (9 on an
   advanced model; a 50-page run found 6–7 clusters) and 2 DATA for backlinks if
   not fetched this month (you have <ai> AI, <data> DATA) — go?"* The cluster
   count is only known after the crawl, so quote the rate and an example, not a
   total. Offer to switch an add-on off
   (`contentOpportunitiesEnabled` / `backlinksEnabled` = false) if the user only
   wants the audit. A generic "this costs credits" under-informs by up to 50×.
4. **`digispot_cancel_audit` is the refund valve** — free, and restores unused
   SITE_AUDIT/PAGE_AUDIT while a run is QUEUED/PICKED/RUNNING. Mention it when
   starting a run; use it if the user changes their mind.
5. **Plan gates are answers, not obstacles.** "Active subscription required",
   a used-up project slot or a FREE-plan lifetime AI-content cap is the
   session's answer — relay it once with the upgrade link
   (https://app.digispot.ai/settings/billing-subscription) and fall back to the
   free path (same discipline as the Spider tier-gate rule).

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
5. **Audited pages vs redirect observations (critical on consolidation-heavy
   sites).** A crawl's Page rows contain two kinds: real content AUDITS, and
   thin **redirect observations** (`isRedirect: true` + `constantPageRepeat:
   true`, status 3xx, `finalUrl` set). An observation is a chain record — the
   site 301-redirects that URL into a destination that was audited ONCE. Its
   score columns sit at 0 **as schema defaults, not verdicts**: never treat an
   observation as a low-scoring or thin page, never recommend content fixes on
   it, and never count it as a crawled PAGE. `Crawl.crawledPages` = audits
   only; `totalPages` = audits + failed + observations (processed URLs).
   `get_crawl_summary` reports "Pages Audited: N (of M processed)" when
   observations exist; `list_pages` labels observation rows
   `REDIRECT (not audited) → destination`; `get_page_report` on an observation
   returns the chain story with a pointer to the destination's audited row.
   When many URLs collapse into few destinations (e.g. a retired blog section
   301-consolidated into hub pages), the REAL findings are: stale sitemap
   (lists retired URLs), redirect chains, and possibly a project-URL host hop
   — not "N poor pages". `get_redirects` lists the per-URL chains.

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
| **Keyword universe** — opportunity lanes, topic map, raw table | `get_keywords` (`section: opportunities\|topics\|keywords`, `q`, `intent`) |
| One topic's pages + keywords by state (covered/improve/create) | `get_keywords` (`topic: "<clusterKey>"` — keys shown in `section: topics`) |
| Internal links to add, hubs, anchor profiles | `get_link_insights` (`section: suggestions\|hubs\|anchors`, `reason: orphan\|low-inbound\|deep`) |
| **Backlinks / off-page authority** (referring domains, follow vs nofollow, spam, domain rank) | `get_backlinks` (`section: summary\|domains\|all`, `limit`) |
| Broader content opportunity list | `get_content_opportunities`, `get_quick_wins` |

**Backlinks — read this before you interpret the numbers.** `get_backlinks` is a free,
project-scoped read of the stored profile (the domain is taken from the project — you never
pass a URL). Prefer it over the `Project Backlink Profile` workflow, which is slower and can
spend cloud credits. It cannot refresh: pulling fresh data from the cloud is a deliberate
human click in the app, never an agent action.

Three rules the data will punish you for ignoring:
- **`rank N/A` means UNRANKED/unknown, not "rank zero".** The provider sends 0 for "no rank
  known" — the tool renders it `N/A` precisely so you don't read it as worst-possible
  authority. Never rank, sort, or advise on `N/A` as if it were a low score.
- **All-nofollow domains pass ZERO equity.** The tool flags them. A domain with 25 links that
  is `ALL-NOFOLLOW` contributes nothing to rankings — treat it as zero authority for advice,
  and never present its link count as a win.
- **`—` means not measured, not zero.** And if `status` is not `ok`, the profile could not be
  fetched — say so; never report "0 backlinks" for a failed read.

**Keywords — imported market data mapped onto the site's topics.** `get_keywords` serves the
project's keyword universe (Google Keyword Planner CSV imports + Digispot cloud enrichment)
mapped onto the SAME topic clusters `get_content_opportunities` reports — use it to back
content decisions with demand evidence. Rules:
- **Import-first:** "No keywords are loaded" is a normal state, not an error — point the user
  to the app's Keywords page (import/enrich are deliberate human actions, never agent calls).
- **Tier-gated module:** a plan-gate reply is the answer for this session — relay it once,
  don't retry or work around it.
- **Banded volumes ("50K+") are floors**, from non-spending Planner accounts — never sum,
  average, or rank precisely on them.
- **Lanes** (`section: opportunities`): `improve` = pos 8–20 striking distance · `expand` =
  owned topic, no covering page · `new` = no matching topic on the site · `optimize` =
  covered but not ranking · `defend` = ranking ≤7. Rows are **page-target units** — variant
  keywords are folded into one row so you never brief two pages for the same target.
- **Drill-down** (`topic: "<clusterKey>"`): one topic's pages and its keywords grouped by
  covered / improve / create — the per-topic evidence for briefs and pillar decisions
  (`⚠ no pillar page` there is a structural gap worth fixing before writing spokes).

### Google (GSC / GA4 — need the integration connected)
| Need | Tool |
|---|---|
| **Four-layer verdict** (audit × search × GA4 behaviour), ranked | `get_google_opportunities` |
| High-traffic pages that also have issues | `get_high_traffic_at_risk` |
| Striking-distance queries (pos 8-20) | `get_gsc_import_top_queries { strikingDistance: true }` |
| Top pages by clicks/impressions | `get_gsc_import_top_pages` |
| GA4: audience, geography, channels, landing pages, engagement | `get_ga4_sections` |
| GSC headline KPIs (clicks/impr/CTR/position) | `get_google_metrics` |
| Live single-URL index status | `get_url_inspection` |
| Google core/spam/Discover updates + outages in a window | `get_google_search_incidents { from, to }` |
| Imports available | `list_gsc_imports` |

`get_ga4_sections` returns more than headline numbers — it carries **top
locations** (sessions by country), **traffic channels** (organic/direct/social/
paid mix), **top landing pages** (with bounce + engaged time), a **channel
trend** (is Organic growing?), and **native GA4 engagement rate**. Read it as a
consultant, not a reporter — see §5.1.

### Comparison (verifying fixes worked)
| Need | Tool |
|---|---|
| Two crawls side-by-side | `compare_audits { baselineCrawlId, comparisonCrawlId }` |
| What changed since baseline | `get_audit_deltas` |

If a Google-dependent tool returns "no GSC data", say so plainly and fall back
to crawl-only severity (you lose the traffic weight but can still rank by
severity × ease). Tell the user connecting GSC unlocks traffic-weighted ranking.

### Workflows (actions that PRODUCE, not just read)

Beyond the read tools above, the MCP exposes **workflows** — curated multi-step
recipes that *do* things a single read can't: rewrite a title with AI, draft a
blog post, compare your page against a competitor's, pull a backlink profile,
build a combined GSC+GA4 report. Three tools drive them:

| Need | Tool |
|---|---|
| See the recipes available for this project (+ their inputs) | `list_workflows` |
| Start a recipe | `run_workflow { workflowId, input }` → returns a `runId` |
| Get a run's status + result | `get_workflow_run { runId }` |

**The pattern (always these four steps):**

1. `list_workflows` → find the recipe by its **name** (e.g. "Competitor Page
   Comparison"), read its `id` and its declared inputs.
2. `run_workflow { workflowId: <that id>, input: { …the recipe's inputs } }`
   → returns `{ runId }`. **`projectId` is injected automatically — never pass it.**
   Inputs with a declared default (e.g. the page-draft recipe's `pageType`) may be
   omitted — the server fills them; pass a value only to override.
3. Poll `get_workflow_run { runId }` until it's `completed` (like
   `start_crawl` → `wait_for_crawl`). Tell the user "running <recipe>…" while you wait.
4. Read the result (the terminal step's deliverable) and fold it into your output.

**HARD RULE — never hardcode a recipe id.** Recipe ids are per-project and change
between installs; resolve the id from `list_workflows` by matching the recipe
**name**, every run. (Same discipline as never hardcoding a crawlId/projectId.)

**Recipe → job (match by name):**

| Recipe | Inputs you supply | Produces |
|---|---|---|
| AI SEO Page Review | `url` | AI section-by-section review (content/AEO/schema/CWV/indexability) |
| Title & Meta Refresh | `url` | AI-written title + meta, keyword-informed |
| Heading Structure Cleanup | `url` | A clean H1–H6 outline |
| Competitor Page Comparison | `urlA`, `urlB`, `fetchBacklinks?` | Point-by-point verdict + beat-them plan + backlink gap |
| AI - Page Writer (MDX) *(renamed in Spider 1.0.4; older installs may still show "AI Page Draft (MDX)" or "AI Blog Draft (MDX)" — match whichever `list_workflows` returns)* | `title`, `keyword`, `pageType?` (`blog`\|`service`, default `blog`), `intent?`, `location?`, `outlineHints?` (must-cover points, one per line) | An on-brand MDX draft — `blog` = 1500–2000-word article; `service` = 900–1300-word commercial service page grounded in the project's business identity with a booking/contact CTA |
| Project Backlink Profile | *(none)* | Referring domains, dofollow, authority |
| Striking-Distance Keywords → CSV | *(none)* | Position-≤20 queries, prioritized CSV |
| High-Traffic Pages at Risk → CSV | *(none)* | Traffic-weighted fix list, CSV |
| Quick Wins to Spreadsheet | `crawlId` | Prioritized quick-wins CSV |
| Traffic & Engagement Report (GSC+GA4) | *(none)* | Combined traffic + engagement report |

**Diagnose-vs-produce — the consent rule.** Reads are free to run. A workflow that
*generates or spends* (any AI draft/rewrite, or a recipe that uses cloud credits
like backlinks/keyword data) is an **action**: name what it will do and that it
consumes AI/cloud credits, then run it only on the user's go-ahead. This extends
the "diagnose + propose, never silently edit" principle to "never silently spend."
Workflows need a paid plan and an AI model connected (for the AI recipes); if a run
comes back not-licensed or no-model, say so and fall back to the read-only path.

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

## 5.1 Reading GA4 like a consultant (not a reporter)

`get_ga4_sections` gives audience, geography, channels, and landing behaviour.
A reporter says "your top country is the US." A consultant asks **"is that
traffic worth anything to THIS business?"** Traffic only counts if it can convert.
Always judge the numbers against **business context** — ask for it if you don't
have it: *what/where does this business serve, and who is the customer?*

**First, establish the business's target market.** Infer it from signals you
already have (the domain's ccTLD/`.in`, the site's address/phone, GSC's top
country, service-area pages, currency) and **confirm it with the user** — don't
assume. A dentist in Chennai, a national Indian SaaS, and a global dev tool have
completely different "good geography."

**Then apply the relevance lens to each GA4 section:**

- **Geography (`countries`).** Match the traffic's location to the serving area.
  A **Chennai** clinic whose sessions are 60% **US** does not have a traffic
  win — it has a **relevance problem**: those visitors can't become patients, so
  they inflate sessions while bounce is high and conversions are ~0. Say so
  plainly: *"US is your #1 country by sessions but you serve Chennai — that
  traffic won't convert. The real signal is your India/Tamil Nadu share; grow
  that."* Cross-check with **bounce/engaged-time on those geos** (in landing
  pages) — mismatched geo usually shows junk engagement. Flag likely causes:
  wrong-intent keywords, scraper/bot referral, an off-target backlink, or content
  that reads globally when the business is local. For a local business,
  **recommend local SEO** (Google Business Profile, city+service pages, local
  schema, NAP consistency) over chasing more national/global impressions.
  *Exception:* if the business is deliberately global (SaaS, publisher,
  e-commerce that ships worldwide), foreign traffic IS the market — don't
  misread reach as noise. The lens is relevance, not "local always wins."

- **Channels (`channels` + `channelTrend`).** Don't just list the mix — read
  the **health** of it. Heavy **Direct** can mean brand strength *or* untagged
  campaigns/bad attribution. Thin **Organic Search** on a site that's spent on
  SEO is an underperformance flag. Rising **Organic** in `channelTrend` is the
  single best proof SEO is working — lead with it in a progress report. Near-zero
  Organic while Paid carries the site = fragile, one budget cut from silence.

- **Landing pages (`landing`).** High **sessions + high bounce + low engaged
  time** = attracting the wrong visitor or a poor match to intent (fix the page
  or the query it ranks for, don't celebrate the sessions). Low sessions + strong
  engagement = a page that deserves more visibility (internal links, refresh,
  promote). This is where GA4 behaviour tells you which GSC rankings are
  *actually* valuable.

- **Engagement rate.** Prefer the **native GA4** rate when present (the tool flags
  it); the 1−bounce estimate is a fallback. A high engagement rate on low-relevance
  geo traffic is contradictory — trust the geo/relevance read over a flattering
  average.

**Explain shifts before alarming the user.** If clicks/sessions dipped in a
window, call `get_google_search_incidents` for that window first: a dip that
lines up with a Google **core/spam update** is likely Google-side (algorithm
re-rank), not a site regression — say which it is instead of prescribing fixes
for a problem the site doesn't have. (The Spider overlays these on its charts;
your written analysis should reach the same conclusion.)

**Bottom line:** never report a GA4 number without its "so what for this
business." Sessions, top country, and channel mix are inputs — the deliverable
is *whether that traffic can convert and what to do about it.*

**Shortcut — `get_google_opportunities` already fuses all four layers per URL.**
It ranks pages by audit × search × GA4 behaviour and emits the verdict for you:
`ranks-but-bounces` (real sessions but high bounce → fix the PAGE, not the
ranking), `hidden-gem` (strong engagement but under-shown → grow visibility),
plus a site traffic-geography note for the relevance lens. Lead with this tool
for "what should I fix next" — then use `get_ga4_sections` when you need the
fuller geography/channel/landing detail behind it.

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
