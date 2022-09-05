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

;; ;; ;; jbb macros ;; ;; ;;
;;  How to store macros here:
;;    use F3, then F4 to record the macro
;;    M-x name-last-kbd-macro
;;    M-x insert-kbd-macro
;;    paste that code below
;;    maybe also give it a name (per examples below)

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
  ;; the "invisible" text will be rendered with " ⬎".
  ;; (Search this text for ⬎ to see why it's not an ellipsis, the default.)
  ;; Had I instead written `(add-to-invisibility-spec 'jbb-fold),
  ;; nothing would be shown to indicate the hidden text.
  ;; Details: https://www.gnu.org/software/emacs/manual/html_node/elisp/Managing-Overlays.html
(defun fold (toHide) ;; folds given t.
  ;; TODO: Should unfold given (), but doesn't.
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
            (overlay-put (make-overlay startRegion endRegion)
                         'invisible 'jbb-fold)
            ;;( put-text-property
            ;;  ;; If the "invisible" property is any non-nil value,
            ;;  ;; the text is invisible. However, some non-nil values
            ;;  ;; (see, e.g., the definition of `jbb-fold` above)
            ;;  ;; cause "invisible" text to display as an ellipsis.
            ;;  startRegion endRegion 'invisible 'jbb-fold)
            (goto-char startRegion) ) ) ) ) ) )
;; (global-set-key (kbd "C-c h") (lambda () (interactive) (fold t)))

(defun unfold ()
  (interactive)
  (progn
    (let ((origin (point)))
      (move-beginning-of-line 1)
      (let ((start (point)))
        (move-end-of-line 1)
        (forward-char 1)
        (let ((end (point)))
          (while (and (invisible-p end)
                      (< end (point-max)))
            (setq end (1+ end)))
          (remove-overlays start end 'invisible 'jbb-fold)
          (put-text-property origin end 'invisible ())
          (goto-char origin))))))
;; (global-set-key (kbd "C-c s") (lambda () (interactive) (unfold)))

;; https://emacs.stackexchange.com/a/37889
(defun mark-receiving-ghci-buffer ()
   (interactive)
   (setq receiving-ghci-buffer (buffer-name)))
(defun send-highlighted-region-to-receiving-ghci-buffer (beg end)
  (interactive "r")
  (process-send-string receiving-ghci-buffer ":{\n")
  (process-send-region receiving-ghci-buffer beg end)
  (process-send-string receiving-ghci-buffer "\n:}\n"))
(global-set-key ( kbd "C-c s")
		( lambda () (interactive)
		  (send-highlighted-region-to-receiving-ghci-buffer) ) )

(defun jbb-full-screen-buffer ()
  (interactive)
  (progn (
list-buffers)
	 (other-window 1)
	 (delete-other-windows)
	 ))

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

(add-hook 'erlang-mode-hook
	  (lambda ()
	    (setq erlang-indent-level 2)))

;; show time
(defun jbb-clock ()
  (interactive)
  (message (format-time-string "%Y-%m-%d %H:%M:%S")))

(defun recenter-left-right ()
  ;; https://stackoverflow.com/a/1249665/916142
  "make the point horizontally centered in the window"
  (interactive)
  (let ((mid (/ (window-width) 2))
        (line-len (save-excursion (end-of-line) (current-column)))
        (cur (current-column)))
    (if (< mid cur)
        (set-window-hscroll (selected-window)
                            (- cur mid)))))
(global-set-key (kbd "C-S-l") 'recenter-left-right)


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

(defun jbb-undo-tree ()
  (interactive)
  (progn (split-window-right)
         (undo-tree-mode)
         (undo-tree-visualize)
         (undo-tree-visualizer-toggle-diff)))`

;; volatile highlights: highlight kills, undos, etc.
(volatile-highlights-mode t)
;; TODO The above does not make vhl the default -- I still have to enable it
;; in every new buffer. Also the code below doesn't work --
;; I can evaluate it by hand (after evaluating the above line),
;; but it breaks the autoload process.
;; (vhl/define-extension 'undo-tree 'undo-tree-yank 'undo-tree-move)
;; (vhl/install-extension 'undo-tree)

;; org-roam
(setq org-roam-database-connector 'sqlite3)
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
 '(org-adapt-indentation t) ;; contents inherit indentation changes
 '(org-fontify-done-headline nil)
 '(org-hide-block-startup t)
 '(org-id-link-to-org-use-id t)
 '(org-roam-db-autosync-mode t)
 '(org-roam-directory "/home/jeff/org-roam")
 '(org-startup-folded t)
 '(org-todo-keywords '((sequence "TODO" "BLOCKED" "DONE")))
 '(package-archives
   '(("gnu" . "http://elpa.gnu.org/packages/")
     ("melpa" . "http://melpa.org/packages/")
     ("melpa-stable" . "http://stable.melpa.org/packages/")))
 '(package-selected-packages
   '(erlang org-roam undo-tree scala-mode python-mode org nix-mode markdown-mode magit intero hide-lines csv-mode auctex)))

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

;; https://github.com/emacs-helm/helm/issues/1038
;; I don't use helm, but if I start, this should improve (to me)
;; the font size for the helm buffer.
(defun helm-buffer-face-mode ()
   "Helm buffer face"
   (interactive)
   (with-helm-buffer
     (setq line-spacing 2)
     (buffer-face-set '(:family "Source Code Pro" :height 300))))
(add-hook 'helm-update-hook 'helm-buffer-face-mode)

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

(menu-bar-mode -1) ;; Whether to show it. (t for true, -1 for nil.)
