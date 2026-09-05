---
name: obsidian-decision-sync
description: >
  Captures architectural, voice, styling, and technical decisions made during development
  and syncs them to the project's Decision Log in Obsidian ('camwyn_codes' vault) as structured ADRs.
  Use when confirming major technical choices, after plan reviews, or when asked to 'log decision'.
---

# Obsidian Decision Sync

Captures critical decisions made during pair programming, architecture planning, and feature implementation, persisting them into your central Obsidian knowledge vault (`camwyn_codes`) so future agent sessions and team members retain full rationale and rejected alternatives.

---

## 1. When to Trigger

- **Explicitly**: When the user says "log this decision", "record our choice in Obsidian", "update decision log", or runs `/obsidian-decision`.
- **Proactively**: When completing an architecture review (`/plan-eng-review`), adopting a new framework/library, establishing a design token standard, or discarding an approach after a technical spike.

---

## 2. Decision Anatomy (ADR Standard)

Every decision record must capture **Choice**, **Rationale**, and **Rejected Alternatives** to prevent future sessions from re-exploring dead ends:

```markdown
### ADR-[YYYYMMDD-HHMM]: <Descriptive Decision Title>
- **Date**: <YYYY-MM-DD>
- **Status**: Accepted
- **Context**: <1-2 sentences on what problem or tradeoff necessitated this decision>
- **Decision**: <Clear statement of the chosen architecture, library, pattern, or rule>
- **Rationale**: <Why this option was selected, referencing performance, DX, simplicity, or constraints>
- **Rejected Alternatives**:
  - *<Alternative 1>*: <Why it was rejected, e.g. too complex, lacking maintenance, high latency>
  - *<Alternative 2>*: <Why it was rejected>
```

---

## 3. Concurrency-Safe Sync Flow

To safely write to Obsidian without race conditions or overwriting desktop changes (resolves vault name from `.agents/obsidian-config.json`, defaulting to `camwyn_codes`):

1. **Locate Target Note**:
   - Primary: `Projects/<ProjectName>/Decisions.md`
   - Fallback 1: `Projects/<ProjectName>.md` (under `## Decision Log`)
   - Fallback 2: `Projects/<ProjectName>/Overview.md` (under `## Decision Log`)

2. **Read Note & Capture Etag**:
   - Call `obsidian_read_note`:
     - `vault`: `"camwyn_codes"`
     - `path`: target note path
   - Extract `etag` and current content.

3. **Format & Append ADR**:
   - Append the new ADR block at the end of the note (or under the appropriate `# ... ADR` header).

4. **Write Note via Safe Etag**:
   - Call `obsidian_edit_note`:
     - `vault`: `"camwyn_codes"`
     - `path`: target note path
     - `content`: updated content
     - `etag`: captured etag

5. **Handle Conflicts**:
   - If `obsidian_edit_note` returns `412 Precondition Failed` (meaning the note was modified concurrently in the Obsidian desktop app):
     - Re-read note via `obsidian_read_note` to get the fresh content and new `etag`.
     - Re-apply the ADR append.
     - Retry `obsidian_edit_note`.

6. **Emit In-Chat Receipt**:
   - Display a clean summary of what was logged to Obsidian:
     > 📝 **Obsidian Decision Recorded**
     > **Note**: `Projects/<ProjectName>/Decisions.md`
     > **ADR**: `ADR-[YYYYMMDD-HHMM]: <Title>`
     > **Status**: Accepted

---

## 4. Guardrails & Privacy

- **Secret Scrubbing**: Never include API keys, passwords, database URLs with credentials, or personal access tokens in ADR entries.
- **Concise & Scannable**: Avoid dumping full source code or verbose chat logs into ADRs. Focus on the core decision, reasoning, and discarded paths.
- **Preserve Note Structure**: Do not modify or delete existing ADR entries when appending new ones unless explicitly instructed to mark an older ADR as `Superseded`.
