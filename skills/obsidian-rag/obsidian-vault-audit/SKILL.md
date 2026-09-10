---
name: obsidian-vault-audit
description: >
  Autonomous diagnostic health and link integrity audit for Obsidian vaults.
  Scans for broken wikilinks, orphan notes, missing project companion notes
  (Overview, Tasks, Worklog, Decisions), and frontmatter schema violations with
  automated remediation. Trigger with '/audit-vault', 'audit vault', or 'vault health'.
---

# Obsidian Vault Health & Link Integrity Auditor

The **Vault Health Auditor** (`/audit-vault`) performs deep diagnostic analysis across an Obsidian vault to detect broken internal links, identify missing project companion notes, flag unlinked orphan notes, and validate frontmatter schemas.

---

## 1. When to Use

Activate `/audit-vault` when:
- Verifying vault integrity after restructuring, note renames, or folder migrations.
- Auditing link health and identifying broken wikilinks (`[[target]]`) or markdown links (`[text](url)`).
- Checking that all active codebases in `Projects/` have required companion notes (`Overview.md`, `Tasks.md`, `Worklog.md`, `Decisions.md`).
- Finding orphan notes that lack incoming backlinks from MOCs or other notes.
- Validating YAML frontmatter compliance against suite schemas.

---

## 2. Multi-Vector Diagnostics

The auditor evaluates six distinct dimensions:

| Vector | Diagnostic Focus | Threshold / Standard |
| :--- | :--- | :--- |
| **Broken Wikilinks** | Broken `[[target]]`, `[[target\|alias]]`, or `[[target#heading]]` | Target must exist by exact path, stem, or attachment |
| **Markdown Links** | Broken relative file links `[label](path/to/file.md)` | File must exist relative to vault root |
| **Companion Completeness** | Missing companion notes in `Projects/<Project>/` | Must contain `Overview.md`, `Tasks.md`, `Worklog.md`, `Decisions.md` |
| **Orphan Notes** | Notes with 0 incoming backlinks | Flags unindexed leaves not referenced in any MOC |
| **Stub Notes** | Empty or near-empty notes (<30 characters) | Flags forgotten placeholders or zero-byte files |
| **Frontmatter Compliance** | Missing YAML blocks or required fields | Checks `pillar`, `status`, `tags`, and timestamps |

---

## 3. Execution

### Running the Diagnostic Engine

Run the native auditor script via `run_command`:

**Windows (PowerShell):**
```powershell
powershell -ExecutionPolicy Bypass -File scripts\audit-vault.ps1
```

**Auto-Scaffolding Missing Companions:**
```powershell
powershell -ExecutionPolicy Bypass -File scripts\audit-vault.ps1 -ScaffoldMissing
```

**Markdown Report Output:**
```powershell
powershell -ExecutionPolicy Bypass -File scripts\audit-vault.ps1 -Format Markdown
```

**JSON Output (Programmatic/CI):**
```powershell
powershell -ExecutionPolicy Bypass -File scripts\audit-vault.ps1 -Format Json
```

**macOS / Linux:**
```bash
./scripts/audit-vault.sh
```

---

## 4. Health Scoring Algorithm

The vault receives an overall **Health Score (0-100%)**:

$$\text{Health Score} = \max(0, 100 - (2 \times \text{BrokenLinks}) - (5 \times \text{MissingCompanions}) - (2 \times \text{StubNotes}))$$

- 🟢 **90 - 100%**: **EXCELLENT** — Vault is tightly linked, companions are complete, and indices are sound.
- 🟡 **75 - 89%**: **GOOD** — Minor link gaps or unlinked notes, but core structure is intact.
- 🔴 **< 75%**: **ATTENTION NEEDED** — Significant broken links or missing project companion notes require remediation.

---

## 5. Report Template

Format the user-facing diagnostic report cleanly:

```markdown
# 🏥 Vault Health & Link Integrity Audit: <Vault Name>

**Health Score**: 🟢 **92 / 100 (EXCELLENT)** | **Total Notes**: 374

| Metric | Value | Status |
|---|---|---|
| **Broken Links** | 0 | ✅ None |
| **Project Companion Gaps** | 0 | ✅ Complete |
| **Stub Notes (<30 chars)** | 2 | ℹ️ Review Stubs |
| **Orphan Notes** | 45 | ℹ️ Backlink audit |

---

### ⚠️ Broken Link Details
*(Omitted if 0 broken links)*
| Source Note | Line | Broken Target | Type |
|---|---|---|---|
| `Areas/Brand/Design.md` | 42 | `[[Old-Color-Palette]]` | Wikilink |

---

### 📁 Project Companion Status
| Project Directory | Status | Missing Notes |
|---|---|---|
| `Projects/project-alpha` | ✅ Complete | None |
| `Projects/project-beta` | ⚠️ Incomplete | `Decisions.md` |

---

### 💡 Remediation Guidance
1. **Auto-Scaffold Missing Companions**: Run `/audit-vault --fix-companions` to generate missing templates.
2. **Fix Renamed Wikilinks**: Update old target stems in affected notes.
3. **Index Orphan Notes**: Add unlinked notes into the appropriate Area MOC or `PARA-Index.md`.
```

---

## 6. Automated Remediation Workflow

When companion notes or links need repair:
1. **Scaffolding**: Automatically generate canonical YAML frontmatter, title, and companion link back to `[[Projects/<Project>/Overview]]`.
2. **Link Canonicalization**: For broken links that point to notes renamed or moved to `Areas/` or `Resources/`, suggest or apply the closest stem match.
3. **MOC Linking**: Present orphan notes grouped by folder so the user can quickly link them into parent Map of Content notes.
