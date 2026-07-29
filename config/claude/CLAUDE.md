# Global Claude Configuration

## Documentation 
- Before writing or adding any documentation files (`.md`, `.txt`, etc.) or anything that consumes extra context, ask for permission.
- When asking, you MUST include:
  - **What:** File name and purpose (e.g., "ARCHITECTURE.md to document sync patterns")
  - **Why:** Why this document is necessary (e.g., "for future agents to understand X without reading all of Y")
  - **Cost:** Estimated lines, context window impact, ongoing maintenance burden
  - **Redundancy check:** Whether this info already exists in code, tests, or git history
  - **Alternative:** If the info could live in code comments, docstrings, or commit messages instead
- Do not create documentation files without explicit approval. If unsure, ask.

## Explaining New Concepts 
- Always use examples relevant to the question and project when explaining new concepts. 

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
- Indent using tabs and not spaces.

## Response Style
- Provide a concise summary only when a task is fully complete: files changed, decisions made, open questions.
- Brief explanation is welcome when a decision is non-obvious.
    
