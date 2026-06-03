# C134 Workstation WLED Knowledge

source_set: accepted and needs-assets `Workstation/light-strip`
case_count: visible-text low-priority workstation cases
status: draft refined from visible text

## Symptoms

- WS002/HLED/WLED reboots after a picking task completes or while unused: `c134-0106`, `c134-0108`, `c134-0109`, `c134-0114`, `c134-0115`, `c134-0116`, `c134-0191`, `c134-0300`, `c134-0349`.
- Light-strip color/display delay after station task transition: `c134-0110`, `c134-0149`.
- Light strip does not light or shows wrong constant color while FLO/task state appears normal: `c134-0211`, `c134-0212`, `c134-0213`, `c134-0214`, `c134-0418`.
- Workstation sensor/display/operator cue ambiguity: `c134-0230`, `c134-0292`, `c134-0439`.
- Workstation photoelectric/light-curtain sensor abnormal indicator: `c134-0292`.

## Fault Tree

1. Confirm this is workstation equipment.
   - WLED/HLED/light-strip, station light command, grid/sensor display, and WS full-box prompts belong to workstation.
   - Do not classify as Ant only because an Ant carried a tote away from WS001/WS002.
2. Align real event time, monitor time, and service log time.
   - Video can be offset from actual time; example `c134-0300` notes monitor time was about 25-26 seconds fast.
3. Check whether this is reboot, delay, wrong color, or missed cue.
   - Reboot: all/partial WLED modules reset or color falls back unexpectedly.
   - Delay: light command exists but execution waits behind another station queue.
   - Wrong/missing cue: UI/task is normal but the physical light/sensor signal is absent or misleading.
4. For delay, inspect station light-command queue isolation.
   - `c134-0110` and `c134-0149` show WS002 light delay tied to queued commands; separating station queues is the confirmed fix in `c134-0110`.
5. For reboot, inspect WLED module power/network/reset evidence.
   - Need module screenshots/video, WLED status page/export if available, station controller logs, and power-cycle timing.
   - Visible text alone is usually insufficient to prove root cause.
6. For sensor/operator-cue cases, inspect physical sensor state and UI prompt mapping.
   - `c134-0439` indicates full-box sensor trigger was not obvious enough, causing operators to identify the wrong picking position.
   - `c134-0292` reports `WS002-1` photoelectric/light-curtain sensor abnormal flashing while the paired sensor stayed red/triggered; classify as workstation sensor/electrical/alignment first.

## Evidence Needed

- Exact station and cell: WS001/WS002, workstation index, grid/cell index.
- Exact event time and monitor offset.
- Video covering before/after station task completion or sensor trigger.
- Station task logs and light-control logs with queue size, stationId, workstationIndex, tote label, and on/off command.
- WLED/HLED module status screenshots, reset time, module count affected, and power/network state.
- For sensor issues: sensor indicator state, physical trigger condition, UI prompt/screenshot, operator action timeline.

## Logs And Files To Inspect

- station task logs containing `StationTaskGroup`, `Queued lighting control message`, stationId, workstationIndex, and container label.
- WLED/HLED controller logs or module status export.
- IMS/IOCS/FLO task-state screenshots when the workstation symptom is linked to task completion.
- Video/screenshot evidence for light color, delay duration, station index, and physical sensor state.

## Likely Causes

- Light-command queue contention between workstation positions: `c134-0110`, `c134-0149`.
- Workstation WLED/HLED module reboot, power, or controller instability: visible in repeated needs-assets reboot cases, but not confirmed without module evidence.
- Light-strip wrong color or no light after robot self-check: needs local module/log evidence; visible text alone does not prove robot-side fault.
- Operator prompt/design ambiguity for full-box sensor: `c134-0439`.
- Physical sensor harness or alignment issue: `c134-0230`, `c134-0292`.

## Exclusion Checks

- If the only symptom is WLED/HLED/light strip behavior, exclude Ant power/motion unless robot logs also show reboot, motion error, or task failure.
- If Ant leaves the station normally and only the light changes incorrectly, start with workstation light-control logs.
- If a WS location appears in an Ant motion/load symptom, keep the case in Ant motion/load unless WLED/HLED or station sensor behavior is the observed failure.
- If video time is offset, do not align logs by video timestamp without correcting the offset.
- If visible text lists images/video only, mark branch `blocked` until local media is available.

## Handling Recommendations

- For light delay, compare queue size and command timestamps across WS001/WS002; isolate station queues when cross-station commands block each other.
- For reboot, collect video plus WLED/HLED module status before power cycling; note whether all modules or one module reset.
- For wrong/missing light, verify station/task mapping before replacing hardware.
- For sensor cue ambiguity, preserve the operator timeline; the training value is often human-machine cue design, not only hardware state.

## Confirmed Examples

- `c134-0110`: WS002 light delay after task completion; logs showed 1号工作台 light command queued and affecting 2号工作台; resolution was splitting 1号 and 2号 workstation light commands into separate queues.
- `c134-0149`: WS002 light delay over 4s; logs include queued lighting control messages and queue sizes around task transition.
- `c134-0439`: full-box sensor trigger was not obvious, causing misidentification of WS001 picking position; recommendation was red constant light after return button when full-box sensor is triggered.

## Unresolved Examples

- `c134-0106`, `c134-0108`, `c134-0109`, `c134-0114`, `c134-0115`, `c134-0116`, `c134-0191`, `c134-0300`, `c134-0349`: WLED/HLED reboot symptoms need local video/module/controller evidence or exact log correlation.
- `c134-0211`, `c134-0212`, `c134-0213`, `c134-0214`: light-strip abnormal color after robot self-check; robot operation/FLO may be normal, but local light module evidence is missing.
- `c134-0292`: WS002-1 light-curtain/photoelectric sensor abnormal flashing; controller/electrical/alignment evidence still needed.

## Specialist Routing

- `workstation`: WLED/HLED/light-strip, station sensor, operator cue, station task-to-light mapping.
- `scheduler-traffic`: station task state, work queue, IMS/FLO/IOCS command timing when no robot task is generated.
- `network-infra`: WLED/controller network reachability or whole-station controller disconnect.
- `vision-media`: verify light color, reset moment, station index, sensor physical state, and monitor timestamp offset.
