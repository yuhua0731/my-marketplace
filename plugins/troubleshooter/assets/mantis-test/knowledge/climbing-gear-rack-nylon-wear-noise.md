# Climbing Gear-Rack Nylon Wear Noise

## Symptoms

- Mantis spider mechanism makes `哐哐哐` or `哐当哐当` mechanical noise during up/down climbing.
- The symptom appears after high-cycle endurance running, for example empty-load `24 hours` at `1.5m/s` and `1m/s^2`.
- Source context can include replacement of climbing gear, harness, or motor before the endurance test, but the noise itself is mechanical.

## Fault Tree

- Confirmed branch: abnormal noise is mechanically coupled to the climbing rack/gear pair.
  - `mantis-test-pt-0118` source states the climbing rack and gear were worn.
  - Source states abnormal gear-rack meshing caused the clunking sound.
- Confirmed branch: material pairing is high-risk.
  - Source states rack material was `PA66`.
  - Source states gear material was `MC901`.
  - Source classifies this as all-plastic transmission and nylon-on-nylon friction.
- Supported branch: visible local photos show wear evidence.
  - Gear/shaft/keyway images show reddish-brown abrasion residue, grooves, and wear tracks.
  - Bore/roller photos show additional scoring/dirty wear context around rotating interfaces.
- Likely branch: high-cycle vertical motion accelerates wear and backlash growth.
  - Empty-load `24h` running at `1.5m/s` and `1m/s^2` can expose material-pair durability issues.
  - Increased backlash or tooth-profile wear can make rack/gear teeth impact and produce clunking.
- Secondary branch: alignment, bearing/shaft support, rack straightness, and gear installation can aggravate the same noise and should be checked before closure.
- Exclusion branch: CAN or motor-control faults are not primary unless decoded logs show aligned motor/CAN errors. A raw CAN CSV alone is only context.

## Evidence Needed

- Full video/audio aligned to the moment of `哐哐哐` noise.
- Close-up photos of gear teeth, rack teeth, shaft/keyway, bearings, and mounting/bore areas before and after replacement.
- Gear/rack material spec, hardness/wear-resistance data, and part batch.
- Backlash, tooth wear depth, rack straightness, shaft/bearing play, and installation/alignment measurements.
- Motor current/torque or CAN decoded state during the noise window.
- Same-condition retest after material change: speed, acceleration, load, duration, noise, backlash, and wear state.

## Logs And Files To Inspect

- `cases/accepted/mantis-test/0118-VSXOwGGhUiVMxTkfqaFcwqEXnUg-2026-05-09-一楼003螳螂异响.md`: source body.
- `assets/mantis-test-pt-0118/retry-image-001-Jh62bAsVjoq6yXxZpHXcGWO8n7g.jpg`: mounting/bore wear and scoring context.
- `assets/mantis-test-pt-0118/retry-image-002-DZcFbXZJDoCGL1xlZkNcgEdRnAe.jpg`: roller/bearing wear context.
- `assets/mantis-test-pt-0118/retry-image-003-MsBCb6CYQosVg8xLhhTcmmMknXg.jpg`, `retry-image-004-TpavbqAHHoIkorxRYGhcGpVqn8g.jpg`, `retry-image-005-QRG5bSNNvojP2vxk5fPc84Z2nwh.jpg`: gear/shaft/keyway wear residue and grooves.
- `assets/mantis-test-pt-0118/retry-image-006-Q3cdbGCL8oLuj2xEZVocPJwXnbh.jpg`: overall rack/climbing context.
- `assets/mantis-test-pt-0118/retry-source-*.mp4` and `retry-source-*.mov`: Mantis climb/motor context; inspect representative frames and audio if tooling permits.
- `assets/mantis-test-pt-0118/retry-source-PGbAbbXoJoUlMyxcJFZchem7nXC.csv`: raw CAN capture; requires project-specific COB-ID dictionary before using it for motor-state conclusions.
- Search terms: `003螳螂`, `爬升齿轮`, `爬升齿条`, `齿轮齿条`, `啮合不正常`, `哐哐哐`, `哐当哐当`, `PA66`, `MC901`, `全塑传动`, `尼龙配尼龙`, `更换齿轮材质`.

## Likely Causes

- PA66 rack and MC901 gear form a nylon-on-nylon pair with poor wear life for the observed duty cycle.
- Wear increases backlash and worsens gear-rack mesh, causing tooth impact noise during vertical movement.
- Gear material, installation alignment, bearing/shaft support, or rack straightness can jointly determine whether the wear becomes audible quickly.

## Exclusion Checks

- Do not route to CAN2 harness fault without resistance jump, CANH/CANL continuity issue, heartbeat loss, or decoded CAN fault evidence.
- Do not blame the 1000W motor without current, torque, drive fault, or speed-control evidence.
- Do not treat harness replacement as the cause of mechanical clunking unless the noise changes with harness state or routing interference.
- Do not close the case after material change without same-condition endurance retest and wear/noise comparison.
- Do not infer material or wear severity from file names; use source text, visible photos, measurements, and retest records.

## Confirmed Examples

- `mantis-test-pt-0118`: 003 Mantis used Xinliu 1000W motor, replaced climbing gear and harness, then ran empty-load `24h` from `05-08 10:00` to `05-09 10:00` at `1.5m/s` and `1m/s^2`. During spider mechanism up/down movement, it produced `哐哐哐` mechanical noise. Source analysis says climbing rack/gear wear caused abnormal meshing and clunking. Source further says PA66 rack plus MC901 gear formed an all-plastic nylon-on-nylon pair with fast wear. Resolution was changing gear material. Local photos show wear residue/grooves on the gear/shaft/keyway and wear/scoring context on nearby rotating interfaces.

## Unresolved Examples

- `mantis-test-pt-0118`: no full audio transcript, no timestamped sound frame, no measured wear/backlash, no material certificate, no decoded CAN mapping, and no same-condition post-material-change retest are local.

## Specialist Routing

- Start with `mantis-handling` for climbing rack/gear, spider mechanism, shaft/bearing support, alignment, and material replacement.
- Add `vision-media` for photo/video inspection of wear, rack movement, and the audible-noise moment.
- Add `embedded-software` or `can-bus` only when logs, CAN decode, current/torque, heartbeat, or drive faults are aligned with the noise window.
