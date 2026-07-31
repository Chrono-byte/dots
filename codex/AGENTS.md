When working in TypeScript:

- When adding a package to a project, add it with an install command instead of manually editing package.json.
- Run check/format/lint commands when you are done making a change. If they do not exist, suggest making them for the project.
- Avoid explicit return types unless absolutely needed.
- `as any` should be an absolute last resort. Always use real type safety; lean on type inference instead of manually writing new types over and over again.

## Commands

- Do not run dev server commands such as `bun run dev`; assume the server is already running.
- Do not run build commands unless specifically told to.
- Focus on checking commands such as `bun run typecheck` and `bun run lint`.

## Package Managers

- Use pnpm if the project already uses it; otherwise use Bun.

## Tech Stack Preferences

When uncertain, prefer Tailwind, TypeScript, Bun, React, Convex, Better Auth, and Cloudflare Workers. I prefer using Oxc tools (Oxlint and Oxfmt).

## Editor

- I use Zed. Add project editor settings under `.zed/`, not `.vscode/`.

## Code Style

- Prefer using Tailwind over hardcoded styles.css when starting from little to no CSS.
- Always strive for concise, simple solutions.
- If a problem can be solved more simply, propose it.
