;;; package --- archive-project.el ---
;; 
;; Filename: archive-project.el
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
(defun my/org-roam-archive-project ()
  "Make the node Archive, switch PROJ to KILL and cancel unfinished task."
  (interactive)
  (defvar node-id nil)
  (defvar id-string nil)
  (let (( node-id (org-entry-get 1 "ID"))
	( id-string "id:")
	(org-roam-dailies-capture-templates
	 '(("t" "ARCHIVE" plain "**** KILL %(org-link-make-string
				  (concat id-string node-id)
				  (org-roam-node-title (org-roam-node-from-id id)))\nCLOSED: %U\n%(org-paste-subtree 5)\n"
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
    (save-window-excursion
      (org-roam-dailies--capture (current-time) nil))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; archive-project.el ends here

;; Local Variables:
;; jinx-local-words: "concat nCLOSED"
;; End:
