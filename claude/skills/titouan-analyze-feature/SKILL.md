---
name: titouan-analyze-feature
description: Produce a synthetic, build-ready technical analysis of an Inato marketplace ticket/feature before coding. Covers the data model (how data is stored), which existing Repository method to reuse or generalize (Finder only for cross-aggregate reads, N+1 not allowed), and which existing use case to extend. Use when the user shares a Notion ticket or feature spec and asks for an analysis, feasibility, data-model, repo/finder, or use-case breakdown ahead of implementation (not the dev breakdown / PR split).
---

# Analyze an Inato feature before building it

Turn a ticket into a synthetic, high-level analysis a teammate could start
coding from. The reader wants the conclusion, not your search trail, so keep the
output high-level with no `file:line` refs.

Two rules that carry the whole skill:

1. **Verify against code, not narration.** Never trust what the ticket, the
   user, or a teammate says a flow does. Open the use case and read it. Behavior
   claims are the ones that bite: if the ticket says "opts out", find the actual
   action and check whether it flips a column, deletes the row, or something
   else. A wrong assumption here silently breaks the whole analysis.
2. **Qualify every method with its module.** Write `Pairing.Repository.getAllForSites`,
   `SiteTrialOpportunityInterest.Repository.getAllBySiteIds`, not bare
   `getAllForSites`. The reader should never have to guess which aggregate a
   method lives on.

Back technical decisions with `.claude/doc/` (CLAUDE.md requires it): run the
`find-doc` skill first when the feature touches an unfamiliar domain, a standard
(access control, RSC), or a pattern choice. If no doc covers it, say so.

## Step 0. Read the ticket, set status

Fetch the Notion ticket to understand the actors (site / org-admin / sponsor),
what they see, the values, and any per-entity repetition ("for each site…", the
N+1 smell for Step 2). This feeds your understanding only. Don't restate the
requirement in the output; the reader has the ticket. Read the comment threads
in full with `notion-get-comments` (the page view truncates them) and resolve
who decided what, with names.

