# AGENTS.md

This file provides guidance to Codex (Codex.ai/code) when working with code in this repository.

## Overview

This is a Codex skill (`embedded-design-docs`) that guides Codex through writing design documents for embedded software. `skills/embedded-design-docs/SKILL.md` is the entry point — it contains the process flow, decision logic, checklists, and domain prompts. Templates live beside that skill file and use `{{placeholder}}` syntax.

## File roles

- `skills/embedded-design-docs/SKILL.md` — Process engine: Unified vs HLD/LLD decision, Starter vs Professional, 3-phase workflow, mandatory review checklist, anti-pattern catalog, domain-specific prompt table, reference document handling
- `skills/embedded-design-docs/unified-template.md` / `skills/embedded-design-docs/unified-professional-template.md` — Unified edition for single-MCU products: merges HLD + LLD into one document (5 chapters Starter, 10 chapters Professional)
- `skills/embedded-design-docs/hld-template.md` / `skills/embedded-design-docs/lld-template.md` — Starter edition (6 chapters, no compatibility section)
- `skills/embedded-design-docs/hld-professional-template.md` / `skills/embedded-design-docs/lld-professional-template.md` — Professional edition (9-10 chapters, adds compatibility, resource budgets, risk assessment, timing diagrams, test guidance, traceability matrix)

## Key design rule

Compatibility (兼容性) lives in Professional edition only. Starter templates must NOT include compatibility sections. When adding new chapters, decide upfront which edition they belong to.

## Placeholder convention

Templates use `{{DESCRIPTION}}` for fill-in prompts that Codex replaces. Inside mermaid code blocks, use `__DESCRIPTION__` (double underscores) instead — mermaid interprets `{{` as a hexagonal node shape and may choke on Unicode delimiters. Sub-prompts like `{{item}}` or `«term»` indicate repeatable rows. When editing templates, keep placeholders descriptive enough that Codex can infer what goes there without reading docs.

## Adding domains

To add a new domain (e.g. NFC, LoRa, audio DSP), add a row to the domain prompts table in SKILL.md. Each row needs the domain name and 3-6 targeted questions that surface the domain's unique design concerns.
