# Autonomous Live Obsidian Synchronization Rule

## Purpose
Enforces autonomous, live synchronization of engineering milestones, architectural choices, and task tracking directly into the developer's Obsidian vault without requiring manual slash commands.

## Activation Triggers & Protocol
Whenever the agent performs any of the following operations during a coding session:

1. **Git Commit (`on_commit`)**:
   - Immediately after executing a `git commit` command, check `.agents/obsidian-config.json`.
   - If `auto_sync.enabled` is `true` and `auto_sync.on_commit` is `true`:
   - Invoke the `obsidian-auto-sync` skill (Commit Sync) to append the commit hash, commit type, and rationale to `Projects/<ProjectName>/Worklog.md`.

2. **Task / Ticket / Major TODO Lifecycle (`on_todo`)**:
   - When a task, ticket, or milestone TODO is created, resolved, or blocked during development.
   - If `auto_sync.enabled` is `true` and `auto_sync.on_todo` is `true`:
   - Invoke the `obsidian-auto-sync` skill (Task Sync) to update `Projects/<ProjectName>/Tasks.md`.

3. **Architectural & Design Decisions (`on_decision`)**:
   - When selecting a library/framework, establishing a design token standard, designing an API contract, or rejecting an architectural alternative.
   - If `auto_sync.enabled` is `true` and `auto_sync.on_decision` is `true`:
   - Invoke the `obsidian-auto-sync` skill (Decision Sync) to record a structured ADR in `Projects/<ProjectName>/Decisions.md`.

## Operational Guardrails
- **Silent Check**: If `.agents/obsidian-config.json` is absent or `auto_sync.enabled` is `false`, proceed normally with development without failing or interrupting the user.
- **Dynamic Quick Links**: Ensure `Projects/<ProjectName>/Overview.md` contains links under `## Quick Links` to `Worklog.md`, `Tasks.md`, and `Decisions.md`.
- **Concurrency Safety**: Always read note content and capture `etag` first, editing with `obsidian_edit_note` to avoid clobbering concurrent edits in the Obsidian desktop application.
