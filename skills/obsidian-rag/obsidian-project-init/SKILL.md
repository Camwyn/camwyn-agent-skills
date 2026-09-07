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

## 3. Branch B: Project Note Already Exists (Automated Drift Detection & Reconciliation)

If a matching project note is found (e.g. `Projects/<ProjectName>/Overview.md` or single-file `Projects/<ProjectName>.md`):

1. **Read Existing Note**:
   - Call `obsidian_read_note` on the matched note to inspect frontmatter, current content, and capture `etag`.

2. **Multi-Vector Drift Analysis**:
   Perform automated drift inspection across 4 vectors:

   - **Vector 1: Tech Stack & Dependencies**:
     - Inspect project manifests (`package.json`, `pyproject.toml`, `Cargo.toml`, `composer.json`, `go.mod`, script files).
     - Compare detected technologies against `tech_stack` frontmatter and `## Architecture & Tech Stack`.
     - Detect: newly added dependencies, removed packages, or framework upgrades.

   - **Vector 2: Subsystems & Architectural Directories**:
     - Scan top-level workspace directories (filtering out vendor/build directories like `node_modules`, `.git`, `vendor`, `dist`, `.gemini`).
     - Compare against documented subsystems in `Overview.md`.
     - Detect: new architectural components (e.g., newly added `rules/`, `plugins/`, `api/`, `services/`, `packages/`).

   - **Vector 3: Companion Notes & Quick Links**:
     - Check if companion notes exist in `Projects/<ProjectName>/`:
       - `Decisions.md` (ADR log)
       - `Worklog.md` (Engineering worklog)
       - `Tasks.md` (Tasks and backlog ledger)
     - Check `## Quick Links` in `Overview.md`.
     - Detect: missing companion notes or missing wiki-links `[[Projects/<ProjectName>/...]]`.

   - **Vector 4: Repository & Git State**:
     - Compare current git branch, remote URL (`git remote get-url origin`), and workspace path against frontmatter `repo_path` and status.

3. **Present Drift Audit Matrix**:
   If ANY drift is detected, present a structured audit table to the user:

   ```markdown
   ### 🔍 Obsidian Project Drift Detected: [<ProjectName>]

   | Vector | Workspace Reality | Obsidian Note (`Overview.md`) | Status |
   |---|---|---|---|
   | **Tech Stack** | `[<found_in_repo>]` | `[<found_in_note>]` | ⚠️ Outdated / New additions |
   | **Subsystems** | `[<found_subsystems>]` | `[<documented_subsystems>]` | ⚠️ Undocumented directories |
   | **Quick Links**| `[<existing_companion_notes>]` | `[<linked_in_quick_links>]` | ⚠️ Missing wiki-links |
   | **Git / Branch** | `<current_branch>` | `<documented_state>` | ℹ️ Metadata update |
   ```

4. **Reconciliation Options (User Selection)**:
   Offer 3 non-destructive options:

   - **Option 1: Surgical Non-Destructive Reconciliation (Recommended)**:
     - Surgically update `tech_stack` in YAML frontmatter.
     - Append or update new subsystems under `## Architecture & Tech Stack`.
     - Populate missing wiki-links under `## Quick Links` to point to `Decisions.md`, `Worklog.md`, and `Tasks.md`.
     - **Preserve all custom descriptions, manual notes, and user text byte-for-byte**.
     - Call `obsidian_edit_note` with `operation: "replace"` and `if_match: "<etag>"`.
   - **Option 2: Append Drift Audit Log**:
     - Preserve existing overview note exactly as-is.
     - Append a dated audit entry under `## Drift & Sync Audit` documenting the findings.
   - **Option 3: Keep As-Is**:
     - Leave Obsidian untouched; load existing note into active context.

5. **Reconciliation Receipt**:
   Emit a clean receipt upon completion:
   > 🔄 **Obsidian Project Reconciled**: Updated `Overview.md` for `<ProjectName>` (Tech stack + subsystems + quick links synchronized).

---

## 4. Error Handling & Guardrails

- **MCP Server Missing / Unreachable**: If `obsidian` MCP tools (`obsidian_search_vault`, `obsidian_create_note`, etc.) are not available, halt and advise the user to run `/obsidian-setup` or configure the `obsidian-mcp` server in their agent MCP settings.
- **Vault Not Connected / Missing**: If the configured vault is unreachable, call `obsidian_list_vaults` and prompt the user to pick an active vault.
- **Etag Conflict on Edit**: If `obsidian_edit_note` returns a 412/etag mismatch, execute bounded 3-attempt backoff (500ms, 1500ms). If all attempts fail, queue payload to `.agents/pending-sync.json` for later flush.
- **Never Overwrite Blindly**: Never replace entire note content without preserving existing non-metadata text written by the user. Always use `if_match` revision guards.
