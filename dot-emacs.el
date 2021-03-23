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
;; I think this says that if a text's "invisibility" property is set to
;; `my-fold`, then an ellipsis should be shown in its place.
;; https://stackoverflow.com/questions/63893154/in-emacs-whats-the-opposite-of-invisible-text/63895106#63895106
(add-to-invisibility-spec '(my-fold . t))

(defun insert-space-around-next-non-alphanum ()
  (interactive)
  (progn
    (search-forward-regexp "[^ a-zA-Z_0-9'\"]")
    (backward-char 1)
    (insert " ")
    (forward-char 1)
    (insert " ") ) )
(global-set-key (kbd "C-c SPC") (lambda () (interactive)
                                  (insert-space-around-next-non-alphanum)))

(defun fold (toHide) ;; folds given t.
  ;; TODO: Should fold given (), but doesn't.
  ;; So I use the `unfold` function for that.
  ;; TODO: It would be better if this showed an ellipsis to represent
  ;; folded text. Maybe on a separate line, so that it wouldn't be masked
  ;; by a comment preceding it.
  (interactive)
  (progn
    (back-to-indentation)
    (let ((nSpaces (current-column)))
      (move-end-of-line 1)
      (let ((startRegion (point)))
        (search-forward-regexp
         (concat "^ \\{0," (number-to-string nSpaces) "\\}[^ $]" ) )
        (move-beginning-of-line 1)
        (let ((i (get-text-property (point) 'invisible)))
          ;; TODO: rather than toHide below, I'd like to use (not i).
          ;; That way I would only need one function and keyboard-shortcut,
          ;; not two. But for some reason, if I do that it always hides.
          (backward-char 1)
          (let ((endRegion (point)))
            ( put-text-property
              ;; If the "invisible" property is any non-nil value,
              ;; the text is invisible. However, some non-nil values
              ;; (see, e.g., the definition of `my-fold` above)
              ;; cause "invisible" text to display as an ellipsis.
              startRegion endRegion 'invisible 'my-fold)
            (goto-char startRegion)
            ) ) ) ) ) )
(global-set-key (kbd "C-c h") (lambda () (interactive) (fold t)))

(defun unfold ()
  (interactive)
  (progn
    (let ((origin (point)))
      (move-end-of-line 1)
      (forward-char 1)
      (let ((end (point)))
        (while (and (invisible-p end) (< end (point-max)))
          (setq end (1+ end)))
        (put-text-property origin end 'invisible ())
        (goto-char origin)))))
(global-set-key (kbd "C-c s") (lambda () (interactive) (unfold)))

(defun jbb-retain-for-mystery-node ()
  "When I imported my freeplane notes into SmSn, some nodes were translated badly. They appear with titles like \"mus.mm\" or \"go.mm\" instead of what they contained in the freeplane data. When I find such a node, I am leaving it in place, and leaving some of its siblings and its parent in place too, but adding this label to the parent, so that I know why not to separate them."
  (interactive)
  (insert " \\ merged, retaining for mystery node"))

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
(add-to-list 'auto-mode-alist '("Makefile" . makefile-mode))

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
  :ensure t
  :hook
  (after-init . org-roam-mode)
  :custom
  (org-roam-directory "~/org-roam")
  :bind (:map org-roam-mode-map
              (("C-c n b" . org-roam) ;; opens the roam-buffer
               ("C-c n f" . org-roam-find-file)
               ;; ("C-c n g" . org-roam-graph))
               :map org-mode-map
               (("C-c n i" . org-roam-insert))
               (("C-c n I" . org-roam-insert-immediate))
               (("C-c n l" . org-store-link))
               (("C-c n h" . org-roam-create-note-from-headline))
               ;; (("C-c C-l" . org-insert-link))
               )))
(setq org-id-link-to-org-use-id t)

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

(defun org-roam-insert-dwim ()
  "Insert an org-roam link. If there is a region active, use it as name."
  (interactive)
  (push (if (region-active-p)
            (capitalize-dwim '(buffer-substring-no-properties
                               (region-beginning)
                               (region-end)))
          (thing-at-point 'symbol))
        regexp-history)
  (call-interactively 'org-roam-insert))

(defun org-roam-create-note-from-headline ()
  ;; by user 'telotortium' at the org-roam discourse:
  ;; https://org-roam.discourse.group/t/creating-an-org-roam-note-from-an-existing-headline/978
  "Create an Org-roam note from the current headline and jump to it.

  Normally, insert the headline’s title using the ’#title:’
  file-level property
  and delete the Org-mode headline. However, if the current headline has a
  Org-mode properties drawer already, keep the headline and don’t insert
  ‘#+title:'. Org-roam can extract the title from both kinds of notes,
  but using
  ‘#+title:’ is a bit cleaner for a short note, which Org-roam encourages."
  (interactive)
  (let ((title (nth 4 (org-heading-components)))
        (has-properties (org-get-property-block)))
    (org-cut-subtree)
    (org-roam-find-file title nil nil 'no-confirm)
    (org-paste-subtree)
    (unless has-properties
      (kill-line)
      (while (outline-next-heading)
        (org-promote)))
    (goto-char (point-min))
    (when has-properties
      (kill-line)
      (kill-line))))

;; Doesn't work but would be cool.
(defun bms/org-roam-rg-search ()
  ;; https://org-roam.discourse.group/t/using-consult-ripgrep-with-org-roam-for-searching-notes/1226
  "Search org-roam directory using consult-ripgrep. With live-preview."
  (interactive)
  (let ((consult-ripgrep-command "rg --null --ignore-case --type org --line-buffered --color=always --max-columns=500 --no-heading --line-number . -e ARG OPTS"))
    (consult-ripgrep org-roam-directory)))
(global-set-key (kbd "C-c rr") 'bms/org-roam-rg-search)

(defun org-hide-properties ()
  ;; https://org-roam.discourse.group/t/org-roam-major-redesign/1198/34
  "Hide org headline's properties using overlay."
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward
            "^ *:PROPERTIES:\n\\( *:.+?:.*\n\\)+ *:END:\n" nil t)
      (overlay-put (make-overlay
                    (match-beginning 0) (match-end 0))
                   'display ""))))
;; (add-hook 'org-mode-hook #'org-hide-properties)
  ;; TODO : It's buggy -- it causes one bullet to appear adjacent to another
  ;; if the second is empty aside from the properties.
  ;; Once it's fixed, uncomment this line.

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
 '(org-roam-directory "/home/jeff/org-roam" t)
 '(package-archives
   '(("gnu" . "http://elpa.gnu.org/packages/")
     ("melpa" . "http://melpa.org/packages/")
     ("melpa-stable" . "http://stable.melpa.org/packages/")))
 '(package-selected-packages
   '(org-roam undo-tree scala-mode python-mode org nix-mode markdown-mode magit intero hide-lines csv-mode auctex)))

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
  "Renames both current buffer and file it's visiting to NEW-NAME."
  (interactive "sNew name: ")
  (let ((name (buffer-name))
	(filename (buffer-file-name)))
    (if (not filename)
	(message "Buffer '%s' is not visiting a file!" name)
      (if (get-buffer new-name)
	  (message "A buffer named '%s' already exists!" new-name)
	(progn
	  (rename-file filename new-name 1)
	  (rename-buffer new-name)
	  (set-visited-file-name new-name)
	  (set-buffer-modified-p nil))))))

;; Never understood why Emacs doesn't have this function, either.
(defun move-buffer-file (dir)
  "Moves both current buffer and file it's visiting to DIR."
  (interactive "DNew directory: ")
  (let* ((name (buffer-name))
         (filename (buffer-file-name))
         (dir
          (if (string-match dir "\\(?:/\\|\\\\)$")
              (substring dir 0 -1) dir))
         (newname (concat dir "/" name)))
    (if (not filename)
        (message "Buffer '%s' is not visiting a file!" name)
      (progn
	(copy-file filename newname 1)
	(delete-file filename)
	(set-visited-file-name newname)))))

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

(defun xah-delete-blank-lines ()
  "Delete all newline around cursor.

URL `http://ergoemacs.org/emacs/emacs_shrink_whitespace.html'
Version 2018-04-02"
  (interactive)
  (let ($p3 $p4)
          (skip-chars-backward "\n")
          (setq $p3 (point))
          (skip-chars-forward "\n")
          (setq $p4 (point))
          (delete-region $p3 $p4)))

(defun xah-shrink-whitespaces ()
  "Remove whitespaces around cursor to just one, or none.

Shrink any neighboring space tab newline characters to 1 or none.
If cursor neighbor has space/tab, toggle between 1 or 0 space.
If cursor neighbor are newline, shrink them to just 1.
If already has just 1 whitespace, delete it.

URL `http://ergoemacs.org/emacs/emacs_shrink_whitespace.html'
Version 2018-04-02T14:38:04-07:00"
  (interactive)
  (let* (
         ($eol-count 0)
         ($p0 (point))
         $p1 ; whitespace begin
         $p2 ; whitespace end
         ($charBefore (char-before))
         ($charAfter (char-after ))
         ($space-neighbor-p (or (eq $charBefore 32) (eq $charBefore 9) (eq $charAfter 32) (eq $charAfter 9)))
         $just-1-space-p
         )
    (skip-chars-backward " \n\t")
    (setq $p1 (point))
    (goto-char $p0)
    (skip-chars-forward " \n\t")
    (setq $p2 (point))
    (goto-char $p1)
    (while (search-forward "\n" $p2 t )
      (setq $eol-count (1+ $eol-count)))
    (setq $just-1-space-p (eq (- $p2 $p1) 1))
    (goto-char $p0)
    (cond
     ((eq $eol-count 0)
      (if $just-1-space-p
          (delete-horizontal-space)
        (progn (delete-horizontal-space)
               (insert " "))))
     ((eq $eol-count 1)
      (if $space-neighbor-p
          (delete-horizontal-space)
        (progn (xah-delete-blank-lines) (insert " "))))
     ((eq $eol-count 2)
      (if $space-neighbor-p
          (delete-horizontal-space)
        (progn
          (xah-delete-blank-lines)
          (insert "\n"))))
     ((> $eol-count 2)
      (if $space-neighbor-p
          (delete-horizontal-space)
        (progn
          (goto-char $p2)
          (search-backward "\n" )
          (delete-region $p1 (point))
          (insert "\n"))))
     (t (progn
          (message "nothing done. logic error 40873. shouldn't reach here" ))))))
(global-set-key (kbd "C-c C-SPC") (lambda () (interactive)
                                    (xah-shrink-whitespaces)))

;; plucked from https://gitlab.haskell.org/ghc/ghc/-/wikis/emacs
(add-hook 'before-save-hook 'delete-trailing-whitespace)
(setq kill-whole-line t) ;; cursor at start => C-k kills the newline too
(column-number-mode 1)
(defun untabify-buffer ()
  "Untabify current buffer."
  (interactive)
  (save-excursion (untabify (point-min) (point-max))))
(setq-default fill-column 80) ;; reformat a comment with M-q
