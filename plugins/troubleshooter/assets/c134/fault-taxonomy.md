# C134 Fault Taxonomy

status: draft
scope: C134 accepted + needs-assets training corpus

## Top-Level Areas

- `ant.power`
- `ant.motion_localization`
- `ant.network`
- `ant.load_handling`
- `ant.sensor`
- `mantis.load_handling`
- `mantis.power`
- `mantis.network`
- `mantis.motion_localization`
- `scheduler_traffic`
- `workstation_wled`
- `infrastructure_server`
- `unknown_needs_assets`

## Fault Types

### ant.power

- `low_battery_shutdown`: battery drops to shutdown threshold; boost module cuts power.
- `charge_dispatch_missing`: low-battery robot is not sent to charge.
- `charge_reservation_conflict`: charging pile reservation released before physical departure.
- `reboot_unknown`: `UPTIME` reset or NXP reboot marker exists, root cause not proven.
- `storage_overlay_sdcard`: overlay full, SD-card mount/log loss, repeated reboot.
- `startup_self_check`: gyro/init/motor heartbeat/startup failure.
- `normal_status_false_positive`: blue light or UNKNOWN interpreted as fault without robot-side evidence.

### ant.motion_localization

- `dm_lost_linear`: DM code lost during straight movement.
- `dm_dirty_or_damaged`: floor-code contamination or bad route segment.
- `scan_gap_rotation`: sparse DM reads during rotation or WS entry/exit.
- `angle_too_large`: command direction or tolerance mismatch.
- `short_move_planning`: short-distance/high-speed/braking infeasible command.
- `camera_offset_calibration`: camera offset or pose estimate drift.
- `drive_parameter_mismatch`: motor/reducer subdivision or drive config mismatch.
- `external_or_motor_obstruction`: possible one-side obstruction; requires CAN proof.

### ant.network

- `single_nic_failure`: one NIC down while other path may still work.
- `dual_nic_disconnect`: both robot IPs unreachable.
- `failover_stuck`: known dual-NIC switching stuck after AP/NIC loss.
- `mqtt_internal_disconnect`: IP reachable but MQTT/NXP disconnected.
- `site_physical_network`: AP/EasyBox/fiber/transceiver/switch path loss.
- `server_kafka_io`: disk I/O or Kafka controller election failure.

### ant.load_handling

- `task_container_state_mismatch`: task/container state inconsistent after clear/TP.
- `reservation_overlap`: robot waits because command/state reservation overlaps.
- `load_sensor_timing`: tote not seated or sensor transition delayed.
- `pt_pd_mechanical_interference`: tote/PT/PD/drag-bar contact.
- `lift_power_low_voltage`: boost module or supply abnormal during lift.
- `mqtt_config_duplicate_command`: wrong MQTT host or duplicate command behavior.

### mantis.load_handling

- `quick_stop_pull_motor`: pull motor enters quick stop; inspect IO and node402.
- `missed_io_pulse`: IO pulse shorter than TPDO sampling period.
- `target_reached_stale`: operation-enabled transition repeats old target reached.
- `offset_expected_actual`: small coordinate mismatch from accessNodeOffset.
- `finger_motor_mismatch`: finger target/actual mismatch or stall.
- `pt_pd_interference_high_torque`: torque spike, tote/finger/PT contact.
- `no_deposit_target`: no PD/tunnel or duplicate deposit contention.
- `logs_missing`: RMS/NXP/CAN missing; cannot prove root cause.

### scheduler_traffic

- `sas_redis_timeout_lock`: SAS orchestration stops after Redis timeout/lock issue.
- `duplicate_deposit_assignment`: multiple robots assigned into one available slot.
- `no_task_after_state_change`: robot available/task state changes but no new task.
- `worker_task_stale`: workstation task state remains after completion.

### workstation_wled

- `wled_reboot`: workstation light-strip reboot or delayed color.
- `ws_sensor_issue`: workstation sensor/light/operation issue.
- `operator_or_process`: human/process sequence issue.

## Evidence Classes

- `observed`: direct symptom, photo/video, field observation.
- `log_proven`: exact log line, timestamp, command, CAN frame, pcap.
- `inferred`: plausible cause from correlation, not confirmed.
- `confirmed`: cause backed by logs/video/config and matching recovery.
- `blocked`: required assets inaccessible or missing.

## Promotion Rules

- `needs-assets` to `accepted`: at least one root-cause branch is supported by logs, video, config, or repeated field evidence.
- Keep `needs-assets`: visible text is useful but missing required logs/media.
- Keep `accepted` with `root_cause: unknown`: evidence proves symptom and path but not cause.
- `rejected`: no symptom, no evidence, or unrelated to troubleshooting.
