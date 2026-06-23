# M145 Troubleshooting Playbook

Use this as the human-readable entrypoint before specialist routing.

## Global Process

1. Record exact symptom, timestamp, robot ID, station/location, task/container ID, and available filenames.
2. Classify the case by observed symptom, not by incidental WS/robot/location words.
3. Load the matching knowledge file and traverse the highest-value fault branch first.
4. Mark every branch as `confirmed`, `likely`, `excluded`, or `blocked`.
5. Treat unavailable videos, images, logs, and chat records as missing assets, not analyzed evidence.
6. Stop only at confirmed root cause, sufficient operational conclusion, or excluded branch.

## Route Order

- Reboot, shutdown, charging, low voltage: embedded-software first, then can-bus/scheduler/network.
- Shutdown blocked after robot lock/manual lock: scheduler-traffic first, then embedded state-machine only if logs show command/state failure.
- DM code loss, deviation, angle, collision precursor: robot-motion first, then embedded/can-bus/media.
- Disconnect, AP, MQTT, Kafka, RVS, site-wide service symptoms: network-infra first.
- Lift, tote, fork, arm, PT/PD, quick stop: handling specialist plus embedded/can-bus/media.
- Mechanical scrape, bracket contact, drag-chain sag, rail interference: vision-media first, then robot-motion/hardware evidence; embedded only if motion logs implicate control behavior.
- Task assignment, locks, no-action, deadlock/interlock: scheduler-traffic first.
- Robot ALLCAN-LED or body state lights stuck on initialization color: embedded-software first, then can-bus/media if state-frame or visual evidence exists.
- WLED/HLED/light strip, workstation sensor/display/operator station: workstation; do not classify as Ant only because an Ant was nearby.

## CAN Gateway Function-Code Compatibility Hiding Feeder Stop Buttons

Knowledge file: `docs/m145/knowledge/can-gateway-function-code-compatibility-stop-button-display.md`

### First Checks

- Confirmed branch: overview button rendering depends on CAN gateway function-code mapping.
  - `m145-pt-0157` source says the uploaded function code was an old-version function code.
  - Source analysis says old function codes became incompatible after CAN gateway firmware upgrade.
  - Source resolution says the button display recovered after modifying the function code.
- Confirmed branch: compare relationship table with IO address variable table.
  - Relationship table screenshot shows `SITE-1`, CAN Node ID `1`, channel indexes `0o03` and `0o02`, function codes `PowerStopButton` and `UrgentStopButton`, MQTT topics `/PowerStopButton/SITE-1` and `/UrgentStopButton/SITE-1`.
  - IO address table `M145_IO地址变量表_V01.xlsx` shows feeder segment `ALL_CAN-4`, `1#9352 BUS-2`, `CAN-ID (DEC) = 1`.
  - The same IO table shows `DI03` is `暂停（黄）NO反馈` and `DI04` is `急停（红）NO反馈`.
- Likely branch: firmware upgrade changed accepted function-code names, semantics, or binding rules, so legacy `PowerStopButton` / `UrgentStopButton` entries no longer produce the expected frontend controls.
- Blocked branch: exact old-to-new function-code mapping is not visible in local assets.
  - No raw config before/after, gateway firmware version, frontend/service logs, or corrected relationship table is present.

### Evidence

- CAN gateway firmware version before and after the upgrade.
- Raw relationship configuration table before and after the fix.
- Exact accepted function-code names for the upgraded gateway firmware.
- Frontend/backend logs showing whether button metadata was ignored, filtered, or failed validation.
- CAN gateway/config-loader logs around upload and service restart.
- Post-fix overview screenshot showing feeder emergency-stop and pause buttons restored.

### Exclusions

- Exclude generic frontend outage if other overview widgets, status indicators, and system controls render normally.
- Exclude missing relationship upload only after confirming the running service read the uploaded table, not merely that the table exists locally.
- Exclude IO wiring or CAN electrical failure if the symptom is only missing UI buttons and there are no CAN heartbeat, input-state, or gateway communication alarms.
- Exclude firmware incompatibility only after checking the gateway firmware version against the function-code schema and corrected table.
- Do not infer the corrected function-code names from this case; require the fixed table or firmware schema.

