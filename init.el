;;; init.el -*- lexical-binding: t; -*-

;; Terminal-first Doom Emacs configuration for Lisp development.
;; Enables Racket, Common Lisp, Scheme, Hy (via Python), and Clojure modules.
;;
;; VANILLA EMACS KEYS — the :editor evil module is deliberately NOT enabled.
;; With evil disabled, Doom uses:
;;     leader      = C-c
;;     localleader = C-c l
;; (doom-leader-key / doom-localleader-key are ignored in non-evil setups;
;;  set doom-leader-alt-key / doom-localleader-alt-key to change them.)
;;
;; After editing this file run: ~/.config/emacs/bin/doom sync
;; Launch in terminal with: emacs -nw

(doom! :input

       :completion
       (corfu +orderless +icons)         ; in-buffer completion (works great in TTY)
       (vertico +icons)                  ; minibuffer completion

       :ui
       doom                              ; Doom's look
       doom-dashboard                    ; startup screen
       hl-todo                           ; TODO/FIXME highlighting
       modeline
       (popup +defaults)
       (vc-gutter +pretty)
       workspaces                        ; tab workspaces (C-c w prefix)
       indent-guides
       (emoji +unicode)                  ; safer in terminals than +ascii
       (treemacs +lsp)

       :editor
       ;; NO evil — vanilla Emacs keybindings throughout.
       file-templates
       fold
       (format +onsave)
       lispy                             ; modal sexp editing, built for vanilla Emacs
       snippets
       word-wrap

       :emacs
       (dired +icons)
       electric
       (ibuffer +icons)
       undo
       vc

       :term
       eshell
       vterm                             ; requires libvterm; falls back to eshell if unavailable

       :checkers
       syntax
       (spell +flyspell)

       :tools
       (eval +overlay)                   ; C-x C-e overlay results
       lookup
       magit
       (lsp +peek)                       ; Eglot alt below; keep lsp-mode for Clojure/Python
       tree-sitter
       direnv                            ; picks up .envrc / uv venvs

       :os
       (:if (featurep :system 'macos) macos)  ; improve compatibility with macOS
       (tty +osc)               ; improve the terminal Emacs experience

       :lang
       (cc +lsp)
       common-lisp                       ; SLY + sly-quicklisp
       data
       emacs-lisp
       (clojure +lsp)                    ; CIDER + clojure-lsp
       markdown
       org
       (python +lsp +pyright)            ; useful next to Hy
       racket                            ; racket-mode + xp-mode
       scheme                            ; Geiser: wired for Chez + Racket in config.el
       sh

       :email

       :app

       :config
       (default +bindings +smartparens))
