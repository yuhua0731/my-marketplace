---
name: embedded-design-docs
description: Write HLD, LLD, and unified design documents for embedded software. Use when the user asks for design docs, architecture docs, high/low-level design, module design, embedded software design, or similar.
---

# Embedded Design Docs

## When to Use

Trigger when the user asks to write, create, or draft any of:
- 嵌入式软件设计 / embedded software design — single-MCU unified design doc
- HLD / 高层设计 / 概要设计 / 系统设计 / architecture design
- LLD / 详细设计 / 模块设计 / module design / component design
- 设计文档 (design doc) without specifying level — ask whether unified, HLD, or LLD

## Decision: Unified vs HLD/LLD

For single-MCU products where all logic runs on one chip, use a **unified design doc** (嵌入式软件设计) instead of splitting into separate HLD and LLD.

**Ask first if unclear.** Key discriminator:

| Scenario | Document Type | Template |
|----------|--------------|----------|
| Single MCU, all firmware on one chip | **Unified** (嵌入式软件设计) | `unified-template.md` |
| Multi-MCU, multi-module system | Separate HLD + LLD | `hld-template.md` + `lld-template.md` |
| User explicitly says "HLD" or "LLD" | Respect user's choice | Existing HLD/LLD templates |

A BLE module or fixed-function co-processor (AT-command modem, sensor hub) does NOT count as a second MCU — if there's only one programmable MCU running application logic, use unified.

## Decision: HLD vs LLD

| HLD | LLD |
|-----|-----|
| Cross-module, system-level | Within a single module |
| Architecture, module responsibilities | Internal structure, tasks, state machines |
| Interfaces *between* modules | Interfaces *inside* a module (functions, structs) |
| Data flow across modules | Algorithms, data structures |
| Error handling *strategy* | Error codes, trigger conditions, recovery steps |
| Read by PM, system architect, module owner | Read by module owner, developers |

**Ask the user if unclear.** Default: if they mention "系统" (system), "方案" (proposal), "架构" (architecture) → HLD. If they mention "模块" (module), "组件" (component), "内部" (internal) → LLD.

## Decision: Starter vs Professional

Ask: "Starter (入门版) or Professional (专业版)?"

| Edition | Scope | When to use |
|---------|-------|-------------|
| **Starter** | Essentials: 5-6 chapters, no compatibility section | Startups, early prototypes, quick-turnaround projects |
| **Professional** | Full detail: adds compatibility analysis, resource budgets, risk assessment, timing diagrams, test guidance | Regulated industries, large teams, long-lifecycle products |

Templates by edition:
- Starter: `unified-template.md` / `hld-template.md` / `lld-template.md`
- Professional: `unified-professional-template.md` / `hld-professional-template.md` / `lld-professional-template.md`

If the user doesn't know, show a one-line summary and let them choose.

## Process

### Phase 1: Gather Requirements

Ask these questions before writing:

1. **Product type** — Single-MCU product or multi-MCU/multi-module system? (Determines unified vs. HLD+LLD — ask if not already clear.)
2. **Scope** — What system/module? What's the boundary?
3. **Audience** — Who reads this? (PM, other teams, developers within the team?)
4. **Constraints** — RTOS/SoC? Memory/flash budget? Real-time deadlines?
5. **Domain** — Wired/wireless? Motor control? Sensor? Power? Security? (triggers domain-specific follow-ups)
6. **Inputs** — Product requirements doc? Reference code? Existing system diagram?
7. **Reference files** — Existing HLD, LLD, reference designs, or datasheets? Provide file paths or URLs.
8. **Output format** — Markdown only, or PDF export via puppeteer?

If **Professional**: also ask about safety level (ISO 26262 ASIL / IEC 61508 SIL / none) and required diagnostic coverage.

### Phase 2: Fill the Template

Choose the template based on edition and document type:
- Starter: `unified-template.md` / `hld-template.md` / `lld-template.md`
- Professional: `unified-professional-template.md` / `hld-professional-template.md` / `lld-professional-template.md`

Go chapter by chapter. For each chapter:

1. Propose content based on what the user has told you
2. Ask the user to confirm or add missing detail
3. **Run the chapter checklist** before moving on
4. If user provided reference files, cross-reference them in the text where applicable (e.g., "按照参考 HLD 中的定义…")

### Phase 3: Final Review

After all chapters are written:

1. Run the mandatory review checklist below. Flag every missing item to the user.
2. Prompt: "文档初稿完成。是否需要评审检查？" (Offer review step — reviewer may be someone other than the author.)
3. If Professional edition, verify the traceability matrix (requirements → test cases) is complete.

## Mandatory Review Checklist

Before the doc is considered complete, verify all 4 pain points are covered. For unified documents, external interfaces (to sensors/peripherals) get HLD-level treatment and internal interfaces (between tasks) get LLD-level treatment within the same document.

### 1. 接口定义 (Interface Definitions)
- [ ] Every inter-module communication path has: method (UART/I2C/SPI/CAN/shared-memory/MQTT/etc.), direction, and message format
- [ ] Every function/API has: signature, parameters, return values, preconditions, side effects
- [ ] Data structures are defined with field types and constraints

### 2. 异常处理流程 (Error Handling Flows)
- [ ] Every external input has error handling defined (invalid data, timeout, out-of-range)
- [ ] Every communication path has failure mode handling (disconnect, crc mismatch, retry strategy)
- [ ] Critical error paths are shown in sequence diagrams or flowcharts
- [ ] Watchdog strategy, fault recovery, and degraded-mode behavior are described

### 3. 向前向后兼容性 (Forward/Backward Compatibility) — Professional only
- [ ] Communication protocols have version fields
- [ ] Data structures account for future extension (reserved fields, length-prefixed)
- [ ] Firmware upgrade compatibility strategy is documented

### 4. 主要功能定义 (Main Function Definitions)
- [ ] Each module/component has a clear responsibility statement
- [ ] Core algorithms are described (pseudocode or flowchart, not just prose)
- [ ] State machines are complete: every state has defined transitions for all relevant events
- [ ] Timing constraints are explicit (deadlines, periods, max latencies)

## Domain-Specific Prompts

When the user mentions certain domains, ask targeted questions before filling the template:

| Domain | Additional Questions |
|--------|---------------------|
| **BLE/蓝牙** | Pairing/bonding flow? GATT service definitions? Advertising parameters? Connection intervals? Security (Just Works / Passkey / OOB)? |
| **Motor control** | Motor type (BLDC/PMSM/stepper)? Control algorithm (FOC/six-step)? Stall detection? Overcurrent protection? Encoder type? Phase loss detection? |
| **Battery-powered** | Power budget? Sleep/wake strategy? Battery chemistry? Fuel gauge? Low-battery behavior? |
| **Safety-critical** | ASIL/SIL level? Safety goals? FTTI? Redundancy strategy? Self-test coverage? Diagnostic coverage target? |
| **OTA/固件升级** | Dual-bank? Rollback strategy? Signature verification? Downtime budget? |
| **Sensor** | Sampling rate? Filtering algorithm? Calibration procedure? Drift compensation? |
| **CAN bus** | Baud rate? Frame format (11/29-bit)? Signal mapping (.dbc)? Bus-off recovery? |

## Handling Reference Documents

If the user provides HLD/LLD reference files, datasheets, or design documents (as file paths, URLs, or pasted text):

1. **Record in Section 1.4 (参考文档)**: Add every reference to the table with: document name, type (HLD/LLD/Datasheet/Reference Design/Standard), source (user-provided link, file path, or attachment), and description (what it covers, why relevant).
2. **Read and incorporate**: Read `.md` files directly. For PDFs, extract text; if extraction fails, ask for key sections. For URLs, use WebFetch.
3. **Cross-reference in body**: When writing a chapter that draws from a reference document, note the source in the text (e.g., "按照参考 HLD 中的定义…").
4. **Style matching**: If the user provides a reference doc and wants the output to follow its structure/depth, adjust the template flexibly — templates are starting points, not straitjackets.

## Anti-Patterns to Catch

During review, actively flag these:

- **Ambiguous interfaces**: "data is sent via UART" — missing baud rate, frame format, protocol
- **Happy-path-only flowcharts**: sequence diagrams that don't show error branches
- **TODO-driven error handling**: "error handling will be added later" sections
- **Undefined states**: state machine diagram has states with missing transitions
- **Implicit assumptions**: "the timer will fire" — missing what happens if it doesn't
- **Copy-paste decay**: sections copied from another doc that reference wrong module names

## PDF Handling

For PDF reference files:
- Extract text. If text extraction fails, ask the user for key sections or a markdown export.
