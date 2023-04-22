;;; splash-screen --- Summary
;;; Commentary:
;;;   Defines a custom splash screen which appears as the default
;;;   buffer on Emacs startup.

;;; Code:

;; Based largely on https://github.com/rougier/emacs-splash/blob/master/splash-screen.el
(defun display-splash-screen ()
  "Display the splash screen."
  (interactive)
  (let* ((splash-buffer (get-buffer-create "*splash*"))
	 (window-height (window-body-height nil))
	 (window-width (window-body-width nil))
	 (vertical-center-offset (- (/ window-height 2) 1)))
    (with-current-buffer splash-buffer
      (setq fill-column window-width)

      (erase-buffer)

      (insert-char ?\n vertical-center-offset)

      (insert (concat "Welcome to " (propertize "BROOKE'S AMAZING EMACS CONFIG!" 'face 'bold)))
      (center-line)
      (insert-char ?\n 1)

      (insert (concat (propertize "(C-c C-p) p"  'face 'font-lock-constant-face) " to open a project."))
      (center-line)

      (display-buffer-same-window splash-buffer nil))))

(defun kill-splash-screen ()
  "Kill the splash screen buffer if it exists."
  (interactive)
  (if (get-buffer "*splash*")
      (kill-buffer "*splash*")))

(provide 'splash-screen)
;;; splash-screen.el ends here
