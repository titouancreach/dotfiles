---
name: titouan-write-demo-steps
description: Write reviewer-facing demo / verification steps for a ticket from its PR(s), then verify them live in the browser before filling the ticket's "Demo steps" section. Use when the user asks to write demo steps, verification steps, QA steps, or fill the Demo steps / Edge cases section of a Notion ticket.
---

# Write demo steps

A demo step lets a human verify a feature without reading code: an action plus an
observable assertion — **Go to X → Click Y → Assert Z**. A step you have not
watched pass is a **guess**; verify every one live before it goes in the ticket.

## Workflow

1. **Find every PR for the ticket** — a ticket often has several (a `site` PR and
   an `org` PR). Cover the whole ticket. `gh pr view <n> --json title,body,url`
   and `gh pr diff <n>`.

2. **Read the diff for user-facing truth, not just the description.**
   - Presentation files: what renders, and the exact copy/labels to assert on.
   - Render *conditions*: interest/auth state, `isNonEmpty` guards, feature flags
     — these become prerequisites and edge cases.
   - Use cases / queries: what each number means (e.g. "patients in the
     opportunity's disease areas"), so assertions are precise.

3. **Get concrete data to demo with.** Query the dev DB
   (`mcp__postgres__execute_sql`) for an entity already in the right state and for
   the names (org/site/opportunity) the steps will quote.

4. **Verify live with Claude in Chrome before writing anything.** Load the
   `mcp__claude-in-chrome__*` tools via ToolSearch, open a fresh tab, walk the
   exact steps, screenshot each assertion. Note the prerequisite login (which
   account/role the URL switches to) and any state changes — **never enter
   credentials yourself**.
   - Org-level pages are reached by **direct URL** (`/organization/{orgId}/...`);
     they aren't always linked from the nav, and bare `/organization` 404s.
     `inheritSiteAccessFromOrganization` means an org-admin (`+org@…`) lands on
     "Your sites" and gets a "TrialMed"-style org switcher in the header.
   - You MAY check `localhost:3000` first (useful before deploy) — but that is a
     private pre-deploy check. See **Staging is the only environment** below.

5. **Match the ticket's format.** Inato tickets use checkbox lists under
   `## Demo steps` and `## Edge cases` — replace the placeholders, keep the
   structure, lead with a one-line prerequisite (env + login + entity).

6. **Cover the edge cases from the guards in step 2** — empty state, the "before"
   state (not yet on the list), no-data CTA vs data shown.

## Staging is the only environment (single source of truth for URLs)

Every URL you verify on and write into the ticket points at **staging**
(`https://marketplace.staging.inato.com/...`), **never `localhost`**. Staging is
what the reviewer demos on (DR `ship-high-quality-features-using-demos.md`: demos
run on staging, not production data). **Staging and local share the same dataset
and the same ids** — an id from the local Postgres MCP is valid on staging, so
build URLs directly from it. A staging 404 means the route is unbuilt/unlinked or
the id is wrong, never a per-env id mismatch. `localhost` stays in your private
pre-deploy check — swap the host to staging before saving, no "swap later" notes.

## Style

- One assertion per step, quoting the literal UI copy (`"You are on the list"`,
  `"9,414 patients in indication"`).
- Concrete URLs and names, not "the relevant page".
- No internal jargon a reviewer can't see in the UI.

## Writing into the Notion ticket

Updating a shared team ticket is a **publish** action — confirm with the user
first unless they explicitly asked you to write it in. Use
`notion-update-page`; preserve the surrounding sections (value-focus callout,
Edge cases, columns) and only replace the placeholders.
