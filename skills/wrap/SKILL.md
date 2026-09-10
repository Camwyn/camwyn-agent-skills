---
name: wrap
description: >
  End-of-day close-out for a coding session. Extends `handoff`: snapshots repo
  state, distills the day's working docs (.ai/, .scratch/) into the Obsidian
  vault Overview/Tasks/Worklog/Decisions, drains the live-sync queue, writes a
  rolling resume document, and prints where things stand. Trigger with 'wrap',
  'wrap up', 'end of day', 'wrap the session', or /wrap. Never commits, never pushes.
argument-hint: "[what tomorrow's session should focus on]"
model: sonnet
effort: low
---

# Wrap

Close out the current session cleanly so tomorrow starts from a known point and the
Obsidian vault is the faithful record of where the work stands.

`wrap` is `handoff` plus the vault close-out. It follows the **Record Ownership**
boundary in `~/.agents/rules/obsidian-live-sync.md`: the vault is the single source
of truth; `.ai/` and `.scratch/` are transient working docs whose *outcomes* get
distilled here.

## Scope

- **This session's project only.** Resolve it from the repo (`git rev-parse --show-toplevel`,
  then `project_aliases` in `obsidian-config.json`) → `Projects/<Project>/` in the vault.
  Cross-project rollups are the job of `/obsidian-digest`, not `wrap`.
- If arguments were passed, treat them as the focus for tomorrow and shape the resume
  doc's **Goal** and **Next steps** around them.

## Preconditions

- Read `.agents/obsidian-config.json` (repo, then `~/.agents/`). If absent or
  `auto_sync.enabled` is `false`, still produce the resume doc and the summary, but
  skip the vault writes and say so in one line.
- If the `obsidian` MCP is unreachable: do every vault write you can via
  `.agents/pending-sync.json` semantics, note it, and continue. Never block the wrap.
- **Never** run `git commit`, `git add`, or `git push`. `wrap` records; it does not change code or history.

## Steps

### 1. Snapshot

- `git status --porcelain` and current branch. List uncommitted / untracked files
  (**report only** — do not stage or commit).
- Last known test status if it came up this session; otherwise say "not run this session".
- The session's commits today (`git log --since=midnight --oneline`).

### 2. Distill working docs → `Overview.md`

- Read `.ai/` roadmap files and any `.scratch/<feature>/` touched today.
- Read `Projects/<Project>/Overview.md` (capture etag). Update **only** a single
  `## Current Focus` block (create it just under the frontmatter/intro if missing):
  2–5 lines — what's active, what moved today, what's next. Do not rewrite the rest
  of Overview; `obsidian-project-init` owns its structure.
- Reconcile `Projects/<Project>/Tasks.md`: check off or annotate items that closed or
  advanced today. Add newly-surfaced tasks with a dated sub-heading. Keep the tester-bug
  / triage style already in the file.

### 3. Worklog rollup

- Run `obsidian-sync flush "<repo root>"` to drain `.agents/pending-sync.json`.
- Open `Projects/<Project>/Worklog.md` (etag). Fold any raw CLI-appended blocks from
  this session into proper **1-Milestone-per-Rollup** entries per
  `obsidian-live-sync.md` (supporting commits roll up under the milestone; a feature
  completion or major refactor caps the block). Don't merge distinct milestones.

### 4. Decisions

- Any architectural / library / API-contract / rejected-alternative decision made this
  session that isn't yet an ADR → append a structured ADR to
  `Projects/<Project>/Decisions.md` (etag-guarded). Skip routine fixes and renames.

### 5. Resume document

- Invoke the `handoff` skill to generate the document body (its fixed 8-section shape).
  If `handoff` is unavailable, produce those same eight sections inline:
  `Goal` · `Current state` · `Next steps` · `Open questions / blockers` · `Key context` ·
  `Pointers` · `Suggested skills` (drop the temp-file step).
- Write the body to `Projects/<Project>/_Resume.md` via `obsidian_edit_note`
  (operation `replace`, etag-guarded), with a first line `> Wrapped <YYYY-MM-DD HH:mm> — <branch>`.
  This file is **rolling**: each wrap overwrites it.
- Ensure `Overview.md` `## Quick Links` has a `[[_Resume]]` entry.

### 6. Report

Print, in the terminal:

- One line: project, branch, commits today, uncommitted file count.
- What was written to the vault (Overview / Tasks / Worklog / Decisions / _Resume), each a path.
- Anything skipped and why (config gate, MCP down, nothing to distill).
- Uncommitted files, if any, as a plain list — so the user can decide whether to commit before closing.
- If today is **Friday** (or later with no digest this week): one line suggesting `/obsidian-digest`.

## Voice

Calm, factual, no celebration. This is a status write, not a retrospective. Follow
`~/.agents/rules/git-writing.md`. If the day was quiet, say so in a sentence — don't pad.
