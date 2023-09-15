;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(require 'use-package)
(package-initialize)

(with-eval-after-load 'shell
  ;; https://github.com/CeleritasCelery/emacs-native-shell-complete
  (native-complete-setup-bash))

;; I probably don't need this but it seems harmless.
(setq tab-stop-list '(2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38 40 42 44 46 48 5 0 52 54 56 58 60 62 64 66 68 70 72 74 76 78 80 82 84 86 88 90 92 94 96 98 100))

;; to avoid hearing beeps
(setq visible-bell t)

;; Indicate hidden text with " ⬎" instead of an ellipsis.
;; Other likely candidates:
;; ‣ ⁕ ↷ ↝ → ⇀ ⇢ ⇾ ⋱ 〉 ► ▻ ➝ ➛ ⟝ ⟶ ⫎ ⬎ ✳
;; Source; Reddit user xtajv
;;   https://www.reddit.com/r/emacs/comments/8r3x9w/can_i_change_what_chars_folded_text_is_displayed/
(set-display-table-slot standard-display-table
                        'selective-display (string-to-vector " ⬎"))

(add-to-invisibility-spec '(jbb-fold . t))
  ;; Has this effect:
  ;; If the 'invisible property of an overlay is set to 'jbb-fold,
  ;; the "invisible" text will be rendered with "⬎".
  ;; (Search this text for ⬎ to see why it's not an ellipsis, the default.)
  ;; Had I instead written `(add-to-invisibility-spec 'jbb-fold),
  ;; nothing would be shown to indicate the hidden text.
  ;; Details: https://www.gnu.org/software/emacs/manual/html_node/elisp/Managing-Overlays.html

(add-to-list 'auto-mode-alist '("\\.nix\\'" . nix-mode))
(add-to-list 'auto-mode-alist '("Makefile" . makefile-mode))

(global-auto-revert-mode t) ;; reload files when changed

(add-hook 'erlang-mode-hook
	  (lambda ()
	    (setq erlang-indent-level 2)))


;; ;; ;; Other stuff ;; ;; ;;

;; Prevent align-regexp from using tabs
;; https://stackoverflow.com/a/25164056/916142
(defadvice align-regexp (around align-regexp-with-spaces activate)
  (let ((indent-tabs-mode nil))
    ad-do-it))

;; So that copy and paste works from Emacs-in-Bash to other apps.
(xclip-mode 1)

(add-hook 'go-mode-hook
          (lambda ()
            (setq tab-width 2)
            (setq indent-tabs-mode nil)))

;; PureScript
(require 'psc-ide)
(add-hook 'purescript-mode-hook
  (lambda ()
    (psc-ide-mode)
    (company-mode)
    (flycheck-mode)
    (turn-on-purescript-indentation)))

;; Gleam, a language like Erlang with static types
;; (load-file "~/.emacs.d/elisp/gleam-mode/gleam-mode.el")
;; (require 'gleam-mode)
;; (add-to-list 'auto-mode-alist '("\\.gleam$" . gleam-mode))

;; no tabs
(add-hook 'python-mode-hook
          (lambda ()
            (setq-default indent-tabs-mode nil)
            (setq tab-width 2)
            (setq python-indent 2)
            (setq python-indent-offset 2)))

;; Coconut is like, interporable with, and better than Python.
(load-file "~/.emacs.d/elisp/coconut-mode/coconut-mode.el")

;; mwim
(global-set-key (kbd "C-a") 'mwim-beginning)
(global-set-key (kbd "C-e") 'mwim-end)

;; block-nav
(setq block-nav-center-after-scroll nil)
(setq block-nav-move-skip-shallower nil)
(global-set-key (kbd "M-<down>") 'block-nav-next-block)
(global-set-key (kbd "M-<up>") 'block-nav-previous-block)
(global-set-key (kbd "M-<right>") 'block-nav-next-indentation-level)
(global-set-key (kbd "M-<left>") 'block-nav-previous-indentation-level)

;; iflipb: change buffers fast
(global-set-key (kbd "<C-tab>")         'iflipb-next-buffer)
(global-set-key (kbd "<C-iso-lefttab>") 'iflipb-previous-buffer)

;; Use `ibuffer` (good sorting, other commands) instead of `list-buffers`.
(global-set-key (kbd "C-x C-b") 'ibuffer)

;; neotree: a tree view for something like dired
(setq neo-theme 'ascii) ;; possibilities: classic ascii arrow icons nerd

;; rainbow brackets. Very customized, elsewhere in this file
;; (automatically created text,
;; via `M-x customize-group rainbow-delimiters-faces)
;;
;; To load it automatically in code:
;; (add-hook 'prog-mode-hook #'rainbow-delimiters-mode)

(global-set-key (kbd "C-x x C-b") 'persp-list-buffers)
  ;; Like all persp-mode shortcuts, this starts with `C-x x`.
  ;; Like `list-buffers`, it starts with `C-x` and ends with `C-b`.

(global-set-key (kbd "C-x /") 'goto-last-change)

(ctrlf-mode +1)

(global-set-key (kbd "M-o") 'ace-window)

(beacon-mode) ;; temporarily highlight cursor after scroll

(require 'js)
(eval-after-load 'js
  (setq js-indent-level 2))

(global-set-key (kbd "C-c <backspace>") 'smart-hungry-delete-backward-char)
(global-set-key (kbd "C-c C-d")         'smart-hungry-delete-forward-char)
(require 'org) ;; so that the next line knows what org-mode-map is
(eval-after-load 'org
  (progn
    (setq org-fontify-done-headline nil)
      ;; prevents DONE headings from displaying in a special pink font that makes links invisible
    (define-key org-mode-map (kbd "C-c C-d")
      ;; disable because it conflicts with my assignment for smart-hungry-delete-forward-char
      nil)))

(defun jbb-org-open-at-point ()
  (interactive) ;; _event is ignored
  (if ;; This if-else clause testing the major mode is basically unnecessary,
      ;; because `jbb-org-open-at-point`
      ;; will only be called via the shortcut defined next,
      ;; which is only available from org-mode.
      (equal "org-mode" (symbol-name major-mode))
      (progn (call-interactively 'org-open-at-point)
	     (delete-other-windows))
    (message ("jbb-org-open-at-point does nothing outside of org-mode."))
))

(eval-after-load "dired"
  ;; In dired-mode, this lets you use "F" to open all marked files.
  ;; (Mark them with "m" first, and unmark them with "u",
  ;; or unmark all of them with "U".)
  ;; Source:
  ;;   https://stackoverflow.com/a/1110487/916142
  '(progn
     (define-key dired-mode-map "F" 'my-dired-find-file)
     (defun my-dired-find-file (&optional arg)
       "Open each of the marked files, or the file under the point, or when prefix arg, the next N files "
       (interactive "P")
       (mapc 'find-file (dired-get-marked-files nil arg))
       )))

(define-key org-mode-map (kbd "C-c C-o")   'jbb-org-open-at-point)
( define-key ;; TODO : Why does this only work for slow clicks?
  org-mode-map [mouse-1] 'jbb-org-open-at-point)

;; volatile highlights: highlight kills, undos, etc.
(volatile-highlights-mode t)
;; TODO The above does not make vhl the default -- I still have to enable it
;; in every new buffer. Also the code below doesn't work --
;; I can evaluate it by hand (after evaluating the above line),
;; but it breaks the autoload process.
;; (vhl/define-extension 'undo-tree 'undo-tree-yank 'undo-tree-move)
;; (vhl/install-extension 'undo-tree)

(setq org-roam-db-location "~/org-roam/org-roam.db")
(use-package org-roam
  :ensure t
  :hook
  (after-init . org-roam-mode)
  :custom
  (org-roam-directory "~/org-roam") )
(setq org-roam-v2-ack t) ;; indicates I migrated

(org-roam-db-autosync-mode)

;; TODO: A lot of global-set-key commands in this file use the wrong syntax,
;; omitting the # symbol. This way works.
;; (So does the lambda expression way, but it's needlessly verbose.)
(global-set-key (kbd "C-c C-l") #'org-insert-link)
(global-set-key (kbd "C-c n l") #'org-store-link)
(setq org-id-link-to-org-use-id t) ;; make stored links refer to IDs
(global-set-key (kbd "C-c n f") #'org-roam-node-find)
(global-set-key (kbd "C-c n i") #'org-roam-node-insert) ;; insert a *link*
(global-set-key (kbd "C-c n d") #'org-roam-db-sync) ;; update the db
(global-set-key (kbd "C-c n b") #'org-roam-buffer-toggle) ;; show backlinks

(setq org-roam-capture-templates
      ;; These folder names are dumb, but to change them I would need
      ;; to change every link involving them.
      '( ("u" "public" plain "%?"
          :if-new (file+head "tech/${slug}.org"
                             "#+title: ${title}\n")
          :unnarrowed t)
	 ("r" "private" plain "%?"
          :if-new (file+head "pers/${slug}.org"
                             "#+title: ${title}\n")
          :unnarrowed t)
	 ("o" "ofiscal" plain "%?"
          :if-new (file+head "ofiscal/${slug}.org"
                             "#+title: ${title}\n")
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
   '("cf7ed2618df675fdd07e64d5c84b32031ec97a8f84bfd7cc997938ad8fa0799f" default))
 '(org-adapt-indentation t)
 '(org-cycle-hide-block-startup t)
 '(org-fontify-done-headline nil)
 '(org-id-link-to-org-use-id t)
 '(org-roam-db-autosync-mode t)
 '(org-roam-directory "/home/jeff/org-roam")
 '(org-startup-folded t)
 '(org-todo-keywords '((sequence "TODO" "BLOCKED" "ONGOING" "DONE")))
 '(package-archives
   '(("gnu" . "http://elpa.gnu.org/packages/")
     ("melpa" . "http://melpa.org/packages/")
     ("melpa-stable" . "http://stable.melpa.org/packages/")))
 '(package-selected-packages
   '(erlang org-roam undo-tree scala-mode python-mode org nix-mode markdown-mode magit intero hide-lines csv-mode auctex))
 '(warning-suppress-log-types '(((unlock-file)))))

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
 '(default ((t (:family "DejaVu Sans Mono" :foundry "PfEd" :slant normal :weight normal :height 300 :width normal))))
 '(ctrlf-highlight-active ((t (:inherit isearch :background "#00ff55" :distant-foreground "#550000" :foreground "#990000"))))
 '(org-level-1 ((t (:extend nil :foreground "#ff8888"))))
   ;; pink rather than red, which is dark
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
 '(org-level-9 ((t (:foreground "red"))))
 '(rainbow-delimiters-base-error-face ((t (:inherit rainbow-delimiters-base-face :background "Red" :foreground "White"))))
 '(rainbow-delimiters-depth-1-face ((t (:inherit rainbow-delimiters-base-face :background "Black" :foreground "White"))))
 '(rainbow-delimiters-depth-2-face ((t (:inherit rainbow-delimiters-base-face :background "white" :foreground "black"))))
 '(rainbow-delimiters-depth-3-face ((t (:inherit rainbow-delimiters-base-face :background "#000066" :foreground "White"))))
 '(rainbow-delimiters-depth-4-face ((t (:inherit rainbow-delimiters-base-face :background "#9999ff" :foreground "black"))))
 '(rainbow-delimiters-depth-5-face ((t (:inherit rainbow-delimiters-base-face :background "#003300" :foreground "white"))))
 '(rainbow-delimiters-depth-6-face ((t (:inherit rainbow-delimiters-base-face :background "#77ff77" :foreground "black"))))
 '(rainbow-delimiters-depth-7-face ((t (:inherit rainbow-delimiters-base-face :background "#884400" :foreground "white"))))
 '(rainbow-delimiters-depth-8-face ((t (:inherit rainbow-delimiters-base-face :background "#ffff66" :foreground "black"))))
 '(rainbow-delimiters-depth-9-face ((t (:inherit rainbow-delimiters-base-face :background "#550055" :foreground "#ffff33")))))

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

;; plucked from https://gitlab.haskell.org/ghc/ghc/-/wikis/emacs
(add-hook 'before-save-hook 'delete-trailing-whitespace)
(setq kill-whole-line t) ;; cursor at start => C-k kills the newline too
(column-number-mode 1)
(setq-default fill-column 80) ;; reformat a comment with M-q

(menu-bar-mode -1) ;; Whether to show it. (t for true, -1 for nil.)

(load-file ".emacs.d/functions.el")
