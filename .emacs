;;; .emacs --- Summary:
;;;
;;; Commentary:
;;;
(add-to-list 'load-path "~/.emacs.d")

(require 'package)
;;; Code:
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/"))
(package-initialize)

;; Use Shift+arrow_keys to move cursor around split panels
(windmove-default-keybindings)

;; When cursor is on edge, move to the other side, as in a toroidal space
(setq windmove-wrap-around t)

;; Show column number
(column-number-mode t)

;; Scroll bar disable
(scroll-bar-mode -1)

;; flash instead of that annoying bell
(setq visible-bell t)

;; Format the title-bar to always include the buffer name
(setq frame-title-format "emacs - %b")

;; Scroll line by line
(setq scroll-step 1)

;; in every buffer, the line shich contains the cursor will be fully highlighted
(global-hl-line-mode 1)

;; Remove startup message
(setq inhibit-startup-message t)

;; treat .h files as c++ files
(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))

					; Add cmake listfile names to the mode list.
(setq auto-mode-alist
      (append
       '(("CMakeLists\\.txt\\'" . cmake-mode))
       '(("\\.cmake\\'" . cmake-mode))
       auto-mode-alist))

(autoload 'cmake-mode "~/.emacs.d/cmake-mode.el" t)

(autoload 'cmake-font-lock-activate "cmake-font-lock" nil t)
(add-hook 'cmake-mode-hook 'cmake-font-lock-activate)



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

(require 'company-c-headers)
;;(add-hook 'c-mode-common-hook 'auto-complete-mode)
(add-hook 'c-mode-common-hook 'flymake-mode)
(add-to-list 'company-backends 'company-c-headers)
(add-to-list 'company-backends 'auto-complete-clang-autoloads)
(add-hook 'after-init-hook 'global-company-mode)
(add-hook 'after-init-hook #'global-flycheck-mode)
(add-hook 'cmake-mode-hook 'cmake-font-lock-activate)
(add-hook 'c-mode-common-hook
          (lambda ()
            (if (derived-mode-p 'c-mode 'c++-mode)
                (if  (not (or (string-match "^/usr/local/include/.*" buffer-file-name)
                              (string-match "^/usr/src/linux/include/.*" buffer-file-name)))
                    (cppcm-reload-all))
              )))
(require 'ggtags)
(add-hook 'c-mode-common-hook 'ggtags-mode)
(add-hook 'c-mode-common-hook 'hs-minor-mode)
(add-hook 'c-mode-common-hook 'linum-mode)
(require 'pcl-c-style)
(add-hook 'c-mode-common-hook 'pcl-set-c-style)

;;(global-company-mode t)
(autoload 'cmake-font-lock-activate "cmake-font-lock" nil t)

(global-set-key (kbd "C-c C-g")
		'(lambda ()(interactive) (gud-gdb (concat "gdb --fullname " (cppcm-get-exe-path-current-buffer)))))
(setq cppcm-extra-preprocss-flags-from-user '("-I/usr/src/linux/include" "-DNDEBUG"))

(setq company-async-timeout 6)

(defun check-expansion ()
  (save-excursion
    (if (looking-at "\\_>") t
      (backward-char 1)
      (if (looking-at "\\.") t
	(backward-char 1)
	(if (looking-at "->") t nil)))))

(defun do-yas-expand ()
  (let ((yas/fallback-behavior 'return-nil))
    (yas/expand)))

(defun tab-indent-or-complete ()
  (interactive)
  (if (minibufferp)
      (minibuffer-complete)
    (if (or (not yas/minor-mode)
	    (null (do-yas-expand)))
	(if (check-expansion)
	    (company-complete)
	  (indent-for-tab-command)))))

(global-set-key [tab] 'tab-indent-or-complete)

;;evil-matchit mode enable
;;(require 'evil-matchit)
(global-evil-matchit-mode 1)

(defun cmake-rename-buffer ()
  "Renames a CMakeLists.txt buffer to cmake-<directory name>."
  (interactive)
					;(print (concat "buffer-filename = " (buffer-file-name)))
					;(print (concat "buffer-name     = " (buffer-name)))
  (when (and (buffer-file-name) (string-match "CMakeLists.txt" (buffer-name)))
					;(setq file-name (file-name-nondirectory (buffer-file-name)))
    (setq parent-dir (file-name-nondirectory (directory-file-name (file-name-directory (buffer-file-name)))))
					;(print (concat "parent-dir = " parent-dir))
    (setq new-buffer-name (concat "cmake-" parent-dir))
					;(print (concat "new-buffer-name= " new-buffer-name))
    (rename-buffer new-buffer-name t)
    )
  )

(add-hook 'cmake-mode-hook (function cmake-rename-buffer))

(defun my-cmake-fix-underscrore ()
  (modify-syntax-entry ?_  "_" cmake-mode-syntax-table))
(add-hook 'cmake-mode-hook 'my-cmake-fix-underscrore)

;; Tell emacs where to find the rosemacs sources
;; replace the path with location of rosemacs on your system
(push "~/.emacs.d/rosemacs" load-path) 
;; Load the library and start it up
(require 'rosemacs)
(invoke-rosemacs)
;; Optional but highly recommended: add a prefix for quick access
;; to the rosemacs commands
(global-set-key "\C-x\C-r" ros-keymap)

;; Configure pair. This plugin help to autoclosing bracket
(require 'autopair)
(autopair-global-mode 1)
(setq autopair-autowrap t)


;; Expand Member Functions.
(require 'member-functions)
(setq mf--source-file-extension "cpp")

(require 'workgroups2)
;; Change some settings
(workgroups-mode 1)        ; put this one at the bottom of .emacs


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(column-number-mode t)
 '(show-paren-mode t)
 '(tool-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(provide 'emacs)
;;; .emacs ends here
