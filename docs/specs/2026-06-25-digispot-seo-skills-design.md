# Digispot AI SEO Skills — Design Spec

**Date:** 2026-06-25
**Status:** Approved → implementing

## Goal

A portable, shareable toolkit of Claude Code **Skills** that let any SEO expert
drive the `digispot-seo` MCP server to solve real SEO problems on **any** site
bound to a Digispot project. The skills are proven prompt-template playbooks —
the expert invokes one, and Claude executes a disciplined, ROI-ranked workflow
against the live MCP tools.

Built as a standalone package (source of truth) and **installed globally** into
`~/.claude/skills/` so every client repo can use them.

## Principles (how SEO experts actually operate)

- **ROI first.** Everything is ranked by `traffic-at-risk × severity × ease`,
  never by crawl order. A consultant fixes the page that bleeds the most traffic
  for the least effort first.
- **Diagnose + propose, never silently edit.** Default output is a paste-ready
  fix plan (exact titles, meta, JSON-LD, redirect maps, link source→target).
  The skill edits the site repo only when the user says "apply".
- **Cite everything.** Every finding ties to URL + traffic/impressions +
  severity + the exact fix. No vague advice.
- **Spend quota wisely.** Free tools (`get_mcp_scope`, `list_issue_definitions`)
  are noted; crawls cost — reuse the latest completed crawl unless stale.
- **Portable.** Never hardcode project or crawlId. Resolve scope at runtime.

## Architecture

```
digispot-ai-seo-skills/
├── README.md                       # what/why, install, skill map, engagement recipes
├── install.sh                      # symlink each skill into ~/.claude/skills + copy foundation in
├── _shared/
│   └── seo-mcp-foundations.md      # SOURCE OF TRUTH — operating procedure all skills inherit
└── skills/
    ├── seo-audit/SKILL.md          # entry point: crawl → graded report → ranked fix plan
    ├── seo-quick-wins/SKILL.md     # high-impact / low-effort triage — "ship this week"
    ├── seo-striking-distance/SKILL.md  # GSC pos 5-20 + traffic-at-risk → rank-gain plan
    ├── seo-content-strategy/SKILL.md   # content gaps + topical authority + cannibalization
    ├── seo-internal-linking/SKILL.md   # site graph → orphans/depth/anchors → link plan
    └── seo-progress-report/SKILL.md    # audit-delta + GSC/GA4 trends → did the fixes work?
```

### Consolidation rationale (6, not 12)

Skills route by `description`. Twelve granular SEO skills overlap heavily
(duplicates / canonical / indexation / sitemap / technical all sound alike to
the router and the user). Six skills mapped to how an engagement is actually
structured give clean separation. Technical sub-areas — duplicates/canonical,
schema/AEO, mobile parity, sitemap/robots/indexation — become **referenced
audit dimensions inside `seo-audit`**, not top-level skills.

### The foundation (`seo-mcp-foundations.md`)

Every skill reads this first. It defines:

1. **Scope resolution** — `get_mcp_scope` confirms the locked project; never
   hardcode project/crawlId.
2. **Crawl freshness** — `list_crawls` → newest *completed* crawl; if none or
   older than the staleness window, `start_crawl` + `wait_for_crawl`.
3. **Tool-selection map** — every digispot-seo tool → when to reach for it.
4. **Prioritization formula** — the ROI ranking model + which tools supply each
   factor (`get_issues_with_traffic`, `get_high_traffic_at_risk`,
   `get_google_opportunities` carry the traffic signal).
5. **Output conventions** — finding schema + paste-ready fix formats.
6. **Parallelism** — fan per-page / per-dimension reads out to subagents.

### Install behavior

`install.sh` is idempotent. For each skill dir it:
- symlinks `skills/<name>/` → `~/.claude/skills/<name>/`, **and**
- copies `_shared/seo-mcp-foundations.md` into `skills/<name>/FOUNDATIONS.md`
  so the installed skill is self-contained (no dangling `../_shared` link).

`FOUNDATIONS.md` copies are git-ignored in the package; `_shared/` stays the
single source of truth.

## Skill shape (every SKILL.md)

```
---
name: seo-...
description: <router-distinct one-liner — when to use this vs the others>
trigger: /seo-...
---
# /seo-...
## When to use   (and when to reach for a sibling skill instead)
## Procedure     (numbered; step 1 always: read FOUNDATIONS.md, resolve scope+crawl)
## Output template
## Worked example (real tool calls with real params)
```

## Out of scope

- Auto-editing the site repo (deferred; "apply" path is a future skill).
- A 13th skill per technical sub-area (folded into `seo-audit`).
- Agent/subagent definition files (skills dispatch parallel Tasks inline).

## Success criteria

- 6 skills install cleanly into `~/.claude/skills/`; each is self-contained.
- Every skill resolves scope/crawl at runtime — no hardcoded IDs.
- Every workflow's output is ROI-ranked and paste-ready.
- README lets a new SEO expert install and run the first audit in <5 min.
