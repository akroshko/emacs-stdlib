;;; emacs-stdlib-functions.el --- Standard emacs function that should
;;; have many uses.
;;
;; Copyright (C) 2015-2019, Andrew Kroshko, all rights reserved.
;;
;; Author: Andrew Kroshko
;; Maintainer: Andrew Kroshko <akroshko.public+devel@gmail.com>
;; Created: Fri Mar 27, 2015
;; Version: 20190228
;; URL: https://github.com/akroshko/emacs-stdlib
;;
;; This file is NOT part of GNU Emacs.
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 3, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Commentary:
;;
;; These are relatively generic functions, often the extensions of
;; ones in common packages.
;;
;; Features that might be required by this library:
;;
;; Generally only requires a basic Emacs installation.
;; TODO: Want to list requirements eventually, but see
;; emacs-config.el for some potential requires.
;; XXXX: Have not added some extremely common functions to having cic:
;; prefix.  May put these in their own file.
;;
;;; Code:

(defun cic:mpp (value &optional buffer)
  "Pretty print a message to a particular buffer and include a
time-stamp in the message.
XXXX: not adding cic: prefix before this function is called so often in adhoc code
TODO: flag to not use timestamp"
  (let ((message-string (concat "-- " (cic:time-stamp) "\n" (with-output-to-string (princ value)))))
    (unless buffer
      (setq buffer (get-buffer-create "*PPCapture*")))
    (with-current-buffer-max (get-buffer-create buffer)
                             (insert (concat message-string "\n")))))

(defun cic:mpp-echo (value &optional buffer)
  "Pretty print a message to a particular buffer and include a
time-stamp in the message.  Echo in minibuffer area as well.
XXXX: not adding cic: prefix before this function is called so often in adhoc code
TODO: flag to not use timestamp"
  (let* ((raw-message-string (with-output-to-string (princ value)))
         (message-string (concat (cic:time-stamp) "\n" raw-message-string)))
    (unless buffer
      (setq buffer (get-buffer-create "*PPCapture*")))
    (with-current-buffer-max (get-buffer-create buffer)
                             (insert (concat message-string "\n")))
    (message raw-message-string)))

