# Project Backlog & Risk Mitigation Tasks

Active task ledger derived from Council risk assessment and product roadmap.

---

## 🛠️ High Priority / Risk Mitigations

*(All high-priority tasks and risk mitigations completed)*

---

## ✅ Completed

- [x] **Standalone CLI / CI Sync Companion (`obsidian-sync`)**
  - Engineered zero-dependency command-line companion tool (`bin/obsidian-sync.ps1`, `bin/obsidian-sync.cmd`, and `bin/obsidian-sync`) supporting `status` (connectivity, configuration, pending queue, vault note counts), `audit` (link integrity and companion health), `digest` (weekly/monthly rollups), and `flush` (drain pending queue). Integrated automatic deployment into `$HOME/.agents/bin` via `install.ps1` and `install.sh`, added PATH guidance, and documented CI/CD usage in `README.md`. *(2026-09-07)*
- [x] **Automated Weekly / Monthly Rollup Digest Generator (`obsidian-digest` / `/obsidian-digest`)**
  - Implemented multi-project executive briefing engine consolidating milestones, closed tasks, and architectural decisions (ADRs) across all active codebases into weekly (`YYYY-Www`), monthly (`YYYY-MM`), or custom rolling day-window digests stored in `Areas/00 Camwyn & Co/Digests/`. Added native PowerShell engine (`scripts/generate-digest.ps1`), cross-platform shell wrapper (`scripts/generate-digest.sh`), reactive Dataview recent activity rollups, and `/schedule` automation support. *(2026-09-07)*
- [x] **Vault Health & Link Integrity Auditor (`obsidian-vault-audit` / `/audit-vault`)**
  - Created multi-vector diagnostic auditor scanning broken wikilinks and markdown links, orphan notes, stub notes, frontmatter schemas, and project companion completeness (`Overview`, `Tasks`, `Worklog`, `Decisions`) with automatic companion note scaffolding (`-ScaffoldMissing`). Added native PowerShell engine (`scripts/audit-vault.ps1`), cross-platform shell wrapper (`scripts/audit-vault.sh`), and full suite integration. *(2026-09-07)*
- [x] **Dataview Plugin Schema & Dynamic Query Blocks**
  - Standardized YAML frontmatter schemas across all suite notes (`pillar`, `status`, `tech_stack`, `created_at`, `updated_at`, `tags`) and embedded dynamic Dataview query blocks (DQL) into `Overview.md` (project task aggregation) and `PARA-Index.md` (active projects directory, directives directory, and vault-wide task rollups) with graceful degradation to static markdown tables. Extended configuration schemas in `obsidian-config.json.example` and live config with `"dataview": { "enabled": true, "render_dynamic_queries": true }`. *(2026-09-07)*
- [x] **Native Git Post-Commit Hook Integration**
  - Added standalone `.git/hooks/post-commit` script with cross-platform runners (`scripts/obsidian-post-commit.ps1` and `scripts/obsidian-post-commit.sh`) to queue milestone commits created outside AI agent turns directly into `.agents/pending-sync.json`. Integrated automatic hook installation into `install.ps1` and `install.sh`, documented in `obsidian-auto-sync/SKILL.md` and `README.md`. *(2026-09-07)*
- [x] **Global PARA Map of Content (MOC) & Master Canvas Generator (`obsidian-index`)**
  - Created dedicated `obsidian-index` skill (`/obsidian-index`) compiling an authoritative master Map of Content (`PARA-Index.md`) and interactive 4-quadrant visual spatial board (`PARA-Index.canvas`) connecting all active `Projects/`, `Areas/` directives, `Resources/` reference playbooks, and `Archives/` across the vault. Scaffolding live master index and canvas in the active vault. *(2026-09-06)*
- [x] **PARA & BASB (CODE) Default Vault Architecture**
  - Established Tiago Forte's PARA method (*Projects, Areas, Resources, Archives*) and CODE operating cycle (*Capture, Organize, Distill, Express*) as the default organization across the suite. Updated `obsidian-config.json.example`, `obsidian-setup`, `obsidian-rag-grounding`, `obsidian-project-init`, and `rules/obsidian-live-sync.md`. Scaffolding `Areas/`, `Resources/`, and `Archives/` with foundational directive templates while providing legacy fallbacks for existing vaults. *(2026-09-06)*
- [x] **Multi-Provider Adapter (Local REST API & In-App MCP Connector)**
  - Added support for both headless direct-filesystem MCP (`obsidian-mcp`) and in-app Obsidian community plugins ([Obsidian Local REST API](https://github.com/coddingtonbear/obsidian-local-rest-api) on port 27124 and `obsidian-mcp-plugin`). Implemented multi-provider detection in `/obsidian-setup`, unified provider adapter routing table across runtime skills (`obsidian-auto-sync`, `obsidian-project-init`), extended configuration schemas in `obsidian-config.json.example`, and documented dual setup options in `README.md`. *(2026-09-06)*
- [x] **Visual Vault Dashboard & Canvas Generator**
  - Added automated generation of interactive Obsidian `.canvas` visual boards (`Dashboard.canvas`) in a connected 2x2 project grid and integrated rich Mermaid subsystem architecture maps in `Overview.md`. *(2026-09-06)*
- [x] **Historical Worklog Archiving Policy (1,000-Line Rotation)**
  - Implemented automatic yearly rotation of milestone blocks to `<Project>/Worklog-Archive-<YYYY>.md` when `Worklog.md` exceeds 1,000 lines, retaining recent active milestones with an archive index link. *(2026-09-06)*
- [x] **Multi-Repo & Git Worktree Mapping**
  - Expanded `obsidian-project-init`, `obsidian-auto-sync`, and `rules/obsidian-live-sync.md` to detect git worktrees and organization namespaces, routing commits to worktree-specific notes while preserving parent project architecture and decision links. Added `organization_nesting` and `worktree_support` to configuration schemas. *(2026-09-06)*
- [x] **Automated ADR Lifecycle**
  - Implemented automated detection of superseded architectural decisions during ADR recording, updating prior ADRs to `Status: Superseded by [[#ADR-ID]]` with bidirectional `Supersedes` backlinks in `obsidian-decision-sync` and `obsidian-auto-sync`. *(2026-09-06)*
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
