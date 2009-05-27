
;; My local elisp files
(add-to-list 'load-path "~/.emacs.d/elisp")

(mwheel-install)  ;(emacs21)
(setq gdb-many-windows "t")

;; Save emacs settings on exit
;; (desktop-save-mode 1)

(eval-after-load "sh-script" '(require 'sh-autoconf))
(add-to-list 'auto-mode-alist '("/configure\\.\\(ac\\|in\\)\\'" . sh-mode))
(add-to-list 'auto-mode-alist '("\\.m4$" . sh-mode))
(add-to-list 'auto-mode-alist '("\\.tex$" . latex-mode))
(add-to-list 'auto-mode-alist '("\\.jsp$" . html-mode))

(setq auto-mode-alist (append `(("\.h$" . c++-mode)) auto-mode-alist))
(setq auto-mode-alist (append `(("\.xmf$" . xml-mode)) auto-mode-alist))

(autoload 'matlab-mode "matlab" "Matlab Editing Mode" t)
(add-to-list 'auto-mode-alist '("\\.m$" . matlab-mode))
(setq matlab-indent-function t)
(setq matlab-shell-command "matlab")

;; Switch between windows just by Shift-arrow
;; (when (fboundp 'windmove-default-keybindings)
;;       (windmove-default-keybindings))
(windmove-default-keybindings 'meta)

;; Treat selected region as windows does. Delete it on write or by DEL.
(delete-selection-mode 1)

;; No splash screen
(setq inhibit-startup-message t)

;; Doxymacs stuff
(defun my-doxymacs-font-lock-hook ()
 (if (or (eq major-mode 'c-mode) (eq major-mode 'c++-mode))
   (doxymacs-font-lock)))
(add-hook 'font-lock-mode-hook 'my-doxymacs-font-lock-hook)
(require 'doxymacs)
(add-hook 'c-mode-common-hook 'doxymacs-mode)

(add-hook 'c++-mode-hook 'fp-c-mode-routine)
(add-hook 'c-mode-hook 'fp-c-mode-routine)
(defun fp-c-mode-routine ()
  (setq show-trailing-whitespace t)
  (setq rebox-default-style 245)
  (local-set-key "\M-r" 'rebox-comment))
(autoload 'rebox-comment "rebox" nil t)
(autoload 'rebox-region "rebox" nil t)
(autoload 'align-cols "align" "Align text in the region." t)
(column-number-mode 1)

(require 'git)
(require 'git-blame)
(require 'tabbar)
(require 'sin-mode)
(require 'filladapt)
(require 'add-log)
(require 'dirvars)
(require 'ppindent)
(require 'template)
(require 'jam-mode)
; (load "vtags")
(template-initialize)

;; in file ~/.Xresources put
;;
;; Emacs.Font: Monospace-8
;; Emacs.FontBackend: xft
;;
;; (if (>= emacs-major-version 23)
;;    (set-default-font "Monospace-8"))

;; C-q TAB   ... make a TAB
;; C-x h and use M-x untabify
(setq-default indent-tabs-mode nil)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; My own styles
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(c-add-style
 "sat"
 '((c-basic-offset . 2)
   (indent-tabs-mode nil)
   (c-comment-only-line-offset . (0 . 0))
   (c-offsets-alist . ((statement-block-intro . +)
                       (knr-argdecl-intro . 5)
                       (substatement-open . 0)
                       (substatement-label . 0)
                       (label . 0)
                       (statement-case-open . 0)
                       (statement-cont . +)
                       (inline-open . 0)
                       (arglist-intro . c-lineup-arglist-intro-after-paren)
                       (arglist-close . c-lineup-arglist)
                       (brace-list-open . 0)
                       ))
   ))

(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(add-log-keep-changes-together t)
 '(auto-compression-mode t nil (jka-compr))
 '(c-default-style (quote ((c-mode . "sat") (c++-mode . "sat") (java-mode . "java") (other . "gnu"))))
 '(case-fold-search t)
 '(compilation-scroll-output t)
 '(compile-command "make -j2 ")
 '(cvs-reuse-cvs-buffer (quote always))
 '(default-input-method "czech")
 '(doxymacs-blank-multiline-comment-template (quote ("/**" > n "* " p > n "*/" > n)))
 '(fill-column 79)
 '(filladapt-token-table (quote (("^" beginning-of-line) (">+" citation->) ("\\(\\w\\|[0-9]\\)[^'`\"< 	
]*>[ 	]*" supercite-citation) (";+" lisp-comment) ("#+" sh-comment) ("%+" postscript-comment) ("^[ 	]*\\(//\\|\\*\\)[^ 	]*" c++-comment) ("@c[ \\t]" texinfo-comment) ("@comment[ 	]" texinfo-comment) ("\\\\item[ 	]" bullet) ("[0-9]+\\.[ 	]" bullet) ("[0-9]+\\(\\.[0-9]+\\)+[ 	]" bullet) ("[A-Za-z]\\.[ 	]" bullet) ("(?[0-9]+)[ 	]" bullet) ("(?[A-Za-z])[ 	]" bullet) ("[0-9]+[A-Za-z]\\.[ 	]" bullet) ("(?[0-9]+[A-Za-z])[ 	]" bullet) ("[-~*+]+[ 	]" bullet) ("o[ 	]" bullet) ("[\\@]\\(param\\|throw\\|exception\\|addtogroup\\|defgroup\\)[ 	]*[A-Za-z_][A-Za-z_0-9]*[ 	]+" bullet) ("[\\@][A-Za-z_]+[ 	]*" bullet) ("[ 	]+" space) ("$" end-of-line))))
 '(gdb-delete-out-of-scope nil)
 '(gdb-show-main nil)
 '(gdb-speedbar-auto-raise t)
 '(gdb-use-separate-io-buffer t)
 '(global-font-lock-mode t nil (font-lock))
 '(idlwave-header-to-beginning-of-file nil)
 '(scroll-bar-mode (quote right))
 '(setq-default indent-tabs-mode)
 '(sh-indentation 2)
 '(show-paren-mode t)
 '(tabbar-cycle-scope (quote tabs))
 '(tabbar-mode t nil (tabbar))
 '(tool-bar-mode nil nil (tool-bar))
 '(transient-mark-mode t)
 '(user-full-name "Jan Paral")
 '(user-mail-address "jparal@gmail.com")
 '(vc-follow-symlinks nil))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Key mapping
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;(global-set-key (kbd "M-<return>") 'complete-tag)
(global-set-key (kbd "C-c ;") 'comment-or-uncomment-region) ;; Uncomment region
(global-set-key (kbd "M-p") 'ppindent-h) ;; Preprocessor indent
(global-set-key (kbd "C-x c") 'compile)        ;; Run compile cmd
;; (global-set-key (kbd "C-x C-l") 'goto-line)    ;; Go To line (M-g g)
(global-set-key (kbd "C-x C-b") 'bs-show)      ;; Buffer switch
(global-set-key (kbd "C-c q") 'filladapt-mode) ;; Enable fill-mode
(global-set-key (kbd "C-c a") 'align-cols) ;; Align columns
(global-set-key (kbd "<f1>") 'git-status)
(global-set-key (kbd "S-<f1>") 'svn-status)
(global-set-key (kbd "S-<f5>") 'gud-until)
(global-set-key (kbd "<f5>") 'gud-cont)
(global-set-key (kbd "<f6>") 'gud-run)
(global-set-key (kbd "<f7>") 'gdb-restore-windows)
(global-set-key (kbd "<f8>") 'gud-watch)
(global-set-key (kbd "S-<f8>") 'gud-print)
(global-set-key (kbd "<f9>") 'gud-break)
(global-set-key (kbd "C-<f9>") 'gud-tbreak)
(global-set-key (kbd "S-<f9>") 'gud-remove)
(global-set-key (kbd "<f10>") 'gud-next)
(global-set-key (kbd "S-<f10>") 'gud-finish)
(global-set-key (kbd "<f11>") 'gud-step)
(global-set-key (kbd "<f12>") 'gud-down)
(global-set-key (kbd "S-<f12>") 'gud-up)
(global-set-key (kbd "S-<left>") 'tabbar-backward)
(global-set-key (kbd "S-<right>") 'tabbar-forward)
(global-set-key (kbd "S-<up>") 'tabbar-backward-group)
(global-set-key (kbd "S-<down>") 'tabbar-forward-group)
(global-set-key (kbd "A-<left>") 'windmove-left)
(global-set-key (kbd "A-<right>") 'windmove-right)
(global-set-key (kbd "A-<up>") 'windmove-up)
(global-set-key (kbd "A-<down>") 'windmove-down)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; define the function to kill the characters from the cursor
;; to the beginning of the current line
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun backward-kill-line (arg)
  "Kill chars backward until encountering the end of a line."
  (interactive "p")
  (kill-line 0))
;; you may want to bind it to a different key
;; (global-set-key "\C-u" 'backward-kill-line)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Enable autoconf-mode for configure.(in|ac)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (autoload 'autoconf-mode "autoconf-mode"
;;   "Major mode for editing autoconf files." t)
;; (setq auto-mode-alist
;;       (cons '("\\.ac\\'\\|configure\\.in\\'" . autoconf-mode)
;; 	    auto-mode-alist))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Enable/Disable FlySpell for specific modes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(dolist (hook '(LaTeX-mode-hook))
  (add-hook hook (lambda () (flyspell-mode 1))))

(add-hook 'c-mode-hook          'flyspell-prog-mode 1)
(add-hook 'c++-mode-hook        'flyspell-prog-mode 1)
(add-hook 'cperl-mode-hook      'flyspell-prog-mode 1)
(add-hook 'autoconf-mode-hook   'flyspell-prog-mode 1)
(add-hook 'autotest-mode-hook   'flyspell-prog-mode 1)
(add-hook 'sh-mode-hook         'flyspell-prog-mode 1)
(add-hook 'makefile-mode-hook   'flyspell-prog-mode 1)
(add-hook 'emacs-lisp-mode-hook 'flyspell-prog-mode 1)
(add-hook 'todoo-mode-hook      'flyspell-prog-mode 1)

;(dolist (hook '(change-log-mode-hook log-edit-mode-hook))
;  (add-hook hook (lambda () (flyspell-mode -1))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Enable auto-fill-mode for comments in C mode and for specific modes as well
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-hook 'c-mode-common-hook
	  (lambda ()
	    (auto-fill-mode 1)
	    (turn-on-filladapt-mode)
	    (set (make-local-variable 'fill-nobreak-predicate)
		 (lambda ()
		   (not (eq (get-text-property (point) 'face)
			    'font-lock-comment-face))))))

(add-hook 'change-log-mode-hook 'turn-on-auto-fill)
(add-hook 'LaTeX-mode-hook 'turn-on-auto-fill)
(add-hook 'LaTeX-mode-hook 'turn-on-filladapt-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Check for shebang magic in file after save, make executable if found.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq my-shebang-patterns
      (list "^#!/usr/.*/perl\\(\\( \\)\\|\\( .+ \\)\\)-w *.*"
	    "^#!/usr/.*/sh"
	    "^#!/usr/.*/bash"
	    "^#!/bin/sh"
	    "^#!/bin/bash"))
(add-hook
 'after-save-hook
 (lambda ()
   (if (not (= (shell-command (concat "test -x " (buffer-file-name))) 0))
       (progn
	 ;; This puts message in *Message* twice, but minibuffer
	 ;; output looks better.
	 (message (concat "Wrote " (buffer-file-name)))
	 (save-excursion
	   (goto-char (point-min))
	   ;; Always checks every pattern even after
	   ;; match.  Inefficient but easy.
	   (dolist (my-shebang-pat my-shebang-patterns)
	     (if (looking-at my-shebang-pat)
		 (if (= (shell-command
			 (concat "chmod u+x " (buffer-file-name)))
			0)
		     (message (concat
			       "Wrote and made executable "
			       (buffer-file-name))))))))
     ;; This puts message in *Message* twice, but minibuffer output
     ;; looks better.
     (message (concat "Wrote " (buffer-file-name))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 )

(message ".emacs loaded")
