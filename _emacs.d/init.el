;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; sven's  emacs configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; configuration, user and version information
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq sk-version "0.5")
(setq user-full-name "")
(setq user-mail-address "")
(setq current-language-environment "English")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; common lisp features for emacs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'cl) 
(require 'cl-lib)
(require 'cl-indent)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; packages
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; F king-package
(require 'package)

(setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")

;; elpa is part of the list as default entry
                                        ;
(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/") t)
(add-to-list 'package-archives '("tromey" . "http://tromey.com/elpa/") t)
;; (add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t )
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))

(package-initialize)

(defvar *package-lists-fetched* nil)

(defun soft-fetch-package-lists ()
  (unless *package-lists-fetched*
    (package-refresh-contents)
    (setf *package-lists-fetched* t)))

;; package-installed-p will always report NIL if a newer
;; version is available. We do not want that.
(defun package-locally-installed-p (package)
  (assq package package-alist))

(defun ensure-installed (&rest packages)
  (unless (cl-loop for package in packages
                   always (package-locally-installed-p package))
    (soft-fetch-package-lists)
    (dolist (package packages)
      (unless (package-locally-installed-p package)
        (package-install package)))))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; general
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(ensure-installed 'powerline)
(powerline-default-theme)

(show-paren-mode 1)

;; comments
(defun toggle-comment-on-line ()
  "comment or uncomment current line"
  (interactive)
  (comment-or-uncomment-region (line-beginning-position) (line-end-position)))
(global-set-key (kbd "C-;") 'toggle-comment-on-line)


;; Changes all yes/no questions to y/n type
(fset 'yes-or-no-p 'y-or-n-p)

;; shell scripts
(setq-default sh-basic-offset 2)
(setq-default sh-indentation 2)

;; No need for ~ files when editing
(setq create-lockfiles nil)

;; disable backup files
(setq make-backup-files nil)

;; tmp files
(setq backup-directory-alist `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms `((".*" ,temporary-file-directory t)))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PAREDIT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(ensure-installed 'paredit)

(require 'paredit)
(eval-when-compile (require 'cl))

(autoload 'enable-paredit-mode "paredit" "Turn on pseudo-structural editing of Lisp code." t)

(add-hook 'lisp-mode-hook 'enable-paredit-mode)
(add-hook 'lisp-interaction-mode-hook 'enable-paredit-mode)
(add-hook 'slime-repl-mode-hook 'enable-paredit-mode)
(add-hook 'eval-expression-minibuffer-setup-hook 'enable-paredit-mode)
(add-hook 'emacs-lisp-mode-hook 'enable-paredit-mode)
(add-hook 'ielm-mode-hook 'enable-paredit-mode)
(add-hook 'scheme-mode-hook  'enable-paredit-mode)


(put 'paredit-forward-delete 'delete-selection 'supersede)
(put 'paredit-backward-delete 'delete-selection 'supersede)
(put 'paredit-newline 'delete-selection t)



(defun override-slime-repl-bindings-with-paredit ()
  (define-key slime-repl-mode-map
      (read-kbd-macro paredit-backward-delete-key) nil))

(add-hook 'slime-repl-mode-hook 'override-slime-repl-bindings-with-paredit)

;; Fix the spacing for macro characters such as #p, etc.
(defvar known-macro-characters (make-hash-table))

(defun determine-cl-macro-character (macro-char)
  (when (slime-connected-p)
    (lexical-let ((macro-char macro-char))
      (slime-eval-async
       `(cl:ignore-errors
         (cl:not (cl:null (cl:get-macro-character
                           (cl:code-char ,macro-char)))))
       (lambda (result)
         (puthash macro-char result known-macro-characters))))))

(defun cl-macro-character-p (macro-char)
  (pcase (gethash macro-char known-macro-characters :not-found)
         (`t t)
         (`nil nil)
         (:not-found
          (determine-cl-macro-character macro-char)
          (or ;; Don't know the result (yet), determine statically.
              (cl-find macro-char '(?# ?,))))))

(defun paredit-detect-cl-macro-character (endp delimiter)
  (when (cl-find major-mode '(slime-repl-mode lisp-mode))
    (if (not endp)
        (save-excursion
         (let ((1-back (char-before (point)))
               (2-back (char-before (- (point) 1))))
           (null (or (cl-macro-character-p (char-before (point)))
                     (cl-macro-character-p (char-before (1- (point))))))))
        t)))

(with-eval-after-load 'paredit
  (add-to-list 'paredit-space-for-delimiter-predicates
               'paredit-detect-cl-macro-character))





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; S L I M E
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq inferior-lisp-program "sbcl")


(ensure-installed 'slime)

(require 'slime)

(setq slime-contribs '(slime-fancy slime-asdf slime-sprof slime-mdot-fu
                       slime-compiler-notes-tree slime-hyperdoc
                       slime-indentation slime-repl))
(setq slime-complete-symbol-function 'slime-fuzzy-complete-symbol)
(setq slime-net-coding-system 'utf-8-unix)
(setq slime-startup-animation nil)
(setq slime-auto-select-connection 'always)
(setq slime-kill-without-query-p t)
(setq slime-description-autofocus t) 
(setq slime-fuzzy-explanation "")
(setq slime-asdf-collect-notes t)
(setq slime-inhibit-pipelining nil)
(setq slime-load-failed-fasl 'always)
(setq slime-when-complete-filename-expand t)
(setq slime-repl-history-remove-duplicates t)
(setq slime-repl-history-trim-whitespaces t)
(setq slime-export-symbol-representation-auto t)
(setq lisp-indent-function 'common-lisp-indent-function)
(setq lisp-loop-indent-subclauses nil)
(setq lisp-loop-indent-forms-like-keywords t)
(setq lisp-lambda-list-keyword-parameter-alignment t)

(add-hook 'slime-repl-mode-hook 'set-slime-repl-return)

(defun set-slime-repl-return ()
  (define-key slime-repl-mode-map (kbd "RET") 'slime-repl-return-at-end)
  (define-key slime-repl-mode-map (kbd "<return>") 'slime-repl-return-at-end))

(defun slime-repl-return-at-end ()
  (interactive)
  (if (<= (point-max) (point))
      (slime-repl-return)
      (slime-repl-newline-and-indent)))




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; magit
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(ensure-installed 'magit)


(setq magit-delete-by-moving-to-trash nil)
(setq magit-no-confirm '(stage-all-changes unstage-all-changes))

;; Stop with these fucking annoying "'"style"'" conventions
(setq git-commit-fill-column 9999)
(setq git-commit-summary-max-length 9999)
(setq git-commit-finish-query-functions nil)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; scheme
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(ensure-installed 'geiser)
;;(add-hook 'geiser-mode-hook (lambda () (company-mode -1)))
;;(setq inferior-lisp-program "hy")
(setq scheme-program-name "guile")



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; navigation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Shows a list of buffers
(global-set-key (kbd "C-x C-b") 'ibuffer)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ui settings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(ensure-installed 'sublime-themes)

(setq inhibit-startup-screen t)
(setq pop-up-frame-function (lambda () (split-window-right)))
(setq split-height-threshold 1400)
(setq split-width-threshold 1500)
(setq ring-bell-function 'ignore)


;; http://directed-procrastination.blogspot.co.uk/2014/04/some-emacs-hacks-for-gdb-and-other-stuff.html
(defun undedicate-window (&optional window)
  (interactive)
  (set-window-dedicated-p (or window (get-buffer-window)) nil))

;; Removing annoying dedicated buffer nonsense
(defun switch-to-buffer! (buffer-or-name &optional norecord force-same-window)
  "Like switch-to-buffer but works for dedicated buffers \(though
it will ask first)."
  (interactive
   (list (read-buffer-to-switch "Switch to buffer: ") nil 'force-same-window))
  (when (and (window-dedicated-p (get-buffer-window))
             (yes-or-no-p "This window is dedicated, undedicate it? "))
    (undedicate-window))
  (switch-to-buffer buffer-or-name norecord force-same-window))

(defun toggle-window-dedication (&optional window)
  (interactive)
  (let ((window (or window (get-buffer-window))))
    (set-window-dedicated-p window (not (window-dedicated-p window)))))


;;; Restoring frame size
(defun --normalized-frame-parameter (parameter)
  (let ((value (frame-parameter (selected-frame) parameter)))
    (if (number-or-marker-p value) (max value 0) 0)))



(load-theme 'misterioso t)
(menu-bar-mode t)

(when window-system
  (tool-bar-mode -1)
  (scroll-bar-mode -1)
  (setq confirm-kill-emacs 'y-or-n-p))

;; No cursor blinking, it's distracting
(blink-cursor-mode 0)

;; full path in title bar
(setq-default frame-title-format "%b (%f)")

;; Customise graphic mode
(when window-system
  (custom-set-faces
   '(default ((t (:family "Source Code Pro" :foundry "ADBE" :slant normal :weight normal :height 105 :width normal))))))


;; number of characters until the fill column
(setq-default fill-column 80)


(ensure-installed 'highlight-current-line)
(require 'highlight-current-line)
(highlight-current-line-on t)
(highlight-current-line-set-bg-color "#444444")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; rustic
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(ensure-installed 'rustic)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; deft
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(ensure-installed 'deft)

(setq deft-extensions '("org"))
(setq deft-directory "~/dev/notes")
(setq deft-recursive t)
(global-set-key [f8] 'deft)




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; server
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'server)
;;(unless (server-running-p) (server-start))

(when (eql system-type 'windows-nt)
  ;; We hack this to never error because otherwise emacs refuses to work
  ;; as a server on Windows due to requiring the dir being fixed to a
  ;; "safe" directory, which we cannot ensure in our portable environment.
  (cl-defun server-ensure-safe-dir (dir)
    (unless (file-exists-p dir)
      (make-directory dir t))))

(add-hook 'emacs-startup-hook
          (lambda ()
            (when (and window-system (not (server-running-p))) 
              (server-start))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; custom file
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Put auto 'custom' changes in a separate file (this is stuff like
;; custom-set-faces and custom-set-variables)
(load
 (setq custom-file (expand-file-name "custom.el" user-emacs-directory))
 'noerror)



