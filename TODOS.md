# Project Backlog & Risk Mitigation Tasks

Active task ledger derived from Council risk assessment and product roadmap.

---

## 🛠️ High Priority / Risk Mitigations

- [ ] **Define Threshold of Significance for Auto-Sync**
  - *Context*: Prevent vault spam and note clutter from micro-commits, lint fixes, or trivial typo edits.
  - *Mitigation*: Add explicit heuristics to `rules/obsidian-live-sync.md` and `skills/obsidian-rag/obsidian-auto-sync/SKILL.md` defining what qualifies as a meaningful milestone commit and true ADR.

- [ ] **Actionable Missing-MCP Detection & Guidance**
  - *Context*: If a user runs `/obsidian-setup` or triggers live-sync without the Obsidian MCP server running, provide immediate actionable diagnosis.
  - *Mitigation*: Implement early-exit checks in `/obsidian-setup` and runtime skills with clear setup steps.

- [ ] **Concurrency Conflict Backoff & Hardening**
  - *Context*: Prevent silent data loss or dropped writes when notes are concurrently opened or edited in Obsidian desktop.
  - *Mitigation*: Verify and harden the 412 etag retry mechanism with exponential backoff across all write handlers.

- [ ] **Automated Drift Detection & Reconciliation**
  - *Context*: Prevent codebase reality and vault overview from diverging over time.
  - *Mitigation*: Expand `/obsidian-init` drift checks for newly added dependencies, tech stack changes, and branch updates.

---

## ✅ Completed

- [x] **Autonomous Live Obsidian Sync Engine**
  - Implemented `obsidian-auto-sync` skill, `rules/obsidian-live-sync.md`, dynamic `Overview.md` quick linking, and multi-platform installer rule linking. *(2026-09-06)*
