# C134 Mantis Load Handling Knowledge

source_set: accepted high-priority `Mantis/load-handling`
case_count: 57
status: refined into evidence-strength patterns from visible text

## Symptoms

- pull/deposit fails but tote is physically already placed: `c134-0077`, `c134-0267`, `c134-0269`, `c134-0271`, `c134-0274`
- fork/finger/arm expected-state mismatch: `c134-0079`, `c134-0140`, `c134-0269`, `c134-0296`, `c134-0305`, `c134-0331`, `c134-0351`, `c134-0364`
- repeated quick stop on pull motor: `c134-0267`, `c134-0272`, `c134-0274`
- offset/position mismatch around A2/A3 access nodes: `c134-0186`, `c134-0187`, `c134-0316`, `c134-0351`
- no action with tote on Mantis or no available deposit target: `c134-0311`, `c134-0316`
- mechanical interference/high torque during pull/deposit: `c134-0317`, `c134-0318`, `c134-0362`, `c134-0364`
- tote skew during A2 pull with short startup/CANopen evidence: `c134-0195`
- insufficient logs blocking conclusion: `c134-0079`, `c134-0308`, `c134-0316`
- Mantis/Ant traffic deadlock after avoidance: `c134-0054`
- Mantis left-right shaking / Ant below stopped / mode recovery dependency: `c134-0026`
- front load sensor or tote-state abnormal during deposit/unload: `c134-0386`
- local command dictionary miss during extraction: `c134-0013`
- anti-pinch sensor state mismatch or false trigger: `c134-0008`, `c134-0425`, `c134-0431`
- rear anti-pinch/sensor trigger with fork or belt looseness: `c134-0303`
- `ARM_MOTOR_SINGLE` following error during pull/load: `c134-0010`, `c134-0076`, `c134-0085`, `c134-0096`, `c134-0141`, `c134-0153`, `c134-0154`, `c134-0155`, `c134-0172`, `c134-0204`, `c134-0205`, `c134-0229`, `c134-0289`, `c134-0327`, `c134-0357`, `c134-0369`
- `ARM_MOTOR_SINGLE` following error during deposit/unload: `c134-0270`
- `ARM_MOTOR_SINGLE` stall during pull/load: `c134-0156`
- Mantis/shelf height mismatch during deposit: `c134-0259`
- Mantis pull offset/height mismatch with image or FLO following-error evidence: `c134-0368`, `c134-0430`, `c134-0432`, `c134-0434`, `c134-0435`

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
   - `c134-0140`: RMS shows `EXTEND` blocked by `coordY - Expected: 18068 Actual: 18067`; manual move to Bay1 recovered operation.
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
8. If filenames and robot label say Mantis, reclassify even when the initial case extraction says Ant.
   - `c134-0195`: source/assets say `A2巷道螳螂`, wormhole/NXP identify `M-A2-S1-1`; NXP only shows startup `canopen_stack`/`node_led` errors, not the full pull sequence.
9. If Mantis task failure is mixed with Ant aisle occupancy or避让, route scheduler/traffic first.
   - `c134-0054`: M1避让 for A-106, then immediately took a pull/deposit task and returned toward a path blocked by A-104; A-106 NXP showed command success, so embedded failure was not the primary branch.
   - `c134-0026`: Mantis pull failure was followed by left-right shaking and an Ant stopped below; computer-side manual mode let the Ant leave, then Mantis auto recovered. SAS logs show reservation/mode churn and conflicts such as selected target already reserved by an Ant.
10. For front-load-sensor deposit failures, correlate UI/video, GPIO, CAN, and container state.
   - `c134-0386`: FLO showed M-A2-S1-1 deposit/unload failed for `TOTE-L-600431`; WAS later logged `container.orphaned` from `M-A2-S1-1`; NXP sampled GPIO transitions but no direct `COMPLETE_FAILURE` line proving root cause.
