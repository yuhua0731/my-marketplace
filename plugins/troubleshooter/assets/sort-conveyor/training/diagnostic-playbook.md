# Sort Conveyor Diagnostic Playbook

Built from accepted high-priority visible-text cases.

## scheduler-traffic / embedded-software / robot-load-handshake

Cases: 1

Signals:

- `sort-conveyor-20260617-load-wait-robot-confirm` symptom: 2026-06-17 17:09 左右，供包机 LOAD 段运行卡住。现场看到状态像卡在 RESET，实际供包机 app 最终停在 `LOADING_WAITING_FOR_SHUTTLE`，等待机器人装货完成确认。
  analysis: ### 供包机 app 日志中的 RESET 是误导

Training focus:

- Preserve symptom, evidence, inference, and unresolved branches separately.
