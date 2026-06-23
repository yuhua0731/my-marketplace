# M147 Fault Taxonomy

## Physical IO And Harness Labeling

- `omnisort.m147.photoelectric_height_limit_dio_label_miswire`
  - Product line: OmniSort / 慧仓闪电播.
  - Typical symptom: photoelectric height-limit sensor signal line is labeled or connected to `DIO3` while the IO table expects `DIO2`.
  - Primary evidence: `M147_IO地址变量表_V01.xlsx` maps `限高光电传感器` to `DI02`; field cable label shows `CONN No.: DIO3`; source says actual plug is inserted into `DIO3`.
  - Primary specialists: `vision-media`, `can-bus`; add `embedded-software` only for running config or gateway mapping disputes.
  - Knowledge: `knowledge/photoelectric-height-limit-dio-label-miswire.md`.

## Handling And Parcel Detection

- `omnisort.m147.concave_parcel_multi_parcel`
  - Product line: OmniSort / 慧仓闪电播.
  - Typical symptom: concave parcel triggers conveyor multi-parcel alarm.
  - Primary evidence: source says concave parcel entered station 2 lift and upper-car light curtain triggered once; video suggests irregular parcel shape.
  - Primary specialists: handling specialist, `vision-media`, `scheduler-traffic`.
  - Knowledge: `knowledge/concave-parcel-multi-parcel.md`.

## Scheduler And Site Dispatch

- `omnisort.m147.multi_site_same_floor_dispatch`
  - Product line: OmniSort / 慧仓闪电播.
  - Typical symptom: same-floor multi-site arrivals make a robot choose the wrong site or move between sites.
  - Primary evidence: parcel arrival timeline, `dispatchingShuttleOnShuttleArrive`, `hasShuttleDispatching`, standby wall/site filtering.
  - Primary specialists: `scheduler-traffic`, handling specialist, `vision-media`.
  - Knowledge: `knowledge/multi-site-same-floor-dispatch.md`.

## Evidence Status

- For IO/harness issues, compare IO table, cable label, and actual plug location before blaming sensor, CAN, or software.
- For M147/M149 cross-project labeling issues, record harness part number, connector label, affected project, and corrected QA photo.
- For scheduler cases, keep site timelines separate before drawing a service-side conclusion.
