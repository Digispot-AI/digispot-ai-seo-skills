# Digispot AI SEO Skills

Proven Claude Code **skills** that drive [Digispot AI](https://digispot.ai)'s MCP
servers like a senior SEO consultant — ROI-ranked, traffic-weighted, paste-ready
fixes for **any website, any industry**.

Invoke a skill, and Claude runs a disciplined workflow against the live MCP:
detect what's connected → resolve the project → find or run the right audit →
pull the data → rank by `traffic-at-risk × severity × ease` → hand you exact
fixes (titles, meta, JSON-LD, redirect maps, internal-link targets) you can paste.

The skills speak to **two** Digispot MCP servers and adapt to whichever you have:
the **Spider** desktop app (deep local crawls, live GSC/GA4, site graph,
workflows) and the **Platform** cloud API (cloud audit history, live keyword
volumes, backlink intelligence, CrUX/PageSpeed on any URL, AI drafts). Either
alone works; together is best.

> **Get the app → [downloads.digispot.ai](https://downloads.digispot.ai/)** ·
> **or a Platform token →** app.digispot.ai/settings/connected-apps/mcp

## How it works

```
1. Connect at least one Digispot MCP server
     Spider   → download the desktop app; it crawls your site and exposes the
                `digispot-seo` MCP, bound to your project via .mcp.json (--project)
     Platform → add the cloud MCP with an `mcp_` token from app.digispot.ai
2. Install the skills — one line, no clone (see Install below)
     curl -fsSL https://raw.githubusercontent.com/digispot-ai/digispot-ai-seo-skills/main/install.sh | bash
3. (Recommended) ~/.digispot/seo-skills/install.sh --project <your-site-repo>
     Drops an AGENTS.md routing block into the site repo so any agent session
     there routes SEO asks to the right skill and detects your setup once.
4. Ask in plain English — e.g. "fix my SEO" — or invoke a skill directly
     Claude picks the skill (or a chain of them), drives the MCP and hands you
     a ranked, paste-ready fix plan.
```

Works the same on an e-commerce store, a SaaS site, a local-business site, a
publisher, or a docs site — nothing in the skills is tied to a vertical.

## The two servers

Mode is detected once per session — see
[`_shared/seo-mcp-foundations.md`](_shared/seo-mcp-foundations.md) §0.5:

| | Spider (desktop app) | Platform (cloud, `digispot_*` tools) |
|---|---|---|
| Brings | Deep local crawls, live GSC/GA4, site graph, device parity, workflows | Cloud audit history, live keyword volumes, backlink intel, CrUX/PageSpeed on any URL, AI drafts |
| Cost | Free reads | Free reads + a few **credit-metered** tools |
| Alone? | ✅ Full classic experience | ✅ 7 of 8 skills run cloud-only; `/seo-internal-linking` needs the Spider |

**Three modes:** *dual* (Spider leads, Platform upgrades slot in), *spider-only*,
*platform-only*. Skills degrade honestly — when a capability doesn't exist on the
connected server, they say so rather than improvising a substitute.

**Never mixed:** a Spider crawl and a Platform cloud audit are different data
stores with different IDs. Skills label every number with its source and never
merge them into one timeline.

## Credits — you are always asked first

Platform tools are mostly free reads, but the ones below spend real credits,
drawn from two separate pools — **DATA** (keyword, SERP, backlink and AI-mentions
lookups) and **AI** (drafts, summaries, images):

| Tool | Cost |
|---|---|
| `digispot_keyword_lookup`, `digispot_related_keywords` | 1 DATA each — charged even on a cache hit |
| `digispot_backlinks_anchors`, `digispot_backlinks_competitors` | 1 DATA, only on a fresh fetch; cached reads are free |
| `digispot_mentions_lookup`, `digispot_mentions_compare`, `digispot_mentions_timeseries_summary`, `digispot_mentions_top_pages_refresh` | Variable DATA, only on a fresh fetch; 24h cache hits are free |
| `digispot_content_generate` | 12 AI (×3 on an advanced model) |
| `digispot_run_audit` | 1 site audit + crawlBudget × page audits (not pooled) |
| `digispot_create_project` | 1 project slot (not pooled) |

Before any of them, a skill will:

1. Check the relevant pool's balance (`digispot_usage_limits`, free).
2. Ask once **with real numbers** — *"validating 12 keywords = 12 DATA credits,
   you have 508 — go?"* — batched, never one prompt per call.
3. Quote variable costs precisely: a cloud audit is `1 site + crawlBudget × page`,
   read from your actual config before asking.

Free tools never prompt. A running cloud audit can be cancelled for a refund of
unused credits. Full rules: [`_shared/seo-mcp-foundations.md`](_shared/seo-mcp-foundations.md) §0.6.

## Requirements

- **At least one of:**
  - The **Digispot AI Spider** desktop app
    ([downloads.digispot.ai](https://downloads.digispot.ai/)) — the
    `digispot-seo` MCP server, bound to one project per repo via `--project`
    in `.mcp.json`.
  - The **Digispot Platform** MCP — an `mcp_` token from
    app.digispot.ai/settings/connected-apps/mcp, configured as a second MCP server.
- Claude Code with the server(s) in the repo's `.mcp.json`.
- For traffic-weighted ranking: Google Search Console / GA4 connected in
  Digispot. Without it the skills still work, ranking by severity × ease.

## Install

No clone required:

```bash
curl -fsSL https://raw.githubusercontent.com/digispot-ai/digispot-ai-seo-skills/main/install.sh | bash
```

That downloads a source snapshot to `~/.digispot/seo-skills` and installs the
skills as real folders in `~/.claude/skills` — self-contained, nothing to keep
around. Re-run the same line any time to update.

Then wire up each site repo (one line per repo, safe to re-run):

```bash
~/.digispot/seo-skills/install.sh --project ~/code/my-site
```

<details>
<summary>Working on the skills themselves? Install from a clone instead.</summary>

```bash
git clone https://github.com/digispot-ai/digispot-ai-seo-skills
cd digispot-ai-seo-skills
./install.sh                            # symlinks each skill back into the clone
./install.sh --project ~/code/my-site
```

Clone mode **symlinks** so your edits are live — keep the clone where it is.
Piped mode **copies**, so there's nothing to break.
</details>

Both forms are idempotent; `--project` only rewrites its own marked block, so
your existing `AGENTS.md` content is kept. Restart Claude Code to load the
skills. `CLAUDE_SKILLS_DIR` overrides the install target and
`DIGISPOT_SKILLS_HOME` the snapshot location. Commit the generated `AGENTS.md`
to share routing with your team.

## The skills

| Skill | Use it when you want to… |
|---|---|
| **`/seo-audit`** | Run a full, graded audit and get a ranked fix plan. The entry point. Covers technical, duplicates/canonical, schema/AEO, mobile parity, indexation as audit dimensions. |
| **`/seo-quick-wins`** | Find the highest-impact, lowest-effort fixes to ship *this week*. |
| **`/seo-striking-distance`** | Turn page-5–20 / position-8–20 rankings + high-traffic-at-risk pages into a rank-gain plan. The biggest growth lever. |
| **`/seo-content-strategy`** | Find content gaps, build a topic-cluster / topical-authority map, and kill keyword cannibalization. Validates demand with live keyword volumes when the Platform is connected. |
| **`/seo-create-content`** | Turn a chosen gap or keyword into a publish-ready page draft with an on-brand cover image. Use when the plan exists and it's time to *create*. |
| **`/seo-internal-linking`** | Fix orphans, deep pages, and weak anchors — get an exact internal-link plan from the site graph. *(Spider required.)* |
| **`/seo-competitor`** | Compare your page head-to-head against a competitor's ranking page — point-by-point gaps + a prioritized plan to beat them, including the backlink gap and free field/lab speed data on *their* URL. |
| **`/seo-progress-report`** | Compare audits + GSC/GA4 trends to prove which fixes worked and what regressed. |

All eight share one operating procedure: [`_shared/seo-mcp-foundations.md`](_shared/seo-mcp-foundations.md)
(copied into each skill at install time so it travels self-contained). Several skills
can also **run workflows** — curated recipes that *produce* things (AI title/meta and blog
drafts, a competitor comparison, a backlink profile, a combined GSC+GA4 report) — not just
read audit data. These are actions: a skill names what a workflow will do (and that it uses
AI / cloud credits) and runs it only on your go-ahead. With the Platform connected, the
cloud equivalents (AI content generation, keyword research, backlink intelligence) are
available too — same consent discipline.

## Recommended engagement flow

```
1. /seo-audit            → graded baseline + ranked fix plan
2. /seo-quick-wins       → ship the cheap high-ROI fixes first
3. /seo-striking-distance→ chase the near-page-1 traffic
4. /seo-competitor       → when a rival outranks a page, see why + how to beat them
5. /seo-content-strategy → plan the content that builds authority
6. /seo-create-content   → draft the top-priority page from that plan
7. /seo-internal-linking → wire the new + orphaned pages in
   …ship fixes…
8. /seo-progress-report  → re-audit, prove the gains, find regressions → loop
```

Running `./install.sh --project <site-repo>` also drops an **`AGENTS.md` routing
block** into the repo, so a plain-English ask ("traffic dropped, help") routes to
the right skill without you remembering the slash command — and the session
detects which servers are connected once, up front. Commit it and your whole
team gets the same routing.

Multi-step asks run as a **chain**, with no slash commands: "fix my SEO" runs
`/seo-audit` → `/seo-quick-wins`, then `/seo-progress-report` once your fixes
ship. Each skill ends with a `[handoff]` line, so the next one starts from the
pages and queries the last one found. A chain pauses only to ask before spending
credits, for a choice only you can make, or while you ship fixes.

## Design notes

- **8 focused skills, not 20** — granular sub-areas (duplicates, schema, mobile,
  sitemap) overlap in the router, so they live as *dimensions inside `/seo-audit`*.
  Competitor comparison earns its own skill because it takes a different input
  (a rival URL) and produces a different deliverable (a beat-them plan).
- **Diagnose + propose by default** — skills never edit your site repo unless you
  say "apply". Anything that *generates or spends* (AI drafts, credit-metered
  lookups) is named as an action and runs only on your go-ahead — never silently.
- **Never silently spend** — credit costs are checked and quoted with real
  numbers before the ask, batched into one consent, never one prompt per call.
- **Capability-probed, not assumed** — one skill set adapts to whichever servers
  are connected; no duplicate "cloud" variants to choose between. When something
  genuinely isn't available, the skill says so instead of faking it.
- **Portable** — no hardcoded project, crawl, or recipe IDs, no vertical
  assumptions; everything is resolved at runtime, so the same skills work across
  every site.

**What these skills don't cover yet**: domain-level competitor tracking and
historical rank tracking. Standalone keyword-volume research is
covered when the Platform is connected (`digispot_keyword_lookup` — credit-
metered, always consented); internal-link planning still requires the Spider's
local site graph.

## License

Licensed under the [Apache License 2.0](LICENSE). "Digispot" and "Digispot AI
Spider" are trademarks of Digispot AI; the license grant does not include
trademark rights (see [`NOTICE`](NOTICE)).
