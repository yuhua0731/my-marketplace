# C132 Fault Taxonomy

C132 belongs to OmniFlow / 慧仓穿云箭. Classify Mantis/fork cases by the observed
failure chain and evidence, not by the generic presence of a Mantis device.

## Fork And Rail Mechanical Interference

- `fork_cover_deformation_rail_wear`: fork cover or guard plate deforms toward
  the rail, causing localized rail-top wear, powder, discoloration, or scratches
  during fork movement.
- `post_rework_clearance_or_alignment`: after repair/rework, cover, rail, screw,
  bracket, or fork parallelism tolerance creates marginal clearance that only
  appears under dynamic stroke or load.

## Lower Priority Branches

- `rail_material_or_surface_defect`: use when wear recurs without a nearby
  interference source or when material/coating evidence points to rail quality.
- `drive_or_can_contributor`: use only when same-window logs show motor current,
  torque, drive alarm, or CAN fault associated with fork movement.

## Case Anchors

- `c132-pt-0174`: cover bottom deformation rubbed A-side inner fork rail top;
  repair/replacement plus rail surface repair was followed by `90h` and `198h`
  retests with no new wear.
- `c132-pt-0005`: A-side inner fork rail top scratches/debris after `87h`
  `35kg` pull/return on `J38A07SP` and `J38A11SP`; no noise or obvious
  interference was found in the visible source, so the case remains an
  unresolved recurrence requiring dynamic clearance and material checks.
