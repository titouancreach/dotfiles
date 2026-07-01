---
name: titouan-analyze-feature
description: Produce a synthetic, build-ready technical analysis of an Inato marketplace ticket/feature before coding — data model (how data is stored), which existing Repository method to reuse/generalize (Finder only for cross-aggregate reads, N+1 not allowed), and which existing use case to extend. Use when the user shares a Notion ticket / feature spec and asks for an analysis, feasibility, data-model, repo/finder, or use-case breakdown ahead of implementation (not the dev breakdown / PR split).
---

# Analyze an Inato feature before building it

Turn a ticket into a **synthetic, high-level** analysis a teammate could start
coding from. Verify every claim against the real code (open the file, check the
line) — but **keep the output high-level: do not include `file:line` references
in the analysis**. The reader wants the conclusion, not your search trail.

## Before anything: ground the analysis in docs

CLAUDE.md requires backing technical decisions with `.claude/doc/`. Use the
**`find-doc`** skill first when the feature touches an unfamiliar domain, a
standard (access control, RSC), or a pattern choice. If no doc covers it, say so
explicitly in the output.

## Step 0 — Read the ticket (for yourself, not the output)

Fetch the Notion ticket to understand the actors (site / org-admin / sponsor),
what they see, the values, and any per-entity repetition ("for each site…" — the
N+1 smell for Step 2). **Do not restate the requirement in the analysis** — the
reader already has the ticket. This step only feeds your own understanding.

