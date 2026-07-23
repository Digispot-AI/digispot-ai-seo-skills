---
name: seo-create-content
description: Turn a content gap or target keyword into a publish-ready page draft with an on-brand cover image — runs the Spider's page-writer and Image Studio workflows, grounded in the owner's Knowledge base. Use when the plan exists and it's time to CREATE. For deciding what to write use seo-content-strategy; for fixing existing pages use seo-audit.
trigger: /seo-create-content
---

# /seo-create-content

Create, don't just diagnose: draft a new page (MDX) for a chosen content gap or
keyword and generate its on-brand cover image, using the project's own workflow
engine so results land inside Spider for review.

**First, read `FOUNDATIONS.md` in this skill's folder** and resolve scope + crawl.

## When to use

- A content gap or keyword target is already chosen and the user wants the page.
- "Write the page for X" / "draft this with an image".

Reach for a sibling instead when: still deciding WHAT to write →
`/seo-content-strategy`; improving an existing page's title/meta →
`/seo-striking-distance` or the Title & Meta Refresh recipe.

## Procedure

1. **Scope + crawl** (FOUNDATIONS §1–2). A completed crawl is not optional
   here: the Page Writer grounds internal links in crawl data. If the run
   result reports internal links unavailable (`internalLinkCount: 0` with a
   crawl notice), STOP and offer `start_crawl` before publishing anything —
   an orphan draft with zero internal links is not shippable.
2. **Setup preflight — the quality inputs live in the app UI.** Output quality
   tracks three owner-configured inputs. Check each BEFORE spending credits;
   when one is missing, tell the user exactly where in the Spider app to set
   it up, then ask whether to proceed degraded or wait:
   - **Knowledge base** — `get_knowledge { view: "context" }`. Empty → point
     the user to the app's **Knowledge** page (offerings, people/credentials,
     locations, policies, pricing). Without it the draft can only lean on
     crawl facts and may omit or invent business specifics.
   - **Reference images** — `list_image_references`. Empty → point the user to
     **Image Studio → Reference library** in the app (upload the real people,
     premises, products, logo). Only `referenceImage: "library:<id>"` is
     reliable; URL references are often NOT ingested. After every image run,
     read `usedReference` in the result — if `false`, say so plainly: the
     image shows representative people/scenes, not the owner's real ones.
   - **Brand guidelines / cover system** — before generating any cover, look
     at the site's existing covers. If a consistent cover template exists,
     match it (prefer a template/code-generated cover over free generation) —
     one "nice" off-template cover in a uniform set is a visual regression.
     If the app has brand guidelines configured (colors, fonts, style), pass
     them via `imageNote`/`coverStyle`; if not, suggest setting them up in
     the app's brand/settings page.
   If a preflight tool is not exposed by this MCP build, that's a version gap,
   not an error: name the missing capability, continue on the degraded path,
   and state what quality is lost.
3. **Ground in the business.** `get_knowledge { view: "context" }` — the draft
   must state the owner's real facts (offerings, locations, people, policies),
   never invented ones. If the target topic has no covering knowledge, say so
   and (only with owner-confirmed facts) capture it via `propose_knowledge`.
4. **Pick the target.** If not already given:
   `get_content_opportunities { section: "gaps", priority: "high" }` and/or
   `get_keywords { section: "opportunities" }` — prefer a gap in the "new" or
   "expand" lane with clear intent. Confirm the choice with the user before
   spending workflow credits.
5. **Find the recipes.** `list_workflows` — the page recipe is
   "AI - Page Writer (MDX)"; standalone images use "AI - Image Studio".
6. **Reference images — match them to the topic via the Knowledge base.**
   `list_image_references` returns labeled references ("Dr. Priya — headshot",
   purpose person/product/logo/style). Don't pick "a person" — pick the RIGHT
   one: cross-reference the knowledge context from step 3 to find who or what
   this page is actually about (the doctor who leads the department being
   written about, the exact product/SKU, the branch being featured), then
   select the reference whose label matches. Pass its id as
   `referenceImage: "library:<id>"`.
   **Identity rule — never substitute:** if the knowledge names Dr. A but only
   Dr. B has a reference image, do NOT use Dr. B's face on Dr. A's topic —
   wrong-person attribution is worse than no person. Fall back to a non-person
   cover (product/style/brand-graphic) and tell the owner which reference
   photo to upload in Image Studio to unlock the authentic version. Same for
   products: the pictured item must be the item the page discusses.
7. **Run the draft.** `run_workflow` with the Page Writer recipe: keyword/title
   from step 3, outline points from the gap's brief, and the cover enabled.
   Then `get_workflow_run` until it completes — report where the MDX + image
   landed (the run's artifacts, visible in Automations → run).
8. **Review pass.** Read the produced draft against the knowledge context from
   step 2: flag any claim not grounded in owner facts, thin sections vs the
   gap's outline, and missing internal links to the cluster's existing pages
   (`get_link_insights` suggestions for the new topic).

## Output

- The chosen target + why (one line).
- Run id(s), where the draft + cover landed, and generation cost context.
- A short review: grounded-facts check, gaps vs outline, internal links to add.
- What the user should edit before publishing — never claim publish-ready
  without the owner reviewing facts.

## Guardrails

- Workflow runs spend AI credits/tokens — always confirm before `run_workflow`,
  and never loop retries without asking.
- Facts come from the Knowledge base; the draft must not invent names, prices,
  credentials, or locations. YMYL topics (health, legal, finance) get a
  conservative, expert-review-required note.
- Identity integrity: a reference image of a person or product may only be
  used on pages ABOUT that person or product (knowledge-matched, step 6).
  When unsure who's pictured or who the page is about, generate without the
  reference and say why.
