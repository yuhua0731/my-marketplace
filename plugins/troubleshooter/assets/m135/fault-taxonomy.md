# M135 Fault Taxonomy

## Robot Indicator And Firmware

- `omnisort.m135.allcan_led_firmware_version_mismatch`
  - Product line: OmniSort / 慧仓闪电播.
  - Typical symptom: robot `ALLCAN-LED` stays at initialization color and does not follow running, fault, standby, or idle states.
  - Primary evidence: source says `机器人固件不对`; Wormhole flashing cannot write the robot; `flash-image` returns `kStatus_FlexSPINOR_CommandFailure`; J-Link is used for handling.
  - Primary specialists: `embedded-software`, then `can-bus` if state frames are available, plus `vision-media` for light-state proof.
  - Knowledge: `knowledge/allcan-led-firmware-version-mismatch.md`.

## Evidence Status

- Treat `ALLCAN-LED` as a robot/device branch, not workstation WLED/HLED, unless the source explicitly names a workstation light strip.
- Treat firmware mismatch as likely, not fully confirmed, until expected version matrix, package checksum, and post-flash retest are available.
- Treat CAN involvement as unproven until CAN/status-frame evidence is collected.
