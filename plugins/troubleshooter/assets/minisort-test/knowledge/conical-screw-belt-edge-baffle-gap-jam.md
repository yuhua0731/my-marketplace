# Conical Screw Belt Edge Baffle Gap Jam

## Symptoms

- Mini drag-chain baffle robot fails to throw a head-heavy or conical object.
- The object rotates in place while the robot is running, then drifts or slides toward the belt edge.
- During throw-off, the object can enter the belt-edge / baffle gap and jam on or near the baffle motor.
- In `minisort-test-pt-0103`, the test object is a screw: head-heavy, long, narrow, and effectively conical for transport behavior.

## Fault Tree

- Confirmed branch: the problematic object geometry is head-heavy and directionally unstable.
  - Source text says the screw is `头重脚轻（锥形物品）`.
  - Source text says it easily rotates in place while the robot is running.
  - Photo `001-image-1266516026a2.jpg` shows a long screw on the belt with the head on one end and a narrow threaded shaft.
- Confirmed branch: the failure position is the belt edge / baffle-side boundary.
  - Source text says the object easily slides out to the belt edge during throw-off and gets stuck on the baffle motor.
  - Photo `002-image-2ac66d64435b.jpg` shows the screw head at the right-side belt edge near the metal baffle/guard gap.
- Evidence-backed branch: this is a physical handling and media-inspection pattern, not a CANopen parameter failure.
  - No source text mentions `CO_SDOClientDownload`, `6083`, `6084`, motor ratio, or baffle non-descent.
  - The failure is object pose/geometry entering a mechanical boundary during throw-off.
- Blocked branch: full motion sequence and final remediation.
  - The local video is available, but without `ffmpeg/ffprobe` only a QuickLook representative frame was extracted.
  - The representative frame shows the MiniSort baffle/throwing scene, but not the exact jam instant.
  - Source `Analysis`, `Resolution`, and `Actions Taken` are empty or `unknown`.

## Evidence Needed

- Full frame sequence from before rotation, edge drift, throw-off, and jam.
- Belt width, side-guide/baffle gap size, baffle motor protrusion, and object dimensions/weight distribution.
- Test matrix for cylindrical, boxed, spherical, long, head-heavy, and conical items.
- Before/after evidence for any guide rail, side guard, baffle cover, belt speed, throw timing, or item-orientation fix.
- Whether the failure repeats only for screws/conical objects or for all small long objects.

## Logs And Files To Inspect

- Case body: `cases/accepted/minisort-test/0103-HEshwpSKYi0pkFkwQbScGU8Bn7g-2026-04-28-Mini拖链挡板机器人-锥形物品抛货时掉落在皮带与挡板之间.md`.
- `assets/minisort-test-pt-0103/001-image-1266516026a2.jpg`: screw object on the belt; head-heavy, long, narrow geometry.
- `assets/minisort-test-pt-0103/002-image-2ac66d64435b.jpg`: screw at the belt edge near the metal baffle/guard gap.
- `assets/minisort-test-pt-0103/003-source-XaDcbGZ2Ro31mTxiqpAcpiVjnne.mov`: MOV video, `960x540`, `16.234s`, `3498864` bytes; QuickLook frame `/tmp/minisort-test-pt-0103-frames/003-source-XaDcbGZ2Ro31mTxiqpAcpiVjnne.mov.png`.
- Search terms: `锥形物品`, `头重脚轻`, `原地旋转`, `皮带边缘`, `皮带与挡板之间`, `挡板电机`, `抛货失败`, `螺丝钉`, `belt edge`, `baffle gap`, `conical parcel`.

## Likely Causes

- Head-heavy/conical objects have unstable contact and can rotate instead of translating cleanly on the belt.
- Rotation plus belt motion can drive the object laterally toward the edge, especially if the head catches or changes friction direction.
- The belt-edge / baffle-side gap or baffle motor exposure gives the object a capture point during throw-off.
- Less likely as primary cause: baffle motor parameter/CAN failure, because visible evidence points to object geometry and mechanical boundary capture rather than baffle non-descent.

## Diagnostic Rules

- Treat long, head-heavy, tapered, or screw-like items as high-risk for lateral drift and edge capture during throw-off.
- For throw failures with such objects, inspect video frames first: object orientation, rotation, belt-edge drift, baffle/gap contact, and final jam point.
- Measure the physical gap and exposed motor/guard geometry before tuning motor parameters.
- Reproduce with representative shapes, not only ordinary rectangular parcels.
- If the object reaches the belt edge before the throw command, start with guidance/containment and belt contact mechanics.

## Exclusion Checks

- Do not route this to `baffle_motor_gear_ratio_accdec_sdo_range` unless logs show SDO aborts on `6083`/`6084` or the baffle does not descend.
- Do not diagnose scheduler or WRS quantity logic; the symptom is physical object trajectory/jam.
- Do not blame generic belt speed without visual proof of lateral drift, rotation, or a gap capture point.
- Do not claim a fix without a post-fix run using the same screw/conical item class.

## Confirmed Examples

- `minisort-test-pt-0103`: during Mini drag-chain baffle robot receive/throw testing with screws, the screw was head-heavy and rotated in place while the robot ran. During throw-off it slid toward the belt edge and got stuck near the baffle motor, causing throw failure. Photos show the screw geometry and the screw head positioned at the belt edge near the metal baffle/guard gap.

## Unresolved Examples

- `minisort-test-pt-0103`: full video frame sequence, exact jam timestamp, gap dimensions, item dimensions, fix choice, and post-fix retest are not local.

## Specialist Routing

- Start with `vision-media` for frame-by-frame physical-state review.
- Add `mantis-handling` for baffle/throwing mechanism geometry, guards, gap, and object handling.
- Add `robot-motion` only if belt/robot motion profile or lateral acceleration is implicated by logs or frame timing.
- Add `embedded-software` only if motor commands, baffle state, or belt control timing are abnormal after the physical gap/object branch is checked.
