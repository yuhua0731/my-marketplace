# MiniSort Test Fault Taxonomy

## Baffle And Motor Parameters

- `omnisort.minisort_test.baffle_motor_gear_ratio_accdec_sdo_range`
  - Product line: OmniSort / 慧仓闪电播.
  - Typical symptom: Mini drag-chain baffle robot intermittently fails to lower the baffle during parcel throwing.
  - Primary evidence: `CO_SDOClientDownload error` on CANopen objects `6083` and `6084`, node `3`, abort `1012531699` / `0x06090031`; baffle motor ratio `1:18` was configured with `1:1` throw-motor acceleration/deceleration parameters.
  - Primary specialists: `can-bus`, `embedded-software`; add handling specialist and `vision-media` for physical baffle sequence.
  - Knowledge: `knowledge/baffle-motor-gear-ratio-accdec-sdo-range.md`.

## Baffle Throw-Off Object Geometry

- `omnisort.minisort_test.conical_screw_belt_edge_baffle_gap_jam`
  - Product line: OmniSort / 慧仓闪电播.
  - Typical symptom: a head-heavy/conical item rotates in place, drifts to the belt edge during throw-off, and jams near the baffle motor or belt/baffle gap.
  - Primary evidence: `minisort-test-pt-0103` source says screw testing found `头重脚轻（锥形物品）` objects rotate in place and slide to the belt edge; photos show the screw geometry and the screw head at the baffle-side belt edge.
  - Primary specialists: `vision-media`, `mantis-handling`; add `robot-motion` for motion timing and `embedded-software` only if motor/command evidence is abnormal.
  - Knowledge: `knowledge/conical-screw-belt-edge-baffle-gap-jam.md`.

## IO And CAN Documentation

- `omnisort.minisort_test.io_address_table_can_termination_ambiguity`
  - Product line: OmniSort / 慧仓闪电播.
  - Typical symptom: MiniSort/M131 IO address variable table or debugging manual does not clearly state the ALLCAN-4 terminal-resistor DIP switch state.
  - Primary evidence: `M131_IO地址变量表_V01.xlsx` screenshot shows same physical CAN bus split across sheet tabs such as `1#9352 BUS-1-1` and `1#9352 BUS-1-2`; source says `9352-1` and `9352-2` node connections were hard to understand.
  - Primary specialists: `can-bus`, `embedded-software`, `vision-media`.
  - Knowledge: `knowledge/io-address-table-can-termination-ambiguity.md`.

## Network And Robot Identity

- `omnisort.minisort_test.nxp_mac_source_mismatch`
  - Product line: OmniSort / 慧仓闪电播.
  - Typical symptom: Mini/MiniSort baffle robot initialization requires NXP MAC, but DHCP Server, industrial PC `arp -a`, NXP `net iface`, and RCS scan discovery show different or crossed MAC/address values.
  - Primary evidence: `minisort-test-pt-0097` visible table compares `K02A17MN`, `K02A20MN`, and `K02A11MN`; examples include `02:04:a0:a1:31:c8`, `02:04:9F:31:A1:C8`, and `02049F31A1C8`.
  - Primary specialists: `network-infra`, `embedded-software`, `scheduler-traffic`, `vision-media`.
  - Knowledge: `knowledge/nxp-mac-source-mismatch.md`.

## Scheduler And Map Data

- `omnisort.minisort_test.dirty_grid_shuttle_standby_offset_mismatch`
  - Product line: OmniSort / 慧仓闪电播.
  - Typical symptom: MiniSort Pro robot overview position differs from physical position; a layer cannot receive parcel; UI may have no alarm.
  - Primary evidence: `setTarget`, `robot_move_command`, `target_reached_event`, and `odom_report_event` agree on a wrong standby/load offset; DB query shows dirty `grid` data or stale `shuttle` standby point.
  - Primary specialists: `scheduler-traffic`, `robot-motion`, `embedded-software`, `vision-media`.
  - Knowledge: `knowledge/dirty-grid-shuttle-standby-offset-mismatch.md`.

- `omnisort.minisort_test.locked_robot_blocks_system_shutdown`
  - Product line: OmniSort / 慧仓闪电播.
  - Typical symptom: MiniSort Pro self-test/no-scan mode locks a robot, then system shutdown hangs or cannot complete.
  - Primary evidence: source says shutdown at `2026-05-06 15:29` failed after locking robots; source analysis names `M002L` locked state; screenshot shows `M002L` grey/initializing while other robots run and UI remains alive.
  - Primary specialists: `scheduler-traffic`, `embedded-software`, `vision-media`.
  - Knowledge: `knowledge/locked-robot-blocks-system-shutdown.md`.

## Feeder External Error Recovery

