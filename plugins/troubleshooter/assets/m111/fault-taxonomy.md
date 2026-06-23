# M111 Fault Taxonomy

## omnisort.m111.baffle_robot_boot_can_sync_loss

- Product line: OmniSort / 慧仓闪电播
- Corpus: `m111`
- Primary specialists: `embedded-software`, `can-bus`
- Symptom anchors: firmware update, probabilistic boot failure, orange flashing, `CAN同步帧丢失`.
- Log anchors: `CO_SDOclientUpload error: -11`, `index 6064 sub_index 0 node_id 1`, `abort code: 84148224`, `0x05040000`, node heartbeat timeout, bootloader/reboot markers.
- Knowledge: `docs/m111/knowledge/baffle-robot-boot-can-sync-loss.md`

## omnisort.conveyor_recovery_race

- Product line: OmniSort / 慧仓闪电播
- Corpus: `m111`
- Primary specialists: `scheduler-traffic`, `mantis-handling`, `vision-media`
- Symptom anchors: conveyor overheight recovery, robot throw/load failure, lift floor transition, forced discharge.
- Knowledge: `docs/m111/knowledge/conveyor-recovery-race.md`

## omnisort.m111.feeder_panel_j5_no_voltage_j6_power_missing

- Product line: OmniSort / 慧仓闪电播
- Corpus: `m111`
- Primary specialists: `embedded-software`, `can-bus`, `vision-media`
- Symptom anchors: Mini/M111 feeder panel, overheight detection sensor, CAN node 11 J5 no voltage, multimeter no output, panel J6 no power wire, temporary CAN node 10 connection, ALLCAN-4 / CANIO location mapping.
- Evidence anchors: panel photos showing HC ROBOTICS ALLCAN-4 / `PARCEL CONVEYOR PANEL`, J4 V-/V+, J8 48V-/48V+, active panel LEDs, source statement that drawing review found J6 power wiring missing.
- Knowledge: `docs/m111/knowledge/feeder-panel-j5-no-voltage-j6-power-missing.md`

## omnisort.m111.lift_belt_motor_noise_red_blink_no_load

- Product line: OmniSort / 慧仓闪电播
- Corpus: `m111`
- Primary specialists: `mantis-handling`, `embedded-software`, `vision-media`
- Secondary specialists: `can-bus`
- Symptom anchors: Mini/M111 lift-module belt motor abnormal noise, continuous-script stutter, Xinliu motor red blinking, squeak remains after synchronous belt removal.
- Evidence anchors: loaded belt video, no-belt motor-only video, motor status light, blink code, motor/driver/CAN/current logs, belt/pulley isolation.
- Knowledge: `docs/m111/knowledge/lift-belt-motor-noise-red-blink-no-load.md`

## omnisort.m111.feeder_sensor_position_package_slide_multi_package

- Product line: OmniSort / 慧仓闪电播
- Corpus: `m111`
- Primary specialists: `embedded-software`, `scheduler-traffic`, `vision-media`
- Secondary specialists: `can-bus`
- Symptom anchors: Mini/M111 feeder, no-scan infeed, first light curtain, `供包机包裹滑动`, second feeder section, `供包机多包`, force unload after conveyor recovery.
- Log anchors: `package infeed error skip`, `sensors[0].length_sensor_state 0`, `LENGTH_SENSOR_ERROR`, `LOADING_ERROR`, `CONVEYOR_EVENT_0X01`, `CONVEYOR_EVENT_0X09`, `RECOVER_CONVEYOR_ERROR_WAITING_SHUTTLE_AT_SITE`, `/etc/station_config/sensor.json`.
- Knowledge: `docs/m111/knowledge/feeder-sensor-position-package-slide-multi-package.md`

## omnisort.m111.baffle_added_drag_chain_bracket_interference

- Product line: OmniSort / 慧仓闪电播
- Corpus: `m111`
- Primary specialists: `vision-media`, `robot-motion`
- Secondary specialists: `embedded-software`
- Symptom anchors: M111 robot after baffle retrofit, drag-chain mounting hole blocked, original drag-chain bracket incompatible, cannot install/fix drag chain normally.
- Evidence anchors: before/after bracket images, new versus original bracket geometry, post-fix installation image/video, source confirmation that redesigned bracket solved the issue.
- Knowledge: `docs/m111/knowledge/baffle-added-drag-chain-bracket-interference.md`

## omnisort.m111.wrs_lift_module_no_action_after_second_scan

- Product line: OmniSort / 慧仓闪电播
- Corpus: `m111`
- Primary specialists: `scheduler-traffic`, `vision-media`
- Secondary specialists: `embedded-software`, `can-bus`
- Symptom anchors: WRS scan/delivery, exception-slot fallback, `提升模组接包后无动作`, 1-minute system unresponsive popup, D002 state `完成抛送货品`.
- Knowledge: `docs/m111/knowledge/wrs-lift-module-no-action-after-second-scan.md`

## omnisort.m111.wrs_timeout_rollback_physical_parcel_divergence

- Product line: OmniSort / 慧仓闪电播
- Corpus: `m111`
- Primary specialists: `scheduler-traffic`, `vision-media`
- Secondary specialists: `embedded-software`
- Symptom anchors: WRS return-box remaining delivery count rollback, two parcels on feeder, first robot load failure, second parcel waits on belt, about 4-minute timeout, first parcel force-discharged to exception, second parcel delivered to normal target slot, remaining delivery / recorded count unchanged.
- Evidence anchors: UI shows `剩余投递数量 44`, `在途中数量 0`, `已录入数量 6`, status `已扫描`; video metadata and frame show feeder/workstation equipment with WRS return-box detail UI; source fix injects timeout duration into barcode add and checks timeout at RCS throw.
- Knowledge: `docs/m111/knowledge/wrs-timeout-rollback-physical-parcel-divergence.md`