**Move the ticket into the analysis workflow (do it automatically, don't ask).**
On the same fetch, check the ticket's `Assignee` and `Status` properties and fix
them with one `notion-update-page` `update_properties` call:

- **No `Assignee`** → assign the current user. Get their Notion id from
  `notion-fetch` with id `"self"` (matches the session email,
  `titouan.creach@inato.com`), then set `Assignee` to `["<userId>"]`.
- **`Status` is not `Analysing`** → set `Status` to `Analysing` (the kanban
  "analysis" column; `Started at` auto-stamps on entry). The option is spelled
  **`Analysing`**, not "Analysis".

Skip whichever is already correct. If both are already right, do nothing.

## Step 1 — Data points (how the data is stored)

For every value the feature reads or writes, trace it to storage:

- Domain entity in `packages/marketplace-domain/src/domain/<Entity>/type.ts`.
- Drizzle table + columns in `application/persistence/Drizzle<Entity>Repository/drizzleTable.ts`.
  Note whether fields live in dedicated columns or inside the `data` JSONB blob —
  it changes how they can be filtered/indexed (JSONB path queries vs column index).
- The **join/overlap logic**: which id on entity A matches which id on entity B.
  Name the exact id types (e.g. `member.primarySpecialty: TherapeuticArea.Id`
  matched against `diseaseArea.therapeuticAreaId`). **Decide what you can** from
  the existing code convention (e.g. "match on `primarySpecialty`, like the
  existing matching code") — don't punt a determinable choice to product. Reserve
  the Open-questions section for things genuinely undecidable from code/design.

Report a table: value → entity → table.column (or `data.path`) → id used for the join.

## Step 2 — Reads: reuse a Repository method, or add a Finder?

This codebase splits read access into two patterns. **The line is the number of
tables, not the complexity of the query:**

- **Repository** — one per aggregate, **one table**. Returns aggregates *and*
  read helpers on that table: `count`/`exists`, `… WHERE id IN (…)` batches, and
  `GROUP BY` on its own table. Batching and grouping on a single table are still
  Repository work. Lives in `domain/<Entity>/Repository/`.
- **Finder** — a read projection that **joins across several aggregates/tables**,
  or a read model that maps to no single aggregate. Lives in `domain/<X>/Finder/`
  + `application/persistence/Drizzle<X>Finder/`, registered in the context's
  `liveLayer`. Example: `SiteTrialsToDiscoverFinder` (TrialOpportunity + Trial +
  Pairing + Site + …). **Do not** reach for a Finder just because a query is
  batched or has a `GROUP BY` — that alone keeps it on the Repository.

Decide in this order — **prefer reuse**:

1. **Reuse** an existing Repository method as-is if it returns what you need.
2. **Extend / generalize** an existing Repository method — e.g. turn `id` into
   `ids` and add a `role?` — so one batched call (`… WHERE id IN (…) GROUP BY id`)
   serves both the single-entity and the list/org view. Still a Repository.
3. **Add a Finder** only when the read genuinely spans multiple aggregates/tables.

**N+1 is not acceptable** until the user says otherwise: never serve a list/org
view with a per-entity call in a loop. Solve it with a **batched single-table
Repository method** (`… WHERE id IN (…)`), reserving a Finder for true
cross-aggregate reads. In the analysis, **estimate the number of rows** the query
touches (entities × per-entity rows) so the reviewer can sanity-check the cost.

State the verdict plainly: **reuse X** / **generalize X to batch by `ids`
(Repository)** / **new Finder Z (cross-aggregate read)**.

The N+1 rule targets the **main** read. For a **secondary lookup** over a small,
bounded set (e.g. "the sites of one org" → get-all-org-sites then filter
`isInterested` in memory), don't invent a dedicated repo method — judge by
cardinality and say so plainly: "small number of sites per org, no special method
needed". Two batched calls + an in-memory filter is fine; that's not an N+1.

## Step 3 — Where does the data get served from?

- **Check whether the value is already shown elsewhere first.** Trace existing
  usages of the relevant query up to the UI — if a component already renders it,
  reuse that component and its data path. Note if a computation exists *internally*
  (subscriptions, estimations) without any UI, so the reviewer knows it was checked.
- Find the page's **RSC server component** and the use case(s) it already calls.
- **Prefer extending an existing use case over adding a new one.** Say it plainly,
  e.g. "add `{ piCount, subICount }` to `getOpportunityPageDataForSite` (already
  builds the page data)" — one line per side (site / org). Only spec a brand-new
  use case (input/output, repo calls) when nothing fits.
- **Access control:** if you extend a use case, it's already enforced — say "no
  new access-control code". For a new entry point, name the check for **the actor
  the entry point serves**: a site-scoped use case → `canUserReadSite`, an
  org-scoped one → `canUserReadOrganization`. **Pick the right check — don't blindly
  copy a sibling's**; a recent sibling may use a weaker `ensureUserIsAuthenticated`
  that you should *not* replicate. Org-admins are covered by auth-time enrichment,
  so only **org-level** entry points need an explicit org path.
- Don't write "this is/ isn't a front-only PR" — just state where the datapoint lands.

## Step 4 — Bounded contexts (guardrail check, not an output section)

Check `packages/marketplace-domain/.dependency-cruiser.js` to confirm the work
sits in one context with no cross-context import. This is a check you **run**, not
a section you **write**: only surface it in the output (under **Risks**) if
there's a violation or doubt. If the feature genuinely spans contexts, STOP and
surface the options from `.claude/rules/bounded-contexts.md` rather than working
around it.

## Step 5 — Seed coverage (can we demo it?)

The local DB and staging run the **same** populate script with the **same ids**:
`packages/server/src/scripts/populateDatabase/insertStagingData/` (data under
`data/**`, state transitions under `insertData/**`; run via `pnpm server
db:reset-staging` with `POPULATE_STAGING_DB_ENABLED=true` — it truncates first).
So a fix to the seed fixes both, and a localhost demo built on seed ids works on
staging by swapping only the host.

Check whether a seeded entity already reaches the **exact state the feature needs
to be visible** (e.g. a pairing ≥ `EnrollmentPlanSubmitted`, not selected-for-trial,
on an `OpenForApplication` trial). Read the seed data + state-transition code, not
just the DB. Then pin the concrete demo handle: site/org id, trial/opportunity id,
login email, page URL.

Verdict:

- **Covered** → name the entity + id + login + demo URL so the demo can be written
  immediately.
- **Gap** → name what's missing and the **smallest seed addition** that closes it.
  Because the same seed runs on staging, extending it is the fix for "staging is
  never in the right state" — call it out as a seed change, usually the first work
  item.

## Output shape

Keep it **synthetic and human-reviewable** — a teammate should grasp it in a
couple of minutes. Short bullets and small tables, not prose; **no `file:line`
refs, no code dumps**. A proposed **method signature** is fine (it's the
contract); the **query body is not** — never write the `GROUP BY … WHERE id IN
(…) ?| ARRAY[…]` SQL. State *what* it returns and that it's one batched call, not
*how* it's written.

**Write for coworkers who know the codebase, not for yourself.** State the
decision; don't explain well-known internal conventions (Repository vs Finder,
bounded contexts, RSC, access-control enrichment, etc.) — every dev on the team
already knows them. "Generalize the existing count method to take `ids`" is
enough; the rationale for *why it's not a Finder* is noise.

