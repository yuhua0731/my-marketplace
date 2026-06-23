# MiniSort NXP MAC Source Mismatch During Robot Initialization

source_set: `minisort-test-pt-0097`
case_count: 1 needs-assets MAC/address identity case
status: runtime routing rules for MiniSort baffle robot NXP MAC source mismatch and cross-robot identity risk

## Symptoms

- Mini/MiniSort baffle robot initialization script requires the NXP MAC address.
- Different sources report different MAC/address values for the same robot/IP:
  - DHCP Server lease table;
  - NXP terminal `net iface`;
  - RCS scan discovery / robot radio communication address;
  - industrial PC `arp -a`.
- Example robots/IPs include `K02A17MN (10.0.64.110)`, `K02A20MN (10.0.64.101)`, and `K02A11MN (10.0.64.102)`.
- Source visible text indicates `K02A20MN` and `K02A11MN` may have crossed or mixed MAC usage.

## Fault Tree

1. Separate representation mismatch from true identity mismatch.
   - DHCP/ARP values may appear as colon-separated MACs such as `02:04:a0:a1:31:c8`.
   - NXP/RCS values may appear as `02:04:9F:31:A1:C8` or compact forms such as `02049F31A1C8`.
   - Determine whether the difference is formatting, byte conversion, locally administered address derivation, or a real robot mismatch.
2. Validate physical robot identity.
   - For each robot, record physical label, expected IP, live DHCP lease, live `arp -a`, direct NXP `net iface`, and RCS-discovered address.
   - If two robots appear crossed, verify from direct terminal on each physical robot before changing bindings.
3. Check stale cache/lease branch.
   - DHCP leases and ARP cache can lag behind robot swaps or IP reuse.
   - Clear DHCP/ARP cache or renew leases before treating mismatch as permanent identity fault.
4. Check initialization-script source-of-truth.
   - Use the MAC/address format consumed by the initialization script and downstream RCS/robot discovery path.
   - Document the accepted source and conversion rule so field teams do not mix DHCP, ARP, NXP, and RCS values.

## Evidence Needed

- Original screenshots or raw exports for DHCP lease table, `arp -a`, NXP `net iface`, and RCS scan discovery.
- Exact initialization script name, expected MAC format, and command input.
- Physical robot label/serial verification for `K02A17MN`, `K02A20MN`, and `K02A11MN`.
- Timestamp-aligned DHCP and ARP cache state after lease renewal or cache flush.
- Final correction or retest showing the initialization command targets the intended robot.

## Logs And Files To Inspect

- `cases/needs-assets/minisort-test/0097-WR1HwEHW4iEgQkkfeafcD50cnqd-2026-04-14-Mini拖链机器人-MAC-地址问题.md`
- No local assets exist under `assets/minisort-test-pt-0097/`.
- Search terms: `MAC 地址`, `NXP MAC`, `DHCP Server`, `DHCP Leases`, `net iface`, `arp -a`, `RCS 扫描发现`, `射频通讯地址`, `K02A17MN`, `K02A20MN`, `K02A11MN`, `02049F31A1C8`, `交叉混用`.

## Likely Causes

- Multiple tools expose different address forms, and the expected conversion/source-of-truth is undocumented.
- DHCP/ARP cache or leases may be stale after robot swaps or IP reuse.
- Robot ID/IP/MAC binding may have been crossed between `K02A20MN` and `K02A11MN`.
- Initialization script may be using a MAC source different from the one RCS uses for robot discovery.

## Exclusion Checks

- Do not diagnose CAN failure without CAN communication evidence; this is address/identity mapping.
- Do not route to Ant/C134 power or network from incidental `重启` text in screenshot descriptions.
- Do not rely on one source alone when DHCP/ARP, NXP, and RCS disagree.
- Do not update bindings until physical robot identity and live `net iface` / RCS scan agree.
- Do not treat embedded image alt text as final proof; request/download the original screenshots or exports for final closure.

## Confirmed Examples

- `minisort-test-pt-0097`: during CS007 `K02A17MN` baffle robot debugging, an initialization script needed NXP MAC. The source compares DHCP Server, NXP `net iface`, RCS scan discovery, and industrial PC `arp -a`. Visible text shows address differences such as `02:04:a0:a1:31:c8` versus `02:04:9F:31:A1:C8` / `02049F31A1C8`, and notes possible cross-use between `K02A20MN` and `K02A11MN`.

## Unresolved Examples

- `minisort-test-pt-0097`: original screenshots, raw exports, script details, conversion rule, final root cause, and retest are missing.

## Specialist Routing

- Start with `network-infra` for DHCP leases, ARP cache, IP/MAC binding, and live network identity.
- Add `embedded-software` for NXP `net iface`, initialization script expectations, and robot-side address generation.
- Add `scheduler-traffic` when RCS robot discovery or robot binding is affected.
- Add `vision-media` only to inspect screenshots of DHCP/ARP/RCS tables when originals are available.
