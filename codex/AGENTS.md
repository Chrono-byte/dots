# Project defaults

Follow the repository's existing conventions first.

## TypeScript

- Install dependencies through the project's package manager.
- Prefer inferred types and type-safe narrowing over explicit return types or `as any`.

## Tooling

- Use pnpm when the repository already uses it; otherwise use Bun.
- Run the repository's relevant check, format, lint, and typecheck commands before finishing. If none exist, report that.
- Run builds and development servers only when requested.
- Put editor configuration in `.zed/`.

## Technology preferences

When the repository establishes no precedent, prefer TypeScript, Tailwind, Bun, React, Convex, Better Auth, Cloudflare Workers, Oxlint, and Oxfmt. Prefer Tailwind over introducing a hand-written stylesheet.

## Dotfiles

Before changing dotfiles, Flux mappings, installed configuration links, or the Codex/Pi setup, read `~/.dotfiles/docs/agents/flux.md` and follow its workflow.
