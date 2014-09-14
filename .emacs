(add-to-list 'load-path "~/.emacs.d")

;; use Shift+arrow_keys to move cursor around split panes
(windmove-default-keybindings)

;; when cursor is on edge, move to the other side, as in a toroidal space
(setq windmove-wrap-around t )

;; show column number
(column-number-mode t)

(scroll-bar-mode -1)

;; flash instead of that annoying bell
(setq visible-bell t)

;; Format the title-bar to always include the buffer name
(setq frame-title-format "emacs - %b")

;; Scroll line by line
(setq scroll-step 1)

;; in every buffer, the line which contains the cursor will be fully highlighted
(global-hl-line-mode 1)

;; Remove startup message
(setq inhibit-startup-message t)

;; Disable toolbar
(tool-bar-mode -1)

;; show matching parens:
(show-paren-mode 1)
(setq show-paren-delay 0)

;; treat .h files as c++ files
(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))

;; Setup Programming Style Guide of PointClouds Library
(load-file "~/.emacs.d/pcl-c-style.el")
(add-hook 'c-mode-common-hook 'pcl-set-c-style)

;; Set a global key form go-to
(global-set-key (kbd "C-c j") 'goto-line)

(require 'package)
(package-initialize)
(add-to-list 'package-archives 
	     '("melpa" . "http://melpa.milkbox.net/packages/") t)
;; Add the user-contributed repository
(add-to-list 'package-archives
             '("marmalade" . "http://marmalade-repo.org/packages/") t)

(require 'desktop)
(desktop-save-mode 1)
(defun my-desktop-save ()
  (interactive)
  ;; Don't call desktop-save-in-desktop-dir, as it prints a message.
  (if (eq (desktop-owner) (emacs-pid))
      (desktop-save desktop-dirname)))
(add-hook 'auto-save-hook 'my-desktop-save)

(require 'yasnippet)
(setq yas-snippet-dirs (append yas-snippet-dirs
			       '("~/.emacs.d/rosemacs/snippets/")))
(yas-global-mode 1)
(setq yas-reload-all t)
(setq yas-also-auto-indent-first-line t)
(setq yas-triggers-in-field t)
(setq yas-wrap-around-region t)
(require 'dropdown-list)
(setq yas-prompt-functions '(yas-dropdown-prompt
			     yas-ido-prompt
			     yas-completing-prompt))

(require 'auto-complete-config)
(ac-config-default)

(defun my:ac-c-headers-init ()
  (require 'auto-complete-c-headers)
  (add-to-list 'ac-sources 'ac-source-c-headers)
  (add-to-list 'achead:include-directories '"/usr/local/include/pcl-1.7")
  (add-to-list 'achead:include-directories '"/usr/include/eigen3")
  (add-to-list 'achead:include-directories '"/usr/include/c++/4.8")
  (add-to-list 'achead:include-directories '"/opt/ros/indigo/include")
  (add-to-list 'achead:include-directories '"/home/carlos/catkin_ws/devel/include"))

(add-hook 'c++-mode-hook 'my:ac-c-headers-init)
(add-hook 'c-mode-hook 'my:ac-c-headers-init)

;; (require 'auto-complete-clang)
(require 'auto-complete-clang-async)
;;(ac-config-default)

;; ac common settings
(setq ac-quick-help-delay 0.5)
;;(setq ac-auto-start 4) ;; so it starts after the firth letter
(setq ac-clang-async-do-autocompletion-automatically nil) ;; so it autocompletion is manually triggered when you type ., -> or ::
(setq ac-auto-start nil)
(setq ac-auto-show-menu 1)
(setq ac-menu-height 10)
(setq ac-ignore-case nil)
(setq ac-use-menu-map t)
(setq ac-dwim t)

(define-key ac-mode-map (kbd "C-S-<iso-lefttab>") 'ac-fuzzy-complete)
(define-key ac-mode-map [(control tab)] 'auto-complete)
(define-key ac-mode-map (kbd "C-c c") 'ac-clang-syntax-check)

(defun ac-cc-mode-clang-setup ()
  (message " * calling ac-cc-mode-clang-setup")
  (setq ac-clang-complete-executable "~/.emacs.d/emacs-clang-complete-async/clang-complete")
  (setq ac-clang-cflags
	(mapcar (lambda (item)(concat "-I" item))
		(split-string
		 "/usr/include/c++/4.8
                  /usr/include/x86_64-linux-gnu/c++/4.8/.
                  /usr/include/c++/4.8/backward
                  /usr/lib/gcc/x86_64-linux-gnu/4.8/include
                  /usr/lib/gcc/x86_64-linux-gnu/4.8/include-fixed
                  /usr/lib/gcc/x86_64-linux-gnu
                  /usr/local/include
                  /usr/include
                  /usr/local/include/pcl-1.7
                  /usr/include/eigen3
                  /opt/ros/indigo/include
                  /home/carlos/catkin_ws/install/include
                  /home/carlos/catkin_ws/devel/include")))
  (setq ac-sources (append '(ac-source-clang-async ac-source-yasnippet) ac-sources))
  (ac-clang-launch-completion-process)
  (setq ac-clang-flags ac-clang-cflags)
  (ac-clang-update-cmdlineargs))

(defun ac-cc-mode-clang-config ()
  (setq-default ac-sources '(ac-source-abbrev ac-source-words-in-same-mode-buffers))
  (add-hook 'emacs-lisp-mode-hook 'ac-emacs-lisp-mode-setup)
  ;;(add-hook 'c-mode-common-hook 'ac-cc-mode-clang-setup)
  (add-hook 'auto-complete-mode-hook 'ac-common-setup)
  (global-auto-complete-mode t))

(add-hook 'c-mode-common-hook 'ac-cc-mode-clang-setup)
(add-hook 'c-mode-common-hook 'hs-minor-mode)
(add-hook 'c-mode-common-hook 'linum-mode)

(ac-cc-mode-clang-config)

;; setup flymake for c++
(require 'flymake)
(require 'cmake-project)
(require 'flymake-cursor)

(setq flymake-gui-warnings-enabled nil)
;;(set-variable 'flymake-start-syntax-check-on-newline nil)
;;(set-variable 'flymake-no-changes-timeout 0.5)

(defun maybe-cmake-project-hook ()
  (if (file-exists-p "CMakeLists.txt") (cmake-project-mode)))
(add-hook 'c-mode-hook 'maybe-cmake-project-hook)
(add-hook 'c++-mode-hook 'maybe-cmake-project-hook)

(defun turn-on-flymake-mode()
(if (and (boundp 'flymake-mode) flymake-mode)
    ()
  (flymake-mode t)))

(add-hook 'c-mode-common-hook (lambda () (turn-on-flymake-mode)))
(add-hook 'c++-mode-hook (lambda () (turn-on-flymake-mode)))

(defun cmake-project-current-build-command ()
  "Command line to compile current project as configured in the build directory."
  (concat "cmake --build "
          (shell-quote-argument (expand-file-name
                                 cmake-project-build-directory)) " -- -j 8" ))

(defun cmake-project-flymake-init ()
  (list (executable-find "cmake")
        (list "--build" (expand-file-name cmake-project-build-directory) "--" "-j" "8" )))
;; end setup flymake for c++

;; Tell emacs where to find the rosemacs sources
;; replace the path with location of rosemacs on your system
(push "~/.emacs.d/rosemacs" load-path) 
;; Load the library and start it up
(require 'rosemacs)
(invoke-rosemacs)
;; Optional but highly recommended: add a prefix for quick access
;; to the rosemacs commands
(global-set-key "\C-x\C-r" ros-keymap)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector ["black" "#d55e00" "#009e73" "#f8ec59" "#0072b2" "#cc79a7" "#56b4e9" "white"])
 '(column-number-mode t)
 '(custom-enabled-themes (quote (adwaita)))
 '(inhibit-startup-screen t)
 '(show-paren-mode t)
 '(tool-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
