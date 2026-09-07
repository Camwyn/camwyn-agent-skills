# Project Backlog & Risk Mitigation Tasks

Active task ledger derived from Council risk assessment and product roadmap.

---

## 🛠️ High Priority / Risk Mitigations

*(All high-priority Council risk mitigation items completed)*

---

## ✅ Completed

- [x] **Automated Drift Detection & Reconciliation**
  - Expanded `obsidian-project-init` with multi-vector drift detection (dependencies, architectural subsystems, companion note links, and git state) and 3-mode non-destructive reconciliation (`operation: "replace"` with `if_match` revision guard). Added live drift awareness to `obsidian-auto-sync` and `rules/obsidian-live-sync.md`. *(2026-09-06)*
- [x] **Actionable Missing-MCP Detection & Guidance**
  - Implemented Section 0 MCP health check in `/obsidian-setup` with copy-pasteable configs for Antigravity, Claude Code, and Cursor across Windows/macOS/Linux, non-blocking queue fallback across all runtime skills, and comprehensive docs in `README.md`. *(2026-09-06)*
- [x] **Concurrency Conflict Backoff & Zero-Data-Loss Replay Queue**
  - Implemented bounded 3-attempt exponential backoff (500ms, 1500ms), fallback persistence to `.agents/pending-sync.json`, automatic queue draining on next sync, and on-demand `/obsidian-flush` manual trigger. *(2026-09-06)*
- [x] **Define Threshold of Significance & 1-Milestone-per-Rollup**
  - Added semantic commit filtering heuristics (`milestones_only` vs `all`) and the "1 Milestone per Rollup" lifecycle with 2-hour scope boundaries in `rules/obsidian-live-sync.md`, `skills/obsidian-rag/obsidian-auto-sync/SKILL.md`, and configuration schemas. *(2026-09-06)*
- [x] **Autonomous Live Obsidian Sync Engine**
  - Implemented `obsidian-auto-sync` skill, `rules/obsidian-live-sync.md`, dynamic `Overview.md` quick linking, and multi-platform installer rule linking. *(2026-09-06)*
