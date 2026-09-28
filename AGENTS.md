# AGENTS.md

Guidance for AI coding agents (and humans) working on this repository.

## What this is

A terminal-only, non-evil Doom Emacs configuration for Lisp-centric
development on a Mac mini M2. The user (Nikolai Schlegel) works in
iTerm2 + tmux, never in GUI Emacs, and uses vanilla Emacs keybindings
(`C-c` leader, `C-c l` localleader) — not Evil mode.

## Environment (verified facts)

- Machine: Mac mini M2, user `nikolai`.
- Emacs: Homebrew `emacs` 31.1 at `/opt/homebrew/bin/emacs`
  (Cellar `emacs/31.1_1`). Emacs 31 turns `xterm-mouse-mode` on by
  default in compatible terminals; `(tty +osc)` therefore does not
  need to add it (Doom's tty module only adds it below Emacs 31).
- Doom Emacs: checkout at `~/.config/emacs`. **Non-standard layout**:
  Doom modules live at `~/.config/emacs/sources/doom+/modules/`
  (not `modules/`); packages are at `~/.config/emacs/.local/straight/repos/`.
  There is no `init.el` in that directory — `early-init.el` is the entry.
- Terminal: iTerm2, often with tmux 3.7c (`mouse on`,
  `default-terminal tmux-256color`, `allow-passthrough on`, built for
  iTerm2 `-CC` integration mode — see `~/.tmux.conf`).
- Lisps: SBCL 2.6.8 (Homebrew, started as an inferior process with
  `--dynamic-space-size 4096`) and LispWorks (a long-running external
  image with a Slynk server on localhost:4005 — attach with
  `sly-connect`, never quit it from Emacs).
- Remote Login (sshd) is ON on this machine (verified 2026-09-27:
  `com.openssh.sshd` loaded via launchd, port 22 answers with
  `SSH-2.0-OpenSSH_10.3`).

## Authoritative version and three-way sync

1. **Authoritative**: `~/.config/doom` on the Mac mini M2 (git repo,
   branch `main`).
2. **GitHub mirror**: <https://github.com/huegli/doom-emacs> (public,
   default branch `main`).
3. Agent working mirror (sandbox, not tracked anywhere).

Any change must end up in all three. The device shell is sandboxed
(no network, no PTY allocation, no `.git` writes), so the flow is:
edit in the mirror → verify → transfer to the device → commit and
push from a sandbox clone of the GitHub repo → the **user** runs
`git pull` on the device (the agent cannot). Commit identity:
`Nikolai Schlegel <nikolai.schlegel@gmail.com>`.

## File map

- `init.el` — Doom module selection. Notable: `(tty +osc)`,
  `(corfu +orderless +icons)`, `(vertico +icons)`, `(treemacs +lsp)`,
  no `:editor evil`, Geiser for Chez + Racket only (no Guile).
- `config.el` — main configuration. Contains the SLY setup, the
  `C-c r` REPL launcher map, theme (`my-doom-dracula`), and loads
  `unify-lisp-keys.el` at the bottom.
- `unify-lisp-keys.el` — the unified `C-c l <key>` localleader grammar
  across sly, geiser, cider, racket, hy, and emacs-lisp maps
  (`'` REPL · `R` restart · `!` interrupt · `e` eval sexp · `d` eval
  defun · `r` region · `b` buffer · `f` load file · `P` pprint ·
  `k` docs · `i` inspect · `m`/`M` macroexpand · `t`/`T` test/trace ·
  `c` compile defun · `p` profile).
- `packages.el` — pinned extra packages (sly, sly-macrostep,
  sly-repl-ansi-color, geiser-chez, rainbow-delimiters, ...).
- `themes/my-doom-dracula-theme.el` — hand-built Dracula variant.
- `themes/dracula-theme.el` — **symlink into Homebrew**; machine
  specific, do not replace with a regular file.
