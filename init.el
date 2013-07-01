; GLOBAL PREFERENCES
(menu-bar-mode -1)
(setq inhibit-startup-message t)
(setq make-backup-files nil)
(setq auto-save-default nil)
(set-background-color "#D6D2D0")
(set-face-background 'mode-line "#D6D2D0")
(set-face-background 'mode-line-inactive "#D6D2D0")
(scroll-bar-mode -1)
(tool-bar-mode -1)
(setq initial-scratch-message "")
(set-fringe-mode '(0 . 0))
(add-to-list 'default-frame-alist '(font . "-schumacher-*-medium-r-normal-*-12-*-*-*-*-*-*-*"))
(setq speedbar-directory-unshown-regexp "^$")
; if file contents changed on disk, buffer will re-read automatically
(global-auto-revert-mode 1) 
(setq auto-revert-interval 2)
(global-set-key [down-mouse-3] 'mouse-popup-menubar-stuff)
;
;EMACS ENVIRONMENT SETUP
(add-to-list 'load-path "~/.emacs.d/utils")
(autoload 'dirtree "dirtree" "Add directory to tree view" t)
(autoload 'inferior-moz-mode "moz" "MozRepl Inferior Mode" t)
(autoload 'moz-minor-mode "moz" "MozRepl Minor Mode" t)
(setq mouse-wheel-scroll-amount '(1 ((shift) . 1))) ;; one line at a time
(setq mouse-wheel-progressive-speed nil) ;; don't accelerate scrolling
(setq scroll-step 1) ;; keyboard scroll one line at a time
;

(set-face-attribute  'mode-line
                 nil 
;                 :foreground "gray80"
;                 :background "gray25" 
                 :box '( :line-width 1  :color "gray75" :style nil ))
(set-face-attribute  'mode-line-inactive
                 nil 
;                 :foreground "gray30"
;                 :background "gray25" 
                 :box '(:line-width 1 :color "gray75" :style nil ))


; hide-show for nxml mode
(add-to-list 'hs-special-modes-alist
             '(nxml-mode
               "<!--\\|<[^/>]>\\|<[^/][^>]*[^/]>"
               ""
               "<!--" ;; won't work on its own; uses syntax table
               (lambda (arg) (my-nxml-forward-element))
               nil))

(require 'package)
(setq package-archives '(("ELPA" . "http://tromey.com/elpa/") 
                          ("gnu" . "http://elpa.gnu.org/packages/")
                          ("marmalade" . "http://marmalade-repo.org/packages/")))

(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/") t)

(package-initialize)
;
;
(add-to-list 'auto-mode-alist '("\.cljs$" . clojure-mode));
(add-to-list 'auto-mode-alist '("\\.js\\'" . js-mode))
;keep emacs from loading the image of an svg, by default
(add-to-list 'auto-mode-alist '("\\.svg\\'" . xml-mode))
;
;
(add-hook 'javascript-mode-hook 'javascript-moz-setup)
(add-hook 'js-mode-hook
          (lambda ()
            ;; Scan the file for nested code blocks
            (imenu-add-menubar-index)
            ;; Activate the folding mode
            (hs-minor-mode t)))

;; KEY BINDINGS
(global-set-key (kbd "C-x s") 'hs-show-block)
(global-set-key (kbd "C-x h") 'hs-hide-block)
(global-set-key (kbd "M-c") 'compile-project )
(global-set-key (kbd "C-s") 'save-buffer )
(global-set-key (kbd "C-p") 'export-to-svgtarget-buffer-and-save)
;
;
; setup for xml editing

(defun my-nxml-forward-element ()
  (let ((nxml-sexp-element-flag))
    (setq nxml-sexp-element-flag (not (looking-at "<!--")))
    (unless (looking-at outline-regexp)
      (condition-case nil
          (nxml-forward-balanced-item 1)
        (error nil)))))
;
;
(add-hook 'nxml-mode-hook 'nxml-mode-setup)

(defun nxml-mode-setup ()
(when (string-match "\\.\\(x?html\\|php[34]?\\)$"
                        (file-name-sans-versions (buffer-file-name)))
      (my-xhtml-extras)
))

  (defun my-xhtml-extras ()
    (make-local-variable 'outline-regexp)
    (setq outline-regexp "\\s *<\\([h][1-6]\\|html\\|body\\|head\\)\\b")
    (make-local-variable 'outline-level)
    (setq outline-level 'my-xhtml-outline-level)
    (outline-minor-mode 1)
    (hs-minor-mode 1))

 (defun my-xhtml-outline-level ()
    (save-excursion (re-search-forward html-outline-level))
    (let ((tag (buffer-substring (match-beginning 1) (match-end 1))))
      (if (eq (length tag) 2)
          (- (aref tag 1) ?0)
        0)))

 (defun my-xhtml-outline-level ()
    (save-excursion (re-search-forward html-outline-level))
    (let ((tag (buffer-substring (match-beginning 1) (match-end 1))))
      (if (eq (length tag) 2)
          (- (aref tag 1) ?0)
        0)))

(defun my-nxml-forward-element ()
    (let ((nxml-sexp-element-flag))
      (setq nxml-sexp-element-flag (not (looking-at "<!--")))
      (unless (looking-at outline-regexp)
        (condition-case nil
            (nxml-forward-balanced-item 1)
          (error nil)))))
;
(fset 'html-mode 'nxml-mode)
;
;
(defun javascript-moz-setup () (moz-minor-mode 1))
;
(defun auto-reload-firefox-on-after-save-hook ()         
          (add-hook 'after-save-hook
                       '(lambda ()
                          (interactive)
                          (comint-send-string (inferior-moz-process)
                                              "setTimeout(BrowserReload(), \"1000\");"))
                       'append 'local)) ; buffer-local
;;; Usage
;; Run M-x moz-reload-mode to switch moz-reload on/off in the
;; current buffer.
;; When active, every change in the buffer triggers Firefox
;; to reload its current page.
(autoload 'moz-reload-mode "moz-reload-mode" "real time javascript update" t) 
; (require 'moz-reload-mode)
;; Example - you may want to add hooks for your own modes.
;; I also add this to python-mode when doing django development.
 (add-hook 'html-mode-hook 'auto-reload-firefox-on-after-save-hook)
 (add-hook 'css-mode-hook 'auto-reload-firefox-on-after-save-hook)
;
;; Add following lines to your .emacs initialization file:
;;
     (require 'real-auto-save)

;disabling real auto save as default so I can trigger it when i want

;     (add-hook 'html-mode-hook 'turn-on-real-auto-save)
;     (add-hook 'javascript-mode-hook 'turn-on-real-auto-save)
;;
;; Auto save interval is 10 seconds by default. You can change it:
;;
     (setq real-auto-save-interval 3) ;; in seconds
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; PROGRAMMING ENVIRONMENT SETUP
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
(defun export-to-svgtarget-buffer-and-save ()
(interactive)
(save-selected-window 
 (setq start-buffer (buffer-name))
 (switch-to-buffer "svgtarget")
 (clipboard-kill-region 1 (point-max))
 (switch-to-buffer start-buffer)
 (clipboard-kill-ring-save (point-min) (point-max))
 (switch-to-buffer "svgtarget")
 (clipboard-yank)
 (save-buffer)
 (switch-to-buffer start-buffer)
))

(defun client-repl-send-input (input)
  "Send INPUT into the client buffer and leave it visible."
  (save-selected-window
    (setq start-buffer (buffer-name))
    (switch-to-buffer-other-frame "client")
    (goto-char (point-max))
    (insert input)
    (comint-send-input)
    (switch-to-buffer-other-frame start-buffer)

))

(defun server-repl-send-input (input)
  "Send INPUT into the server buffer and leave it visible."
  (save-selected-window
    (setq start-buffer (buffer-name))
    (switch-to-buffer-other-frame "server")
    (goto-char (point-max))
    (insert input)
    (comint-send-input)
    (switch-to-buffer-other-frame start-buffer)
))

(defun compile-project ()
  "Send INPUT into the project-compiler window."
  (interactive)
  (save-selected-window
    (setq start-buffer (buffer-name))
    (switch-to-buffer-other-frame "project")
    (goto-char (point-max))
    (insert "(compile-project)" )
    (comint-send-input)
    (switch-to-buffer-other-frame start-buffer)
))

(defun expression-preceding-point ()
  "Return the expression preceding point as a string."
  (buffer-substring-no-properties
   (save-excursion (backward-sexp) (point))
   (point)))

(defun client-repl-eval-last-expression ()
  "Send the expression preceding point to the client buffer."
  (interactive)
  (client-repl-send-input (expression-preceding-point)))

(defun server-repl-eval-last-expression ()
  "Send the expression preceding point to the client buffer."
  (interactive)
  (server-repl-send-input (expression-preceding-point)))
 

(add-hook 'clojure-mode-hook
          '(lambda ()
             (define-key clojure-mode-map (kbd "C-e") 'client-repl-eval-last-expression)
             (define-key clojure-mode-map (kbd "C-w") 'server-repl-eval-last-expression)))


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(cua-mode t nil (cua-base))
 '(speedbar-show-unknown-files t)
 '(speedbar-use-images nil)
 '(tool-bar-mode nil))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(font-lock-comment-face ((t (:foreground "steel blue")))))
