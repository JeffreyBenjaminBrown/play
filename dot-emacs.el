; jbb-custom macros

;;  How to store macros here:
;;    use F3, then F4 to record the macro
;;    M-x name-last-kbd-macro
;;    M-x insert-kbd-macro
;;    paste that code below
;;    maybe also give it a name (per examples below)
(defun shorten-other-window ()
  "Expand current window to use a bit more than half of the other window's lines."
  (interactive)
  (enlarge-window (floor (* (window-height (next-window)) 0.55))))

;; add-to-list 'auto-mode-alist '("\\.curry\\'" . haskell-mode))

;; (load-file "~/.emacs.d/elisp/coconut-mode.el")

;; (global-auto-revert-mode t) ;; reload files when changed

;; no tabs
(setq-default indent-tabs-mode nil)
(setq tab-width 2)
(setq python-indent 2)

;; use Prolog not Perl in .pl files
(add-to-list 'auto-mode-alist '("\\.\\(pl\\|pro\\|lgt\\)" . prolog-mode))

;; jbb macros
(global-set-key (kbd "C-c a") 'append-to-file)
(fset 'left-justify-line
   "\C-a\346\342\C-o\C-a\C-k")

;; makes debugging easier. josh suggests
  (add-hook 'after-init-hook '(lambda () (setq debug-on-error t)))

;; kill-region should have no effect if the region is not activeo
  (defvar mark-even-if-inactive nil)

;;;; Semantic Synchrony
;;  ;; where is the server?
;;    ;; (defvar smsn-server-host "fortytwo.net") ;; online
;;    (defvar smsn-server-host "127.0.0.1") ;; local
;;  (defvar smsn-server-port 8182) ;; 8182 is default
;;  (defvar smsn-server-protocol "websocket") ;; websocket is default
;;  (defvar smsn-default-vcs-file "/mnt/smsn-data/vcs") ;; ought to be default
;;  (defvar smsn-default-freeplane-file "/mnt/smsn-data/it.mm") ;; ought to be default
;;  (let ((default-directory "~/.emacs.d/elisp/")) ;; Weird scope!
;;    (normal-top-level-add-subdirs-to-load-path))
;;  (require 'smsn-mode)

;; haskell
  ;; there's also haskell-emacs, installed via `M-x package-list-packages`
  ;; installing the haskell-mode package from within emacs
    ;; required me to then add this
  (add-to-list 'load-path "~/.emacs.d/elpa/haskell-mode-16.1")

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("8b82aa6c511e289ed6868ae9c082b04844968be6ce2eef62c3c899b2b1038eb4" default))
 '(haskell-process-path-stack "/home/jeff/code/Tidal")
 '(haskell-process-type 'stack-ghci)
 '(package-archives
   '(("gnu" . "http://elpa.gnu.org/packages/")
     ("melpa-stable" . "http://stable.melpa.org/packages/")))
 '(package-selected-packages
   '(groovy-mode intero discover-my-major discover yafolding find-file-in-repository rainbow-delimiters hide-lines idris-mode ac-haskell-process haskell-emacs-base ess haskell-emacs haskell-mode))
 '(send-mail-function 'mailclient-send-it))
    ;; per advice: https://mail.google.com/mail/u/0/#inbox/15fc2b4e97f194d2
  (require 'haskell-mode)
  (require 'package)  ;; (following https://github.com/haskell/haskell-mode readme)

;; tidal
  (add-to-list 'load-path "~/code/Tidal")
  (add-to-list 'load-path "~/code/git_play/tidal/emacs")
  (require 'tidal)
   ;; doesn't seem to help

;; custom, jbb
  (show-paren-mode 1)
  (tool-bar-mode -1) ;; hide some icons I never use
  ;; fonts, colors
    (add-to-list 'default-frame-alist '(background-color . "#eeeeee"))
    (set-face-attribute 'region nil :background "#ccc")
    (load-theme 'manoj-dark)

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "DejaVu Sans Mono" :foundry "PfEd" :slant normal :weight normal :height 220 :width normal)))))



;; from Stevey Egge: https://sites.google.com/site/steveyegge2/my-dot-emacs-file
(defun rename-file-and-buffer (new-name)
 "Renames both current buffer and file it's visiting to NEW-NAME." (interactive "sNew name: ")
 (let ((name (buffer-name))
	(filename (buffer-file-name)))
 (if (not filename)
	(message "Buffer '%s' is not visiting a file!" name)
 (if (get-buffer new-name)
	 (message "A buffer named '%s' already exists!" new-name)
	(progn 	 (rename-file filename new-name 1) 	 (rename-buffer new-name) 	 (set-visited-file-name new-name) 	 (set-buffer-modified-p nil))))))

(defun rename-file-and-buffer (new-name)
 "Renames both current buffer and file it's visiting to NEW-NAME." (interactive "sNew name: ")
 (let ((name (buffer-name))
	(filename (buffer-file-name)))
 (if (not filename)
	(message "Buffer '%s' is not visiting a file!" name)
 (if (get-buffer new-name)
	 (message "A buffer named '%s' already exists!" new-name)
	(progn 	 (rename-file filename new-name 1) 	 (rename-buffer new-name) 	 (set-visited-file-name new-name) 	 (set-buffer-modified-p nil)))))) ;;
;; Never understood why Emacs doesn't have this function, either.
;;
(defun move-buffer-file (dir)
 "Moves both current buffer and file it's visiting to DIR." (interactive "DNew directory: ")
 (let* ((name (buffer-name))
	 (filename (buffer-file-name))
	 (dir
	 (if (string-match dir "\\(?:/\\|\\\\)$")
	 (substring dir 0 -1) dir))
	 (newname (concat dir "/" name)))
 (if (not filename)
	(message "Buffer '%s' is not visiting a file!" name)
 (progn 	(copy-file filename newname 1) 	(delete-file filename) 	(set-visited-file-name newname)))))
(put 'narrow-to-region 'disabled nil)
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)
(put 'scroll-left 'disabled nil)

(add-to-list 'load-path "/usr/local/mercury-14.01.1/lib/mercury/elisp")
(autoload 'mdb "gud" "Invoke the Mercury debugger" t)

;; Intero, the Haskell IDE: http://chrisdone.github.io/intero/
;; (add-hook 'haskell-mode-hook 'intero-mode)

;; elpy, the emacs python environment
(setq elpy-rpc-python-command "python3")
(elpy-enable)

;; exec-path-from-shell, which package makes Emacs's PATH match shell's
(when (memq window-system '(mac ns x))
  (exec-path-from-shell-initialize))
