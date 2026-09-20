;; -*- no-byte-compile: t; -*-
;;; packages.el

;; Hy has no Doom module, so pin it here.
(package! hy-mode)

;; Nicer Common Lisp docs / navigation on top of :lang common-lisp (SLY).
(package! sly-macrostep)
(package! sly-repl-ansi-color)

;; Structural editing helpers useful across every Lisp.
;; NOTE: lispy is NOT declared here — it comes from the `:editor lispy' module
;; enabled in init.el. (Without evil, that module gives you plain lispy and
;; skips lispyville, which is exactly what you want.)
(package! aggressive-indent)

;; Better HyperSpec offline lookup (fetches once, then usable air-gapped).
(package! clhs)

;; Geiser back-ends. Doom's :lang scheme module pulls in `geiser' itself,
;; but only the back-ends you name here are installed.
(package! geiser-chez)
(package! geiser-racket)

;; Envrc integrates with direnv/uv so Emacs sees per-project Python venvs
;; (Hy lives inside those). Doom's :tools direnv already pulls direnv.el,
;; but envrc is a lighter buffer-local alternative some prefer:
;; (package! envrc)
