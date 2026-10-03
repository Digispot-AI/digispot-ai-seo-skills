# Testing the skills

The essential cases to run before a release. Each row is one prompt or one skill run in a **fresh Claude Code session**, and runs in each mode it applies to.

| Mode | Connect | How the skills detect it |
|---|---|---|
| **Spider** | The [Spider desktop app](https://downloads.digispot.ai/) — it writes the `digispot-seo` entry in your site repo's `.mcp.json` | `get_mcp_scope` is offered |
| **Platform** | An `mcp_` key from app.digispot.ai → Settings → Connected Apps → MCP, added as an MCP server (`https://mcp.digispot.ai/mcp`) | `digispot_whoami` is offered |
| **Dual** | Both | Both are offered |

**How to judge a row:** read the tool calls Claude Code shows and the final answer. A row fails if Claude calls a tool the row says it must not, spends credits without asking, or reports a number without saying where it came from.

**Status:** `[ ]` not tested · `[P]` pass · `[F]` fail · `[—]` does not apply
**Priority:** 🔴 must pass before release · 🟡 should pass

---

## 1. Install

Run these in a scratch folder, not a real site repo.

| # | Pri | Scenario | Expected | Status |
|---|---|---|---|---|
| 1.1 | 🔴 | Install from a clone | `./install.sh` → 8 skills in `~/.claude/skills/`, each with a `FOUNDATIONS.md` | [P] 2026-10-03 |
| 1.2 | 🔴 | One-line install | `curl -fsSL …/main/install.sh \| bash` → 8 skills installed as real folders, no clone needed | [ ] |
| 1.3 | 🟡 | Set up a site repo with nothing in it | `--project` creates `AGENTS.md` and a `CLAUDE.md` that imports it | [P] 2026-10-03 |
| 1.4 | 🔴 | Set up a site repo that has its own `AGENTS.md` and `CLAUDE.md` | Block added after your text; `@AGENTS.md` added to `CLAUDE.md`; your lines untouched; re-running changes nothing else | [P] 2026-10-03 |
| 1.5 | 🔴 | `AGENTS.md` whose end marker was deleted | Installer stops with an error and leaves the file as it was | [P] 2026-10-03 |

---

## 2. Mode and session

| # | Pri | Scenario | Expected | Spider | Platform | Dual |
|---|---|---|---|---|---|---|
| 2.1 | 🔴 | Mode declared | First SEO reply names the mode; no calls to the server that isn't connected | [ ] | [ ] | [ ] |
| 2.2 | 🔴 | Right project | Spider: the project bound in `.mcp.json`. Platform: the project whose domain matches the site, confirmed in one line; asks if none matches | [ ] | [ ] | [ ] |
| 2.3 | 🟡 | Session reused | Run `/seo-audit` then `/seo-quick-wins` in one session: the second reuses the `[session]` card, no re-detection | [ ] | [ ] | [ ] |
| 2.4 | 🔴 | Data never mixed | Spider crawl numbers and cloud audit numbers are labelled separately; never one timeline, never one grade | [—] | [—] | [ ] |

---

## 3. Skills — happy path

One run per skill. "Expected" is what every mode must produce; the mode-specific notes say what changes.

| # | Pri | Skill | Expected | Spider | Platform | Dual |
|---|---|---|---|---|---|---|
| 3.1 | 🔴 | `/seo-audit` | Grade, then Ship now / Plan / Backlog with paste-ready fixes. Platform: says the cloud grade comes from a sample of pages and names what the cloud can't see (site graph, devices) | [ ] | [ ] | [ ] |
| 3.2 | 🔴 | `/seo-quick-wins` | Only cheap fixes, each with exact text to paste — no "consider revising" | [ ] | [ ] | [ ] |
| 3.3 | 🔴 | `/seo-striking-distance` | Queries at positions 8–20 with a move per page. Platform: GSC data labelled "as of last sync" | [ ] | [ ] | [ ] |
| 3.4 | 🟡 | `/seo-content-strategy` | Gaps, clusters and cannibalization, ranked. Dual/Platform: live keyword volumes only after consent (§4) | [ ] | [ ] | [ ] |
| 3.5 | 🔴 | `/seo-create-content` | A draft with no invented prices, names or credentials. Spider: grounded in the Knowledge base. Platform: asks you for the facts first | [ ] | [ ] | [ ] |
| 3.6 | 🟡 | `/seo-competitor` | Gaps in content, schema, speed and backlinks, with a plan. Platform: header says the content diff is agent-read | [ ] | [ ] | [ ] |
| 3.7 | 🔴 | `/seo-internal-linking` | Spider: `source → target` links with exact anchors. Platform: says it needs the Spider and stops | [ ] | [ ] | [ ] |
| 3.8 | 🟡 | `/seo-progress-report` | What improved, what regressed, each tied to a fix. Dual: cloud audit results on their own labelled line | [ ] | [ ] | [ ] |

---

## 4. Credits

| # | Pri | Scenario | Expected | Spider | Platform | Dual |
|---|---|---|---|---|---|---|
| 4.1 | 🔴 | No silent spend | Every paid action — a workflow, a crawl, a paid Platform tool — waits for an explicit "yes" in chat. Say "no": nothing runs | [ ] | [ ] | [ ] |
| 4.2 | 🔴 | One ask, real numbers | Several paid calls → one ask with the count and your balance ("8 keywords = 8 DATA credits, you have N") | [—] | [ ] | [ ] |
| 4.3 | 🔴 | Right price | A draft is quoted as 12 AI credits (×3 on an advanced model); a cloud audit as 1 site audit + up to `crawlBudget` page audits | [—] | [ ] | [ ] |
| 4.4 | 🟡 | Pools kept apart | DATA and AI credits are quoted separately, never added up | [—] | [ ] | [ ] |
| 4.5 | 🟡 | Free stays free | No consent ask before free reads | [ ] | [ ] | [ ] |

---

## 5. When things are missing

| # | Pri | Scenario | Expected | Spider | Platform | Dual |
|---|---|---|---|---|---|---|
| 5.1 | 🟡 | No GSC | Says the traffic signal is missing and ranks by severity × ease; never invents positions or clicks | [ ] | [ ] | [ ] |
| 5.2 | 🟡 | No recent crawl or audit | States the data's date and offers a fresh run (with the price, on Platform) | [ ] | [ ] | [ ] |
| 5.3 | 🟡 | Server not reachable | Says which server is down. Spider or Platform alone: stops. Dual: says what it can no longer do, then continues with the other | [ ] | [ ] | [ ] |
| 5.4 | 🔴 | Invalid or revoked key | Relays the error with the link to Settings → Connected Apps → MCP; no retry loop | [—] | [ ] | [ ] |
| 5.5 | 🟡 | Plan limit reached | Relays the limit and the upgrade link once; no workaround | [ ] | [ ] | [ ] |
