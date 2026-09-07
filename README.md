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
├── rules/                         # Autonomous agent behavioral rules
│   └── obsidian-live-sync.md      # Auto-sync on commits, tasks, and decisions
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
        ├── obsidian-decision-sync/# Concurrency-safe ADR decision capture
        │   └── SKILL.md
        └── obsidian-auto-sync/    # Autonomous commit, task, and decision logger
            └── SKILL.md
```

---

## 🧠 Obsidian Knowledge Base Suite (`skills/obsidian-rag/`)

Bi-directional sync, RAG grounding, and structured Architectural Decision Records (ADRs) using Obsidian as persistent agent memory.

| Skill | Trigger / Command | Description |
|---|---|---|
| **[`obsidian-setup`](skills/obsidian-rag/obsidian-setup/SKILL.md)** | `/obsidian-setup` | Interactive setup wizard. Discovers available vaults, sets default vault preferences, validates folder structure (`Projects/`, `System/`), and configures autonomous live-sync. |
| **[`obsidian-project-init`](skills/obsidian-rag/obsidian-project-init/SKILL.md)** | `/obsidian-init` | Scans vault for current repo, initializes `Projects/<Name>/Overview.md` (with Mermaid maps), `Dashboard.canvas` visual boards, and `Decisions.md`. Supports git worktrees, organization namespaces, and 4-vector drift reconciliation. |
| **[`obsidian-rag-grounding`](skills/obsidian-rag/obsidian-rag-grounding/SKILL.md)** | `/obsidian-rag` | Ingests project overview, recent ADRs, and system guidelines with cascading project overrides to ground creative, UI, and coding tasks. |
| **[`obsidian-decision-sync`](skills/obsidian-rag/obsidian-decision-sync/SKILL.md)** | `/obsidian-decision` | Formats choices into structured ADRs (*Chosen, Rationale, Rejected Alternatives*) with automated superseding detection and bidirectional links. |
| **[`obsidian-auto-sync`](skills/obsidian-rag/obsidian-auto-sync/SKILL.md)** | Autonomous / `/obsidian-flush` | Automatically records commits to `Worklog.md` (with 1,000-line milestone rotation), tickets to `Tasks.md`, and ADRs to `Decisions.md` with zero-data-loss replay queue. |

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

### 🔌 Prerequisites (Obsidian MCP Server)

The Obsidian Suite communicates with your local Obsidian vault via Model Context Protocol (MCP) using [`obsidian-mcp`](https://github.com/StevenStavrakis/obsidian-mcp).

Ensure your agent or IDE has the `obsidian` MCP server configured:

#### Antigravity IDE
Add to `~/.gemini/config/mcp_config.json`:
- **Windows**:
  ```json
  {
    "mcpServers": {
      "obsidian": {
        "command": "cmd.exe",
        "args": [
          "/c",
          "npx",
          "-y",
          "obsidian-mcp",
          "serve",
          "--vault",
          "<vault_name>=<path_to_vault>"
        ]
      }
    }
  }
  ```
- **macOS / Linux**:
  ```json
  {
    "mcpServers": {
      "obsidian": {
        "command": "npx",
        "args": [
          "-y",
          "obsidian-mcp",
          "serve",
          "--vault",
          "<vault_name>=<path_to_vault>"
        ]
      }
    }
  }
  ```

#### Claude Desktop / Claude Code
Add to `claude_desktop_config.json`:
```json
{
  "mcpServers": {
    "obsidian": {
      "command": "npx",
      "args": [
        "-y",
        "obsidian-mcp",
        "serve",
        "--vault",
        "<vault_name>=<path_to_vault>"
      ]
    }
  }
}
```
*(On Windows, use `"command": "cmd.exe"` with `"args": ["/c", "npx", ...]`)*.

#### Cursor
Under **Cursor Settings > Features > MCP Servers**, add a new server:
- **Name**: `obsidian`
- **Type**: `command`
- **Command**: `npx -y obsidian-mcp serve --vault <vault_name>=<path_to_vault>`

---

### ⚙️ Post-Install Configuration

Once installed, configure your Obsidian vault preferences:

1. **Interactive Wizard (Recommended)**:
   In any agent chat session, run:
   ```text
   /obsidian-setup
   ```
   The wizard will discover available vaults via the Obsidian MCP server, prompt you to select your default vault, verify folder structure (`Projects/`, `System/`), and bootstrap foundational system directives (`Tone and Voice.md`, `Design Tokens.md`, `Architecture Principles.md`).

2. **Manual / Headless Configuration**:
   The installer creates a local configuration file at:
   - `~/.agents/obsidian-config.json`

   You can open this file and set `"default_vault"` directly to your preferred vault name without modifying any repository files or git-tracked skills.

---

## 🛠️ Adding New Skills

1. Add your skill folder anywhere under `skills/` (either flat or grouped inside a suite folder like `skills/my-suite/my-skill/`).
2. Include a `SKILL.md` file with standard YAML frontmatter.
3. Run `./install.ps1` to link it to your agent skills folder.
4. Commit your changes to Git.

---

## 📄 License

MIT License. See [LICENSE](LICENSE) for details.
