;;; package --- org-roam-project.el --- -*- lexical-binding: t -*-
;; 
;; Filename: org-roam-project.el
;; Description: archive org roam project
;; Author: Frédéric Willem
;; Created: jeu oct 26 22:51:06 2023 (+0200)
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;; Commentary:
;; 
;; 
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;; Change Log:
;; 
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or (at
;; your option) any later version.
;; 
;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;; 
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <https://www.gnu.org/licenses/>.
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;; Code:



(require 'org)
(require 'org-roam)
(require 'org-roam-dailies)

(defun org-roam-project-node-insert-immediate (arg &rest args)
  "Insert a node immediately.
For ARG and ARGS, see `org-roam-node-insert'"
  (interactive "P")
  (let ((args (push arg args)))
    (apply #'org-roam-node-insert args)))

(defun org-roam-project-filter-by-tag (tag-name)
  "Filter the project by TAG-NAME."
  (lambda (node)
    (member tag-name (org-roam-node-tags node))))

(defun org-roam-project-list-notes-by-tag (tag-name)
  "Search nodes by TAG-NAME."
  (mapcar #'org-roam-node-file
          (seq-filter
           (org-roam-project-filter-by-tag tag-name)
           (org-roam-node-list))))

(defun org-roam-project-refresh-agenda-list ()
  "Set the agenda.
These are the project files, the calendar file and
weekly file"
  (interactive )
  (setq org-agenda-files (org-roam-project-list-notes-by-tag "Project"))
  (add-to-list 'org-agenda-files (expand-file-name "calendar.org" org-roam-directory))
  (org-roam-project-add-to-agenda (current-time))
  (org-roam-project-add-to-agenda (time-subtract (current-time) (days-to-time 7))))

(defun org-roam-project-add-to-agenda (my-time)
  "Add to agenda list the weekly file.
MY-TIME is a the in the wanted week"
  (let ((org-roam-dailies-capture-templates
         '(("d" "default" entry "" :target
            (file+datetree "%<%Y-W%W>.org" 'week)
            :immediate-finish t
            :kill-buffer t)))
        today-file)
    (save-window-excursion
      (org-roam-dailies--capture my-time t)
      (save-buffer)
      (setq today-file (buffer-file-name))
      (add-to-list 'org-agenda-files today-file))))

(defun org-roam-project-project-finalize-hook ()
  "Add the captured project file to `org-agenda-files'.
If the capture was not aborted."
  ;; Remove the hook since it was added temporarily
  (remove-hook 'org-capture-after-finalize-hook #'org-roam-project-project-finalize-hook)

  ;; Add project file to the agenda list if the capture was confirmed
  (unless org-note-abort
    (with-current-buffer (org-capture-get :buffer)
      (add-to-list 'org-agenda-files (buffer-file-name)))))

(defun org-roam-project-find-project ()
  "Find a node tagged as Project."
  (interactive)
  ;; Add the project file to the agenda after capture is finished
  (add-hook 'org-capture-after-finalize-hook #'org-roam-project-project-finalize-hook)

  ;; Select a project file to open, creating it if necessary
  (org-roam-node-find
   nil
   nil
   (org-roam-project-filter-by-tag "Project")
   nil))


(defun org-roam-project-archive-project ()
  "Make the node Archive, switch PROJ to KILL and cancel unfinished task."
  (interactive)
  (defvar node-id nil)
  (defvar id-string nil)
  (let (( node-id (org-entry-get 1 "ID"))
	( id-string "id:")
	(org-roam-dailies-capture-templates
	 '(("t" "ARCHIVE" plain "**** KILL %(org-link-make-string
				  (concat id-string node-id)
				  (org-roam-node-title (org-roam-node-from-id node-id)))\nCLOSED: %U\n%(org-paste-subtree 5)\n"
	    :target (file+datetree "%<%Y-W%W>.org" 'week)
	    :immediate-finish t
	    :kill-buffer t))))
    (org-todo 'right)
    (org-map-tree (lambda ()
		    (if
			(and
			 (org-entry-is-todo-p)
			 (not (equal (org-entry-get nil "ITEM") "DONE")))
			(org-todo "CANCELLED"))))
    (org-roam-tag-add '("ARCHIVE"))
    (org-roam-tag-add '("ProjectArchive"))
    (org-roam-tag-remove '("Project"))
    (org-copy-subtree)
    (save-buffer)
    (setq org-agenda-files (delete buffer-file-name org-agenda-files))
    (save-window-excursion
      (org-roam-dailies--capture (current-time) nil))))

(defun org-roam-project-make-archive()
  "Action when tagging project tasks as ARCHIVE."
  (when (member "ARCHIVE" (org-get-tags))
    (org-roam-project-archive-project)))
(provide 'org-roam-project)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; org-roam-project.el ends here

;; Local Variables:
;; jinx-local-words: "concat nCLOSED"
;; End:
