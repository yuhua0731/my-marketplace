# Ant 3 Test Fault Taxonomy

## `omniflow.ant3.lift_home_sensor_sheetmetal_gap_misalignment`

- Product line: `omniflow`
- Corpus: `ant-3-test`
- Primary specialists: `robot-motion`, `vision-media`, `embedded-software`
- Runtime knowledge: `ant-3-test/knowledge/lift-home-sensor-sheetmetal-gap-misalignment.md`
- Pattern: Ant 3.0 lift origin sensors disagree after homing, for example `inductiveSensorFront: true` and `inductiveSensorRear: false`. Prioritize physical sensor-target gap, sheet-metal bend tolerance, and dual-side installation datum. A `2.5mm` design gap equals the sensor maximum working distance but exceeds the stable `0~2.1mm` range, so small machining or assembly errors can cause missed trigger or collision.

## `omniflow.ant3.allcan4_copper_standoff_insulation_short`

- Product line: `omniflow`
- Corpus: `ant-3-test`
- Primary specialists: `vision-media`, `can-bus`, `embedded-software`
- Runtime knowledge: `ant-3-test/knowledge/allcan4-copper-standoff-insulation-short.md`
- Pattern: Ant 3.0 ALLCAN-4 sparks, smokes, or burns during `init+move`, lift homing, or lift motor start. Prioritize board mounting and insulation inspection: copper standoff or metal mounting hardware may press through ALLCAN-4 insulation, expose internal routing, and cause a local short. Normal static `25.0V` input or normal robot function does not clear the safety risk.

## `omniflow.ant3.allcan_power_and_dm_camera`

- Product line: `omniflow`
- Corpus: `ant-3-test`
- Primary specialists: `can-bus`, `embedded-software`, `vision-media`
- Secondary specialist: `robot-motion`
- Runtime knowledge: `ant-3-test/knowledge/allcan-power-and-dm-camera.md`
- Pattern: Ant 3.0 ALLCAN/camera issues split into power-reset, DM decode timing, and boost/load branches. Check 24V rail, board reset, DM decode statistics, robot speed/path, and boost-module voltage/current before merging distinct symptoms.

## `omniflow.ant3.bumper_bracket_fastener_fracture`

- Product line: `omniflow`
- Corpus: `ant-3-test`
- Primary specialists: `vision-media`, `robot-motion`, `embedded-software`
- Runtime knowledge: `ant-3-test/knowledge/bumper-bracket-fastener-fracture.md`
- Pattern: Ant 3.0 bumper bracket fixed screw/fastener fracture or missing/broken bracket fastening point. Prioritize physical structure inspection: confirm whether the failed object is screw shank, insert/standoff, bracket boss, or loosened/missing fastener; then check witness-paint movement, torque/process record, thread engagement, bumper impact/collision history, bracket deformation, and same-batch fleet risk. Do not route to CAN/ALLCAN/power unless logs show aligned electrical symptoms.
