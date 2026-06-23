# M004 Fault Taxonomy

## Camera Decode And Homing

- `omnisort.m004.allcandm_seam_crop_marker_detection`
  - Product line: OmniSort / 慧仓闪电播.
  - Typical symptom: MiniSort Pro no-scan loading mode reports `移动时标记点检测异常` after locking `M004R`.
  - Primary evidence: `dmenc: datamatrix decode failed`, seam/code-height discontinuity, selected upper/lower bright rows, center line, and crop cutting into the code.
  - Primary specialists: `vision-media`, `robot-motion`, `embedded-software`; add `can-bus` only if CAN evidence exists.
  - Knowledge: `knowledge/allcandm-seam-crop-marker-detection.md`.

- `omnisort.m004.allcandm_dense_center_offset_shuttle_home_fail`
  - Product line: OmniSort / 慧仓闪电播.
  - Typical symptom: MiniSort Pro self-test startup reports `SHUTTLE_HOME_FAIL` or `回原点时编码器异常` for `M004R` at feeder/conveyor position.
  - Primary evidence: robot at feeder-position code strip, decode debug image showing center-line mismatch, and `AllCANDM/dense_center_offset` value `0`.
  - Primary specialists: `robot-motion`, `vision-media`, `embedded-software`, `can-bus`.
  - Knowledge: `knowledge/allcandm-dense-center-offset-shuttle-home-fail.md`.

## Evidence Status

- Treat the encoder-abnormal popup as symptom text, not proof of encoder hardware failure.
- Treat the marker-detection popup as symptom text, not proof of CAN or motor failure.
- For feeder-position homing failures, inspect DM/barcode decode geometry before replacing encoder/drive hardware.
- For seam-position marker failures, inspect ALLCAN-DM selected rows, crop window, and raw image before replacing hardware.
- Require before/after config and retest evidence before declaring the offset adjustment fully verified.
