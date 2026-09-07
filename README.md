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
        ├── obsidian-auto-sync/    # Autonomous commit, task, and decision logger
        │   └── SKILL.md
        └── obsidian-index/        # Master PARA Map of Content (MOC) & Canvas generator
            └── SKILL.md
```

---

## 🧠 Obsidian Knowledge Base Suite (`skills/obsidian-rag/`)

Bi-directional sync, RAG grounding, and structured Architectural Decision Records (ADRs) using Obsidian as persistent agent memory.

| Skill | Trigger / Command | Description |
|---|---|---|
| **[`obsidian-setup`](skills/obsidian-rag/obsidian-setup/SKILL.md)** | `/obsidian-setup` | Interactive setup wizard. Discovers vaults, sets default vault preferences, validates the **PARA** folder structure (`Projects/`, `Areas/`, `Resources/`, `Archives/`), and configures live-sync. |
| **[`obsidian-project-init`](skills/obsidian-rag/obsidian-project-init/SKILL.md)** | `/obsidian-init` | Scans vault for current repo, initializes `Projects/<Name>/Overview.md` (with Mermaid maps), `Dashboard.canvas` visual boards, and `Decisions.md`. Supports git worktrees, organization namespaces, and 4-vector drift reconciliation. |
| **[`obsidian-rag-grounding`](skills/obsidian-rag/obsidian-rag-grounding/SKILL.md)** | `/obsidian-rag` | Ingests project overview, recent ADRs, `Areas/` system guidelines, and `Resources/` references with cascading project overrides to ground creative, UI, and coding tasks. |
| **[`obsidian-decision-sync`](skills/obsidian-rag/obsidian-decision-sync/SKILL.md)** | `/obsidian-decision` | Formats choices into structured ADRs (*Chosen, Rationale, Rejected Alternatives*) with automated superseding detection and bidirectional links. |
| **[`obsidian-auto-sync`](skills/obsidian-rag/obsidian-auto-sync/SKILL.md)** | Autonomous / `/obsidian-flush` | Automatically records commits to `Worklog.md` (with 1,000-line milestone rotation), tickets to `Tasks.md`, and ADRs to `Decisions.md` with zero-data-loss replay queue. |
| **[`obsidian-index`](skills/obsidian-rag/obsidian-index/SKILL.md)** | `/obsidian-index` | Compiles an authoritative master Map of Content (`PARA-Index.md`) and interactive spatial visual board (`PARA-Index.canvas`) across all 4 PARA pillars. |

---

### 🏛️ The PARA & BASB (CODE) Architecture

The suite adopts Tiago Forte's **Building a Second Brain (BASB)** and **PARA** methods by default:

* **P — Projects (`Projects/`)**: Active repositories, deliverables, and goal-oriented initiatives (`Overview.md`, `Worklog.md`, `Tasks.md`, `Decisions.md`, `Dashboard.canvas`).
* **A — Areas (`Areas/`)**: Ongoing standards and directives without a fixed end date (`Tone and Voice.md`, `Design Tokens.md`, `Architecture Principles.md`). *(Legacy `System/` folders are automatically supported as fallbacks)*.
* **R — Resources (`Resources/`)**: Reusable technical cheat-sheets, third-party API contracts, prompt packs, and reference guides.
* **A — Archives (`Archives/`)**: Completed projects, deprecated architecture logs, and yearly rotated worklogs (`Archives/Worklogs/`).

**The CODE Operating Cycle**:
1. **Capture**: Intercept git commits, tickets, and architectural trade-offs automatically via live-sync hooks.
2. **Organize**: Route entities directly into their proper PARA bucket.
3. **Distill**: Consolidate micro-commits into **1 Milestone per Rollup**, extract concise ADRs, and prune noise.
4. **Express**: Render interactive spatial **`Dashboard.canvas`** boards, Mermaid dependency graphs, and verified production code.

#### 📊 Dataview Plugin Schema & Dynamic Queries
All notes generated by the suite follow a unified database schema (`pillar`, `type`, `status`, `tech_stack`, `created_at`, `updated_at`, `tags`):
- When the community [Dataview](https://github.com/blacksmithgu/obsidian-dataview) plugin is installed in Obsidian, notes embed reactive live queries:
  - `PARA-Index.md`: Live tables of active projects, area directives, and vault-wide incomplete tasks.
  - `Overview.md`: Real-time project task board querying `Tasks.md`.
- Works seamlessly without Dataview: all notes include fully formed markdown fallback tables.
- Toggle via `obsidian-config.json`: `"dataview": { "enabled": true, "render_dynamic_queries": true }`.

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

*(The installer also automatically links `.git/hooks/post-commit` into your local git repository to queue commits created via manual CLI or external IDEs).*

---

### 🪝 Standalone Git Post-Commit Hook

If you make commits directly in terminal, VS Code Source Control panel, or GitKraken outside an active AI agent session, the included post-commit hook ensures no milestones are missed:
1. When you run `git commit`, `.git/hooks/post-commit` runs `scripts/obsidian-post-commit.ps1` (or `scripts/obsidian-post-commit.sh`).
2. If the commit meets the **Threshold of Significance** (`milestones_only`), it queues the metadata into `.agents/pending-sync.json`.
3. When your AI agent opens next (or on `/obsidian-flush`), all queued commits are rolled up into `Projects/<ProjectName>/Worklog.md`.

---

### 🔌 Prerequisites & Provider Setup

The Obsidian Suite supports two communication providers depending on your workflow:

#### Option A: Headless MCP Server (`obsidian-mcp`) — *Recommended for CLI & Background Agents*
Direct filesystem access using [`obsidian-mcp`](https://github.com/StevenStavrakis/obsidian-mcp). Operates without needing the Obsidian desktop application running.

Ensure your agent or IDE has the `obsidian` MCP server configured:

##### 1. Antigravity IDE
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

##### 2. Claude Desktop / Claude Code
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

##### 3. Cursor
Under **Cursor Settings > Features > MCP Servers**, add a new server:
- **Name**: `obsidian`
- **Type**: `command`
- **Command**: `npx -y obsidian-mcp serve --vault <vault_name>=<path_to_vault>`

---

#### Option B: Obsidian Local REST API Plugin — *Recommended for Active Desktop Users*
Communicates with the [Obsidian Local REST API](https://github.com/coddingtonbear/obsidian-local-rest-api) community plugin running inside Obsidian. Immediately triggers in-app events, Dataview indexing, and Canvas refresh.

1. In Obsidian, go to **Settings > Community plugins > Browse** and install **Local REST API**.
2. Enable the plugin and copy your generated **API Key** from the plugin settings.
3. Set your environment variable:
   - **Windows (PowerShell)**:
     ```powershell
     [Environment]::SetEnvironmentVariable("OBSIDIAN_REST_API_KEY", "<your_api_key>", "User")
     ```
   - **macOS / Linux (Bash/Zsh)**:
     ```bash
     export OBSIDIAN_REST_API_KEY="<your_api_key>"
     ```
4. In `.agents/obsidian-config.json`, set `"provider": "local_rest_api"`.

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
