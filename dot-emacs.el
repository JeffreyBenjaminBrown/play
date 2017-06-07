;; makes debugging easier. josh suggests
  (add-hook 'after-init-hook '(lambda () (setq debug-on-error t)))

;; Semantic Synchrony
  ;; where is the server?
    ;; (defvar smsn-server-host "fortytwo.net") ;; online
    (defvar smsn-server-host "127.0.0.1") ;; local
  (defvar smsn-server-port 8182) ;; 8182 is default
  (defvar smsn-server-protocol "websocket") ;; websocket is default
  (defvar smsn-default-vcs-file "/mnt/smsn-data/vcs") ;; ought to be default
  (defvar smsn-default-freeplane-file "/mnt/smsn-data/it.mm") ;; ought to be default
  (let ((default-directory "~/.emacs.d/elisp/")) ;; Weird scope!
    (normal-top-level-add-subdirs-to-load-path))
  (require 'smsn-mode)

;; haskell
  ;; installing the haskell-mode package from within emacs
  ;; required me to then add this
  (add-to-list 'load-path "~/.emacs.d/elpa/haskell-mode-16.1")
  (require 'haskell-mode)

;; tidal
  (add-to-list 'load-path "~/git_play/tidal/emacs")
  (require 'tidal)

;; custom, jbb
  ;; obsolete?
    ;;  (global-unset-key (kbd "C-r"))
    ;;  (global-set-key (kbd "C-r") 'isearch-backward)
      ;; bug: should be there already
  (show-paren-mode 1)
  (tool-bar-mode -1) ;; hide some icons I never use
  ;; fonts, colors
    (add-to-list 'default-frame-alist '(background-color . "#eeeeee"))  
    (set-face-attribute 'region nil :background "#ccc")
    (custom-set-faces
     ;; custom-set-faces was added by Custom.
     ;; If you edit it by hand, you could mess it up, so be careful.
     ;; Your init file should contain only one such instance.
     ;; If there is more than one, they won't work right.
     '(default ((t (:family "DejaVu Sans Mono"
			    :foundry "PfEd" :slant normal
			    :weight normal :height 200 :width normal)))))

;; for haskell-mode (following https://github.com/haskell/haskell-mode readme)
  (require 'package)

  (custom-set-variables
   ;; custom-set-variables was added by Custom.
   ;; If you edit it by hand, you could mess it up, so be careful.
   ;; Your init file should contain only one such instance.
   ;; If there is more than one, they won't work right.
   '(package-archives
     (quote
      (("gnu" . "http://elpa.gnu.org/packages/")
       ("melpa-stable" . "http://stable.melpa.org/packages/"))))
   '(package-selected-packages (quote (haskell-mode))))
    (package-initialize)
