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
(setq doom-theme 'dracula)

;; Font settings only apply in GUI; keep here so switching to GUI still works.
(setq doom-font (font-spec :family "JetBrains Mono" :size 13))

;; Terminal mouse, clipboard, cursor shape, and key disambiguation are all
;; handled by the `(tty +osc)' module in init.el — nothing needed here:
;;   • xterm-mouse-mode        added to tty-setup-hook by the module
;;   • clipboard              clipetty / OSC 52 (the +osc flag)
;;   • key disambiguation     kkp (Kitty keyboard protocol), which also
;;                            separates C-i from TAB
;;
;; Deliberately NOT setting `xterm-extra-capabilities' to modifyOtherKeys:
;; that is a competing solution to the same problem kkp solves, and running
;; both risks garbled modifier keys. If a chord like C-c C-l misbehaves in
;; the terminal, check `M-x kkp-status' before adding anything back here.

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

;;;; ─────────────────────────────────────────────────────────────
;;;; No auto-start: the REPL appears only when you ask for it
;;;;
;;;; Doom's :lang common-lisp module puts `+common-lisp-init-sly-h' on
;;;; `sly-mode-hook', and that function fires the moment any Lisp buffer
;;;; turns on sly-mode — opening a single .lisp file launches SBCL.
;;;;
;;;; Setting `sly-auto-start' to 'never is NOT sufficient: the hook
;;;; let-binds it to 'always around its own call, so it overrides whatever
;;;; you configure. The hook itself has to be removed.
;;;;
;;;; Side benefit: that hook also installs `+common-lisp--cleanup-sly-maybe-h'
;;;; on `kill-buffer-hook', which quits the Lisp when the last SLY buffer
;;;; closes. Harmless for an inferior SBCL, but for LispWorks — where SLY is
;;;; attached to a long-running external image — it would kill your session.
;;;; Removing the hook removes that hazard too.
;;;; ─────────────────────────────────────────────────────────────
(after! sly
  (remove-hook 'sly-mode-hook #'+common-lisp-init-sly-h)
  (setq sly-auto-start 'never
        ;; `sly' otherwise offers to reuse an open connection; our own
        ;; command decides that, so keep plain `sly' predictable.
        sly-command-switch-to-existing-lisp 'never))

(defun my/sly-connect-lispworks ()
  "Attach SLY to a LispWorks Slynk server on localhost:4005.
Errors with setup instructions when nothing is listening."
  (interactive)
  (condition-case nil
      (sly-connect "localhost" 4005)
    (file-error
     (user-error
      (concat "Nothing listening on localhost:4005. "
              "In the LispWorks listener: (ql:quickload :slynk) "
              "then (slynk:create-server :port 4005 :dont-close t)")))))

(defun my/sly-repl-dwim (&optional ask)
  "Show the SLY REPL, asking which Lisp to use when not connected.

When a connection already exists, just switch to its REPL. Otherwise
ask for SBCL (started here as an inferior process) or LispWorks
(attached to an existing image on localhost:4005).

With \\[universal-argument] ASK, prompt even when connected, so you can
open a second Lisp alongside the first."
  (interactive "P")
  (if (and (sly-connected-p) (not ask))
      (sly-mrepl)
    (let ((read-answer-short t))
      (pcase (read-answer
              "Which Lisp? "
              '(("sbcl"      ?s "start a new inferior SBCL")
                ("lispworks" ?l "attach to LispWorks on localhost:4005")
                ("quit"      ?q "do nothing")))
        ("sbcl"      (sly 'sbcl))
        ("lispworks" (my/sly-connect-lispworks))
        (_           (message "No REPL started"))))))

;; Take over C-c C-z, which sly-mrepl binds directly in `sly-mode-map'.
;; `after! sly-mrepl' matters — binding earlier gets clobbered when the
;; contrib loads.
(after! sly-mrepl
  (define-key sly-mode-map (kbd "C-c C-z") #'my/sly-repl-dwim))

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
       :desc "SLY: ask SBCL or LispWorks"   "s" #'my/sly-repl-dwim
       :desc "SLY: start SBCL"              "S" (cmd! (sly 'sbcl))
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
