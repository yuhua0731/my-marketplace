# Throwing Baffle Scraping Drive Shaft

## Symptoms

- OmniSort / M145 lift module has a throwing-mechanism baffle or side guard close to the active drive shaft or roller.
- Source reports `提升模组抛物机构挡板与主动轮轴剐蹭`.
- Close-up photos show the baffle/guard plate, drive shaft, wheel/roller, and adjacent belt path with very small clearance.
- Local video is available and readable, but only a Quick Look representative frame was extracted in this environment.

## Fault Tree

1. Confirm the contact point and witness marks.
   - Inspect close-up photos, slow-motion video, and onsite rub marks on the baffle edge, shaft, roller, bearing block, and belt surface.
   - Mark whether contact is static at rest, occurs during throwing motion, or only appears when the lift/throwing assembly vibrates.
   - Measure clearance through the full stroke and at the worst tolerance stack-up.
2. Check baffle/guard installation geometry.
   - Verify the baffle plate is not bent, skewed, reversed, shifted by slot clearance, or installed with the wrong spacer/washer stack.
   - Check screw tightness, locating surfaces, and whether the plate edge intrudes into the shaft/roller dynamic envelope.
3. Check active shaft, roller, and bearing-seat position.
   - Verify shaft axial position, bearing block alignment, wheel/roller runout, and whether fasteners or collars have walked outward.
   - Check whether the belt, roller cover, or adjacent throwing mechanism pushes the shaft side into the baffle clearance.
4. Check assembly tolerance and production variation.
   - Compare with another M145 unit or another lift module using the same baffle and shaft design.
   - Review drawings/BOM/change records for baffle thickness, bend radius, mounting hole position, spacer length, and shaft collar stack.
5. Validate correction dynamically.
   - After adjustment, trimming, spacer change, or part correction, run the lift/throwing cycle repeatedly under normal speed/load.
   - Re-check noise, rub marks, belt tracking, shaft heat, and clearance after vibration.

## Evidence Needed

- Photos or video frame showing the exact contact point and rub/witness marks.
- Measured static and dynamic clearance between baffle/guard and active shaft/roller.
- Baffle plate drawing/BOM/version, mounting-hole tolerance, bend angle, spacer/washer stack, and installation orientation.
- Shaft/bearing-seat drawing or inspection record: axial position, runout, collar/fastener position, and bearing block alignment.
- Before/after validation video or inspection record after mechanical adjustment.

## Logs And Files To Inspect

- Source text and reports with `M145`, `提升模组`, `抛物机构`, `挡板`, `主动轮轴`, `主动轮`, `剐蹭`, `干涉`, `间隙`, `轴向窜动`, `装配偏差`, `bearing block`, `drive shaft`, `roller`, `clearance`.
- Photos/video first; motion logs are secondary and mainly useful for cycle timing and repeatability.
- CAD/drawing/BOM/change records for the baffle, side guard, shaft, roller, bearing block, and spacer stack.
- Assembly inspection records for baffle orientation, screw torque, shaft axial position, and belt/roller alignment.

## Likely Causes

- Baffle/guard plate is installed with insufficient clearance to the shaft/roller dynamic envelope.
- Baffle plate is bent, skewed, reversed, or shifted by mounting-hole tolerance.
- Shaft, collar, roller, or bearing block is axially offset or has runout that consumes the clearance.
- Spacer/washer stack or part revision changed the baffle-to-shaft distance.
- Vibration or throwing-cycle load makes a marginal static clearance become contact.

## Exclusion Checks

- Do not call embedded/CAN/scheduler root cause without logs showing abnormal motion commands or unexpected state transitions.
- Do not prescribe trimming the baffle before confirming whether shaft/roller axial position or bearing-seat installation is out of tolerance.
- Do not prove clearance from one static photo; inspect the full throwing/lift cycle and post-run witness marks.
- Do not merge this with drag-chain scrape: this branch is local baffle/drive-shaft or roller interference inside the lift/throwing mechanism.
- If video tooling cannot extract full frames, record the limitation and rely only on visible photo/thumbnail evidence.

## Confirmed Examples

- `m145-pt-0158`: source reports M145 lift-module throwing-mechanism baffle scraping the active drive shaft. Local photos show the baffle/guard plate and drive shaft/roller area with very small clearance; Quick Look video thumbnail shows the same assembly envelope.

## Unresolved Examples

- `m145-pt-0158`: no measured clearance, exact rub mark photo, drawing/BOM/version, shaft runout/axial-position measurement, or post-fix validation evidence is present. Full video frame extraction was unavailable because ffmpeg/Python video libraries were not installed.

## Specialist Routing

- `vision-media`: inspect close-up photos, video frames, witness marks, and before/after clearance evidence.
- `robot-motion`: use only if motion cycle dynamics, vibration, or repeatability by position/speed changes the contact.
- `embedded-software`: use only if logs show abnormal motion commands, state transitions, or cycle timing that causes unexpected physical overlap.
