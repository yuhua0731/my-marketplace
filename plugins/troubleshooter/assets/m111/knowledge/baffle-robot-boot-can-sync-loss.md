# Baffle Robot Boot CAN Sync Loss After Firmware Update

## Symptoms

- M111 baffle robot probabilistically fails to boot after a firmware update.
- Source symptom says the robot flashes orange light at `2026-05-07 16:42:39`.
- The visible status table maps `橙色闪烁` to `CAN同步帧丢失` and `需要人工处理`.
- NXP log repeatedly reports CANopen SDO upload failures to `node_id 1`, `index 6064`, `sub_index 0`.

## Fault Tree

- Confirmed branch: CANopen communication to motor node 1 is not completing.
  - `retry-source-DFRxbVBeFobzBYxrXWycfXXAnvh.log` contains `15113` lines of `CO_SDOclientUpload error: -11`.
  - `15097` lines target `index 6064 sub_index 0 node_id 1 abort code: 84148224`.
  - Abort code `84148224` is `0x05040000`, consistent with CANopen SDO timeout.
- Likely branch: firmware update exposed a CANopen boot/sync/initialization incompatibility.
  - The case source explicitly ties the symptom to `更新固件`.
  - The same log contains repeated bootloader/reboot markers, `Proceed to reset all nodes`, and node heartbeat timeouts for nodes `1`, `2`, and `3`.
- Likely branch: motor node 1 does not reach a stable operational state before the application reads object `0x6064`.
  - The failing object `0x6064` is the CANopen position actual value.
  - Repeated reads every about 100 ms should be treated as a diagnostic symptom, not as proof that position feedback is the root cause.
- Excluded branch: orange flashing alone proves firmware defect.
  - Orange flashing is only a state indicator for CAN sync loss; it must be paired with logs or CAN frames.
- Blocked branch: video-confirmed LED sequence and physical boot timing.
  - Local MOV exists, but this environment has no `ffmpeg`/`ffprobe`, and ImageMagick cannot decode it without ffmpeg.

## Evidence Needed

- Raw CAN frames or candump/pcap from boot through the first orange flashing state.
- Exact firmware version, commit, build target, object dictionary/EDS, node-ID map, bitrate, SYNC producer settings, and heartbeat timeout settings.
- Successful-boot comparison log from the same robot and same firmware.
- Confirmation that `retry-source-CS3tbdsMToP1k3xf5ntcysFXnSc.hex` is the exact firmware flashed to the failing device.
- Decodable video frames or onsite observation showing boot sequence, LED state changes, and timing relative to log timestamps.
- Wiring, termination, power-rail, and node-1 motor/controller inspection if the failure remains after firmware rollback or config correction.

## Logs And Files To Inspect

- `assets/m111-pt-0116/retry-source-DFRxbVBeFobzBYxrXWycfXXAnvh.log`: strip ANSI escapes, then search `CO_SDOclientUpload error`, `index 6064`, `node_id 1`, `abort code: 84148224`, `heartbeat timeout`, `Proceed to reset all nodes`, `Booting MCUboot`, and `main task exception`.
- `assets/m111-pt-0116/retry-image-001-KKZ0bWNlXogsZYxTy4lcMdcKnLQ.png`: status table only; use it to interpret orange flashing as `CAN同步帧丢失`, not as root-cause evidence.
- `assets/m111-pt-0116/retry-source-IZBhbnwAaoJkKlxXkJ1cX9ywnHd.MOV`: video attachment; needs ffmpeg or another decoder before visual facts can be claimed.
- `assets/m111-pt-0116/retry-source-CS3tbdsMToP1k3xf5ntcysFXnSc.hex`: firmware artifact; no readable diagnostic strings were found in basic ASCII inspection.

## Likely Causes

- Firmware/config mismatch after update: wrong object dictionary, node-ID expectation, heartbeat/SYNC timing, bitrate, or boot order.
- CANopen node 1 reset or pre-operational state while the application repeatedly reads `0x6064`.
- CAN bus or node power instability that manifests during boot and causes node heartbeat timeouts.
- Application startup loop that treats repeated SDO timeout as a recoverable poll instead of failing fast with a clear CAN sync diagnostic.

## Exclusion Checks

- Exclude pure network/MQTT fault only if CANopen SDO timeout and node heartbeat loss are absent; `mqtt_service: iface ... not ready` appears during boot but is not the strongest symptom here.
- Exclude LED-board/display fault only if logs and CAN frames show normal SYNC, heartbeat, and SDO reads while the LED still flashes orange.
- Exclude motor position sensor fault only if node 1 is operational and CAN transport is healthy but object `0x6064` returns invalid position values.
- Exclude firmware regression only after reproducing both old and new firmware with the same hardware, node-ID map, and CAN capture.

## Confirmed Examples

- `m111-pt-0116`: after firmware update, M111 baffle robot probabilistically failed to boot and flashed orange. Log from `2026-05-07T08:30:35Z` through `09:39:34Z` repeatedly reports `CO_SDOclientUpload error: -11, index 6064 sub_index 0 node_id 1 abort code: 84148224`; the same log includes bootloader/reboot markers and node heartbeat timeout events.

## Unresolved Examples

- `m111-pt-0116`: root cause remains unresolved because raw CAN frames, firmware version mapping, successful-boot comparison, and decodable video evidence are missing.

## Specialist Routing

- Start with `embedded-software` for firmware build, boot order, reset loop, object dictionary, and startup state machine.
- Add `can-bus` for SYNC, heartbeat, SDO timeout, node-ID, bitrate, termination, and bus capture.
- Use `vision-media` only after the MOV can be decoded to confirm LED sequence and boot timing.
