---
name: obsidian-setup
description: >
  Interactive setup wizard for Obsidian integration. Discovers available vaults,
  configures default vault preferences, validates foundational folder structure
  (Projects/, System/), and bootstraps core voice/design/architecture notes.
  Run once on initial setup or anytime you want to reconfigure Obsidian settings.
---

# Obsidian Integration Setup Wizard

Interactive configuration wizard for connecting AI agent workflows to your Obsidian knowledge base.

## 0. Prerequisite Check & MCP Diagnosis

Before attempting any vault operations, verify that the `obsidian` MCP toolset is available:

1. **Test MCP Toolset**:
   - Check if `obsidian_list_vaults` exists in the active agent tool definitions and responds.
2. **If Missing, Unconfigured, or Unreachable**:
   - **Immediately stop** the setup wizard.
   - Present a clear, actionable diagnostic box with copy-pasteable configuration snippets:

```markdown
> 🛑 **Obsidian MCP Server Not Detected or Unreachable**
>
> The Obsidian integration requires the [`obsidian-mcp`](https://github.com/StevenStavrakis/obsidian-mcp) server to communicate with your local Obsidian vault.
>
> ### Quick Setup Guide:
>
> #### 1. Antigravity IDE
> Add the server definition to `~/.gemini/config/mcp_config.json`:
>
> **Windows**:
> ```json
> {
>   "mcpServers": {
>     "obsidian": {
>       "command": "cmd.exe",
>       "args": [
>         "/c",
>         "npx",
>         "-y",
>         "obsidian-mcp",
>         "serve",
>         "--vault",
>         "<vault_name>=<absolute_path_to_vault>"
>       ]
>     }
>   }
> }
> ```
>
> **macOS / Linux**:
> ```json
> {
>   "mcpServers": {
>     "obsidian": {
>       "command": "npx",
>       "args": [
>         "-y",
>         "obsidian-mcp",
>         "serve",
>         "--vault",
>         "<vault_name>=<absolute_path_to_vault>"
>       ]
>     }
>   }
> }
> ```
>
> #### 2. Claude Desktop / Claude Code
> Add to `claude_desktop_config.json` (under `%APPDATA%\Claude` on Windows or `~/Library/Application Support/Claude` on macOS):
> ```json
> {
>   "mcpServers": {
>     "obsidian": {
>       "command": "npx",
>       "args": [
>         "-y",
>         "obsidian-mcp",
>         "serve",
>         "--vault",
>         "<vault_name>=<absolute_path_to_vault>"
>       ]
>     }
>   }
> }
> ```
> *(On Windows, use `command: "cmd.exe"` with `args: ["/c", "npx", ...]` if npx is not directly resolved).*
>
> #### 3. Cursor
> Open **Cursor Settings > Features > MCP Servers** and click **Add New MCP Server**:
> - **Name**: `obsidian`
> - **Type**: `command`
> - **Command**: `npx -y obsidian-mcp serve --vault <vault_name>=<absolute_path_to_vault>`
>
> ---
>
> 🔄 **After Saving**: Restart or reload your AI agent session, then re-run `/obsidian-setup`.
```

---

## 1. Vault Discovery & Configuration

1. **List Available Vaults**:
   - Call `obsidian_list_vaults` to discover all mounted vault IDs.
2. **Confirm Default Vault**:
   - Prompt the user to select or confirm the primary vault (e.g., `personal_vault` or `notes`).
3. **Persist Configuration**:
   - Save or update `.agents/obsidian-config.json`:
     ```json
     {
       "default_vault": "my_vault",
       "projects_dir": "Projects",
       "system_dir": "System",
       "adrs_per_context_limit": 5,
       "auto_sync": {
         "enabled": true,
         "on_commit": true,
         "on_decision": true,
         "on_todo": true
       },
       "global_notes": {
         "tone_and_voice": "System/Tone and Voice.md",
         "design_tokens": "System/Design Tokens.md",
         "architecture": "System/Architecture Principles.md"
       }
     }
     ```

---

## 2. Vault Structure Inspection

Search the configured vault for foundational folders and notes:

1. **Projects Directory (`Projects/`)**:
   - Query `obsidian_search_vault` with `scope: "Projects"`.
   - If missing, offer to create `Projects/` directory via `obsidian_create_directory`.

