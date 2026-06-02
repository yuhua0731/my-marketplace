# C134 Ant Network Knowledge

source_set: accepted high-priority `Ant/network`
case_count: 10
status: draft refined from visible text

## Symptoms

- single Ant disconnected: `c134-0002`, `c134-0157`, `c134-0228`, `c134-0252`, `c134-0256`, `c134-0283`, `c134-0284`
- both robot IPs unreachable: `c134-0252`, `c134-0256`
- robot IPs reachable but FLO/MQTT disconnected: `c134-0228`
- site-wide short disconnect: `c134-0227`
- site-wide disconnect from server/Kafka issue: `c134-0337`
- robot rebooted to `UNKNOWN`, then could not charge and drained battery: `c134-0027`

## Fault Tree

1. Scope the disconnect first.
   - One robot only: inspect robot NIC, wormhole, MQTT, NXP, board.
   - Many/all robots: inspect AP/uplink/server/Kafka before robot hardware.
2. Check ping reachability by both IPs.
   - Both IPs unreachable points to NIC/AP/link/board branch; examples `c134-0252`, `c134-0256`.
   - Both IPs reachable but FLO disconnects points to MQTT/NXP-to-wormhole path; example `c134-0228`.
3. Correlate NXP MQTT disconnect with wormhole/NIC logs.
   - `c134-0252`: MQTT disconnect at `[2026-02-22T13:28:44+0800]`; wormhole shows `phy1-sta0` AP loss at `[2026-02-22T13:28:32+0800]`.
   - `c134-0228`: NXP shows MQTT disconnect at `[2026-02-03T16:22:46+0800]`, wormhole has no NIC disconnect and both IPs ping.
4. Check dual-NIC state and failover.
   - `c134-0157`: IP `10.0.64.116` had no packets from before `2026-01-21T12:52:39.700277000+0800`; the other NIC still carried MQTT until later full loss.
   - `c134-0252`: known NIC1 switching stuck issue can prevent both NICs from reconnecting after NIC2/AP loss.
5. Check hardware if both NICs fail or repeat on same robot.
   - `c134-0283`: both NICs disconnected at `[2026-04-19T03:23:28Z][UPTIME:5919]`; resolution was replacing layer-3 board.
   - `c134-0284`: NIC2 then NIC1 disconnected; same resolution.
6. For whole-site short disconnect, test physical network path.
   - `c134-0227`: ping AP and EasyBox simultaneously; if both drop, suspect fiber transceiver/fiber/cable/switch path.
   - Replacement of a pair of transceivers on `2026-02-06 11:45` stopped observed loss through `2026-02-09 08:40:49`.
7. For whole-site service disconnect, inspect server disk I/O and Kafka.
   - `c134-0337`: high disk I/O caused Kafka controller election failure and restart; stopping EFK reduced pressure, root fix was replacing HDD with SSD.
8. If network loss follows robot reboot/UNKNOWN, split root cause.
   - `c134-0027`: last pre-reboot command succeeded in `IDLE`; robot rebooted to `UNKNOWN`, could not move to charge, then voltage dropped below `4.0v`.

## Evidence Needed

- ping results for both robot IPs with timestamps.
- wormhole/system logs around NIC/AP events: `wwan*`, `phy1-sta0`, reconnect/disconnect.
- NXP MQTT disconnect timestamps and keepAlive timeout evidence.
- dumpcap/pcap from robot NICs and AP/uplink side.
- AP, EasyBox, switch/uplink ping monitoring for site-wide events.
- server disk I/O, Kafka controller/broker logs, EFK load for whole-site disconnects.
- robot board replacement/repair history for repeated same-robot dual-NIC loss.

## Logs And Files To Inspect

- robot `system.log`, `wormhole.log`, `A-xxx_system_*`
- NXP logs for MQTT disconnect and reboot markers.
- dumpcap/pcap by NIC/IP, especially last communication time.
- AP/EasyBox ping monitor output.
- Kafka controller/broker logs, server disk I/O metrics, EFK service status.

## Likely Causes

- single NIC abnormality or robot-side network-card failure: `c134-0002`, `c134-0157`
- dual-NIC failover/switching stuck: `c134-0252`
- MQTT/NXP-to-wormhole internal path issue despite reachable IPs: `c134-0228`
- layer-3 board fault: `c134-0283`, `c134-0284`
- physical uplink/transceiver instability: `c134-0227`
- server disk I/O causing Kafka election failure: `c134-0337`
- reboot-to-UNKNOWN causing no-charge drain, not pure network fault: `c134-0027`

## Exclusion Checks

- Both robot IPs ping but MQTT is broken: do not blame AP/uplink first; inspect NXP/wormhole/MQTT.
- One NIC down but the other still carries MQTT: do not treat as full robot disconnect until both paths fail or MQTT keepAlive expires.
- Whole-site FLO disconnect with server symptoms: inspect Kafka/RVS/SAS and disk I/O before AP hardware.
- Whole-site ping drops to both AP and EasyBox: suspect upstream physical path, not AP-only.
- Reboot before disconnect: classify power/system root separately; network may be consequence.
- Missing wormhole NIC event at disconnect time: keep root cause unknown unless pcap or NXP evidence closes the path.

## Handling Recommendations

- Capture both-IP ping, NXP MQTT timestamp, and wormhole NIC timestamp before rebooting the robot.
- For repeated same-robot dual-NIC loss, inspect/reseat/replace network board or layer-3 board.
- Enable dual-NIC redundancy validation for cases like `c134-0256`, where logs did not show wormhole events.
- For whole-site physical path suspicion, monitor AP and EasyBox in parallel overnight under normal powered load.
- For Kafka/server root causes, reduce disk I/O immediately, then move to SSD and separate controller/broker roles if needed.

## Confirmed Examples

- `c134-0227`: whole-site short disconnect correlated with AP/EasyBox loss; replacing one pair of transceivers stopped observed packet loss.
- `c134-0252`: NIC2 AP loss plus known NIC1 switching stuck caused full disconnect; fix branch is failover bug.
- `c134-0283`, `c134-0284`: repeated A107 NIC disconnects resolved by replacing layer-3 board.
- `c134-0337`: whole-site disconnect came from Kafka controller election failure under high disk I/O; root fix was HDD to SSD.

## Unresolved Examples

- `c134-0002`: dumpcap last communication with A108 at `13点21分19秒`; another NIC had disconnected the previous night; exact cause unresolved.
- `c134-0157`: NIC1 was already down, MQTT later broke on remaining path, then NXP rebooted; exact first cause unresolved.
- `c134-0228`: both IPs ping, no wormhole NIC disconnect, NXP MQTT disconnected; NXP-wormhole internal cause unknown.
- `c134-0256`: both IPs unreachable, NXP MQTT disconnected, no wormhole event; needs dual-NIC redundancy validation.

## Specialist Routing

- `network-infra`: AP/EasyBox/uplink, transceiver, switch, ping, pcap, Kafka/server network symptoms.
- `embedded-software`: NXP MQTT state, wormhole/NXP interaction, reboot-to-UNKNOWN behavior.
- `scheduler-traffic`: no-charge after UNKNOWN/reboot and task-state consequences.
- `can-bus`: only needed when disconnect is mixed with low-voltage or CAN-side power evidence.