### Examples

- `m145-pt-0157`: M145 overview does not display feeder emergency-stop/pause buttons. Source analysis says the uploaded function code was an old version and became incompatible after CAN gateway firmware upgrade. After modifying the function code, display recovered.

- `m145-pt-0157`: exact upgraded function-code names, firmware version, raw logs, and post-fix screenshot are not present in local assets.

## Drag Chain Sag Scraping Stainless Bracket

Knowledge file: `docs/m145/knowledge/drag-chain-sag-stainless-bracket-scrape.md`

### First Checks

1. Confirm the physical interference point first.
   - Inspect slow-motion video frames and onsite witness marks.
   - Mark the drag chain and stainless bracket contact side, height, and longitudinal position.
   - Measure static and dynamic clearance at the D door position.
2. Check drag-chain geometry.
   - Verify chain free length, mounting positions, bend radius, cable fill, and support span.
   - Excess length or unsupported span can let the chain fold downward into the bracket.
   - Wrong fixed/end mounting can shift the fold point into the local frame envelope.
3. Check bracket and frame envelope.
   - Compare the D door stainless bracket with neighboring sections.
   - Look for protruding edges, low bracket height, local deformation, or installation tolerance.
   - Confirm whether the bracket is inside the real dynamic motion envelope, not only the CAD static envelope.
4. Check motion and installation contributors.
   - Speed, acceleration, vibration, rail tilt, or robot installation skew can increase chain sag near one location.
   - Repeat passes at normal speed and reduced speed to separate geometry from dynamic excitation.
5. Validate correction.
   - Shorten/re-route/support the drag chain or modify the bracket only after contact point is confirmed.
   - Re-run full-travel passes through D door and inspect for noise, scrape marks, and clearance.

### Evidence

- Original video or high-frame-rate clip showing the contact instant.
- Close-up photos of drag-chain and stainless-bracket witness marks.
- Measured clearance at D door through full travel.
- Drag-chain length, bend radius, cable fill, and mounting position.
- Bracket drawing/BOM/version and installed height/offset.
- Before/after full-travel validation video after any mechanical change.

### Exclusions

- Do not call embedded/CAN/scheduler root cause without logs showing abnormal commanded motion or state transitions.
- Do not prescribe shortening the chain until bend radius, cable fill, and full-travel margin are checked.
- Do not blame the stainless bracket alone if the same bracket geometry works at other sections but this chain is longer or unsupported.
- Do not treat a single static photo as proof of clearance; the failure is reported during motion near D door.
- If the video does not show contact clearly, keep the branch as likely mechanical interference and record missing contact/witness-mark evidence.

### Examples

- `m145-pt-0159`: source says M145 drag chain is long; near D door, the drag chain folds downward and scrapes a stainless bracket. Local video is available and shows the drag-chain path near the rail/frame/bracket area.

- `m145-pt-0159`: extracted frames do not clearly show the exact scrape instant, measured clearance, wear marks, or final corrective action.

## Lift Belt Coefficient And Roller Diameter Mismatch

Knowledge file: `docs/m145/knowledge/lift-belt-coefficient-roller-diameter-small-parcel.md`

### First Checks

1. Confirm the visible feeding symptom with a minimum-size parcel.
   - Check whether the parcel leaves the lift module too late, stops before reaching the robot, or is measured shorter/longer than expected.
   - Preserve the command speed, test mode, parcel size, and affected library/site.
2. Measure actual belt speed instead of trusting the configured coefficient.
   - Use the same speed command for the lift-module belt and feeder belt.
   - Measure both belts with a tachometer or equivalent tool and compare in the same unit.
   - In `m145-pt-0166`, the lift-module reading is `35.525 m/min` (`0.592 m/s`) and the feeder reading is `48.795 m/min` (`0.813 m/s`).
