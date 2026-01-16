;; -*- lexical-binding: t -*-
(setq max-lisp-eval-depth 5000) ;; more stack space
(push '(fullscreen . maximized) default-frame-alist) ;; fullscreen early

;; load package manager
(require 'package)
(setq package-archives
      '(("gnu" . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa-stable" . "https://stable.melpa.org/packages/")
        ("melpa" . "https://melpa.org/packages/")))
;; Always prefer melpa-stable or gnu/nongnu to melpa for stability.
(setq package-archive-priorities
      '(("melpa-stable" . 100)
        ("gnu" . 50)
        ("nongnu" . 50)
        ("melpa" . 0)))

(setq-default use-package-enable-imenu-support t) ;; must be set before loading
(require 'use-package)
(setopt use-package-always-ensure t)
(setopt use-package-always-demand t)

(set-charset-priority 'unicode)
(prefer-coding-system 'utf-8-unix)
(set-frame-font "Menlo-12")
(setq-default tab-width 2)
(setq-default indent-tabs-mode nil)

(use-package shut-up
  :functions shut-up)

(shut-up (set-fill-column 120))

(use-package modus-themes)
;;:config (load-theme 'modus-vivendi-tritanopia t))

(use-package miasma-theme
  :config (load-theme 'miasma t))

(defun check-config ()
  "Warn if exiting Emacs with an init file that doesn't load."
  (interactive)
  (or (ignore-errors
        (load-file "~/.config/emacs/init.el"))
      (y-or-n-p "Configuration file may be malformed: really exit?")))

(push #'check-config kill-emacs-query-functions)

;; This opens a web browser without prompting. No!
(defalias 'describe-gnu-project 'ignore)
;; Too easy to accidentally invoke
(defalias 'view-emacs-news 'ignore)
;; Just not relevant at all.
(defalias 'describe-copying 'ignore)
;; Too easy to trigger
(defalias 'mouse-wheel-text-scale 'ignore)

;;; Navigation functions
(defun pt/copy ()
  "VSCode-like Copy command.
If region is active, copy it but preserve the active region.
Otherwise copy the current line."
  (interactive)
  (if (region-active-p)
      (progn
        (pulse-momentary-highlight-region
         (region-beginning) (region-end))
        ;; Region case: prevent deactivation
        (let ((deactivate-mark nil))
          (call-interactively #'kill-ring-save)))
    (progn
      ;; No region: copy whole line
      (kill-ring-save (line-beginning-position) (line-end-position))
      (pulse-momentary-highlight-one-line))))

(defun pt/cut ()
  "A version of `yank-region' that behaves like Cut in VS Code.
If no region is active, call `function:kill-whole-line', otherwise call
`yank-region'."
  (interactive)
  (call-interactively
   (if (region-active-p)
       #'kill-region
     #'kill-whole-line)))

(defun pt/beginning-of-line ()
  "Check if all characters before the cursor point are whitespace.
If so, move to the beginning of the line. Otherwise, move to the first
non-whitespace character on the line."
  (interactive)
  (let ((line-start-to-point
         (buffer-substring-no-properties
          (line-beginning-position) (point))))
    (if (string-match "\\`\\s-*\\'" line-start-to-point)
        (beginning-of-line)
      (back-to-indentation))))

(defun pt/eol-then-newline ()
  "Go to end of line, then `newline-and-indent'."
  (interactive)
  (move-end-of-line nil)
  (newline-and-indent))

(defun pt/eol-semicolon-then-newline ()
  "Go to end of line, insert a semicolon, then `newline-and-indent'."
  (interactive)
  (move-end-of-line nil)
  (insert ";")
  (newline-and-indent))

(defun pt/eol-comma-then-newline ()
  "Go to end of line, insert a semicolon, then `newline-and-indent'."
  (interactive)
  (move-end-of-line nil)
  (insert ",")
  (newline-and-indent))

(defun display-startup-echo-area-message ()
  "Override the normally tedious startup message."
  (message "Welcome back."))

(defun pt/reset-gc-limit ()
  "Set the GC limit to something reasonable."
  (when custom-file
    (load-file custom-file))
  (setq gc-cons-threshold (* 2 100 1024 1024)))

(use-package emacs
  :hook
  ((compilation-mode . visual-line-mode)
   (prog-mode . goto-address-prog-mode)
   (prog-mode . subword-mode)
   (prog-mode . completion-preview-mode)
   (before-save . delete-trailing-whitespace)
   (emacs-startup . pt/reset-gc-limit))
  :bind
  (("C-;" . execute-extended-command)
   ("C-c ;" . execute-extended-command)
   ("s-P" . execute-extended-command)
   ("C-c ." . completion-at-point)
   ("C-." . completion-at-point)
   ("C-a" . pt/beginning-of-line)
   ("C-c p" . pt/copy-file-name-to-kill-ring)
   ("C-c u" . duplicate-dwim)
   ("C-c m" . project-compile)
   ("C-x f" . project-find-file)
   ("C-x s" . save-buffer)
   ("C-c <up>" . upcase-dwim)
   ("C-c <down>" . downcase-dwim)
   ("s-c" . pt/copy)
   ("<pinch>" . nil)
   ("s-d" . eldoc)
   ("s-x" . pt/cut)
   ("s-." . completion-at-point)
   ("s-/" . comment-dwim)
   ("s-<return>" . pt/eol-then-newline)
   ("S-s-<return>" . pt/eol-semicolon-then-newline)
   ("C-s-<return>" . pt/eol-comma-then-newline)
   ("C-c f" . project-find-file)
   ("s-p" . project-find-file)
   ("s-w" . kill-current-buffer)
   ("<mouse-2>" . nil)
   :map
   minibuffer-mode-map
   ("<TAB>" . minibuffer-complete))
  :custom
  (abbrev-suggest t) ; Useful reminder
  (auto-revert-avoid-polling t) ; use kqueue on macOS
  (auto-revert-check-vc-info t) ; behave sanely
  (auto-revert-interval 1) ; wait a little
  (case-fold-search nil) ; case-sensitive searches. staggeringly bad default.
  (column-number-mode t) ; duh
  (confirm-kill-processes nil) ; stop nagging
  (confirm-nonexistent-file-or-buffer nil) ; new files are fine
  (comment-empty-lines t) ; more consistent comment behavior
  (compilation-read-command nil) ; don't ask for a compilation command every time (C-u overrides)
  (compilation-scroll-output 'first-error) ; stop when dying
  (completion-ignore-case t)
  (custom-file (concat user-emacs-directory "custom.el"))
  (default-directory "~/src/") ; mine
  (delete-by-moving-to-trash t)
  (display-time-default-load-average nil) ; pointless
  (dired-kill-when-opening-new-dired-buffer t)
  (dired-create-destination-dirs 'ask)
  (dired-do-revert-buffer t)
  (dired-kill-when-opening-new-dired-buffer t) ; don't spawn a million buffers
  (dired-mark-region t)
  (eldoc-echo-area-prefer-doc-buffer t) ; don't double-show docs
  (eldoc-echo-area-use-multiline-p t) ; multiline is fine
  (executable-prefix-env) ; use shebang
  (enable-recursive-minibuffers t) ; can be useful
  (global-auto-revert-non-file-buffers t) ; let directories revert
  (help-window-select t) ; lets me bury them quick with q
  (indicate-buffer-boundaries 'left) ; kinda cute
  (inhibit-startup-screen t) ; if I see that gnu one more time
  (initial-major-mode 'fundamental-mode) ; why is lisp so special huh
  (initial-scratch-message "") ; I know what a scratch buffer is
  (js-indent-level 2)
  (kill-do-not-save-duplicates t) ; keep kill ring tidy
  (kill-whole-line t) ; behave like macos
  (pulse-delay 0.02) ; a little quicker please
  (read-process-output-max (* 4 65536)) ; bigger read buffers
  (read-minibuffer-restore-windows nil)
  (read-buffer-completion-ignore-case t) ; whyyyy
  (require-final-newline t) ; always newline EOL
  (ring-bell-function 'ignore) ; this only works sometimes lol
  (save-interprogram-paste-before-kill t) ; preserve kill ring better
  (save-some-buffers-default-predicate 'save-some-buffers-root) ; don't ask me to save files outside of the project
  (sentence-end-double-space nil) ; lol
  (sh-basic-offset 2) ; easy there
  (standard-indent 2) ; four is for the birds
  (switch-to-buffer-obey-display-actions t)
  (tab-always-indent 'complete) ; let tab complete
  (truncate-string-ellipsis "…") ; shorter
  (use-short-answers t) ; obviously
  (use-dialog-box nil) ; macOS integration is terrible
  (use-file-dialog nil) ; use vertico and friends
  (uniquify-buffer-name-style 'forward)
  (visible-bell nil) ; it still rings sometimes anyway
  (x-underline-at-descent-line t) ; superstition
  (y-or-n-p-use-read-key t)
  (Man-sed-command "gsed")
  :config
  (context-menu-mode) ; Fairly useless, but better than nothing
  (delete-selection-mode) ; The obvious behavior
  ;; (global-auto-revert-mode) ; Every other editor does this
  (global-display-line-numbers-mode) ; This is the fastest line number functonality
  (global-hi-lock-mode) ; Highlight text with C-x w h
  (global-so-long-mode) ; Avoid potential slowdowns
  (minibuffer-depth-indicate-mode) ; Indicate recursive minibuffers
  (tooltip-mode -1) ; just no
  (winner-mode))

(use-package diff
  :commands diff-no-select)

;; Emacs doesn't check whether a buffer actually has unsaved changes
;; before asking you. Awful. TODO investigate, this doesn't seem to work right...
(defun pt/check-file-modification (&optional _)
  "Clear modified bit on all unmodified buffers."
  (interactive)
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (when (and buffer-file-name
                 (buffer-modified-p)
                 (not (file-remote-p buffer-file-name))
                 (current-buffer-matches-file-p))
        (set-buffer-modified-p nil)))))

(defun current-buffer-matches-file-p ()
  "Return t if the current buffer is identical to its associated file."
  (when buffer-file-name
    (diff-no-select buffer-file-name (current-buffer) nil 'noasync)
    (with-current-buffer "*Diff*"
      (and (search-forward-regexp
            "^Diff finished \(no differences\)\."
            (point-max) 'noerror)
           t))))

(advice-add 'project-compile :before #'pt/check-file-modification)
(add-hook 'before-save-hook #'pt/check-file-modification)
(add-hook 'kill-buffer-hook #'pt/check-file-modification)
(advice-add 'magit-status :before #'pt/check-file-modification)
(advice-add
 'save-buffers-kill-terminal
 :before #'pt/check-file-modification)

(use-package ediff
  :pin manual
  :hook (ediff-after-quit-hook-internal . winner-undo)
  :custom
  (ediff-window-setup-function 'ediff-setup-windows-plain)
  (ediff-split-window-function 'split-window-horizontally)
  (ediff-diff-options "-w" "ignore whitespace"))

(use-package try) ;; Quick way to test out packages

(use-package hl-line
  :pin manual
  :hook ((prog-mode . hl-line-mode) (text-mode . hl-line-mode)))

(use-package yasnippet
  :commands yas-global-mode
  :config (shut-up (yas-global-mode)))

(use-package yasnippet-capf
  :commands yasnippet-capf
  :after yasnippet
  :init (add-to-list 'completion-at-point-functions #'yasnippet-capf))

(use-package recentf
  :pin manual
  :config (shut-up (recentf-mode))
  :custom
  (recentf-auto-cleanup 'never)
  (recentf-max-saved-items 500)
  (recentf-max-menu-items 100))

(use-package savehist
  :pin manual
  :config (savehist-mode))

(use-package unfill)

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package which-key
  :diminish
  :pin gnu
  :custom (which-key-idle-delay 0.3)
  :config
  (which-key-mode)
  (which-key-setup-minibuffer))

(use-package minions
  :commands minions-mode
  :custom
  (minions-prominent-modes
   '(global-auto-revert-mode
     magit-auto-revert-mode
     magit-mode
     modalka-mode
     pith-recording-mode))
  :config (minions-mode))

(use-package repeat
  :config (shut-up (repeat-mode)))

;; There's gotta be something better than this, right? Someone? Anyone?
(use-package smartparens
  :commands sp-local-pair
  :hook
  ((prog-mode . smartparens-mode)
   (text-mode . smartparens-mode)
   (conf-mode . smartparens-mode))
  :config (require 'smartparens-config)
  ;; Smartparens doesn't do the obvious thing wrt indentation, but we can fix that.
  (defun indent-between-pair (&rest _ignored)
    (newline)
    (indent-according-to-mode)
    (forward-line -1)
    (indent-according-to-mode))
  (sp-local-pair
   'prog-mode
   "{"
   nil
   :post-handlers '((indent-between-pair "RET")))
  (sp-local-pair
   'prog-mode
   "["
   nil
   :post-handlers '((indent-between-pair "RET")))
  (sp-local-pair
   'prog-mode
   "("
   nil
   :post-handlers '((indent-between-pair "RET"))))

(use-package edit-indirect
  :commands edit-indirect-region
  :config
  (defun pt/edit-sql-indirect ()
    "Edit the currently active region as an indirect SQL buffer."
    (interactive)
    (unless (region-active-p)
      (user-error "Select a region first"))
    (edit-indirect-region (region-beginning) (region-end) t)
    (sql-mode)))

(use-package xref
  :pin gnu
  :custom (xref-auto-jump-to-first-xref t)
  :bind
  (("s-r" . #'xref-find-references)
   ("s-<mouse-1>" . #'xref-find-definitions-at-mouse)
   ("C-<down-mouse-1>" . #'xref-find-definitions-at-mouse)
   ("C-S-<down-mouse-1>" . #'xref-find-references-at-mouse)
   ("C-<down-mouse-2>" . #'xref-go-back)
   ("s-[" . #'xref-go-back)
   ("M-[" . #'xref-go-back)
   ("s-]" . #'xref-go-forward)
   ("M-]" . #'xref-go-forward)))

;;; Completion/UI

(use-package doom-modeline
  :pin melpa
  :custom
  (doom-modeline-hud t)
  (doom-modeline-vcs-max-length 2000)
  (doom-modeline-minor-modes t)
  (doom-modeline-window-width-limit nil)
  (doom-modeline-buffer-encoding 'nondefault)
  (doom-modeline-buffer-file-name-style 'relative-from-project)
  :config (doom-modeline-mode))

(use-package vertico
  :defines vertico-map
  :commands vertico-mode
  :bind
  (:map
   vertico-map
   ("'" . vertico-quick-exit)
   ("C-c '" . vertico-quick-insert)
   ("DEL" . vertico-directory-delete-char))
  :config (vertico-mode)
  :custom (vertico-count 25))

(use-package marginalia
  :commands marginalia-mode
  :config (marginalia-mode))

(use-package all-the-icons)

(use-package visual-regexp
  :bind (([remap query-replace] . vr/replace) ("C-c R" . vr/replace)))

(use-package embark
  :bind (("C-c e" . embark-act) ("C-h b" . embark-bindings))
  :custom
  (embark-cycle-key ".")
  (embark-verbose-indicator-display-action
   '(display-buffer-below-selected)))

(use-package consult
  :hook (completion-list-mode . consult-preview-at-point-mode)
  :custom
  (consult-narrow-key ">")
  (consult-widen-key "<")
  (completion-in-region-function #'consult-completion-in-region)
  (xref-show-xrefs-function #'consult-xref)
  (xref-show-definitions-function #'consult-xref)
  :bind
  (("C-s" . consult-line)
   ("C-c s" . consult-line)
   ("C-c i" . consult-imenu)
   ("C-c I" . consult-imenu-multi)
   ("C-c r" . consult-recent-file)
   ("C-c `" . consult-flymake)
   ("s-e" . consult-flymake)
   ("C-x b" . consult-buffer)
   ("C-c b" . consult-buffer)
   ("C-c r" . consult-buffer)
   ("s-p" . consult-buffer)
   ("C-c y" . consult-yank-pop)))

(use-package embark-consult
  :after (embark consult))

;; no concurrency means we have to use dtach if we want anything
;; resembling a normal shell command situation
(use-package detached
  :commands (detached-init detached-shell-command)
  :bind (([remap async-shell-command] . detached-shell-command))
  :custom (detached-shell-program "/bin/zsh")
  :config (detached-init))

(use-package expand-region
  :bind ("C-c n" . er/expand-region))

(use-package deadgrep
  :bind ("C-c h" . deadgrep))

;; Emacs undo is ruthlessly unintuitive and the only
;; time I can ever get it straight is with a visual representation
;; of the internals.
(use-package vundo
  :bind ("C-c z" . vundo)
  :custom (vundo-glyph-alist vundo-unicode-symbols))

(use-package symbol-overlay
  :hook (prog-mode . symbol-overlay-mode))

(defun pt/open-ghostty ()
  "Switch to Ghostty."
  (interactive)
  (call-process "open" nil nil nil "/Applications/Ghostty.app"))

(bind-key "s-g" #'pt/open-ghostty)

;; it's better than nothing but I still don't like it.
(use-package indent-bars
  :vc (:url "https://github.com/jdtsmith/indent-bars")
  :hook (prog-mode . indent-bars-mode)
  :hook (yaml-mode . indent-bars-mode)
  :custom (indent-bars-prefer-character t))

;; This should be built into Emacs, it's obvious
(use-package breadcrumb
  :commands breadcrumb-mode
  :config (breadcrumb-mode))

(use-package eglot-booster
  :vc (:url "https://github.com/jdtsmith/eglot-booster")
  :hook (eglot-managed-mode . eglot-booster-mode))

;; it's great. However, don't forget about vc-mode,
;; which can be just as fast.
(use-package magit
  :defines magit-no-confirm
  :functions (magit-get-current-branch magit-auto-revert-mode)
  :hook (vc-checkin . magit-refresh)
  :bind ("C-c g" . magit-status)
  :custom
  (magit-list-refs-sortby "-committerdate")
  (magit-no-confirm '(stage-all-changes set-and-push))
  :config
  (defun doom-modeline-vcs-name ()
    "Display the vcs name."
    (and vc-mode (magit-get-current-branch)))
  (magit-auto-revert-mode +1))

(use-package forge
  :after magit)

;; Best jump-to package.
(use-package avy
  :bind (("C-c l" . avy-goto-line) ("C-c k" . avy-kill-whole-line)))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides
   '((file (orderless styles basic partial-completion)))))

(use-package man)
(use-package info)

;; Transient interface for avy
(use-package casual-suite
  :pin melpa
  :config
  ;; ediff keymap is generated every time?!?
  ;; i guess there's a hook you can get after the generation?
  (defalias 'ediff-toggle-help #'casual-man-tmenu)
  :bind
  (("C-c j" . casual-avy-tmenu)
   ("s-E" . #'casual-editkit-main-tmenu)
   ("s-C" . #'casual-editkit-copy-tmenu)
   ("s-m" . #'casual-compile-tmenu)
   ("s-o" . #'casual-symbol-overlay-tmenu))
  :bind
  (:map dired-mode-map ("?" . casual-dired-tmenu))
  (:map Man-mode-map ("?" . #'casual-man-tmenu))
  (:map calc-mode-map ("?" . #'casual-calc-tmenu))
  (:map Info-mode-map ("?" . #'casual-info-tmenu)))

(use-package eros
  :commands eros-mode
  :config (eros-mode))

;; treesit-auto is super slow with Consult. But it's useful to install
;; every tree-sitter grammar at once. https://github.com/renzmann/treesit-auto/issues/135
(use-package treesit-auto
  :disabled ;; slowwwwww
  :config
  (setq treesit-language-source-alist
        '((typescript
           .
           ("https://github.com/tree-sitter/tree-sitter-typescript"
            "master"
            "typescript/src"))
          (tsx
           .
           ("https://github.com/tree-sitter/tree-sitter-typescript"
            "master"
            "tsx/src"))
          (python
           . ("https://github.com/tree-sitter/tree-sitter-python"))))
  (push '(go-mode . go-ts-mode) major-mode-remap-alist)
  (push
   '(typescript-mode . typescript-ts-mode) major-mode-remap-alist)
  (push '(rust-mode . rust-ts-mode) major-mode-remap-alist)
  (push '(js-mode . js-ts-mode) major-mode-remap-alist)
  (global-treesit-auto-mode))

;; Better window switching
(use-package ace-window
  :bind ("C-c o" . ace-window))

;; Replace crappy native Emacs help
(use-package helpful
  :bind
  (:map
   help-map
   ("f" . helpful-callable)
   ("v" . helpful-variable)
   ("k" . helpful-key)))

(use-package diff-hl
  :commands global-diff-hl-mode
  :hook
  ((magit-pre-refresh . diff-hl-magit-pre-refresh)
   (magit-post-refresh . diff-hl-magit-pre-refresh)
   (magit-post-refresh . diff-hl-update)
   (vc-checkin-hook . magit-refresh))
  :after magit
  :config (global-diff-hl-mode))

(use-package buffer-terminator
  :commands buffer-terminator-mode
  :custom (buffer-terminator-verbose nil)
  :config (buffer-terminator-mode))

;;; Programming stuff

(use-package project
  :pin gnu
  :functions pt/recentf-in-project
  :bind ("C-c F" . #'project-switch-project)
  :bind ("C-c R" . #'pt/recentf-in-project)
  :config
  (defun pt/recentf-in-project ()
    "As `recentf', but filtering based on the current project root."
    (interactive)
    (consult-buffer '(consult-source-project-recent-file)))

  (defun pt/copy-file-name-to-kill-ring (full-path)
    "Copy the current buffer file name to the clipboard.
The path will be relative to the project's root directory, if set.
Invoking with FULL-PATH copies the full path."
    (interactive "P")
    (let ((filename (pt/project-relative-file-name full-path)))
      (kill-new filename)
      (message "Copied buffer file name '%s' to the kill ring."
               filename)))
  :custom
  ;; This is one of my favorite things: you can customize
  ;; the options shown upon switching projects.
  (project-switch-commands
   '((project-find-file "Find file")
     (magit-project-status "Magit" ?g)
     (deadgrep "Grep" ?h)
     (project-dired "Dired" ?d)
     (pt/recentf-in-project "Recently opened" ?r)))
  (compilation-always-kill t)
  (project-vc-merge-submodules nil))

(defun pt/project-relative-file-name (include-prefix)
  "Return the project-relative filename, or the full path if INCLUDE-PREFIX is t."
  (letrec ((fullname
            (if (equal major-mode 'dired-mode)
                default-directory
              (buffer-file-name)))
           (root (project-root (project-current)))
           (relname
            (if fullname
                (file-relative-name fullname root)
              fullname))
           (should-strip (and root (not include-prefix))))
    (if should-strip
        relname
      fullname)))

(use-package apheleia
  :disabled
  :config
  (push '(sqlfluff . ("sqlfluff" "format" "--dialect" "postgres" "-"))
        apheleia-formatters))

(use-package elisp-autofmt
  :hook (emacs-lisp-mode . elisp-autofmt-mode)
  :custom (elisp-autofmt-load-packages-local '("use-package-core")))

;; LSP
;; investigate gh-actions-language-server someday
(use-package eglot
  :hook
  ((js-mode . eglot-ensure)
   (rust-mode . eglot-ensure)
   (just-mode . eglot-ensure)
   (fish-mode . eglot-ensure)
   (dockerfile-mode . eglot-ensure)
   (typescript-mode . eglot-ensure)
   (terraform-mode . eglot-ensure)
   (makefile-mode . eglot-ensure)
   (yaml-mode . eglot-ensure))
  :bind
  (:map
   eglot-mode-map
   ("C-c c" . eglot-code-actions)
   ("C-c a R" . eglot-reconnect)
   ("C-c a r" . eglot-rename))
  :bind
  (("s-r" . xref-find-references)
   ("s-f" . xref-find-definitions)
   ("s-i" . eglot-find-implementation)
   ([remap rust-test] . rust-nextest))
  :config
  (add-to-list
   'eglot-server-programs '(fish-mode . ("fish-lsp" "start")))
  (add-to-list
   'eglot-server-programs
   '(makefile-mode . ("autotools-language-server")))
  (setq eglot-events-buffer-config '(:size 2000 :format short))
  (setopt eglot-autoshutdown t))

(use-package consult-eglot
  :after consult
  :bind ("s-t" . consult-eglot-symbols))

(use-package consult-eglot-embark
  :commands consult-eglot-embark-mode
  :after consult-eglot
  :config (consult-eglot-embark-mode))

(use-package lsp-mode
  :disabled
  :hook (lsp-after-initialize . pt/lsp-hook)
  :bind
  (:map
   lsp-mode-map
   ("C-c c" . lsp-execute-code-action)
   ("C-c a r" . lsp-rename))
  :custom
  (lsp-enable-text-document-color nil)
  (lsp-typescript-format-enable nil)
  :config
  (defun pt/lsp-hook ()
    (breadcrumb-local-mode -1)
    (local-set-key (kbd "<tab-bar> <mouse-movement>") #'ignore)))

(use-package lsp-ui
  :after lsp-mode
  :custom (lsp-ui-doc-delay 0.75))

(use-package flymake
  :pin gnu
  :hook (sh-mode . flymake-mode)
  :custom (flymake-show-diagnostics-at-end-of-line nil))

(use-package flyover
  :hook (flymake-mode . flyover-mode))

(use-package flymake-shellcheck
  :commands flymake-shellcheck-load
  :init (add-hook 'sh-mode-hook 'flymake-shellcheck-load))

(use-package flymake-sqlfluff
  :commands flymake-sqlfluff-load
  :config
  (defun pt/sql-hook ()
    (flymake-sqlfluff-load)
    (setq-local tab-width 4))
  :hook (sql-mode . pt/sql-hook))

(use-package fancy-compilation
  :commands fancy-compilation-mode
  :config (fancy-compilation-mode))

(use-package rust-mode
  :defines rust-mode-map
  :hook (rust-mode . rust-ts-mode)
  :config
  (defun rust-nextest ()
    "Test using `cargo test`"
    (interactive)
    (compile "cargo nextest run"))
  :custom (rust-format-on-save t))

(use-package cargo-mode
  :hook (rust-ts-mode . pt/rust-hook)
  :commands cargo-minor-mode
  :config
  (defun pt/rust-hook ()
    (cargo-minor-mode)
    (setq-local compile-command "cargo build")))

(use-package transient
  :commands (transient-prefix transient-setup))

(use-package cargo-transient
  :after rust-mode
  :bind (:map rust-mode-map ("C-c M" . cargo-transient)))

(use-package dape
  :bind ("C-c a d" . dape-transient)
  :hook
  ((kill-emacs . dape-breakpoint-save)
   (after-init . dape-breakpoint-load)
   (dape-display-source . pulse-momentary-highlight-one-line))
  :config
  (transient-define-prefix
   dape-transient () "Dape – Debug Adapter Protocol"
   [["Session"
     ("d" "Start / select config" dape)
     ("r" "Restart" dape-restart)
     ("f" "Restart frame" dape-restart-frame)
     ("D" "Disconnect + quit" dape-disconnect-quit)
     ("q" "Quit" dape-quit)]
    ["Execution"
     ("p" "Pause" dape-pause)
     ("c" "Continue" dape-continue)
     ("n" "Next (step over)" dape-next)
     ("s" "Step in" dape-step-in)
     ("o" "Step out" dape-step-out)
     ("u" "Until" dape-until)]
    ["Breakpoints" ("b" "Toggle breakpoint" dape-breakpoint-toggle)
     ("B" "Remove all" dape-breakpoint-remove-all)
     ("l" "Log breakpoint" dape-breakpoint-log)
     ("e"
      "Conditional expr"
      dape-breakpoint-expression)
     ("h" "Hit count" dape-breakpoint-hits)]
    ["Stack / Threads"
     ("t" "Select thread" dape-select-thread)
     ("S" "Select stack frame" dape-select-stack)
     (">" "Frame down" dape-stack-select-down)
     ("<" "Frame up" dape-stack-select-up)]
    ["Inspect"
     ("i" "Info buffer" dape-info)
     ("x" "Eval expression" dape-evaluate-expression)
     ("w" "Watch DWIM" dape-watch-dwim)
     ("R" "REPL" dape-repl)
     ("m" "Memory" dape-memory)
     ("M" "Disassemble" dape-disassemble)]])
  :custom
  (dape-breakpoint-global-mode +1)
  (dape-buffer-window-arrangement 'gud)
  (dape-info-hide-mode-line nil))

;; This package appears broken for some reason so we do this manually.
(use-package exec-path-from-shell
  :config
  (let*
      ((fish-path
        (shell-command-to-string
         "/opt/homebrew/bin/fish -i -c \"echo -n \\$PATH[1]; for val in \\$PATH[2..-1];echo -n \\\":\\$val\\\";end\""))
       (full-path (append exec-path (split-string fish-path ":"))))
    (setenv "PATH" fish-path)
    (setq exec-path full-path))
  ;; (setq exec-path-from-shell-shell-name "/opt/homebrew/bin/fish")
  ;; (exec-path-from-shell-initialize)
  )

(use-package github-browse-file
  :custom (github-browse-file-show-line-at-point t))

(use-package makefile-executor
  :bind ("C-c M" . makefile-executor-execute-project-target))

(use-package direnv
  :commands direnv-mode
  :config (direnv-mode)
  :custom (direnv-always-show-summary nil))

(use-package codespaces
  :disabled
  :bind ("C-c S" . codespaces-connect)
  :config
  (codespaces-setup)
  (push 'tramp-own-remote-path tramp-remote-path)
  :custom
  (vc-handled-backends '(Git))
  (tramp-ssh-controlmaster-options ""))

(use-package sudo-edit)

(use-package fish-mode)

(use-package agent-shell
  :commands (agent-shell pt/agent-shell-other-window)
  :bind ("C-c A" . #'pt/agent-shell-other-window)
  :custom
  (agent-shell-anthropic-authentication
   (agent-shell-anthropic-make-authentication :login t))
  (agent-shell-anthropic-claude-command (list "runclaude-acp"))
  :config
  (defun pt/agent-shell-other-window ()
    (interactive)
    (let ((win
           (if (one-window-p)
               (split-window-right)
             (next-window (selected-window)))))
      (select-window win)
      (call-interactively #'agent-shell))))

(use-package go-mode
  :defines go-mode-map
  :commands gofmt-before-save
  :custom (gofmt-command "goimports")
  :hook
  ((go-mode . eglot-ensure)
   (go-mode . abbrev-mode)
   (before-save . pt/go-specific-save-hook))
  :config
  (defun pt/go-mod-vendor-tidy ()
    (interactive)
    (async-shell-command "go mod vendor && go mod tidy"))
  (defun pt/go-specific-save-hook ()
    (when (eq major-mode 'go-mode)
      (gofmt-before-save))))

(use-package gotest
  :commands (go-test-current-test go-test-current-file go-import-add)
  :after go-mode
  :bind
  (:map
   go-mode-map
   ("C-c a t" . #'go-test-current-test)
   ("C-c a T" . #'go-test-current-file)
   ("C-c a i" . #'go-import-add)))

(use-package cc-mode)
(use-package swift-mode)
(use-package protobuf-mode)
(use-package terraform-mode
  :custom (terraform-format-on-save t))
(use-package dockerfile-mode)
(use-package docker-compose-mode)
(use-package markdown-mode)
(use-package web-mode)
(use-package just-mode)
(use-package clojure-mode)
(use-package edn)
(use-package yaml-mode)
(use-package capnp-mode)
(use-package flatbuffers-mode)
(use-package haskell-mode
  :defines (haskell-mode-map haskell-indentation-mode-map)
  :bind (:map haskell-mode-map ("," . modalka-mode))
  :bind (:map haskell-indentation-mode-map ("," . modalka-mode)))
(use-package tide)

(use-package typescript-mode
  :hook (typescript-mode . typescript-ts-mode)
  :custom (typescript-indent-level 2)
  :config
  (defun pt/ts-hook ()
    (eglot-ensure)
    (setq-local enable-eglot-autoformat nil)
    (setq-local tab-width 2)
    (setq-local eglot-send-changes-idle-time 3))
  :hook (typescript-ts-mode . pt/ts-hook)
  :hook (js-ts-mode . pt/ts-hook))

(add-hook 'js-mode-hook #'js-ts-mode)

;; (defun just-consult ()
;;   "Run a recipe from the Justfile associated with the current working directory."
;;   (interactive)
;;   (let* ((command-string (shell-command-to-string "just --summary"))
;;          (all-commands (s-split " " (s-trim command-string)))
;;          (recipe (completing-read "Justfile command:" all-commands)))
;;     (unless recipe
;;       (user-error "No command to run"))
;;     (compile (format "just %s" recipe))))

(use-package yaml-imenu
  :commands yaml-imenu-enable
  :after yaml-mode
  :config (yaml-imenu-enable))

(use-package flymake-yamllint
  :hook (yaml-mode . flymake-mode)
  :hook (yaml-mode . flymake-yamllint-setup))

(use-package verb)

(use-package org
  :commands (pt/org-mode-hook org-emphasize)
  :pin manual
  :hook (org-mode . #'pt/org-mode-hook)
  :bind
  (:map
   org-mode-map ("C-c ;" . nil) ("C-c c" . pt/org-mode-insert-code))
  :bind ("C-c S" . org-store-link)
  :config
  (defun pt/org-mode-hook ()
    (flymake-mode -1))
  (defun pt/org-mode-insert-code ()
    "Like markdown-insert-code, but for org instead."
    (interactive)
    (org-emphasize ?~))
  :custom
  (org-special-ctrl-a t)
  (org-src-ask-before-returning-to-edit-buffer nil)
  (org-src-window-setup 'current-window))

(use-package htmlize)

;; (when (executable-find "sclang")
;;   (push
;;    "/Users/patrick/Library/Application Support/SuperCollider/downloaded-quarks/scel/el"
;;    load-path)
;;
;;   (require 'sclang)
;;
;;   (push "/Users/patrick/src/pith" load-path)
;;
;;   (bind-key "C-<return>" #'sclang-eval-defun sclang-mode-map)
;;   (setf sclang-show-wworkspace-on-startup nil)
;;
;;   (use-package tidal
;;     :bind (:map tidal-mode-map ("," . modalka-mode)))
;;
;;   (use-package real-auto-save
;;     :hook (tidal-mode . real-auto-save-mode)
;;     :custom (real-auto-save-interval 100))
;;
;;   (defun tidal-hush ()
;;     "Stop all the patterns currently running."
;;     (interactive)
;;     (tidal-send-string "hush"))
;;
;;   (use-package emms)
;;   (emms-all)
;;   (require 'emms-setup)
;;
;;   (require 'pith)
;;
;;   (bind-key "C-x c" #'pith-dispatch)
;;   (bind-key "C-<RET>" #'tidal-run-multiple-lines tidal-mode-map)
;;
;;   (setq
;;    pith-workdir "/Users/patrick/tidal"
;;    pith-sample-reload-command "~reload.value")
;;
;;   (bind-key "z" #'pith-play-file-at-dired-point dired-mode-map)
;;
;;   (define-emms-simple-player
;;    afplay '(file)
;;    (regexp-opt '(".mp3" ".m4a" ".aac" ".flac" ".wav")) "afplay")
;;
;;   (setq emms-player-list `(,emms-player-afplay)))


;; Cobble-yourself-a-modal-editor. Works better than the giant hack
;; that is devil-mode. However, I do use the comma key as the leader
;; key, so there needs to be a little custom timer code so that
;; modalka can imitate how Devil treats the leader key when typing
;; a space after a comma.
(use-package modalka
  :commands modalka-define-kbd
  :defines (modalka-mode-map)
  :functions (time-since-modalka-last-invoked pt/modalka-advice)
  :hook (prog-mode . modalka-mode)
  :hook (read-only-mode . modalka-mode)
  :hook (after-init . modalka-mode)
  :bind ("," . modalka-mode)
  :bind (:map c-mode-map ("," . modalka-mode))
  :bind (:map c-mode-base-map ("," . modalka-mode))
  :bind
  (:map
   modalka-mode-map
   ("," . pt/modalka-comma)
   ("<SPC>" . pt/modalka-space)
   ("<RET>" . pt/modalka-enter)
   ("g" . pt/quit)
   ("/" . pt/cape-modalka)
   ("." . pt/quit)
   ("q" . quit-window)
   (";" . execute-extended-command))
  :custom
  (modalka-cursor-type 'hollow)
  (modalka-excluded-modes '(magit-mode magit-status-mode))
  :config
  (defun pt/quit ()
    (interactive)
    (ignore-errors
      (exit-recursive-edit))
    (modalka-mode -1)
    (keyboard-quit))
  (defvar pt/last-hit-comma-at nil)
  (defun pt/modalka-advice (&optional _)
    (setq pt/last-hit-comma-at (current-time)))
  (defun time-since-modalka-last-invoked ()
    (time-subtract
     (current-time) (or pt/last-hit-comma-at (current-time))))
  (advice-add 'modalka-mode :before #'pt/modalka-advice)
  (defun pt/modalka-comma ()
    (interactive)
    (let ((delta (time-since-modalka-last-invoked)))
      (when (< (time-to-seconds delta) 2)
        (insert ","))
      (modalka-mode -1)))
  (defun pt/cape-modalka ()
    (interactive)
    (modalka-mode -1)
    ;; Way uglier than it should be.
    (setq unread-command-events
          (mapcar
           (lambda (e) `(t . ,e))
           (listify-key-sequence (kbd "M-/")))))
  (defun pt/modalka-enter ()
    (interactive)
    (newline-and-indent)
    (modalka-mode -1))
  (defun pt/modalka-space ()
    (interactive)
    (let ((delta (time-since-modalka-last-invoked)))
      (when (< (time-to-seconds delta) 2)
        (insert ", "))
      (modalka-mode -1)))
  ;; The incongruities in the following reflect ~20 years of
  ;; brain-breakage induced by Emacs keybindings
  (modalka-define-kbd "a" "C-a")
  (modalka-define-kbd "b" "C-c b")
  (define-key modalka-mode-map "c" mode-specific-map)
  (modalka-define-kbd "C" "C-c c")
  (modalka-define-kbd "d" "C-d")
  (modalka-define-kbd "e" "C-e")
  (modalka-define-kbd "E" "C-c e")
  (modalka-define-kbd "f" "C-c f")
  (modalka-define-kbd "F" "C-c F")
  (modalka-define-kbd "G" "C-c g")
  (define-key modalka-mode-map "h" help-map)
  (modalka-define-kbd "H" "C-c h")
  (modalka-define-kbd "i" "C-c i")
  (modalka-define-kbd "I" "C-c I")
  (modalka-define-kbd "j" "C-c j")
  (modalka-define-kbd "J" "C-c J")
  (modalka-define-kbd "k" "C-k")
  (modalka-define-kbd "K" "C-c k")
  (modalka-define-kbd "l" "C-c l")
  (modalka-define-kbd "m" "C-c m")
  (modalka-define-kbd "M" "C-c M")
  (modalka-define-kbd "n" "C-n")
  (modalka-define-kbd "N" "C-c n")
  (modalka-define-kbd "o" "C-c o")
  (modalka-define-kbd "p" "C-p")
  ;; q?
  (modalka-define-kbd "r" "C-c r")
  (modalka-define-kbd "R" "C-c R")
  (modalka-define-kbd "s" "C-c s")
  (modalka-define-kbd "S" "C-x C-s")
  (modalka-define-kbd "t" "C-c t")
  (modalka-define-kbd "u" "C-c u")
  (define-key modalka-mode-map "v" vc-prefix-map)
  (define-key modalka-mode-map "x" ctl-x-map)
  (modalka-define-kbd "y" "C-c y")
  (modalka-define-kbd "z" "C-c z")
  (define-key modalka-mode-map "4" ctl-x-4-map)
  (modalka-define-kbd "`" "C-c `")
  (modalka-define-kbd "!" "M-&")) ; shell-command

(provide 'init)
