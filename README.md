# Doom Emacs — Terminal Lisp Configuration

Terminal-first Doom Emacs setup tuned for **Common Lisp, Scheme, Clojure, Racket, and Hy** on macOS (Apple Silicon).

**Vanilla Emacs keybindings — `:editor evil` is not enabled.**

## Key layout

With evil disabled, Doom relocates its prefixes ([Doom docs](https://docs.doomemacs.org/latest/)):

| | Evil default | **This config (non-evil)** |
|---|---|---|
| Leader | `SPC` | **`C-c`** |
| Localleader | `SPC m` | **`C-c l`** |
| Docs at point | `K` | **`C-c c k`** |
| Jump to definition | `gd` | **`C-c c d`** (or `M-.`) |
| Find references | `gD` | **`C-c c D`** |
| Universal argument | `SPC u` | **`C-u`** |

`doom-leader-key` and `doom-localleader-key` are ignored in non-evil setups — set
`doom-leader-alt-key` / `doom-localleader-alt-key` if you want different prefixes.

Because `C-c l` is the localleader, the Lisp REPL launcher lives on **`C-c r`**
("run/repl"), not `C-c l`.

## Files

Drop these into `~/.config/doom/` (Doom's default config dir):

- `init.el` — enabled modules (no evil)
- `config.el` — user configuration
- `packages.el` — extra packages beyond what modules pull in
- `unify-lisp-keys.el` — cross-Lisp unified bindings on the `C-c l` localleader
- `custom.el` — Emacs `custom-set-variables` output (safe-theme hashes, etc.)
- `themes/` — `dracula-theme.el` (symlink to the Homebrew `emacs-dracula`
  package) and `my-doom-dracula-theme.el`, a doom-dracula variant that takes
  its font-lock colors from upstream Dracula
- `cheatsheet/` — `fetch_fonts.py` plus two builders that generate the printable
  keybinding PDFs (see [Cheat sheets](#cheat-sheets))

Terminal behaviour — mouse, clipboard, cursor shape, and key disambiguation —
comes from the `(tty +osc)` module in `init.el` rather than from hand-written
settings in `config.el`.

## First-time install

```zsh
# 1. Install Doom (skip if already installed)
git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
~/.config/emacs/bin/doom install

# 2. Clone this config into place
git clone https://github.com/huegli/doom-emacs.git ~/.config/doom

# themes/dracula-theme.el is a symlink into this formula, so install it:
brew install emacs-dracula

# 3. Sync
~/.config/emacs/bin/doom sync

# 4. Run in the terminal
emacs -nw
```

Add `~/.config/emacs/bin` to your `PATH` so `doom` is on your shell.

## External dependencies

Install what you actually use — Doom will complain politely for anything missing.
`brew doctor` first if you haven't in a while.

### Prerequisites

```zsh
# Homebrew itself (skip if installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Search tools Doom relies on
brew install ripgrep fd git coreutils

# Optional but recommended
brew install libvterm            # unlocks the :term vterm module
brew install --cask font-jetbrains-mono
```

### Emacs — `emacs-plus@30` with native compilation (terminal-only)

`emacs-plus` builds Emacs from source with the flags Doom benefits most from:
native compilation (much faster elisp) and tree-sitter. On M2 the initial build
takes ~5–10 minutes; after that, package installs and Doom startup are
noticeably snappier.

This build targets `emacs -nw` only — no Cocoa app, no WebKit, no image libs
you wouldn't use from a terminal. That trims the compile time and dependency
footprint.

```zsh
brew tap d12frosted/emacs-plus

brew install emacs-plus@30 \
  --with-native-comp \
  --with-tree-sitter \
  --with-no-frame-refocus \
  --with-poll                    # better process handling than select()
```

Flag notes:

- `--with-native-comp` — the reason to use `emacs-plus`. Emacs will AOT-compile
  elisp to native code on first load; `doom sync` triggers a big compile pass.
- `--with-tree-sitter` — Doom's `:tools tree-sitter` module needs this.
- `--with-poll` — replaces `select()` with `poll()` and lifts the 1024-fd
  limit; matters once you have LSP + CIDER + SLY + vterm running.
- `--with-no-frame-refocus` — harmless in a terminal, avoids a macOS Cocoa
  focus quirk if you ever launch the app frame.

Deliberately omitted (all GUI-only):

- `--with-imagemagick`, `--with-xwidgets`, `--with-rsvg`, `--with-dbus`
- `--with-mailutils` (only useful if you send mail from within Emacs)
- All icon flags (`--with-modern-*`, `--with-savchenkovaleriy-big-sur-icon`)

Put the CLI binary on `PATH`:

```zsh
echo 'export PATH="/opt/homebrew/opt/emacs-plus@30/bin:$PATH"' >> ~/.zshrc
exec zsh

emacs --version                  # should say GNU Emacs 30.x
emacs -Q --batch --eval '(message "native-comp: %s" \
  (if (and (fboundp (quote native-comp-available-p)) \
           (native-comp-available-p)) "yes" "no"))'
```

The second command should print `native-comp: yes`. If it says `no`, `libgccjit`
is missing or mismatched — `brew reinstall gcc libgccjit` and rebuild.

**Daemon (recommended for terminal use):**

```zsh
emacs --daemon                   # start once per login
alias e='emacsclient -nw'        # attach in the current terminal
```

Or have launchd start it automatically:

```zsh
brew services start d12frosted/emacs-plus/emacs-plus@30
```

With the daemon running, `emacsclient -nw` opens in ~200 ms even with a large
Doom config.

### Racket

```zsh
brew install --cask racket
racket --version                 # sanity check

# Recommended packages for a smoother racket-mode experience
raco pkg install --auto drracket-tool-lib   # racket-xp-mode analysis backend
raco pkg install --auto rackunit-lib        # test framework used by C-c C-t
```

Doom's `:lang racket` module picks up the `racket` binary from `PATH`; no extra
config needed.

### Scheme (Chez + Racket via Geiser)

Racket is already installed above. Add Chez as the primary Scheme:

```zsh
brew install chezscheme
chez --version                   # or:  scheme --version
```

Homebrew's formula installs both `chez` and `scheme` shims. The Doom config
calls the binary `chez`; if your install only exposes `scheme`, either symlink
it (`ln -sf $(brew --prefix)/bin/scheme /usr/local/bin/chez`) or edit
`geiser-chez-binary` in `config.el`.

From Emacs:

- `C-c r z` — open a Chez REPL via Geiser
- `C-c r R` — open a Racket REPL via Geiser (alternative to `racket-mode`)
- `.rkt` files still use `racket-mode` by default; `.scm` / `.ss` use Geiser.

### Clojure

```zsh
# Official Clojure CLI (deps.edn / clj / clojure)
brew install clojure/tools/clojure

# Leiningen — useful for legacy project.clj repos
brew install leiningen

# clojure-lsp — used by :lang (clojure +lsp) for completion/refactoring
brew install clojure-lsp/brew/clojure-lsp-native

# A JDK is required. Any recent LTS works; Temurin 21 is a solid default.
brew install --cask temurin@21
```

CIDER's `cider-jack-in` will start an nREPL server automatically from any
`deps.edn` or `project.clj` project. First launch downloads middleware to
`~/.m2/`, so give it a minute on a fresh machine.

### Hy (via uv)

Hy is a Python library, so it lives inside a Python environment. Two options:

**Global tool (simplest)** — one Hy on your `PATH`, isolated by uv:

```zsh
brew install uv
uv python install 3.12          # or 3.13; Hy tracks recent CPython
uv tool install --python 3.12 hy
hy --version                    # should print a Hy version banner
```

`uv tool install` puts a `hy` shim in `~/.local/bin` (make sure that's on
`PATH`). `hy-mode` in Emacs just calls `hy`, so nothing else to configure.

**Per-project (recommended for real work)** — lets each project pin its own
Hy + Python + dependencies, and Doom's `:tools direnv` module activates it
automatically when you `cd` in:

```zsh
cd ~/code/my-hy-project
uv init --python 3.12           # creates pyproject.toml + .venv
uv add hy

# Wire direnv so Emacs (and your shell) pick up the venv on entry
brew install direnv
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
cat > .envrc <<'EOF'
source .venv/bin/activate
EOF
direnv allow
```

Now `M-x run-hy` inside any file under that project uses the project's Hy.

Optional Python LSP for the underlying `.py` you may write alongside `.hy`:

```zsh
uv tool install "python-lsp-server[all]"
# or, if you prefer Microsoft's Pyright (matches Doom's +pyright flag):
uv tool install pyright
```

### Common Lisp workflow

- **SBCL** — launched as an inferior process by SLY. Just `SPC l s` (or `M-x sly`).
- **LispWorks** — you drive the LispWorks IDE yourself and start a Slynk server
  inside it, then attach from Emacs. In the LispWorks listener:

  ```lisp
  (ql:quickload :slynk)
  (slynk:create-server :port 4005 :dont-close t)
  ```

  Or, if you keep Slynk outside Quicklisp, `(load "/path/to/slynk-loader.lisp")`
  then the same `create-server` call. Put it in your LispWorks init file to
  autostart it on every launch.

  From Emacs: `C-c r w` → attaches to `localhost:4005`. Use `C-c r C` if you
  ever need a different host/port.

## Terminal tips (iTerm2 + tmux)

- **Truecolor:** `defaults write com.googlecode.iterm2 -dict-add 'AsciiFontMetrics' '{ForceCoolretroTermCompatibility = 0;}'` isn't needed — just set iTerm2 profile → *Terminal → Report Terminal Type* to `xterm-256color`, and in tmux add `set -ga terminal-overrides ",xterm-256color:Tc"`.
- **Meta key:** iTerm2 → Profiles → Keys → *Left Option* = `Esc+`. Essential here — without evil, everything runs through `C-`/`M-` chords, so a working Meta is not optional.
- **`C-c` in a terminal:** safe. Emacs claims `C-c` as a prefix before the TTY can treat it as SIGINT, so the Doom leader works normally under `emacs -nw`.
- **Clipboard:** the `(tty +osc)` module routes the clipboard through clipetty / OSC 52. If it misbehaves inside tmux, add `set -g set-clipboard on` to `~/.tmux.conf`.
- **Key disambiguation:** `(tty +osc)` also enables [kkp](https://github.com/benotn/kkp), the Kitty keyboard protocol, which lets the terminal distinguish chords it otherwise couldn't — including `C-i` from `TAB`. This is why `config.el` deliberately does *not* set `xterm-extra-capabilities` to `modifyOtherKeys`: that is a competing mechanism for the same problem, and enabling both risks garbled modifiers. If a chord misbehaves under `emacs -nw`, run `M-x kkp-status` to confirm the terminal negotiated kkp before changing anything.
- **Fast startup:** `emacs --daemon` once, then `emacsclient -nw` for near-instant launches.

## Daily commands

### General (Doom leader = `C-c`)

| Task | Keys |
|---|---|
| Command palette | `M-x` |
| Find file in project | `C-c p f` (or `C-x C-f`) |
| Switch buffer | `C-c b b` (or `C-x b`) |
| Toggle terminal | `C-c o t` (vterm) |
| Git status | `C-c g g` |
| Toggle line numbers | `C-c t l` |
| Jump to definition | `C-c c d` or `M-.` |
| Docs at point | `C-c c k` |
| Describe key | `C-h k` |
| All bindings in this mode | `C-h m` |
| Which-key help | `C-c` then wait |
| Lisp REPL launcher | `C-c r` then wait |
| Unified Lisp commands | `C-c l` then wait |

### Start / connect a REPL (`C-c r` …)

| Task | Keys |
|---|---|
| Start SBCL (inferior) | `C-c r s` or `M-x sly` |
| Connect to LispWorks :4005 | `C-c r w` |
| Connect to another Slynk | `C-c r C` |
| Jack-in Clojure | `C-c r c` or `C-c M-j` |
| Jack-in ClojureScript | `C-c r j` or `C-c M-J` |
| Run Racket buffer | `C-c r k` or `C-c C-k` |
| Geiser Racket REPL | `C-c r R` |
| Geiser Chez REPL | `C-c r z` |
| Start Hy REPL | `C-c r h` or `M-x run-hy` |

Or just `C-c l '` inside any Lisp buffer — it opens that language's REPL.

### Unified cross-Lisp grammar (`C-c l` …)

Identical in Common Lisp, Scheme, Clojure, Racket, Hy, and Emacs Lisp:

| Task | Keys | Task | Keys |
|---|---|---|---|
| REPL: start / switch | `C-c l '` | Restart REPL | `C-c l R` |
| Eval last sexp | `C-c l e` | Interrupt | `C-c l !` |
| Eval defun | `C-c l d` | Compile defun | `C-c l c` |
| Eval region | `C-c l r` | Load file | `C-c l f` |
| Eval / load buffer | `C-c l b` | Eval + pretty-print | `C-c l P` |
| Docs for symbol | `C-c l k` | Inspect value | `C-c l i` |
| Macroexpand-1 | `C-c l m` | Macroexpand all | `C-c l M` |
| Run test at point | `C-c l t` | Trace / debug | `C-c l T` |

Slots a given mode has no command for are left unbound; `C-c l` then waiting
shows exactly what that mode supports.

### Common Lisp — SLY (`sly-mode` buffers)

Verified against the [SLY User Manual v1.0.42](https://joaotavora.github.io/sly/).

| Task | Keys |
|---|---|
| Compile defun at point | `C-c C-c` |
| Compile & load file | `C-c C-k` |
| Compile file (no load) | `C-c M-k` |
| Load file (`LOAD`) | `C-c C-l` |
| Eval last sexp (overlay) | `C-x C-e` |
| Eval defun | `C-M-x` |
| Eval region | `C-c C-r` |
| Eval + pretty-print | `C-c C-p` |
| Eval from minibuffer | `C-c :` |
| Interrupt Lisp | `C-c C-b` |
| Switch to REPL | `C-c C-z` |
| Sync REPL package/dir | `C-c ~` |
| Jump to definition / back | `M-.` / `M-,` |
| Find references | `M-?` |
| Next / previous compiler note | `M-n` / `M-p` |
| Describe symbol | `C-c C-d C-d` |
| Describe function | `C-c C-d C-f` |
| HyperSpec at point | `C-c C-d C-h` |
| Apropos | `C-c C-d C-a` |
| Apropos (incl. internal) | `C-c C-d C-z` |
| Apropos package | `C-c C-d C-p` |
| Macroexpand-1 | `C-c C-m` |
| Macroexpand all | `C-c M-m` |
| Disassemble | `C-c M-d` |
| Inspect (prompt) | `C-c I` |
| Toggle trace at point | `C-c C-t` |
| Trace Dialog | `C-c T` |
| List callers / callees | `C-c <` / `C-c >` |
| Who-calls / who-references | `C-c C-w C-c` / `C-c C-w C-r` |
| Sticker at point | `C-c C-s C-s` |
| Sticker replay | `C-c C-s C-r` |
| Sticker next / prev | `C-c C-s n` / `C-c C-s p` |

In the SLY REPL buffer (`sly-mrepl-mode`):

| Task | Keys |
|---|---|
| Previous / next input | `M-p` / `M-n` |
| History isearch | `C-r` |
| Interrupt | `C-c C-b` (also `C-c C-c`) |
| Clear recent output | `C-c C-o` |
| Clear entire REPL | `C-c M-o` |
| Previous / next value button | `C-M-p` / `C-M-n` |
| REPL comma commands | `,` at prompt — e.g. `,in-package`, `,cd`, `,restart-inferior-lisp`, `,quit` |

### Scheme — Geiser (`.scm`, `.ss`, and `geiser-repl-mode`)

Verified against the [Geiser User Manual](https://elpa.nongnu.org/nongnu/doc/geiser.html).

In Scheme buffers (`geiser-mode`):

| Task | Keys |
|---|---|
| Eval last sexp | `C-x C-e` |
| Eval defun | `C-M-x` or `C-c C-c` |
| Eval region | `C-c C-r` |
| Eval buffer | `C-c C-b` |
| Load file | `C-c C-l` |
| Eval defun + switch to REPL | `C-c M-e` (also `C-c M-c`) |
| Eval region + switch to REPL | `C-c M-r` |
| Eval buffer + switch to REPL | `C-c M-b` |
| Switch to REPL | `C-c C-z` |
| Switch to REPL + enter module | `C-c C-a` (or `C-u C-c C-z`) |
| Switch Scheme implementation | `C-c C-s` |
| Jump to definition / back | `M-.` / `M-,` |
| Symbol docs | `C-c C-d C-d` |
| Module exports | `C-c C-d C-m` |
| Callers / callees | `C-c <` / `C-c >` |
| Macroexpand last sexp | `C-c C-m C-e` |
| Macroexpand definition | `C-c C-m C-x` |
| Macroexpand region | `C-c C-m C-r` |
| Edit module | `C-c C-e C-m` |
| Add to load path | `C-c C-e C-l` |
| Toggle `()` ↔ `[]` | `C-c C-e C-[` |
| Insert `λ` | `C-c C-\\` |
| Autodoc (echo area) | always on |

In the Geiser REPL (`geiser-repl-mode`):

| Task | Keys |
|---|---|
| Load file | `C-c C-l` |
| Switch to previous buffer | `C-c C-z` |
| Set current module | `C-c C-m` |
| Import module | `C-c C-i` |
| Jump to definition | `M-.` |
| Symbol docs | `C-c C-d C-d` |
| Module docs | `C-c C-d C-m` |
| Clear REPL buffer | `C-c M-o` |
| Restart REPL | `M-x geiser-restart-repl` |

Comma shortcuts are the underlying Scheme's own REPL commands, not Geiser's;
type `,help` at the prompt. In Chez: `,cd`, `,inspect`, `,pop`, `,quit`. In
Racket: `,enter <module>`, `,enter (file "...")`.

### Clojure — CIDER (`.clj`, `.cljs`, `.cljc`)

Verified against the [CIDER keybindings reference](https://docs.cider.mx/cider/keybindings.html).

| Task | Keys |
|---|---|
| Eval last sexp (overlay) | `C-x C-e` (also `C-c C-e`) |
| Eval defun | `C-c C-c` (also `C-M-x`) |
| Eval region | `C-c C-v r` (`C-c C-v` prefix map) |
| Load / reload buffer | `C-c C-k` |
| Switch to REPL | `C-c C-z` |
| Jump to definition / back | `M-.` / `M-,` |
| Docs for symbol | `C-c C-d d` (`C-c C-d` prefix map) |
| Javadoc | `C-c C-d j` |
| Inspect value at point | `C-c M-i` |
| Run test at point | `C-c C-t t` (`C-c C-t` prefix map) |
| Run tests in ns | `C-c C-t n` |
| Run all project tests | `C-c C-t p` |
| Show test report | `C-c C-t b` |
| Debug next form | `C-u C-M-x` (or `C-u C-c C-c`) |
| Macroexpand-1 | `C-c C-m` |
| Macroexpand menu (incl. all) | `C-c M-m` → e.g. `a` for all |
| Interrupt eval | `C-c C-b` |
| Namespace prefix map | `C-c M-n` — e.g. `r` refresh, `n` set, `b` browse |
| Quit connection | `C-c C-q` |
| clojure-lsp code actions | `C-c c a` |
| clojure-lsp rename | `C-c c r` |

Note CIDER groups many commands under prefix maps: `C-c C-d` (docs), `C-c C-v`
(eval), `C-c C-t` (tests), `C-c M-n` (namespaces), `C-c M-m` (macroexpansion),
`C-c C-j` (insert-in-REPL). Press the prefix then wait — which-key will list
the suffix keys.

### Racket — `racket-mode` (`.rkt`)

Verified against the [racket-mode reference](https://racket-mode.com/multi-back-end-index.html).

In `racket-mode` buffers:

| Task | Keys |
|---|---|
| Run module at point | `C-c C-c` or `C-c C-k` |
| Send last sexp | `C-x C-e` |
| Send definition | `C-M-x` |
| Send region | `C-c C-r` |
| Switch to REPL | `C-c C-z` |
| Run test submodule | `C-c C-t` |
| Profile | `C-c C-o` |
| Open logger | `C-c C-l` |
| Cycle paren shapes `()`/`[]`/`{}` | `C-c C-p` |
| Insert `λ` | `C-M-y` |
| Fold / unfold test submodules | `C-c C-f` / `C-c C-u` |
| Open require path | `C-c C-x C-f` |
| Expand region | `C-c C-e r` |
| Expand last sexp | `C-c C-e e` |
| Expand definition | `C-c C-e x` |
| Expand file (macro stepper) | `C-c C-e f` |

In `racket-mode` **without** xp-mode:

| Task | Keys |
|---|---|
| Documentation search | `C-c C-d` |
| Describe (search-based) | `C-c C-.` (also `C-c C-s`) |

In `racket-xp-mode` (background analysis; enabled in your `config.el`):

| Task | Keys |
|---|---|
| Jump to definition | `M-.` (`xref-find-definitions`) |
| Documentation for symbol | `C-c C-d` |
| Describe symbol | `C-c C-.` |
| Find references | `C-c # ?` |
| Rename | `C-c # r` |
| Next / previous *use* | `C-c # n` / `C-c # p` |
| Next / previous *definition* | `C-c # j` / `C-c # k` |
| Next / previous *error* | `C-c # N` / `C-c # P` |
| Re-annotate buffer | `C-c # g` |
| Tail call up / down | `C-c # ^` / `C-c # v` |
| Tail sibling next / prev | `C-c # >` / `C-c # <` |

In `racket-repl-mode`:

| Task | Keys |
|---|---|
| Break current computation | `C-c C-c` |
| Exit REPL | `C-c C-\\` |
| Switch back to source | `C-c C-z` |
| Describe / docs at point | `C-c C-.` / `C-c C-d` |
| Expand region/sexp/defn/file | `C-c C-e r/e/x/f` |

### Hy — `hy-mode` + inferior Hy REPL

Verified against
[hy-mode.el source](https://github.com/hylang/hy-mode/blob/master/hy-mode.el).
The binding surface is deliberately small.

| Task | Keys |
|---|---|
| Start / switch to REPL | `C-c C-z` (`run-hy`) |
| Send last sexp | `C-c C-e` |
| Send current form | `C-M-x` |
| Send region | `C-c C-r` |
| Send buffer | `C-c C-b` |
| Describe thing at point | `C-c C-d d` (or `C-c C-d C-d`) |
| Insert `breakpoint()` / `pdb.set_trace` | `C-c C-t` |

`hy-mode` does **not** bind `C-x C-e` or `C-c C-c`; the eval-last-sexp key is
`C-c C-e`. If you want `C-x C-e` too, add to `config.el`:

```elisp
(after! hy-mode
  (define-key hy-mode-map (kbd "C-x C-e") #'hy-shell-eval-last-sexp))
```

Tips:

- Hy shares Python's import system, so activating your `uv`-managed venv (via
  `direnv`) before starting the REPL is what makes `import` work correctly.
- `M-x pyvenv-activate` (from `pyvenv`, pulled in by `:lang python`) lets you
  switch venvs mid-session without leaving Emacs.
- To see the Python code Hy compiles to, run `hy2py file.hy` in a `vterm`
  buffer alongside the source.
- `M-.` uses xref; for reliable jumps, prefer starting the REPL and having Hy
  import the module first.

### Universal (any Lisp buffer)

| Task | Keys |
|---|---|
| Eval defun | `C-M-x` (all five modes) |
| Jump to def / back | `M-.` / `M-,` |
| Docs at point | `C-c c k` (`+lookup/documentation`) |
| Describe symbol (vanilla) | `C-h o` |
| Structural: slurp / barf right | `C-)` / `C-}` (smartparens) |
| Structural: slurp / barf left | `C-(` / `C-{` |
| Wrap in parens | `M-(` |
| Splice sexp | `M-s` |
| Raise sexp | `M-r` |
| Transpose sexps | `C-M-t` |

Eval-last-sexp is *not* universal out of the box:
- SLY, Geiser, Racket, CIDER: `C-x C-e`
- Hy: `C-c C-e` — `unify-lisp-keys.el` adds `C-x C-e` to match the others

### Lispy (modal sexp editing, no evil needed)

The `:editor lispy` module is enabled. When point rests **on a paren**, single
letters become structural commands — this is lispy's intended design, and
without evil there's no lispyville compromise layer.

| Key | Action |
|---|---|
| `j` / `k` | Next / previous sexp (same level) |
| `f` / `b` | Forward / backward into sexps |
| `d` | Jump to the other end of the current sexp |
| `>` / `<` | Slurp / barf |
| `w` / `s` | Move sexp up / down |
| `e` | Eval current sexp |
| `m` | Mark sexp |
| `c` | Clone sexp |
| `r` | Raise sexp |
| `x` | Prompt for a transform (`lispy-x` menu) |
| `q` | Ace-jump to any paren in view |
| `i` | Insert (drops you into normal editing inside the sexp) |

To turn it off for a mode: `(remove-hook 'clojure-mode-hook #'lispy-mode)`.

## Cheat sheets

Two printable PDFs are generated from source in `cheatsheet/`:

| Script | Output | Layout |
|---|---|---|
| `build.py` | `lisp-keybindings.pdf` | By mode — one panel per Lisp, plus Doom keys, structural editing, and lispy |
| `build_by_task.py` | `lisp-keybindings-by-task.pdf` | By task — one row per action, five columns comparing SLY / Geiser / CIDER / racket-mode / hy-mode |

Both are Letter landscape, two pages, with DM Sans and JetBrains Mono embedded.

```zsh
cd cheatsheet
pip install reportlab            # only dependency

python3 fetch_fonts.py          # downloads 5 TTFs into /tmp/fonts
python3 build.py
python3 build_by_task.py
```

`fetch_fonts.py` takes an optional destination (`python3 fetch_fonts.py ~/.fonts`),
but the builders look in `/tmp/fonts`, so change `FONT_DIR` in both if you move it.
DM Sans is pulled through the Google Fonts CSS API rather than by direct URL,
because the predictable-looking gstatic TTF paths return 404 — the script parses
the real URLs out of the `@font-face` blocks the API returns.

### A note on glyph coverage

DM Sans has no Greek or arrow glyphs, so the card text spells out `lambda` and
uses `<->` instead of λ and ↔. Using those characters directly renders empty
boxes. Inspect any regenerated PDF before printing.

The PDFs are build artifacts and are intentionally not committed — regenerate
them after changing any binding, so the cards never disagree with `config.el`
and `unify-lisp-keys.el`.

## Updating

```zsh
~/.config/emacs/bin/doom upgrade    # pulls Doom + all packages
~/.config/emacs/bin/doom sync       # after any change to init.el/packages.el
~/.config/emacs/bin/doom doctor     # diagnose missing deps
```

After changing a keybinding, regenerate the cheat sheets (above) so the
printable cards stay in step with the config.
