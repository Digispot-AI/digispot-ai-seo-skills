---
name: seo-create-image
description: Generate an on-brand image with the Spider's Image Studio — a blog cover with a readable title, a working scene with the owner's real people, or a product shot — with exact layout, colors and size, then check it before handing it over. Use when the user wants an image on its own (a cover for an existing post, a hero, a product visual). For a new page plus its cover in one go use seo-create-content.
trigger: /seo-create-image
---

# /seo-create-image

Produce one publish-ready image through the Spider's **Image Studio** (the
"AI - Image Studio" workflow), on the owner's own image key, and review it before
you hand it over. The Spider does the rendering, text compositing and file
handling; your job is to pass it inputs it actually supports, read what it
reports back, and catch a bad result before the user does.

Everything here runs over the Digispot MCP server, so it works the same in any
MCP client (Claude Desktop, Claude Code, Cursor, …). Image tools return an inline
**preview image** with their result; if your client cannot display images, give
the user the saved file path and ask them to check the points in step 6.

**First, read `FOUNDATIONS.md` in this skill's folder** and resolve scope (§1).
No crawl is needed for an image.

## When to use

- "Make a cover for this post", "a hero image for the dental page", "a product
  shot of the 500 ml bottle", "the doctor with a patient in our clinic".

Reach for a sibling instead when the page itself does not exist yet →
`/seo-create-content` (it writes the page and its cover together).

## Procedure

1. **Use the typed tool — never guess input values.**
   - **`generate_image`** (Spider 1.0.10+) is the entry point. Its schema IS the
     contract: every option is an enum whose description says what each value
     means. Pass only listed values.
   - **Older builds without `generate_image`:** `list_workflows` → find
     "AI - Image Studio" by **name** (never a hardcoded id) →
     `list_workflows { workflowId: "<its id>" }` for the input contract → run it
     with `run_workflow`. Pass select values **verbatim**.
   - Either way: a value that is not an option rejects the run and the reply lists
     the valid ones. Map the user's words onto the list (table below) and retry.
     A key the recipe does not support comes back in an `IGNORED` line: that
     option did not take effect, so tell the user and do not describe the image
     as if it had. If an input this skill describes is not offered at all, this
     Spider build predates it. Say which capability is missing and continue.

2. **Map the request onto the contract.** Typical translations (confirm against
   step 1's list):

   | The user says | Pass |
   |---|---|
   | "cover", "blog header", "featured image" | `profile: "blog-cover"` |
   | "the doctor with a patient", "our team at work" | `profile: "people-scene"` + a person reference |
   | "product photo", "catalog shot" | `profile: "product-shot"` + the product reference |
   | "flat vector", "flat illustration", "vector art of a microscope" | `style: "illustration"` |
   | "icons in our brand colors", "minimal brand graphic" | `style: "flat-vector"` (icon medallions, not a drawn subject) |
   | "photo", "realistic" | `style: "photorealistic"` |
   | "title on the left", "keep the left half empty" | `titleSide: "left"` |
   | "use #171f46 and #E0684C", "our navy and clay" (with hexes) | `palette: "#171f46, #E0684C"` |
   | "1200×675 for the site", "OG size" | `outputSize: "1200x675"` (overrides `aspectRatio`) |
   | "no dark box behind the text" | `scrim: "none"` |
   | "title in cream", "use Inter" | `textColor: "#F6F3EE"`, `fontFamily: "Inter"` |

   Put **what to depict** in `brief` (subject, setting, mood; one clear subject).
   Put **placement and colors in their own inputs**, not only in the brief:
   `titleSide` decides the composition and the title position, and `palette` is a
   hard color constraint. If a brief says "subject on the left" while
   `titleSide: "left"`, the title side wins and the scene is recomposed to match,
   so leave placement words out of the brief.

3. **Preflight — the quality inputs live in the app.**
   - **Reference images:** `list_image_references`. People scenes and product
     shots need the REAL person/product: pass `referenceImage: "library:<id>"`,
     matched to what the image is about (the doctor the page is about, the exact
     SKU). Never put one person's face on another person's topic. No matching
     reference → say so, offer a non-person image, and name the photo to upload in
     **Image Studio → Reference library**.
   - **Brand:** when no `palette` is given, colors come from the project's brand
     kit; for a title, so does the font. If the site has a fixed cover template
     (look at a few existing covers first), match its title side, colors and size.
   - **Exact title text:** `coverTitle` (and `coverDescription`) are composited
     programmatically in the brand font, so the wording comes out exactly as
     typed. Never ask the image model to draw words.

4. **Confirm, then run.** Every render is billed to the owner's image key (each
   result reports its `cost`). State the profile, style, title side, colors and
   size you will use, get a go-ahead, then call `generate_image { … }`. It waits
   for the render (about a minute at most) and returns the result facts and a
   preview. If it says the run is still rendering, poll `get_workflow_run { runId }`
   and then call `download_workflow_image { runId }` for the file and preview.
   (Older builds: `run_workflow` + `get_workflow_run`.)

