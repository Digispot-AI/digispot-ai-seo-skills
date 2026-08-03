<!-- digispot-seo:begin v1 -->
# Digispot SEO — routing for this repo

This repo is bound to a Digispot SEO project. SEO work here is done through the
Digispot SEO skills (installed separately — if `/seo-audit` etc. are unavailable,
tell the user to install https://github.com/digispot-ai/digispot-ai-seo-skills
and continue with plain MCP tools).

## Route SEO intents to skills — don't improvise with raw tools

| The user says (any phrasing of)… | Invoke |
|---|---|
| "audit my site" / "how healthy is my SEO" / "full check" | `/seo-audit` |
| "what should I fix first" / "quick wins" / "fast results" | `/seo-quick-wins` |
| "did the fixes work" / "traffic dropped" / "are we winning" / reporting | `/seo-progress-report` |
| "almost page 1" / "easy ranking gains" / positions 8–20 | `/seo-striking-distance` |
| "what content should we write" / topic clusters / cannibalization | `/seo-content-strategy` |
| "write/draft a page or post" | `/seo-create-content` |
| "why does <rival> outrank me" / compare vs a competitor page | `/seo-competitor` |
| orphan pages / internal links / link equity / "buried pages" | `/seo-internal-linking` *(needs the Spider app)* |

A bare SEO question with no clear intent → ask which of these they want, or
default to `/seo-quick-wins` for "help me improve".

## Detect the servers ONCE per session

Probe tool availability (don't call anything yet — just check what's offered):

- `get_mcp_scope` present → **Spider** (local crawler app) is connected.
- `digispot_projects` present → **Platform** (cloud) is connected.

Declare the mode (dual / spider-only / platform-only) in your first SEO reply
and keep it for the whole session. The skills' FOUNDATIONS §0.5 defines how each
mode behaves — including that `/seo-internal-linking` is Spider-only.

## Session state — resolve once, reuse

After the first skill resolves scope/crawl it emits a `[session]` card. Later
skill invocations in the same conversation MUST reuse that card instead of
re-probing servers or re-resolving scope/crawl (details: FOUNDATIONS §0.5).

## Money

Platform tools prefixed `digispot_` can spend real credits (exactly seven of
them do). The skills handle the consent protocol (FOUNDATIONS §0.6) — never
call a credit-charging Platform tool outside a skill without checking
`digispot_usage_limits` and getting explicit user consent with real numbers.
<!-- digispot-seo:end -->
