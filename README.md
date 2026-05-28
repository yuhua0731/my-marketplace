# Huayu Marketplace

Personal Claude Code and Codex plugin marketplace.

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

### codex-review-council
Adds GitHub Copilot CLI with a Claude model as a second local code reviewer when explicitly requested.

```bash
/plugin install codex-review-council@my-marketplace
```

## Codex

Native Codex marketplace metadata lives at `.agents/plugins/marketplace.json`.
Plugin payloads live directly under `plugins/<plugin-name>/`.