2. **System & Directives Directory (`System/`)**:
   - Query `obsidian_search_vault` with `scope: "System"`.
   - If missing, offer to create `System/` directory via `obsidian_create_directory`.

---

## 3. Global Knowledge Note Bootstrapping

Check if foundational global directives exist, and offer to create starter templates for any that are missing:

### A. `System/Tone and Voice.md`
If missing, offer to create with template:
```markdown
---
title: "Global Tone & Voice Guidelines"
type: system-directive
tags: [system, voice, tone, style]
---

# Tone & Voice Guidelines

Authoritative voice, tone, and communication principles to ground all user-facing copy, documentation, and agent responses.

## Core Tone Principles
1. **Clear & Concise**: Favor direct, active sentences over verbose fluff.
2. **Humanized & Natural**: Avoid corporate buzzwords, excessive signpost transitions, and formulaic AI writing patterns.
3. **Accurate & Unambiguous**: Be precise with technical terminology and instructions.

## UI Copy Standards
- **Buttons**: Short, action-oriented verbs (e.g. "Create Project", "Sync Changes").
- **Error Messages**: Explain what happened clearly and provide a concrete recovery action.
- **Empty States**: Friendly guidance on what to do first.
```

### B. `System/Design Tokens.md`
If missing, offer to create with template:
```markdown
---
title: "Global Design System & Styling Rules"
type: system-directive
tags: [system, design, styling, tokens]
---

# Design System & Styling Tokens

Authoritative design rules, typography, and color palettes for web apps and user interfaces.

## Aesthetics & Theme
- **Theme**: Dark mode first, sleek glassmorphism accents, subtle micro-interactions.
- **Typography**: Modern Google Fonts (e.g., Inter, Plus Jakarta Sans, Outfit).
- **Color Palette**: Curated HSL tokens with high contrast and harmonious accent gradients.

## Component Rules
- Avoid generic browser default inputs; use crafted states (hover, focus-visible, active).
- Maintain responsive fluid layouts with container queries and modern CSS variables.
```

### C. `System/Architecture Principles.md`
If missing, offer to create with template:
```markdown
---
title: "Engineering & Architecture Principles"
type: system-directive
tags: [system, architecture, engineering]
---

# Engineering & Architecture Principles

Core architectural standards across repositories and projects.

## Standards
- **DRY & Modular**: Keep components focused on a single responsibility.
- **Explicit over Clever**: Write readable, well-typed, and maintainable code.
- **Decision Records**: Log all major architectural pivots and rejected alternatives to `Decisions.md`.
```

---

## 4. Autonomous Live-Sync Configuration

Ask the user if they would like the agent to autonomously keep Obsidian updated as work happens:

1. **Prompt for Live Sync & Filter Thresholds**:
   - Ask if they want autonomous synchronization enabled:
     - Commits logged to `Projects/<ProjectName>/Worklog.md` (with "1 Milestone per Rollup" lifecycle)
     - Tasks/TODOs logged to `Projects/<ProjectName>/Tasks.md`
     - Architectural decisions logged to `Projects/<ProjectName>/Decisions.md`
   - Ask for their preferred commit verbosity:
     - **Milestones Only (Recommended)**: Filters out minor formatting, lints, and typos; rolls up supporting work into 1 milestone per block.
     - **All Commits**: Records every commit unconditionally.
2. **Persist Toggles**:
   - Update `auto_sync` in `.agents/obsidian-config.json`:
     ```json
     "auto_sync": {
       "enabled": true,
       "on_commit": true,
       "on_decision": true,
       "on_todo": true,
       "filters": {
         "commit_level": "milestones_only",
         "rollup_window_hours": 2
       }
     }
     ```

---

## 5. Verification & Summary

1. **Verify Tool Permissions**:
   - Confirm read, write, and search operations succeed against the selected vault.
2. **Present Final Setup Summary**:
   - Display configured vault name, detected directories, auto-sync status, and available global notes.
   - Summarize how downstream skills (`obsidian-project-init`, `obsidian-rag-grounding`, `obsidian-decision-sync`, `obsidian-auto-sync`) will use this configuration.
