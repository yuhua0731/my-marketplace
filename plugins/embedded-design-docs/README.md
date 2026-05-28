# Embedded Design Docs

A Claude Code skill for writing design documents for embedded software: unified design docs (嵌入式软件设计, for single-MCU products), HLD (高层设计), and LLD (详细设计).

## Installation

Claude Code:

```bash
git clone https://github.com/yuhua0731/embedded-design-docs.git
mkdir -p ~/.claude/skills
ln -s "$(pwd)/embedded-design-docs" ~/.claude/skills/embedded-design-docs
```

Codex:

```bash
mkdir -p ~/.codex/skills
ln -s "$(pwd)/embedded-design-docs" ~/.codex/skills/embedded-design-docs
```

Restart Claude Code or Codex. The skill activates automatically on prompts like "write an HLD for..."

## What It Does

Helps Claude write complete, review-ready design documents by enforcing:

1. **接口定义** — every interface has method, direction, and message format
2. **异常处理流程** — error classification, recovery flows, watchdog strategy
3. **向前向后兼容性** (Professional) — protocol versioning, firmware upgrade compatibility
4. **主要功能定义** — state machines, algorithms, timing constraints

## Editions

| Edition | Templates | Chapters |
|---------|-----------|----------|
| **Unified** | `unified-template.md` / `unified-professional-template.md` | 5-10 chapters — single-MCU, merges HLD+LLD |
| **Starter** | `hld-template.md` / `lld-template.md` | 6 chapters — essentials |
| **Professional** | `hld-professional-template.md` / `lld-professional-template.md` | 9-10 chapters — adds compatibility, resource budgets, risk assessment, timing diagrams, test guidance, traceability matrix |

## Structure

```
embedded-design-docs/
├── SKILL.md                              # Process: decisions, 3-phase flow, checklists, domain prompts
├── unified-template.md                   # Unified Starter (single MCU)
├── unified-professional-template.md      # Unified Professional (single MCU)
├── hld-template.md                       # HLD Starter
├── hld-professional-template.md          # HLD Professional
├── lld-template.md                       # LLD Starter
└── lld-professional-template.md          # LLD Professional
```

## Usage

Invoke in Claude Code: "write a design doc for ..." or "write an HLD/LLD for ..."

The skill will:
1. Determine doc type (unified vs. HLD+LLD) based on product complexity
2. Ask clarifying questions (scope, constraints, domain, reference files, safety level)
3. Fill the template chapter by chapter with your input
4. Run a mandatory review checklist against the 4 core pain points
5. Flag anti-patterns (happy-path-only diagrams, ambiguous interfaces, etc.)

Templates can also be used standalone by team members without Claude.

## License

MIT
