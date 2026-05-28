# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Claude Code skill (`embedded-design-docs`) that guides Claude through writing design documents for embedded software. SKILL.md is the entry point — it contains the process flow, decision logic, checklists, and domain prompts. Templates are standalone markdown files with `{{placeholder}}` syntax.

## File roles

- `SKILL.md` — Process engine: Unified vs HLD/LLD decision, Starter vs Professional, 3-phase workflow, mandatory review checklist, anti-pattern catalog, domain-specific prompt table, reference document handling
- `unified-template.md` / `unified-professional-template.md` — Unified edition for single-MCU products: merges HLD + LLD into one document (5 chapters Starter, 10 chapters Professional)
- `hld-template.md` / `lld-template.md` — Starter edition (6 chapters, no compatibility section)
- `hld-professional-template.md` / `lld-professional-template.md` — Professional edition (9-10 chapters, adds compatibility, resource budgets, risk assessment, timing diagrams, test guidance, traceability matrix)

## Key design rule

Compatibility (兼容性) lives in Professional edition only. Starter templates must NOT include compatibility sections. When adding new chapters, decide upfront which edition they belong to.

## Placeholder convention

Templates use `{{DESCRIPTION}}` for fill-in prompts that Claude replaces. Inside mermaid code blocks, use `__DESCRIPTION__` (double underscores) instead — mermaid interprets `{{` as a hexagonal node shape and may choke on Unicode delimiters. Sub-prompts like `{{item}}` or `«term»` indicate repeatable rows. When editing templates, keep placeholders descriptive enough that Claude can infer what goes there without reading docs.

## Adding domains

To add a new domain (e.g. NFC, LoRa, audio DSP), add a row to the domain prompts table in SKILL.md. Each row needs the domain name and 3-6 targeted questions that surface the domain's unique design concerns.
