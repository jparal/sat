;; *****************************************************************************
;;
;;  sin-mode.el
;;  Font-lock support for SIN files
;;
;;  Copyright (C) 2003, 2004, Rob Walker <rob@tenfoot.org.uk>
;;    http://www.tenfoot.org.uk/emacs/
;;  12 May 2004 - 0.3 - Fix keyword quoting, XEmacs support
;;  22 Mar 2003 - 0.2 - Autoload
;;  04 Mar 2003 - 0.1 - Added imenu support and basic indentation
;;
;;  Copyright (C) 2000, Eric Scouten
;;  Started Sat, 05 Aug 2000
;;
;; *****************************************************************************
;;
;;  This is free software; you can redistribute it and/or modify
;;  it under the terms of the GNU General Public License as published by
;;  the Free Software Foundation; either version 2, or (at your option)
;;  any later version.
;;
;;  sin-mode.el is distributed in the hope that it will be useful,
;;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;;  General Public License for more details.
;;
;;  You should have received a copy of the GNU General Public License
;;  along with GNU Emacs; see the file COPYING.  If not, write to the
;;  Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;;  Boston, MA 02111-1307, USA.
;;
;; *****************************************************************************
;;
;;  To add font-lock support for SIN files, simply add the line
;;  (require 'sin-mode) to your .emacs file. Make sure generic-mode.el
;;  is visible in your load-path as well.
;;
;; *****************************************************************************


;; Generic-mode is a meta-mode which can be used to define small modes
;; which provide basic comment and font-lock support. sin-mode depends on
;; this mode.

;; generic.el for GNU emacs, generic-mode.el for XEmacs
(if (string-match "XEmacs\\|Lucid" emacs-version)
    (require 'generic-mode)
  (require 'generic))

(defun sin-mode-quote-keywords (keywords)
  "Returns a list of expressions that match each element in KEYWORDS.
For generic-mode, each element is quoted. For generic, each element is unchanged."
  (if (featurep 'generic-mode)
      (mapcar 'regexp-quote keywords)
    keywords))

;;;###autoload
(define-generic-mode 'sin-mode

  ; SIN comments always start with '#'
  (list ?# )

  ; SAT keywords (defined later)
  nil

  ; Extra stuff to colorize
  (list

   ; SAT keywords
   (generic-make-keywords-list
    (list "font-lock-keyword-face-EXAMPLE")
    'font-lock-keyword-face)

   ; SAT built-in variables
   (generic-make-keywords-list
    (list
     "font-lock-constant-face-EXAMPLE")
    'font-lock-constant-face)

   ; SAT built-in targets
   (generic-make-keywords-list
    (list
     "font-lock-builtin-face-EXAMPLE")
    'font-lock-builtin-face)

   ; SAT built-in targets (warnings)
   (generic-make-keywords-list
    (list
     "font-lock-warning-face-EXAMPLE1" "font-lock-warning-face-EXAMPLE2")
    'font-lock-warning-face)

   ; Jambase rules
   (generic-make-keywords-list
    (sin-mode-quote-keywords
     (list
      "font-lock-function-name-face-EXAMPLE"))
    'font-lock-function-name-face)

   ; Jambase built-in targets
   (generic-make-keywords-list
    (list
     "font-lock-builtin-face-EXAMPLE1" "font-lock-builtin-face-EXAMPLE2")
    'font-lock-builtin-face)

   ; Jambase built-in variables
   (generic-make-keywords-list
    (sin-mode-quote-keywords
     (list
      "font-lock-function-name-face-EXAMPLE1"))
    'font-lock-function-name-face)

   ; Jam variable references $(foo)
   '("$(\\([^ :\\[()\t\r\n]+\\)[)\\[:]" 1 font-lock-variable-name-face))

  ; Apply this mode to all files *.sin
  (list "\\.sin\\'")

  ; Attach setup function so we can modify syntax table.
  (list 'sin-mode-setup-function)

  ; Brief description
  "Generic mode for SIN (Sat INput) configuration files of SAT package.")

(defun sin-mode-setup-function ()
  (modify-syntax-entry ?_ "w")
  (modify-syntax-entry ?. "w")
  (modify-syntax-entry ?/ "w")
  (modify-syntax-entry ?+ "w")
  (modify-syntax-entry ?# "<")
;;;   (modify-syntax-entry ?/ ". 124b")
;;;   (modify-syntax-entry ?* ". 23")
;;;   (modify-syntax-entry ?\n "> b")
  (modify-syntax-entry ?\n ">")
  (setq imenu-generic-expression
        '(("Rules" "^rule\\s-+\\([A-Za-z0-9_]+\\)" 1)
          ("Actions" "^actions\\s-+\\([A-Za-z0-9_]+\\)" 1)))
  (imenu-add-to-menubar "SIN")
  (make-local-variable 'indent-line-function)
  (setq indent-line-function 'sin-indent-line)
  (run-hooks 'sin-mode-hook)
  )

(defvar sin-mode-hook nil)

(defvar sin-indent-size 2
  "Amount to indent by in sin-mode")

(defvar sin-case-align-to-colon t
  "Whether to align case statements to the colons")

(defun sin-indent-line (&optional whole-exp)
  "Indent current line"
  (interactive)
  (let ((indent (sin-indent-level))
	(pos (- (point-max) (point))) beg)
    (beginning-of-line)
    (setq beg (point))
    (skip-chars-forward " \t")
    (if (zerop (- indent (current-column)))
	nil
      (delete-region beg (point))
      (indent-to indent))
    (if (> (- (point-max) pos) (point))
	(goto-char (- (point-max) pos)))
    ))

(defun sin-goto-block-start ()
  "Goto the start of the block containing point (or beginning of buffer if not
   in a block"
  (let ((l 1))
    (while (and (not (bobp)) (> l 0))
      (skip-chars-backward "^{}")
      (unless (bobp)
        (backward-char)
        (setq l (cond
                 ((eq (char-after) ?{) (1- l))
                 ((eq (char-after) ?}) (1+ l))
                 )))
      )
    (bobp))
  )

(defun sin-indent-level ()
  (save-excursion
    (let ((p (point))
          ind
          (is-block-start nil)
          (is-block-end nil)
          (is-case nil)
          (is-switch nil)
          switch-ind)
      ;; see what's on this line
      (beginning-of-line)
      (setq is-block-end (looking-at "^[^{\n]*}\\s-*$"))
      (setq is-block-start (looking-at ".*{\\s-*$"))
      (setq is-case (looking-at "\\s-*case.*:"))

      ;; goto start of current block (0 if at top level)
      (if (sin-goto-block-start)
          (setq ind 0)
        (setq ind (+ (current-indentation) sin-indent-size)))

      ;; increase indent in switch statements (not cases)
      (setq is-switch (re-search-backward "^\\s-*switch" (- (point) 100) t))
      (when (and is-switch (not (or is-block-end is-case)))
        (goto-char p)
        (setq ind (if (and sin-case-align-to-colon
                           (re-search-backward "^\\s-*case.*?\\(:\\)"))
                      (+ (- (match-beginning 1) (match-beginning 0))
                         sin-indent-size)
                    (+ ind sin-indent-size)))
        )

      ;; indentation of this line is sin-indent-size more than that of the
      ;; previous block
      (cond (is-block-start  ind)
            (is-block-end    (- ind sin-indent-size))
            (is-case         ind)
            (t               ind)
            )
      )))

(provide 'sin-mode)

;; sin-mode.el ends here
