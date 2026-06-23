# CS002 Fault Taxonomy

CS002 belongs to OmniFlow / 慧仓穿云箭. Classify by observed failure chain:
mechanical structure, fastener retention, lift transition, motion/CAN, or
scheduler symptoms.

## Throwing Mechanism And Structure

- `throwing_mechanism_fastener_fatigue_fracture`: throwing mechanism fixed-hole,
  folded sheet metal, screw group, or bracket fractures under repeated vibration.
- `fastener_loosening_vibration_amplifier`: screw/nut looseness increases
  throwing-mechanism vibration amplitude and accelerates structural cracking.
- `lift_transition_impact_excitation`: lift reducer backlash or height mismatch
  between lift plate and horizontal rail creates impact vibration when the robot
  crosses the transition.

## Lower Priority Branches

- `drive_or_can_contributor`: use only when same-window motor current, drive
  alarm, or CAN evidence appears before the mechanical failure.
- `material_or_process_defect`: use when fracture repeats after vibration,
  fastener retention, and geometry are corrected, or material/fracture analysis
  supports a part defect.

## Case Anchors

- `cs002-pt-0062`: throwing mechanism and base frame had few fixing points;
  screws loosened under severe vibration caused by lift backlash / height step;
  repeated bending fractured the sheet metal at a folded weak point.