11. For `ARM_MOTOR_SINGLE#following error`, separate motor/driver fault from external load.
   - `c134-0010`: UI error `[ERROR]1102#NODE402_ERROR#ARM_MOTOR_SINGLE#following error, 55299`; NXP recorded `node402 fault history recorded: ARM_MOTOR_SINGLE#following error, 55299` and `MoveArms -> FaultReaction`; source notes `A2-S2-B5-PT1` had not replaced sheet metal, and photo shows tote skew/contact risk.
   - `c134-0155`: UI and NXP both show `ARM_MOTOR_SINGLE#following error, 55347`; photo shows tote not fully pulled into the access area.
   - `c134-0085`: UI/NXP show `ARM_MOTOR_SINGLE#following error, 55344`; CAN1 was 0KB and unavailable.
   - `c134-0096`: UI error `[ERROR]1102#NODE402_ERROR#ARM_MOTOR_SINGLE#following error, 55386`; CAN pcaps are available but NXP/wormhole are not, so external load versus motor branch remains unresolved.
   - `c134-0141`: UI error `[ERROR]1102#NODE402_ERROR#ARM_MOTOR_SINGLE#following error, 55355`; photo shows tote skew/tilt at `A2-S2-B2`, making external load/PT geometry a high-value branch.
   - `c134-0204`: UI error `[ERROR]1102#NODE402_ERROR#ARM_MOTOR_SINGLE#following error, 55490`; photo shows tote visibly skewed/tilted at `A2-S2-B5`.
   - `c134-0205`: UI error `[ERROR]1102#NODE402_ERROR#ARM_MOTOR_SINGLE#following error, 10277`; source reports tote skew at `A3-S2-B12-PT`.
   - `c134-0153`: PDA/NXP show repeated `ARM_MOTOR_SINGLE#following error` values `10217` and `10245`.
   - `c134-0154`: NXP shows repeated `ARM_MOTOR_SINGLE#following error` values `55317` and `55423`; field photo shows tote partly in the access area.
   - `c134-0172`: UI and NXP both show `ARM_MOTOR_SINGLE#following error, 55388`; photo shows tote partly in the access/pull area.
   - `c134-0289`: UI/NXP show `ARM_MOTOR_SINGLE#following error, 55225`; field inspection found no abnormal interference but measured Mantis托箱面 about 1 mm higher than the access-position托箱面.
   - `c134-0327`: UI/NXP show `ARM_MOTOR_SINGLE#following error, 55405`; field inspection found the tote partly riding on the limit strip/限位条.
   - `c134-0369`: UI/NXP show `ARM_MOTOR_SINGLE#following error, 55272`; source preliminary judgment was tote skew.
   - `c134-0229`: UI error `1102#NODE402_ERROR#ARM_MOTOR_SINGLE#following error, 55341`; field photo showed tote partly on the B1-side挡边, making mechanical load/interference a high-value branch.
   - `c134-0076`: UI error `1102#NODE402_ERROR#ARM_MOTOR_SINGLE#following error, 55214`; NXP/wormhole at failure time were 0KB, so backend logs alone cannot prove motor hardware failure.
   - `c134-0357`: NXP records `ARM_MOTOR_SINGLE#following error, 10307` and `MoveArms -> FaultReaction`; photo shows tote in access/pull area, but exact contact/load cause is unresolved.
12. For `ARM_MOTOR_SINGLE#stall`, inspect physical obstruction and excessive load first.
   - `c134-0156`: UI showed `1102#NODE402_ERROR#ARM_MOTOR_SINGLE#stall`; NXP recorded `node402 fault history recorded: ARM_MOTOR_SINGLE#stall, 56614` and `MoveArms -> FaultReaction`; photo shows tote close to side guide/access mechanism.
