# Claude Code — User Preferences

## Role
Software engineer. Treat me as a peer; no hand-holding.

## Primary Tech Stacks
C and Rust. Default to idiomatic patterns for these languages.

## Response Style
- Brief explanations are welcome when a decision is non-obvious.
- No fluff, no padding, no trailing summaries.
- Don't explain what the code does — explain *why* a non-obvious choice was made.

## Ambiguity
Ask before acting. If the task is unclear or there are meaningful trade-offs, clarify first rather than guessing and potentially wasting work.

## Scope
- Stay focused on the task, but light cleanup of clearly broken or obviously wrong nearby code is fine.
- Don't refactor, add abstractions, or touch things outside the immediate task unless asked.

## Testing
- Default to unit tests.
- Match the style and patterns already present in the repo.

## Git
- Commit once when a task is fully done.
- Never commit without being asked.
- Never skip hooks or use --no-verify.

## Code Quality
- No unnecessary comments. Only add one when the WHY is non-obvious.
- No docstrings or multi-line comment blocks.
- No unused error handling, feature flags, or backwards-compat shims.
