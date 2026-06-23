# Scheduler Config Hardlink Loss Causing Invalid Motion Command

## Symptoms

- OmniSort / M145 starts successfully, system overview shows running state, but the robot does not physically move as expected.
- Robot map position and actual robot position diverge.
- Robot eventually reports `END CMD TIMEOUT ERROR`, for example `seq: 28, timeout: 600s`.
- Logs show move commands with physically impossible parameters, such as `speed: 200`, `acc: 397887`, and `dec: 397887`, even though the visible scheduler configuration shows normal values.

## Fault Tree

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

## Evidence Needed

- Runtime log line containing `move_cmd payload` for the failing robot.
- UI/screenshot or file content showing expected scheduler config values.
- Actual filesystem paths used by the running scheduler process and UI editor.
- Hardlink/symlink/inode check for the config file across deployment directories.
- Robot state timeline around start, move command, ack, timeout, and emergency/stop commands.
- Physical/map position screenshot or video if position mismatch matters.

## Logs And Files To Inspect

- Search logs for `move_cmd payload`, `speed`, `acc`, `dec`, `END_CMD_TIMEOUT_ERROR`, `END CMD TIMEOUT ERROR`, `STATE_MOVE`, `STATE_ERROR`, `ack_cmd payload`, and the robot ID such as `M002`.
- Inspect scheduler config values: `vehicle_origin_max_speed`, `vehicle_acceleration`, `vehicle_boost_acceleration`, `delivery_rack_horizontal_track_len`, `numHorizontalTracks`.
- Check deployment paths under the running service account, especially whether UI-edited config and scheduler-read config are the same inode or intended link target.

## Likely Causes

- Scheduler config hardlink loss or duplicated config directories is likely when visible config values are normal but runtime command payload uses extreme values.
- Invalid motion command parameters are likely to cause robot non-execution or timeout even if the robot is connected and powered.
- Position mismatch is a downstream symptom when scheduler believes the robot moved or is at a target while the robot physically did not execute the invalid command.

## Exclusion Checks

- If runtime `move_cmd payload` speed/acc/dec are normal, do not blame config hardlink loss from this pattern alone.
- If the robot is disconnected or voltage/power is abnormal, resolve connectivity/power before interpreting motion timeout.
- If UI and running scheduler are proven to read the same config file and inode, inspect config parsing, unit conversion, default fallback, or cached config.
- If only screenshots are available, treat command payload and config values as screenshot evidence; raw log/config files are needed for exact file-path proof.

## Confirmed Examples

- `m145-pt-0155`: M145 opened in self-test mode at `2026-06-11 13:55:54`; after successful startup, robot did not run and map position differed from actual position.
  - Overview screenshot at `2026-06-11 14:02:35` shows system running, M002 displayed near `B4-4`, while the annotated actual robot position is around the middle track area.
  - Robot page shows M002 online with voltage `56.4V` and state `去装货点`.
  - Alarm screenshot at `2026-06-11 14:01:27` shows `END CMD TIMEOUT ERROR`, `seq: 28`, `timeout: 600s`.
  - Log screenshot at `2026-06-11T14:03:02.032000+0800` shows `move_cmd payload` with `position: 3.54`, `speed: 200`, `acc: 397887`, `dec: 397887`.
  - Earlier log screenshot at `2026-06-11T13:56:58.739000+0800` shows the same invalid motion parameters followed by command timeout behavior.
  - Config screenshots show normal values: `vehicle_origin_max_speed: 1`, `vehicle_acceleration: 3.5`, `vehicle_boost_acceleration: 3.2`.
  - Source resolution states the excessive speed was caused by scheduler file configuration error, and checking found multiple directories with hardlink loss.

## Unresolved Examples

- `m145-pt-0155` lacks raw log and filesystem command output, so the exact duplicate paths/inode relationship is not directly verified in local assets.
- The case proves the M145 symptom pattern, but the same rule should be rechecked when another project uses a different scheduler deployment layout.

## Specialist Routing

- `scheduler-traffic`: runtime command payload, scheduler config source, service restart, task/position state.
- `embedded-software`: robot state machine response to invalid motion command, timeout/error transition.
- `network-infra`: only if robot connectivity or service path prevents config/command delivery.
- `vision-media`: UI screenshots, map-vs-physical position mismatch, visible robot state.
