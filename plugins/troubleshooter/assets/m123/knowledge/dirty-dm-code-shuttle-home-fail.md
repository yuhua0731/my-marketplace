# Dirty DM Code Causing Shuttle Home Fail

## Symptoms

- M123 / MiniSort Pro startup or homing fails.
- UI reports `SHUTTLE_HOME_FAIL` and/or `回原点时编码器异常`.
- The affected robot may show normal voltage, for example `55.02V`, and the alarm can point to a specific robot such as `M003R`.

## Fault Tree

- Confirmed branch: align UI alarm, robot ID, and timestamp.
  - In `m123-pt-0129`, M003R reports `SHUTTLE_HOME_FAIL` at `2026-05-09 15:17:13`.
  - The same event also reports `回原点时编码器异常`, robot `M003R`, voltage `55.02V`.
- Confirmed branch: inspect the DM/barcode image before declaring encoder hardware failure.
  - Local DM image shows the code strip around `C0002360`, `C0002400`, and `C0002440`.
  - Source analysis states the startup failure was caused by dirty DM codes.
- Confirmed branch: cleaning the barcode restored normal operation.
  - Source states `清洁条码后恢复正常`.
- Likely branch: dirty or low-contrast DM code causes localization/homing decode failure, which surfaces as `SHUTTLE_HOME_FAIL` or encoder abnormality.
- Related branch: dense-center offset or camera geometry can cause similar alarm text, but that requires center-line/config evidence. Do not merge this contamination case with offset cases.

## Evidence Needed

- Raw robot/NXP logs around the alarm timestamp.
- DM camera decode debug output before cleaning, including confidence, decode result, and any `SCAN OUT OF AREA` or read failure.
- Before/after DM code photos under the same lighting/camera exposure.
- Repeated startup/homing retest after cleaning.
- Maintenance record identifying contamination type, cleaning method, and whether more DM strips are affected.

## Logs And Files To Inspect

- Case body: `cases/accepted/m123/0129-LzJdwdrOViupF2kY92wcoiFBnJf-2026-05-09-M123Pro开机失败.md`.
- `assets/m123-pt-0129/retry-image-001-KahpbJQEkoWd8VxKTNgcRo2snuh.png`: `SHUTTLE_HOME_FAIL`, M003R, `2026-05-09 15:17:13`.
- `assets/m123-pt-0129/retry-image-002-QkE9bl14ho3eTfxkWm7c0Jt4nug.png`: `回原点时编码器异常`, M003R, `55.02V`.
- `assets/m123-pt-0129/retry-image-003-KMWBbTtvgoRfMkxgCrGc97wsnEc.png`: overview map and highlighted M003R position.
- `assets/m123-pt-0129/retry-image-004-JGXsb9Pqqo88o5xX3DEcz51hn7e.jpg`: physical robot/DM reading area.
- `assets/m123-pt-0129/retry-image-005-WLcmb1Zqxo1kqFxzHaqcAf7qntf.jpg`: DM code strip with `C0002360`, `C0002400`, `C0002440`.
- Search terms: `M123Pro开机失败`, `M003R`, `SHUTTLE_HOME_FAIL`, `回原点时编码器异常`, `DM码脏污`, `清洁条码后恢复正常`, `C0002360`, `C0002400`, `C0002440`.

## Likely Causes

- Dirt, smudge, low contrast, or partial contamination on the DM/barcode strip blocks reliable localization during startup/homing.
- Camera image quality or lighting can amplify a dirty-code problem.
- If cleaning does not resolve it, then inspect camera geometry, dense-center offset, encoder, motor, drive, and CAN evidence.

## Exclusion Checks

- Do not route to M004 `dense_center_offset` solely from `SHUTTLE_HOME_FAIL` or `回原点时编码器异常`.
- Do not replace encoder or motor before checking DM code cleanliness and decode images.
- Do not treat normal-looking UI voltage as proof of power health beyond this event; it only makes low-voltage root cause less likely here.
- Do not close a repeat issue without post-clean repeated homing/startup retest.

## Confirmed Examples

- `m123-pt-0129`: M003R failed startup at `2026-05-09 15:17:13` with `SHUTTLE_HOME_FAIL` and `回原点时编码器异常`; UI showed `55.02V`. The source says inspection found dirty DM codes, and cleaning the barcode restored normal operation. Local DM image shows nearby code labels `C0002360`, `C0002400`, and `C0002440`.

## Unresolved Examples

- `m123-pt-0129`: no raw robot log, no decode confidence frame, no post-clean image, and no repeated retest count are local.

## Specialist Routing

- Start with `vision-media` for DM/barcode image quality, dirt, lighting, and camera view.
- Add `robot-motion` for startup/homing localization and shuttle position.
- Add `embedded-software` for alarm translation, decode logs, and homing state-machine evidence.
- Add `can-bus` only if encoder/CAN errors remain after barcode cleaning and decode checks.
