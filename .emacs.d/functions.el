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

(defun jbb-clock () ;; show time
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

(defun jbb-undo-tree ()
  (interactive)
  (progn (split-window-right)
         (undo-tree-mode)
         (undo-tree-visualize)
         (undo-tree-visualizer-toggle-diff)))`

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

(defun untabify-buffer ()
  "Untabify current buffer."
  (interactive)
  (save-excursion (untabify (point-min) (point-max))))