3. Check whether the difference can be explained by reducer ratio.
   - Source chat says the lift-module reducer ratio is about `0.7` and the feeder ratio is about `0.71`; another screenshot says `14:20` vs `20:28`.
   - That small ratio difference does not explain a roughly 25% actual belt-speed gap.
4. Check roller diameter and mechanical coefficient.
   - Source chat says the lift-module roller diameter changed from `φ38` before M129 to `φ30` after M131.
   - Diameter ratio `30/38 = 0.789` is close to the measured speed ratio `35.525/48.795 = 0.728`.
   - If the lift-module coefficient stayed the same as the feeder coefficient after the roller diameter changed, commanded speed and actual belt speed diverge.
5. Validate correction at the production-library level.
   - Increase or recalibrate the lift-module belt coefficient according to mechanical parameters.
   - Apply the coefficient to all production libraries using this roller configuration.
   - Re-test minimum-size parcels and length measurement after the coefficient update.

### Evidence

- Raw before/after mechanical parameter or coefficient configuration.
- Controller or scheduler logs showing the commanded speed used for both belts.
- Tachometer measurement method, calibration, contact point, and repeated readings.
- Post-fix video/log proving minimum-size parcels reach the robot and length measurement is normal.
- List of production libraries that share the `φ30` lift-module roller configuration.

### Exclusions

- Do not blame feeder logic or scheduler sequencing before verifying actual belt speed under the same command.
- Do not treat reducer ratio as the root cause when the ratio difference is close to 1:1 and cannot explain the measured speed gap.
- Do not assume the coefficient is correct because the configuration file uses the same value for lift and feeder belts.
- Do not call the fix complete until minimum-size parcel delivery and length measurement are re-tested after coefficient update.
- If only screenshots are available, record missing raw config/log/post-fix evidence.

### Examples

- `m145-pt-0166`: source says M145 minimum-parcel feeding ends early. Under the same speed command, tachometer images show `35.525 m/min` on the lift-module belt and `48.795 m/min` on the feeder belt. Source analysis says the lift-module belt is about 25% slower; reducer ratios are close, but the lift-module roller changed from `φ38` to `φ30`. Resolution is to increase the lift-module belt coefficient and update all production libraries using the affected mechanical parameters.

- `m145-pt-0166`: raw before/after coefficient config, command logs, tachometer calibration/repeated readings, and post-fix parcel-delivery proof are not present in local assets.

## Overview Robot Width Scale Config Mismatch

Knowledge file: `docs/m145/knowledge/overview-robot-width-scale-config-mismatch.md`

### First Checks

1. Separate display geometry from motion geometry.
   - In `m145-pt-0156`, the visible symptom is on the Sort Control System overview page; no robot motion, collision, or loading failure is locally documented.
   - If the robot runs normally and only the icon is too wide, prioritize frontend/map rendering and config transformation.
2. Check parameter-table to runtime-config unit conversion.
   - Local parameter-table screenshot shows `机器人宽 (mm) = 674`.
   - Local config screenshot shows `positionMap.shuttleWidth: 0.674`.
   - These are consistent if the renderer expects meters, so do not stop at "width config is wrong".
3. Compare icon width against grid geometry.
   - Inspect `horizontalTrackLength`, `verticalTrackLength`, `gridCountInOneTrackSide`, slot/grid width, canvas/SVG scale, zoom level, and CSS transform.
   - Check whether robot width is drawn in the wrong axis, double-scaled, treated as pixels instead of meters, or compared to a grid cell using a different unit.
4. Confirm model/version selection.
   - The parameter-table note says large fixed parameter `655`, while the highlighted value is `674`; verify whether M145 should use `674`, `655`, or a model-specific override.
5. Root cause remains blocked until raw config and frontend/runtime payload prove the exact mismatch.

### Evidence

