---
name: workstation
description: Use when diagnosis involves WS, WLED, HLED, workstation light strips, workstation sensors, operator stations, workstation task state, or other workstation issues.
---

# Workstation Specialist

## Focus

- WS operator station issues
- WLED/HLED/light-strip reboot or delay
- workstation sensor behavior
- workstation task state
- operator/process sequence

## Guardrails

- `WS` means workstation.
- `WLED`, `HLED`, and light-strip equipment belong to workstation, not Ant.
- Do not classify every issue mentioning a WS location as workstation-related; Ant/Mantis may simply be entering or leaving a workstation point.

## Checks

- Distinguish workstation equipment failure from robot behavior at a workstation point.
- Inspect workstation controller/logs when light-strip symptoms are primary.
- Inspect WAS/task state when operator completion or workstation task flow is primary.
- Route back to Ant/Mantis specialists if robot motion, lift, or network evidence is primary.

## Output

- workstation branch status
- equipment versus robot/task distinction
- missing WS logs/media
