File Edit Options Buffers Tools Emacs-Lisp Help
(require 'use-package)
(package-initialize)

(custom-set-variables
 '(package-archives
   '(("gnu" . "http://elpa.gnu.org/packages/")
     ("melpa" . "http://melpa.org/packages/")
     ("melpa-stable" . "http://stable.melpa.org/packages/"))))

;; Prevent align-regexp from using tabs
;; https://stackoverflow.com/a/25164056/916142
(defadvice align-regexp (around align-regexp-with-spaces activate)
  (let ((indent-tabs-mode nil))
    ad-do-it))

(global-auto-revert-mode t) ;; reload files when changed

(defvar mark-even-if-inactive nil)

(global-set-key (kbd "C-x /") 'goto-last-change)

(put 'narrow-to-region 'disabled nil)
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)
(put 'scroll-left 'disabled nil)

(menu-bar-mode -1) ;; Whether to show it. (t for true, -1 for nil.)
