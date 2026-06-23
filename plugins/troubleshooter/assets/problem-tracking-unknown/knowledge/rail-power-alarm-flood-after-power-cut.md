# Rail Power Alarm Flood After Power Cut

source_set: `problem-tracking-unknown-pt-0163`
case_count: 1 focused OmniSort rail-power alarm lifecycle case
status: runtime routing rules for rail power supply 1/2 alarms after intentional power cut/startup

## Symptoms

- After cutting动力电源 and powering on, system probabilistically reports `导轨供电电源1异常，请检查` and `导轨供电电源2异常，请检查`.
- Source says the alarms self-close without any handling.
- Source says when power is intentionally cut for equipment inspection, the system reports one alarm every `30S`, causing many records.
- Screenshot evidence includes `2026-06-08 13:44:41` simultaneous rail power supply 1/2 alarms.
- Sort Control System event page shows repeated rail power supply 1/2 alarms around `2026-06-16 15:39:00` to `15:39:04`; page footer shows `441-460/174085`.

## Fault Tree

1. Confirm expected power state.
   - If动力电源 is intentionally off for maintenance/test, raw rail-power status may be expected but should be gated or deduplicated.
   - If rail power should be energized, treat as possible real rail power fault.
2. Separate true rail fault from transient startup alarm.
   - True fault: rail supply voltage/current/status remains abnormal after startup stabilization.
   - Transient: startup sampling occurs before rail power/status debounce is stable, then self-clears.
   - Alarm-policy defect: repeated polling creates a new event every `30S` during intentional power-off.
3. Inspect alarm lifecycle.
   - Check whether backend creates a new alarm row for every poll instead of updating an active alarm.
   - Check clear/close timing, suppression windows, maintenance mode, and startup grace period.
4. Verify product/site identity.
   - Source says `M141-2`; screenshot shows `M123-SITE-2`. Resolve this before assigning project-specific root cause.
5. Preserve safety behavior.
   - Suppression/deduplication must not hide real rail power failures after power should be restored.

## Evidence Needed

- Backend alarm/event create/update/clear logs around `2026-06-08 13:44:41` and `2026-06-16 15:39:00`.
- Rail power supply 1/2 voltage/current/status telemetry around power cut, startup, and self-clear.
- Startup sequence timing and status debounce rules.
- Requirement document `SORT设备操作界面新增需求` (`Dga2doPApopCULxHOeaczJpqn8g`).
- Proof of the stated `30S` reporting interval in backend logs.
- Product/site confirmation for `M141-2` versus `M123-SITE-2`.
- Before/after verification showing intentional power-off alarms are deduplicated or gated while real faults still alarm.

## Logs And Files To Inspect

- Case body: `cases/needs-assets/problem-tracking-unknown/0163-CdbXw6hNgiYGIOkwobncdyCHn1f-2026-06-15-每次开机会有概率报-导轨供电电源1-2异常.md`.
- Screenshot: `assets/problem-tracking-unknown-pt-0163/retry-image-001-Q242bzjuAo3MsYxSo99c3tOxnKe.png`.
- Screenshot: `assets/problem-tracking-unknown-pt-0163/retry-image-002-KqOtb4dqfo8IYyxg86pcSOrQn9c.png`.
- Search terms: `M141-2`, `M123-SITE-2`, `导轨供电电源1异常`, `导轨供电电源2异常`, `每隔30S`, `自行关闭`, `Sort Control System`, `报错汇总`, `动力电源`, `设备排查`, `alarm dedup`, `startup grace`, `maintenance mode`.

## Likely Causes To Test

- Startup sampling or debounce window is too short, producing transient false alarms before rail power status is stable.
- Intentional power-off maintenance mode is not propagated to alarm policy.
- Backend event creation lacks active-alarm deduplication and creates a new row each poll.
- UI shows auto-closed transient alarms with the same severity as persistent real faults.
- Real rail power supply 1/2 input is slow, intermittent, or unstable after power recovery.

## Exclusion Checks

- Do not suppress alarms when rail power is expected to be energized and remains abnormal after a grace period.
- Do not classify as confirmed hardware failure from the screenshot alone.
- Do not diagnose scheduler queue, CAN, or network from the UI event text alone.
- Do not treat `174085` as the count caused by this issue; it only proves the event table is large.
- Do not assign to M141 or M123 project until source/screenshot identity conflict is resolved.

## Confirmed Examples

- None yet. `problem-tracking-unknown-pt-0163` establishes the alarm lifecycle triage path, but root cause remains unresolved without backend alarm logs and rail telemetry.

## Unresolved Examples

- `problem-tracking-unknown-pt-0163`: source reports M141-2 probabilistically raises `导轨供电电源1、2异常` after动力电切断 and startup, then self-closes; screenshots show rail power 1/2 alarms and dense event rows. Missing backend logs, rail telemetry, requirement doc, and site identity resolution keep cause unconfirmed.

## Specialist Routing

- `embedded-software`: rail-power status sampling, startup state, debounce, sensor/IO status, and clear timing.
- `scheduler-traffic`: alarm lifecycle, event deduplication, maintenance-mode gating, UI/backend event policy.
- `vision-media`: screenshot evidence, UI event timestamp, site label.
- `network-infra`: only if duplicate events are caused by event transport retries or service reconnects.
