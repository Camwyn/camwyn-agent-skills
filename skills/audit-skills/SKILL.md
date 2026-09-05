---
name: audit-skills
description: >
  Audit IDE-wide skill usage across all conversations and workspaces.
  Parses centralized Antigravity transcript logs to report most used skills,
  dormant skills, zero-run unused skills, and context optimization recommendations.
  Trigger with 'audit skills', 'skill usage report', or /audit-skills.
---

# Audit Skills (IDE-Wide Telemetry)

Analyzes historical telemetry across all conversations and workspaces in the Antigravity IDE to reveal skill utilization, identify deadweight / unused skills, and track workflow trends.

---

## 1. Process & Execution

When invoked:

1. **Locate Installed Skills**:
   - Inspect workspace skills: `c:\Users\camwy\.agents\skills\`
   - Inspect global skills: `~/.gemini/config/skills/` and `~/.gemini/config/plugins/*/skills/`
   - Inspect built-in skills: `~/.gemini/antigravity-ide/builtin/skills/`

2. **Parse Centralized Transcripts (Dual-Pass)**:
   - Query all transcript logs in:
     `$HOME\.gemini\antigravity-ide\brain\*\.system_generated\logs\transcript.jsonl`
   - **Pass 1**: Extract tool file loads using regex `skills[\\/]([a-zA-Z0-9_\-]+)[\\/]SKILL\.md`
   - **Pass 2**: Extract direct user slash command invocations matching `<USER_REQUEST>\\n/([a-zA-Z0-9_\-]+)`
   - Extract timestamps, conversation IDs, and invocation frequencies.

3. **Compute Usage Metrics**:
   - Total invocations per skill (tool reads + direct slash commands).
   - Unique conversations where each skill was activated.
   - Most recent invocation timestamp.
   - Identification of **Zero-Run Skills** (installed skills with 0 invocations in transcripts).

---

## 2. PowerShell Analysis Command

To compute metrics efficiently, execute the following script via `run_command`:

```powershell
$transcripts = Get-ChildItem "$HOME\.gemini\antigravity-ide\brain\*\.system_generated\logs\transcript.jsonl" -ErrorAction SilentlyContinue

# Pass 1: Tool file loads (Agent reads SKILL.md)
$toolLoads = Select-String -Path $transcripts.FullName -Pattern 'skills[\\/]([a-zA-Z0-9_\-]+)[\\/]SKILL\.md' | ForEach-Object {
    [PSCustomObject]@{
        Skill        = $_.Matches.Groups[1].Value
        Type         = 'ToolLoad'
        Conversation = $_.Path.Split('\')[7]
    }
}

# Pass 2: Direct user slash commands (e.g. /grill-me, /triage)
$slashCommands = Select-String -Path $transcripts.FullName -Pattern '<USER_REQUEST>\\n/([a-zA-Z0-9_\-]+)' | ForEach-Object {
    if ($_.Line -match '<USER_REQUEST>\\n/([a-zA-Z0-9_\-]+)') {
        [PSCustomObject]@{
            Skill        = $Matches[1]
            Type         = 'SlashCommand'
            Conversation = $_.Path.Split('\')[7]
        }
    }
}

$combined = @($toolLoads) + @($slashCommands)

# Group by skill
$usage = $combined | Group-Object Skill | Select-Object @{N='Skill';E={$_.Name}}, @{N='Count';E={$_.Count}}, @{N='ToolLoads';E={($_.Group | Where-Object {$_.Type -eq 'ToolLoad'}).Count}}, @{N='SlashCommands';E={($_.Group | Where-Object {$_.Type -eq 'SlashCommand'}).Count}}, @{N='UniqueConversations';E={($_.Group.Conversation | Select-Object -Unique).Count}} | Sort-Object Count -Descending

# Discover installed skills in .agents/skills
$installed = Get-ChildItem "$HOME\.agents\skills" -Directory -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name
$usedSkillNames = $usage.Skill

$unused = $installed | Where-Object { $usedSkillNames -notcontains $_ }

[PSCustomObject]@{
    TotalInvocations = ($combined | Measure-Object).Count
    TotalConversations = ($transcripts | Measure-Object).Count
    UsedCount = ($usage | Measure-Object).Count
    UnusedCount = ($unused | Measure-Object).Count
    TopSkills = ($usage | Select-Object -First 20)
    UnusedSkills = ($unused | Sort-Object)
} | ConvertTo-Json -Depth 5
```

---

## 3. Output Format

Present the audit report using clean GitHub markdown tables and callouts:

```markdown
# 📊 IDE-Wide Skill Usage Audit

- **Total Conversations Analyzed**: `<N>`
- **Total Skill Invocations**: `<N>`
- **Active Skills**: `<N>` | **Unused Skills**: `<N>`

---

### 🏆 Top Skills Leaderboard
| Rank | Skill Name | Invocations | Tool Loads | Slash Commands | Unique Conversations |
|:---:|:---|:---:|:---:|:---:|:---:|
| 1 | `obsidian-project-init` | 12 | 12 | 0 | 6 |
| 2 | `obsidian-setup` | 11 | 11 | 0 | 5 |
| 3 | `obsidian-rag-grounding` | 10 | 10 | 0 | 5 |
| ... | ... | ... | ... | ... | ... |

---

### 💤 Dormant Skills (Used 1-2 times)
- `auto-scope` (1 run)
- `session-budget` (1 run)
- `prototype` (1 run)

---

### 🚫 Unused Skills (Zero Invocations Across All Sessions)
Installed in `.agents/skills/` but never triggered in recorded history:
- `agents-md-lint`, `ask-matt`, `code-review`, `domain-modeling`, ...

---

### 💡 Optimization Insights
- **High Utility Clusters**: Highlight which domains (e.g. Planning, Obsidian, Architecture) dominate developer workflow.
- **Pruning Candidates**: Recommend archiving or removing zero-run skills that might add cognitive overhead or clutter discovery.
```

---

## 4. On-Demand Actions

Offer follow-up actions to the user:
1. **Prune/Archive Unused Skills**: Move zero-run skills to an `archive/` folder.
2. **Deep Dive on a Skill**: Show timestamps, conversation topics, and context for any specific skill.
3. **Workspace vs Global Split**: Compare skills used in current workspace vs other projects.
