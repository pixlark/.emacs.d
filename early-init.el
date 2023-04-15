;;; early-init --- Summary
;;; Commentary:
;;;   Runs earlier than `init.el` in the startup process.

;;; Code:

;; Maximize window immediately on startup
(defun early-configure-miscellaneous ()
  "Configure miscellaneous options.")

;; Early startup process
(early-configure-miscellaneous)

(provide 'early-init)
;;; early-init.el ends here
