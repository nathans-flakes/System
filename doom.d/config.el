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
      doom-unicode-font (font-spec :family "FiraCode Nerd Font" :size 11 :weight 'semi-light)
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

(use-package! centaur-tabs
  :config
  (setq centaur-tabs-set-icons t
        centaur-tabs-set-bar 'underflow
        centaur-tabs-style "wave"
        centaur-tabs-enable-key-bindings t)
  (centaur-tabs-headline-match)
  (centaur-tabs-group-by-projectile-project))

(use-package! mixed-pitch
  :hook
  (org-mode . mixed-pitch-mode)
  (markdown-mode . mixed-pitch-mode)
  :config
  (setq mixed-pitch-set-height t))

(setq doom-modeline-buffer-file-name-style 'truncate-with-project
      doom-modeline-mu4e t)

(display-time-mode 1)

(after! treemacs
  (setq treemacs-width 25))

(use-package! alert
  :config
  ;; TODO: Make this conditional so we can make the correct choice on macos
  (setq alert-default-style 'libnotify))

(setq-default fill-column 100)

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

(use-package! org-superstar
  :hook (org-mode . org-superstar-mode)
  :config
  (setq org-superstart-special-todo-items t))

(defvar nm/org-agenda-files-timer nil
  "Timer for automatically updating the org-agenda files")
(defvar nm/time-at-agenda-update 0
  "Time at last agenda update")

(defun nm/update-org-agenda-files ()
  "Helper function for updating the org-agenda files."
  ;; Calcuate time since last update
  (let* ((time-seconds  (float-time (current-time)))
         (seconds-since (- time-seconds nm/time-at-agenda-update))
         (idle-time     (current-idle-time))
         (idle-seconds  (if idle-time (float-time idle-time) 0)))
    ;; If it has been more than 10 minutes since our last agenda file update, then go ahead and update
    ;; Additionally update if the idle timer is greater than 30 seconds
    (when (or
           (> seconds-since 600)
           (> idle-seconds 30))
      ;; Update our time variable
      (setq nm/time-at-agenda-update seconds-since)
      ;; Update our agenda files
      (setq org-agenda-files
        (seq-filter (lambda (item)
                      (and
                       ;; Only accept things that are a directory, or an org file
                       (or (file-directory-p item)
                          (string-match-p ".*org$" item))
                       ;; Exclude the syncthing folder
                       (not (string-match-p ".*stfolder$" item))
                       ;; Exclude the elfeed data folder
                       (not (string-match-p (concat "^" (regexp-quote org-directory) "elfeed/.*") item))))
                    (directory-files-recursively org-directory directory-files-no-dot-files-regexp)))))
  ;; Update the timer, first canceling the old one
  (when nm/org-agenda-files-timer
    (cancel-timer nm/org-agenda-files-timer)
  (setq nm/org-agenda-files-timer (run-with-timer 60 nil 'nm/update-org-agenda-files))))

(after! org
  ;; Set the agenda files on first start
  ;; This also configures the timer for us
  (nm/update-org-agenda-files))

(defvar nm/org-agenda-update-timer nil
  "Timer for automatically updating the org-agenda views")

(defun nm/org-agenda-refresh-conditional ()
  "Helper function to only refresh the org-agenda views if it
either isn't focused or we have been idle long enough. This
avoids updating the buffer, and thus annoying the user, while
they are in the middle of doing something.

This function will run on a 60 second loop, only actually doing
work if it thinks it needs to."
  ;; Make sure the org-agenda-buffer exists, bail out if it doesnt
  (when (boundp 'org-agenda-buffer-name)
    ;; Attempt to get the org agenda buffer
    (when-let ((buffer (get-buffer org-agenda-buffer-name)))
      ;; Calcuate idle time
      (let* ((idle-time (current-idle-time))
             (idle-seconds (if idle-time (float-time idle-time) 0)))
        ;; Update the org-agenda views if any of the following apply:
        ;; - The agenda buffer is not in focus
        ;; - The idle time is greater than one minute
        (when (or
               (not (eq (window-buffer (selected-window)) buffer))
               (> idle-seconds 60))
          ;; Since we are not in the org-agenda-buffer it is safe to rebuild the views
          (with-current-buffer buffer
            (org-agenda-redo-all))))))
    ;; Update the timer, first canceling the old one
    (when nm/org-agenda-update-timer
      (cancel-timer nm/org-agenda-update-timer))
    (setq nm/org-agenda-update-timer (run-with-timer 60 nil 'nm/org-agenda-refresh-conditional)))

(after! org
  ;; This method sets up the timer on its own
  (nm/org-agenda-refresh-conditional))

(after! org
  (setq org-log-into-drawer t
        org-log-done 'time))

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

(use-package! org-protocol-capture-html)

(after! org
  (push
   '("w" "Web site" entry
     (file "")
     "* %a :website:\n\n%U %?\n\n%:initial")
   org-capture-templates))

(use-package! anki-editor)

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

(use-package! rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

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
  :hook (elfeed-show-mode . variable-pitch-mode)
  :hook (elfeed-show-mode . visual-line-mode)
  :bind ("C-x w" . elfeed)
  :config
  (setq elfeed-search-filter "@4-weeks-ago +unread"
        elfeed-db-directory (concat org-directory "elfeed/db/")
        elfeed-enclosure-default-dir (concat org-directory "elfeed/enclosures/")
        shr-max-width nil)
  (make-directory elfeed-db-directory t))

(after! mu4e
  (setq sendmail-program (executable-find "msmtp")
        send-mail-function #'smtpmail-send-it
        message-sendmail-f-is-evil t
        message-sendmail-extra-arguments '("--read-envelope-from")
        message-send-mail-function #'message-send-mail-with-sendmail))

(after! mu4e
  (set-email-account! "mccarty.io"
                      '((mu4e-sent-folder . "/nathan@mccarty.io/Sent")
                        (mu4e-drafts-folder . "/nathan@mccarty.io/Drafts")
                        (mu4e-trash-folder . "/nathan@mccarty.io/Trash")
                        (mu4e-refile-folder . "/nathan@mccarty.io/Archive")
                        (smtpmail-smtp-user . "nathan@mccarty.io"))
                      t))

(after! mu4e
  (setq mu4e-bookmarks '())
  (add-to-list 'mu4e-bookmarks
               '(:name "All Mail"
                 :key ?a
                 :query "NOT flag:trashed"))
  (add-to-list 'mu4e-bookmarks
               '(:name "Inbox - nathan@mccarty.io"
                 :key ?m
                 :query "maildir:\"/nathan@mccarty.io/Inbox\" AND NOT flag:trashed"))
  (add-to-list 'mu4e-bookmarks
               '(:name "Unread"
                 :key ?u
                 :query "flag:unread AND NOT flag:trashed")))

(after! mu4e
  (mu4e-alert-enable-mode-line-display))

(setq +mu4e-backend nil)
(after! mu4e
        (setq mu4e-get-mail-command "true"
              mu4e-update-interval nil))

(after! mu4e
  (setq mu4e-change-filenames-when-moving t))
