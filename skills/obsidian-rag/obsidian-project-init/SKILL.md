---
name: obsidian-project-init
description: >
  Scan Obsidian vault for the current project, initialize canonical project notes if missing,
  or detect drift and prompt for non-destructive updates if they already exist.
  Use when dropping into an existing codebase, kicking off a new project, or running /obsidian-init.
---

# Obsidian Project Init & Sync

Connects the active codebase to your central Obsidian knowledge vault (resolved from `default_vault` in `.agents/obsidian-config.json`). Discovers project identity, checks if project documentation exists in Obsidian, bootstraps missing notes with structured templates, or detects drift and prompts for non-destructive updates.

---

## 1. Discovery & Environment Detection

When triggered:

1. **Resolve Vault Target**:
   - Check `.agents/obsidian-config.json` for `default_vault` (e.g. resolve `<VaultName>`).
   - If unsure, missing, or on error, call `obsidian_list_vaults` to confirm available vaults.

2. **Inspect Current Codebase Context**:
   - **Project Name**: Base directory name, `name` in `package.json` / `pyproject.toml` / `Cargo.toml`, or git repository name.
   - **Tech Stack**: Detected languages, frameworks, major dependencies.
   - **Repo Status**: Git remote URL, current branch, brief summary of repository purpose.

3. **Search Obsidian Vault**:
   - Call `obsidian_search_vault`:
     - `vault`: `"<VaultName>"`
     - `query`: `"<ProjectName>"`
     - `mode`: `"filename"` (and fallback to `"content"` with `scope: "Projects"`)

---

## 2. Branch A: Project Does NOT Exist in Obsidian (Bootstrap)

If no note matches the project name under `Projects/`:

1. **Create Project Directory**:
   - Call `obsidian_create_directory`:
     - `vault`: `"<VaultName>"`
     - `path`: `"Projects/<ProjectName>"`

2. **Initialize `Projects/<ProjectName>/Overview.md`**:
   - Call `obsidian_create_note` with the following template:

```markdown
---
title: "<ProjectName>"
type: project
tags:
  - project
  - active
tech_stack:
  - <tech_1>
  - <tech_2>
created_at: <YYYY-MM-DD>
status: active
repo_path: "<relative_or_git_url>"
---

# <ProjectName>

## Overview
<1-2 paragraph description of the project's purpose, domain, and primary goals>

## Architecture & Tech Stack
- **Languages & Frameworks**: <Languages/Frameworks>
- **Core Dependencies**: <Key libraries>
- **Key Subsystems**:
  - `src/...`: <Brief role>

## Voice, Tone & Design Principles
- **Tone & Voice**: <Key tone rules for UI/copy (overrides global `System/Tone and Voice.md` if specified)>
- **Design Tokens**: <Key styling/design system rules (overrides global `System/Design Tokens.md` if specified)>

## Quick Links
- Repository: `<RepoPath>`
- Decisions: [[Projects/<ProjectName>/Decisions|Decisions Log]]
- Optional Project Overrides:
  - [[Projects/<ProjectName>/Tone and Voice|Custom Voice & Tone]] *(if overriding global)*
  - [[Projects/<ProjectName>/Design Tokens|Custom Design Tokens]] *(if overriding global)*
```

3. **Initialize `Projects/<ProjectName>/Decisions.md`**:
   - Call `obsidian_create_note`:

```markdown
---
title: "<ProjectName> - Decision Log"
type: decision-log
tags:
  - project/decisions
  - adr
project: "[[Projects/<ProjectName>/Overview|<ProjectName>]]"
---

# <ProjectName> — Architectural Decision Records (ADRs)

This log records significant architectural, voice, styling, and structural choices.

---
```

4. **Confirm to User**:
   - Emit a clean summary of the newly created Obsidian notes and link them:
     - `Projects/<ProjectName>/Overview.md`
     - `Projects/<ProjectName>/Decisions.md`

---

## 3. Branch B: Project Note Already Exists (Drift Detection)

If a matching project note is found (e.g. `Projects/<ProjectName>/Overview.md` or single-file `Projects/<ProjectName>.md`):

1. **Read Existing Note**:
   - Call `obsidian_read_note` on the matched note to inspect frontmatter, tech stack, and overview.

2. **Compare with Current Codebase (Drift Check)**:
   - Check if new dependencies or frameworks were added (e.g., added Tailwind, Prisma, FastAPI).
   - Check if git remote or repository path has changed.
   - Check if status is outdated (e.g., marked `planning` but actively built).

3. **Prompt User with Delta Options (Non-Destructive)**:
   - If drift is detected:
     > **Project Note Found**: `Projects/<ProjectName>/Overview.md`
     > **Detected Drift**:
     > - Tech stack in repo: `[<new_tech>]` (missing in Obsidian)
     > - Branch/remote: `<current_branch>`
     > 
     > Would you like to:
     > 1. **Merge updates** — Update frontmatter and tech stack while preserving all custom notes.
     > 2. **Append update log** — Add a dated status entry under `## Sync Updates`.
     > 3. **Keep as-is** — Load existing note into session context without modifying Obsidian.
   - If user chooses to merge:
     - Use `obsidian_edit_note` with the `etag` from `obsidian_read_note` to safely update only the relevant frontmatter / sections without clobbering custom user writing.

---

## 4. Error Handling & Guardrails

- **Vault Not Connected / Missing**: If the configured vault is unreachable, call `obsidian_list_vaults` and prompt the user to pick an active vault.
- **Etag Conflict on Edit**: If `obsidian_edit_note` returns a 412/etag mismatch, re-read the note immediately, re-calculate diff, and retry the edit.
- **Never Overwrite Blindly**: Never replace entire note content without preserving existing non-metadata text written by the user.
