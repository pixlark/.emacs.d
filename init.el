;;; init --- Summary
;;; Commentary:
;;;   Runs at startup.  Defines most configuration options.

;;; Code:

(defun configure-theme ()
  "Configure theme options."
  (set-face-attribute 'default nil :family "Source Code Pro" :height 128)
  (set-face-attribute 'fixed-pitch nil :family "Source Code Pro" :height 128))

(defun configure-miscellaneous ()
  "Configure miscellaneous options."
  ;; Put auto-generated customize code into `custom.el`.
  (setq-default custom-file "~/.emacs.d/custom.el")
  ;; Inihibit the startup splash screen
  (setq inhibit-startup-message t)
  ;; Disable some unnecessary GUI elements
  (when window-system
    (menu-bar-mode -1)
    (tool-bar-mode -1)
    (scroll-bar-mode -1))
  ;; Make it so that new buffers and files without extensions open in
  ;; `text-mode` rather than in `fundamental-mode`.
  (setq-default major-mode 'text-mode)
  ;; Add a command for opening our emacs configuration quickly.
  (defun edit-conf ()
    (interactive)
    (find-file "~/.emacs.d/init.el"))
  (global-set-key (kbd "C-c c") 'edit-conf)
  ;; Add a command for quickly viewing our keybinding notes.
  (defun view-keybinding-notes ()
    (interactive)
    (split-window-right)
    (find-file "~/.emacs.d/binding-notes.md"))
  (global-set-key (kbd "C-c k") 'view-keybinding-notes)
  ;; Silence error bells - they're annoying
  (setq-default ring-bell-function 'ignore)
  ;; Use unix-style line endings everywhere, even on Windows.
  (setq-default buffer-file-coding-system 'utf-8-unix)
  ;; Show trailing whitespace
  (setq-default show-trailing-whitespace t)
  ;; Never use tabs
  (setq-default indent-tabs-mode nil))

(defun configure-text-mode ()
  "Configuration for `text-mode`."
  (add-hook
   'text-mode-hook
   (lambda ()
     (indent-tabs-mode -1)
     (visual-line-mode 1))))

(defun configure-elisp-mode ()
  "Configuration for `elisp-mode`."
  (add-hook 'emacs-lisp-mode-hook
	    (lambda ()
	      (company-mode 1)
	      (flycheck-mode 1))))

(defun configure-xml-mode ()
  "Configuration for `xml-mode`."
  (setq-default nxml-child-indent 4)
  ;; File associations
  (add-to-list 'auto-mode-alist '("\\.xml\\'" . nxml-mode))
  (add-to-list 'auto-mode-alist '("\\.xaml\\'" . nxml-mode))
  (add-to-list 'auto-mode-alist '("\\.csproj\\'" . nxml-mode))
  (add-to-list 'auto-mode-alist '("\\.csproj.user\\'" . nxml-mode))
  (add-to-list 'auto-mode-alist '("\\.appxmanifest\\'" . nxml-mode))
  (add-to-list 'auto-mode-alist '("\\.manifest\\'" . nxml-mode)))

(defun configure-packages ()
  "Setup archives, load `use-package`, and define package dependencies."
  ;; Use the locally-installed package.el library. This comes with any
  ;; version of Emacs 24.1 or greater.
  (require 'package)
  ;; Add Melpa and Melpa Stable to our avilable package archives
  (add-to-list 'package-archives
	       '("melpa" . "https://melpa.org/packages/") t)
  (add-to-list 'package-archives
	       '("melpa-stable" . "https://stable.melpa.org/packages/") t)

  ;; Initialize use-package, which we use to define dependencies on
  ;; all of our external packages.
  (eval-when-compile
    (add-to-list 'load-path "~/.emacs.d/use-package")
    (require 'use-package))
  ;; `gruber-darker` theme
  (use-package gruber-darker-theme
    :ensure t
    :pin melpa
    :if window-system
    :config
    (load-theme 'gruber-darker t))
  ;; `company-mode` auto-completion
  (use-package company
    :ensure t
    :pin melpa
    :custom
    (company-idle-delay 0)
    (company-minimum-prefix-length 1)
    (company-selection-wrap-around t))
  ;; `company-posframe` makes company-mode rendering better
  ;; for non-terminal-based Emacs instances
  (use-package company-posframe
    :ensure t
    :pin melpa
    :if window-system
    :config (company-posframe-mode 1)
    :custom (company-posframe-quickhelp-delay 0))
  ;; `flycheck-mode` error checking
  (use-package flycheck
    :ensure t
    :pin melpa)
  ;; `lsp-mode` language server protocol support
  (use-package lsp-mode
    :ensure t
    :pin melpa
    :after (company flycheck)
    :custom
    (lsp-enable-snippet nil)
    (lsp-rust-analyzer-server-display-inlay-hints t)
    :config
    (add-hook 'lsp-rust-analyzer-inlay-hints-mode-hook
	      (lambda ()
		(set-face-attribute 'lsp-rust-analyzer-inlay-face nil :inherit 'font-lock-doc-face))))
  ;; `lsp-ui` adds some extra features to `lsp-mode`
  (use-package lsp-ui
    :ensure t
    :pin melpa
    :after (lsp-mode)
    :bind
    ("C-c d" . lsp-ui-doc-show)
    :custom
    (lsp-ui-sideline-delay 0)
    (lsp-ui-sideline-show-symbol t))
  ;; `rustic-mode` Rust language support
  (use-package rustic
    :ensure t
    :pin melpa
    :after (lsp-mode)
    :custom (rustic-analyzer-command '("rustup" "run" "stable" "rust-analyzer")))
  ;; `neotree` displays a directory tree listing
  (use-package neotree
    :demand t
    :ensure t
    :pin melpa
    :custom
    (neo-window-width 35)
    :bind
    ("C-c t" . neotree-toggle)
    :bind*
    ("C-c C-c" . neotree-copy-node))
  ;; `ripgrep` is a powerful search tool
  (use-package ripgrep
    :demand t
    :ensure t
    :pin melpa)
  ;; `projectile` is a project manager
  (use-package projectile
    :demand t
    :ensure t
    :pin melpa
    :after (neotree ripgrep)
    :custom
    (projectile-require-project-root t)
    (projectile-switch-project-action 'neotree-projectile-action)
    :config
    (projectile-global-mode 1)
    (add-hook 'projectile-after-switch-project-hook
	      (lambda ()
		(neotree-show)
		(require 'splash-screen)
		(kill-splash-screen)))
    :bind (:map projectile-mode-map
		("C-c C-p" . projectile-command-map))
    :bind* ("C-c C-p s s" . projectile-ripgrep))
  ;; `flycheck-projectile` can list all errors in the current project
  (use-package flycheck-projectile
    :demand t
    :pin manual
    :after (projectile flycheck)
    ;; Use my personal fork of `flycheck-projectile`
    :init
    (add-to-list 'load-path "~/.emacs.d/flycheck-projectile")
    :bind ("C-c e" . flycheck-projectile-list-errors))
  ;; `tree-sitter` is a modern syntax highlighting framework
  (use-package tree-sitter
    :ensure t
    :pin melpa)
  ;; `tree-sitter-langs` provide specific languages for `tree-sitter`
  (use-package tree-sitter-langs
    :ensure t
    :pin melpa
    :after tree-sitter)
  ;; `csharp-mode` provides syntax support for C#
  (use-package csharp-mode
    :ensure t
    :pin melpa
    :hook (csharp-mode . (lambda ()
			   (tree-sitter-hl-mode 1)
			   (lsp-mode 1)
			   (flycheck-mode 1)
			   (company-mode 1))))
  ;; `diredful` gives colors to dired
  (use-package diredful
    :ensure t
    :pin melpa
    :config (diredful-mode 1)))

(defun configure-personal ()
  "Configure our personal packages."
  (add-to-list 'load-path "~/.emacs.d/brooke")
  ;; Splash screen
  (require 'splash-screen)
  (add-hook 'window-setup-hook 'display-splash-screen)
  ;; Rexc mode
  (require 'rexc-mode)
  (tree-sitter-require 'rexc "~/.emacs.d/tree-sitter-rexc/build/Release/" "tree-sitter-rexc")
  (add-to-list tree-sitter-major-mode-language-alist '(rexc-mode . rexc)))

;; Startup process
(configure-theme)
(configure-miscellaneous)
(configure-text-mode)
(configure-elisp-mode)
(configure-xml-mode)
(configure-packages)
(configure-personal)

(provide 'init)
;;; init.el ends here