On the same fetch, fix `Assignee` and `Status` with one `notion-update-page`
`update_properties` call (do it automatically, don't ask):

- No `Assignee`: assign the current user. Get the id from `notion-fetch` id
  `"self"` (session email `titouan.creach@inato.com`), set `Assignee` to
  `["<userId>"]`.
- `Status` not `Analysing`: set it to `Analysing` (spelled `Analysing`, not
  "Analysis"; `Started at` auto-stamps).

Skip whichever is already correct. If the user says to analyze locally or not to
move the ticket, skip the status change entirely.

## Step 1. Data points (how the data is stored)

Trace every value the feature reads or writes to storage:

- Domain entity in `packages/marketplace-domain/src/domain/<Entity>/type.ts`.
- Drizzle table + columns in
  `application/persistence/Drizzle<Entity>Repository/drizzleTable.ts`. Note
  whether a field is a dedicated column or inside the `data` JSONB blob; it
  changes how it filters and indexes (JSONB path query vs column index).
- The join or overlap: which id on A matches which id on B. Name the exact id
  types (`member.primarySpecialty: TherapeuticArea.Id` vs
  `diseaseArea.therapeuticAreaId`). Decide from the existing convention. Don't
  punt a determinable choice to product; reserve open questions for what is
  genuinely undecidable from code.

Output: a table of value, entity, table.column (or `data.path`), join id.

## Step 2. Reads: reuse a Repository method, or add a Finder?

The line is the number of tables, not query complexity:

- **Repository**: one aggregate, one table. Returns aggregates and read helpers
  on that table (`count`/`exists`, `WHERE id IN (…)` batches, `GROUP BY` on its
  own table). Batching and grouping on one table stay here. Lives in
  `domain/<Entity>/Repository/`.
- **Finder**: a read projection that joins across aggregates/tables, or maps to
  no single aggregate. Lives in `domain/<X>/Finder/` +
  `application/persistence/Drizzle<X>Finder/`, registered in the context's
  `liveLayer`. Example: `SiteTrialsToDiscoverFinder`. A batch or `GROUP BY` alone
  does not make it a Finder.

Decide in order, and prefer reuse:

1. **Reuse** an existing Repository method as is.
2. **Generalize** one: turn `id` into `ids`, drop a too-narrow SQL filter, so one
   batched call serves both the single-entity and the list/org view. Still a
   Repository.
3. **Add a Finder** only for a genuine cross-aggregate read.

**Prefer one broad read + categorize in memory over several filtered methods**
when the items you need span the filter boundary. If a feature needs both the
rows a filtered read returns and the rows it excludes (for example open pairings
plus the closed/declined ones it filters out), generalize the filtered read into
a broad one (`getAllOpenForSites` into `getAllForSites`) and let one in-memory
function sort every row into its section. One read, one place decides, and the
sectioning is pure domain logic you can test without SQL. Check the callers of
the method you widen: if it has one caller, replace it; leave no dead filtered
method behind.

**N+1 is not acceptable** until the user says otherwise: never serve a list/org
view with a per-entity call in a loop. A secondary lookup over a small bounded
set (the sites of one org, then filter in memory) is not an N+1; judge by
cardinality and say so. Estimate the rows the query touches.

## Step 3. Where the data gets served from

- Check whether the value is already shown elsewhere. Trace existing usages up to
  the UI and reuse the component and its data path if one renders it.
- Find the page's RSC server component and the use case(s) it calls.
- Extend an existing use case, don't add one: "add `{ piCount, subICount }` to
  `getOpportunityPageDataForSite`", one line per side (site / org). Spec a new
  use case only when nothing fits.
- Access control: extending a use case is already enforced (`Access control: none
  new`). A new entry point names the check for the actor it serves: site-scoped
  `canUserReadSite`, org-scoped `canUserReadOrganization`. Pick the right check,
  don't copy a sibling's weaker `ensureUserIsAuthenticated`. Org-admins are
  covered by auth-time enrichment, so only org-level entry points need an
  explicit org path.

## Step 4. Bounded contexts (a check you run, not a section you write)

Confirm the work sits in one context with no cross-context import
(`packages/marketplace-domain/.dependency-cruiser.js`). Surface it (under Risks)
only on a violation or doubt. If the feature genuinely spans contexts, STOP and
surface the options from `.claude/rules/bounded-contexts.md`.

## Step 5. Seed coverage (can we demo it?)

Local DB and staging run the same populate script with the same ids:
`packages/server/src/scripts/populateDatabase/insertStagingData/` (data under
`data/**`, transitions under `insertData/**`; run via `pnpm server
db:reset-staging` with `POPULATE_STAGING_DB_ENABLED=true`). A seed fix fixes
both, and a localhost demo on seed ids works on staging by swapping the host.

Check whether a seeded entity reaches the exact state the feature needs to be
visible. Read the seed data and transition code, not just the DB.

- **Covered**: name entity + id + login + demo URL, so the demo can be written now.
- **Gap**: name the smallest seed addition that closes it. Usually the first work item.

## Output shape

Write a verdict sheet, not a report. Every section states a decision as a
labelled noun phrase (`Generalize getAllOpenForSites to getAllForSites`, `Access
control: none new`), plus at most one short clause of justification. Short
bullets and small tables, no prose, no `file:line`, no code dumps. Qualify method
names (`Module.Repository.method`). A method signature is the contract and is
fine; the SQL body is not.

For a real design fork (one read + fold vs several methods, extend vs new use
case), write a short pro/cons and state the choice. Use `✅` and `⚠️` lines, one
clause each, and end with the pick.

Don't write a non-decision: anything you considered and found fine ("no new
Finder", "no N+1", "no cross-context import", "settled", "confirmed"). You name
only what you ARE doing. The one exception is a negative that changes a build
decision (a perf risk you ruled out, with the reason).

Write for coworkers who know the codebase. Never explain Repository-vs-Finder,
bounded contexts, RSC, or access-control enrichment. Match the reader's plain,
casual voice ("we need every interest row", "otherwise they leak into discover").
No em dashes. No abbreviations ("opportunity", not "opp"). No AI-tell filler
("surface", "leverage", "seamless"). Plain code operators (`&&`, `||`), never
logic symbols.

Your first draft runs about twice too long. Write it, then halve it: cut
build-up, asides, meta-commentary; fragments over sentences.

The analysis is only these sections:

- *(optional one-liner)*: if it's a sibling of recent work, one sentence pointing
  at it ("Sibling of AST-2144, same placement, same shaped use cases.").
- **Data points**: table + join resolved inline in the match column.
- **Repository**: reuse / generalize / Finder decision + a row estimate. Add the
  pro/cons block here when there's a real fork.
- **Use cases**: which to extend (one line per side) + the access-control check.
- **Presentation**: where the datapoint lands (component to mirror + wiring).
- **Seed / demo data**: covered (entity + id + login + demo URL) or the gap +
  smallest seed addition. Always concrete.
- **Risks**: only real ones. A risk blocks, needs a decision, or is deferred. For
  each, state what it is, why it's hard, and the decision with its owner ("big
  refactor, don't do it now, tag product"; "org collapse rule agreed with
  Zhenni"). Not hypotheticals like "could be labelled differently one day". `N/A`
  if none.
- **Next steps**: `N/A` unless there's a concrete follow-up.

**Leave out:** a requirement restatement, a PR / commit split (that's the dev
breakdown), and demo steps. Analysis is not planning.
