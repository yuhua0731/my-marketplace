# Component Test Fault Taxonomy

## `component_test.allcan_led_flash_tool_jlink_verify_failures`

- Product line: `unknown_or_new`
- Corpus: `component-test`
- Primary specialists: `embedded-software`, `vision-media`
- Secondary specialists: `can-bus`, `hardware`
- Runtime knowledge: `component-test/knowledge/allcan-led-flash-tool-jlink-verify-failures.md`
- Pattern: ALLCAN-LED flashing failures split into two branches: pre-connect J-Link runtime/DLL errors such as `Expected to be given a valid DLL`, and post-program verify failures such as `Error while verifying programmed data`. Treat verify failure as distinct from total programming failure when the device appears to boot after power cycle; compare passing/failing boards, fixture contact, power/SWD integrity, and raw J-Link verify logs.

## `component_test.allcan_led_esp_flash_tool_crash`

- Product line: `unknown_or_new`
- Corpus: `component-test`
- Primary specialists: `embedded-software`, `vision-media`
- Secondary specialist: `hardware`
- Runtime knowledge: `component-test/knowledge/allcan-led-esp-flash-tool-crash.md`
- Pattern: ALLCAN-LED ESP/WLED flash tool exits or crashes while GUI is configured for `Wled-esp8266` / `ESP8266`. Separate GUI wrapper failure from actual ESP flashing by running the visible `esptool.exe` command directly; if `Hash of data verified` appears, inspect packaged runtime, subprocess handling, port/baud arguments, and crash logs before blaming target hardware or CAN.

## `omniflow.component_test.allcan_dm_dirty_floor_code_loss`

- Product line: `omniflow`
- Corpus: `component-test`
- Primary specialists: `robot-motion`, `vision-media`, `embedded-software`
- Secondary specialist: `can-bus`
- Runtime knowledge: `component-test/knowledge/allcan-dm-dirty-floor-code-loss.md`
- Pattern: Ant 3.0 / ALLCAN-DM reports `DM code lost`; scan statistics isolate a route/code row or route segment with unusually low read count. Photo or field inspection may show floor-code contamination/surface damage, but a centered stop pose does not exclude an upstream route-segment read gap.

## `omniflow.component_test.allcan_dm_flash_power_cycle_reset`

- Product line: `omniflow`
- Corpus: `component-test`
- Primary specialists: `embedded-software`, `can-bus`
- Secondary specialists: `mantis-handling`, `vision-media`
- Runtime knowledge: `component-test/knowledge/allcan-dm-flash-power-cycle-reset.md`
- Pattern: Mantis 3.0 / C144 ALLCAN-DM SD-card update is interrupted because whole-machine power-on causes the power baseboard to perform a secondary power-on and restart DM. Stabilize DM power with independent 24V or controlled baseboard power commands before blaming firmware image, SD card, or CAN.

## `omniflow.component_test.motor_drive_emergency_stop`

- Product line: `omniflow`
- Corpus: `component-test`
- Primary specialists: `can-bus`, `embedded-software`, `mantis-handling`, `vision-media`
- Runtime knowledge: `component-test/knowledge/motor-drive-emergency-stop.md`
- Pattern: motor/drive does not stop or hold correctly after emergency stop, or descending load generates back-EMF/DC-bus overvoltage; correlate physical motion, drive parameters, NXP node402/controlword behavior, overvoltage module data, and CAN evidence.

## `component_test.allcan_s_can_transceiver_failure`

- Product line: `unknown_or_new`
- Corpus: `component-test`
- Primary specialists: `can-bus`, `embedded-software`, `vision-media`
- Runtime knowledge: `component-test/knowledge/allcan-s-can-transceiver-failure.md`
- Pattern: ALLCAN-S board powers normally and CAN transceiver supply is present, but CANAble/node scan cannot find the node; replacing CAN transceiver `U4` restores expected node IDs.

## `component_test.vh_flowser_motor_can_heartbeat_loss`