13. For deposit/unload following error, inspect shelf/tote clearance before motor hardware.
   - `c134-0270`: UI/NXP show `ARM_MOTOR_SINGLE#following error, 10260` while depositing `TOTE-H-101665`; field inspection found tote bottom interfered with shelf crossbeam/横梁.
   - `c134-0259`: source concludes Mantis plane was lower than shelf/storage position at `B7-L15-T4`; adjust Mantis deposit height before chasing motor hardware.
   - `c134-0434`: FLO shows `M-A1-S1-1` `ARM_MOTOR_SINGLE#following error, 55259` while extracting `TOTE-H-100281`; source says `A1-S2-B4` pick position needs lowering `6MM`, so height/access geometry is the first branch.
   - `c134-0430`: FLO shows `M-A2-S1-1` `ARM_MOTOR_SINGLE#following error, 10040` while extracting `TOTE-L-600316`; source says `A2-S2-B6` whole pick is biased toward `B1`, matching offset/external-load before motor-hardware diagnosis.
14. For command-cache errors, inspect RCS/RMS command lifecycle before hardware.
   - `c134-0013`: `"Could not get RobotCommand ... from local commands dictionary"` while mechanism had not extended; clear plus reset arms recovered.
15. For anti-pinch sensor mismatches, verify physical obstruction and IO mapping.
   - `c134-0008`: UI showed `antiPinchSensors front - Expected: False Actual: True`; field text said fork was not blocked and tote was not clamped.
   - `c134-0425`: NXP confirmed `PIN_SENSOR_ANTIPINCH_RIGHT is not as expected. expected value: false, actual value: true` and `FUTURE_STATE_NOT_MATCH#PIN_SENSOR_ANTIPINCH_RIGHT#Expected: false#Actual: true`; repeated GPIO toggles support sensor/IO instability branch.
   - `c134-0431`: backend state showed `antiPinchSensors.left=true` while `M-A3-S2-2` was idle/no obstacle and task failed with `[WARNING]FUTURE_STATE_NOT_MATCH#PIN_SENSOR_ANTIPINCH_LEFT#Expected: false#Actual: true`; fault-time NXP/wormhole logs were 0 B.
   - `c134-0303`: FLO screenshot marked `Anti-pinch Rear`; field inspection found fork looseness, and later maintenance suspected belt pressure-block looseness causing belt looseness.
16. For image/text-only pull-offset cases, accept the operational offset conclusion but keep the root cause bounded.
   - `c134-0368`: `A2-S2-B12-L10-T3` pull failed; arm biased toward `B13`; source action was adjusting pull offset toward `B1` about `7mm`.
   - `c134-0432`: `A2-S2-B6` 13:13 pull failed; whole pick biased toward `B1`; same location recurred in `c134-0430` at 18:53 with FLO following error.
   - `c134-0435`: title says `M-A3-S2-1`, body says `M-A2-S2-1`; `A3-S2-B5-L5-T4` pull failed and source action was adjusting toward `B1` by `3-4mm`. Preserve the robot-label conflict.

## Evidence Strength Matrix

| Evidence | Diagnostic strength | Use it for | Do not use it for |
|---|---|---|---|
| UI + NXP node402 following/stall error | strong | Mantis arm/fork fault branch | physical root cause alone |
| CAN quick stop / `60FD` / TPDO timing | strong | firmware/IO timing branch | scheduler-only conclusion |
| 1 mm `coordY` expected/actual mismatch | strong | access-node/offset config branch | motor replacement |
| torque >200% or speed collapse | strong | external load/interference branch | pure software conclusion |
| SAS `No PDs or Tunnels available` | strong | scheduler target-selection branch | actuator fault |
| missing local `RobotCommand` | strong | command lifecycle/cache branch | mechanical fault first |
| anti-pinch expected false actual true with GPIO toggles | strong | sensor/wiring/debounce branch | arm motor root cause |
| image-only offset or tote skew | medium | operational geometry branch | firmware or motor proof |
| 0KB NXP/CAN/wormhole logs | weak/blocking | asset request | negative proof |

## Pattern Library

