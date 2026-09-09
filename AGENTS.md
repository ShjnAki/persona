# Persona contributor guidance for Codex

## Environment

- Persona is an Electron, TypeScript, React, Three.js, and Vite desktop application.
- The intended development setup is WSL2 Ubuntu on a Windows 11 host, with Electron displayed through WSLg. Check `/etc/os-release` rather than assuming the current distribution; the environment may differ from the intended setup.
- Use Node.js 24 or newer and npm. Run `nvm use` from the repository root when nvm is available; `.nvmrc` selects Node 24.
- Electron 39 embeds Node 22, so runtime sources intentionally compile against the Node 22 type declarations even though repository tooling requires Node 24+.
- Linux voice activity capture requires `pw-dump` and `pw-record` on `PATH`.

## Setup and commands

- Install reproducibly with `npm ci` when `package-lock.json` is authoritative. Use `npm install` only when intentionally updating dependencies or the lockfile.
- Development with renderer/runtime watchers and Electron: `npm run dev`.
- Build and launch the current application: `npm run demo`.
- Build the runtime and launch without rebuilding the renderer: `npm start`.
- Production build: `npm run build`.
- Lint: `npm run lint`.
- All tests: `npm test`; focused suites: `npm run test:node` and `npm run test:renderer`.
- Asset validation: `npm run assets:check`.
- Platform-neutral validation bundle: `npm run check` (lint, tests, assets, production audit, and build).
- Native helper commands: `npm run native:build` and `npm run native:test`; both are intentional no-ops on Linux.
- Packaging commands are `npm run dist:linux`, `npm run dist:appimage`, `npm run dist:windows`, and `npm run dist:mac`; run them only when packaging is in scope and on the target OS described in `README.md` and `docs/RELEASING.md`.

## Architecture and editing rules

- Preserve the four-layer architecture documented in `docs/DEVELOPMENT.md`: native listeners, privileged Electron main process, sandboxed preload, and React/Three.js renderer. Do not give the renderer filesystem, process, or raw-audio access.
- Edit TypeScript sources, never generated `.cjs` or `.cjs.map` runtime files. The build emits those ignored files beside their sources.
- Keep `shared/persona-api.d.ts` and the typed preload implementation synchronized when the cross-process API changes.
- Preserve the existing architecture and security boundaries unless a change has a clear, documented justification.
- Keep changes focused. Do not refactor unrelated code, overwrite user changes, or add generated output to Git.

## Verification

- After every modification, run the narrowest relevant lint, test, asset, or build checks; before handing off a broad change, prefer `npm run check` when network-dependent `npm audit` is appropriate.
- At minimum, run `npm run build` for changes that can affect compilation or bundling. Run the focused test suite while iterating and `npm test` for behavior changes.
- Do not run `npm audit fix --force`. Report audit findings and evaluate upgrades deliberately.
- Do not modify `package-lock.json` unless dependency metadata is intentionally changing. Review its diff separately whenever it changes.

## WSLg, graphics, and UI inspection

- Treat `libGL`, OpenGL, EGL, Mesa, DRM, GPU-process crashes, or software-rendering fallback messages as WSLg/Linux environment symptoms until diagnostics show an application defect. Do not modify Persona's renderer to mask a broken WSLg/GPU setup.
- Useful read-only diagnostics include `wsl.exe --status` from Windows, `uname -a`, `cat /etc/os-release`, `printenv DISPLAY WAYLAND_DISPLAY`, `glxinfo -B`, `eglinfo`, and `LIBGL_DEBUG=verbose npm run demo`. Installing `mesa-utils` or other system packages requires an explicit environment diagnosis first.
- The Playwright MCP configuration is useful for the Vite-rendered UI, DOM, console, network, and screenshots. Persona is an Electron application: browser-only reproduction does not validate Electron main/preload, tray, native audio, transparent-window, click-through, or WSLg behavior. Use Playwright's Electron automation APIs in dedicated project tests if direct Electron end-to-end coverage is later added.
- Do not treat headless browser rendering as proof of WSLg/GPU behavior.

## Documentation and external tools

- Use Context7 when current library or API documentation is needed, especially before relying on version-sensitive behavior.
- Use GitHub MCP or `gh` for issues and pull requests only when it adds value. Never place tokens or credentials in tracked files, `.env`, Git configuration, or documentation.
- GitHub MCP expects `GITHUB_PAT_TOKEN` from the launching environment. If it is absent or invalid, stop and ask the user to authenticate; never invent, print, or persist a credential.

## Git hygiene

- Run `git status` before editing and `git diff` before handoff. Preserve pre-existing working-tree changes and identify them separately.
- Do not commit, push, force-push, reset, clean, discard, or rewrite history unless the user explicitly requests it.
- Avoid changes outside the task and do not mix tooling/configuration work with functional Persona changes.
