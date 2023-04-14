;; `init.el`
;;   Runs at startup. Defines most configuration options.

(defun configure-packages ()
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
    :config (load-theme 'gruber-darker t))
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
    :config (add-hook 'company-mode-hook
		      (lambda () (company-posframe-mode 1))))
  ;; `flycheck-mode` error checking
  (use-package flycheck
    :ensure t
    :pin melpa)
  ;; `lsp-mode` language server protocol support
  (use-package lsp-mode
    :ensure t
    :pin melpa
    :after (company flycheck)
    :custom (lsp-enable-snippet nil))
  ;; `rustic-mode` Rust language support
  (use-package rustic
    :ensure t
    :pin melpa
    :after (lsp-mode)
    :custom (rustic-analyzer-command '("rustup" "run" "stable" "rust-analyzer"))))

(defun configure-miscellaneous ()
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
  ;; Silence error bells - they're annoying
  (setq-default ring-bell-function 'ignore))

(defun configure-text-mode ()
  (add-hook
   'text-mode-hook
   (lambda ()
     (indent-tabs-mode -1)
     (visual-line-mode 1))))

;; Startup process
(configure-miscellaneous)
(configure-text-mode)
(configure-packages)
