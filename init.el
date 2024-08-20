;; -*- lexical-binding: t -*-
(setq max-lisp-eval-depth 5000)
(push '(fullscreen . maximized) default-frame-alist)

(require 'package)
(push '("melpa" . "https://melpa.org/packages/") package-archives)
(push '("melpa-stable" . "https://stable.melpa.org/packages/") package-archives)
(push '("nongnu" . "https://elpa.nongnu.org/nongnu/") package-archives)

(setq-default use-package-enable-imenu-support t) ; must be set before loading
(require 'use-package)
(setopt use-package-always-ensure t)
(setopt use-package-always-demand t)

(defun check-config ()
  "Warn if exiting Emacs with an init file that doesn't load."
  (or
   (ignore-errors (load-file "~/.config/emacs/init.el"))
   (y-or-n-p "Configuration file may be malformed: really exit?")))

(push #'check-config kill-emacs-query-functions)

;; This opens a web browser without prompting. No!
(defalias 'describe-gnu-project 'ignore)
;; Too easy to accidentally invoke
(defalias 'view-emacs-news 'ignore)
;; Just not relevant at all.
(defalias 'describe-copying 'ignore)

;;; Navigation functions
(defun pt/copy ()
  "A version of `function:kill-ring-save' that behaves like Copy in VSCode.
Calls `function:kill-ring-save', unless no region is active, in which
case it behaves as though the region consists of the entire line."
  (interactive)
  (if (region-active-p)
      (call-interactively #'kill-ring-save)
    (progn
      (kill-ring-save (line-beginning-position) (line-end-position))
      (message "Copied line to kill ring."))))

(defun pt/cut ()
  "A version of `yank-region' that behaves like Cut in VS Code.
If no region is active, call `function:kill-whole-line', otherwise call
`yank-region'."
  (interactive)
  (call-interactively
   (if (region-active-p) #'kill-region #'kill-whole-line)))

(defun pt/beginning-of-line ()
  "Check if all characters before the cursor point are whitespace.
If so, move to the beginning of the line. Otherwise, move to the first
non-whitespace character on the line."
  (interactive)
  (let ((line-start-to-point (buffer-substring-no-properties
                              (line-beginning-position)
                              (point))))
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

(defun display-startup-echo-area-message ()
  "Override the normally tedious startup message."
  (message "Welcome back."))

(use-package emacs
  :hook (compilation-mode . visual-line-mode)
  :hook (prog-mode . goto-address-prog-mode)
  :hook (compilation-filter . ansi-color-compilation-filter)
  :hook (before-save . delete-trailing-whitespace)
  :bind (("C-;" . execute-extended-command)
	 ("C-c ;" . execute-extended-command)
	 ("C-c ." . completion-at-point)
	 ("C-a" . pt/beginning-of-line)
	 ("C-c u" . duplicate-dwim)
         ("C-c m" . project-compile)
         ("C-x f" . project-find-file)
         ("C-x s" . save-buffer)
	 ("s-c" . pt/copy)
         ("s-d" . eldoc)
	 ("s-x" . pt/cut)
         ("s-." . completion-at-point)
	 ("s-/" . comment-dwim)
         ("s-<return>" . pt/eol-then-newline)
         ("S-s-<return>" . pt/eol-semicolon-then-newline)
         ("C-c f" . project-find-file)
	 ("s-p" . project-find-file)
         ("s-w" . kill-this-buffer)
	 :map minibuffer-mode-map
	 ("<TAB>" . minibuffer-complete))
  :custom
  (abbrev-suggest t) ; Useful reminder
  (auto-revert-avoid-polling t) ; use kqueue on macoS
  (auto-revert-check-vc-info t) ; behave sanely
  (auto-revert-interval 5) ; wait a little
  (case-fold-search nil) ; case-sensitive searches. staggeringly bad default.
  (custom-safe-themes t) ; don't warn on themes
  (column-number-mode t) ; duh
  (confirm-kill-processes nil) ; stop nagging
  (confirm-nonexistent-file-or-buffer nil) ; new files are fine
  (comment-empty-lines t) ; more consistent comment behavior
  (compilation-read-command nil) ; don't ask for a compilation command every time (C-u overrides)
  (compilation-scroll-output 'first-error) ; stop when dying
  (confirm-kill-processes nil) ; this is naggy
  (default-directory "~/src/") ; mine
  (display-time-default-load-average nil) ; pointless
  (dired-create-destination-dirs 'ask)
  (dired-do-revert-buffer t)
  (dired-kill-when-opening-new-dired-buffer t) ; don't spawn a million buffers
  (dired-mark-region t)
  (eldoc-echo-area-prefer-doc-buffer t) ; don't double-show docs
  (eldoc-echo-area-use-multiline-p t) ; multiline is fine
  (executable-prefix-env) ; use shebang
  (enable-recursive-minibuffers t) ; can be useful
  (help-window-select t) ; lets me bury them quick with q
  (indicate-buffer-boundaries 'left) ; kinda cute
  (inhibit-startup-screen t) ; if I see that gnu one more time
  (initial-major-mode 'fundamental-mode) ; why is lisp so special huh
  (initial-scratch-message "") ; I know what a scratch buffer is
  (kill-do-not-save-duplicates t) ; keep kill ring tidy
  (kill-whole-line t) ; behave like macos
  (read-process-update (* 1024 1024)) ; bigger read buffers
  (require-final-newline t) ; always newline EOL
  (ring-bell-function 'ignore) ; this only works sometimes lol
  (save-interprogram-paste-before-kill t) ; preserve kill ring better
  (save-some-buffers-default-predicate 'save-some-buffers-root) ; don't ask me to save files outside of the project
  (sentence-end-double-space nil) ; lol
  (sh-basic-offset 2 sh-basic-indentation 2) ; easy there 
  (switch-to-buffer-obey-display-actions t)
  (tab-always-indent 'complete) ; let tab complete
  (truncate-string-ellipsis "…") ; shorter
  (use-short-answers t) ; obviously
  (use-dialog-box nil) ; macOS integration is terrible
  (use-file-dialog nil) ; use vertico and friends
  (visible-bell t) ; it still rings sometimes anyway
  (x-underline-at-descent-line t) ; superstition
  :config
  (context-menu-mode) ; Fairly useless, but better than nothing
  (electric-pair-mode) ; Problematic, but built-in
  (delete-selection-mode) ; The obvious behavior
  (global-auto-revert-mode) ; Every other editor does this
  (global-display-line-numbers-mode) ; This is the fastest line number functonality
  (global-so-long-mode) ; Avoid potential slowdowns
  (minibuffer-depth-indicate-mode) ; Indicate recursive minibuffers
  (pixel-scroll-precision-mode) ; More beautiful scrolling
  (tooltip-mode -1) ; just no
  )

(setq-default fill-column 135) ; it's not 1975 anymore, we have wide screens

;; Stolen from Bedrock Emacs. Justified because backup files are so annoying.
;; Don't litter file system with *~ backup files; put them all inside
;; ~/.emacs.d/backup or wherever
(defun bedrock--backup-file-name (fpath)
  "Return a new file path of FPATH.
If the new path's directories does not exist, create them."
  (let* ((backupRootDir (concat user-emacs-directory "emacs-backup/"))
         (filePath (replace-regexp-in-string "[A-Za-z]:" "" fpath )) ; remove Windows driver letter in path
         (backupFilePath (replace-regexp-in-string "//" "/" (concat backupRootDir filePath "~") )))
    (make-directory (file-name-directory backupFilePath) (file-name-directory backupFilePath))
    backupFilePath))

(setopt make-backup-file-name-function 'bedrock--backup-file-name)

;; TODO investigate, this doesn't seem to work right...

(defun pt/check-file-modification (&optional _)
  "Clear modified bit on all unmodified buffers."
  (interactive)
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (when (and buffer-file-name (buffer-modified-p) (not (file-remote-p buffer-file-name)) (current-buffer-matches-file-p))
        (set-buffer-modified-p nil)))))

(defun current-buffer-matches-file-p ()
  "Return t if the current buffer is identical to its associated file."
  (autoload 'diff-no-select "diff")
  (when buffer-file-name
    (diff-no-select buffer-file-name (current-buffer) nil 'noasync)
    (with-current-buffer "*Diff*"
      (and (search-forward-regexp "^Diff finished \(no differences\)\." (point-max) 'noerror) t))))

(advice-add 'project-compile :before #'pt/check-file-modification)
(add-hook 'before-save-hook #'pt/check-file-modification)
(add-hook 'kill-buffer-hook #'pt/check-file-modification)
(advice-add 'magit-status :before #'pt/check-file-modification)
(advice-add 'save-buffers-kill-terminal :before #'pt/check-file-modification)

(setq-default indent-tabs-mode nil)

(use-package try)

;;; Built-in package
;; See also use-package emacs above
(use-package hl-line
  :pin manual
  :hook ((prog-mode . hl-line-mode)
         (text-mode . hl-line-mode)))

(use-package recentf
  :pin manual
  :bind ("C-c r" . recentf)
  :config (recentf-mode)
  :custom
  (recentf-auto-cleanup (* 60 60))
  (recentf-max-saved-items 100)
  (recentf-max-menu-items 100))

(use-package savehist
  :pin manual
  :config (savehist-mode))

(use-package unfill
  :pin melpa-stable)

(use-package rainbow-delimiters
  :pin melpa-stable
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package which-key
  :pin gnu
  :custom
  (which-key-idle-delay 0.5)
  :config
  (which-key-mode)
  (which-key-setup-side-window-bottom))

(setq dired-kill-when-opening-new-dired-buffer t)

(use-package xref
  :pin gnu
  :custom (xref-auto-jump-to-first-xref t)
  :bind (("s-r" . #'xref-find-references)
         ("C-<down-mouse-1>" . #'xref-find-definitions)
         ("C-S-<down-mouse-1>" . #'xref-find-references)
         ("C-<down-mouse-2>" . #'xref-go-back)
         ("s-[" . #'xref-go-back)
         ("s-]" . #'xref-go-forward)))

;;; Completion/UI

;; The default modeline is underrated but doom-modeline is better about paths
(use-package doom-modeline
  :pin melpa-stable
  :custom
  (doom-modeline-hud nil)
  (doom-modeline-vcs-max-length 200)
  (doom-modeline-buffer-encoding 'nondefault)
  (doom-modeline-buffer-file-name-style 'relative-from-project)
  :config (doom-modeline-mode))

;; Best completion package
(use-package vertico
  :pin melpa-stable
  :bind (:map vertico-map
              ("'"           . vertico-quick-exit)
              ("C-c '"       . vertico-quick-insert)
	      ("DEL" . vertico-directory-delete-char))
  :config (vertico-mode)
  :custom
  (vertico-count 25))

;; Informative minibuffer data
(use-package marginalia
  :pin melpa-stable
  :config (marginalia-mode))

;; Inline completion is good
(use-package corfu
  :pin melpa-stable
  :hook (corfu-mode . corfu-popupinfo-mode)
  :bind (:map corfu-map
              ("'" . corfu-quick-insert)
	      ("C-n" . corfu-next)
	      ("C-p" . corfu-previous))
  :custom
  (corfu-preselect 'valid)
  (corfu-popupinfo-delay '(0.25 . 0.1))
  (corfu-popupinfo-hide nil)
  :config
  (global-corfu-mode))

(use-package nerd-icons
  :pin melpa-stable)

(use-package nerd-icons-dired
  :pin melpa
  :after nerd-icons
  :hook (dired-mode . nerd-icons-dired-mode))

(use-package nerd-icons-completion
  :pin melpa
  :after (nerd-icons marginalia)
  :hook (marginalia-mode . nerd-icons-completion-marginalia-setup)
  :config (nerd-icons-completion-mode))

(use-package nerd-icons-corfu
  :pin melpa-stable
  :after (nerd-icons corfu)
  :custom
  (corfu-margin-formatters '(nerd-icons-corfu-formatter)))


;; Richer data source for corfu
(use-package cape
  :pin melpa-stable
  :bind
  ("M-/" . cape-prefix-map)
  :config
  (setq completion-at-point-functions '(elisp-completion-at-point
                                        cape-abbrev
                                        cape-keyword
                                        cape-dabbrev
                                        cape-file
                                        )))

;; find-and-replace is so crappy otherwise
(use-package visual-regexp
  :pin melpa-stable
  :bind (([remap query-replace] . vr/replace)
         ("C-c R" . vr/replace)))

;; (use-package unfill-paragraph)

;; probably the best package
(use-package embark
  :pin melpa-stable
  :bind (("C-c e" . embark-act)
         ("C-h b" . embark-bindings))
  :custom
  (embark-cycle-key ".")
  (embark-verbose-indicator-display-action '(display-buffer-below-selected)))

;; Consult has a zillion things; I wish it was smaller, but what it does
;; it does well, and it's smaller than Helm.
(use-package consult
  :pin melpa-stable
  :hook (completion-list-mode . consult-preview-at-point-mode)
  :config
  (defun pt/consult-complete ()
    (interactive)
    (let
        ((completion-in-region-function #'consult-completion-in-region))
      (call-interactively #'completion-at-point)))
  :custom
  (xref-show-xrefs-function #'consult-xref)
  (xref-show-definitions-function #'consult-xref)
  :bind (("C-s" . consult-line)
         ("C-c s" . consult-line)
         ("C-c i" . consult-imenu)
         ("C-c I" . consult-imenu-multi)
         ("C-c r" . consult-recent-file)
         ("C-c `" . consult-flymake)
         ("C-x b" . consult-buffer)
         ("C-c b" . consult-buffer)
         ("C-c y" . consult-yank-pop)
         ("s-;" . pt/consult-complete)))

;; Needed for the above
(use-package embark-consult
  :after (embark consult)
  :pin melpa-stable)

;; remembering past inputs costs nothing and is user-friendly
(use-package prescient
  :pin melpa-stable
  :config (prescient-persist-mode)
  :custom
  (prescient-sort-full-matches-first t))

(use-package vertico-prescient
  :pin melpa-stable
  :after (vertico prescient)
  :config
  (setq vertico-prescient-completion-styles '(prescient orderless basic partial-completion emacs22 flex initials shorthand)))

(use-package corfu-prescient
  :pin melpa-stable
  :after (corfu prescient orderless)
  :config (corfu-prescient-mode)
  :custom
  (corfu-prescient-completion-styles '(prescient orderless basic)))

;; no concurrency means we have to use dtach if we want anything
;; resembling a normal shell command situation
(use-package detached
  :pin melpa-stable
  :bind (([remap async-shell-command] . detached-shell-command))
  :config (detached-init))

;; what the hell, let's give it a try
;; sorry, eshell. you are not a real thing
(use-package eat
  :pin nongnu
  :bind ("C-c t" . eat))

(use-package expand-region
  :pin melpa-stable
  :bind ("C-c n" . er/expand-region))

;; Smarter and faster than consult-ripgrep
(use-package deadgrep
  :pin melpa-stable
  :bind ("C-c h" . deadgrep))

;; Emacs undo is ruthlessly unintuitive and the only
;; time I can ever get it straight is with a visual representation
;; of the internals.
(use-package vundo
  :pin gnu
  :bind ("C-c z" . vundo)
  :custom (vundo-glyph-alist vundo-unicode-symbols))

;; TODO: remove this when Emacs 30 is stable
(unless (package-installed-p 'vc-use-package)
  (package-vc-install "https://github.com/slotThe/vc-use-package"))
(require 'vc-use-package)

;; it's better than nothing but I still don't like it.
(use-package indent-bars
  :vc (:fetcher github :repo jdtsmith/indent-bars)
  :hook (prog-mode . indent-bars-mode)
  :hook (yaml-mode . indent-bars-mode)
  :custom
  (indent-bars-prefer-character t))

;; This should be built into Emacs, it's obvious
(use-package breadcrumb
  :pin gnu
  :config
  (breadcrumb-mode))

;; it's great. However, don't forget about vc-mode,
;; which can be just as fast.
(use-package magit
  :pin melpa-stable
  :bind ("C-c g" . magit-status))

;; Best jump-to package.
(use-package avy
  :pin melpa-stable
  :bind (("C-c l" . avy-goto-line)
	 ("C-c k" . avy-kill-whole-line)))

;; Transient interface for avy
(use-package casual-suite
  :pin melpa-stable
  :bind ("C-c j" . casual-avy-tmenu)
  :bind (:map dired-mode-map
              ("s-b" . casual-dired-tmenu)))

;; Aggressively use tree-sitter
(use-package treesit-auto
  :pin melpa-stable
  :custom
  (push '(go-mode . go-ts-mode) major-mode-remap-alist)
  (treesit-auto-install 'prompt))

;; Better window switching
(use-package ace-window
  :pin melpa-stable
  :bind ("C-c o" . ace-window))

;; Replace crappy native Emacs help
(use-package helpful
  :pin melpa-stable
  :bind (:map help-map
	      ("f" . helpful-callable)
	      ("v" . helpful-variable)
	      ("k" . helpful-key)
	      ))

(use-package diff-hl
  :pin melpa-stable
  :hook (magit-pre-refresh . diff-hl-magit-pre-refresh)
  :hook (magit-post-refresh . diff-hl-magit-pre-refresh)
  :after magit
  :config
  (global-diff-hl-mode)
  (diff-hl-flydiff-mode)
  (diff-hl-margin-mode)
  :custom
  (diff-hl-disable-on-remote t)
  (diff-hl-margin-symbols-alist
   '((insert . " ")
     (delete . " ")
     (change . " ")
     (unknown . "?")
     (ignored . "i"))))

;; Rich completion styles (you don't realize how much you miss these...)
(use-package orderless
  :pin melpa-stable
  :after prescient
  :custom
  (orderless-matching-styles '(orderless-literal
                               orderless-prefixes
                               orderless-initialism
                               orderless-regexp))
  (completion-styles '(prescient orderless basic partial-completion emacs22 flex initials shorthand))
  (completion-category-overrides '((file (styles basic partial-completion)))))

;;; Programming stuff

(use-package project
  :pin gnu
  :bind ("C-c F" . #'project-switch-project)
  :config
  (defun pt/recentf-in-project ()
  "As `recentf', but filtering based on the current project root."
  (interactive)
  (let* ((proj (project-current))
         (root (if proj (project-root proj) (user-error "Not in a project"))))
    (cl-flet ((ok (fpath) (string-prefix-p root fpath)))
      (find-file (completing-read "Find recent file:" recentf-list #'ok)))))
  :custom
  ;; This is one of my favorite things: you can customize
  ;; the options shown upon switching projects.
  (project-switch-commands
   '((project-find-file "Find file")
     (magit-project-status "Magit" ?g)
     (deadgrep "Grep" ?h)
     (project-dired "Dired" ?d)
     (pt/recentf-in-project "Recently opened" ?r)
     ))
  (compilation-always-kill t)
  (project-vc-merge-submodules nil))

;; LSP
(use-package eglot
  :pin manual
  :hook (rust-mode . eglot-ensure)
  ; :hook (before-save . eglot-format-buffer)
  :bind (:map eglot-mode-map
              ("C-c c" . eglot-code-actions)
              ("C-c a r" . eglot-rename))
  :bind (("s-r" . xref-find-references)
         ("s-f" . xref-find-definitions)
         ("s-i" . xref-find-implementations)))

(use-package consult-eglot
  :pin melpa
  :after consult
  :bind ("s-t" . consult-eglot-symbols))

(use-package flymake
  :pin manual
  :hook (rust-mode . flymake-mode)
  :hook (sh-mode . flymake-mode)
  :custom
  (flymake-show-diagnostics-at-end-of-line t))

(use-package rust-mode
  :pin melpa-stable
  :custom (rust-format-on-save))

;; May not be necessary anymore, I can't tell
(use-package exec-path-from-shell
  :pin melpa-stable
  :config
  (exec-path-from-shell-initialize))

;; Makefile targeting via Consult
(use-package makefile-executor
  :pin melpa
  :bind ("C-c M" . makefile-executor-execute-project-target))

;; Necessary for shell stuff to work right
(use-package direnv
  :pin melpa-stable
  :config (direnv-mode)
  :custom (direnv-always-show-summary nil))

;; GitHub Codespaces
(use-package codespaces
  :pin melpa
  :config
  (codespaces-setup)
  (push 'tramp-own-remote-path tramp-remote-path)  
  :custom
  (vc-handled-backends '(Git))
  (tramp-ssh-controlmaster-options ""))

(use-package protobuf-mode :pin melpa-stable)
(use-package go-mode :pin melpa-stable
  :hook (go-mode . eglot-ensure))
(use-package terraform-mode :pin melpa-stable)
(use-package dockerfile-mode :pin melpa-stable)
(use-package markdown-mode :pin melpa-stable)
(use-package yaml-mode :pin melpa-stable)

(use-package yaml-imenu
  :pin melpa-stable
  :after yaml-mode
  :config (yaml-imenu-enable))

(use-package flymake-yamllint
  :pin melpa-stable
  :hook (yaml-mode . flymake-mode)
  :hook (yaml-mode . flymake-yamllint-setup))

;; Org
(use-package org
  :pin manual
  :custom
  (org-special-ctrl-a t)
  (org-src-ask-before-returning-to-edit-buffer nil)
  (org-src-window-setup 'current-window))

(use-package htmlize
  :pin melpa-stable)

;; Cobble-yourself-a-modal-editor. Works better than the giant hack
;; that is devil-mode. However, I do use the comma key as the leader
;; key, so there needs to be a little custom timer code so that
;; modalka can imitate how Devil treats the leader key when typing
;; a space after a comma.
(use-package modalka
  :pin melpa-stable
  :after cape
  :hook (prog-mode . modalka-mode)
  :hook (read-only-mode . modalka-mode)
  :hook (after-init . modalka-mode)
  :bind ("," . modalka-mode)
  :bind (:map modalka-mode-map
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
    (ignore-errors (exit-recursive-edit))
    (modalka-mode -1)
    (keyboard-quit))
  (defvar pt/last-hit-comma-at nil)
  (defun pt/modalka-advice (&optional _)
    (setq pt/last-hit-comma-at (current-time)))
  (defun time-since-modalka-last-invoked ()
    (time-subtract (current-time) (or pt/last-hit-comma-at (current-time))))
  (advice-add 'modalka-mode :before #'pt/modalka-advice)
  (defun pt/modalka-comma ()
    (interactive)
    (let ((delta (time-since-modalka-last-invoked)))
      (when (< (time-to-seconds delta) 2) (insert ","))
      (modalka-mode -1)))
  (defun pt/cape-modalka ()
    (interactive)
    (modalka-mode -1)
    ;; Way uglier than it should be.
    (setq unread-command-events
      (mapcar (lambda (e) `(t . ,e))
              (listify-key-sequence (kbd "M-/")))))
  (defun pt/modalka-enter ()
    (interactive)
    (newline-and-indent)
    (modalka-mode -1))
  (defun pt/modalka-space ()
    (interactive)
    (let ((delta (time-since-modalka-last-invoked)))
      (when (< (time-to-seconds delta) 2) (insert ", "))
      (modalka-mode -1)))
  ;; The incongruities in the following reflect ~20 years of
  ;; brain-breakage induced by Emacs eybindings
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
  (modalka-define-kbd "`" "C-c `")
  (modalka-define-kbd "!" "M-&")) ; shell-command

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ignored-local-variable-values '((eval auto-save-visited-mode t)))
 '(package-selected-packages
   '(ace-window breadcrumb cape casual-suite codespaces consult-eglot corfu-prescient deadgrep detached diff-hl direnv dockerfile-mode
                doom-modeline eat embark-consult exec-path-from-shell expand-region flymake-yamllint go-mode haki-theme helpful htmlize
                indent-bars magit makefile-executor marginalia markdown-mode modalka nerd-icons-completion nerd-icons-corfu
                nerd-icons-dired nordic-night-theme orderless protobuf-mode rainbow-delimiters rust-mode terraform-mode
                timu-spacegrey-theme treesit-auto try unfill vc-use-package vertico-prescient visual-regexp vundo yaml-imenu))
 '(package-vc-selected-packages
   '((indent-bars :vc-backend Git :url "https://github.com/jdtsmith/indent-bars")
     (vc-use-package :vc-backend Git :url "https://github.com/slotThe/vc-use-package")
     (sideline-eglot :url "https://github.com/emacs-sideline/sideline-eglot.git"))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
