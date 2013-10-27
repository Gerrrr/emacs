;; PACKAGE INIT

(require 'package)
(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                         ("marmalade" . "http://marmalade-repo.org/packages/")
                         ("melpa" . "http://melpa.milkbox.net/packages/")))
(package-initialize)


(setq extra-packages
      '(rainbow-delimiters ;; nested parenthesis are now different in color
        auto-complete      ;; auto complete mode
        icomplete+         ;; better icomplete
        gist               ;; integration with github's gist
        tabbar

        ;; language-specific modes
        clojure-mode clojurescript-mode paredit
        highlight nrepl nrepl-eval-sexp-fu
        python-mode
        column-marker
        flymake-cursor
        haskell-mode
))

(defun package-check (p)
  (unless (package-installed-p p)
    (package-install p)))

(mapcar 'package-check extra-packages)

;; REQUIRES
(require 'recentf)
    (recentf-mode 1)
    (setq recentf-max-menu-items 25)
    (global-set-key "\C-x\ \C-r" 'recentf-open-files)

(require 'auto-complete nil t)
(add-to-list 'ac-dictionary-directories "~/.emacs.d/ac-dict")
(require 'auto-complete-config nil t)
(ac-config-default)
(setq ac-comphist-file "~/.emacs.d/cache/ac-comphist.dat"
      ac-candidate-limit 20
      ac-ignore-case nil)
(global-auto-complete-mode)

;; tabbar
(require 'tabbar)
(tabbar-mode)
(setq tabbar-buffer-groups-function
       (lambda ()
         (list "All Buffers")))

;; BINDINGS
(global-set-key [M-left] 'tabbar-backward-tab)
(global-set-key [M-right] 'tabbar-forward-tab)
(global-set-key [M-up] 'speedbar-get-focus)
(global-set-key (kbd "C-<tab>") 'next-buffer)
(global-set-key (kbd "C-x C-k") 'kill-this-buffer)

;; SETTINGS
(set-default-font "Source Code Pro Medium-12")
(add-to-list 'default-frame-alist '(font . "Source Code Pro Medium-12"))
(load-theme 'solarized-light t)

(global-linum-mode 1)
(global-hl-line-mode 1)
(global-rainbow-delimiters-mode 1)

(global-whitespace-mode 1)
(add-hook 'before-save-hook 'delete-trailing-whitespace) ;; remove trailing ws

(require 'paren)
(show-paren-mode +1)
(setq show-paren-style 'parenthesis)
(set-face-background 'show-paren-match-face "#6f6f6f")
(set-face-foreground 'show-paren-match-face "#94bff3")

;; whenever an external process changes a file underneath emacs, and
;; there was no unsaved changes in the corresponding buffer, just
;; revert its content to reflect what's on-disk.
(global-auto-revert-mode 1)

;; hate this auto-fill-mode hook
(remove-hook 'text-mode-hook 'turn-on-auto-fill)

;; autopair
(require 'autopair)
(autoload 'autopair-global-mode "autopair" nil t)
(autopair-global-mode)
(add-hook 'lisp-mode-hook
          #'(lambda () (setq autopair-dont-activate t)))

;; Clojure

(defvar electrify-return-match
  "[\]}\)\"]"
  "If this regexp matches the text after the cursor, do an \"electric\"
  return.")

(defun electrify-return-if-match (arg)
  "If the text after the cursor matches `electrify-return-match' then
  open and indent an empty line between the cursor and the text.  Move the
  cursor to the new line."
  (interactive "P")
  (let ((case-fold-search nil))
    (if (looking-at electrify-return-match)
        (save-excursion (newline-and-indent)))
    (newline arg)
    (indent-according-to-mode)))

(defun paredit-mode-enable () (paredit-mode 1))
(add-hook 'clojure-mode-hook 'paredit-mode-enable)
(add-hook 'clojure-mode-hook
          '(lambda ()
             (local-set-key (kbd "RET") 'electrify-return-if-match)))

;; highlight expression on eval
;; taken from emacs-live project, needed for nrepl-eval-sexp-fu
(defun live-paredit-top-level-p ()
  "Returns true if point is not within a given form i.e. it's in
  toplevel 'whitespace'"
  (not
   (save-excursion
     (ignore-errors
       (paredit-forward-up)
       t))))

(require 'highlight)
(require 'nrepl-eval-sexp-fu)
(setq nrepl-eval-sexp-fu-flash-duration 0.5
      nrepl-eval-sexp-fu-flash-face 'compilation-info-face
      nrepl-eval-sexp-fu-flash-error 'compilation-error-face)

(add-to-list 'auto-mode-alist '("\\.cljx\\'" . clojure-mode))

(add-hook 'nrepl-interaction-mode-hook
          'nrepl-turn-on-eldoc-mode)
(setq nrepl-hide-special-buffers t)
(setq nrepl-popup-stacktraces-in-repl t)

;; Python
;column edge line
(require 'column-marker)
(add-hook 'python-mode-hook (lambda () (interactive) (column-marker-1 80)))

(require 'python-mode)
(add-hook 'python-mode-hook
          #'(lambda ()
              (push '(?' . ?')
                    (getf autopair-extra-pairs :code))
              (setq autopair-handle-action-fns
                    (list #'autopair-default-handle-action
                          #'autopair-python-triple-quote-action))))

(when (load "flymake" t)
  (defun flymake-pyflakes-init ()
    (let* ((temp-file (flymake-init-create-temp-buffer-copy
               'flymake-create-temp-inplace))
       (local-file (file-relative-name
            temp-file
            (file-name-directory buffer-file-name))))
      (list "/usr/local/bin/flake8"  (list local-file))))
   (add-to-list 'flymake-allowed-file-name-masks
                '("\\.py\\'" flymake-pyflakes-init)))

(add-hook 'python-mode-hook 'flymake-find-file-hook)
(eval-after-load 'flymake '(require 'flymake-cursor))


(custom-set-variables
  '(py-pychecker-command "pychecker.sh")
  '(py-pychecker-command-args (quote ("")))
  '(python-check-command "pychecker.sh"))