- Quick stop / missed IO / stale target-reached: `c134-0267`, `c134-0272`, `c134-0274`; check TPDO mode and firmware semantics.
- 1 mm expected-state mismatch: `c134-0351`, `c134-0140`, `c134-0316`; audit access-node offsets before hardware.
- No deposit target / scheduler contention: `c134-0311`; route SAS/PD/tunnel selection first.
- External load, high torque, PT deformation: `c134-0362`, `c134-0318`, `c134-0364`; video/torque/contact evidence outranks motor swap guesses.
- ARM following error with physical interference: `c134-0270`, `c134-0229`, `c134-0327`, `c134-0010`, `c134-0155`; inspect tote bottom, side guide, limit strip, and shelf clearance.
- Height/offset geometry corrections: `c134-0259`, `c134-0430`, `c134-0432`, `c134-0434`, `c134-0435`; accept operational fix while keeping firmware/motor cause unproven without logs.
- Anti-pinch/sensor mismatch: `c134-0008`, `c134-0425`, `c134-0431`, `c134-0303`; separate physical obstruction from IO instability.
- Command dictionary/cache desync: `c134-0013`; inspect RCS/RMS command lifecycle before mechanism inspection.
- Logs missing or 0KB: `c134-0076`, `c134-0085`, `c134-0303`, `c134-0431`; keep diagnosis unresolved even when UI error is clear.

## Evidence Needed

- RMS/RCS command-set lifecycle with command index and timestamps.
- NXP logs for HSM, node402, quick stop, target reached, state mismatch.
- CAN logs for pull motor, fork, finger motors, `60FD` IO, TPDO timing.
- SAS task/container and available shelf/PD/tunnel selection logs.
- access node and accessNodeOffset config for rest, load, deposit points.
- torque curves for pull/fork/finger motors.
- video/photo showing tote position, fork extension, finger position, PT/PD deformation/interference.
- photos/videos showing sensor panel state, fork looseness, belt pressure-block condition, and belt tension.
- robot label from wormhole/MQTT when title text is ambiguous.
- UI screenshots for exact FLO/Fleet errors such as `ARM_MOTOR_SINGLE#following error`, `ARM_MOTOR_SINGLE#stall`, `antiPinchSensors front`, and missing `RobotCommand`.

## Logs And Files To Inspect

- NXP logs, especially quick stop and target-reached sequence.
- candump/CAN for pull motor/finger motor state, torque, IO.
- RMS/RCS `robot_command_set.create` and command lifecycle dumps.
- SAS `SelectDepositService`, `FindClosestAvailableShelfService`, robot task create logs.
- access node/offset database rows for affected location.
- monitor video around physical contact or failed extend/pull.
- RCS/RMS command dictionary and command-set lifecycle when the UI says `Could not get RobotCommand`.

## Likely Causes

- pull motor quick stop plus missed IO event / firmware target-reached behavior: `c134-0267`, `c134-0272`, `c134-0274`
- expected-state mismatch due to 1 mm offset difference: `c134-0351`, likely `c134-0316`
- expected-state mismatch due to 1 mm `coordY` difference before `EXTEND`: `c134-0140`
- location-specific offset bias: `c134-0186`, `c134-0187`
- no available deposit target / duplicate deposit contention: `c134-0311`
- mechanical interference or PT/PD deformation: `c134-0318`, `c134-0362`, `c134-0364`
- incomplete logs preventing root-cause proof: `c134-0079`, `c134-0308`, `c134-0316`
- limited startup/CANopen evidence with physical tote-skew symptom: `c134-0195`
- scheduler/traffic sequencing deadlock after Mantis避让: `c134-0054`
- scheduler/traffic/mode interlock causing Mantis shaking/blocked Ant recovery dependency: likely branch for `c134-0026`
- front-load-sensor/tote-state mismatch during Mantis deposit: `c134-0386`
- command dictionary/cache desync or missing command record: `c134-0013`
- anti-pinch sensor active when expected false: `c134-0008`, `c134-0431`
- right anti-pinch sensor active during arm return/deposit command: `c134-0425`
- rear anti-pinch trigger due to mechanical looseness around fork/belt: likely `c134-0303`
- external load/mechanical interference causing arm following error: likely branch for `c134-0010`, `c134-0155`, `c134-0172`, `c134-0229`; unresolved for `c134-0076`
- tote/limit-strip/shelf clearance interference causing arm following error: `c134-0270`, likely `c134-0204`, `c134-0205`, `c134-0327`, branch for `c134-0369`
- Mantis deposit plane lower than shelf plane / height mismatch: `c134-0259`
- Mantis pull/access offset or height mismatch: `c134-0368`, `c134-0430`, `c134-0432`, `c134-0434`, `c134-0435`
- small access-height mismatch contributing to arm following error: branch for `c134-0289`
- external obstruction/excessive load causing arm stall: likely branch for `c134-0156`