- `cheatsheet/` — Python sources that build the two PDF cheat
  sheets. PDFs are gitignored build artifacts. Constraints: Letter
  landscape, 2 pages per sheet; DM Sans has no Greek or arrow
  glyphs — spell "lambda", use "<->".

## Key decisions and why

- **Non-evil**: `map!` forms scoped to evil states (`:n :i :v` ...) are
  silently ignored. `doom-leader-key`/`doom-localleader-key` are ignored
  without evil; the `-alt-key` variants are what apply. Docs keys:
  `C-c c k`; jump-to-def `M-.` (evil-only `K`/`gd`/`gD` do not exist).
- **SLY REPL never auto-starts**: Doom's `+common-lisp-init-sly-h`
  was removed from `sly-mode-hook` (it let-binds `sly-auto-start` to
  `'always`, so setting that variable alone does nothing). Removing it
  also removed `+common-lisp--cleanup-sly-maybe-h`, which would have
  killed the external LispWorks image when the last SLY buffer closed.
- **`my/sly-repl-dwim`** (on `C-c C-z` and `C-c l '`): when connected,
  switches to the existing REPL via `(call-interactively #'sly-mrepl)`
  — a plain `(sly-mrepl)` call silently returns the buffer without
  displaying it, because the display logic lives in the `interactive`
  spec. When not connected, asks: `s` = inferior SBCL, `l` = attach
  to LispWorks on :4005. `C-u` forces the question even when
  connected.
- **`C-c C-z` is taken via `[remap sly-mrepl]`**, not `define-key`:
  `sly-mrepl.el` binds `C-c C-z` inside its `define-sly-contrib`
  `(:on-load ...)` block, which runs when Doom calls `sly-setup` from
  `after-init-hook` — after user config. Any direct binding is
  overwritten; a remap is immune to load order.
- **Completion is corfu, not company**: Doom's `:completion company`
  module is deprecated in favor of corfu; sly, geiser, cider, and
  racket all provide CAPFs natively, which corfu consumes directly.
- **Terminal mouse** (verified 2026-09-25 by feeding real SGR mouse
  sequences to Emacs on a PTY): works directly, inside tmux with this
  user's `~/.tmux.conf`, and over SSH. Emacs 31 enables it by default.

## Rules for making changes

1. Verify assumptions against the installed sources on the device —
   especially Doom module code — instead of relying on memory.
2. Syntax-check any edited elisp before committing:
   `emacs -Q --batch -l <file>` or a read-all-forms check.
   Note: byte-compiling `config.el` outside Doom fails on
   `use-package!`-style macros — that failure is a harness artifact.
3. Multi-edit batches are atomic: one failing edit silently rolls
   back the whole batch. Re-verify after any partial failure.
4. After pushing to the device, tell the user to run
   `cd ~/.config/doom && git pull` (the agent's device shell cannot).
5. Never suggest `sly-quit-lisp` workflows for the LispWorks
   connection; the image is started and owned outside Emacs.
6. `IS-MAC` is obsolete — use `(featurep :system 'macos)`.

## History (what has been built here so far)

1. Terminal-only, non-evil Doom config for SBCL + LispWorks, Geiser
   (chez + racket, no guile), CIDER, racket-mode.
2. `unify-lisp-keys.el`: one localleader grammar across all Lisps.
3. `C-c r` leader map for REPL/connection launchers.
4. Two PDF cheat sheets generated from `cheatsheet/` sources
   (keybindings by key and by task), regenerated after the
   non-evil conversion.
5. Repository put under git, pushed to GitHub, README fixed,
   cheat sheet sources added.
6. SLY REPL on demand (see decisions above), including the
   auto-start removal, the SBCL/LispWorks prompt, and two
   binding bugs found and fixed via on-device verification.
7. Completion reviewed: stayed with corfu (rationale above).
8. Mouse support verified over direct PTY, tmux, and SSH.
9. User commits on top: restored `rainbow-delimiters` package,
   `(tty +osc)` cleanup, activated `my-doom-dracula` theme,
   added `(treemacs +lsp)`.
