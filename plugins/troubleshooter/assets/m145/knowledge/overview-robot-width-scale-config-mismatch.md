# Overview Robot Width Scale Config Mismatch

## Symptoms

- M145 / OmniSort overview page shows robot icons wider than slot/grid cells.
- The source says robot width configuration was checked and appeared normal.
- Screenshots show robot physical/config width values such as `机器人宽 (mm) = 674` and runtime config such as `positionMap.shuttleWidth = 0.674`.

## Fault Tree

1. Separate display geometry from motion geometry.
   - In `m145-pt-0156`, the visible symptom is on the Sort Control System overview page; no robot motion, collision, or loading failure is locally documented.
   - If the robot runs normally and only the icon is too wide, prioritize frontend/map rendering and config transformation.
2. Check parameter-table to runtime-config unit conversion.
   - Local parameter-table screenshot shows `机器人宽 (mm) = 674`.
   - Local config screenshot shows `positionMap.shuttleWidth: 0.674`.
   - These are consistent if the renderer expects meters, so do not stop at "width config is wrong".
3. Compare icon width against grid geometry.
   - Inspect `horizontalTrackLength`, `verticalTrackLength`, `gridCountInOneTrackSide`, slot/grid width, canvas/SVG scale, zoom level, and CSS transform.
   - Check whether robot width is drawn in the wrong axis, double-scaled, treated as pixels instead of meters, or compared to a grid cell using a different unit.
4. Confirm model/version selection.
   - The parameter-table note says large fixed parameter `655`, while the highlighted value is `674`; verify whether M145 should use `674`, `655`, or a model-specific override.
5. Root cause remains blocked until raw config and frontend/runtime payload prove the exact mismatch.

## Evidence Needed

- Raw `rcs_config.json`, not only screenshot, including full `positionMap`.
- Frontend/API payload consumed by the overview page for `shuttleWidth`, track lengths, grid counts, and zoom.
- Renderer code or config mapping that converts meters/mm to pixels.
- Slot/grid width definition and physical/logical cell dimensions.
- Browser zoom/device pixel ratio and whether the screenshot is affected by page zoom.
- Before/after fix screenshot and commit/config diff.

## Logs And Files To Inspect

- Case body: `cases/needs-assets/m145/0156-NExQwYVYKixaUMk5iPLcrArUnAh-2026-06-11-M145界面概览图机器人宽度不对.md`.
- Local overview screenshot: `assets/m145-pt-0156/retry-image-001-B8Lhb298so4wKFxAlbqcAvIsnqg.png`.
- Local parameter screenshot: `assets/m145-pt-0156/retry-image-002-MXnXbbjSio8trDxQPwWc0F1LnPd.png`.
- Local config screenshot: `assets/m145-pt-0156/retry-image-003-EdYwbEH8zo4XPQx2kaccpoHDnlf.png`.
- Search terms: `shuttleWidth`, `positionMap`, `horizontalTrackLength`, `verticalTrackLength`, `gridCountInOneTrackSide`, `机器人宽`, `格口宽度`, `overview`, `canvas`, `scale`.

## Likely Causes

- Frontend overview renderer uses a different unit or scale than `positionMap.shuttleWidth`.
- Slot/grid width and robot width are converted from different coordinate systems.
- Runtime service or frontend cache reads stale geometry despite the screenshot showing the expected config.
- Model-size selection is ambiguous because the parameter table note and highlighted value do not agree.

## Exclusion Checks

- Do not diagnose scheduler hardlink/config-loss unless command payloads or robot physical/map position diverge.
- Do not diagnose CAN gateway or IO function-code compatibility unless missing buttons or IO controls are involved.
- Do not diagnose mechanical width or collision without physical clearance, collision, loading, or motion evidence.
- Do not claim frontend renderer root cause from screenshots alone; require raw payload and scale calculation.

## Confirmed Examples

- None. `m145-pt-0156` is evidence-limited but useful as a diagnostic pattern.

## Unresolved Examples

- `m145-pt-0156`: overview screenshot shows M001/M002/M003 robot icons wider than slot/grid cells. Parameter screenshot shows `机器人宽=674mm`, and config screenshot shows `shuttleWidth=0.674`; root cause is not proven because raw config, runtime payload, renderer code, grid width definition, and fix result are missing.

## Specialist Routing

- Start with `scheduler-traffic` for map/config/runtime geometry and site/grid definitions.
- Add `vision-media` to inspect screenshots and compare rendered icon width to grid width.
- Add `embedded-software` only if the running service loads stale config or publishes wrong geometry to frontend.

