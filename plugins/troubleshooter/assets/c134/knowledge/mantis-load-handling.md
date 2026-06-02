# C134 Mantis Load Handling Knowledge

source_set: accepted high-priority `Mantis/load-handling`
case_count: 21
status: draft refined from visible text

## Symptoms

- pull/deposit fails but tote is physically already placed: `c134-0077`, `c134-0267`, `c134-0269`, `c134-0271`, `c134-0274`
- fork/finger/arm expected-state mismatch: `c134-0079`, `c134-0269`, `c134-0296`, `c134-0305`, `c134-0331`, `c134-0351`, `c134-0364`
- repeated quick stop on pull motor: `c134-0267`, `c134-0272`, `c134-0274`
- offset/position mismatch around A2/A3 access nodes: `c134-0186`, `c134-0187`, `c134-0316`, `c134-0351`
- no action with tote on Mantis or no available deposit target: `c134-0311`, `c134-0316`
- mechanical interference/high torque during pull/deposit: `c134-0317`, `c134-0318`, `c134-0362`, `c134-0364`
- insufficient logs blocking conclusion: `c134-0079`, `c134-0308`, `c134-0316`

## Fault Tree

1. Confirm physical state versus database/task state.
   - If tote is already in target but task failed, inspect command completion and sensor mismatch; examples `c134-0267`, `c134-0269`.
   - If Mantis has tote but no deposit action, inspect SAS target selection; `c134-0311` saw `No PDs or Tunnels available`.
2. Check quick stop and motor-state sequence.
   - `c134-0267`: pull motor entered quick stop while static/retracted; upper `HSM_Main` did not see IO change; motor returned to operation enabled and repeated old target-reached, causing premature command complete.
   - `c134-0272`, `c134-0274`: quick stop triggered near X about `14445`/`14447` during horizontal move.
3. Check whether IO pulse was too short for current TPDO mode.
   - `c134-0267`: IO state `60FD` used TPDO type `0x01`, one sync frame every `10ms`; IO change shorter than `10ms` could be missed by NXP.
   - Branch fix: TPDO transmission type `0xFE` event-triggered plus motor firmware support for timed reporting.
4. Check command target/state and offset config.
   - `c134-0351`: rest position offset y `-7` led to current y `11341`, load access node offset y `-6` expected EXTEND y `11342`; 1 mm mismatch caused expected/actual error.
   - `c134-0316` reports similar `coordY Expected: 11342 Actual 11341` without logs.
   - `c134-0186`, `c134-0187`: M3 offset biased toward B3; needed adjustment toward B1, sometimes location-specific rather than global.
5. Check finger command and sensor state.
   - `c134-0296`: pull task failed before fork extension; inspect `ARTICULATE_FINGERS` command and nearby rest/load positions.
   - `c134-0305`: `FINGER_MOTOR_RIGHT4 Expected: 9000 Actual: 4150` and `UNABLE_TO_REACH_TARGET_STATE`.
   - `c134-0364`: finger motors 3/4 stalled at same time, likely finger hit tote.
6. Check mechanical interference and torque.
   - `c134-0362`: fork torque jumped to about 200%, speed dropped, tote tail lifted and finger position was disturbed.
   - `c134-0318`: abnormal pull torque exceeded 200%, normal pull torque is within 50%; suspected PT sheet-metal deformation.
   - `c134-0317`: repeated B2 PT pull failures with no obvious resistance manually; weight did not exceed 30 kg.
7. Check logs before concluding.
   - `c134-0079`: RMS logs incomplete; could not locate arm retract/task-complete logs.
   - `c134-0308`, `c134-0316`: no RMS logs; mark blocked and wait for reproduction.

## Evidence Needed