;; (mpp-table '(("1" "2" "3") ("1" "2" "3")))
(defun mpp-table (obj)
  "Turn a list of lists into an org-table and pretty print."
  (with-temp-buffer
    (dolist (row obj)
      (dolist (column row)
        (insert "| ")
        (insert (pp-to-string column))
        (insert " "))
      (insert "|\n"))
    (point-min)
    (org-table-align)
    (mpp (buffer-string))))

;; XXXX: this could cause issues with debugging if function is made more complex
(when (not (fboundp 'cic:find-file-meta))
  (defun cic:find-file-meta (arg filename &optional wildcards)
    "A find file function that is often replaced with something else in my special setups"
    (cond ((equal arg nil)
           (find-file filename wildcards))
          ((equal arg '(4))
           (create-frame-here)
           (find-file filename wildcards))
          ((equal arg '(16))
           (create-frame-other-window-maximized)
           (find-file filename wildcards)))))

(when (not (fboundp 'cic:get-filename--meta))
  (defun cic:get-filename--meta (filename)
    "A get file function that is often replaced with something else in my special setups"
    filename))

(defun cic:time-stamp ()
  "Create a time-stamp."
  (format-time-string "%H:%M:%S" (current-time)))

(defun s-trim-full (str)
  "Strip full leading and trailing whitespace from STR.  Does
this for every line."
  (while (string-match "\\`\n+\\|^\\s-+\\|\\s-+$\\|\n+\\'"
                       str)
    (setq str (replace-match "" t t str)))
  str)

(defun s-trim-full-no-properties (str)
  "Like strip-full but remove text properties."
  (substring-no-properties (s-trim-full str)))

(defun cic:trim-into-one-line (str)
  "Convert STR into one line with no leading or trailing whitespace."
  (while (string-match "[[:space:]]*\n+[[:space:]]*\\|[[:space:]]\\{2,\\}"
                       str)
    (setq str (replace-match " " t t str)))
  (s-trim-full str))

(defun s-trim-colons (str)
  "Strip leading and trailing colons off of STR."
  (when (stringp str)
    (while (string-match "^:" str)
      (setq str (replace-match "" t t str)))
    (while (string-match ":$" str)
      (setq str (replace-match "" t t str))))
  str)

(defun cic:trim-trailing-slash (str)
  "Strip trailing slash off of STR."
  (when (stringp str)
    (while (string-match "/$" str)
      (setq str (replace-match "" t t str))))
  str)

;; TODO: move this to appropriate place
(defun cic:trim-uid-org-link (str)
  "Trim out uid from org-link."
  (if (stringp str)
      (replace-regexp-in-string "=[A-Z0-9]\\{11\\}=$" "" str)
    str))

(defun cic:trim-after-double-colon (str)
  "Strip everything after and including a double colon in STR."
  (when (stringp str)
    (if (string-match "\\(.*\\)::.*" str)
        (setq str (match-string 1 str))))
  str)

(defun s-trim-square-brackets (str)
  "Strip leading and trailing square brackets off of STR."
  (when (stringp str)
    (while (string-match "^\\[" str)
      (setq str (replace-match "" t t str)))
    (while (string-match "\\]$" str)
      (setq str (replace-match "" t t str))))
  str)

(defun s-trim-dashes (str)
  "Strip leading and trailing dashes off of STR."
  (when (stringp str)
    (while (string-match "^-" str)
      (setq str (replace-match "" t t str)))
    (while (string-match "-$" str)
      (setq str (replace-match "" t t str))))
  str)

(defun s-trim-leading-dashes (str)
  "Strip leading dashes off of STR."
  (when (stringp str)
    (while (string-match "^-" str)
      (setq str (replace-match "" t t str))))
  str)

(defun cic:full-string-p (thing-or-string)
  "Determine if something is nil or an empty string."
  (if (or (not thing-or-string) (equal (s-trim-full thing-or-string) ""))
      nil
    t))

;; taken from stackoverflow
(defun cic:count-occurences (regex string)
  "Count the occurences of REGEX in STRING."
  (cic:recursive-count regex string 0))

(defun cic:recursive-count (regex string start)
  "Helper function for cic:count-occurences to Recursively count
REGEX in STRING from the START character."
  (if (string-match regex string start)
      (1+ (cic:recursive-count regex string (match-end 0)))
    0))

(defun cic:string-to-float (str)
  "Convert STR to float."
  (let (new-var)
    (when (stringp str)
      (setq str (string-to-number str)))
    (unless (floatp str)
      (setq str (float str)))
    str))

(defun cic:string-to-float-empty-zero (str)
  "Convert STR to float or return zero for a nil or empty
string."
  (if (cic:is-not-empty-string-nil str)
      (cic:string-to-float str)
    0))

(defun subseq-short (seq start &optional end)
  "Take subsequence froma sequence that is possibly too short."
  (let ((length-seq (length seq)))
    (if (< length-seq end)
        (subseq seq start length-seq)
      (subseq seq start end))))

;; TODO: there is a directory-list-recursively (or similar...)
;; http://www.emacswiki.org/emacs/ElispCookbook#toc59
(defun cic:walk-path (dir action)
  "Walk DIR executing ACTION with arugments (dir file)"
  (cond ((file-directory-p dir)
         (or (char-equal ?/ (aref dir(1- (length dir))))
             (setq dir (file-name-as-directory dir)))
         (let ((lst (directory-files dir nil nil t))
               fullname file)
           (while lst
             (setq file (car lst))
             (setq lst (cdr lst))
             (cond ((member file '("." "..")))
                   (t
                    (and (funcall action dir file)
                         (setq fullname (concat dir file))
                         (file-directory-p fullname)
                         (cic:walk-path fullname action)))))))
        (t
         (funcall action
                  (file-name-directory dir)
                  (file-name-nondirectory dir)))))

(defun cic:org-find-headline (headline &optional buffer)
  "Find a particular HEADLINE in BUFFER."
  (goto-char (org-find-exact-headline-in-buffer headline)))

(defun cic:org-find-checkbox (name)
  "Find a particular checkbox with text NAME in BUFFER.
TODO: Currently prefix search, do I want an exact search?"
  (re-search-forward (concat cic:emacs-stdlib-checkbox-regexp name))
  (move-beginning-of-line 1))

(defun cic:org-find-list-item (name)
  "Find a particular list item with text NAME in BUFFER.
TODO: Currently actually prefix search, do I want an exact search?"
  (re-search-forward (concat cic:emacs-stdlib-list-exact-regexp name))
  (move-beginning-of-line 1))

(defun cic:org-find-table (&optional count)
  "Find a particular table with text NAME (based on headline) in BUFFER.
"
  (unless count
    (setq count 1))
  (dotimes (i count)
    (while (not (or (org-table-p) (eobp)))
      (forward-line 1))
    (when (< i (- count 1))
      (cic:org-table-last-row)
      (forward-line 2))))

(defun cic:org-table-to-lisp-no-separators ()
  "Convert the org-table to lisp and eliminate seperators."
  (remove-if-not (lambda (x) (if (eq x 'hline) nil x)) (org-table-to-lisp)))

(defun cic:org-table-last-row ()
  "Goto the last row of the next table in the buffer.."
  (let (table-next
        seperator-next
        table-next-next
        (keep-going t))
    (while keep-going
        (save-excursion
          (forward-line 1)
          (setq table-next (org-table-p))
          (setq seperator-next (string-match "|-+\+.*|" (cic:get-current-line)))
          (forward-line 1)
          (setq table-next-next (org-table-p)))
        (if (or
               (and table-next (not seperator-next))
               (and table-next seperator-next table-next-next))
            (forward-line)
          (setq keep-going nil)))))

(defun cic:org-table-lookup-location (filename table-name key-value &optional column)
  "Lookup the location (in buffer) of KEY-VALUE from TABLE-NAME
in FILENAME given COLUMN number."
  (unless column
    (setq column 1))
  (when (not (listp filename))
    (setq filename (list filename)))
  (let (found-list)
    (dolist (the-filename filename)
      (list (do-org-table-rows the-filename table-name row
                               (org-table-goto-column column)
                               (when (string= key-value (s-trim-full (org-table-get nil column)))
                                 (setq found-list (append found-list (list (list the-filename (point)))))))))
    (setq found-list (delq nil found-list))
    (when (> (length found-list) 1)
      (error "Found too many locations!!!"))
    (car found-list)))

(defun cic:org-table-lookup-row (filename table-name key-value  &optional column)
  "Lookup the row (in elisp) of KEY-VALUE from TABLE-NAME in FILENAME given COLUMN.
number."
  (unless column
    (setq column 1))
  (let (lisp-table
        found-row)
    (with-current-file-transient-org-table filename table-name
                                 (setq lisp-table (cic:org-table-to-lisp-no-separators)))
    (do-org-table-rows filename table-name row
                       (org-table-goto-column column)
                       (when (string= key-value (s-trim-full (org-table-get nil column)))
                         (setq found-row (cic:org-table-assoc lisp-table key-value column))))
    found-row))

(defun cic:org-table-get-keys (filename table-name &optional column)
  "Get the list of keys from TABLE-NAME in FILENAME given
COLUMN. number"
  (unless column
    (setq column 1))
  (let (key-values)
    (do-org-table-rows filename table-name row
                       (org-table-goto-column column)
                       (setq key-values (cons (s-trim-full-no-properties (org-table-get nil column)) key-values)))
    (remove-if 'full-string-p key-values)
    key-values))

(defun cic:org-table-select-key (filename table-name prompt &optional column history-variable)
  "Select key using completing-read with PROMPT from TABLE-NAME
in FILENAME given COLUMN number."
  (unless column
    (setq column 1))
  (completing-read prompt (cic:org-table-get-keys filename table-name column) nil t history-variable))

(defun cic:org-table-assoc (lisp-table key &optional column equal-test)
  "Get row associated with KEY from LISP-TABLE."
  (unless column
    (setq column 1))
  (cic:assoc-nth column key lisp-table equal-test))

(defun cic:assoc-nth (n key assoc-list &optional equal-test)
  "Get the Nth item from the KEY from ASSOC-LIST with an optional
EQUAL-TEST that defaults to equal"
  (unless equal-test
    (setq equal-test 'equal))
  (let (selected
        (zeron (- n 1)))
    (dolist (item assoc-list)
      (when (funcall equal-test key (nth zeron item))
        (setq selected item)))
    selected))

(defun cic:get-headline-text (headline-line)
  "Get just the clean headline text from HEADLINE-LINE
representing the text of a line the headline is on."
  (let (headline-text)
    (when (string-match cic:emacs-stdlib-headline-regexp headline-line)
      (setq headline-text (match-string 1 headline-line)))))

(defun cic:org-headline-p (line-substring)
  "Is LINE-SUBSTRING an org-mode headline?"
  (string-match cic:emacs-stdlib-headline-regexp line-substring))

(defun cic:org-list-p (line-substring)
  "Is LINE-SUBSTRING an org-mode list item?"
  (string-match cic:emacs-stdlib-list-regexp line-substring))

(defun cic:org-plain-list-p (line-substring)
  "Is LINE-SUBSTRING a plain (no checkboxes) org-mode list item?"
  (and
   (string-match cic:emacs-stdlib-list-regexp line-substring)
   (not (string-match cic:emacs-stdlib-checkbox-regexp line-substring))))

(defun cic:org-checkbox-p (line-substring)
  "Is LINE-SUBSTRING an org-mode checkbox item?"
  (string-match cic:emacs-stdlib-checkbox-regexp line-substring))

(defun cic:org-check-last-heading-level-1 ()
  "Check if we are at the last heading level 1 in the file.  To
see if a loop can keep going."
  (let ((line-no (line-number-at-pos)))
    (save-excursion
      (org-forward-heading-same-level 1 nil)
      (if (equal line-no (line-number-at-pos))
          nil
        t))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; macros to do things temporarily

;; XXXX: set filename filter if not already set, used for filenames in
;; special formats that may be declared late
(unless (fboundp 'with-filename-filter)
  (fset 'with-filename-filter 'identity))

;; do I want to do other headlines too, or within a headline
(defmacro do-org-headlines (filename headline-name headline-subtree &rest body)
  "Iterate over headlines in FILENAME. HEADLINE-NAME holds the
headline itself with HEADLINE-SUBTREE containing the subtree that
the HEADLINE represents."
  (declare (indent 1) ;; (debug t)
           )
  `(save-excursion
     (set-buffer (find-file-noselect (with-filename-filter ,filename)))
     (goto-char (point-min))
     (let ((keep-going t))
       (while keep-going
         ;; next headline same level
         (if (re-search-forward (concat "^\* .*")  nil t)
             (progn
               (beginning-of-line)
               (let ((current-line (cic:get-current-line)))
                 (setq ,headline-name (when (string-match "^\* \\(.*\\)" current-line)
                                        (match-string 1 current-line)))
                 (setq ,headline-subtree (buffer-substring (point) (save-excursion
                                                                     (org-end-of-subtree)
                                                                     (point)))))
               ,@body
               (end-of-line))
           (setq keep-going nil))))))

;; TODO want to allow files with table-less headlines
(defmacro do-org-tables (filename table-name table &rest body)
  "Iterate over tables in FILENAME. TABLE-NAME holds the table
name itself with TABLE containing a lisp representation of the
table.  While iterating might position cursor in first column and
first row of table.  Use save-excursion while moving in the body
of this macro, just in case."
  (declare (indent 1) ;; (debug t)
           )
  `(save-excursion
     (set-buffer (find-file-noselect (with-filename-filter ,filename)))
     (goto-char (point-min))
     ;; TODO figure out best layout for file and best way to do this
     (let ((keep-going t))
       (while keep-going
         ;; next headline same level
         (when (string-match cic:emacs-stdlib-headline-regexp (cic:get-current-line))
           (setq ,table-name (match-string 1 (cic:get-current-line))))
         (save-excursion
           (forward-line 1)
           (setq ,table nil)
           (while (not (or (and (cic:org-headline-p (cic:get-current-line)) (= (org-outline-level) 1)) (org-table-p) (eobp)))
             (forward-line 1))
           (when (org-table-p)
             (setq ,table (cic:org-table-to-lisp-no-separators))))
         (when (and ,table-name ,table)
           ,@body)
         ;; see if we can keep going
         (setq keep-going (cic:org-check-last-heading-level-1))
         ;; if not end
         (when keep-going
           (org-forward-heading-same-level 1 nil))))))

;; TODO: make sure we can deal with seperators
(defmacro do-org-table-rows (filename table-name row &rest body)
  "Iterate over the rows of the table TABLE-NAME in FILENAME.
ROW contains the current row converted into elisp."
  (declare (indent 1) ;; (debug t)
           )
  `(save-excursion
     (set-buffer (find-file-noselect (with-filename-filter ,filename)))
     (goto-char (point-min))
     ;; TODO replace with org-headline-goto???
     ;; XXXX: complicated regexp deals with tags
     (when (re-search-forward (concat "^\* " ,table-name "\\([[:space:]]:.*\\)?$") nil t)
       (cic:org-find-table)
       (let ((keep-going t)
             (lisp-table (cic:org-table-to-lisp-no-separators))
             (row-count 0))
         (while keep-going
           (unless (string-match "|-+\+.*|" (cic:get-current-line))
             (setq ,row (nth row-count lisp-table))
             ,@body
             (setq row-count (1+ row-count)))
           (save-excursion
             ;; TODO need to catch error or whatever from this
             (forward-line 1)
             (unless (org-at-table-p)
               (setq keep-going nil)))
           (when keep-going
             (forward-line 1)))))))

;; think, like table with table-row, should get item-lines
(defmacro do-org-list-items (filename list-name item-line &rest body)
  "Iterate over the items of list LIST-NAME in FILENAME.
ITEM-LINE contains the line that a particular item is on."
  (declare (indent 1) ;; (debug t)
           )
  `(save-excursion
     (set-buffer (find-file-noselect (with-filename-filter ,filename)))
     (goto-char (point-min))
     (when (re-search-forward (concat "^\* " ,list-name "$") nil t)
       (forward-line 1)
       (let ((keep-going t))
         (while keep-going
           (setq ,item-line (cic:get-current-line))
           ,@body
           (save-excursion
             (forward-line 1)
             (when (or (and (cic:org-headline-p (cic:get-current-line)) (= (org-outline-level) 1)) (progn (end-of-line) (eobp)))
               (setq keep-going nil)))
           (when keep-going
             (forward-line 1)))))))

(defmacro set-unless (var &rest body)
  "Set a variable with body if it is nil."
  (error))

(defmacro when-string-match (pattern string group matched &rest body)
  "When GROUP of PATTERN matches string set MATCHED to the result
and execute BODY.."
  (declare (indent 1) ;; (debug t)
           )
  `(unless ,group
     (setq ,group 0))
  `(when (string-match ,pattern ,string)
     (setq ,matched (match-string ,group ,string))
     ,@body))

(defmacro with-current-buffer-create (buffer-or-name &rest body)
  "Create BUFFER-OR-NAME if nonexistant and run BODY like
with-current-buffer."
  (declare (indent 1) ;; (debug t)
           )
  `(save-excursion
     (set-buffer (get-buffer-create ,buffer-or-name))
     ,@body))

(defmacro with-current-buffer-min (buffer-or-name &rest body)
  "Like with-current-buffer but always go to point min."
  `(save-excursion
     (set-buffer ,buffer-or-name)
     (goto-char (point-min))
     ,@body))

(defmacro with-current-buffer-max (buffer-or-name &rest body)
  "Like with-current-buffer but always go to point max."
  `(save-excursion
     (set-buffer ,buffer-or-name)
     (goto-char (point-max))
     ,@body))

(defmacro with-current-buffer-erase (buffer-or-name &rest body)
  "Like with-current-buffer but always erase it."
  `(save-excursion
     (set-buffer ,buffer-or-name)
     (setq buffer-read-only nil)
     (erase-buffer)
     ,@body))

(defmacro with-current-file (filename &rest body)
  "Execute BODY with FILENAME as buffer.  Uses
with-filename-filter."
  (declare (indent 1) ;; (debug t)
           )
  `(save-excursion
     (set-buffer (find-file-noselect (with-filename-filter ,filename)))
     ,@body))

(defmacro with-current-file-transient (filename &rest body)
  "Execute BODY with FILENAME as buffer.  Close the file if it
does not already exist Uses with-filename-filter."
  (declare (indent 1) ;; (debug t)
           )
  `(save-excursion
     (let ((already-existing-buffer (get-file-buffer ,filename))
           (current-file-buffer (find-file-noselect (with-filename-filter ,filename))))
       (set-buffer current-file-buffer)
       ,@body
       (unless already-existing-buffer
         (kill-buffer current-file-buffer)))))

(defmacro with-current-file-transient-headline (filename headline &rest body)
  "Execute BODY with FILENAME as buffer after finding HEADLINE.
Uses with-filename-filter."
  (declare (indent 1) ;; (debug t)
           )
  `(save-excursion
     (let (((already-existing-buffer (get-file-buffer ,filename))
            (current-file-buffer (find-file-noselect (with-filename-filter ,filename))))))
     (set-buffer the-buffer)
     (cic:org-find-headline ,headline)
     (let ((the-return (progn
                         ,@body)))
       (unless already-existing-buffer
         (kill-buffer current-file-buffer))
       the-return)))

(defmacro with-current-file-min (filename &rest body)
  "Like with-current-file, but always go to point-min."
  (declare (indent 1) ;; (debug t)
           )
  `(save-excursion
     (set-buffer (find-file-noselect (with-filename-filter ,filename)))
     (goto-char (point-min))
     ,@body))

(defmacro with-current-file-transient-min (filename &rest body)
  "Like with-current-file, but always go to point-min."
  (declare (indent 1) ;; (debug t)
           )
  `(save-excursion
     (let ((already-existing-buffer (get-file-buffer ,filename))
           (current-file-buffer (find-file-noselect (with-filename-filter ,filename))))
       (set-buffer current-file-buffer)
       (goto-char (point-min))
       (let ((the-return (progn
                           ,@body)))
         (unless already-existing-buffer
           (kill-buffer current-file-buffer))
         the-return))))

(defmacro with-current-file-max (filename &rest body)
  "Like with-current-file, but always go to point max."
  (declare (indent 1) ;; (debug t)
           )
  `(save-excursion
     (set-buffer (find-file-noselect (with-filename-filter ,filename)))
     (goto-char (point-max))
     ,@body))

(defmacro with-current-file-transient-max (filename &rest body)
  "Like with-current-file, but always go to point max."
  (declare (indent 1) ;; (debug t)
           )
  `(save-excursion
     (let ((already-existing-buffer (get-file-buffer ,filename))
           (current-file-buffer (find-file-noselect (with-filename-filter ,filename))))
       (set-buffer current-file-buffer)
       (goto-char (point-max))
       (let ((the-return (progn
                           ,@body)))
         (unless already-existing-buffer
           (kill-buffer current-file-buffer))
         the-return))))

(defmacro with-current-file-transient-org-table (filename table-name &rest body)
  "Like with-current-file, but find TABLE-NAME."
  (declare (indent 1) ;; (debug t)
           )
  `(save-excursion
     (let ((already-existing-buffer (get-file-buffer ,filename))
           (current-file-buffer (find-file-noselect (with-filename-filter ,filename))))
       (set-buffer current-file-buffer)
       (goto-char (point-min))
       (when (re-search-forward (concat "^\* " ,table-name "$") nil t)
         (cic:org-find-table)
         (let ((the-return (progn
                             ,@body)))
           (unless already-existing-buffer
             (kill-buffer current-file-buffer))
           the-return)))))

(defun cic:car-fallthrough (object)
  "If car-safe does not work, just return the object.  Otherwise
return car of OBJECT."
  (if (car-safe object)
      (car object)
    object))

(defun cic:cdr-fallthrough (object)
  "If cdr-safe does not work, just return OBJECT. Otherwise
return cdr of OBJECT."
  (if (cdr-safe object)
      (cdr object)
    object))

; http://www.emacswiki.org/emacs/ElispCookbook#toc20
(defun cic:string-integer-p (string)
  "Check if STRING is an integer."
  (when (string-match "\\`[-+]?[0-9]+\\'" string)
      t))

(defun cic:string-float-p (string)
  "Check if STRING is a floating point number."
  (when (string-match "\\`[-+]?[0-9]+\\.[0-9]*\\'" string)
      t))

;; XXXX: why does this work?
(defun cic:zip (&rest streams)
  "Zip function like in many programming languages."
  (apply #'mapcar* #'list streams))

(defun cic:ensure-list (object)
  "Turn an OBJECT that is not a list into a list.  If it is
already a list then leave it alone."
  (unless (listp object)
          (setq object (list object)))
  object)

(defun cic:car-only (lst)
  "Ensure a list is only length 1 and get the car.  Raise an
error is list is longer than length 1."
  (when (> (length lst) 1)
    (error))
  (car lst))

(defun cic:nts-nan (num &optional format-string)
  "Like number-to-string but returns a nil for nan.
TODO: Make formatting an option so more universal."
  (unless format-string
    (setq format-string "%4.3f"))
  (if (or (not num) (isnan (float num)) (= num 1.0e+INF) (= num -1.0e+INF))
      ""
    (format format-string num)))

(defun cic:org-last-headline ()
  "Goto last headline in the current buffer."
  (goto-char (point-min))
  (when (not (cic:org-headline-p))
    (org-forward-element))
  (let (headline-position-list)
    (do-org-headlines buffer-file-name headline subtree
                      (setq headline-position-list (append headline-position-list (list (point)))))
    (goto-char (car (last headline-position-list)))))

(defun cic:delete-substring (substring-regexp string)
  "Delete the substring matched by SUBSTRING-REGEXP from STRING."
  (if (string-match substring-regexp string)
      (let ((beg (match-beginning 0))
            (end (match-end 0)))
        (concat (substring string 0 beg) (substring string end)))
    string))

;; http://www.emacswiki.org/emacs/ElispCookbook#toc4
(defun ends-with (string suffix)
  "Return t if STRING ends with SUFFIX."
  (and (string-match (rx-to-string `(: ,suffix eos) t)
                         string)
       t))

(defun starts-with (string prefix)
  "Return t if STRING starts with prefix."
  (and (string-match (rx-to-string `(: bos ,prefix) t)
                     string)
       t))

;; XXXX: I really do want this here if the following function will be useful at all
(random t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; file helpers

;; do we open a new window?
;; do we switch?
;; TODO this can be fixed a lot!!!
;; TODO ensure no line argument goes to line 1
;; make sure existing buffer is opened!!!
(defun cic:find-file-other-window-goto-line (filename &optional line alternate)
  "Find and select FILENAME in other window and goto line number
LINE."
  (let ((old-buffer (current-buffer))
        (old-window (get-buffer-window))
        new-buffer)
    (save-excursion
      ;; pop open new file in other buffer
      (setq new-buffer (find-file-other-window filename))
      (switch-to-buffer new-buffer)
      ;; jump to the correct line, in case buffer is already open
      (goto-char (point-min))
      (forward-line (1- line)))
  (select-window old-window)
  (set-buffer old-buffer)))

(defun cic:list-files (path)
  "List files in PATH."
  (remove-if-not (lambda (e)
                   (not (file-directory-p (cic:join-paths path e))))
                     (directory-files path)))

;; TODO: option to take out dot directories?
(defun cic:list-directories (path)
  "List directories in PATH.  Gets rid of . and .."
  (let ((the-dirs (remove-if-not (lambda (e)
                                       (file-directory-p (cic:join-paths path e)))
                                 (directory-files path))))
    ;; TODO: do one operation using pattern matching
    (cl-remove ".." (cl-remove "." the-dirs :test #'string=) :test #'string=)))

(defun cic:find-file-goto-line (filename &optional line)
  (let ((old-buffer (current-buffer))
        (old-window (get-buffer-window))
        new-buffer)
    (save-excursion
      ;; pop open new file in other buffer
      (setq new-buffer (find-file filename))
      (switch-to-buffer new-buffer)
      ;; jump to the correct line, in case buffer is already open
      (goto-char (point-min))
      (when line
        (forward-line (1- line))))
  (select-window old-window)
  (set-buffer old-buffer)))

(defun cic:is-empty-string-whitespace (str)
  "Test if STR is empty, all whitespace, or nil."
  (when str
    (string-equal (s-trim-full str) "")))

(defun cic:is-not-empty-string-nil (str)
  "Check if STR is an empty string (no characters or all
whitespace) or a nil."
  (and str (not (string= (s-trim-full str) ""))))

(defun cic:delete-current-line ()
  "Delete the current line without touching the kill ring.
TODO: this function needs work."
;; TODO: use this from  https://www.emacswiki.org/emacs/ElispCookbook#toc13
;; (let ((beg (point)))
;;    (forward-line 1)
;;    (forward-char -1)
;;    (delete-region beg (point)))
  (let ((p1 (line-beginning-position))
        saved-text-properties
        p2)
    (save-excursion
      (goto-char (line-end-position))
      (forward-line 1)
      ;; save text properties
      ;; (setq saved-text-properties (text-properties-at (point)))
      (setq p2 (point)))
    (delete-region p1 p2)
    ;; restore text properties
    ;; TODO make actually work for all situations
    ;; (add-text-properties (point) (1+ (point)) saved-text-properties)
    ))

;;from http://ergoemacs.org/emacs/elisp_all_about_lines.html
(defun cic:get-current-line ()
  "Get the current line."
  (buffer-substring-no-properties (line-beginning-position) (line-end-position)))

;; TODO: this is odd, can't seem to work
(defun cic:check-convert-number-to-string (number)
  "Try and convert NUMBER to a string, or just return untouched
if not possible."
  (if (string-integer-p number)
      (string-to-number number)
    number))

;; TODO: appears no longer used
;; (defmacro with-time (time-output-p &rest exprs)
;;   "Evaluate an org-table formula, converting all fields that look
;; like time data to integer seconds.  If TIME-OUTPUT-P then return
;; the result as a time value."
;;   (list
;;    (if time-output-p 'cic:org-time-seconds-to-string 'identity)
;;    (cons 'progn
;;          (mapcar
;;           (lambda (expr)
;;             `,(cons (car expr)
;;                     (mapcar
;;                      (lambda (el)
;;                        (if (listp el)
;;                            (list 'with-time nil el)
;;                          (cic:org-time-string-to-seconds el)))
;;                      (cdr expr))))
;;           `,@exprs))))

;; (defun cic:org-time-seconds-to-string (secs)
;;   "Convert a number of seconds to a time string."
;;   (cond ((>= secs 3600) (format-seconds "%h:%.2m:%.2s" secs))
;;         ((>= secs 60) (format-seconds "%m:%.2s" secs))
;;         (t (format-seconds "%s" secs))))

;; (defun cic:org-time-string-to-seconds (s)
;;   "Convert a string HH:MM:SS to a number of seconds."
;;   (cond
;;    ((and (stringp s)
;;          (string-match "\\([0-9]+\\):\\([0-9]+\\):\\([0-9]+\\)" s))
;;     (let ((hour (string-to-number (match-string 1 s)))
;;           (min (string-to-number (match-string 2 s)))
;;           (sec (string-to-number (match-string 3 s))))
;;       (+ (* hour 3600) (* min 60) sec)))
;;    ((and (stringp s)
;;          (string-match "\\([0-9]+\\):\\([0-9]+\\)" s))
;;     (let ((min (string-to-number (match-string 1 s)))
;;           (sec (string-to-number (match-string 2 s))))
;;       (+ (* min 60) sec)))
;;    ((stringp s) (string-to-number s))
;;    (t s)))

(defun cic:symbol-to-string-or-list (maybe-string-list)
  "Dereference a symbol to (presumably) a string or list of
strings. Leave alone if already a string or list of strings.
TODO: this is a messed up function I can probably delete
"
  (let (new-string-list)
    (if (symbolp maybe-string-list)
        (setq new-string-list (symbol-value maybe-string-list))
      (setq new-string-list maybe-string-list))
    (cic:ensure-list new-string-list)))

(defun cic:symbol-value (maybe-symbol)
  "Dereference a symbol to it's value."
  (if (symbolp maybe-symbol)
      (symbol-value maybe-string-list)
    (setq new-string-list maybe-symbol)))

(defun increment-char (ch)
  "Not perfect, need better way sometimes to select file..."
  (cond ((string= ch "z")
         "A")
        ((string= ch "Z")
         "1")
        (t
         (char-to-string (1+ (string-to-char ch))))))
;; (cic:select-list-item (list "item1" "item2"))
(defun cic:select-list-item (lst &optional string-key header-message)
  "Select a string from a list of strings LST using alphabet then number keys.
TODO: use string-key to select a string"
  (let* ((count "a")
         (index-count 0)
         (cancel 'cancel)
         (select-alist (mapcar (lambda (e)
                                 (let (the-list)
                                   (if string-key
                                       (setq thelist (list count (funcall string-key e) index-count))
                                     (setq thelist (list count e e)))
                                   (setq count (increment-char count))
                                   (setq index-count (1+ index-count))
                                   thelist))
                               lst)))
    (cic:select-alist select-alist
                      header-message
                      (lambda (e)
                        (setq selected e)))))

(defun cic:select-list-item-default-index (lst &optional string-key default-value)
  "Select a list item from LST.
TODO: document more"
  (let* ((count "a")
         (index-count 0)
         (cancel 'cancel)
         (default 'default)
         (select-alist (mapcar (lambda (e)
                                 (let (thelist)
                                   (if string-key
                                       (setq thelist (list count (funcall string-key e) index-count))
                                     (setq thelist (list count e index-count)))
                                   (setq count (increment-char count))
                                   (setq index-count (1+ index-count))
                                   thelist))
                               lst)))

    (when default-value
        (setq select-alist (append select-alist (list (list "0" (concat "default " default-value) 'default)))))
    (cic:select-alist select-alist
                      ""
                      (lambda (e)
                        (setq selected e)))))

(defun replace-nonprintable (str)
  "Replace non-printable characters with blanks in STR.
TODO: No str variable name and replace some bad characters with
dsimilar ones."
  (replace-regexp-in-string "[^[:print:]]" "" str))

(defun cic:get-list-duplicates (lst)
  "Get the duplicate items in list LST."
  (set-difference lst (remove-duplicates lst :test 'equal)))

(defun cic:test-strings-in-list (lst1 lst2)
  "Tests if any items in LST1 are also in LST2."
  (cl-intersection lst1 lst2 :test 'string=))

;; http://ergoemacs.org/emacs/elisp_read_file_content.html
(defun cic:read-file-lines (filepath)
  "Return a list of lines of a file at filePath."
  (with-temp-buffer
    (insert-file-contents filepath)
    (split-string (buffer-string) "\n" t)))

(defun cic:read-file-regexp (filepath)
  "Return a list of lines of a file at FILEPATH.  All lines are
properly escaped and combined with | to be an emacs regexp."
  (let ((file-lines (cic:read-file-lines filepath)))
    ;; rather than identity I need a generic escape function
    (mapconcat 'cic:escape-posix-regexp file-lines "\\|")))

(defun cic:escape-posix-regexp (posix-regexp)
  "Escapes a few select posix regexps to emacs regexps.
  Generally functionality is added here as needed."
  (replace-regexp-in-string (regexp-quote "\\\\") "\\\\" posix-regexp))

(defun cic:join-paths (&rest args)
  "Join paths in elisp.

   XXX: Only works with two arguments!"
  (concat (file-name-as-directory (car args)) (cadr args)))

(defun count-indentation (&optional current-line)
  "Count the indentation level in CURRENT-LINE, if nil use the
current line at point."
  (unless current-line
    (setq current-line (cic:get-current-line)))
  (- (length current-line) (length (s-trim-left current-line))))

(defun cic:list-from-file-filename (filename)
  "Get a list based on the lines in FILENAME."
  (remove-if-not 'cic:is-not-empty-string-nil
                 (with-temp-buffer
                   (insert-file-contents filename)
                   (split-string (buffer-substring-no-properties (point-min) (point-max)) "\n"))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; filesystem helper functions

(defun cic:find-file-upwards (file-to-find)
  "Recursively searches each parent directory starting from the default-directory.
looking for a file with name file-to-find.  Returns the path to it
or nil if not found."
  (cl-labels
      ((find-file-r (path)
                    (let* ((parent (file-name-directory path))
                           (possible-file (concat parent file-to-find)))
                      (cond
                       ((file-exists-p possible-file) possible-file) ;; Found
                       ;; The parent of ~ is nil and the parent of / is itself.
                       ;; Thus the terminating condition for not finding the file
                       ;; accounts for both.
                       ((or (null parent) (equal parent (directory-file-name parent))) nil) ;; Not found
                       (t (find-file-r (directory-file-name parent))))))) ;; Continue
    (find-file-r default-directory)))

(defun cic:org-show-previous-heading-tidily ()
  "Show previous entry, keeping other entries closed.
TODO: figure out what to do with this and whether I use it?"
  (let ((pos (point)))
    (outline-previous-heading)
    (unless (and (< (point) pos) (bolp) (org-on-heading-p))
      (goto-char pos)
      (hide-subtree)
      (error "Boundary reached"))
    (org-overview)
    (org-reveal t)
    (org-show-entry)
    (show-children)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; new functions

(defun goto-location (location)
  "XXXX: A helper function that will soon be replaced.
Abstraction level is too high."
  (if (stringp (car location))
      (progn
        (find-file (car location))
        (when (derived-mode-p 'org-mode)
          (org-show-all))
        (goto-char (cadr location)))
    (progn
      (switch-to-buffer (car location))
      (when (derived-mode-p 'org-mode)
        (org-show-all))
      (goto-char (cadr location)))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; string, shell command, and shell helpers

(defun cic:make-shell-command (&rest args)
  "Create a shell command from ARGS.

XXXX: Not currently used or tested."
  (concat (car args) " " (combine-and-quote-strings (cdr args))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; thing at point bounds

(defun cic:region-or-thing-at-point-no-properties (thing)
  "Select either a region if active or the thing-at-point."
  (let ((current-thing (cic:region-or-thing-at-point thing)))
    (if current-thing
        (substring-no-properties current-thing)
      nil)))

(defun cic:region-or-thing-at-point (thing)
  "Select either a region if active or the thing-at-point."
  (let (selected-text)
    (if (region-active-p)
        (setq selected-text (buffer-substring (mark) (point)))
      (setq selected-text (thing-at-point thing)))
    selected-text))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; current filename
(defun cic:get-current-filename ()
  "Get the current filename based on context."
  (cond ((derived-mode-p 'dired-mode)
         (file-name-nondirectory (cic:dired-filename-at-point)))
        (t
         (file-name-nondirectory buffer-file-name))))

;; from https://github.com/jimm/elisp/blob/master/emacs.el
;; http://en.wikipedia.org/wiki/Password_strength
;; 24 alphanumpunc characters = 144 bits of entropy

(defconst cic:password-characters-Alphanum
  "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
  "This is 62 characters total")

(defconst cic:password-characters-alphanum-lower
  "0123456789abcdefghijklmnopqrstuvwxyz"
  "This is 36 characters total")

(defconst cic:password-characters-Alphanum-punct
  "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!?@#$%^&*-_=+/.,"
  "This is 78 characters total.")

(defconst cic:password-characters-Alpha
  "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
  "This is 52 characters total.")

(defconst cic:password-characters-alpha-lower
  "abcdefghijklmnopqrstuvwxyz"
  "This is 26 characters total.")

(defun cic:create-password (char-set char-num &optional random-source)
  "Create a random password from CHAR-SET that is CHAR-NUM
characters long.  The shell command 'openssl rand' is used, but
setting RANDOM-SOURCE non-nil uses built-in random function.

XXXX: This function should absolutely be checked before using for
anything too critical!!!

TODO: Even more options for random numbers might be better but I
think openssl is find for this purpose."
  (let ((length-passwordchars (length char-set)))
    (cond (random-source
           (mapconcat (lambda (dummy)
                        (let ((idx (random length-passwordchars)))
                          (substring char-set idx (1+ idx))))
                      (number-sequence 0 (- char-num 1))
                      ""))
          (t
           (let ((new-password "")
                 (new-password-char))
             ;; TODO: should probably just make one go at this and then truncate or take random substring
             (dotimes (n char-num)
               ;; get a random number
               (setq new-password-char nil)
               (while (not new-password-char)
                 (setq new-password-char (string-to-number (s-trim-full (shell-command-to-string "openssl rand -hex 1")) 16))
                 (if (>= new-password-char length-passwordchars)
                     (setq new-password-char nil)
                   (setq new-password (concat new-password (substring char-set new-password-char (1+ new-password-char)))))))
             new-password)))))

(when nil
  (cic:select-alist '(("g" . ("galaxy" (list "file://galaxy" "test") ))
                      ("h" . ("help" "file://help")))
                    "Test: " 'identity))
(defun cic:select-alist (&optional filter-alists header-message command) ;;  filter-alist-first)
  "Allows user to select from an alist.
TODO: I don't actually use the nested function and I think this
can be greatly simplified."
  ;; "Allows user to select a symbol from a nested alist"
  (interactive)
  ;; get keys until alist is exhausted
  (let ((minibuffer-prompt "")
        key-press
        (current-alist filter-alists)
        canceled
        selected
        minibuffer-line
        minibuffer-select
        minibuffer-cancel
        (count 0))
    ;; keep reading input while there are inner alists
    ;; read input
    ;; initialise variables
    (if header-message
        (setq minibuffer-prompt (concat header-message "\n") )
      (setq minibuffer-prompt ""))
    ;; TODO do I want this?
    (dolist (search-key current-alist)
      (setq minibuffer-select (concat "(" (car search-key) ")"))
      ;; TODO: this needs a bit more
      ;; (put-text-property 0 (length minibuffer-select) 'face 'bold minibuffer-select)
      (setq minibuffer-line (concat minibuffer-select " " (cadr search-key)))
      ;; TODO: I like these colors for now, although something a bit more subtle is fine
      (if (= (mod count 2) 1)
          (put-text-property 0 (length minibuffer-line) 'face '(:background "light gray") minibuffer-line)
        (put-text-property 0 (length minibuffer-line) 'face '(:background "light sky blue") minibuffer-line))
      (setq minibuffer-prompt (concat minibuffer-prompt
                                      (concat minibuffer-line "\n")))
      (setq count (1+ count)))
    (setq minibuffer-cancel "(-) cancel")
    ;; TODO: will need to define face
    ;; :bold t
    ;; '(:background "dark gray" :foreground "red")
    (put-text-property 0 (length minibuffer-cancel) 'face '(:background "khaki2") minibuffer-cancel)
    (setq minibuffer-prompt (concat minibuffer-prompt minibuffer-cancel))
    ;; read a key
    ;; TODO: have way of escaping
    (setq key-press (read-key minibuffer-prompt))
    (when (or (equal key-press 45) (equal key-press 3) (equal key-press 7))
      (setq canceled t))
    (setq key-press (make-string 1 key-press))
    ;; test for valid keypress, inner-selection is nil if not valid
    (setq inner-selection (assoc key-press current-alist))
    ;; use input, decide if alist is in fact an inner alist
    (setq selected (caddr inner-selection))
    (unless canceled
      (funcall command (cic:symbol-value selected)))))

(defun cic:org-insert-indent-list-item ()
  "Insert a list item, open and indent properly.
TODO: used for checklists, do I need this?
"
  (if (cic:org-headline-p (cic:get-current-line))
      (progn
        (move-end-of-line 1)
        (insert "\n")
        (org-cycle)
        (insert "- "))
    (progn
      (move-end-of-line 1)
      (org-meta-return))))

;; code for testing
;; (remove-hook 'org-metareturn-hook 'cic:org-insert-new-list)
(defun cic:org-insert-new-list ()
  "Insert a list item, open and indent properly.."
  (when (cic:org-headline-p (cic:get-current-line))
      (move-end-of-line 1)
      (insert "\n")
      (org-cycle)
      (insert "- ")
      t))
(add-hook 'org-metareturn-hook 'cic:org-insert-new-list)

;; TODO: change name of this function
(defun cic:uid-64 ()
  "Create an 11 character unique ID (about 56 bits of randomness)."
  ;; XXXX: this is meant to be easily searchable and human enterable, it is not cryptographically secure!
  (cic:create-password "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ" 11))

(defun cic:browse-url-conkeror (url &rest args)
  "Browse a url in the Conkeror web browser."
  (let ((browse-url-generic-program "conkeror"))
    (browse-url-generic url)))

(defun cic:org-table-elisp-replace (elisp-table-original elisp-table-replacement)
  "Replace the original table at point ELISP-TABLE-ORIGINAL with
the ELISP-TABLE-REPLACEMENT.  Only uses expensive org-table-put
when values has changed.

Meant to be used programatically and behaviour is undefined if
there is not mutual correspondance between table at point,
ELISP-TABLE-ORIGINAL, and ELISP-TABLE-REPLACEMENT."
  ;; TODO: add some quick sanity checks here
  (when (org-at-table-p)
    (save-excursion
      (let ((nrows (length elisp-table-original))
            (ncols (length (car elisp-table-original))))
        ;; TODO: do better than straight imperative programming?
        (dotimes (i nrows)
          (dotimes (j ncols)
            (when (not (string= (cic:elisp-array-string elisp-table-original i j)
                                (cic:elisp-array-string elisp-table-replacement i j)))
              (org-table-put (1+ i) (1+ j) (cic:elisp-array-string elisp-table-replacement i j)))))))))

(defun cic:elisp-array-string (elisp-array i j)
  (let ((thestr (elt (elt elisp-array i) j)))
    (if (stringp thestr)
        (s-trim-full-no-properties thestr)
      "")))

;; from https://stackoverflow.com/questions/6532898/is-there-a-apply-function-to-region-lines-in-emacs
(defun apply-function-to-region-lines (fn)
  "Apply a function FN to each line in the region."
  (interactive)
  (when (region-active-p)
    (save-excursion
      (region-beginning)
      ;; loop over lines till region at end
      (goto-char (region-end))
      (let ((end-marker (copy-marker (point-marker)))
            next-line-marker)
        (goto-char (region-beginning))
        (if (not (bolp))
            (forward-line 1))
        (setq next-line-marker (point-marker))
        (while (< next-line-marker end-marker)
        (let ((start nil)
              (end nil))
          (goto-char next-line-marker)
          (save-excursion
            (setq start (point))
            (forward-line 1)
            (set-marker next-line-marker (point))
            (setq end (point)))
          (save-excursion
            (let ((mark-active nil))
              (narrow-to-region start end)
              (funcall fn)
              (widen)))))
      (set-marker end-marker nil)
      (set-marker next-line-marker nil)
      (setq deactivate-mark nil)))))

(defun cic:increase-indent ()
  "Increase the indent of a line or a region if that is active."
  (interactive)
  (if (region-active-p)
      (apply-function-to-region-lines (lambda ()
                                        (beginning-of-line)
                                        (insert " ")))
    (save-excursion
      (beginning-of-line)
      (insert " "))))

(defun cic:decrease-indent ()
  "Decrease the indent of a line or a region if that is active."
  (interactive)
  (if (region-active-p)
      (apply-function-to-region-lines (lambda ()
                                        (beginning-of-line)
                                        (when (looking-at " ")
                                          (delete-char 1))))
    (save-excursion
      (beginning-of-line)
      (when (looking-at " ")
        (delete-char 1)))))

(defun cic:make-file-finder (f)
  "Make a command to find a particular file."
  (lexical-let ((sym (gensym)))
    (setq sym f)
    `(lambda ()
       (interactive)
       (find-file ,sym))))

(defun cic:org-refile-region-or-subtree (destination-file)
  "Refile and indicate has been refiled."
  ;; TODO: do I want this to be more general than org-file
  ;; TODO: make sure destination file is an org-file
  ;; TODO: maybe just check if destination file is symbol
  (unless (or (not (derived-mode-p 'org-mode)) (not destination-file) (eq destination-file 'cancel))
    (let (region-to-move
          (beg-of-region (region-beginning))
          (end-of-region (region-end))
          (current-filename (cic:current-grouppath buffer-file-name))
          new-subtree
          (check-input-char 13))
      ;; ask about location
      ;; TODO: pop-up showing things to be moved
      (save-window-excursion
        (cic:find-file-meta nil destination-file)
        (goto-char (point-max))
        (setq check-input-char (read-char "Refile to here (<enter> accepts and any other key cancels): "))
        (message nil))
      (message nil)
      (when (equal check-input-char 13)
        (when (not (region-active-p))
          (org-mark-subtree)
          (setq beg-of-region (region-beginning))
          (setq end-of-region (region-end)))
        (setq region-to-move (buffer-substring beg-of-region end-of-region))
        (delete-region beg-of-region end-of-region)
        ;; TODO: handle this with-current-file, do I want to jump to destination
        (with-current-file destination-file
          ;; is what I've cut a subtree
          (with-temp-buffer
            (org-mode)
            ;; trim whitespace
            (insert (s-trim region-to-move))
            ;; add subtree to the end with tag
            (goto-char (point-min))
            (if (cic:org-headline-p (cic:get-current-line))
                (progn
                  ;; cut headline to level 1
                  (dotimes (count (- (org-outline-level) 1))
                    (org-promote-subtree))
                  ;; add tag to headline
                  (when (not (string-match ":refiled:" (cic:get-current-line)))
                    (end-of-line)
                    (insert (concat " (from " current-filename ") :refiled:"))))
              (progn
                ;; add headline
                (goto-char (point-min))
                (while (not (eobp))
                  (beginning-of-line)
                  (insert "  ")
                  (forward-line))
                (goto-char (point-min))
                (insert (concat "* (from " current-filename ") :refiled:\n"))))
            (setq new-subtree (buffer-substring (point-min) (point-max))))
          (with-current-file-max destination-file
            (when (not (= (current-column) 0))
              (insert "\n"))
            (insert new-subtree))))))
  (when (not (derived-mode-p 'org-mode))
    (message "Refile only works in org-mode!")))

(defun cic:org-refile-subtree-preserve-structure (destination-file)
  "Refile and preserve structure."
  (unless (or (not (derived-mode-p 'org-mode)) (not destination-file) (eq destination-file 'cancel))
    (cond ((region-active-p)
           (message "Cannot refile while region is active!!!"))
          ((/= (org-outline-level) 2)
           (message "Must be at level 2 heading to refile!!!"))
          (t
           (let (new-subtree
                 (current-filename (cic:current-grouppath buffer-file-name))
                 (current-toplevel-tree (save-excursion (cic:goto-previous-heading-level 1)
                                                        (org-back-to-heading)
                                                        (s-trim-full-no-properties (org-get-heading))))
                 (check-input-char 13))
             ;; avoid if region is active
             (save-window-excursion
               (cic:find-file-meta nil destination-file)
               ;; find same heading
               (goto-char (point-min))
               (if (ignore-errors (cic:org-find-headline current-toplevel-tree))
                   (goto-char (org-end-of-subtree))
                 (goto-char (point-max)))
               ;; if headline does not exist, just go to end
               (setq check-input-char (read-char "Refile to here (<enter> accepts and any other key cancels): "))
               (message nil))
             (when (equal check-input-char 13)
               (org-mark-subtree)
               (setq beg-of-region (region-beginning))
               (setq end-of-region (region-end))
               (setq region-to-move (buffer-substring beg-of-region end-of-region))
               (delete-region beg-of-region end-of-region)
               (with-current-file-min (cic:get-filename-meta destination-file)
                 (if (ignore-errors (cic:org-find-headline current-toplevel-tree))
                     (goto-char (org-end-of-subtree))
                   (progn
                     (goto-char (point-max))
                     (insert (concat "* " current-toplevel-tree))))
                 ;; go to the end of the tree
                 (insert "\n")
                 ;; now insert it
                 (insert region-to-move)
                 (cic:org-kill-trailing-blank-lines)
                 (basic-save-buffer))))))))

(defun cic:goto-previous-heading-level (level)
  ;; goto the open heading level
  (org-back-to-heading)
  (beginning-of-line)
  (setq heading-level
        (org-outline-level))
  (setq move-heading-level
        (- heading-level
           level))
  (when (< move-heading-level 0)
    (setq move-heading-level 0))
  (org-up-heading-all move-heading-level))

;; TODO: add more cases at some point, start putting more places
(defun cic:org-kill-trailing-blank-lines ()
  "Kill trailing blanks at end of trees and after :END:"
  ;; XXXX: lightly tested, be sure to diff before committing for now
  (interactive)
  (let ((line-found nil))
   (when (derived-mode-p 'org-mode)
     (save-excursion
       (goto-char (point-min))
       (while (not (eobp))
         (forward-line)
         (cond ((string-match "^\\s-*$" (cic:get-current-line))
                (setq line-found nil)
                (save-excursion
                  (forward-line)
                  (when (and (not (eobp)) (string-match "^\\*" (cic:get-current-line)))
                    (setq line-found t)))
                (when line-found
                  (beginning-of-line)
                  (cic:kill-line-elisp)))
               ((string-match ":END:" (cic:get-current-line))
                (setq line-found nil)
                (save-excursion
                  (forward-line)
                  (when (and (not (eobp)) (string-match "^\\s-*$" (cic:get-current-line)))
                    (beginning-of-line)
                    (cic:kill-line-elisp))))))))))

;; https://stackoverflow.com/questions/4870704/appending-characters-to-the-end-of-each-line-in-emacs
;; create key for this and clean up language
(defun add-string-to-end-of-lines-in-region (str b e)
  "prompt for string, add it to end of lines in the region"
  (interactive "sWhat shall we append? \nr")
  (goto-char e)
  (forward-line -1)
  (while (> (point) b)
    (end-of-line)
    (insert str)
    (forward-line -1)))
;; TODO: do I want this? now
;; (global-set-key (kbd "H-c")     'cic:current-clean)

(defun cic:current-compile-full (&optional arg)
  "Full compile in one command (eventually split off helper functions)."
  (interactive "P")
  (if arg
      (cic:current-compile '(64))
    (cic:current-compile '(16))))

;; TODO: make this work with other things
(defun cic:current-compile (&optional arg)
  "Just see how my document is doing."
  ;; TODO: maybe enable disabling images
  (interactive "P")
  (cond ((derived-mode-p 'latex-mode)
         (cond ((equal arg '(4))
                (let ((full-filename buffer-file-name))
                  ;; TODO: need current compile but wait?
                  ;; recursive call to compile
                  (cic:current-compile nil)
                  (let ((active-process (with-current-file-transient full-filename
                                          (TeX-active-process))))
                    ;; (mpp active-process)
                    (when active-process
                      (set-process-sentinel active-process 'first-latex-compile-process-sentinel)))))
               ((equal arg '(16))
                (cic:current-compile 'full))
               ((equal arg '(64))
                (let ((full-filename buffer-file-name))
                  ;; TODO: need current compile but wait?
                  ;; recursive call to compile
                  (cic:current-compile 'full)
                  (let ((active-process (with-current-file-transient full-filename
                                          (TeX-active-process))))
                    ;; (mpp active-process)
                    (when active-process
                      (mpp "Starting multi-...")
                      (set-process-sentinel active-process 'first-latex-full-compile-process-sentinel)))))
               ;; TODO: make more universal
               ((equal arg 'full)
                (shell-command-to-string (concat "echo \"\" > ~/cic-vcs-academic/phdthesis/includeonly.tex"))
                (TeX-command "LaTeX" 'TeX-master-file nil))
               (t
                (save-some-buffers t)
                ;; (setq auto-revert-verbose-old auto-revert-verbose)
                ;; (setq auto-revert-verbose nil)
                ;; get includeonly working
                (when (or (string-match "thesis" (buffer-name)) (string-match "chapter" (buffer-name)))
                  (shell-command-to-string (concat "echo \"\\includeonly{" (file-name-base buffer-file-name) "}\" > ~/cic-vcs-academic/phdthesis/includeonly.tex")))
                (TeX-command "LaTeX" 'TeX-master-file nil))))
        ((derived-mode-p 'python-mode)
         ;; TODO: use some beter configuration
         ;; XXXX: pyflakes can't easily ignore common design decision I make
         ;; (python-check (concat "pyflakes " buffer-file-name))
         ;; TODO: do I want this...
         ;; (flycheck-buffer)
         ;; TODO: better customization
         ;; https://pycodestyle.readthedocs.io/en/latest/intro.html#error-codes
         ;; http://flake8.pycqa.org/en/latest/user/error-codes.html
         ;; TODO: have a production mode
         ;; XXXX: these reflect common stylistic changes I've made for research-focused code,
         ;;       e.g., from <<module>> import * is incredibly useful when experimenting with many functions reflecting many math problems,
         ;;             enforcing space after comma is not always best style for huge lists of numbers,
         ;;             long lines are good for long formulas,
         ;;             multiple spaces after commas are good for complex data structures,
         ;;             sometimes add paths is good before importing on experimental setups,
         ;;             requiring whitespace around operators does not allows intuitive grouping of expressions
         ;;             I like to comment blocks out so wrong and unexpected indentation will always be found
         (python-check (concat "flake8 --ignore=E114,E116,E122,E124,E127,E201,E221,E222,E225,E226,E231,E241,E251,E261,E266,E302,E305,E401,F401,E402,F402,E403,F403,E405,F405,E501 " buffer-file-name)))))

(defun first-latex-compile-process-sentinel (process event)
  (mpp (concat "First: " event))
  (when (equal event "finished\n")
    ;; call next
    (mpp "first sentinel")
    (let ((full-filename buffer-file-name))
      (TeX-command "BibTeX" 'TeX-master-file nil)
      (let ((active-process (with-current-file-transient full-filename
                              (TeX-active-process))))
        (if active-process
            (set-process-sentinel active-process 'second-bibtex-compile-process-sentinel)
          (mpp "No first active process"))))))

(defun second-bibtex-compile-process-sentinel (process event)
  (mpp (concat "Second: " event))
  (when (equal event "finished\n")
    ;; call next
    (mpp "second sentinel")
    (let ((full-filename buffer-file-name))
      (cic:current-compile nil)
      (let ((active-process (with-current-file-transient full-filename
                              (TeX-active-process))))
        (if active-process
            (set-process-sentinel active-process 'third-latex-compile-process-sentinel)
          (mpp "No second active process"))))))

(defun third-latex-compile-process-sentinel (process event)
  (mpp (concat "Third: " event))
  (when (equal event "finished\n")
    (mpp "third sentinel")
    (let ((full-filename buffer-file-name))
      (cic:current-compile nil))))

(defun first-latex-full-compile-process-sentinel (process event)
  (mpp (concat "First multi-: " event))
  (when (equal event "finished\n")
    ;; call next
    (mpp "first sentinel multi-")
    (let ((full-filename buffer-file-name))
      (TeX-command "BibTeX" 'TeX-master-file nil)
      (let ((active-process (with-current-file-transient full-filename
                              (TeX-active-process))))
        (if active-process
            (set-process-sentinel active-process 'second-bibtex-full-compile-process-sentinel)
          (mpp "No first multi- active process"))))))

(defun second-bibtex-full-compile-process-sentinel (process event)
  (mpp (concat "Second multi-: " event))
  (when (equal event "finished\n")
    ;; call next
    (mpp "second sentinel multi-")
    (let ((full-filename buffer-file-name))
      (cic:current-compile 'full)
      (let ((active-process (with-current-file-transient full-filename
                              (TeX-active-process))))
        (if active-process
            (set-process-sentinel active-process 'third-latex-full-compile-process-sentinel)
          (mpp "No second multi- active process"))))))

(defun third-latex-full-compile-process-sentinel (process event)
  (mpp (concat "Third multi-: " event))
  (when (equal event "finished\n")
    (mpp "third sentinel multi-")
    (let ((full-filename buffer-file-name))
      (cic:current-compile 'full)
      (let ((active-process (with-current-file-transient full-filename
                              (TeX-active-process))))
        (if active-process
            (set-process-sentinel active-process 'fourth-latex-full-compile-process-sentinel)
          (mpp "No third mutli- active process"))))))

(defun fourth-latex-full-compile-process-sentinel (process event)
  (mpp (concat "Fourth multi-: " event))
  (when (equal event "finished\n")
    (mpp "fourth sentinel multi-")
    (sit-for 1.0)
      (message "Done LaTeX multi-compile!")))


;; build, just latex for now
;; TODO: clean this out, other things capture it now...
(defun cic:current-build ()
  (interactive)
  (cond ((derived-mode-p 'latex-mode)
         ;; needs latex-extra package
         ;; TODO: clean first?
         ;; TODO: does not get set by appropriate advice
         (setq cic:current-build-filename buffer-file-name)
         (call-interactively 'latex/compile-commands-until-done)
         ;; (let ((full-filename buffer-file-name))
         ;;   (TeX-command "LatexMk" 'TeX-master-file nil)
         ;;   (let* ((current-filename (file-name-sans-extension (file-name-nondirectory full-filename)))
         ;;          (active-process (with-current-file-transient full-filename
         ;;                            (TeX-active-process))))
         ;;     (setq cic:current-build-filename current-filename)
         ;;     ;; TODO: how to stop this from overriding default message, move to emacs-stdlib
         ;;     (if active-process
         ;;         (set-process-sentinel active-process
         ;;                               (lambda (process event)
         ;;                                 ;; reload liberally, event when failed
         ;;                                 (when (or (equal event "finished\n") (string-match "exited abnormally" event))
         ;;                                   (start-process "xpdf reload" nil "xpdf" "-remote" cic:current-build-filename "-reload"))
         ;;                                 (message "Finished compiling and reloading xpdf! Type `C-c C-l' to see results!")))
         ;;       (progn
         ;;         (message "No active process! Reloading anyways!")

         )
        ((derived-mode-p 'markdown-mode)
         (gh-md-export-buffer))))

(defun cic:current-clean ()
  (interactive)
  (cond ((derived-mode-p 'latex-mode)
         (TeX-command "Clean All" 'TeX-master-file nil)
         (sit-for 0.5)
         (message "Cleaned!!!"))))

;; TODO: move
(global-set-key [prior] 'scroll-down)
(global-set-key [next]  'scroll-up)
(global-set-key (kbd "S-<prior>") 'beginning-of-buffer)
(global-set-key (kbd "S-<next>" ) 'end-of-buffer)

(defun create-frame-other-window-maximized (&optional name)
  (interactive)
  (select-frame (make-frame-command))
  (set-frame-position (selected-frame) 0 0)
  (cic:x-force-maximized))

(defun create-frame-other-window-maximized-focus (&optional name)
  (interactive)
  (select-frame-set-input-focus (make-frame-command))
  (set-frame-position (selected-frame) 0 0)
  (cic:x-force-maximized))

;; TODO: need to test this on non-graphical display
(defun create-frame-here (&optional frame-name)
  ""
  (interactive)
  (let (new-frame)
    (cond (frame-name
           (if (display-graphic-p)
               (setq new-frame (make-frame (list (cons 'name frame-name))))
             (progn
               (setq new-frame (make-frame (list (cons name frame-name))))
               (select-frame new-frame))))
          (t
           (setq new-frame (make-frame-command))
           (select-frame new-frame)))
    (cic:x-force-maximized)
    new-frame))

(defun cic:hl-line-mode-or-disable-visuals (&optional arg)
  "Turn off any visuals that other functions might have put on."
  (interactive "P")
  (if arg
      (progn
        (set-cursor-color "#ffffff")
        (blink-cursor-mode -1))
    (call-interactively 'hl-line-mode)))

(defun cic:create-or-select-frame-displaying-buffer (my-buffer)
  ;; https://emacs.stackexchange.com/questions/2959/how-to-know-my-buffers-visible-focused-status
  ;; my-buffer is supposed to be the buffer you are looking for
  ;; assume buffer has been created
  (cond ((get-buffer-window my-buffer t)
         ;; raise frame, then focus
         (raise-frame (window-frame (get-buffer-window my-buffer t)))
         (select-window (get-buffer-window my-buffer t))
         (switch-to-buffer my-buffer))
        (t
         (create-frame-other-window-maximized)
         (switch-to-buffer my-buffer))))

(defun cic:select-frame-displaying-buffer (my-buffer)
  ;; https://emacs.stackexchange.com/questions/2959/how-to-know-my-buffers-visible-focused-status
  ;; my-buffer is supposed to be the buffer you are looking for
  ;; assume buffer has been created
  (when (get-buffer-window my-buffer t)
    ;; raise frame, then focus
    (raise-frame (window-frame (get-buffer-window my-buffer t)))
    (select-window (get-buffer-window my-buffer t))
    (switch-to-buffer my-buffer)))

;; this is generally hooked into a global key for popping open the clipboard as editable text
;; TODO: needs a better name
(defun cic:create-open-paste-collection ()
  (interactive)
  (with-current-buffer-create-min "*Collection*"
    ;; TODO: possibly clear buffer (can I select)
    ;;       do I really want to add current one first
    (x-clipboard-yank))
  (cic:create-or-select-frame-displaying-buffer "*Collection*")
  ;; TODO: decide on whether I want to grab focus or not when pasting
  ;;       way of disabling?
  (select-frame-set-input-focus (window-frame (get-buffer-window "*Collection*" t))))

(defun cic:create-open-collection-frame ()
  (interactive)
  (cic:create-or-select-frame-displaying-buffer "*Collection*")
  ;; can probably be reduced number of commands
  (select-frame-set-input-focus (window-frame (get-buffer-window "*Collection*" t))))

(defun cic:other-window-next ()
  (interactive)
  (let ((current-window (selected-window)))
    (other-window 1)
    ;; TODO: better way to detect end of buffer, eobp
    (ignore-errors (scroll-up))
    (select-window current-window)))

(defun cic:other-window-previous ()
  (interactive)
  (let ((current-window (selected-window)))
    (other-window 1)
    ;; TODO: better way to detect end of buffer, eobp
    (ignore-errors (scroll-down))
    (select-window current-window)))

(defun cic:add-to-alist (the-alist the-key &rest the-values)
  (add-to-list the-alist (append (list the-key) the-values))
  ;; (if (assoc the-key (symbol-value the-alist))
  ;;     ;; replace
  ;;     (progn
  ;;       ;; https://emacs.stackexchange.com/questions/3397/how-to-replace-an-element-of-an-alist
  ;;       (setf (cdr (assoc the-key (symbol-value the-alist))) the-value))
  ;;   ;; otherwise add anew
  ;;   (add-to-list the-alist (list the-key the-value)))
  )

(defun cic:switch-buffer-new-window-below ()
  ;; TODO: unwind if not successful or if I cancel ido-switch-buffer
  (interactive)
  (split-window-vertically)
  (windmove-down)
  (ido-switch-buffer))

;; (defun cic:yank-primary ()
;;   (interactive)
;;   (let ((x-select-enable-primary t)
;;         (x-select-enable-clipboard nil))
;;     (call-interactively 'yank)))

(defun cic:org-paste-new-heading ()
  (interactive)
  (end-of-line)
  (org-insert-heading-respect-content)
  (yank))
;; TODO: move this somewhere proper
(define-key org-mode-map (kbd "<C-mouse-1>") 'cic:org-paste-new-heading)

(defun cic:count-words-region-or-buffer ()
  "Count whole buffer if not active region."
  (interactive)
  (if (region-active-p)
      (call-interactively 'count-words-region)
    (save-excursion
      (mark-whole-buffer)
      (call-interactively 'count-words-region))))

(defun cic:kill-region-only-active (beg end &optional region)
  "Kill region only if active.
TODO: do something else (like copy whole line) if no region?"
  (interactive (list (mark) (point) 'region))
  (if (region-active-p)
      (kill-region beg end region)
    (message "Cannot delete unless there is an active region!")))

(defun cic:page-up ()
  ;; https://www.emacswiki.org/emacs/Scrolling#toc3
  ;; TODO get rid of flashing and instead smoothly go
  (interactive)
  (setq this-command 'previous-line)
  (previous-line
   (- (window-text-height)
      next-screen-context-lines)))

(defun cic:page-down ()
  ;; TODO: in progress
  ;; https://www.emacswiki.org/emacs/Scrolling#toc3
  ;; restore cursore.... half pgup/down?
  (interactive)
  (setq this-command 'next-line)
  (next-line
   (- (window-text-height)
      next-screen-context-lines)))

(defun cic:move-up ()
  ;; nice for reading code on laptop in bed
  (interactive)
  ;; this combination is faster than letting (scroll-preserve-screen-position 'other)

  (let ((saved-position (point)))
    (ignore-errors (forward-line -1))
    ;; if forward-line moves point
    (when (/= (point) saved-position)
      ;; condition-case nil
      (ignore-errors (scroll-down 1))
      ;; (beginning-of-buffer (forward-line))
      )))

(defun cic:move-down ()
  ;; nice for reading code on laptop in bed
  (interactive)
  ;; this combination is faster than letting (scroll-preserve-screen-position 'other)
  ;; TODO no sure some of these lets are necessary
  (let ((saved-position (point))
        (scroll-margin 0)
        (scroll-conservatively 10000)
        (next-screen-context-lines 0))
    (forward-line)
    ;; if forward-line moves point
    (when (/= (point) saved-position)
      (scroll-up 1))))

(defun cic:toggle-media ()
  (interactive)
  (cond ((derived-mode-p 'org-mode)
         (org-toggle-inline-images))
        ((derived-mode-p 'dired-mode)
         nil)
        ((derived-mode-p 'wdired-mode)
         nil))
  (message "Media toggled!"))

(defun org-quote-region ()
  (interactive)
  (if (org-at-table-p)
      (call-interactively 'org-table-rotate-recalc-marks)
    (cond
     ((region-active-p)
      (let ((start (region-beginning))
            (end (region-end)))
        (goto-char end)
        (end-of-line)
        (insert "\n#+END_QUOTE")
        (goto-char start)
        (beginning-of-line)
        (insert "#+BEGIN_QUOTE\n")))
     (t
      (insert "#+BEGIN_" choice "\n")
      (save-excursion (insert "#+END_" choice))))))

;;bind to key
;; TODO: avoiding wierd stuff if I hold control, will I ever use org-set-tags command?
(define-key org-mode-map (kbd "C-c q")   'org-quote-region)
(define-key org-mode-map (kbd "C-c C-q") 'org-quote-region)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; capture from an external source
;; these are often called from the command line

(defun cic:capture-conkeror-buffer (title capture-text)
  (let ((decoded-title (base64-decode-string title))
        (decoded-temp-filename (base64-decode-string capture-text)))
    ;; TODO: need safe titles and add datestring
    ;; TODO: should I redo the buffer?
    (with-current-buffer-create (concat "capture-conkeror-" decoded-title)
      ;; TODO: can use replace
      (insert-file-contents decoded-temp-filename)
      (goto-char (point-min))
      ;; TODO: format a bit better because html is stupid
      )))

;; (cic:capture-rxvt-scrollback "/home/akroshko/tmp/collect/urxvt-20171017103512.txt")
(defun cic:capture-rxvt-scrollback (tmp-file)
  (let ((captured-scrollback (with-current-file-transient tmp-file
                               (buffer-substring-no-properties (point-min) (point-max)))))
    ;; TODO: need safe titles and add datestring
    (with-current-buffer-create (concat "capture-urxvt-scrollback-" (format-time-string "%Y%m%d%H%M%S" (current-time)))
      (insert captured-scrollback)
      (goto-char (point-max))
      ;; TODO: format a bit better because html is stupid
      )))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; apt
(defun cic:apt-show ()
  (interactive)
  ;; TODO: need to add . to this
  (let* ((the-symbol (thing-at-point 'symbol))
         ;; TODO: test for invalid packages
         (apt-show-output (shell-command-to-string (concat "apt-cache show " the-symbol)))
         (current-window (get-buffer-window))
         (the-buffer (pop-to-buffer "*apt show*")))
    (with-current-buffer-erase the-buffer
      (insert apt-show-output)
      (goto-char (point-min)))
    (select-window current-window)))
(global-set-key (kbd "s-m a") 'cic:apt-show)

(defun cic:dired-filename-at-point ()
  (expand-file-name (dired-file-name-at-point)))


(defun cic:standard-datestamp-current-time ()
  (format-time-string "%Y%m%dt%H%M%S" (current-time)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; org-mode C-enter
(defun cic:org-mode-control-return (&optional arg)
  (interactive "P")
  (when (derived-mode-p 'org-mode)
    (cond ((org-table-p)
           (org-table-insert-row '(4)))
          (t
           (org-insert-heading-respect-content)))))

(defun cic:kill-line-elisp ()
  (let (kill-ring
        kill-whole-line)
    (kill-line)))

(provide 'emacs-stdlib-functions)
