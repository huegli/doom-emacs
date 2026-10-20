# AGENTS.md

Guidance for AI coding agents (and humans) working on this repository.

## What this is

A terminal-only, non-evil Doom Emacs configuration for Lisp-centric
development on a Mac mini M2. The user (Nikolai Schlegel) works in
iTerm2 + tmux, never in GUI Emacs, and uses vanilla Emacs keybindings
(`C-c` leader, `C-c l` localleader) — not Evil mode.

The same repository is also checked out on a second machine running
Omarchy Linux (see "Second machine" below). `config.el` loads the
Omarchy integration only when that machine's system file exists, so
the Mac setup is unaffected.

## Environment (verified facts)

- Machine: Mac mini M2, user `nikolai`.
- Emacs: Homebrew `emacs` 31.1 at `/opt/homebrew/bin/emacs`
  (Cellar `emacs/31.1_1`). Emacs 31 turns `xterm-mouse-mode` on by
  default in compatible terminals — but only outside tmux. The
  detection queries the terminal for XTVERSION and checks the reply
  against a small allowlist (iTerm2, kitty, foot, alacritty, contour);
  tmux answers that query itself (`"tmux 3.7c"`, confirmed via
  `strings $(which tmux)`) instead of forwarding it to iTerm2, so the
  match always fails inside tmux. `config.el` therefore adds its own
  unconditional `xterm-mouse-mode` enable to `tty-setup-hook` to cover
  that gap (Doom's `(tty +osc)` module only adds it below Emacs 31).
- Doom Emacs: checkout at `~/.config/emacs`. **Non-standard layout**:
  Doom modules live at `~/.config/emacs/sources/doom+/modules/`
  (not `modules/`); packages are at `~/.config/emacs/.local/straight/repos/`.
  There is no `init.el` in that directory — `early-init.el` is the entry.
- Terminal: iTerm2, often with tmux 3.7c (`mouse on`,
  `default-terminal tmux-256color`, `allow-passthrough on`, built for
  iTerm2 `-CC` integration mode — see `~/.tmux.conf`).
- Lisps: SBCL 2.6.8 (Homebrew, started as an inferior process with
  `--dynamic-space-size 4096`) and LispWorks, in two forms: (1) a
  long-running external image with a Slynk server on localhost:4005 —
  attach with `sly-connect`, never quit it from Emacs; and (2)
  `~/.local/bin/sly-lw-console`, a saved LispWorks 8.1 image (Mach-O
  executable, not on this repo's tracked files) that SLY launches as
  its own inferior process, the same way it launches SBCL.
- Remote Login (sshd) is ON on this machine (verified 2026-09-27:
  `com.openssh.sshd` loaded via launchd, port 22 answers with
  `SSH-2.0-OpenSSH_10.3`).

### Second machine: Omarchy Linux (verified 2026-10-09)

- aarch64 Arch Linux running Omarchy 4.0.3rc4-2, user `nikolai`.
- Emacs: `emacs-wayland` 31.1 (pgtk build) at `/usr/bin/emacs`.
- Doom: same non-standard layout as on the Mac (`~/.config/emacs`,
  modules under `sources/doom+/modules/`).
- AUR package `omarchy-emacs` 1.10.1 installs the integration under
  `/usr/share/omarchy-emacs/config/` (`omarchy.el`, `init.el`,
  `shell-bashrc`, `themes/omarchy-theme.el`). The active theme's
  generated colors are in `~/.local/state/omarchy/current/theme/`
  (`omarchy-colors.el`, `colors.toml`).
- SBCL is **not** installed here and there is no LispWorks; the
  Homebrew `themes/dracula-theme.el` symlink dangles.

## Authoritative version and two-way sync

1. **Authoritative**: `~/.config/doom` on the Mac mini M2 (git repo,
   branch `main`) — this is also the agent's working directory; there
   is no separate sandboxed mirror. The Omarchy Linux machine has its
   own `~/.config/doom` checkout of the same repo; commit and push from
   whichever machine you are on, and `git pull` on the other before
   editing there.
2. **GitHub mirror**: <https://github.com/huegli/doom-emacs> (public,
   default branch `main`).

Any change must end up in both. The agent shell has full `git` and
network access when working in `~/.config/doom` (verified 2026-09-27:
`git add`, `git commit`, and `git push origin main` all succeeded
directly), so the flow is simply: edit → verify → commit → push.
No transfer-to-device step and no user-run `git pull` are needed for
this checkout. Commit identity:
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
- `themes/omarchy-theme.el` — copy of the `omarchy-emacs` package's
  theme (Omarchy machine only; it `require`s `omarchy-colors`, which
  exists only there). Does not track package upgrades — re-copy from
  `/usr/share/omarchy-emacs/config/themes/` after updating the package.
- `shell-bashrc` — rcfile for `M-x shell` on the Omarchy machine
  (copied from the package): sources Omarchy's bash defaults without
  readline bindings or starship escape sequences.
- `omarchy/emacs.desktop` — app-launcher override for the Omarchy
  machine (Mac ignores it). The system entry runs plain `emacs %F`,
  which opens a Wayland GUI window; this one runs
  `omarchy-launch-tui emacs -nw %F` (opens in Omarchy's styled
  terminal) and sets `StartupWMClass=org.omarchy.emacs` to match the
  app-id that helper assigns. Install by copying to
  `~/.local/share/applications/emacs.desktop`; not symlinked or
  auto-installed. Re-diff against `/usr/share/applications/emacs.desktop`
  after Emacs package upgrades. Shell use is covered by the user's
  `emacs -nw` alias.
- `omarchy/emacsclient.desktop` — launcher override for the Emacs
  daemon client on the Omarchy machine. A daemon has no frame type of
  its own; each client picks it. The system entry uses
  `emacsclient --create-frame` (GUI); this one runs
  `omarchy-launch-tui --app-id=org.omarchy.emacsclient emacsclient -t
  --alternate-editor= %F` (`-t` = terminal frame, empty `--alternate-editor=` = start a daemon if none
  runs). Its "New Instance" action runs `emacs -nw`.
  `StartupWMClass=org.omarchy.emacsclient` matches the `--app-id`.
  The `emacs.service` user unit (`/usr/bin/emacs --fg-daemon`) needs no
  change. Install to `~/.local/share/applications/emacsclient.desktop`.
  Use `--alternate-editor=` rather than `-a ""`: `xdg-terminal-exec`
  drops the empty argument, `emacsclient` errors out and the window
  closes at once. Tested 2026-10-15 with the running `emacs.service`
  daemon: opens a terminal frame (`display-graphic-p` nil). Note that
  `omarchy.el` also calls `server-start`, so any plain Emacs session is
  a server too.
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
  spec. When not connected, asks: `s` = inferior SBCL, `l` = inferior
  LispWorks console (`sly-lw-console`, via `sly-lisp-implementations`),
  `c` = attach to an already-running LispWorks image's Slynk on :4005
  (`my/sly-connect-lispworks`). `C-u` forces the question even when
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
  user's `~/.tmux.conf`, and over SSH. Emacs 31 enables it by default
  outside tmux; inside tmux it does not (see Environment section), so
  `config.el` forces it on unconditionally via `tty-setup-hook`.
- **Mouse-wheel scrolling** (`<wheel-up>`/`<wheel-down>` "is undefined",
  fixed 2026-09-28): `xterm-mouse-mode` only decodes SGR mouse sequences
  into Emacs events (clicks/selection); the *binding* of those wheel
  events to scrolling lives in `mwheel.el`, which is normally loaded by
  GUI startup code (`term/ns-win.el`, `term/x-win.el`) that never runs
  on a terminal-only frame. Verified with `emacs -Q --batch`:
  `(featurep 'mwheel)` is nil at startup and `[wheel-up]` is unbound in
  `global-map` until `mouse-wheel-mode` is invoked explicitly.
  `config.el`'s `tty-setup-hook` now forces `(mouse-wheel-mode 1)`
  alongside `xterm-mouse-mode`.
- **Treemacs auto-sidebar by width**: `(treemacs +lsp)` opens automatically
  when the selected frame is at least `my/treemacs-min-width` (100) columns,
  but only inside a real project (`doom-project-root` non-nil and not `~`).
  The handler on `window-size-change-functions` is debounced with a
  `run-with-timer` and is idempotent: it only acts when the frame's wide/narrow
  state or the sidebar's visibility changes. A manual open/close in any frame
  sets the global `my/treemacs--user-override` and disables automation
  everywhere until `M-x my/treemacs-auto-resume`. At startup from the
  dashboard, the sidebar stays pending until `doom-first-file-hook` fires.

- **Omarchy integration in Doom** (fixed 2026-10-09): `config.el`
  loads `/usr/share/omarchy-emacs/config/omarchy.el` only if it
  exists. That file assumes a vanilla `~/.config/emacs` and breaks
  under Doom in three ways, each handled in `config.el`:
  (1) it finds `omarchy-theme` with a plain `locate-file` over
  `custom-theme-load-path`, which skips symbol entries; Doom lists
  `~/.config/doom/themes/` only as the symbol `custom-theme-directory`,
  so the lookup returned nil and startup died with
  `load-file(nil)` / `wrong-type-argument stringp nil`; fixed by
  adding the themes dir as a string first. (2) Theme: since
  2026-10-14 `my-doom-dracula` is used on every machine;
  `omarchy-apply-theme` is overridden with `ignore` (advice added
  before loading, survives the package's `defun`) so neither startup
  nor Omarchy theme changes replace it. Font sync still runs.
  (3) It points bash's
  `--rcfile` at `user-emacs-directory`, which Doom redirects to its
  cache dir; `explicit-bash-args` is reset to use `doom-user-dir`.
  The package's `init.el` and the `omarchy.el` shim are not used —
  Doom never reads them.

## Rules for making changes

1. Verify assumptions against the installed sources on the device —
   especially Doom module code — instead of relying on memory.
2. Syntax-check any edited elisp before committing:
   `emacs -Q --batch -l <file>` or a read-all-forms check.
   Note: byte-compiling `config.el` outside Doom fails on
   `use-package!`-style macros — that failure is a harness artifact.
3. Multi-edit batches are atomic: one failing edit silently rolls
   back the whole batch. Re-verify after any partial failure.
4. Commit and push directly from `~/.config/doom` (see sync section
   above) — no separate transfer or user-run `git pull` needed for
   this checkout.
5. Never suggest `sly-quit-lisp` workflows for the LispWorks
   connection; the image is started and owned outside Emacs.
6. `IS-MAC` is obsolete — use `(featurep :system 'macos)`.
7. Keep machine-specific code guarded (by `featurep :system` or a
   `file-exists-p` on the system file it needs) so one `config.el`
   starts cleanly on both the Mac and the Omarchy machine.

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
10. Added a third SLY launch path (2026-09-28): `sly-lw-console`, a
    saved LispWorks image at `~/.local/bin/sly-lw-console`, registered
    in `sly-lisp-implementations` and launched by SLY as an inferior
    process (`l` in the `my/sly-repl-dwim` prompt), alongside the
    existing inferior-SBCL (`s`) and Slynk-attach (`c`, now moved off
    `l`) paths.
11. Omarchy Linux support (2026-10-09): second checkout on an aarch64
    Omarchy 4 machine; `config.el` loads the `omarchy-emacs` package's
    integration with Doom-specific fixes (see decisions above);
    added `themes/omarchy-theme.el` and `shell-bashrc`.
12. Terminal-only launcher on Omarchy (2026-10-14): added
    `omarchy/emacs.desktop`; `my-doom-dracula` now used on all hosts
    with the package's `omarchy-apply-theme` disabled.
13. Terminal-only daemon client launcher (2026-10-15): added
    `omarchy/emacsclient.desktop`.
14. Implemented width-aware treemacs sidebar (2026-10-20): auto-opens at
    >= 100 columns inside real projects, follows live resizes via
    `window-size-change-functions` with a 0.2s debounce, and stops on any
    manual open/close in any frame until `my/treemacs-auto-resume`.
