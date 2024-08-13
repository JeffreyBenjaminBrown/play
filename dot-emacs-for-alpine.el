
( defun broken-package-init
  ;; https://stackoverflow.com/a/31080940/916142
"This doesn't work, but if I execute the add-to-list commands manually I can then install most of the packages listed manually."
  (require 'package)
  ( add-to-list 'package-archives
    ("gnu" . "http://elpa.gnu.org/packages/"))
  ( add-to-list 'package-archives
    ("melpa" . "http://melpa.org/packages/"))
  ( add-to-list 'package-archives
    ("melpa-stable" . "http://stable.melpa.org/packages/")

  ; list the packages you want
  ( setq package-list '(
                        beacon
                        block-nav
                        ctrlf
                        goto-last-change
                        iflip
                        magit
                        mwim
                        org-roam
                        use-package
                        volatile-highlights
                        xclip
                        ) )

  ; activate all the packages
  (package-initialize)

  ; fetch the list of packages available
  (unless package-archive-contents
    (package-refresh-contents))

  ; install the missing packages
  (dolist (package package-list)
    (unless (package-installed-p package)
      (package-install package))))

(with-eval-after-load 'shell
  ;; https://github.com/CeleritasCelery/emacs-native-shell-complete
  (native-complete-setup-bash))

;; to avoid hearing beeps
(setq visible-bell t)

(global-auto-revert-mode t) ;; reload files when changed

(defadvice align-regexp
    ;; Prevent align-regexp from using tabs
    ;; https://stackoverflow.com/a/25164056/916142
    (around align-regexp-with-spaces activate)
  (let ((indent-tabs-mode nil))
    ad-do-it))

;; So that copy and paste works from Emacs-in-Bash to other apps.
(xclip-mode 1)

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

(global-set-key (kbd "C-x /") 'goto-last-change)

(beacon-mode) ;; temporarily highlight cursor after scroll
(require 'org) ;; so that the next line knows what org-mode-map is
(eval-after-load 'org
  (progn
    (setq org-fontify-done-headline nil)
      ;; prevents DONE headings from displaying in a special pink font that makes links invisible
    (define-key org-mode-map (kbd "C-c C-d")
      ;; disable because it conflicts with my assignment for smart-hungry-delete-forward-char
      nil)))

(volatile-highlights-mode t) ;; highlight kills, undos, etc.

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
	 ("s" "stale" plain "%?"
          :if-new (file+head "stale/${slug}.org"
                             "#+title: ${title}\n")
          :unnarrowed t)
	 ("o" "ofiscal" plain "%?"
          :if-new (file+head "ofiscal/${slug}.org"
                             "#+title: ${title}\n")
          :unnarrowed t)
	 ))


;; kill-region should have no effect if the region is not active
(defvar mark-even-if-inactive nil)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(iflipb-ignore-buffers '("()")) ;; ignores no buffers
'(org-adapt-indentation t)
 '(org-cycle-hide-block-startup t)
 '(org-edit-src-content-indentation 0)
 '(org-fontify-done-headline nil)
 '(org-id-link-to-org-use-id t)
 '(org-roam-db-autosync-mode t)
 '(org-roam-directory "/home/jeff/org-roam")
 '(org-src-window-setup 'current-window) ;; This way `C-c '` (org-edit-special) in org-mode on a code block opens the code-edit window full-screen rather than splitting the frame.
 '(org-startup-folded t)
 '(org-todo-keywords '((sequence "TODO" "BLOCKED" "ONGOING" "DONE")))
 '(package-archives
   '(("gnu" . "http://elpa.gnu.org/packages/")
     ("melpa" . "http://melpa.org/packages/")
     ("melpa-stable" . "http://stable.melpa.org/packages/"))))

;; word wrap when starting org-mode
(add-hook 'org-mode-hook 'toggle-truncate-lines)

(show-paren-mode 1) ;; show matching parens

(put 'narrow-to-region 'disabled nil)
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)
(put 'scroll-left 'disabled nil)

;; plucked from https://gitlab.haskell.org/ghc/ghc/-/wikis/emacs
(add-hook 'before-save-hook 'delete-trailing-whitespace)
(setq kill-whole-line t) ;; cursor at start => C-k kills the newline too
(column-number-mode 1)

(menu-bar-mode -1) ;; Whether to show it. (t for true, -1 for nil.)
