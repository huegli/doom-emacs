;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'dracula)
;; Specify both a dark and light theme, like so and Doom will choose which one
;; to load based on your system light/dark setting:
;;
;;   (setq doom-theme '(doom-one   . doom-one-light))   ; (DARK . LIGHT)
;;
;; If you want more pro-active theme switching based on OS light/dark mode, look
;; up the `auto-dark' package.

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `with-eval-after-load' block, otherwise Doom's defaults may override your
;; settings. E.g.
;;
;;   (with-eval-after-load 'PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look them up).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;;;; ─────────────────────────────────────────────────────────────
;;;; Identity
;;;; ─────────────────────────────────────────────────────────────
(setq user-full-name    "Nikolai Schlegel"
      user-mail-address "nikolai.schlegel@gmail.com")

;; Make mouse work in TTY (useful in iTerm2 / tmux).
(unless (display-graphic-p)
  (xterm-mouse-mode 1)
  ;; Enable clipboard passthrough via OSC 52 when available.
  (setq select-enable-clipboard t
        select-enable-primary   t))

;; iTerm2 truecolor: Doom detects most cases, but this is a safe nudge.
(unless (display-graphic-p)
  (add-to-list 'term-file-aliases '("xterm-256color" . "xterm"))
  (setq xterm-extra-capabilities '(modifyOtherKeys)))

;; Line numbers off in terminal for speed; toggle with C-c t l.
(setq display-line-numbers-type nil)

;; Softer scrolling in TTY.
(setq scroll-margin 3
      scroll-conservatively 101)

;;;; ─────────────────────────────────────────────────────────────
;;;; Structural editing everywhere Lispy
;;;; ─────────────────────────────────────────────────────────────
(defvar my/lisp-mode-hooks
  '(emacs-lisp-mode-hook
    lisp-mode-hook
    lisp-data-mode-hook
    sly-mrepl-mode-hook
    scheme-mode-hook
    geiser-repl-mode-hook
    racket-mode-hook
    racket-repl-mode-hook
    clojure-mode-hook
    clojurescript-mode-hook
    clojurec-mode-hook
    cider-repl-mode-hook
    hy-mode-hook
    inferior-hy-mode-hook))

(dolist (hook my/lisp-mode-hooks)
  (add-hook hook #'rainbow-delimiters-mode))

;; Doom's smartparens is on by default; if you prefer paredit strictness:
;; (dolist (hook my/lisp-mode-hooks) (add-hook hook #'paredit-mode))

;; Modal sexp editing comes from the `:editor lispy' module (init.el), which
;; already enables lispy-mode in Lisp buffers — no manual hooks needed.
;; Without evil there's no lispyville layer, so lispy's single-letter commands
;; work directly whenever point sits on a paren. To opt a mode out:
;;   (remove-hook 'racket-mode-hook #'lispy-mode)

;;;; ─────────────────────────────────────────────────────────────
;;;; Common Lisp — SLY
;;;;
;;;;   SBCL      : launched by SLY as an inferior process.
;;;;   LispWorks : connect to an already-running Slynk server on
;;;;               127.0.0.1:4005. Start Slynk inside LispWorks with:
;;;;                 (ql:quickload :slynk)
;;;;                 (slynk:create-server :port 4005 :dont-close t)
;;;;               or load ~/quicklisp/dists/.../slynk-loader.lisp directly.
;;;; ─────────────────────────────────────────────────────────────
(after! sly
  (setq inferior-lisp-program "sbcl"
        sly-default-lisp     'sbcl)

  (setq sly-lisp-implementations
        '((sbcl ("sbcl" "--dynamic-space-size" "4096"))))

  ;; Default host/port for `sly-connect' — matches your LispWorks Slynk.
  (setq sly-net-coding-system 'utf-8-unix)

  ;; Nice-to-haves loaded via packages.el
  (add-to-list 'sly-contribs 'sly-macrostep)
  (add-to-list 'sly-contribs 'sly-repl-ansi-color))

;; Convenience: one keystroke to attach to the running LispWorks image.
(defun my/sly-connect-lispworks ()
  "Attach SLY to the LispWorks Slynk server on localhost:4005."
  (interactive)
  (sly-connect "localhost" 4005))

;; Offline HyperSpec — after first use it's cached and works without network.
(after! clhs
  (setq common-lisp-hyperspec-root
        (expand-file-name "HyperSpec/" (or (getenv "XDG_DATA_HOME") "~/.local/share"))))

;;;; ─────────────────────────────────────────────────────────────
;;;; Racket (racket-mode is the primary Racket experience)
;;;; ─────────────────────────────────────────────────────────────
(after! racket-mode
  (add-hook 'racket-mode-hook #'racket-xp-mode)   ; background analysis
  (setq racket-show-functions '(racket-show-echo-area)))

;;;; ─────────────────────────────────────────────────────────────
;;;; Scheme — Geiser with Chez + Racket back-ends (no Guile)
;;;;
;;;; Use `racket-mode' for .rkt buffers by default; use Geiser for .scm/.ss
;;;; and for opening a Chez or Racket REPL from anywhere:
;;;;   M-x geiser-chez    or   C-c r z
;;;;   M-x geiser-racket  or   C-c r R
;;;; ─────────────────────────────────────────────────────────────
(after! geiser
  (setq geiser-active-implementations '(chez racket)
        geiser-default-implementation 'chez
        geiser-repl-history-filename
        (expand-file-name "geiser-history" doom-cache-dir)))

(after! geiser-chez
  (setq geiser-chez-binary "chez"))     ; Homebrew installs `chez' on PATH

(after! geiser-racket
  ;; Homebrew's Racket cask puts `racket' on PATH.
  (setq geiser-racket-binary "racket"))

;;;; ─────────────────────────────────────────────────────────────
;;;; Clojure — CIDER + clojure-lsp
;;;; ─────────────────────────────────────────────────────────────
(after! cider
  (setq cider-repl-display-help-banner nil
        cider-save-file-on-load        t
        cider-prompt-for-symbol        nil
        cider-repl-pop-to-buffer-on-connect 'display-only
        cider-font-lock-dynamically    '(macro core function var deprecated)
        cider-eldoc-display-for-symbol-at-point t))

;; Doom's clojure module already wires clojure-lsp via lsp-mode.
;; If you'd rather use Eglot:
;; (setq +lsp-defer-shutdown 5)
;; (add-hook 'clojure-mode-hook #'eglot-ensure)

;;;; ─────────────────────────────────────────────────────────────
;;;; Hy — sits on top of Python venvs (uv-friendly)
;;;; ─────────────────────────────────────────────────────────────
(use-package! hy-mode
  :mode ("\\.hy\\'" . hy-mode)
  :interpreter ("hy" . hy-mode)
  :config
  (setq hy-shell-interpreter "hy"
        hy-shell-use-control-codes t)
  ;; Pick up the uv-managed venv automatically via direnv.
  (add-hook 'hy-mode-hook #'eldoc-mode))

;;;; ─────────────────────────────────────────────────────────────
;;;; Global REPL launcher — leader is C-c (non-evil)
;;;;
;;;; IMPORTANT: C-c l is Doom's LOCALLEADER when evil is disabled, so the
;;;; launcher group cannot live on `l'. It sits on C-c r ("run / repl").
;;;; Verify C-c r is free in your setup with:  C-h k C-c r
;;;;
;;;; Per-mode eval/docs/test commands live on the localleader instead — see
;;;; unify-lisp-keys.el, loaded at the bottom of this file.
;;;; ─────────────────────────────────────────────────────────────
(map! :leader
      (:prefix-map ("r" . "run/repl")
       :desc "SLY: start SBCL"              "s" #'sly
       :desc "SLY: connect LispWorks :4005" "w" #'my/sly-connect-lispworks
       :desc "SLY: connect (prompt)"        "C" #'sly-connect
       :desc "CIDER: jack-in Clojure"       "c" #'cider-jack-in-clj
       :desc "CIDER: jack-in ClojureScript" "j" #'cider-jack-in-cljs
       :desc "Racket: run buffer"           "k" #'racket-run
       :desc "Geiser: Racket REPL"          "R" #'geiser-racket
       :desc "Geiser: Chez REPL"            "z" #'geiser-chez
       :desc "Hy: run REPL"                 "h" #'run-hy))

;; Load the cross-Lisp unified localleader grammar (C-c l …).
(load! "unify-lisp-keys")

;;;; ─────────────────────────────────────────────────────────────
;;;; Small quality-of-life
;;;; ─────────────────────────────────────────────────────────────
(setq-default fill-column 100)
(setq confirm-kill-emacs nil            ; don't nag in a terminal session
      make-backup-files    nil
      auto-save-default    t
      auto-save-interval   200
      require-final-newline t
      indent-tabs-mode     nil)

;; Larger undo history for long REPL sessions.
(setq undo-limit         (* 80 1024 1024)
      undo-strong-limit  (* 120 1024 1024)
      undo-outer-limit   (* 240 1024 1024))

;; Show trailing whitespace only in prog buffers.
(add-hook 'prog-mode-hook (lambda () (setq show-trailing-whitespace t)))

;; Terminal Magit is heavy; keep status hunks visible.
(after! magit
  (setq magit-diff-refine-hunk 'all))