- Raw `rcs_config.json`, not only screenshot, including full `positionMap`.
- Frontend/API payload consumed by the overview page for `shuttleWidth`, track lengths, grid counts, and zoom.
- Renderer code or config mapping that converts meters/mm to pixels.
- Slot/grid width definition and physical/logical cell dimensions.
- Browser zoom/device pixel ratio and whether the screenshot is affected by page zoom.
- Before/after fix screenshot and commit/config diff.

### Exclusions

- Do not diagnose scheduler hardlink/config-loss unless command payloads or robot physical/map position diverge.
- Do not diagnose CAN gateway or IO function-code compatibility unless missing buttons or IO controls are involved.
- Do not diagnose mechanical width or collision without physical clearance, collision, loading, or motion evidence.
- Do not claim frontend renderer root cause from screenshots alone; require raw payload and scale calculation.

### Examples

- None. `m145-pt-0156` is evidence-limited but useful as a diagnostic pattern.

- `m145-pt-0156`: overview screenshot shows M001/M002/M003 robot icons wider than slot/grid cells. Parameter screenshot shows `机器人宽=674mm`, and config screenshot shows `shuttleWidth=0.674`; root cause is not proven because raw config, runtime payload, renderer code, grid width definition, and fix result are missing.

## Scheduler Config Hardlink Loss Causing Invalid Motion Command

Knowledge file: `docs/m145/knowledge/scheduler-config-hardlink-loss-invalid-motion-command.md`

### First Checks

1. Start from the command payload sent to the robot.
   - If the move command has impossible speed/acceleration/deceleration, prioritize scheduler/config read path before robot hardware.
   - If move parameters are normal, investigate robot communication, lock state, position map mismatch, and drive execution.
2. Compare source configuration with runtime command payload.
   - In the visible M145 config, `vehicle_origin_max_speed: 1`, `vehicle_acceleration: 3.5`, and `vehicle_boost_acceleration: 3.2` are normal.
   - Runtime command payloads show `speed: 200`, `acc: 397887`, and `dec: 397887`, so the runtime process is not using the expected config values.
3. Check deployment directory and hardlink/symlink consistency.
   - If the same scheduler/config file exists in multiple directories or a hardlink is lost, the UI may show one config while the running scheduler reads another.
   - Restarting or editing only the visible config is insufficient until the running path is confirmed.
4. Validate robot-side symptom after fixing config path.
   - Clear stale robot state and verify the next `move_cmd payload` has normal speed/acc/dec.
   - Confirm map position and physical position converge and no `END CMD TIMEOUT ERROR` recurs.

### Evidence

- Runtime log line containing `move_cmd payload` for the failing robot.
- UI/screenshot or file content showing expected scheduler config values.
- Actual filesystem paths used by the running scheduler process and UI editor.
- Hardlink/symlink/inode check for the config file across deployment directories.
- Robot state timeline around start, move command, ack, timeout, and emergency/stop commands.
- Physical/map position screenshot or video if position mismatch matters.

### Exclusions

- If runtime `move_cmd payload` speed/acc/dec are normal, do not blame config hardlink loss from this pattern alone.
- If the robot is disconnected or voltage/power is abnormal, resolve connectivity/power before interpreting motion timeout.
- If UI and running scheduler are proven to read the same config file and inode, inspect config parsing, unit conversion, default fallback, or cached config.
- If only screenshots are available, treat command payload and config values as screenshot evidence; raw log/config files are needed for exact file-path proof.

### Examples

- `m145-pt-0155`: M145 opened in self-test mode at `2026-06-11 13:55:54`; after successful startup, robot did not run and map position differed from actual position.
  - Overview screenshot at `2026-06-11 14:02:35` shows system running, M002 displayed near `B4-4`, while the annotated actual robot position is around the middle track area.
  - Robot page shows M002 online with voltage `56.4V` and state `去装货点`.
  - Alarm screenshot at `2026-06-11 14:01:27` shows `END CMD TIMEOUT ERROR`, `seq: 28`, `timeout: 600s`.
  - Log screenshot at `2026-06-11T14:03:02.032000+0800` shows `move_cmd payload` with `position: 3.54`, `speed: 200`, `acc: 397887`, `dec: 397887`.
  - Earlier log screenshot at `2026-06-11T13:56:58.739000+0800` shows the same invalid motion parameters followed by command timeout behavior.
  - Config screenshots show normal values: `vehicle_origin_max_speed: 1`, `vehicle_acceleration: 3.5`, `vehicle_boost_acceleration: 3.2`.
  - Source resolution states the excessive speed was caused by scheduler file configuration error, and checking found multiple directories with hardlink loss.

