# C134 High-Value Accepted Sample Cleanup 2026-06-04

goal: turn repeated accepted high-priority cases into stable diagnostic rules and plugin-usable knowledge.

## Ant/power sample set

- `c134-0019`: confirmed low-battery shutdown; battery dropped from 24% to 0%, boost-module low-battery shutdown after sustained below-threshold state; charging dispatch was the operational cause.
- `c134-0024`: screenshot-confirmed `1102#NODE402_ERROR#MOVER_MOTOR_LEFT#under voltage`; SAS logs only prove task/availability context, not electrical root cause.
- `c134-0095`: charging pile reservation was released before physical departure; next robot was assigned the same pile and blocked.
- `c134-0124`: reboot confirmed twice with abrupt SOC drop; BMS/boost/charging-power is leading branch but not final without CAN/BMS evidence.
- `c134-0223`: robots carrying totes/unfinished tasks waited instead of charging; design/dispatch gap, not a robot-side voltage proof.
- `c134-0299`: repeated reboot with overlay full/SD-card abnormality; resolved by SD-card replacement.
- `c134-0372`: FLO disappearance plus reboot confirmed; MQTT/network errors preceded reboot, but battery stayed stable and causality is unproven.
- `c134-0409`: startup/init failure after motor heartbeat loss; E-stop recovery sequence is the operational rule.

## Ant/motion-localization sample set

- `c134-0003`: DM-loss symptom with scan-offset growth and correction; floor/scanner/RMS cause remains unresolved.
- `c134-0037`: DM loss plus dirty floor code and collision; cleaning floor code is the confirmed resolution.
- `c134-0041`: `10.784297867562598` degree command angle exceeded 10-degree tolerance; tolerance/planning rule fixed it.
- `c134-0198`: repeated WS001-3 target `131847, 101499`; treat as repeated-point geometry/command issue before single-robot hardware.
- `c134-0231` / `c134-0232`: repeated `[130847, 101500]` WS001-3 scan/rotation issue across robots.
- `c134-0319`: high-speed stop over too-short distance; braking distance check outranks floor-code speculation.
- `c134-0361`: title/assets identify A-102 but body says A-111; preserve robot-ID conflict and treat collision as outcome until video/log timing proves cause.
- `c134-0428`: trapezoid planning used current real velocity instead of theoretical velocity; route exceeded endpoint.

## Rebuild outputs

- `training/c134/accepted-training.jsonl`
- `training/c134/diagnostic-patterns.md`
- `training/c134/diagnostic-playbook.md`
- `docs/c134/case-index.md`
- `docs/c134/case-index.json`
- synced copy under `plugins/troubleshooter/assets/c134/`
