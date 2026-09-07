---
name: obsidian-auto-sync
description: >
  Autonomous, event-driven live synchronization engine that records commits to Worklog.md,
  tickets/TODOs to Tasks.md, and architectural choices to Decisions.md, while dynamically
  linking them in Projects/<ProjectName>/Overview.md.
---

# Obsidian Auto-Sync Engine

Autonomously records repository milestones, tasks, and architectural decisions into your central Obsidian knowledge vault, maintaining a structured, living record of project evolution without requiring manual user commands.

---

## 1. Trigger Conditions & Configuration Gate

Before executing any sync action, read `.agents/obsidian-config.json`:

1. **Verify Global Switch**:
   - If `auto_sync.enabled` is `false` or missing, abort silently.
2. **Verify Event Trigger**:
   - For commits: verify `auto_sync.on_commit == true`
   - For tasks/TODOs: verify `auto_sync.on_todo == true`
   - For decisions: verify `auto_sync.on_decision == true`
3. **Resolve Vault**:
   - Use `default_vault` from `.agents/obsidian-config.json` (e.g. `<VaultName>`).
4. **Resolve Project Name**:
   - Use repository name or root folder name (`<ProjectName>`). Target folder is `Projects/<ProjectName>/`.

---

## 2. Dynamic `Overview.md` Link Injection

Whenever writing to `Worklog.md`, `Tasks.md`, or `Decisions.md`:

1. **Check if `Projects/<ProjectName>/Overview.md` exists**:
   - Call `obsidian_read_note` on `Projects/<ProjectName>/Overview.md`.
   - If missing, bootstrap it via `obsidian-project-init` template.
2. **Ensure Quick Links Section Contains Target Notes**:
   - Under `## Quick Links`, verify links exist:
     - `[[Projects/<ProjectName>/Decisions|Decisions Log]]`
     - `[[Projects/<ProjectName>/Worklog|Worklog]]`
     - `[[Projects/<ProjectName>/Tasks|Tasks & Backlog]]`
   - If any link is missing, append it under `## Quick Links` via safe `etag` edit.

---

## 3. Sync Handlers

### A. Commit Sync (`Worklog.md`)
Triggered when the agent executes a git commit:

1. **Significance Evaluation**:
   - Check `auto_sync.filters.commit_level` in `.agents/obsidian-config.json` (defaults to `"milestones_only"`).
   - If `"milestones_only"`:
     - Allow: `feat:`, `refactor:`, breaking changes, major skill/rule additions, or architectural migrations.
     - Silently skip: `style:`, `lint:`, minor typos (`docs(typo):`), temp debug logs, or minor test bumps.

2. **The "1 Milestone per Rollup" Algorithm**:
   Every entry in `Worklog.md` represents **strictly one milestone**:
   - Call `obsidian_read_note` on `Projects/<ProjectName>/Worklog.md`.
   - Inspect the latest `### [YYYY-MM-DD HH:MM]` block.
   - **Start New Milestone Block** if:
     - The incoming commit is a milestone commit (`feat:`, major refactor, completed ticket).
     - OR the latest block is already capped with a milestone.
     - OR $>2$ hours have elapsed (`rollup_window_hours`) or functional scope changed.
   - **Rollup Supporting Commit** if:
     - The incoming commit is an incremental supporting commit (`chore:`, `test:`, minor `refactor:`) building toward an active milestone.
     - Append to the active block's `- **Commits**:` bullet list.

3. **Target Note**: `Projects/<ProjectName>/Worklog.md`
4. **Initial Scaffolding** (if note does not exist):
   ```markdown
   ---
   title: "<ProjectName> - Worklog"
   type: worklog
   tags:
     - project/worklog
     - changelog
   project: "[[Projects/<ProjectName>/Overview|<ProjectName>]]"
   ---

   # <ProjectName> — Engineering Worklog

   Chronological record of commits, milestones, and implementation progress.

   ---
   ```
5. **Milestone Rollup Entry Format**:
   ```markdown
   ### [YYYY-MM-DD HH:MM] <Milestone Title>
   - **Milestone**: 🏁 <1-sentence summary of the milestone achieved>
   - **Commits (<N>)**:
     - `<short_hash>` - <commit subject>
   - **Key Files**: `<file1>`, `<file2>`
   ```

### B. Task / Ticket Sync (`Tasks.md`)
Triggered when a task, ticket, or major TODO is created, updated, or marked completed in session:

1. **Target Note**: `Projects/<ProjectName>/Tasks.md`
2. **Initial Scaffolding** (if note does not exist):
   ```markdown
   ---
   title: "<ProjectName> - Tasks & Backlog"
   type: tasks
   tags:
     - project/tasks
     - backlog
   project: "[[Projects/<ProjectName>/Overview|<ProjectName>]]"
   ---

   # <ProjectName> — Tasks & Backlog

   Live ledger of active, completed, and backlog items.

   ---
   ```
3. **Append or Update Entry**:
   ```markdown
   ### [YYYY-MM-DD] <Task Title>
   - **Status**: `[Pending | In Progress | Done]`
   - **Context**: <Brief description of the problem, ticket requirement, or blocker>
   - **Resolution / Next Steps**: <What was completed or what remains to be done>
   ```

### C. Decision Sync (`Decisions.md`)
Triggered when an architectural choice, dependency selection, or styling decision is finalized:

1. **Target Note**: `Projects/<ProjectName>/Decisions.md`
2. **Initial Scaffolding** (if note does not exist):
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
3. **Append ADR**:
   ```markdown
   ### ADR-[YYYYMMDD-HHMM]: <Descriptive Title>
   - **Date**: <YYYY-MM-DD>
   - **Status**: Accepted
   - **Context**: <1-2 sentences on what problem or tradeoff necessitated this decision>
   - **Decision**: <Clear statement of the chosen architecture, library, pattern, or rule>
   - **Rationale**: <Why this option was selected, referencing performance, DX, simplicity, or constraints>
   - **Rejected Alternatives**:
     - *<Alternative 1>*: <Why it was rejected>
     - *<Alternative 2>*: <Why it was rejected>
   ```

---

## 4. Concurrency & Conflict Protection

All updates MUST execute through this safe loop:
1. `obsidian_read_note`: retrieve existing markdown content and current `etag`.
2. Format the new block and append/update target section.
3. `obsidian_edit_note`: supply `path`, updated `content`, and captured `etag`.
4. **On 412 Precondition Failed**:
   - Re-read note via `obsidian_read_note` to get fresh content.
   - Re-apply entry to latest content.
   - Retry `obsidian_edit_note`.

---

## 5. Session Confirmation

Emit a compact, unobtrusive receipt in conversation:
> 🔄 **Obsidian Live Sync**: Recorded commit `[<short_hash>]` to `Projects/<ProjectName>/Worklog.md`