## Exclusion Checks

- Tote is already in target location: do not assume pull failed physically; inspect premature command complete and sensor mismatch.
- No metal interference visible after clear: still inspect quick stop and motor state; quick stop may have been transient.
- Expected/actual coordinate differs by 1 mm at A2: inspect offset config before hardware.
- Torque >200%: prioritize physical interference, deformation, or tote/finger contact.
- No RMS logs: classify as unresolved and request reproduction logs; do not invent conclusion.
- Same task has no available PD/tunnel: route to scheduler/traffic, not Mantis actuator first.
- Startup `failed to sdo client download` or LED-type errors are evidence, but not enough to prove the tote-skew root cause without the command/pull window.
- A Mantis traffic deadlock with successful device commands should not be treated as a Mantis actuator fault first.
- If Mantis shaking clears only after an Ant below leaves, inspect reservations, mode changes, and shared access-zone occupancy before motor hardware.
- UI says front load sensor error: verify against video and CAN/GPIO mapping before replacing the sensor.
- UI says `ARM_MOTOR_SINGLE#following error`: inspect tote skew,挡边 contact, and arm load before concluding motor/driver failure.
- Source says Mantis plane is lower than shelf/货位: measure and adjust deposit height/access-node offset before motor debugging.
- UI says `ARM_MOTOR_SINGLE#stall`: inspect physical obstruction, tote side-guide contact, and torque/current before concluding motor/driver failure.
- UI says missing `RobotCommand`: inspect command lifecycle/local dictionary/cache first; mechanical inspection is secondary if the mechanism did not move.
- `coordY` differs by 1 mm before `EXTEND`: inspect access-node/offset generation and tolerance before replacing Mantis hardware.
- Left anti-pinch true with no physical neighbor/obstacle: inspect sensor, wiring, IO mapping, and debounce before concluding scheduler failure.
- Right/top anti-pinch future-state mismatch during arm movement: inspect GPIO pulse timing, wiring, IO mapping, and physical obstruction before replacing arm motor hardware.
- Rear anti-pinch trigger with field-visible fork/belt looseness: inspect mechanical mounting and belt pressure block before replacing sensor/electronics.
- Image/text-only offset recommendations are operationally useful but not enough to prove motor, driver, or firmware root cause.
- `ARM_MOTOR_SINGLE#following error` with a field offset/height recommendation should be routed through geometry/load checks before replacing motor hardware.

## Handling Recommendations

- Keep CAN logging enabled for Mantis quick-stop cases.
- Update motor firmware for quick-stop target-reached behavior and TPDO event-triggered IO reporting where applicable.
- Normalize or audit accessNodeOffset values around A2/A3 rest/load/deposit points.
- For repeated B2/PT failures, inspect sheet metal, tote height, finger contact, and torque rather than relying on manual no-resistance checks.
- For Mantis with tote and no action, inspect SAS available-location selection and duplicate deposit task generation.
- Preserve RMS logs before clear/reset; many cases become unrecoverable without them.
- Trust exact robot labels and asset filenames (`M-A2-S1-1`, `A2巷道螳螂`) over a stale `Ant` extraction label.
- For repeated same-location Mantis failures such as `A2-S2-B6`, compare before/after access-node offsets and keep FLO screenshots with exact following-error codes.

## Confirmed Examples