- `m145-pt-0155` lacks raw log and filesystem command output, so the exact duplicate paths/inode relationship is not directly verified in local assets.
- The case proves the M145 symptom pattern, but the same rule should be rechecked when another project uses a different scheduler deployment layout.

## Throwing Baffle Scraping Drive Shaft

Knowledge file: `docs/m145/knowledge/throwing-baffle-drive-shaft-scrape.md`

### First Checks

1. Confirm the contact point and witness marks.
   - Inspect close-up photos, slow-motion video, and onsite rub marks on the baffle edge, shaft, roller, bearing block, and belt surface.
   - Mark whether contact is static at rest, occurs during throwing motion, or only appears when the lift/throwing assembly vibrates.
   - Measure clearance through the full stroke and at the worst tolerance stack-up.
2. Check baffle/guard installation geometry.
   - Verify the baffle plate is not bent, skewed, reversed, shifted by slot clearance, or installed with the wrong spacer/washer stack.
   - Check screw tightness, locating surfaces, and whether the plate edge intrudes into the shaft/roller dynamic envelope.
3. Check active shaft, roller, and bearing-seat position.
   - Verify shaft axial position, bearing block alignment, wheel/roller runout, and whether fasteners or collars have walked outward.
   - Check whether the belt, roller cover, or adjacent throwing mechanism pushes the shaft side into the baffle clearance.
4. Check assembly tolerance and production variation.
   - Compare with another M145 unit or another lift module using the same baffle and shaft design.
   - Review drawings/BOM/change records for baffle thickness, bend radius, mounting hole position, spacer length, and shaft collar stack.
5. Validate correction dynamically.
   - After adjustment, trimming, spacer change, or part correction, run the lift/throwing cycle repeatedly under normal speed/load.
   - Re-check noise, rub marks, belt tracking, shaft heat, and clearance after vibration.

### Evidence

- Photos or video frame showing the exact contact point and rub/witness marks.
- Measured static and dynamic clearance between baffle/guard and active shaft/roller.
- Baffle plate drawing/BOM/version, mounting-hole tolerance, bend angle, spacer/washer stack, and installation orientation.
- Shaft/bearing-seat drawing or inspection record: axial position, runout, collar/fastener position, and bearing block alignment.
- Before/after validation video or inspection record after mechanical adjustment.

### Exclusions

- Do not call embedded/CAN/scheduler root cause without logs showing abnormal motion commands or unexpected state transitions.
- Do not prescribe trimming the baffle before confirming whether shaft/roller axial position or bearing-seat installation is out of tolerance.
- Do not prove clearance from one static photo; inspect the full throwing/lift cycle and post-run witness marks.
- Do not merge this with drag-chain scrape: this branch is local baffle/drive-shaft or roller interference inside the lift/throwing mechanism.
- If video tooling cannot extract full frames, record the limitation and rely only on visible photo/thumbnail evidence.

### Examples

- `m145-pt-0158`: source reports M145 lift-module throwing-mechanism baffle scraping the active drive shaft. Local photos show the baffle/guard plate and drive shaft/roller area with very small clearance; Quick Look video thumbnail shows the same assembly envelope.

- `m145-pt-0158`: no measured clearance, exact rub mark photo, drawing/BOM/version, shaft runout/axial-position measurement, or post-fix validation evidence is present. Full video frame extraction was unavailable because ffmpeg/Python video libraries were not installed.
