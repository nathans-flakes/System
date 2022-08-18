;;; init.el -*- lexical-binding: t; -*-

;; This file controls what Doom modules are enabled and what order they load
;; in. Remember to run 'doom sync' after modifying it!

;; NOTE Press 'SPC h d h' (or 'C-h d h' for non-vim users) to access Doom's
;;      documentation. There you'll find a link to Doom's Module Index where all
;;      of our modules are listed, including what flags they support.

;; NOTE Move your cursor over a module's name (or its flags) and press 'K' (or
;;      'C-c c k' for non-vim users) to view its documentation. This works on
;;      flags as well (those symbols that start with a plus).
;;
;;      Alternatively, press 'gd' (or 'C-c c d') on a module to browse its
;;      directory (for easy access to its source code).

(doom! :completion
       (company +childframe)           ; the ultimate code completion backend
       (ivy +fuzzy +precient +childframe +icons)

       :ui
       doom              ; what makes DOOM look the way it does
       doom-dashboard    ; a nifty splash screen for Emacs
       (emoji +unicode)  ; 🙂
       hl-todo           ; highlight todo-words
       indent-guides     ; highlighted indent columns
       modeline          ; snazzy, Atom-inspired modeline, plus API
       nav-flash         ; blink cursor line after big motions
       (popup +defaults)   ; tame sudden yet inevitable temporary windows
       tabs              ; a tab bar for Emacs
       (treemacs +lsp)          ; a project drawer, like neotree but cooler
       unicode           ; extended unicode support for various languages
       window-select     ; visually switch windows
       workspaces        ; tab emulation, persistence & separate workspaces
       zen               ; distraction-free coding or writing

       :editor
       file-templates    ; auto-snippets for empty files
       fold              ; (nigh) universal code folding
       (format +onsave)  ; automated prettiness
       multiple-cursors  ; editing in many places at once
       rotate-text       ; cycle region at point between text candidates
       snippets          ; my elves. They type so I don't have to
       word-wrap         ; soft wrapping with language-aware indent

       :emacs
       (dired +icons)             ; making dired pretty [functional]
       electric          ; smarter, keyword-based electric-indent
       (ibuffer +icons)         ; interactive buffer management
       undo              ; persistent, smarter undo for your inevitable mistakes
       vc                ; version-control and Emacs, sitting in a tree

       :term
       vterm             ; the best terminal emulation in Emacs

       :checkers
       (syntax +childframe)              ; tasing you for every semicolon you forget
       (spell +flyspell +hunspell +everywhere) ; tasing you for misspelling mispelling

       :tools
       (debugger +lsp)          ; stepping through code, to help you add bugs
       direnv
       docker
       editorconfig      ; let someone else argue about tabs vs spaces
       (eval +overlay)     ; run code, run (also, repls)
       lookup              ; navigate your code and its documentation
       lsp               ; M-x vscode
       (magit +forge)             ; a git porcelain for Emacs
       pdf               ; pdf enhancements
       rgb               ; creating color strings

       :os
       (:if IS-MAC macos)  ; improve compatibility with macOS
       (tty +osc)

       :lang
       data              ; config/data formats
       emacs-lisp        ; drown in parentheses
       json              ; At least it ain't XML
       (latex +fold)             ; writing papers in Emacs has never been so fun
       markdown          ; writing docs for people to ignore
       nix               ; I hereby declare "nix geht mehr!"
       (org +pandoc +present +roam2 +pomodoro)               ; organize your plain life in plain text
       raku              ; the artist formerly known as perl6
       rest              ; Emacs as a REST client
       (rust +lsp)
       (sh +fish)                ; she sells {ba,z,fi}sh shells on the C xor
       yaml             ; JSON, but readable
       (kotlin +lsp)
       (java +lsp +meghanada)
       (javascript +lsp)

       :email
       (mu4e +org)

       :app
       (rss +org)        ; emacs as an RSS reader

       :config
       literate
       (default +bindings +smartparens))

(add-hook! 'emacs-startup-hook #'doom-init-ui-h)