- `omnisort.minisort_test.conveyor_external_error_replay_force_unload`
  - Product line: OmniSort / 慧仓闪电播.
  - Typical symptom: after feeder/conveyor disconnect and system reset, old external error `0x06` / `CONVEYOR RECONNECTED` is replayed at startup and force unload cannot finish.
  - Primary evidence: feeder disconnect/recover logs, central-control reset/error-state cleanup, external-error replay after boot, force-unload lifecycle, and recovery behavior.
  - Primary specialists: `scheduler-traffic`, `embedded-software`, `network-infra`, `vision-media`.
  - Knowledge: `knowledge/conveyor-external-error-replay-force-unload.md`.

## WRS Return-Box Aggregate Accounting

- `omnisort.minisort_test.return_box_batch_exception_aggregate_negative_remaining`
  - Product line: OmniSort / 慧仓闪电播.
  - Typical symptom: after WRS return-box batch exception handling, remaining delivery quantity becomes negative and on-the-way quantity remains positive.
  - Primary evidence: `minisort-test-pt-0028` return box `0414142813` shows plan `200`, remaining `-1`, on-the-way `1`, recorded `136`, abnormal `64`; `wrs.log` shows `POST /api/return-boxes/batch-exception-handling` at `2026-04-14 17:38:16` with body `{"ids":[5],"abnormalReasonId":5}`; source analysis identifies subtracting detail remaining sum from current box remaining as the formula fault.
  - Primary specialists: `scheduler-traffic`; add `embedded-software` only if active WCS delivery callbacks still change `on_the_way_quantity`; add `vision-media` for UI/log screenshots.
  - Knowledge: `knowledge/return-box-batch-exception-aggregate-negative-remaining.md`.

## Full-box Sensor Trigger Configuration

- `omnisort.minisort_test.full_box_trigger_num_can_gateway_mapping`
  - Product line: OmniSort / 慧仓闪电播.
  - Typical symptom: full-box sensor trigger window loads for minutes, wall trigger count is missing/transparent, editing trigger count fails without popup, and logs may show `PUBLISH_FAIL_MAX_RETRY_TIMES_EXCEEDED`.
  - Primary evidence: corrected config rows with `-trigger-num`, `FullBoxTriggersNumber`, `/FullBoxTriggersNumber/...`; CAN gateway ODTM/mapping rows; central-control retry/publish logs; mapping/relationship table count match.
  - Primary specialists: `scheduler-traffic`, `network-infra`, `embedded-software`, `can-bus`, `vision-media`.
  - Knowledge: `knowledge/full-box-trigger-num-can-gateway-mapping.md`.

## Robot Motion Parameter Timing

- `omnisort.minisort_test.full_box_exception_unload_delayed_move_slow_run`
  - Product line: OmniSort / 慧仓闪电播.
  - Typical symptom: in Mini Plus locked sowing mode, after a grid is full and recovered, the robot moves toward the exception mouth at abnormal/slow speed.
  - Primary evidence: `M004L` around `14:28:42~14:29:28`; central-control command has normal `position: 2.42`, `speed: 4`, `acc: 3.2`, `dec: 3.2`; robot move lifecycle shows pre-arrival/terminate then new `Move`; PDO and SDO profile velocity are both `4753`; source resolution says delayed-call move parameters must take effect after movement-start event.
  - Primary specialists: `embedded-software`, `scheduler-traffic`, `vision-media`.
  - Knowledge: `knowledge/full-box-exception-unload-delayed-move-slow-run.md`.

## Evidence Status

- Treat `target_reached_event` as evidence that the robot reached the commanded offset, not proof that the command was the correct physical target.
- Compare commanded offset with source-of-truth station coordinates before blaming robot localization.
- Deleting dirty `grid` rows is insufficient if `shuttle` standby data was already generated from stale records.
- Treat UI overview screenshots as symptom evidence; use logs and DB/config records for root-cause proof.
- For baffle non-descent, decode SDO aborts and compare motor ratio/template before replacing motor hardware.
- For screw/conical-item throw failures, inspect item geometry, rotation, edge drift, and belt/baffle gap capture before CANopen or motor-parameter branches.
- For IO table ambiguity, verify CAN topology and terminal-resistor documentation before treating it as a runtime CAN failure.
- For NXP MAC mismatch, align physical robot label, IP, DHCP/ARP, `net iface`, and RCS scan source before changing robot bindings.
- For shutdown failure after robot lock, preserve the lock-state precondition and inspect scheduler/system shutdown barriers before hardware power branches.
- For feeder force-unload after reset, distinguish a stale replayed external error from a live feeder fault; check whether central control still has the matching error-code record before treating force unload as a physical recovery.
- For WRS return-box batch exception counter anomalies, do not accept total arithmetic equality as proof; check non-negative counter semantics and whether residual detail quantities were converted to abnormal.
- For full-box trigger-count configuration, verify both central-control allcan import and CAN gateway `FullBoxTriggersNumber` ODTM/mapping generation; `/FullWatcherForBox/...` sensor status alone is not enough.
- For full-box recovery followed by abnormal robot speed to the exception mouth, compare central-control command values with robot move lifecycle timing before blaming full-box sensor mapping or locked-sowing count logic.
