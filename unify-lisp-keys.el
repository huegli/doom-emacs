;;; unify-lisp-keys.el -*- lexical-binding: t; -*-
;;;
;;; Unified keybindings across SLY, Geiser, CIDER, racket-mode, and hy-mode.
;;; Written for Doom Emacs WITHOUT evil — vanilla Emacs keys throughout.
;;;
;;; Loaded from config.el with:  (load! "unify-lisp-keys")
;;;
;;; ─── Doom's non-evil key layout ──────────────────────────────────────────
;;;   leader       = C-c          (doom-leader-alt-key)
;;;   localleader  = C-c l        (doom-localleader-alt-key)
;;;
;;; Already claimed by Doom's +emacs-bindings: C-c c (code), C-c e (eval
;;; line/region), C-c p (projectile), C-c w (workspaces), C-c ! (checkers),
;;; C-c b/f/g/h/i/n/o/q/s/t/x, and C-c l itself.
;;;
;;; This file uses ONLY:
;;;   • C-c C-<key>  in each mode's own keymap  (major-mode space, Tier 2)
;;;   • C-c l <key>  the localleader            (guaranteed collision-free, Tier 3)
;;;
;;; Nothing here touches Doom's own leader bindings.


;;;; ═══════════════════════════════════════════════════════════════════════
;;;; TIER 1 — What Doom already unifies for non-evil users
;;;; ═══════════════════════════════════════════════════════════════════════
;;
;;   C-c c d      +lookup/definition       — all five modes
;;   C-c c D      +lookup/references       — where the backend supports it
;;   C-c c k      +lookup/documentation    — all five modes
;;   C-c c a      lsp code actions         — CIDER, Python/Hy
;;   C-c c r      lsp rename               — CIDER, Python/Hy
;;   C-c e        +eval/line-or-region     — generic, any mode with an eval backend
;;   M-. / M-,    xref jump / pop          — native in all five modes
;;   C-M-x        eval defun               — native in all five modes
;;   C-c C-z      switch to REPL           — native in all five modes
;;   C-) C-} C-( C-{ M-( M-" M-s M-r       — smartparens, all modes
;;
;; NOTE: the evil-only bindings gd / gD / K do NOT exist in your setup.
;; `C-c c k' is the documentation key. `C-h o' (describe-symbol) is a decent
;; vanilla-Emacs fallback that works everywhere too.


;;;; ═══════════════════════════════════════════════════════════════════════
;;;; TIER 2 — Additive aliases in each mode's own C-c C-<key> space
;;;; ═══════════════════════════════════════════════════════════════════════
;;
;; These are unaffected by the evil/non-evil choice: they live in major-mode
;; keymaps, which Emacs reserves for C-c C-<key>.

;; ── Eval last sexp → C-x C-e everywhere ───────────────────────────────────
;; 4/5 already use C-x C-e. Only hy-mode differs (it uses C-c C-e).
(after! hy-mode
  (define-key hy-mode-map (kbd "C-x C-e") #'hy-shell-eval-last-sexp))

;; ── Eval region → C-c C-r everywhere ──────────────────────────────────────
;; 4/5 already use C-c C-r. CIDER puts it behind its C-c C-v prefix map.
;; Verify first:  C-h k C-c C-r  in a .clj buffer should report "undefined".
(after! cider
  (define-key cider-mode-map (kbd "C-c C-r") #'cider-eval-region))

;; ── Load/eval whole buffer → C-c C-k everywhere ───────────────────────────
;; SLY, CIDER, and racket-mode already use C-c C-k. Geiser and hy-mode use
;; C-c C-b, which is *interrupt* in SLY and CIDER — the most dangerous
;; collision across the five. Adding C-c C-k lets you stop using C-c C-b.
(after! geiser-mode
  (define-key geiser-mode-map (kbd "C-c C-k") #'geiser-eval-buffer))

(after! hy-mode
  (define-key hy-mode-map (kbd "C-c C-k") #'hy-shell-eval-buffer))

;; ── Free racket's C-c C-c for "eval this form" ────────────────────────────
;; racket-mode binds BOTH C-c C-c and C-c C-k to racket-run-module-at-point,
;; so C-c C-c means "run the whole file" where it means "eval one form" in
;; SLY, Geiser, and CIDER. C-c C-k still runs the module; nothing is lost.
(after! racket-mode
  (define-key racket-mode-map (kbd "C-c C-c") #'racket-send-definition))

;; ── Interrupt → C-c C-b, consistently ────────────────────────────────────
(after! racket-mode
  (define-key racket-mode-map (kbd "C-c C-b") #'racket-repl-break))

;;
;; STILL NOT UNIFIABLE on C-c C-<key> — these need Tier 3:
;;   Docs.        racket-mode binds C-c C-d to a *command*, so it can't also be
;;                a prefix. SLY/Geiser want C-c C-d C-d; CIDER/hy want C-c C-d d.
;;   Macroexpand. SLY/CIDER put it directly on C-c C-m; Geiser uses C-c C-m as
;;                a prefix (and as set-module in its REPL); racket uses C-c C-e.
;;   Tests.       C-c C-t means four different things across the five modes.


;;;; ═══════════════════════════════════════════════════════════════════════
;;;; TIER 3 — Unified localleader grammar:  C-c l <key>
;;;; ═══════════════════════════════════════════════════════════════════════
;;
;; Flat, single-letter suffixes — three keystrokes total, no sub-prefixes.
;; (With a two-key localleader, nesting an extra prefix costs more than it
;; buys. Compare C-c l e against SPC m e e under evil.)
;;
;;   C-c l '   REPL: start / switch to it      C-c l R   REPL: restart
;;   C-c l e   Eval last sexp                  C-c l !   Interrupt
;;   C-c l d   Eval defun                      C-c l c   Compile defun
;;   C-c l r   Eval region                     C-c l f   Load file from disk
;;   C-c l b   Eval / load buffer              C-c l P   Eval + pretty-print
;;   C-c l k   Docs for symbol at point        C-c l i   Inspect value
;;   C-c l m   Macroexpand-1                   C-c l M   Macroexpand all
;;   C-c l t   Run test at point               C-c l T   Trace / debug toggle
;;   C-c l p   Profile
;;
;; `k' is docs (not `d') to match Doom's own C-c c k for +lookup/documentation,
;; which frees `d' to mean "defun" consistently.
;;
;; C-c l is verified free in all five modes: each of SLY, Geiser, CIDER, and
;; racket-mode binds C-c C-l (with Control), never C-c l.
;;
;; Unbound slots are simply omitted per mode; which-key shows what's available.

;; ── Common Lisp — SLY ────────────────────────────────────────────────────
(map! :after sly
      :map sly-mode-map
      :localleader
      :desc "REPL"                "'" #'sly-mrepl
      :desc "Restart Lisp"        "R" #'sly-restart-inferior-lisp
      :desc "Interrupt"           "!" #'sly-interrupt
      :desc "Eval last sexp"      "e" #'sly-eval-last-expression
      :desc "Eval defun"          "d" #'sly-eval-defun
      :desc "Eval region"         "r" #'sly-eval-region
      :desc "Compile & load file" "b" #'sly-compile-and-load-file
      :desc "Load file"           "f" #'sly-load-file
      :desc "Eval + pprint"       "P" #'sly-pprint-eval-last-expression
      :desc "Docs for symbol"     "k" #'sly-describe-symbol
      :desc "Macroexpand-1"       "m" #'sly-expand-1
      :desc "Macroexpand all"     "M" #'sly-macroexpand-all
      :desc "Inspect"             "i" #'sly-inspect
      :desc "Compile defun"       "c" #'sly-compile-defun
      :desc "Toggle trace"        "T" #'sly-toggle-trace-fdefinition
      ;; SLY-only extras
      :desc "HyperSpec lookup"    "h" #'sly-hyperspec-lookup
      :desc "Apropos"             "a" #'sly-apropos
      :desc "Disassemble"         "D" #'sly-disassemble-symbol)

;; ── Scheme — Geiser (Chez default, Racket secondary) ─────────────────────
(map! :after geiser-mode
      :map geiser-mode-map
      :localleader
      :desc "REPL"                "'" #'geiser-mode-switch-to-repl
      :desc "Restart REPL"        "R" #'geiser-restart-repl
      :desc "Eval last sexp"      "e" #'geiser-eval-last-sexp
      :desc "Eval defun"          "d" #'geiser-eval-definition
      :desc "Eval region"         "r" #'geiser-eval-region
      :desc "Eval buffer"         "b" #'geiser-eval-buffer
      :desc "Load file"           "f" #'geiser-load-file
      :desc "Docs for symbol"     "k" #'geiser-doc-symbol-at-point
      :desc "Macroexpand-1"       "m" #'geiser-expand-last-sexp
      :desc "Macroexpand defun"   "M" #'geiser-expand-definition
      ;; Geiser-only extras
      :desc "Set Scheme impl"     "s" #'geiser-set-scheme
      :desc "Edit module"         "x" #'geiser-edit-module
      :desc "Module exports"      "E" #'geiser-doc-module)

;; ── Clojure — CIDER ──────────────────────────────────────────────────────
(map! :after cider
      :map cider-mode-map
      :localleader
      :desc "REPL"                "'" #'cider-switch-to-repl-buffer
      :desc "Restart REPL"        "R" #'cider-restart
      :desc "Interrupt"           "!" #'cider-interrupt
      :desc "Eval last sexp"      "e" #'cider-eval-last-sexp
      :desc "Eval defun"          "d" #'cider-eval-defun-at-point
      :desc "Eval region"         "r" #'cider-eval-region
      :desc "Load buffer"         "b" #'cider-load-buffer
      :desc "Load file"           "f" #'cider-load-file
      :desc "Eval + pprint"       "P" #'cider-pprint-eval-last-sexp
      :desc "Docs for symbol"     "k" #'cider-doc
      :desc "Macroexpand-1"       "m" #'cider-macroexpand-1
      :desc "Macroexpand all"     "M" #'cider-macroexpand-all
      :desc "Inspect"             "i" #'cider-inspect
      :desc "Test at point"       "t" #'cider-test-run-test
      :desc "Debug defun"         "T" #'cider-debug-defun-at-point
      ;; CIDER-only extras
      :desc "Test namespace"      "n" #'cider-test-run-ns-tests
      :desc "Refresh namespaces"  "F" #'cider-ns-refresh
      :desc "Test report"         "?" #'cider-test-show-report)

;; ── Racket — racket-mode ─────────────────────────────────────────────────
(map! :after racket-mode
      :map racket-mode-map
      :localleader
      :desc "REPL"                "'" #'racket-repl
      :desc "Run module"          "R" #'racket-run-module-at-point
      :desc "Eval last sexp"      "e" #'racket-send-last-sexp
      :desc "Eval defun"          "d" #'racket-send-definition
      :desc "Eval region"         "r" #'racket-send-region
      :desc "Run buffer"          "b" #'racket-run-module-at-point
      :desc "Docs for symbol"     "k" #'racket-xp-describe
      :desc "Macroexpand-1"       "m" #'racket-expand-last-sexp
      :desc "Macroexpand defun"   "M" #'racket-expand-definition
      :desc "Test submodule"      "t" #'racket-test
      :desc "Profile"             "p" #'racket-profile
      ;; racket-only extras
      :desc "Logger"              "L" #'racket-logger
      :desc "Rename (xp)"         "n" #'racket-xp-rename
      :desc "Documentation"       "h" #'racket-documentation-search)

;; ── Hy — hy-mode ─────────────────────────────────────────────────────────
(map! :after hy-mode
      :map hy-mode-map
      :localleader
      :desc "REPL"                "'" #'run-hy
      :desc "Eval last sexp"      "e" #'hy-shell-eval-last-sexp
      :desc "Eval current form"   "d" #'hy-shell-eval-current-form
      :desc "Eval region"         "r" #'hy-shell-eval-region
      :desc "Eval buffer"         "b" #'hy-shell-eval-buffer
      :desc "Docs for symbol"     "k" #'hy-describe-thing-at-point
      :desc "Insert breakpoint"   "T" #'hy-insert-pdb
      ;; Hy-only extras
      :desc "Activate venv"       "v" #'pyvenv-activate)

;; ── Emacs Lisp (bonus — same grammar for your config files) ──────────────
(map! :after elisp-mode
      :map emacs-lisp-mode-map
      :localleader
      :desc "IELM"                "'" #'ielm
      :desc "Eval last sexp"      "e" #'eval-last-sexp
      :desc "Eval defun"          "d" #'eval-defun
      :desc "Eval region"         "r" #'eval-region
      :desc "Eval buffer"         "b" #'eval-buffer
      :desc "Load file"           "f" #'load-file
      :desc "Docs for symbol"     "k" #'helpful-at-point
      :desc "Macroexpand-1"       "m" #'macrostep-expand
      :desc "Inspect"             "i" #'+emacs-lisp/edebug-instrument-defun-on)


;;;; ═══════════════════════════════════════════════════════════════════════
;;;; Optional — reclaim single-key modal editing without evil
;;;; ═══════════════════════════════════════════════════════════════════════
;;
;; The `:editor lispy' module (enabled in init.el) is the non-evil answer to
;; evil's sexp motions: whenever point rests on a paren, single letters become
;; structural commands (j/k next/prev sexp, f/b forward/back, d swap side,
;; > < slurp/barf, w/s move, e eval, m mark). Because there's no evil layer,
;; you get lispy's intended design rather than lispyville's compromise.
;;
;; If lispy's takeover of letter keys is too aggressive, disable it per mode:
;;   (remove-hook 'clojure-mode-hook #'lispy-mode)
;;
;; Another option worth knowing about for non-evil users is `:editor god',
;; which gives modal command entry without remapping any letters.


;;;; ═══════════════════════════════════════════════════════════════════════
;;;; Verification
;;;; ═══════════════════════════════════════════════════════════════════════
;;
;; After `doom sync' and restart:
;;
;;   C-h k C-x C-e    in .hy   → hy-shell-eval-last-sexp
;;   C-h k C-c C-r    in .clj  → cider-eval-region
;;   C-h k C-c C-k    in .scm  → geiser-eval-buffer
;;   C-h k C-c C-c    in .rkt  → racket-send-definition
;;   C-c l            in any Lisp → which-key shows the same grammar
;;   C-c r            → the REPL launcher group (config.el)
;;
;; Useful when a binding isn't what you expect:
;;   C-h m                          all bindings for the current major mode
;;   C-h b                          every active binding
;;   M-x doom/describe-active-minor-mode
;;
;; Reminder: any `map!' form using evil state prefixes (:n :i :v :m :o) is
;; silently ignored without :editor evil. If a binding seems to do nothing,
;; check that it isn't state-scoped.

(provide 'unify-lisp-keys)
;;; unify-lisp-keys.el ends here
