# Skills Adoption Plan — Workflow MCP Tools (Phase 3)

**Date:** 2026-07-08
**Status:** Plan for review — no skill edits yet
**Prereq (DONE):** Phase 1 shipped `list_workflows` / `run_workflow` / `get_workflow_run` to the `digispot-seo` MCP (56 tools), verified live.

---

## 1. Why now

The 6 skills are **diagnose-and-recommend** — they read audit/GSC data and hand back paste-ready
fixes. Until now they *couldn't* do competitor comparison, off-page/backlinks, keyword volume,
or content generation, because those capabilities weren't on the MCP. Phase 1 changed that: the
workflow engine (10 curated recipes) is now reachable over MCP. This plan wires those recipes
into the skills so the suite reflects a full SEO practice.

**None of the 6 skills reference the workflow tools today** (verified). This is the gap.

## 2. The new capability surface (verified live)

Three tools, start-then-poll:
- `list_workflows` → the 10 recipes + input specs (discover at runtime).
- `run_workflow { workflowId, input }` → `{ runId }`.
- `get_workflow_run { runId }` → status, then the curated deliverable.

The 10 recipes and their real inputs (`projectId` is injected by the MCP — skills never pass it):

| Recipe (match by NAME) | Inputs the skill must supply | Deliverable |
|---|---|---|
| AI SEO Page Review | `url` | AI section-by-section review (AEO/schema/CWV/indexability) |
| Title & Meta Refresh | `url` | AI-written title + meta, keyword-informed |
| Heading Structure Cleanup | `url` | Clean H1–H6 outline |
| Competitor Page Comparison | `urlA`, `urlB`, `fetchBacklinks?` | Point-by-point verdict + action plan + backlink gap |
| AI Blog Draft (MDX) | `title`, `keyword`, `intent?`, `location?` | 1500–2000w on-brand MDX draft |
| Project Backlink Profile | — | Referring domains, dofollow, authority |
| Striking-Distance Keywords → CSV | — | Pos ≤20 queries, prioritized CSV |
| High-Traffic Pages at Risk → CSV | — | Traffic-weighted fix list CSV |
| Quick Wins to Spreadsheet | `crawlId` | Prioritized quick-wins CSV |
| Traffic & Engagement Report (GSC+GA4) | — | Combined traffic/engagement report |

### Hard constraint the skills MUST encode
Recipe IDs are **per-project UUIDs**, not stable slugs. A skill MUST call `list_workflows`,
match the recipe by its **name string**, read the returned `id`, then `run_workflow { workflowId: id }`.
**Never hardcode a recipe id.** This is the workflow analogue of the existing "never hardcode a
crawlId/projectId" rule.

### Async pattern
`run_workflow` returns immediately with a `runId`; the skill polls `get_workflow_run` until
terminal (like `start_crawl` → `wait_for_crawl`). Recipes that drive crawl+AI take longer than a
read — the skill should tell the user "running <recipe>…" and poll, not block silently.

## 3. Approach: weave into the existing 6 (keep "6 not 12"), add ONE new skill

Chosen approach: **weave workflow tools into the skills where they fit, add exactly one net-new
skill for the one capability that has no honest home** (competitor analysis), and teach the
shared FOUNDATIONS the workflow pattern once.

Rationale for the single new skill: competitor comparison is a distinct *job* with distinct
inputs (the user supplies a rival URL) and a distinct output (a beat-the-competitor plan). It
doesn't fit "audit my site" or "chase my rankings" without distorting them. Everything else
(generation, backlinks, keywords, traffic report) genuinely deepens an existing skill.

### 3a. FOUNDATIONS (shared, copied into every skill) — teach the pattern ONCE
Add a new section to `_shared/seo-mcp-foundations.md`:
- **"Running workflows (actions, not just reads)."** Explains: the MCP now has recipes that
  *produce* things (drafts, comparisons, reports) beyond reading audit data; the
  list→match-by-name→run→poll pattern; the id-is-not-stable constraint; the start-then-poll
  async note; and a recipe→job table (subset of §2 above).
- **Diagnose-vs-produce principle.** Default is still diagnose + paste-ready fix. A workflow that
  *generates* (blog, title/meta rewrite) is an **action** — offer it, name that it drives AI +
  cloud credits, and only run on the user's go-ahead. Mirrors the existing "never silently edit"
  rule extended to "never silently spend."

### 3b. Per-skill weave

