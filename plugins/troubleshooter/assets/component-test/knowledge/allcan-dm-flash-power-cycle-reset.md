# ALLCAN-DM SD-Card Update Interrupted By Power-Baseboard Secondary Power-On

source_set: `component-test-pt-0056`
case_count: 1 ALLCAN-DM update/power sequencing case
status: runtime routing rules for Mantis 3.0 ALLCAN-DM update failures caused by DM reset during power-baseboard secondary power-on

## Symptoms

- On G楼螳螂3.0 or C144 螳螂3.0, updating the ALLCAN-DM program requires inserting an SD card.
- After the whole Mantis powers on, the power baseboard performs a secondary power-on.
- DM is restarted during that sequence.
- The restart interrupts the programming/update process and causes abnormal flashing behavior.

## Fault Tree

1. Start with power/reset stability during the update window.
   - `component-test-pt-0056`: source says whole-Mantis power-on triggers secondary power-on from the power baseboard.
   - DM restarts during that event.
   - If the SD-card update has already started, the restart can interrupt the update state.
2. Verify whether the update was done under isolated DM power.
   - Workaround A: use an external 24V power supply to power DM independently.
   - Workaround B: send power-on / power-off commands to the power baseboard to control DM power timing.
3. Treat as field-update process risk.
   - Source says both solutions are cumbersome and temporarily cannot completely solve the problem.
   - A release-ready fix should reduce the field sequence to a reliable, documented, low-step procedure.
4. Keep runtime ALLCAN-DM branches separate.
   - This case is about update-time reset/power sequencing.
   - It does not contain `DM code lost`, scan-rate, floor-code, or navigation failure evidence.

## Evidence Needed

- DM power rail and reset timing during whole-Mantis power-on and the baseboard secondary power-on.
- DM boot/update log or SD-card update progress/failure code.
- Power-baseboard command log showing power-on/power-off timing.
- Exact firmware/update package version and SD-card update steps.
- Confirmation that external 24V or controlled baseboard command sequence lets the same update complete.
- Final validated field procedure or design change; current source says it is not fully solved.

## Logs And Files To Inspect

- `cases/accepted/component-test/0056-PfOjwCx1ciMBgNkzLnWcCTDhnzg-2026-03-24-更新ALLCAN-DM程序时供电问题.md`
- No local assets exist for `assets/component-test-pt-0056/`.
- Search terms: `ALLCAN-DM`, `DM程序`, `SD卡`, `螳螂3.0`, `C144`, `电源底板`, `二次上电`, `DM会被重启`, `烧录程序时异常`, `外接24V`, `单独给DM供电`, `上电指令`, `掉电指令`.

## Likely Causes

- DM loses power or resets during the SD-card update because the power baseboard performs a secondary power-on after whole-machine power-up.
- The field update process lacks a guaranteed stable DM power window.
- The current power-baseboard control path can work around the issue, but is too cumbersome for a clean field-update process.

## Exclusion Checks

- Do not blame firmware image, SD-card contents, or update tool first until DM power/reset stability is proven.
- Do not route to ALLCAN-DM dirty floor-code/no-read diagnostics without runtime navigation evidence.
- Do not route to ALLCAN-LED/J-Link flashing diagnostics; this is an ALLCAN-DM SD-card update and power sequencing issue.
- Do not diagnose CAN bus communication failure without CAN logs, heartbeat/SDO errors, or bus captures around the update.
- Do not claim full resolution while the only known methods remain external 24V supply or manual baseboard power commands.

## Confirmed Examples

- `component-test-pt-0056`: G楼螳螂3.0 and C144 螳螂3.0 need SD-card insertion when updating ALLCAN-DM. After whole-Mantis power-on, the power baseboard performs secondary power-on, DM restarts, and update/flashing becomes abnormal. Current workarounds are external 24V independent DM power or explicit power-baseboard up/down commands to control DM power timing.

## Unresolved Examples

- `component-test-pt-0056`: missing power/reset waveform, DM update log, power-baseboard command log, firmware package version, post-workaround success evidence, and final simplified field procedure.

## Specialist Routing

- Start with `embedded-software` for DM boot/update sequence, SD-card update state, and power-baseboard command sequencing.
- Add `can-bus` only if communication logs show bus-level errors during update or power-baseboard command exchange.
- Add `mantis-handling` for Mantis 3.0 physical access/update procedure and field-maintenance workflow.
- Add `vision-media` only if photos/video of the update setup, wiring, or board indicators are available.
