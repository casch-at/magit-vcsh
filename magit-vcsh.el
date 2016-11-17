;; magit-vcsh.el --- A magit wrapper for vcsh -*- lexical-binding: t -*-
;;
;; Copyright (c) 2016 Christian Schwarzgruber
;;
;; Author: Christian Schwarzgruber <c.schwarzgruber.cs@gmail.com>
;;
;; Version: 0.1
;; Package-Requires: ((magit))
;; Keywords: git vcsh tools vc
;; URL: https://github.com/cslux/magit-vcsh

;;
;; magit-vcsh is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or (at
;; your option) any later version.
;;
;; magit-vcsh is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see http://www.gnu.org/licenses.
;;

;;; Commentary:

;; You need to call `magit-vcsh-status' the first time, afterwards you
;; can call any magit command.
;;
;; It's your responsibility to reset the saved magit variables, by
;; calling `magit-vcsh-magit-restore', to restore magit it's saved
;; state.
;;

;;; Code:

(require 'magit-git)

(defvar magit-vcsh--git-exectuable nil
  "Will hold the value of `magit-git-executable',
when calling `magit-vcsh-status' for the first time.")

(defvar magit-vcsh--git-global-arguments nil
  "Will hold the value of `magit-git-global-arguments',
when calling `magit-vcsh-status' for the first time.")

(defvar magit-vcsh-executable "vcsh"
  "The vcsh executable.")

;;;###autoload
(defun magit-vcsh-status (&optional arg)
  "Call `magit-status-internal' for vcsh repository.
When ARG is non-nil, or no vcsh repository has been chosen already,
ask for repository.

This is just a tiny magit wrapper for vcsh. All this function does is saving
the current value of `magit-git-exectuable' and `magit-git-global-arguments'.
Than it will set `magit-git-exectuable' to the vcsh executable and
will prepand the selected vcsh repository to `magit-git-global-arguments'.
The magit variables can be restored to the saved values by calling
`magit-vcsh-magit-restore'."
  (interactive "P")
  (let ((vcsh-repos (split-string
                     (shell-command-to-string
                      (format "%s list" magit-vcsh-executable))))
        vcsh-repo)
    (if (not vcsh-repos)
        (error "No vcsh repository created yet")
      (when (or (not magit-vcsh--git-global-arguments) arg)
        (setq vcsh-repo (completing-read "VCSH Repository: " vcsh-repos nil t)))
      (when vcsh-repo
        (unless magit-vcsh--git-exectuable
          (setq magit-vcsh--git-exectuable magit-git-executable)
          (setq magit-git-executable magit-vcsh-executable))
        (if magit-vcsh--git-global-arguments
            (when arg (pop magit-git-global-arguments))
          (setq magit-vcsh--git-global-arguments magit-git-global-arguments))
        (push vcsh-repo magit-git-global-arguments))
      (when (and magit-vcsh--git-exectuable
                 (member (car magit-git-global-arguments) vcsh-repos))
        (magit-status-internal (expand-file-name "~/"))))))

;;;###autoload
(defun magit-vcsh-magit-restore ()
  "Restore magit variables to the saved values."
  (interactive)
  (when magit-vcsh--git-exectuable
    (setq magit-git-executable magit-vcsh--git-exectuable
          magit-vcsh--git-exectuable nil))
  (when magit-vcsh--git-global-arguments
    (setq magit-git-global-arguments magit-vcsh--git-global-arguments
          magit-vcsh--git-global-arguments nil)))

(provide 'magit-vcsh)

;;; magit-vcsh.el ends here