- RMS/RCS command-set lifecycle with command index and timestamps.
- NXP logs for HSM, node402, quick stop, target reached, state mismatch.
- CAN logs for pull motor, fork, finger motors, `60FD` IO, TPDO timing.
- SAS task/container and available shelf/PD/tunnel selection logs.
- access node and accessNodeOffset config for rest, load, deposit points.
- torque curves for pull/fork/finger motors.
- video/photo showing tote position, fork extension, finger position, PT/PD deformation/interference.

## Logs And Files To Inspect

- NXP logs, especially quick stop and target-reached sequence.
- candump/CAN for pull motor/finger motor state, torque, IO.
- RMS/RCS `robot_command_set.create` and command lifecycle dumps.
- SAS `SelectDepositService`, `FindClosestAvailableShelfService`, robot task create logs.
- access node/offset database rows for affected location.
- monitor video around physical contact or failed extend/pull.

## Likely Causes

- pull motor quick stop plus missed IO event / firmware target-reached behavior: `c134-0267`, `c134-0272`, `c134-0274`
- expected-state mismatch due to 1 mm offset difference: `c134-0351`, likely `c134-0316`
- location-specific offset bias: `c134-0186`, `c134-0187`
- no available deposit target / duplicate deposit contention: `c134-0311`
- mechanical interference or PT/PD deformation: `c134-0318`, `c134-0362`, `c134-0364`
- incomplete logs preventing root-cause proof: `c134-0079`, `c134-0308`, `c134-0316`

## Exclusion Checks

- Tote is already in target location: do not assume pull failed physically; inspect premature command complete and sensor mismatch.
- No metal interference visible after clear: still inspect quick stop and motor state; quick stop may have been transient.
- Expected/actual coordinate differs by 1 mm at A2: inspect offset config before hardware.
- Torque >200%: prioritize physical interference, deformation, or tote/finger contact.
- No RMS logs: classify as unresolved and request reproduction logs; do not invent conclusion.
- Same task has no available PD/tunnel: route to scheduler/traffic, not Mantis actuator first.

## Handling Recommendations

- Keep CAN logging enabled for Mantis quick-stop cases.
- Update motor firmware for quick-stop target-reached behavior and TPDO event-triggered IO reporting where applicable.
- Normalize or audit accessNodeOffset values around A2/A3 rest/load/deposit points.
- For repeated B2/PT failures, inspect sheet metal, tote height, finger contact, and torque rather than relying on manual no-resistance checks.
- For Mantis with tote and no action, inspect SAS available-location selection and duplicate deposit task generation.
- Preserve RMS logs before clear/reset; many cases become unrecoverable without them.

## Confirmed Examples

- `c134-0267`: quick stop, missed short IO event risk, stale target-reached after operation enabled, and premature complete explain tote placed but command failure.
- `c134-0351`: `coordY` mismatch `11341` vs expected `11342` traced to offset `-7` versus `-6`.
- `c134-0311`: two Ant deposit tasks were generated when only one A2 position was available, leaving Mantis with tote and no deposit path.
- `c134-0362`: high fork torque/interference lifted tote tail, disturbed fingers, and left tote partly on Mantis.
- `c134-0364`: tote not placed correctly and finger motors 3/4 stalled, likely finger hit tote.

## Unresolved Examples

- `c134-0079`: missing RMS logs block task sequence analysis.
- `c134-0308`: no RMS logs; only similar to prior A2 offset/state issue.
- `c134-0316`: failed task and 1 mm EXTEND mismatch observed, but logs rolled off.
- `c134-0317`, `c134-0318`: repeated B2 PT failures suggest mechanical/torque issue; exact root cause not confirmed.

## Specialist Routing

- `mantis-handling`: fork/finger/arm state, PT/PD geometry, quick stop, tote handling.
- `can-bus`: motor state machine, TPDO, IO pulse, torque and target-reached semantics.
- `embedded-software`: NXP HSM/node402 handling, firmware behavior after quick stop.
- `scheduler-traffic`: available PD/tunnel selection, duplicate deposit contention, task state.
- `vision-media`: tote/finger/PT interference, physical position, deformation, recovery sequence.