- Product line: `unknown_or_new`
- Corpus: `component-test`
- Primary specialists: `can-bus`, `embedded-software`, `vision-media`
- Secondary specialist: `hardware`
- Runtime knowledge: `component-test/knowledge/vh-flowser-motor-can-heartbeat-loss.md`
- Pattern: VH / Flowser baffle motor loses heartbeat after short runtime; FlowCAN direct connection also cannot communicate or send messages, and the suspect motor can make the whole CAN bus unavailable. Normal static resistance readings or a PCB photo without visible burn do not exclude CAN transceiver, TVS/protection, MCU/boot, connector/solder, or robot-side power/ground overstress.

## `omniflow.component_test.baffle_robot_lift_anti_pinch_low_voltage`

- Product line: `omniflow`
- Corpus: `component-test`
- Primary specialists: `vision-media`, `can-bus`, `embedded-software`
- Secondary specialists: `robot-motion`, `scheduler-traffic`
- Runtime knowledge: `component-test/knowledge/baffle-robot-lift-anti-pinch-low-voltage.md`
- Pattern: baffle robot or shuttle physically interferes with a lift; lift reports anti-pinch vehicle protection while robot hardware alarm reports `SHUTTLE CAN ERROR 12577` / `0x3121` main-motor low-voltage. Correlate physical sequence with motor power wiring and motherboard output evidence before blaming lift sensor or localization.

## `omniflow.component_test.baffle_drop_wheel_jam_encoder_short`

- Product line: `omniflow`
- Corpus: `component-test`
- Primary specialists: `vision-media`, `embedded-software`, `can-bus`
- Secondary specialists: `robot-motion`, `hardware`
- Runtime knowledge: `component-test/knowledge/baffle-drop-wheel-jam-encoder-short.md`
- Pattern: baffle drop or physical wheel jam causes encoder abnormality first, then main-motor CAN emergency / short-circuit alarms and disable detections. Treat `主电机CAN总线紧急事件` as a possible consequence of mechanical jam or overload until raw CAN and physical inspection prove a CAN-layer initiating fault.

## `component_test.baffle_raise_pause_completion_flag_recovery`

- Product line: `unknown_or_new`
- Corpus: `component-test`
- Primary specialists: `embedded-software`, `vision-media`
- Secondary specialists: `scheduler-traffic`, `can-bus`
- Runtime knowledge: `component-test/knowledge/baffle-raise-pause-completion-flag-recovery.md`
- Pattern: after baffle robot throw failure and recovery, loading fails because the baffle is raised again. If pause happens before baffle-up completes and the completion flag is only set in movement state, pause/recovery misses the completion event; set completion when the baffle-up state completes and regression-test pause during actuator motion.

## `omniflow.component_test.lift_motor_enable_fail_encoder_c90`

- Product line: `omniflow`
- Corpus: `component-test`
- Primary specialists: `embedded-software`, `vision-media`
- Secondary specialists: `can-bus`, `hardware`
- Runtime knowledge: `component-test/knowledge/lift-motor-enable-fail-encoder-c90.md`
- Pattern: dual-motor lift reports `D端提升机电机2使能失败` while the servo drive displays `Er.C90`. Treat it as encoder communication/intermittent connector/EMI branch first; power-cycle recovery argues against confirmed permanent wire break but does not close the case without connector, cable, grounding, parameter, and retest evidence.

## `omniflow.component_test.baffle_motor_can_communication_loss`

- Product line: `omniflow`
- Corpus: `component-test`
- Primary specialists: `can-bus`, `embedded-software`, `vision-media`
- Secondary specialist: `mantis-handling`
- Runtime knowledge: `component-test/knowledge/baffle-motor-can-communication-loss.md`
- Pattern: baffle robot or baffle actuator reports CAN communication abnormal stop, stale or stopped motor temp/voltage telemetry, `CAN_MOTOR_ERROR`, baffle-up command error, servo reset error, and failed recovery. A normal-looking bus resistance measurement such as `112.4Ω` does not exclude intermittent connector, node power, or single-node communication loss.
