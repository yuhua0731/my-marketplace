# My Marketplace

Personal Claude Code plugin marketplace.

## Claude Code

```bash
/plugin marketplace add yuhua0731/my-marketplace
```

## Plugins

### embedded-design-docs
HLD, LLD, and unified design documents for embedded software.

```bash
/plugin install embedded-design-docs@my-marketplace
```

### coworkers
Virtual coworker personas for design review and technical decisions.

```bash
/plugin install coworkers@my-marketplace
```

## Codex

Native Codex marketplace metadata lives at `.agents/plugins/marketplace.json`.
The local marketplace expects these sibling checkout links:

```bash
plugins/embedded-design-docs -> ../../embedded-design-docs
plugins/coworkers -> ../../coworkers
```
