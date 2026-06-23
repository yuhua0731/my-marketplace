---
name: leader
description: Use when diagnosing an issue packet, Feishu problem document, field report, log bundle, or unclear troubleshooting case across supported corpora; builds the fault tree, routes to specialists, and produces the final diagnosis.
---

# Troubleshooter Leader

Use company, product-line, and corpus-specific local plugin assets first.

Company layer:

- `assets/hc-robotics/company-overview.md`
- `assets/hc-robotics/product-portfolio.md`
- `assets/hc-robotics/industry-solutions.md`
- `assets/hc-robotics/knowledge/`

OmniFlow / 慧仓穿云箭 product-line layer:

- `assets/omniflow/product-overview.md`
- `assets/omniflow/common-architecture.md`
- `assets/omniflow/common-terms.md`
- `assets/omniflow/fault-taxonomy.md`
- `assets/omniflow/knowledge/`
- `assets/problem-tracking-unknown/knowledge/`
- `assets/problem-tracking-unknown/troubleshooting-playbook.md`
- `assets/test-floor-traffic/knowledge/`
- `assets/test-floor-traffic/troubleshooting-playbook.md`
- `assets/component-test/knowledge/`
- `assets/component-test/troubleshooting-playbook.md`

OmniSort / 慧仓闪电播 product-line and corpus layers:

- `assets/m111/knowledge/`
- `assets/m004/knowledge/`
- `assets/m004/troubleshooting-playbook.md`
- `assets/m123/knowledge/`
- `assets/m123/fault-taxonomy.md`
- `assets/m123/troubleshooting-playbook.md`
- `assets/m133/knowledge/`
- `assets/m133/fault-taxonomy.md`
- `assets/m133/troubleshooting-playbook.md`
- `assets/m129/knowledge/`
- `assets/m129/troubleshooting-playbook.md`
- `assets/m141/knowledge/`
- `assets/m141/troubleshooting-playbook.md`
- `assets/m145/knowledge/`
- `assets/m145/troubleshooting-playbook.md`
- `assets/m147/knowledge/`
- `assets/minisort-test/knowledge/`
- `assets/minisort-test/troubleshooting-playbook.md`

Corpus layer examples. Load the matching corpus package when the issue identifies one:

- `assets/c134/fault-taxonomy.md`
- `assets/c134/knowledge/`
- `assets/c134/troubleshooting-playbook.md`
- `assets/boost-module/fault-taxonomy.md`
- `assets/boost-module/knowledge/`
- `assets/boost-module/troubleshooting-playbook.md`
- `assets/c113/troubleshooting-playbook.md`
- `assets/sort-conveyor/troubleshooting-playbook.md`

## Workflow

1. Read the source packet before deciding.
2. Extract exact symptom, timestamps, device/robot IDs, location, company, product names, product line, project, corpus, and available files.
3. Identify product line before applying project assumptions. For HC Robotics, map 慧仓穿云箭 to `omniflow` / `OmniFlow`, and 慧仓闪电播 to `omnisort` / `OmniSort`.
4. Load context in order: `assets/hc-robotics/`, `assets/<product_line>/`, `assets/<corpus>/`, then case assets.
5. If the corpus is known, load `assets/<corpus>/`; if unknown, infer from source title, product names, device IDs, paths, and user wording, then mark confidence.
6. Classify the area using product-line and corpus taxonomies when available.
7. Load the matching knowledge file.
8. Build a fault tree from observed symptom to plausible branches.
9. If direct evidence cannot confirm root cause, search same-corpus and same-product-line knowledge for highly similar historical cases. Use them to support a `likely` branch only when symptom, device family, action phase, log cutoff/coverage gap, and recovery pattern materially match. List matching points, differences, and the missing evidence still needed.
10. Route evidence to specialists by observed domain:
   - charging pile green fast blink / SOC stall: `can-bus`, `embedded-software`, `vision-media`
   - test-floor collision after DM code loss: `robot-motion`, `network-infra`, `scheduler-traffic`, `vision-media`
   - test-floor abnormal power-off with stale RMS battery or CANopen Pre-operational: `embedded-software`, `can-bus`, `network-infra`, `vision-media`
   - component-test ALLCAN-DM dirty floor-code loss: `robot-motion`, `vision-media`, `embedded-software`, then `can-bus` if pcap/candump is decodable
   - component-test ALLCAN-S CAN transceiver failure or node scan failure: `can-bus`, `embedded-software`, `vision-media`
   - component-test lift motor enable failure with drive `Er.C90`: `embedded-software`, `vision-media`, then `can-bus` if drive/CAN trace exists
   - M141 EasyBox/CAN Gateway power-cycle stale safety state: `embedded-software`, `can-bus`, `scheduler-traffic`, `vision-media`
   - M123 drive-power cut where feeder/conveyor does not home after restart and `server status bit1` may not have toggled: `embedded-software`, `can-bus`, `scheduler-traffic`, `vision-media`
   - M133 scanner focus / S311 frontend scan-result display / `SCAN OUT OF AREA` / `CONVEYOR_SCAN_BARCODE_EXISTS` / convey-fail abnormal-grid flow: `scheduler-traffic`, `vision-media`, `embedded-software`
   - M145 scheduler config hardlink loss causing invalid robot motion command: `scheduler-traffic`, `embedded-software`, `network-infra`, `vision-media`
   - MiniSort dirty grid/shuttle standby offset or map-vs-physical mismatch: `scheduler-traffic`, `robot-motion`, `embedded-software`, `vision-media`
   - M129/OmniSort Leisai lift homing torque-retry failure: `can-bus`, `embedded-software`, `vision-media`, `scheduler-traffic`
   - M004 MiniSort Pro feeder-position ALLCANDM dense-center offset homing failure: `robot-motion`, `vision-media`, `embedded-software`, `can-bus`
   - Boost-module passive balance, cell-voltage imbalance, UVLO, or standby drain bench tests: `boost-module`, `embedded-software`, `vision-media`, then `can-bus` only if telemetry exists
   - power/reboot: `embedded-software`, `can-bus`, `scheduler-traffic`, `network-infra`
   - motion/localization: `robot-motion`, `embedded-software`, `can-bus`, `vision-media`
   - network/connectivity: `network-infra`, `embedded-software`
   - load handling: `embedded-software`, `robot-motion`, `scheduler-traffic`, `vision-media`
   - Mantis or rack-handling mechanism: `mantis-handling`, `can-bus`, `embedded-software`, `scheduler-traffic`, `vision-media`
   - Scheduler/no-action: `scheduler-traffic`, then robot specialist only if robot evidence exists
   - WS/WLED: `workstation`
10. Merge conclusions only after checking conflicts and evidence strength.

## Output

Lead with one of:

- `diagnose`
- `needs-assets`
- `insufficient`
- `reject`

Then provide:

- company/product line/project/corpus
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
- Historical high-similarity cases can corroborate a hypothesis when direct proof is missing, but they do not confirm root cause by themselves. Keep the conclusion at `likely` unless current-case logs, video, configuration, telemetry, or physical inspection close the branch.
- Do not import C134-specific assumptions into another corpus unless the evidence or user explicitly supports the analogy.
- Reuse product-line common knowledge only within the same product line; do not import C134 / OmniFlow assumptions into OmniSort cases unless the evidence supports the analogy.
- `WS` means workstation. `WLED` and light-strip belong to workstation, not Ant.
