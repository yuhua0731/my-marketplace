# ALLCAN-S CAN Transceiver Failure

## Symptoms

- Returned ALLCAN-S boards power on, but CAN communication indicator alternates green/orange quickly, indicating CAN bus error.
- CAN node scan cannot find the board even when the board is powered and a terminator is connected.
- Multiple field-returned boards can show the same symptom, for example Amazon returned node-labeled boards `7`, `8`, `11`, and `12`.

## Fault Tree

1. Confirm basic board power first.
   - Measure MCU 3.3V rail.
   - Measure CAN transceiver 5V rail.
   - If either rail is missing or unstable, resolve power before replacing the CAN transceiver.
2. Confirm CAN scan setup.
   - Use CANAble or equivalent adapter, correct bitrate, wiring, and terminal resistor.
   - If the scan tool finds no node while power rails are normal, prioritize the CAN physical-layer branch.
3. Replace or isolate the CAN transceiver.
   - If replacing the transceiver restores node discovery, treat the transceiver as confirmed failed.
   - If replacement does not restore the node, continue with MCU firmware, CAN termination, wiring, soldering, ESD/overstress, and clock/reset checks.
4. Check version/known-issue context.
   - If the case matches a known ALLCAN-S issue and the source says `V07` fixes it, record hardware/software version and apply the known repair path.
   - Do not assume all ALLCAN-S bus errors are the same V07-fixed issue without power and scan evidence.

## Evidence Needed

- Photos or meter readings for MCU 3.3V and CAN transceiver 5V rails.
- CAN node scan before repair showing no nodes found.
- CAN node scan after repair showing the expected node IDs.
- Board labels, node IDs, hardware version, and firmware/version context.
- Repair record identifying the replaced chip, for example CAN transceiver `U4`.
- Video or screenshot of indicator behavior and scan procedure when available.

## Logs And Files To Inspect

- Search terms: `ALLCAN-S`, `ALL-CAN-S`, `CAN 通讯指示灯`, `绿橙交替`, `CAN 总线错误`, `CANAble`, `终端电阻`, `扫描节点`, `未找到节点`, `找到节点`, `CAN 收发芯片`, `CAN 收发器`, `U4`, `3.29V`, `5.32V`, `1000000 bps`, `V07`, `Amazon`.
- Inspect photos of the board and measurement points before interpreting node scan results.

## Likely Causes

- CAN transceiver damage is likely when MCU 3.3V and transceiver 5V supplies are present, node scan still finds no node, and replacing the CAN transceiver restores all expected nodes.
- Field overstress, ESD, wiring, or bus fault history may be upstream causes of transceiver damage, but require separate evidence.
- Known-version defect is possible when the source ties the issue to a `V07` fix; verify board/firmware version before generalizing.

## Exclusion Checks

- If MCU 3.3V is absent, do not replace the CAN transceiver before diagnosing power/regulator/MCU power.
- If CAN transceiver 5V is absent, check supply path and connector before declaring chip damage.
- If CANAble bitrate, termination, or wiring is unverified, do not treat "未找到节点" as board failure.
- If only one board fails and replacement does not restore scanning, inspect soldering, connector, MCU firmware, boot state, and oscillator/reset.
- If all nodes are found after repair, do not continue into firmware/CANopen state branches unless application-level communication still fails.

## Confirmed Examples

- `component-test-pt-0114`: Amazon returned four ALLCAN-S boards with node labels `7`, `8`, `11`, and `12`; after power-on the CAN communication indicator alternated green/orange quickly, described as CAN bus error.
  - Source table: MCU voltage measured at component `U4` pin 5 was `3.29V`, marked pass.
  - Source table and photo: CAN transceiver voltage measured at `U4` pin 3 was `5.32V`, marked pass.
  - Source table: using CANAble with terminal resistor and node scan tool found no node before repair, marked fail.
  - Source resolution: replacing CAN transceiver chip `U4` restored normal behavior.
  - Repair verification screenshot at `1000000 bps` shows nodes found: `8`, `7`, `12`, and `11`, then scan complete.
  - Source states this matched a known issue and `V07` version has fixed it.

## Unresolved Examples

- `component-test-pt-0114`: raw CAN scan logs and oscilloscope/CAN waveform captures are not local; pre-repair "no node found" is from source table and video/visual evidence.
- `component-test-pt-0114`: the exact electrical overstress path that damaged the transceivers is not identified locally.

## Specialist Routing

- `can-bus`: CAN physical layer, node scan, termination, bitrate, transceiver replacement verification.
- `embedded-software`: firmware/version context, boot state, known `V07` fix, node ID behavior after hardware is repaired.
- `vision-media`: indicator behavior, board labels, measurement photos, scan-tool screenshots, repair verification media.
- `network-infra`: not primary; only use if CAN-to-host tooling or adapter path is suspect.
