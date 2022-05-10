;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Nathan McCarty"
      user-mail-address "nathan@mccarty.io")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
(setq doom-font (font-spec :family "FiraCode Nerd Font" :size 11 :weight 'semi-light)
      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 15))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
;; (setq doom-theme 'doom-solarized-dark)
(use-package! solarized-theme
  :demand t
  :config
  (setq solarized-distinct-fringe-background t
        solarized-distinct-doc-face t
        solarized-scale-markdown-headlines t
        solarized-scale-org-headlines t)
  (load-theme 'solarized-selenized-dark t))

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/Org/")


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

(after! centaur-tabs
  (setq centaur-tabs-set-icons t
        centaur-tabs-set-bar 'underflow
        centaur-tabs-style "alternate")
  (centaur-tabs-headline-match)
  (centaur-tabs-group-by-projectile-project))

(use-package! mixed-pitch
  :hook
  (org-mode . mixed-pitch-mode)
  (markdown-mode . mixed-pitch-mode)
  :config
  (setq mixed-pitch-set-height t))

(after! avy
  (define-key!
    "C-:" 'avy-goto-char
    "C-'" 'avy-goto-char-2
    "M-g f" 'avy-goto-line
    "M-g w" 'avy-goto-word-1
    "M-g e" 'avy-goto-word-0)
  (cheatsheet-add-group 'Avy
                        '(:key "C-:" :description "Goto Char")
                        '(:key "C-'" :description "Goto Char (2)")
                        '(:key "M-g f" :description "Goto line")
                        '(:key "M-g w" :description "Goto word")
                        '(:key "M-g e" :description "Goto word (0)")))

(after! swiper
  (define-key! "C-s" 'swiper))

(use-package! crux
  :bind (("C-k"   . crux-smart-kill-line)
         ("C-c ^" . crux-top-join-line)))

(global-unset-key (kbd "C-q"))
(use-package! string-inflection
  :bind (("C-q" . string-inflection-all-cycle)))
(cheatsheet-add-group 'string-inflection
                      '(:key "C-q" :description "Rotate case"))

(use-package! smart-hungry-delete
  :bind (("M-<backspace>" . smart-hungry-delete-backward-char)))

(use-package! deadgrep
  :bind ("C-c s r" . deadgrep))

(setq org-hide-emphasis-markers t
      org-pretty-entities t)

(font-lock-add-keywords 'org-mode
                        '(("^ *\\([-]\\) "
                           0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "")))
                          ("^ *\\([+]\\) "
                           0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "")))))

(use-package! org-roam
  :custom
  (org-roam-directory (concat org-directory "Roam/"))
  (org-roam-complete-everywhere t)
  :bind (("C-c r l" . org-roam-buffer-toggle)
         ("C-c r f" . org-roam-node-find)
         ("C-c r g" . org-roam-graph)
         ("C-c r i" . org-roam-node-insert)
         ("C-c r c" . org-roam-capture)
         ("C-c r T" . org-roam-dailies-capture-today)
         ("C-c r t" . org-roam-dailies-goto-today)
         :map org-mode-map
         ("C-M-i" . completion-at-point))
  :config
  (setq org-roam-node-display-template (concat "${title:*} " (propertize "${tags:10}" 'face 'org-tag)))
  (org-roam-db-autosync-mode)
  (setq org-roam-dailies-capture-templates
      '(("d" "default" entry "* %<%I:%M %p>: %?"
         :if-new (file+head "%<%Y-%m-%d>.org" "#+title: %<%Y-%m-%d>\n")))))

(use-package! magit-todos
  :hook (magit-mode . magit-todos-mode))

(use-package! magit-delta
  :hook (magit-mode . magit-delta-mode))

(magit-wip-mode)

(use-package! multi-vterm
  :bind (("C-c o M" . multi-vterm)
         ("C-c o m" . multi-vterm-project)))

(use-package! separedit
  :bind
  (:map prog-mode-map
   ("C-c '" . separedit))
  :config
  (setq separedit-default-mode 'gfm-mode
        separedit-continue-fill-column t))

(after! lsp-ui
  (setq lsp-ui-sideline-show-diagnostics t
      lsp-ui-sideline-show-hover t
      lsp-ui-sideline-show-code-actions t))

(after! lsp-ui
  (setq lsp-ui-peek-enable t
      lsp-ui-peek-show-directory t))

(after! lsp-ui
  (setq lsp-ui-doc-enable t
      lsp-ui-doc-position 'top
      lsp-ui-doc-show-with-cursor t))

(after! lsp-mode
  (setq lsp-auto-configure t
        lsp-lens-enable t
        lsp-rust-analyzer-cargo-watch-command "clippy"
        lsp-rust-analyzer-cargo-watch-args ["--all-features"]
        lsp-rust-analyzer-experimental-proc-attr-macros t
        lsp-rust-analyzer-proc-macro-enable t
        lsp-rust-analyzer-use-rustc-wrapper-for-build-scripts t
        lsp-rust-analyzer-import-enforce-granularity t))

(use-package! markdown-mode
  :mode ("README\\.md" . gfm-mode)
  :hook (markdown-mode . variable-pitch-mode)
        (markdown-mode . auto-fill-mode)
  :config
  (setq markdown-header-scaling t
        markdown-hide-markup t
        markdown-fontify-code-blocks-natively t))

(use-package! grip-mode
  :bind (:map markdown-mode-command-map
         ("g" . grip-mode)))

(use-package! elfeed
  :hook (elfeed-search-mode . elfeed-update)
  :bind ("C-x w" . elfeed)
  :config
  (setq elfeed-search-filter "@2-weeks-ago +unread"
        elfeed-db-directory (concat org-directory "elfeed/db/")
        elfeed-enclosure-default-dir (concat org-directory "elfeed/enclosures/"))
  (make-directory elfeed-db-directory t))
