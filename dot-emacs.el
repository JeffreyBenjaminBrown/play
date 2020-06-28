;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(require 'use-package)
(package-initialize)

;; jbb macros
;;  How to store macros here:
;;    use F3, then F4 to record the macro
;;    M-x name-last-kbd-macro
;;    M-x insert-kbd-macro
;;    paste that code below
;;    maybe also give it a name (per examples below)
(global-set-key (kbd "C-c a") 'append-to-file)
(fset 'left-justify-line
   "\C-a\346\342\C-o\C-a\C-k")

(defun jbb-theme ()
  (interactive)
  (load-theme `manoj-dark
	      1) ) ;; Suppresses the request for confirmation.

(defun jbb-smsn-start ()
  (interactive)
  (org-roam-mode -1)
  (smsn-mode) )

(defun jbb-smsn-flatten-tree ()
  "Flattens the current tree view. Useful for deletion. PITFALL: Dangerous! If you push the graph after running this, you'll lose the structure of the tree."
  (interactive)
  (if (equal major-mode 'smsn-mode)
      (progn
	(y-or-n-p "Is this really a TREE?")
	(replace-regexp "^ *" "") ;; delete leading whitespace
	(jbb-divide-subtrees-and-leaves) )
    (message "This command only makes sense in smsn-mode.")
    ) )

(defun jbb-divide-subtrees-and-leaves ()
  "Puts the point between subtrees (above) and leaves (below). This is to call the user's attention to the fact that both exist.

PITFALL: If there are no leaves, the regex search will fail, and an error message will be thrown. It's harmless."
  (beginning-of-buffer)
  (sort-lines nil 1 (buffer-size) ) ;; now the leaves are last (+ comes before ·)
  (goto-char (point-min)) ;; go to beginning of buffer
  (search-forward-regexp "^· :[[:alnum:]]\\{16\\}: ") ;; put mark just before title
  (beginning-of-line)
  (insert "\nBEWARE! Above are (if anything) trees, not leaves.\n")
  (open-line 1)
  (previous-line)
  (recenter)
  )

(defun shorten-other-window ()
  "Expand current window to use a bit more than half of the other window's lines."
  (interactive)
  (enlarge-window (floor (* (window-height (next-window)) 0.45))))

(add-to-list 'auto-mode-alist '("\\.nix\\'" . nix-mode))

(global-auto-revert-mode t) ;; reload files when changed

;; no tabs
(add-hook 'python-mode-hook
          (lambda ()
            (setq-default indent-tabs-mode nil)
            (setq tab-width 2)
            (setq python-indent 2)
            (setq python-indent-offset 2)))

;; org-roam
(use-package org-roam
  :hook
  (after-init . org-roam-mode)
  :custom
  (org-roam-directory
   "/org-roam") ;; for the roam db
  :bind (:map org-roam-mode-map
          ( ;; ("C-c n l" . org-roam)
            ;; ("C-c n g" . org-roam-show-graph)
	    ("C-c n l" . org-roam-store-link)
            ("C-c n f" . org-roam-find-file)
            ("C-c n b" . org-roam-buffer-toggle-display)
            ("C-c n c" . org-roam-db-build-cache) )
          :map org-mode-map
          ( ("C-c n i" . org-roam-insert))))

(setq org-roam-capture-templates
      ;; These folder names are dumb, but to change them I would need
      ;; to change every link involving them.
      '( ( "u" "public" plain
	   (function org-roam--capture-get-point)
           "%?"
           :file-name "tech/%<%Y%m%d%H%M%S>-${slug}"
           :head "#+title: ${title}\n"
           :unnarrowed t)

         ( "r" "private" plain
           (function org-roam--capture-get-point)
           "%?"
           :file-name "pers/%<%Y%m%d%H%M%S>-${slug}"
           :head "#+title: ${title}\n"
           :unnarrowed t)

         ( "o" "ofiscal" plain
	   (function org-roam--capture-get-point)
           "%?"
           :file-name "ofiscal/%<%Y%m%d%H%M%S>-${slug}"
           :head "#+title: ${title}\n"
           :unnarrowed t)
         ))

;; makes debugging easier. josh suggests
  (add-hook 'after-init-hook '(lambda () (setq debug-on-error t)))

;; kill-region should have no effect if the region is not active
  (defvar mark-even-if-inactive nil)

;; Semantic Synchrony
  ;; where is the server?
    ;; (defvar smsn-server-host "fortytwo.net") ;; online
  (defvar smsn-server-host "127.0.0.1") ;; local
  (defvar smsn-server-port 8183) ;; 8182 is default
  (defvar smsn-server-protocol "websocket") ;; websocket is default
  (defvar smsn-default-vcs-file "/mnt/smsn-data/vcs") ;; ought to be default
  ;; (defvar smsn-default-freeplane-file "/mnt/smsn-data/it.mm") ;; ought to be default
  (let ((default-directory "~/.emacs.d/elisp/")) ;; Weird scope!
    (normal-top-level-add-subdirs-to-load-path))
  (require 'smsn-mode)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("cf7ed2618df675fdd07e64d5c84b32031ec97a8f84bfd7cc997938ad8fa0799f" default)))
 '(org-roam-directory "/home/jeff/org-roam")
 '(package-archives
   (quote
    (("gnu" . "http://elpa.gnu.org/packages/")
     ("melpa" . "http://melpa.org/packages/")
     ("melpa-stable" . "http://stable.melpa.org/packages/"))))
 '(package-selected-packages
   (quote
    (org-roam undo-tree scala-mode python-mode org nix-mode markdown-mode magit intero hide-lines csv-mode auctex))))

;; org-mode colors
;; find colors with `M-x list-colors-display`
(custom-theme-set-faces 'user
                        `(org-level-1 ((t (:foreground "red")))))
(custom-theme-set-faces 'user
                        `(org-level-2 ((t (:foreground "orange")))))
(custom-theme-set-faces 'user
                        `(org-level-3 ((t (:foreground "yellow")))))
(custom-theme-set-faces 'user
                        `(org-level-4 ((t (:foreground "green")))))
(custom-theme-set-faces 'user
                        `(org-level-5 ((t (:foreground "cyan")))))
(custom-theme-set-faces 'user
                        `(org-level-6 ((t (:foreground "blue")))))
(custom-theme-set-faces 'user
                        `(org-level-7 ((t (:foreground "purple")))))
(custom-theme-set-faces 'user
                        `(org-level-8 ((t (:foreground "red")))))
(custom-theme-set-faces 'user
                        `(org-level-9 ((t (:foreground "red")))))
(custom-theme-set-faces 'user
                        `(org-level-10 ((t (:foreground "orange")))))
(custom-theme-set-faces 'user
                        `(org-level-11 ((t (:foreground "yellow")))))
(custom-theme-set-faces 'user
                        `(org-level-12 ((t (:foreground "green")))))
(custom-theme-set-faces 'user
                        `(org-level-13 ((t (:foreground "cyan")))))
(custom-theme-set-faces 'user
                        `(org-level-14 ((t (:foreground "blue")))))
(custom-theme-set-faces 'user
                        `(org-level-15 ((t (:foreground "purple")))))
(custom-theme-set-faces 'user
                        `(org-level-16 ((t (:foreground "red")))))

;; word wrap when starting org-mode
(add-hook 'org-mode-hook 'toggle-truncate-lines)

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
 '(default ((t (:family "DejaVu Sans Mono" :foundry "PfEd" :slant normal :weight normal :height 220 :width normal))))
 '(org-level-1 ((t (:foreground "red"))))
 '(org-level-10 ((t (:foreground "orange"))))
 '(org-level-11 ((t (:foreground "yellow"))))
 '(org-level-12 ((t (:foreground "green"))))
 '(org-level-13 ((t (:foreground "cyan"))))
 '(org-level-14 ((t (:foreground "blue"))))
 '(org-level-15 ((t (:foreground "purple"))))
 '(org-level-16 ((t (:foreground "red"))))
 '(org-level-2 ((t (:foreground "orange"))))
 '(org-level-3 ((t (:foreground "yellow"))))
 '(org-level-4 ((t (:foreground "green"))))
 '(org-level-5 ((t (:foreground "cyan"))))
 '(org-level-6 ((t (:foreground "blue"))))
 '(org-level-7 ((t (:foreground "purple"))))
 '(org-level-8 ((t (:foreground "red"))))
 '(org-level-9 ((t (:foreground "red")))))



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

;;(add-to-list 'load-path "/usr/local/mercury-14.01.1/lib/mercury/elisp")
;;(autoload 'mdb "gud" "Invoke the Mercury debugger" t)

;; Intero, the Haskell IDE: http://chrisdone.github.io/intero/
;; (add-hook 'haskell-mode-hook 'intero-mode)

;; elpy, the emacs python environment
;;(setq elpy-rpc-python-command "python3")
;;(elpy-enable)

;; exec-path-from-shell, which package makes Emacs's PATH match shell's
;;(when (memq window-system '(mac ns x))
;;  (exec-path-from-shell-initialize))
