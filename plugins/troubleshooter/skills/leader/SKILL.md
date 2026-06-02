---
name: leader
description: Use when diagnosing a C134 issue packet, Feishu problem document, field report, log bundle, or unclear troubleshooting case; builds the fault tree, routes to specialists, and produces the final diagnosis.
---

# Troubleshooter Leader

Use the local plugin assets first:

- `assets/c134/fault-taxonomy.md`
- `assets/c134/troubleshooter-plugin-spec.md`
- `assets/c134/knowledge/`
- `assets/c134/high-priority-asset-intake-plan.md`

## Workflow

1. Read the source packet before deciding.
2. Extract exact symptom, timestamps, robot IDs, location, product line, and available files.
3. Classify the area using `fault-taxonomy.md`.
4. Load the matching knowledge file.
5. Build a fault tree from observed symptom to plausible branches.
6. Route evidence to specialists:
   - Ant power/reboot: `embedded-software`, `can-bus`, `scheduler-traffic`, `network-infra`
   - Ant motion/localization: `robot-motion`, `embedded-software`, `can-bus`, `vision-media`
   - Ant network: `network-infra`, `embedded-software`
   - Ant load handling: `embedded-software`, `robot-motion`, `scheduler-traffic`, `vision-media`
   - Mantis handling: `mantis-handling`, `can-bus`, `embedded-software`, `scheduler-traffic`, `vision-media`
   - Scheduler/no-action: `scheduler-traffic`, then robot specialist only if robot evidence exists
   - WS/WLED: `workstation`
7. Merge conclusions only after checking conflicts and evidence strength.

## Output

Lead with one of:

- `diagnose`
- `needs-assets`
- `insufficient`
- `reject`

Then provide:

- symptom
- strongest evidence
- fault-tree branches with status: `confirmed`, `likely`, `excluded`, `blocked`
- root cause or operational conclusion
- next checks
- missing assets

## Guardrails

- Preserve exact timestamps, command labels, robot IDs, log filenames, coordinates, and source wording.
- Distinguish observed facts, field claims, inference, and confirmed conclusions.
- Do not treat inaccessible attachments as analyzed evidence.
- Use `unknown` instead of inventing facts.
- `WS` means workstation. `WLED` and light-strip belong to workstation, not Ant.
