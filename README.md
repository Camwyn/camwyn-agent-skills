# Camwyn Agent Skills

> A curated collection of custom AI agent skills for Antigravity, Claude Code, Cursor, and Gemini CLI, enabling persistent knowledge management, IDE-wide telemetry, and advanced workflow automation.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

---

## 🧭 Overview

**`camwyn-agent-skills`** is the central, unified repository for all custom AI agent skills, plugins, and workflow suites created by Camwyn.

All skills in this repository can be installed or live-linked (via NTFS Directory Junctions on Windows or symlinks on Unix) directly into your workspace's `.agents/skills/` or global `~/.gemini/config/skills/` directory.

---

## 📦 Skills Directory

### 🧠 Obsidian Knowledge Base Suite
Bi-directional sync, RAG grounding, and structured Architectural Decision Records (ADRs) using Obsidian as persistent agent memory.

| Skill | Trigger / Command | Description |
|---|---|---|
| **[`obsidian-setup`](skills/obsidian-setup/SKILL.md)** | `/obsidian-setup` | Interactive setup wizard. Discovers available vaults, sets default vault preferences, validates folder structure (`Projects/`, `System/`), and bootstraps global voice/design/architecture notes. |
| **[`obsidian-project-init`](skills/obsidian-project-init/SKILL.md)** | `/obsidian-init` | Scans vault for current repo, initializes `Projects/<Name>/Overview.md` + `Decisions.md`, or detects drift and prompts for non-destructive merges if present. |
| **[`obsidian-rag-grounding`](skills/obsidian-rag-grounding/SKILL.md)** | `/obsidian-rag` | Ingests project overview, recent ADRs, and system guidelines with cascading project overrides to ground creative, UI, and coding tasks. |
| **[`obsidian-decision-sync`](skills/obsidian-decision-sync/SKILL.md)** | `/obsidian-decision` | Formats choices into structured ADRs (*Chosen, Rationale, Rejected Alternatives*) and syncs via safe `etag` concurrency. |

### 📊 Telemetry & Audit Suite
Tools for inspecting agent execution, tracking skill utilization, and optimizing context.

| Skill | Trigger / Command | Description |
|---|---|---|
| **[`audit-skills`](skills/audit-skills/SKILL.md)** | `/audit-skills` | Analyzes centralized Antigravity transcript logs across all workspaces to report top used skills, dormant skills, and zero-run unused skills. |

---

## 🚀 Installation & Live Linking

### Automated Live Linking (Recommended)

Running the install script creates live directory links (junctions on Windows, symlinks on Unix). Any changes you make in this repository are immediately active in your agent sessions with zero copying!

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

## 🛠️ Adding a New Skill

To add a new skill to this repository:
1. Create a new directory under `skills/<your-skill-name>/`.
2. Add a `SKILL.md` file with YAML frontmatter:
   ```markdown
   ---
   name: your-skill-name
   description: Brief description of what this skill does and when to invoke it.
   ---

   # Your Skill Title

   Instructions for the agent...
   ```
3. Run `./install.ps1` to link the new skill into `.agents/skills/`.
4. Commit your changes:
   ```bash
   git add .
   git commit -m "feat: add <your-skill-name> skill"
   ```

---

## 📄 License

MIT License. See [LICENSE](LICENSE) for details.
