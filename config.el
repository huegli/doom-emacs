;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Nikolai Schlegel"
      user-mail-address "nikolai.schlegel@gmail.com")

;; Local Font & Theme configuration
;;
(load! "local.el")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type nil)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/Library/CloudStorage/Dropbox/Documents/Org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
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

;; No titlebar decorations for Emacs windows
(add-to-list 'default-frame-alist '(undecorated-round . t))

;; Small text scaling for Zen mode
(setq! +zen-text-scale 1.2)

;; some convienience key bindings
(global-set-key (kbd "s-n") #'make-frame)
(global-set-key (kbd "s-w") #'delete-frame)
(global-set-key (kbd "C-z") #'undo)

(use-package! vertico-posframe
  :custom
  ((vertico-posframe-width 150)
   (vertico-posframe-height 30)))

(use-package! denote
  :hook (dired-mode . denote-dired-mode)
  :bind
  ( :map global-map
         ("C-c d n" . denote-open-or-create)
         ("C-c d d" . denote-sort-dired)
         ("C-c d r" . denote-rename-file)
         )
  :custom
  ((denote-directory "~/Library/CloudStorage/Dropbox/Documents/Org/denote")
   (denote-file-type 'org)
   (denote-known-keywords '("emacs" "macosx" "stephanie" "mikhaila" "sandiego" "financials" "programing"))
   (denote-date-prompt-use-org-read-date t)
   (denote-dired-directories-include-subdirectories t))
  :config
  (denote-rename-buffer-mode 1)
  )

(use-package! consult-denote
  :bind ( :map global-map
        ("C-c d f" . consult-denote-find)
        ("C-c d g" . consult-denote-grep))
  :config
  (consult-denote-mode 1))

(use-package! dired
  :bind (
         :map dired-mode-map
              ("C-c C-d C-r" . #'denote-dired-rename-files)
         )
  :config
  (setq dired-dwim-target t)
  (setq denote-dired-directories
        '("~/Library/CloudStorage/Dropbox/Documents/Org/denote"
          "~/Library/CloudStorage/Dropbox/Statements 2024"
          "~/Desktop"
          "~/Downloads"))
  (add-hook 'dired-mode-hook #'denote-dired-mode-in-directories))

(use-package! org
  :custom-face
  (org-document-title ((t (:weight bold :height 1.4))))
  :custom
  ((org-attach-id-dir "~/Library/CloudStorage/Dropbox/Documents/Org/attachments")
   (org-startup-with-inline-images t)
   (org-confirm-babel-evaluate t)
   (org-babel-lisp-eval-fn 'sly-eval))
  :config
  (add-to-list 'org-file-apps '("\\.xlsx\\'" . system))
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (lisp . t)
     (python . t)
     (dot . t)
     (gnuplot . t)
     (conf-space . t))))

(use-package! org-download
  :custom
  ((org-download-image-dir "~/Library/CloudStorage/Dropbox/Documents/Org/attachments/")))

(use-package! org-roam
  :custom
  ((org-roam-directory "~/Library/CloudStorage/Dropbox/Documents/Org/roam")))

(use-package! writeroom
  :hook (org-mode . writeroom-mode))

(defun my-nov-setup ()
  (face-remap-add-relative 'variable-pitch :family "ETBembo"
                                           :height 1.2)
  (variable-pitch-mode))

(use-package! nov
  :config
  (add-to-list 'auto-mode-alist '("\\.epub\\'" . nov-mode))
  (add-hook 'nov-mode-hook 'my-nov-setup))

(use-package! ultra-scroll
  :init
  (setq scroll-conservatively 101 ; important!
        scroll-margin 0)
  :config
  (ultra-scroll-mode 1))

(use-package! sly
  :init
  (setq sly-lisp-implementations
        '((lispworks ("/Users/Nikolai/.local/bin/lw-console"))
          (sbcl ("/opt/homebrew/bin/sbcl" "--dynamic-space-size 4096")))))

(use-package! pulsar
  :config
  (setq pulsar-pulse nil)
  (setq pulsar-face 'pulsar-yellow)
  (add-hook 'consult-after-jump-hook #'pulsar-recenter-top)
  (add-hook 'consult-after-jump-hook #'pulsar-reveal-entry)
  (pulsar-global-mode 1))

;; (use-package! gptel
;;   :bind
;;   ( :map global-map
;;          ("C-c g" . gptel-send)
;;          ("C-c C-g" . gptel-send))
;;   :config
;;   (gptel-make-ollama "Ollama"
;;     :host "localhost:11434"
;;     :stream t
;;     :models '(llama3.3:latest deepseek-r1:latest)))

;; accept completion from copilot and fallback to company
;;(use-package! copilot
;;  :hook (prog-mode . copilot-mode)
;;  :bind (:map copilot-completion-map
;;              ("<tab>" . 'copilot-accept-completion)
;;             ("TAB" . 'copilot-accept-completion)
;;              ("C-TAB" . 'copilot-accept-completion-by-word)
;;              ("C-<tab>" . 'copilot-accept-completion-by-word)))

(use-package! ollama-buddy
  :bind (:map global-map
              ("C-c o l" . ollama-buddy-menu)))

(use-package! vterm
  :custom
  ((vterm-shell "/opt/homebrew/bin/fish")))
