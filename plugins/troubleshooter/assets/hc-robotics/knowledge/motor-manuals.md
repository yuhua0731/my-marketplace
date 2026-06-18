# HC Robotics Motor Manual Archive

scope: company-wide motor and drive manuals for all HC Robotics product lines
source: https://hcrobots.feishu.cn/wiki/wikcnLfdEU41gdhbyzfl8q2TEYc?from=from_copylink
wiki_node: `wikcnLfdEU41gdhbyzfl8q2TEYc`
doc_title: `电机`
status: global reference index

## Use For

- motor alarms, blink counts, fault codes, and vendor-specific error meanings
- CANopen emergency codes and object dictionary references
- motor node ID, baud rate, wiring, connector, and parameter lookup
- replacement motor model/config verification
- distinguishing drive/motor faults from scheduler, RF, MQTT, or robot state-machine faults

## First-Level Archive Nodes

| Manual group | Wiki node | Object type |
|---|---|---|
| 德马克电机 | `wikcnHxKabrrE9AhCQjIl3Vvnlg` | docx |
| 台达电机 | `wikcn1mcC6cd4KKqb3NlSRub56D` | docx |
| 雷赛电机 | `wikcnxhnWjOOYpUIihv2dUCNCge` | docx |
| BLD-300B.pdf | `wikcnCXyC6oMVfxPjghR5KCBsfe` | file |
| 心流电机 | `wikcnWmfx1TRmpKwa2Z8OMc8ihg` | docx |
| 伟创电机 | `HZtawxZ4hi6HA6kTs5qc2ea1nfc` | docx |
| 德晟电机 | `W4PhwzqCdiIe8KkJZOocW5bqn5e` | docx |

## Lookup Rule

1. Identify the motor or drive vendor/model from labels, BOM, config, or field text.
2. Open the matching manual group from this archive.
3. Convert decimal error codes to hex before lookup when logs print decimal `error_code`.
4. Preserve the source manual and page/section in the case record.
5. Do not treat a manual definition as root cause by itself; combine it with logs, measurements, photos, and recovery evidence.

## Known Extracted Mappings

- 雷赛 LD2 CANopen: decimal `33056` = hex `0x8120` = `错误被动模式` / CAN error passive mode, alarm code `902`.