- `c134-0267`: quick stop, missed short IO event risk, stale target-reached after operation enabled, and premature complete explain tote placed but command failure.
- `c134-0351`: `coordY` mismatch `11341` vs expected `11342` traced to offset `-7` versus `-6`.
- `c134-0140`: `coordY` mismatch `18067` vs expected `18068` blocked `EXTEND`; manual move to Bay1 recovered operation.
- `c134-0311`: two Ant deposit tasks were generated when only one A2 position was available, leaving Mantis with tote and no deposit path.
- `c134-0362`: high fork torque/interference lifted tote tail, disturbed fingers, and left tote partly on Mantis.
- `c134-0364`: tote not placed correctly and finger motors 3/4 stalled, likely finger hit tote.
- `c134-0054`: M1/A-104/A-106 deadlock was operationally explained by Mantis避让/task sequencing and blocked return path.
- `c134-0026`: Mantis shaking plus stopped Ant below was operationally recovered by computer-side manual mode allowing the Ant to leave; logs point to scheduler/reservation/mode interaction, not confirmed motor fault.
- `c134-0013`: missing local `RobotCommand` caused extraction/load failure before mechanism extension; clear plus reset arms recovered.
- `c134-0270`: deposit/unload following error `10260` was operationally explained by tote-bottom interference with shelf crossbeam/横梁.
- `c134-0259`: A2 `B7-L15-T4` deposit failure was operationally attributed to Mantis plane lower than the shelf position; recommended action was adjusting Mantis deposit height.
- `c134-0303`: FLO marked `Anti-pinch Rear`; field inspection found fork looseness and likely belt pressure-block looseness, making mechanical maintenance the primary branch.
- `c134-0368`: `A2-S2-B12-L10-T3` pull failure was operationally attributed to arm bias toward `B13`; recommended offset correction was toward `B1` about `7mm`.
- `c134-0430` and `c134-0432`: repeated `A2-S2-B6` M2 pull failures were operationally attributed to pick offset bias toward `B1`; `c134-0430` additionally records `ARM_MOTOR_SINGLE#following error, 10040`.
- `c134-0434`: `A1-S2-B4` M1 pull failure records `ARM_MOTOR_SINGLE#following error, 55259`; source action was lowering the pick position by `6MM`.
- `c134-0435`: `A3-S2-B5-L5-T4` pull failure source action was adjusting toward `B1` by `3-4mm`; robot label remains inconsistent between title and body.

## Unresolved Examples

