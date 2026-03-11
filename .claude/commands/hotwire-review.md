---
name: hotwire-review
description: Review branch changes for Hotwire (Turbo + Stimulus) and Rails best practices. Use when reviewing PRs, auditing frontend code, or checking uncommitted changes for Stimulus controllers, Turbo Frames/Streams, and Rails view patterns. Triggers on requests like "review for hotwire issues", "check stimulus code", or "audit turbo implementation".
argument-hint: "[scope: uncommitted (default), branch, PR #123, file path, or project]"
---

Review code for Hotwire/Rails anti-patterns.

## Scope

Determine scope from "$ARGUMENTS":
- No argument or "uncommitted" → `git diff` (unstaged) + `git diff --cached` (staged)
- "branch" → `git diff main...HEAD`
- "PR #123" or PR URL → use `gh pr diff 123`
- File path → review that specific file
- "project" → review all Stimulus controllers and Turbo-related files

## Documentation Lookup

Use Context7 MCP to fetch current Hotwire documentation (`hotwired/stimulus`, `hotwired/turbo`, `hotwired/turbo-rails`) when verifying anti-patterns.

## Stimulus Controllers
- `targetConnected`/`targetDisconnected` for aggregate UI (counts, visibility) instead of element-specific setup
- Event listeners not added in `connect()` or not removed in `disconnect()`
- Arrow functions vs bound methods used incorrectly for event handlers
- DOM queries instead of Stimulus targets/values/classes
- Global state instead of Stimulus values for reactive state
- Action naming conventions and param syntax violations

## Turbo Frames & Streams
- Frames scoped too large or too small
- Wrong event choice (`turbo:frame-load` vs `turbo:before-fetch-response`)
- Manual DOM manipulation that should use Turbo Streams
- Incorrect `data-turbo-*` configuration on forms/links

## Rails Views (ERB)
- Partials not used appropriately for Turbo Stream responses
- Turbo Frame `id` mismatches between views and controllers
- Incorrect `turbo_frame_tag`/`turbo_stream` helper usage
- Embedded `<script>` tags instead of Stimulus controllers

## Controllers (Ruby)
- Missing `turbo_stream` format responses
- Incorrect redirect vs render for Turbo requests
- Wrong `request.variant` or format detection

## General
- jQuery/vanilla JS DOM manipulation conflicting with Turbo morphing
- Race conditions between Turbo navigation and JS initialization
- CSS transitions incompatible with Turbo page replacement

## Output Format
For each issue: **file:line** → anti-pattern → documentation reference → fix
