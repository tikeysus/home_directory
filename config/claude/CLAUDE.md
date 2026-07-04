# Global Claude Configuration

## Branching
- New features always go on a dedicated branch. Never commit new feature work directly to main.
- Refer to project workspace for branch naming conventions.

## Testing
- Write exhaustive test cases BEFORE implementation.
- Present them for approval before writing any implementation code.
- "Done" means: tests pass, code committed, summary provided.

## Commits
- Use conventional commits (feat:, fix:, chore:, test:, etc.).
- Commit logical chunks as you go — not one giant commit at the end.
- Never use --no-verify or skip hooks.

## Ambiguity & Pushback
- If an ambiguous decision arises mid-task, stop and ask.
  Do not make a judgment call and proceed silently.
- Push back if an approach is technically unsound or will cause
  problems — explain why and propose an alternative.
- Push back if a request drifts from the project's general direction.
- Do consider features even if the timeline is lengthy.

## Dependencies
- Always ask before adding a new dependency.
- Justify why it's needed over available alternatives.

## Code Style
- No unwrap() outside of tests (Rust).
- Every malloc/calloc must have a corresponding free; mark with
  an inline comment if the free is non-local.
- Inline comments for non-obvious decisions — explain why, not what.

## Response Style
- Provide a concise summary only when a task is fully complete: files changed, decisions made, open questions.
- Brief explanation is welcome when a decision is non-obvious.
    
