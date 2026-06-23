# CS002 Throwing Mechanism Fastener Fatigue Fracture

## Scope

Use this when a CS002 / OmniFlow baffle robot has throwing-mechanism fixed-hole,
sheet-metal, bracket, or screw-connection fracture during operation.

This is primarily a mechanical vibration, fastener retention, and handling
structure issue. Treat motor/CAN/software signals as secondary unless same-window
logs prove they preceded the mechanical failure.

## Symptoms

- Baffle robot throwing mechanism fixed connection is `震断`, fractured, or
  cracked near screw holes, long slots, folded edges, or corner fastener groups.
- Photos show cracked black sheet metal near the throwing mechanism / base-frame
  connection.
- Screws or nuts near the broken region are loose, have visible clearance, or
  show shifted witness marks.
- Source mentions severe vibration when the robot passes a lift plate /
  horizontal-track height transition.

## Fault Tree

- Too few fixing points or poor load path:
  - Small corner fastener groups and long slots concentrate dynamic load at the
    folded sheet-metal edge.
- Fastener loosening under vibration:
  - Loose screws increase mechanism vibration amplitude, causing repeated
    bending at the fixed hole or fold.
- Lift backlash and height transition excitation:
  - Large reducer backlash or height difference between the lift plate and
    horizontal rail creates impact vibration as the robot passes the transition.
- Sheet-metal bend fatigue:
  - Folded regions can contain microcracks or lower fatigue margin; repeated
    bending eventually fractures the sheet metal.

## Evidence Needed

- Robot IDs, location, runtime window, load state, and whether the fracture is
  on one or multiple robots.
- Close-up photos of the fracture surface, fixed holes, folded edge, screws,
  nuts, washers, and witness paint.
- Dynamic video or slow-motion capture when the robot crosses the lift/track
  transition.
- Measurement of lift reducer backlash and height difference between lift plate
  and horizontal rail.
- Fastener torque/process record, thread-locking method, washer/locking hardware
  spec, and post-run torque check.
- Repair action and retest result under the same transition and load.

## Logs And Files To Inspect

- Case body and local media under `assets/<case_id>/`.
- Videos showing lift/track height transition, mechanism shaking, or screw
  movement.
- Maintenance records for reducer backlash, rail/lift height adjustment, screw
  torque, thread locker, washer, and reinforced bracket changes.
- If available: motor current/torque spikes during the transition and any
  same-window drive/CAN alarms.

## Likely Causes

- The throwing mechanism and base frame are fixed by too few points, allowing
  repeated bending at a weak folded sheet-metal region.
- Severe vibration from lift backlash and height step loosens screws and
  increases mechanism motion.
- Fatigue fracture occurs at the folded/fastened region after repeated bending.

## Diagnostic Rules

- For fixed-hole or folded-edge fracture, inspect the upstream vibration source
  before replacing the broken sheet metal.
- If screws are loose, check whether looseness is cause, amplifier, or
  consequence: inspect witness marks, torque, thread locking, washers, and slot
  wear.
- Dynamic transition checks matter: run the robot through the lift/horizontal
  rail transition while observing the throwing mechanism and fastener group.
- Strengthening only the broken part is incomplete unless fixing-point count,
  screw retention, reducer backlash, and height difference are also addressed.

## Exclusion Checks

- Exclude CAN/software as primary when no logs show communication or drive
  errors before the mechanical crack.
- Exclude a pure material defect until fastener retention, fixing-point count,
  and vibration source are checked.
- Exclude simple screw replacement as a complete fix unless post-run torque and
  no-new-crack retest are recorded.

## Confirmed Examples

- `cs002-pt-0062`: CS002 `I39B67S` / `I39B45S` baffle robots had throwing
  mechanism screw-fixed connection fractured during operation. Source analysis
  says the throwing mechanism and base frame had few fixing points; the CS002
  lift reducer had large backlash; the lift plate and horizontal rail had a
  large height difference; the robot generated severe vibration at this
  position. Loose screws increased mechanism vibration amplitude, and repeated
  bending caused sheet-metal fatigue fracture at the folded weak point. Local
  images show the cracked fastener/fold area and loose/clearance-prone fastener
  region; video thumbnails show lift/track transition and fastener group
  context.

## Unresolved Examples

- `cs002-pt-0062`: full frame-by-frame video inspection, vibration measurement,
  fastener torque/process record, fracture analysis, repair action, and retest
  evidence were not available locally.

## Specialist Routing

- `mantis-handling`: throwing mechanism, baffle robot structure, fastener group,
  lift transition, reducer backlash, and dynamic vibration.
- `vision-media`: fracture photos, screw looseness, long-slot/fold geometry,
  and video of transition vibration.
- `embedded-software` / `can-bus`: only if same-window logs show drive/CAN
  faults before mechanical failure.