- `c134-0079`: missing RMS logs block task sequence analysis.
- `c134-0308`: no RMS logs; only similar to prior A2 offset/state issue.
- `c134-0316`: failed task and 1 mm EXTEND mismatch observed, but logs rolled off.
- `c134-0317`, `c134-0318`: repeated B2 PT failures suggest mechanical/torque issue; exact root cause not confirmed.
- `c134-0195`: A2 pull failure with skewed tote; NXP only has startup `canopen_stack`/`node_led` errors and MQTT label `M-A2-S1-1`, so root cause remains unresolved.
- `c134-0386`: M2 deposit/unload failed for `TOTE-L-600431`; source claims front load sensor error and logs show later orphaned tote state, but sensor/CAN root cause is unresolved.
- `c134-0008`: front anti-pinch expected/actual mismatch was visible and recovered after initialize, but sensor hardware versus transient signal remains unproven.
- `c134-0431`: left anti-pinch false trigger/stuck true caused `FUTURE_STATE_NOT_MATCH`; sensor hardware, wiring, IO mapping, and debounce branch remains unresolved because NXP/wormhole logs were 0 B.
- `c134-0425`: right anti-pinch false trigger caused `FUTURE_STATE_NOT_MATCH`; NXP confirms sensor mismatch and GPIO toggles, but exact physical versus electrical cause remains unresolved.
- `c134-0076`: `ARM_MOTOR_SINGLE#following error, 55214`; fault-time NXP/wormhole logs were 0KB, so root cause remains unresolved.
- `c134-0085`: `ARM_MOTOR_SINGLE#following error, 55344`; CAN1 was 0KB, so motor/driver versus external-load branch remains unresolved.
- `c134-0096`: `ARM_MOTOR_SINGLE#following error, 55386`; CAN pcaps and images exist, but NXP/wormhole logs are absent and decoded CAN/physical cause remains unresolved.
- `c134-0141`: `ARM_MOTOR_SINGLE#following error, 55355`; photo shows tote skew at `A2-S2-B2`, but NXP/CAN/RMS are absent.
- `c134-0204`: `ARM_MOTOR_SINGLE#following error, 55490`; photo shows tote skew at `A2-S2-B5`, but NXP/CAN/RMS are absent.
- `c134-0205`: `ARM_MOTOR_SINGLE#following error, 10277`; source reports tote skew at `A3-S2-B12-PT`, but NXP/CAN/RMS are absent.
- `c134-0010`: `ARM_MOTOR_SINGLE#following error, 55299`; NXP confirms `MoveArms -> FaultReaction`, and source/photo suggest PT sheet-metal or tote skew/contact branch, but exact cause remains unresolved.
- `c134-0153`: repeated following errors `10217` and `10245`; exact physical/CAN cause remains unresolved.
- `c134-0154`: repeated following errors `55317` and `55423`; photo shows incomplete pull, but exact physical or motor cause remains unresolved.
- `c134-0155`: `ARM_MOTOR_SINGLE#following error, 55347`; NXP confirms fault history and photo shows incomplete pull, but exact physical or motor cause remains unresolved.
- `c134-0156`: `ARM_MOTOR_SINGLE#stall, 56614`; NXP confirms stall and photo shows side-guide/contact risk, but exact obstruction or hardware cause remains unresolved.
- `c134-0172`: `ARM_MOTOR_SINGLE#following error, 55388`; NXP confirms fault history and photo shows tote in access area, but exact cause remains unresolved.
- `c134-0229`: `ARM_MOTOR_SINGLE#following error, 55341` with tote partly on B1-side挡边; likely external load/interference branch, but exact motor/CAN proof remains unresolved.
- `c134-0289`: `ARM_MOTOR_SINGLE#following error, 55225`; field found no direct interference but about 1 mm height mismatch, so cause remains unresolved.
- `c134-0327`: `ARM_MOTOR_SINGLE#following error, 55405`; tote partly riding on limit strip/限位条 is strong physical evidence, but CAN torque proof is not closed.
- `c134-0357`: `ARM_MOTOR_SINGLE#following error, 10307`; NXP confirms fault transition and photo shows tote in access area, but physical/CAN root cause remains unresolved.
- `c134-0369`: `ARM_MOTOR_SINGLE#following error, 55272`; source observed tote skew, but exact contact point/CAN proof remains unresolved.
- `c134-0217`: `A2-S2-B2` PT取箱失败 with complete CAN/NXP assets; NXP text search found no node402 fault/following-error string, so RMS/FLO error and CAN decoding are still needed.
- `c134-0168`: `A3-S2-B9` pull failure with only images; source says No.2 Mantis could not be connected, so logs could not be extracted.
- `c134-0303`: NXP/wormhole were 0KB, so firmware/CAN branch is not closed even though mechanical evidence is strong.
- `c134-0368`, `c134-0430`, `c134-0432`, `c134-0434`, `c134-0435`: no NXP/CAN/RMS/SAS logs were provided, so motor/driver/firmware root cause is not closed.

## Specialist Routing

- `mantis-handling`: fork/finger/arm state, PT/PD geometry, quick stop, tote handling.
- `can-bus`: motor state machine, TPDO, IO pulse, torque and target-reached semantics.
- `embedded-software`: NXP HSM/node402 handling, firmware behavior after quick stop.
- `scheduler-traffic`: available PD/tunnel selection, duplicate deposit contention, task state.
- `vision-media`: tote/finger/PT interference, physical position, deformation, recovery sequence.