**Three hard rules on what to leave out:**

- **Never state a negative or a non-decision.** Mention a Finder only when you're
  actually adding one; never write "no new Finder", "all single-table batched",
  "no N+1", "no cross-context import", "not a front-only PR" as reassurance. State
  what you ARE doing — the absence of a Finder is implied by not naming one. (Only
  exception: a negative that's genuinely load-bearing, e.g. a perf risk you
  considered and ruled out for a stated reason.)
- **Risks = open questions and real risks only.** Never add a bullet that
  announces something is "settled", "resolved", "confirmed", or "no longer a
  question". If it isn't an open question or a live risk, it doesn't belong in the
  section — delete it, don't document its resolution.
- **Be terse — the user actively hates verbosity here.** Your default draft runs
  ~2x too long; write it, then **halve it**. Drop every clause that doesn't change
  a build decision: build-up, reassurances, parenthetical asides, meta-commentary
  ("this is exactly the confusion X flags…"). Fragments over sentences; one-line
  section intros. A real example: a 139-line draft was cut to ~60 and only then
  accepted. Use plain words and code (`&&`, `||`), never logic symbols (`∧`, `∨`)
  or non-ubiquitous jargon like "keyed" (write "same `trialId`"). Optimise for a
  30-second human skim, not a complete prose document.
- **Lead with labels, not verbs.** Name the decision as a noun phrase / "X per Y"
  label, not a verb-y sentence describing it. Write `One use case per page`, not
  `One use case feeds the whole page`. `My pipeline = interest-driven`, not
  `My pipeline is driven by the interest table`. `Access control: none new`, not
  `There is no new access control to add`. The label is the point; any clause
  after it is justification, kept short.

The analysis is *only* these sections:

- *(optional one-liner)* — if the ticket is a sibling of recent work, open with a
  single sentence pointing at it (e.g. "Sibling of AST-2144 — same placement,
  same shaped use cases."). One line, no elaboration of the differences — those
  belong in the relevant section below.
- **Data points** — table + the join/overlap resolved **inline in the table's
  match column**. Don't repeat the match as a paragraph under the table.
- **Repository** — reuse vs generalize vs Finder verdict + a row estimate.
- **Use cases** — which existing use case to extend (one line per side) + the
  access-control check.
- **Presentation** — where the datapoint lands (component to mirror + wiring).
- **Seed / demo data** — covered (entity + id + login + demo URL) or the gap +
  smallest seed addition. Always concrete — this is what the demo gets built on.
- **Risks** — bounded-context concerns, perf, genuinely undecidable product
  questions. `N/A` if none — and prefer `N/A` over a bullet that just says
  something is fine/settled. (The bounded-context *check* from Step 4 always runs;
  surface it here only if there's a violation or doubt — not as its own section.)
- **Next steps** — `N/A` unless there's a concrete follow-up.

**Leave out:** a Requirement restatement (the ticket has it), a PR / commit split
(that's *dev breakdown*, a separate artefact), demo steps, and "front-only PR?"
framing. Analysis ≠ planning.
