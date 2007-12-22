(defun replace-all (from to str)
  "Replace all instances of FROM with TO in STR, and return the
result"
  (while (string-match from str)
    (setq str (replace-match to t t str)))
  str)

(defmacro indenting-changes (&rest body)
  "Execute BODY and then indent any insertions made at point"
  `(let ((indent-region-start (point)))
       ,@body
       (indent-region indent-region-start (point) nil)
       (indent-according-to-mode)))

(defun beginning-of-line-dwim ()
  "Execute `beginning-of-line-text', or `beginning-of-line' if point
is already at the beginning of the text."
  (interactive)
  (let ((pt (point)))
        (beginning-of-line-text)
        (if (= pt (point))
                (beginning-of-line))))

(defun indent-buffer ()
  (interactive)
  (indent-region (point-min) (point-max) nil))

;;Improved clipboard interaction -- before a new kill,
;;check the clipboard, and if there's something new on it,
;;put it in the kill ring
(setq last-clipboard nil)

(defadvice kill-new (before kill-new-save-clipboard)
  (when (and (boundp 'x-select-enable-clipboard)
             x-select-enable-clipboard
             interprogram-paste-function
             (functionp interprogram-paste-function))
    (let ((clipboard (funcall interprogram-paste-function)))
      (when (and clipboard
                 (not (string= clipboard last-clipboard)))
        (setq last-clipboard clipboard)
        (kill-new clipboard)))))

(ad-activate 'kill-new)

(defun increment-number-at-point (&optional amount)
  "Increment the number under point by `amount'"
  (interactive "p")
  (let ((num (number-at-point)))
    (when (numberp num)
      (let ((newnum (+ num amount))
            (p (point)))
        (save-excursion
          (skip-chars-backward "-.0123456789")
          (delete-region (point) (+ (point) (length (number-to-string num))))
          (insert (number-to-string newnum)))
        (goto-char p)))))

(defun decrement-number-at-point (&optional amount)
  (interactive "p")
  "Decrement the number under point by `amount'"
  (increment-number-at-point (- (abs amount))))

(provide 'utils)