5. **Read the result before you look at the image.** `generate_image` summarises
   these; `get_workflow_run` returns them as the image step's output fields:
   - `status` (`ok` or a failure kind) and `notice`: a non-empty notice always
     matters. Relay it.
   - `overlay.side` / `overlay.placement`: `clear` means the title sits in empty
     space on the requested side; `switched` means the render left the OTHER side
     empty and the title went there (tell the user); `crowded` means no clear side
     existed and the title sits on a backing over the art (re-run, see step 7).
   - `overlay.contrast`: the estimated WCAG contrast of the title. Below 4.5 is
     not AA; say so.
   - A title was asked for but `overlay.applied` is `false`: the image shipped
     text-free. Say so; re-adding the title needs no new render (the owner can do
     it in the app, or you can place the text yourself on the image).
   - `width` × `height`: the delivered size. With `outputSize` it must match exactly.
   - `alt`: ready-to-use alt text. Hand it over with the image.
   - `usedReference: false` with a reference passed → the image shows a
     representative person/product, not the owner's. Say so plainly.

6. **Look at it yourself.** Review the preview image returned by `generate_image`
   (or by `download_workflow_image { runId }`) as a reviewer would:
   - the title is fully in empty space and touches no part of the subject;
   - the title is readable at thumbnail size;
   - there are no stray letters, numbers, fake text or logos in the artwork;
   - the colors are the requested ones (no hue family the user did not ask for);
   - the background is one finished composition, not a half-filled or split canvas.
   Report each failed check specifically ("the title's last line runs into the
   microscope base").

7. **Fix with the cheapest lever.**
   - The art is right but the text placement or style is wrong, or the user wants
     to set the text themselves → `download_workflow_image { runId, variant: "raw" }`
     returns the same render without the title (no new spend).
   - The art itself is wrong (subject in the title space, wrong colors, stray
     text, unfinished background) → tighten the inputs that caused it (move
     placement out of the brief, add `palette`, set `titleSide`, simplify the
     subject) and re-run, with the user's go-ahead for each run. Stop after two
     re-runs and report what keeps failing; never loop silently.

## Output

- The saved file's path from `download_workflow_image` (and the raw one if
  fetched), its size, and `alt`. The file is on the user's computer: an agent
  with file access can copy it into the site repo, otherwise the user opens it.
- One line on what was rendered: profile, style, title side, colors.
- Your review: each check from step 6 as pass/fail, plus anything `notice`,
  `placement` or `contrast` reported.
- Cost of the run(s) and the run id(s). Every take is also kept in the app under
  Automations → the run, where the owner can swap takes or edit the title for free.

## Guardrails

- Every run spends the owner's image key. Confirm before each one.
- Pass only inputs the contract lists. Never claim an option was applied when
  `run_workflow` reported it as ignored.
- Identity integrity: a person's or product's reference is used only on images
  about that person or product.
- Text belongs to the overlay (`coverTitle`), never to the image prompt.
