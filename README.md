# Camwyn Agent Skills

> A curated collection of custom AI agent skills for Antigravity, Claude Code, Cursor, and Gemini CLI, enabling persistent knowledge management, IDE-wide telemetry, and advanced workflow automation.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

---

## 🧭 Overview

**`camwyn-agent-skills`** is the central, unified repository for all custom AI agent skills, plugins, and workflow suites created by Camwyn.

All skills in this repository can be installed or live-linked (via NTFS Directory Junctions on Windows or symlinks on Unix) directly into your workspace's `.agents/skills/` or global `~/.gemini/config/skills/` directory.

---

## 📦 Skills Directory Structure

```
camwyn-agent-skills/
├── README.md
├── LICENSE
├── install.ps1                    # Master recursive installer
├── install.sh                     # Master recursive installer (bash)
│
└── skills/
    ├── audit-skills/              # IDE-wide dual-pass telemetry & skill auditor
    │   └── SKILL.md
    │
    └── obsidian-rag/              # Unified Obsidian Suite
        ├── obsidian-config.json.example
        ├── obsidian-setup/        # Onboarding wizard & vault configuration
        │   └── SKILL.md
        ├── obsidian-project-init/ # Project scanner & note bootstrapper
        │   └── SKILL.md
        ├── obsidian-rag-grounding/# Knowledge base grounding with cascading overrides
        │   └── SKILL.md
        └── obsidian-decision-sync/# Concurrency-safe ADR decision capture
            └── SKILL.md
```

---

## 🧠 Obsidian Knowledge Base Suite (`skills/obsidian-rag/`)

Bi-directional sync, RAG grounding, and structured Architectural Decision Records (ADRs) using Obsidian as persistent agent memory.

| Skill | Trigger / Command | Description |
|---|---|---|
| **[`obsidian-setup`](skills/obsidian-rag/obsidian-setup/SKILL.md)** | `/obsidian-setup` | Interactive setup wizard. Discovers available vaults, sets default vault preferences, validates folder structure (`Projects/`, `System/`), and bootstraps global voice/design/architecture notes. |
| **[`obsidian-project-init`](skills/obsidian-rag/obsidian-project-init/SKILL.md)** | `/obsidian-init` | Scans vault for current repo, initializes `Projects/<Name>/Overview.md` + `Decisions.md`, or detects drift and prompts for non-destructive merges if present. |
| **[`obsidian-rag-grounding`](skills/obsidian-rag/obsidian-rag-grounding/SKILL.md)** | `/obsidian-rag` | Ingests project overview, recent ADRs, and system guidelines with cascading project overrides to ground creative, UI, and coding tasks. |
| **[`obsidian-decision-sync`](skills/obsidian-rag/obsidian-decision-sync/SKILL.md)** | `/obsidian-decision` | Formats choices into structured ADRs (*Chosen, Rationale, Rejected Alternatives*) and syncs via safe `etag` concurrency. |

---

## 📊 Telemetry & Audit Suite (`skills/audit-skills/`)

| Skill | Trigger / Command | Description |
|---|---|---|
| **[`audit-skills`](skills/audit-skills/SKILL.md)** | `/audit-skills` | Analyzes centralized Antigravity transcript logs across all workspaces to report top used skills, dormant skills, and zero-run unused skills. |

---

## 🚀 Installation & Live Linking

Running the install script automatically discovers all skills recursively and creates live directory links (junctions on Windows, symlinks on Unix):

#### Windows (PowerShell)
```powershell
./install.ps1
```

#### macOS / Linux (Bash)
```bash
chmod +x install.sh
./install.sh
```

---

## 🛠️ Adding New Skills

1. Add your skill folder anywhere under `skills/` (either flat or grouped inside a suite folder like `skills/my-suite/my-skill/`).
2. Include a `SKILL.md` file with standard YAML frontmatter.
3. Run `./install.ps1` to link it to your agent skills folder.
4. Commit your changes to Git.

---

## 📄 License

MIT License. See [LICENSE](LICENSE) for details.
