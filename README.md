# Digispot AI SEO Skills

Proven Claude Code **skills** that drive the **Digispot AI Spider** through its
[`digispot-seo`](https://digispot.ai) MCP server like a senior SEO consultant —
ROI-ranked, traffic-weighted, paste-ready fixes for **any website, any industry**.

Invoke a skill, and Claude runs a disciplined workflow against the live MCP:
resolve the project → find or run the right crawl → pull the data → rank by
`traffic-at-risk × severity × ease` → hand you exact fixes (titles, meta,
JSON-LD, redirect maps, internal-link targets) you can paste.

> **Get the app → [downloads.digispot.ai](https://downloads.digispot.ai/)**
> The Digispot AI Spider desktop app is the crawler and the MCP server these
> skills talk to. Download it first, then install the skills below.

## How it works

```
1. Download the Digispot AI Spider desktop app   → https://downloads.digispot.ai/
     The app crawls your site and exposes the `digispot-seo` MCP server,
     bound to your project via .mcp.json (--project).
2. Clone this repo and run ./install.sh
     Installs the six skills into Claude Code.
3. Invoke a skill in Claude Code — e.g. /seo-audit
     Claude drives the MCP and hands you a ranked, paste-ready fix plan.
```

Works the same on an e-commerce store, a SaaS site, a local-business site, a
publisher, or a docs site — nothing in the skills is tied to a vertical.

## Requirements

- The **Digispot AI Spider** desktop app
  ([downloads.digispot.ai](https://downloads.digispot.ai/)), which provides the
  `digispot-seo` MCP server bound to one project per repo via `--project`.
- Claude Code with that `digispot-seo` MCP configured in the repo's `.mcp.json`.
- For traffic-weighted ranking: Google Search Console / GA4 connected in
  Digispot. Without it the skills still work, ranking by severity × ease.

## Install

```bash
git clone <this-repo> digispot-ai-seo-skills
cd digispot-ai-seo-skills
./install.sh            # symlinks each skill into ~/.claude/skills + self-contains it
```

Re-run `./install.sh` any time to refresh. Restart Claude Code to load the skills.
Set `CLAUDE_SKILLS_DIR` to install somewhere other than `~/.claude/skills`.

## The skills

| Skill | Use it when you want to… |
|---|---|
| **`/seo-audit`** | Run a full, graded audit and get a ranked fix plan. The entry point. Covers technical, duplicates/canonical, schema/AEO, mobile parity, indexation as audit dimensions. |
| **`/seo-quick-wins`** | Find the highest-impact, lowest-effort fixes to ship *this week*. |
| **`/seo-striking-distance`** | Turn page-5–20 / position-8–20 rankings + high-traffic-at-risk pages into a rank-gain plan. The biggest growth lever. |
| **`/seo-content-strategy`** | Find content gaps, build a topic-cluster / topical-authority map, and kill keyword cannibalization. |
| **`/seo-internal-linking`** | Fix orphans, deep pages, and weak anchors — get an exact internal-link plan from the site graph. |
| **`/seo-progress-report`** | Compare crawls + GSC/GA4 trends to prove which fixes worked and what regressed. |

All six share one operating procedure: [`_shared/seo-mcp-foundations.md`](_shared/seo-mcp-foundations.md)
(copied into each skill at install time so it travels self-contained).

## Recommended engagement flow

```
1. /seo-audit            → graded baseline + ranked fix plan
2. /seo-quick-wins       → ship the cheap high-ROI fixes first
3. /seo-striking-distance→ chase the near-page-1 traffic
4. /seo-content-strategy → plan the content that builds authority
5. /seo-internal-linking → wire the new + orphaned pages in
   …ship fixes…
6. /seo-progress-report  → re-crawl, prove the gains, find regressions → loop
```

## Design notes

- **6 skills, not 12** — granular sub-areas (duplicates, schema, mobile,
  sitemap) overlap in the router; they live as *dimensions inside `/seo-audit`*.
- **Diagnose + propose by default** — skills never edit your site repo unless you
  say "apply".
- **Portable** — no hardcoded project or crawl IDs, no vertical assumptions;
  scope is resolved at runtime, so the same skills work across every site.

See [`docs/specs/`](docs/specs/) for the full design spec.

## License

Licensed under the [Apache License 2.0](LICENSE). "Digispot" and "Digispot AI
Spider" are trademarks of Digispot AI; the license grant does not include
trademark rights (see [`NOTICE`](NOTICE)).
