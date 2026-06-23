# Mantis Climb Overtorque From Zero Rail Power

## Symptoms

- Mantis/spider climbs upward with heavy load, for example `35kg`, and emergency-brakes/stops.
- NXP or drive log shows repeated `NODE402 OVERTORQUE`, `following error`, and transition into `FaultReaction`.
- Supercapacitor voltage drops during upward climb.
- The same speed/acceleration may pass during descent but fail during upward climb.

## Fault Tree

1. Confirm the load and motion profile.
   - Record load, direction, speed, acceleration, vertical distance, and whether capacitor lead-out or test wiring changed.
   - Upward climb under load is a stronger rail-power stress condition than descent.
2. Check external/rail power before motor replacement.
   - Measure rail-power voltage at the cabinet, rail, pickup, module input, and during climb.
   - Inspect cabinet neutral line, supply polarity, series-supply wiring, and rail pickup/contact.
   - If actual rail supply is `0V`, overtorque/following error is likely a consequence of supply collapse and capacitor depletion.
3. Correlate supercapacitor voltage with motor fault timing.
   - If capacitor voltage drops while current rises and motor reports overtorque/following error, treat power feed as the first branch.
   - Use raw NXP/CAN and waveform data when available to align voltage dip, torque warning, and fault reaction.
4. Verify after correction.
   - Correct neutral/polarity/rail-power wiring.
   - Repeat the same loaded upward climb and record rail voltage, capacitor voltage/current, and NXP/CAN logs.

## Evidence Needed

- Raw NXP log around overtorque/following error.
- CAN/drive pcap/candump or fault frames around the climb fault.
- Oscilloscope waveform export for capacitor voltage/current and rail supply.
- Cabinet/rail wiring photos before and after correction.
- Measured rail-power voltage at cabinet output, rail, pickup, and module input.
- Same-condition retest after wiring correction: load, speed, acceleration, direction, voltage/current, and fault status.

## Logs And Files To Inspect

- `cases/accepted/cs006/0001-QcQrwHHa8iWFokkDenmcERXsnRf-2026-04-03-CS006-001-螳螂负载-35kg-向上爬升过程中爬升电机报错.md`
- `assets/cs006-pt-0001/001-image-0c8cb7188a8f.png`
- `assets/cs006-pt-0001/002-image-61ab55807a09.jpg`
- `assets/cs006-pt-0001/003-image-b268cbcdbed5.jpg`
- Search terms: `NODE402 OVERTORQUE`, `dual402 following error`, `FaultReaction`, `超级电容`, `导轨供电`, `零线未连接`, `29v`, `0v`, `35kg`, `1.5m/s`, `6600mm`.

## Likely Causes

- Cabinet neutral line not connected, disabling or destabilizing rail power.
- Two series `29V` rail supplies wired with opposite positive/negative directions, yielding actual rail supply `0V`.
- Mantis climbs from supercapacitor energy only; capacitor voltage falls under heavy upward load and drive reports overtorque/following error.
- Secondary contributors can include rail pickup/contact or added capacitor lead-out harness, but source evidence points first to cabinet/rail-power wiring.

## Exclusion Checks

- Do not replace climbing motor, drive, or controller before verifying rail power and cabinet wiring.
- Do not treat `NODE402 OVERTORQUE` as proof of mechanical overload if rail supply is absent.
- Do not conclude CAN root cause from fault reaction screenshots without CAN frames.
- Do not use descent success to clear power-feed risk; upward loaded climb has different energy demand.
- Do not close without same-condition loaded upward climb retest after wiring correction.

## Confirmed Examples

- `cs006-pt-0001`: CS006-001 tested a 35kg Mantis at `1.5m/s`, acceleration `1.0m/ss`, vertical displacement `0~6600mm`. Descent on `2026-04-02` did not show the issue; upward climb on `2026-04-03` emergency-braked and NXP reported motor following error. Local log screenshot shows repeated `NODE402 OVERTORQUE`, `dual402 following error`, and `FaultReaction`. Oscilloscope photo supports capacitor voltage dropping during climb. Source resolution found G-floor CS006 cabinet neutral not connected and two series `29V` rail supplies wired in opposite positive/negative directions, making actual rail power `0V`; after adjustment, later testing had no abnormality.

## Unresolved Examples

- `cs006-pt-0001`: no raw NXP log, CAN/drive trace, waveform export, wiring photos, exact rail voltage measurement record, or same-condition post-fix retest log is local.

## Specialist Routing

- `mantis-handling`: climbing mechanism, load, direction, rail contact, physical test condition.
- `embedded-software`: NXP `NODE402 OVERTORQUE`, following error, and fault-state transitions.
- `can-bus`: drive/CAN fault frames and motor state if available.
- `vision-media`: log screenshot, field wiring/photo context, oscilloscope trace.
- `boost-module`: only if boost/supercapacitor or rail-power module data is needed.
