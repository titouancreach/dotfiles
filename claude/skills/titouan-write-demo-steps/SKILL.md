---
name: titouan-write-demo-steps
description: Write reviewer-facing demo / verification steps for a ticket from its PR(s), then verify them live in the browser before filling the ticket's "Demo steps" section. Use when the user asks to write demo steps, verification steps, QA steps, or fill the Demo steps / Edge cases section of a Notion ticket.
---

# Write demo steps

Demo steps let a human verify a feature without reading code. Each step is an
action plus an observable assertion: **Go to X → Click Y → Assert Z**.

## Workflow

1. **Find the PR(s) for the ticket.** A ticket often has several (e.g. a `site`
   PR and an `org` PR). Cover the whole ticket, not just the last PR.
   - `gh pr view <n> --json title,body,url` and `gh pr diff <n>`.

2. **Read the diff for the user-facing truth — not just the description.**
   - Presentation files: what renders, and the exact copy/labels to assert on.
   - The render *conditions*: which interest/auth state, which `isNonEmpty`
     guards, which feature flag. These become the prerequisites and edge cases.
   - Use cases / queries: what each number means (e.g. "patients in the
     opportunity's disease areas"), so assertions are precise.

3. **Get concrete data to demo with.** Steps need real, working IDs and a
   known state. Query the dev DB (`mcp__postgres__execute_sql`) to find an
   entity already in the right state (e.g. an org "on the list" with positioned
   sites), and to name things (org/site/opportunity names) in the steps.

4. **Verify live with Claude in Chrome before writing anything.** Load the
   `mcp__claude-in-chrome__*` tools via ToolSearch, open a fresh tab, walk the
   exact steps, and screenshot each assertion. A demo step you have not seen
   pass is a guess.
   - Verify on **staging** (`https://marketplace.staging.inato.com`) — that is
     the environment the reviewer will demo on (per the team DR
     `ship-high-quality-features-using-demos.md`: demos run on staging to avoid
     touching production data). **Staging and local share the same dataset and
     the same ids** — an id from the local Postgres MCP is valid on staging, so
     build URLs directly from it (e.g. `/organization/{orgIdFromMcp}/...`).
     Don't assume ids differ across environments. A staging 404 usually means
     the route is unbuilt/unlinked or the id is genuinely wrong, not a per-env
     id mismatch.
   - You MAY verify locally on `localhost:3000` first — useful to check the
     feature *before* it is deployed — but localhost is a private pre-deploy
     check only. The URLs you write into the ticket are always staging.
   - The org-level pages are reached by **direct URL** (`/organization/{orgId}/...`);
     they are not always linked from the nav, and bare `/organization` 404s.
     `inheritSiteAccessFromOrganization` means an org-admin (`+org@…`) login lands
     on "Your sites" listing the org's inherited sites and gets a "TrialMed"-style
     org switcher in the header.
   - Note the **prerequisite login** (which account/role the URL switches to)
     and any state changes; never enter credentials yourself.

5. **Match the ticket's existing format.** Inato tickets use checkbox lists
   under `## Demo steps` and `## Edge cases`. Replace the placeholders, keep the
   structure. Lead with a one-line prerequisite (env + login + entity).

6. **Cover edge cases from the guards you found in step 2** — empty state, the
   "before" state (e.g. not yet on the list), no-data CTA vs data shown.

## Style

- One assertion per step. Quote the literal UI copy to check (`"You are on the
  list"`, `"9,414 patients in indication"`).
- Concrete URLs and names, not "the relevant page".
- No internal jargon a reviewer can't see in the UI.

## Writing into the Notion ticket

Updating a shared team ticket is a publish action — confirm with the user first
unless they explicitly asked you to write it in. Use
`mcp__claude_ai_Notion__notion-update-page`; preserve the surrounding sections
(value-focus callout, Edge cases, columns) and only replace the placeholders.

**Every URL written into the ticket must point at staging**
(`https://marketplace.staging.inato.com/...`) — **never `localhost`**. Notion is
a shared team doc; a localhost link is useless to teammates and signals the demo
wasn't set up on the shared environment. Don't leave localhost links with a
"swap host later" note — swap the host to staging before saving. localhost stays
in your local pre-deploy check, not in the ticket.
