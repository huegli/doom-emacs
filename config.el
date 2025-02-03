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
(setq doom-font (font-spec :family "Iosevka Curly" :size 16 :weight 'medium)
      doom-variable-pitch-font (font-spec :family "Iosevka Etoile" :size 17 :weight 'light))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

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

;; some convienience key bindings
(global-set-key (kbd "s-n") #'make-frame)
(global-set-key (kbd "s-w") #'delete-frame)
(global-set-key (kbd "C-z") #'undo)

;; (use-package! xah-fly-keys
;;   :custom
;;   (xah-fly-use-control-key t)
;;   (xah-fly-use-meta-key t)
;;   :config
;;   (xah-fly-keys-set-layout "dvorak")
;;   (xah-fly-keys 1))

(use-package! denote
  :hook (dired-mode . denote-dired-mode)
  :bind
  ( :map global-map
         ("C-c d n" . denote-open-or-create)
         ("C-c d d" . denote-sort-dired)
         ("C-c d r" . denote-rename-file)
         ("C-c d R" . denote-rename-file-using-front-matter)
         ("C-c d j" . denote-journal-extras-new-or-existing-entry)
         ;; :map org-mode-map
         ;; ("C-c d l" . denote-link)
         ;; ("C-c d L" . denote-add-links)
         ;; ("C-c d b" . denote-backlinks)
         )
  :custom
  ((denote-directory "~/Library/CloudStorage/Dropbox/Documents/Org/denote")
   (denote-file-type 'org)
   (denote-known-keywords '("emacs" "macosx" "stephanie" "mikhaila" "sandiego" "financials" "programing"))
   (denote-date-prompt-use-org-read-date t)
   (denote-journal-extras-title-format 'day-date-month-year)
   (denote-dired-directories-include-subdirectories t))
  :config
  (denote-rename-buffer-mode 1)
  )

(use-package! casual
  :bind (
         ;; :map bookmark-bmenu-mode-map
              ;; ("C-o" . #'casual-bookmarks-tmenu)
              ;; ("J" . #'bookmark-jump)
              ;; :map calendar-mode-map
              ;; ("C-o" . #'casual-calendar-tmenu)
              ;; :map Info-mode-map
              ;; ("C-o" . #'casual-info-tmenu)
         ))

(use-package! dired
  :bind (
         :map dired-mode-map
              ("C-o" . #'casual-dired-tmenu)
              ("s" . #'casual-dired-sort-by-tmenu)
              ("/" . #'casual-dired-search-replace-tmenu)
              ("C-c C-d C-i" . #'denote-dired-link-marked-notes)
              ("C-c C-d C-r" . #'denote-dired-rename-files)
              ("C-c C-d C-k" . #'denote-dired-rename-marked-files-with-keywords)
              ;; ("C-c C-d C-R" . #'denote-dired-rename-marked-files-using-front-matter)
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
  :bind (
         :map org-mode-map
              ("C-c m" . #'org-menu)
         )
  :custom
  ((org-attach-id-dir "~/Library/CloudStorage/Dropbox/Documents/Org/attachments")))

(use-package! org-download
  :custom
  ((org-download-image-dir "~/Library/CloudStorage/Dropbox/Documents/Org/attachments/")))

(use-package! org-roam
  :custom
  ((org-roam-directory "~/Library/CloudStorage/Dropbox/Documents/Org/roam")))

(use-package! nov
  :config
  (add-to-list 'auto-mode-alist '("\\.epub\\'" . nov-mode)))

(use-package! ultra-scroll
  :init
  (setq scroll-conservatively 101 ; important!
        scroll-margin 0)
  :config
  (ultra-scroll-mode 1))

(use-package! gptel
  :bind
  ( :map global-map
         ("C-c g" . gptel-send)
         ("C-c C-g" . gptel-send))
  :config
  (gptel-make-ollama "Ollama"
    :host "localhost:11434"
    :stream t
    :models '(llama3.3:latest deepseek-r1:latest)))

;; accept completion from copilot and fallback to company
;;(use-package! copilot
;;  :hook (prog-mode . copilot-mode)
;;  :bind (:map copilot-completion-map
;;              ("<tab>" . 'copilot-accept-completion)
;;             ("TAB" . 'copilot-accept-completion)
;;              ("C-TAB" . 'copilot-accept-completion-by-word)
;;              ("C-<tab>" . 'copilot-accept-completion-by-word)))