| Skill | Workflow tool(s) to add | How it deepens the skill |
|---|---|---|
| **seo-audit** | `Project Backlink Profile`, `AI SEO Page Review` (for the top at-risk page) | Adds the **off-page dimension** the audit never had; the AI page review enriches the top-page drill-down beyond raw `get_page_issues`. |
| **seo-quick-wins** | `Title & Meta Refresh`, `Heading Structure Cleanup` | Turns a *recommended* meta/heading fix into a **generated, paste-ready** one — quick wins become "here's the exact rewrite," not "consider rewriting." |
| **seo-striking-distance** | `Competitor Page Comparison` (see 3c — may route to the new skill), `Title & Meta Refresh` | For a stuck pos-8–20 page, compare against the URL currently ranking above it and generate the intent-matched title. |
| **seo-content-strategy** | `AI Blog Draft (MDX)` | "Write now" items become **actual drafts**, not just briefs. NOTE: keyword volume/difficulty is NOT directly consumable today — it exists inside `Title & Meta Refresh` as an *intermediate* `digispot-keywords` step, so the curated `get_workflow_run` (terminal-node only) does not surface it. Treat keyword-data-as-output as a §4 gap, not a solved item. |
| **seo-internal-linking** | *(none — stays read-only; correct as-is)* | Linking is a pure graph-read job; no workflow fits. Leave it. |
| **seo-progress-report** | `Traffic & Engagement Report (GSC+GA4)`, `Project Backlink Profile` | One-shot combined GSC+GA4 report replaces several manual reads; backlink profile lets the report show **off-page trend**, not just on-page. |

### 3c. ONE new skill: `/seo-competitor`
- **Job:** given the user's page and a competitor's URL (or "who ranks above me for X"), run
  `Competitor Page Comparison` (with `fetchBacklinks`), synthesize the verdict + a prioritized
  "beat them" plan (content gaps, schema, speed, backlink gap), and tie each move to a fix.
- **Why its own skill:** distinct user input (rival URL), distinct deliverable, and it's the #1
  capability an SEO expert expects that the suite has never had. Weaving it into striking-distance
  would overload that skill's "push my near-page-1 rankings" focus.
- **Cross-links:** striking-distance points here when the user asks "why does <competitor> outrank
  me"; audit points here for a competitive baseline.

## 4. What's RIGHT beyond today's tools (don't limit to what we have)

Naming the gaps a senior SEO would still see, so the engine roadmap and skills roadmap converge:

1. **Standalone keyword research tool (CONFIRMED gap, cheap to close).** The
   `digispot-keywords` node already returns real volume/difficulty/cpc/intent from Digispot
   Cloud — but only as an *intermediate* step inside `Title & Meta Refresh`, so
   `get_workflow_run` (terminal-node only) never surfaces it to a skill. The data exists; it's
   just not reachable as output. Two cheap fixes: (a) a tiny keyword-only recipe whose TERMINAL
   node is `digispot-keywords` (seed keywords → volume/difficulty rows), or (b) a named
   `get_keyword_data` tool. Either lets `seo-content-strategy` and `seo-striking-distance` plan
   from real demand. **Highest-ROI §4 item — recommend building alongside Phase 3.**
2. **Competitor at the DOMAIN level.** `compare_pages` is page-vs-page. `CompetitorTracking`
   exists in schema (score gap, backlink gap, keyword gap) but has no writer/tool. A
   `competitor_compare { competitorDomain }` recipe would power a domain-level `/seo-competitor`.
   **Roadmap, not this phase.**
3. **Named per-capability tools (Phase 2 of the spider work).** `compare_pages{urlA,urlB}`,
   `get_backlink_profile{}`, `generate_blog_draft{...}` as typed named tools would make the skills
   read cleaner than the generic `run_workflow` + name-match dance. The skills SHOULD be written
   to prefer named tools **if/when Phase 2 ships**, falling back to the generic runner. Plan the
   skills so the swap is a one-line change (a helper "run recipe X" that uses the named tool when
   present, else list→match→run).
4. **Rank tracking over time.** `RankTracking`/`RankKeyword` schema exists, no tool. A
   `get_rank_history` would let `seo-progress-report` show true position trends, not just GSC
   snapshots. **Roadmap.**

The skills plan above works entirely on **today's** tools; items 1–4 are where "what's right"
exceeds "what we have," flagged so they can be sequenced as engine work.

## 5. Deliverables of Phase 3 (when built)

- `_shared/seo-mcp-foundations.md` — new "Running workflows" section + diagnose-vs-produce rule.
  (Copied into each skill's FOUNDATIONS.md at install time — one edit, propagates.)
- 5 existing SKILL.md files updated per §3b (internal-linking untouched).
- 1 new skill: `skills/seo-competitor/SKILL.md` + FOUNDATIONS copy + install wiring.
- `README.md` — skills table updated (6 → 7), "what these skills don't cover yet" note (§4 gaps).
- `install.sh` — include the new skill (verify it globs `skills/*` so no change needed).

## 6. Verification (when built)

Each touched skill must be dry-run against a live MCP-bound project (any test project):
- `/seo-quick-wins` → offers a `Title & Meta Refresh` and the generated meta actually returns.
- `/seo-competitor <your page> <competitor page>` → `Competitor Page Comparison` completes, verdict shown.
- `/seo-progress-report` → `Traffic & Engagement Report` runs and the combined report renders.
- Confirm every skill discovers recipes by name (kill the run if any hardcoded id appears).

## 7. Out of scope (this phase)

- Building the engine tools in §4 (keyword research, domain competitor, rank history) — roadmap.
- Phase 2 named tools in the spider repo — separate; skills written to adopt them when present.
- `seo-internal-linking` changes — it's correctly read-only.
- Reworking the existing read-based procedures — workflows are *additive*, not replacements.
