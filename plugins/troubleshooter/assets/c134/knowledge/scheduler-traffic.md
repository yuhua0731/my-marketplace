# C134 Scheduler Traffic Knowledge

source_set: accepted scheduler and command-generation cases, including `c134-0447`
case_count: 1 focused command-geometry example plus related no-action/interlock examples in the corpus
status: runtime routing rules for scheduler/RMS command generation before blaming robot-side localization

## Symptoms

- Robot stops with `Task failed` after receiving a MOVE command.
- Robot-side alarm reports `1202#DIFF402_ERROR#MOVER_MOTOR#DM code lost during linear motion`.
- RCS/RMS command payload has `expectedState` and `futureState` that are not aligned to the same DM-code line.
- `FUTURE_STATE_NOT_MATCH#Velocity#Expected:0#Actual:1181` can appear after the bad command geometry.

## Fault Tree

1. Build the command timeline before robot-side diagnosis.
   - Preserve the exact `robotCommandLabel`, task label, expected state, future state, target coordinates, velocity, and acceleration.
   - Example `c134-0447`: command `A-103-S2182292-2026-06-12T06:58:58.173Z-0`.
2. Compare expected pose, future pose, and MOVE target geometry.
   - In `c134-0447`, expected state is near `118719,99000`, but command target is `118656,104226`.
   - The X coordinate shifts by `-63 mm` while Y moves about `+5226 mm`, creating a slight diagonal instead of staying on the `x=118719` DM line.
3. Check whether NXP executed the command it received.
   - `c134-0447` NXP received `MOVE_EVENT: 118656, 104226`.
   - The robot trajectory followed the command line; relative error to the command line stayed small before DM loss.
4. Interpret DM loss as possible downstream evidence.
   - In `c134-0447`, DM reads progressed on `118719GG099000`, `118719GG100000`, `118719GG100750`, then became continuous `NoRead`.
   - Since the command line drifted away from the DM-code line, scanner loss is more consistent with bad MOVE geometry than dirty floor code or vehicle runout.
5. Escalate to RMS/path-planning root cause when command geometry is invalid.
   - Check map node conversion, scheduler-to-robot coordinate transform, path segment generation, and any offset injected between expected state and future state.

## Evidence Needed

- RCS/RMS command records with `expectedState`, `futureState`, `coordX`, `coordY`, `finalTargetX`, `finalTargetY`, `maxVelocity`, and `maxAcceleration`.
- NXP log proving the robot received the same target as the service command.
- DM read/no-read sequence before fault.
- Actual pose samples before fault to compare against the command line.
- Map/path segment definition for the expected DM line.
- Any coordinate transform, offset, or map-node conversion logs around the command-generation window.

## Logs And Files To Inspect

- RCS command/status log.
- RMS path-planning or command-generation log.
- NXP motion/localization log.
- Kafka robot command updates if available.
- Map/node conversion data for the affected route segment.

## Likely Causes

- `move_target_off_dm_line`: MOVE target generated off the expected DM-code line.
- Map node or segment coordinate conversion error.
- Scheduler/RMS coordinate transform offset between expected and future state.
- Downstream robot-side `DM_LOST` caused by command geometry, not by primary scanner/floor failure.

## Exclusion Checks

- If the NXP target differs from RCS/RMS target, inspect command transport or translation before path planning.
- If expected state, future state, and MOVE target are all aligned to the same DM line, do not use this branch; inspect floor code, scanner, drivetrain, and braking feasibility.
- If trajectory deviates significantly from the received command line, inspect robot-side motion/localization or drivetrain.
- If DM loss begins before the bad command segment, do not treat the scheduler command as the first cause.
- Do not classify the case as dirty floor code only because `DM_LOST` appears; compare command geometry first.

## Confirmed Examples

- `c134-0447`: A-103 stopped at `2026-06-12 14:59`. RCS/RMS generated a target `118656,104226` from expected state near `118719,99000`; NXP received and followed that target, then lost DM reads after moving away from the `x=118719` DM line.

## Unresolved Examples

- `c134-0447`: exact RMS/path-planning defect is not closed. Follow up on why `futureState.coordX = 118656` was generated instead of a DM-line-aligned target.

## Specialist Routing

- `scheduler-traffic`: command generation, expected/future state mismatch, map-node conversion, service timeline.
- `robot-motion`: DM read sequence, actual trajectory, scanner loss, command-line following check.
- `embedded-software`: NXP command receipt and diff402/localization details.
