# Boost Module Protection With CANopen Pre-op And Stale Battery

## Symptoms

- Ant 3.0 abnormal power-off during test-floor scheduling.
- RMS/Kafka heartbeat may still show `ONLINE`, `errors: []`, and stale battery such as `batteryCharge: 58`.
- Robot-side or boost-module evidence shows much lower battery state or voltage, for example actual voltage below `3.2V` or Wormhole `can_battery_status: Battery: 19.0%`.
- CANopen analysis may show communication overrun `0x8110` / `CO_EMC_CAN_OVERRUN`, NMT `05` Operational changing to `7F` Pre-operational, and PDO data no longer updating.

## Fault Tree

1. Start with the power symptom, not the displayed RMS battery value.
   - If RMS shows normal battery but robot-side CAN, Wormhole, or boost telemetry shows low voltage/SOC collapse, treat the RMS value as suspect.
   - If all robot-side battery sources agree with RMS, look for true sudden load, battery-pack, BMS, or boost-module protection instead of stale communication.
2. Separate real low-voltage protection from telemetry loss.
   - Low cell/pack voltage or boost-module protection can explain the actual shutdown.
   - CANopen Pre-operational can explain why PDO battery data stops refreshing and RMS keeps a stale value.
3. Check NMT state and EMCY/code-analysis evidence.
   - `CO_CANsend()` send buffer full maps to `CO_CAN_ERRTX_OVERFLOW`.
   - `CO_EM_process()` can set `CO_EM_CAN_TX_OVERFLOW` and `CO_EMC_CAN_OVERRUN`.
   - `CO_EMC_CAN_OVERRUN = 0x8110`.
   - With `NMT_CONTROL = 0x2011`, a communication error bit can move NMT from `05` Operational to `7F` Pre-operational.
   - In `7F`, NMT/SDO/Heartbeat/EMCY can still exist, but PDO does not run, so battery PDO may be stale or missing.
4. Check CAN channel and node identity before concluding.
   - One capture can show a heartbeat such as `0x750=7f` while another channel or node still shows `05`.
   - Do not collapse different CAN loops into one state without node/channel mapping.
5. Treat log cutoff as evidence gap, not proof.
   - If NXP/Wormhole logs end before the reported power-off time, they support abnormal termination only as a gap or cutoff, not as a complete final shutdown sequence.

## Evidence Needed

- RMS/Kafka heartbeat near the event, including `batteryCharge`, `connectionStatus`, `mainState`, and `errors`.
- Robot-side battery source: `can_battery_status`, battery PDO, BMS, or boost-module telemetry.
- CAN pcap/candump for the relevant battery/boost loop with timestamps around the transition.
- NXP log around the event and restart, including UPTIME markers.
- Boost-module voltage/current/SOC chart or raw telemetry.
- Video frames around the event if physical power-off, collision, charging-pile entry/exit, or operator action matters.
- Battery/boost-module protection threshold/config when available.

## Logs And Files To Inspect

- Search logs for `CO_EMC_CAN_OVERRUN`, `0x8110`, `Pre-operational`, `Operational`, `PDO`, `CO_CAN_ERRTX_OVERFLOW`, `CO_EM_CAN_TX_OVERFLOW`, `batteryCharge`, `can_battery_status`, `UPTIME`.
- Decode custom pcapng/raw CAN frames when `tcpdump` reports `UNSUPPORTED`; unsupported pcap format is not evidence that no CAN data exists.
- Compare pcap times against the reported local event time and log UTC timestamps.

## Likely Causes

- Real low voltage or boost-module protection is likely when boost telemetry shows voltage/SOC collapse or dips below threshold.
- Stale RMS battery is likely when robot-side battery sources diverge from RMS and CANopen/PDO evidence shows `7F` Pre-operational or communication overrun.
- Charging-pile entry/exit, boost-module restart, or load transients are possible contributors only when timing evidence connects them to voltage dip or CAN transition.
- 4G power cycling or serial `ttyS` overrun is not the same fault as CANopen `0x8110`; keep it as a network/serial side branch unless correlated.

## Exclusion Checks

- If the relevant node remains `05` Operational and battery PDO continues updating through the event, do not use CANopen Pre-operational as the stale-battery explanation.
- If RMS battery matches robot-side battery and the robot still powers off, investigate true power path, battery pack, BMS, boost module, and load transient.
- If logs do not include the final minute, do not claim the exact shutdown order.
- If video only shows the test floor and robots with lights on, use it as scene/time context, not proof of electrical power-off.

## Confirmed Examples

- `test-floor-traffic-pt-0109`: Ant 3.0 `K17A31AN` abnormal power-off reported at `2026-05-25 13:17:33`.
  - RMS/Kafka screenshot at `2026/5/25 13:17:19` shows `robotLabel: K1731`, `connectionStatus: ONLINE`, `batteryCharge: 58`, `mainState: IDLE`, `errors: []`.
  - Battery chart shows SOC collapse and voltage/current dips; source analysis states actual voltage below `3.2V` triggered boost-module protection.
  - Wormhole log repeatedly reports `can_battery_status: Battery: 19.0%`, conflicting with RMS `58`.
  - Code analysis explains `0x8110` / `CO_EMC_CAN_OVERRUN` and NMT `05 -> 7F`.
  - Retry pcap contains repeated `8110` payloads and `0x750` heartbeats with data `7f`; another pcap shows `0x710`/`0x750` data `05`, so channel/node mapping remains important.
  - NXP and Wormhole logs end near local `13:16:11`, before the reported `13:17:33` power-off, so final shutdown sequence is not directly captured.

## Unresolved Examples

- `test-floor-traffic-pt-0109` still has unresolved evidence gaps:
  - The final minute from local `13:16:11` to reported `13:17:33` is absent from NXP/Wormhole logs.
  - Video representative frames show the test-floor scene and robot lights, but do not directly prove the electrical power-off sequence.
  - CAN pcaps show different heartbeat states across captures, so exact CAN channel/node mapping remains required before generalizing the transition timing.

## Specialist Routing

- `embedded-software`: NXP logs, UPTIME/restart, CANopen state machine, PDO behavior.
- `can-bus`: CAN pcap/candump, NMT/EMCY/heartbeat, custom pcap decoding.
- `network-infra`: RMS/Kafka heartbeat divergence, Wormhole service, 4G/serial noise if correlated.
- `vision-media`: confirm physical scene, charging-pile context, collision/operator action, or visible power-off only when video frames show it.
