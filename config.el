;;; config.el -*- lexical-binding: t; -*-

;;;; ─────────────────────────────────────────────────────────────
;;;; Identity
;;;; ─────────────────────────────────────────────────────────────
(setq user-full-name    "Nikolai Schlegel"
      user-mail-address "nikolai.schlegel@gmail.com")

;;;; ─────────────────────────────────────────────────────────────
;;;; Terminal-friendly UI
;;;; ─────────────────────────────────────────────────────────────
;; A theme that renders well in 256-color and truecolor terminals.
(setq doom-theme 'my-doom-dracula)

;; Font settings only apply in GUI; keep here so switching to GUI still works.
(setq doom-font (font-spec :family "JetBrains Mono" :size 13))

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
  (add-hook hook #'rainbow-delimiters-mode)
  (add-hook hook #'aggressive-indent-mode))

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
  (sly-connect "localhos" 4005))

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
