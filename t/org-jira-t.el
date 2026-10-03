;;; org-jira-t.el --- ERT tests

;; Copyright (C) 2017 Matthew Carter <m@ahungry.com>
;;
;; Authors:
;; Matthew Carter <m@ahungry.com>
;;
;; Maintainer: Matthew Carter <m@ahungry.com>
;; URL: https://github.com/ahungry/org-jira
;; Version: 2.6.2
;; Keywords: ahungry jira org bug tracker
;; Package-Requires: ((emacs "24.5") (cl-lib "0.5") (request "0.2.0"))

;; This file is not part of GNU Emacs.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see
;; <http://www.gnu.org/licenses/> or write to the Free Software
;; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
;; 02110-1301, USA.

;;; Commentary:

;; This tests the extension to org-mode for syncing issues with JIRA
;; issue servers.

;;; News:

;;;; Changes since 0.0.0:
;; - Add some basic tests

;;; Code:

(require 'org-jira)

(set-time-zone-rule t)

(ert-deftest org-jira-date-to-org-clock-test ()
  (should
   (string= "2017-01-01 Sun 00:00"
            (org-jira-date-to-org-clock "2017-01-01T00:00:00.000+0000")))
  (should
   (string= "2017-02-05 Sun 00:00"
            (org-jira-date-to-org-clock "2017-02-05T00:00:00.000+0000")))
  )

(ert-deftest org-jira-org-clock-to-date-test ()
  (should
   (string= "2017-01-01T00:00:00.000+0000"
            (org-jira-org-clock-to-date "2017-01-01 Sun 00:00")))
  )

(ert-deftest org-jira-time-stamp-to-org-clock-test ()
  (should
   (string= "2017-01-01 Sun 00:05"
            (org-jira-time-stamp-to-org-clock '(22632 18348))))
  )

(defvar org-jira-worklog-fixture-response
  '((startAt . 0)
    (maxResults . 2)
    (total . 2)
    (worklogs .
              [((self . "https://example.com/rest/api/2/issue/10402/worklog/10101")
                (author
                 (self . "https://example.com/rest/api/2/user?username=admin")
                 (name . "admin")
                 (key . "admin")
                 (accountId . "omitted")
                 (emailAddress . "m@example.com")
                 (avatarUrls
                  (48x48 . "https://avatar-cdn.atlassian.com/12345?s=48&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F12345%3Fd%3Dmm%26s%3D48%26noRedirect%3Dtrue")
                  (24x24 . "https://avatar-cdn.atlassian.com/12345?s=24&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F12345%3Fd%3Dmm%26s%3D24%26noRedirect%3Dtrue")
                  (16x16 . "https://avatar-cdn.atlassian.com/12345?s=16&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F12345%3Fd%3Dmm%26s%3D16%26noRedirect%3Dtrue")
                  (32x32 . "https://avatar-cdn.atlassian.com/12345?s=32&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F12345%3Fd%3Dmm%26s%3D32%26noRedirect%3Dtrue"))
                 (displayName . "Matthew Carter")
                 (active . t)
                 (timeZone . "America/New_York"))
                (updateAuthor
                 (self . "https://example.com/rest/api/2/user?username=admin")
                 (name . "admin")
                 (key . "admin")
                 (accountId . "omitted")
                 (emailAddress . "m@example.com")
                 (avatarUrls
                  (48x48 . "https://avatar-cdn.atlassian.com/12345?s=48&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F12345%3Fd%3Dmm%26s%3D48%26noRedirect%3Dtrue")
                  (24x24 . "https://avatar-cdn.atlassian.com/12345?s=24&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F12345%3Fd%3Dmm%26s%3D24%26noRedirect%3Dtrue")
                  (16x16 . "https://avatar-cdn.atlassian.com/12345?s=16&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F12345%3Fd%3Dmm%26s%3D16%26noRedirect%3Dtrue")
                  (32x32 . "https://avatar-cdn.atlassian.com/12345?s=32&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F12345%3Fd%3Dmm%26s%3D32%26noRedirect%3Dtrue"))
                 (displayName . "Matthew Carter")
                 (active . t)
                 (timeZone . "America/New_York"))
                (comment . "Some comment here")
                (created . "2017-02-27T23:47:04.261+0000")
                (updated . "2017-02-27T23:47:04.261+0000")
                (started . "2017-02-26T00:08:00.000+0000")
                (timeSpent . "1h")
                (timeSpentSeconds . 3600)
                (id . "10101")
                (issueId . "10402"))
               ((self . "https://example.com/rest/api/2/issue/10402/worklog/10200")
                (author
                 (self . "https://example.com/rest/api/2/user?username=admin")
                 (name . "admin")
                 (key . "admin")
                 (accountId . "omitted")
                 (emailAddress . "m@example.com")
                 (avatarUrls
                  (48x48 . "https://avatar-cdn.atlassian.com/12345?s=48&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F12345%3Fd%3Dmm%26s%3D48%26noRedirect%3Dtrue")
                  (24x24 . "https://avatar-cdn.atlassian.com/12345?s=24&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F12345%3Fd%3Dmm%26s%3D24%26noRedirect%3Dtrue")
                  (16x16 . "https://avatar-cdn.atlassian.com/12345?s=16&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F12345%3Fd%3Dmm%26s%3D16%26noRedirect%3Dtrue")
                  (32x32 . "https://avatar-cdn.atlassian.com/12345?s=32&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F12345%3Fd%3Dmm%26s%3D32%26noRedirect%3Dtrue"))
                 (displayName . "Matthew Carter")
                 (active . t)
                 (timeZone . "America/New_York"))
                (updateAuthor
                 (self . "https://example.com/rest/api/2/user?username=admin")
                 (name . "admin")
                 (key . "admin")
                 (accountId . "omitted")
                 (emailAddress . "m@example.com")
                 (avatarUrls
                  (48x48 . "https://avatar-cdn.atlassian.com/12345?s=48&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F12345%3Fd%3Dmm%26s%3D48%26noRedirect%3Dtrue")
                  (24x24 . "https://avatar-cdn.atlassian.com/12345?s=24&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F12345%3Fd%3Dmm%26s%3D24%26noRedirect%3Dtrue")
                  (16x16 . "https://avatar-cdn.atlassian.com/12345?s=16&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F12345%3Fd%3Dmm%26s%3D16%26noRedirect%3Dtrue")
                  (32x32 . "https://avatar-cdn.atlassian.com/12345?s=32&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F12345%3Fd%3Dmm%26s%3D32%26noRedirect%3Dtrue"))
                 (displayName . "Matthew Carter")
                 (active . t)
                 (timeZone . "America/New_York"))
                (comment . "Add 32 minutes")
                (created . "2017-03-16T23:25:45.396+0000")
                (updated . "2017-03-16T23:25:45.396+0000")
                (started . "2017-03-16T22:25:00.000+0000")
                (timeSpent . "32m")
                (timeSpentSeconds . 1920)
                (id . "10200")
                (issueId . "10402"))]))
  "A sample response, as served from the #'jiralib-get-worklogs call.")

(ert-deftest org-jira-worklogs-to-org-clocks-test ()
  (let ((result (org-jira-worklogs-to-org-clocks
                 (cdr (assoc 'worklogs org-jira-worklog-fixture-response)))))
    (should
     (string= "2017-02-26 Sun 00:08"
              (caar result)))
    (should
     (string= "2017-02-26 Sun 01:08"
              (cadar result)))
    (should
     (string= "2017-03-16 Thu 22:25"
              (caadr result)))
    (should
     (string= "2017-03-16 Thu 22:57"
              (cadadr result)))
    ))

(ert-deftest org-jira-format-clock-test ()
    (should
     (string= "CLOCK: [2017-02-26 Sun 00:08]--[2017-02-26 Sun 01:08]"
              (org-jira-format-clock '("2017-02-26 Sun 00:08" "2017-02-26 Sun 01:08")))))

(ert-deftest org-jira-org-clock-to-jira-worklog-test ()
  (let ((result
         (org-jira-org-clock-to-jira-worklog
          "[2017-04-05 Wed 01:00]--[2017-04-05 Wed 01:46] =>  0:46"
          "  :id: 10101
  Success!
CLOCK:")))
    (should (string= "10101" (cdr (assoc 'worklog-id result))))
    (should (string= "Success!" (cdr (assoc 'comment result))))
    (should (string= "2017-04-05T01:00:00.000+0000" (cdr (assoc 'started result))))
    (should (= 2760.0 (cdr (assoc 'time-spent-seconds result))))
    ))

(ert-deftest org-jira-org-clock-to-jira-worklog-no-id-test ()
  (let ((result
         (org-jira-org-clock-to-jira-worklog
          "[2017-04-05 Wed 01:00]--[2017-04-05 Wed 01:46] =>  0:46"
          "My sweet comment!
CLOCK:")))
    (should (equal nil (cdr (assoc 'worklog-id result))))
    (should (string= "My sweet comment!" (cdr (assoc 'comment result))))
    (should (string= "2017-04-05T01:00:00.000+0000" (cdr (assoc 'started result))))
    (should (= 2760.0 (cdr (assoc 'time-spent-seconds result))))
    ))

(ert-deftest org-jira-sort-org-clocks-test ()
  (let* ((clocks '(("2017-02-26 Sun 00:08" "2017-02-26 Sun 01:08" "Some comment here" "10101")
                     ("2017-03-16 Thu 22:25" "2017-03-16 Thu 22:57" "Add 32 minutes" "10200"))
                   )
         (result (org-jira-sort-org-clocks clocks)))

    (should (string= "2017-03-16 Thu 22:25" (car (car result))))
    ))

;;  This test sort of sucks, as its just confirming we get back some strings.
(ert-deftest org-jira-decode-test ()
  (should (string= "" (org-jira-decode nil)))
  (should (string= "dog" (org-jira-decode "dog"))))

(ert-deftest org-jira-t-get-org-priority-string ()
  (let ((org-jira-priority-to-org-priority-omit-default-priority nil)
        (org-default-priority ?B))
    (should (string= "[#B] " (org-jira-get-org-priority-string ?B)))
    (setq org-jira-priority-to-org-priority-omit-default-priority t)
    (should (string= "" (org-jira-get-org-priority-string ?B)))
    (should (string= "" (org-jira-get-org-priority-string nil)))
    )
  )

(ert-deftest org-jira-t-strip-priority-tags ()
  (should (string= "good and clean" (org-jira-strip-priority-tags "[#C] good and clean")))
  (should (string= "food and clean" (org-jira-strip-priority-tags "  [#C] [#D] food and clean ")))
  )


;;; Comment popup buffer

(defmacro org-jira-t-with-comment-popup (vars initial &rest body)
  "Open a comment popup holding INITIAL, bind VARS (BUF SUBMITTED), run BODY.
SUBMITTED is set to the list of texts the submit function received."
  (declare (indent 2))
  (let ((buf (nth 0 vars)) (submitted (nth 1 vars)))
    `(let* ((,submitted nil)
            (,buf (org-jira-comment-edit-buffer
                   "*org-jira-comment: T-1*" ,initial
                   (lambda (text) (push text ,submitted)))))
       (unwind-protect
           (with-current-buffer ,buf ,@body)
         (when (buffer-live-p ,buf) (kill-buffer ,buf))))))

(ert-deftest org-jira-comment-edit-buffer-setup-test ()
  (org-jira-t-with-comment-popup (buf submitted) "* hi"
    (should (derived-mode-p 'org-mode))
    (should org-jira-comment-mode)
    (should (string= "* hi" (buffer-string)))))

(ert-deftest org-jira-comment-finish-submits-converted-text-test ()
  (let ((org-jira-comment-to-jira-function #'upcase))
    (org-jira-t-with-comment-popup (buf submitted) ""
      (insert "  some *bold* text\n\n")
      (org-jira-comment-finish)
      (should (equal '("SOME *BOLD* TEXT") submitted))
      (should-not (buffer-live-p buf)))))

(ert-deftest org-jira-comment-finish-empty-errors-test ()
  (org-jira-t-with-comment-popup (buf submitted) ""
    (insert " \n\n")
    (should-error (org-jira-comment-finish) :type 'user-error)
    (should (buffer-live-p buf))
    (should-not submitted)))

(ert-deftest org-jira-comment-abort-test ()
  (org-jira-t-with-comment-popup (buf submitted) "draft"
    (org-jira-comment-abort)
    (should-not (buffer-live-p buf))
    (should-not submitted)))

(ert-deftest org-jira-comment-body-for-edit-test ()
  ;; Uniform two-space guard indentation is stripped...
  (should (string= "a\n\nb" (org-jira--comment-body-for-edit "  a\n\n  b")))
  ;; ...but a body that is not uniformly indented is left alone, so
  ;; nested list/code indentation survives.
  (should (string= "- a\n  - b" (org-jira--comment-body-for-edit "- a\n  - b"))))

(ert-deftest org-jira-add-comment-popup-submits-test ()
  (let (called)
    (cl-letf (((symbol-function 'org-jira-comment-edit-buffer)
               (lambda (_name _initial submit-fn &optional _issue-id)
                 (funcall submit-fn "converted")))
              ((symbol-function 'jiralib-add-comment)
               (lambda (key text &optional _cb) (setq called (list key text))))
              ((symbol-function 'org-jira-filename) (lambda () "T")))
      (org-jira-add-comment "T-1" "T")
      (should (equal '("T-1" "converted") called)))))
;;; @-mentions in the comment popup

(defvar org-jira-t-users
  '(((accountId . "a1") (displayName . "Jane Doe") (emailAddress . "jane@x.com"))
    ((accountId . "a2") (displayName . "Janet Roe"))))

(defmacro org-jira-t-with-user-search (&rest body)
  "Run BODY with the Jira user search stubbed; `calls' counts requests."
  `(let ((calls 0))
     (cl-letf (((symbol-function 'jiralib-search-viewable-users)
                (lambda (_key _query) (cl-incf calls) org-jira-t-users)))
       (setq org-jira-comment--mention-cache nil)
       ,@body)))

(ert-deftest org-jira-comment-mention-candidates-test ()
  (org-jira-t-with-user-search
   (should (equal '("Jane Doe" "Janet Roe")
                  (org-jira-comment--mention-candidates "T-1" "jan")))
   ;; Cached per issue and query.
   (org-jira-comment--mention-candidates "T-1" "jan")
   (should (= 1 calls))
   ;; Too short to be worth a request.
   (should-not (org-jira-comment--mention-candidates "T-1" "j"))
   (should (= 1 calls))))

(ert-deftest org-jira-comment-mention-capf-test ()
  (org-jira-t-with-user-search
   (org-jira-t-with-comment-popup (buf submitted) ""
     (setq org-jira-comment--issue-id "T-1")
     (insert "hello @jan")
     (let ((capf (org-jira-comment-mention-capf)))
       (should capf)
       (should (= 8 (nth 0 capf)))      ; just after the @
       (should (= 11 (nth 1 capf)))
       (should (equal '("Jane Doe" "Janet Roe")
                      (all-completions "jan" (nth 2 capf)))))
     ;; An @ inside a word (an email address) is not a mention.
     (erase-buffer)
     (insert "mail me@jan")
     (should-not (org-jira-comment-mention-capf)))))

(ert-deftest org-jira-comment-mention-insert-test ()
  (org-jira-t-with-user-search
   (org-jira-t-with-comment-popup (buf submitted) ""
     (setq org-jira-comment--issue-id "T-1")
     (insert "hi @jan")
     (let ((capf (org-jira-comment-mention-capf))
           (org-jira-comment-mention-insert-function
            (lambda (id name) (format "<%s|%s>" id name))))
       (all-completions "jan" (nth 2 capf)) ; as the UI does, fills the cache
       (funcall (plist-get (nthcdr 3 capf) :exit-function) "Jane Doe" 'finished))
     (should (string= "hi <a1|Jane Doe>" (buffer-string))))))

(ert-deftest org-jira-comment-mention-default-insert-test ()
  (should (string= "[~accountid:a1]"
                   (funcall org-jira-comment-mention-insert-function
                            "a1" "Jane Doe"))))

(ert-deftest org-jira-comment-at-command-test ()
  (let (completed)
    (cl-letf (((symbol-function 'completion-at-point)
               (lambda () (setq completed t))))
      (org-jira-t-with-comment-popup (buf submitted) ""
        (org-jira-comment-insert-at)
        (should (string= "@" (buffer-string)))
        (should completed)
        (should (eq #'org-jira-comment-insert-at (key-binding "@")))))))

(ert-deftest org-jira-comment-newline-in-src-block-keeps-popup-test ()
  ;; Indenting inside a src block normally opens an *Org Src* edit buffer,
  ;; which popup managers use to displace the comment popup.
  (let (edited)
    (cl-letf (((symbol-function 'org-edit-src-code)
               (lambda (&rest _) (setq edited t))))
      (org-jira-t-with-comment-popup (buf submitted) "#+begin_src\n#+end_src"
        (goto-char (point-min))
        (end-of-line)
        (call-interactively #'org-return)
        (should-not edited)
        (should (get-buffer-window buf))))))


;;; Comments nested under a "*** Comments" heading

(defun org-jira-t-comment (id created author-id name body)
  "Build a comment record from raw Jira data."
  (org-jira-sdk-create-comment-from-data
   `((id . ,id) (created . ,created) (updated . ,created) (body . ,body)
     (author . ((displayName . ,name) (accountId . ,author-id))))))

(defmacro org-jira-t-with-issue-file (&rest body)
  "Run BODY with `org-jira-working-dir' holding T.org with issue T-1."
  `(let* ((dir (make-temp-file "org-jira-t" t))
          (org-jira-working-dir dir)
          (file (expand-file-name "T.org" dir)))
     (with-temp-file file
       (insert "** TODO T-1 an issue\n:PROPERTIES:\n:ID: T-1\n:END:\n"
               "*** Worklog: someone\n:PROPERTIES:\n:ID: w1\n:END:\n"))
     (unwind-protect
         (progn ,@body)
       (when-let* ((buf (find-buffer-visiting file)))
         (with-current-buffer buf (set-buffer-modified-p nil))
         (kill-buffer buf))
       (delete-directory dir t))))

(defun org-jira-t-render (&rest comments)
  "Render COMMENTS on T-1 and return the project file's text."
  (let ((issue (make-instance 'org-jira-sdk-issue
                              :issue-id "T-1" :proj-key "T" :filename "T")))
    (dolist (c comments) (org-jira--render-comment issue c))
    (with-current-buffer (find-buffer-visiting
                          (expand-file-name "T.org" org-jira-working-dir))
      (save-restriction (widen) (buffer-substring-no-properties
                                 (point-min) (point-max))))))

(ert-deftest org-jira-comment-headline-test ()
  ;; The suite runs in UTC; see `set-time-zone-rule' at the top of this file.
  (should (string= "[[jira-user:12345][@Gowri Hiremath]] [2026-10-02 Fri 15:35]"
                   (org-jira--comment-headline
                    "2026-10-02T15:35:12.000+0000" "12345" "Gowri Hiremath")))
  (should (string= "@Gowri Hiremath [2026-10-02 Fri 15:35]"
                   (org-jira--comment-headline
                    "2026-10-02T15:35:12.000+0000" nil "Gowri Hiremath"))))

(ert-deftest org-jira-sdk-comment-author-id-test ()
  (should (equal "12345" (oref (org-jira-t-comment "1" "2026-10-02T15:35:12.000+0000"
                                                   "12345" "A" "b")
                               author-id)))
  ;; Jira Server has no accountId.
  (should (equal "jdoe" (oref (org-jira-sdk-create-comment-from-data
                               '((id . "1") (body . "b") (created . "2026-10-02T15:35:12.000+0000")
                                 (updated . "2026-10-02T15:35:12.000+0000")
                                 (author . ((displayName . "J") (name . "jdoe")))))
                              author-id))))

(ert-deftest org-jira-render-comment-nests-under-comments-test ()
  (org-jira-t-with-issue-file
   (let ((text (org-jira-t-render
                (org-jira-t-comment "1" "2026-10-02T15:35:12.000+0000" "12345" "Ann" "first")
                (org-jira-t-comment "2" "2026-10-02T16:00:00.000+0000" "678" "Bob" "second"))))
     (should (= 1 (with-temp-buffer (insert text) (goto-char (point-min))
                                    (how-many "^\\*\\*\\* Comments$"))))
     ;; Comments sit after the worklog, not inside it.
     (should (string-match-p "Worklog: someone\n:PROPERTIES:\n:ID: w1\n:END:\n\\*\\*\\* Comments\n\\*\\*\\*\\* \\[\\[jira-user:12345\\]\\[@Ann\\]\\] \\[[^]]+\\]\n"
                             text))
     (should (< (string-match "@Ann" text) (string-match "@Bob" text))))))

(ert-deftest org-jira-render-comment-replaces-by-id-test ()
  (org-jira-t-with-issue-file
   (org-jira-t-render
    (org-jira-t-comment "1" "2026-10-02T15:35:12.000+0000" "12345" "Ann" "old"))
   (let ((text (org-jira-t-render
                (org-jira-t-comment "1" "2026-10-02T15:35:12.000+0000" "12345" "Ann" "new"))))
     (should (string-match-p "new" text))
     (should-not (string-match-p "old" text))
     (should (= 1 (with-temp-buffer (insert text) (goto-char (point-min))
                                    (how-many "^\\*\\*\\*\\* ")))))))

(ert-deftest org-jira-render-comment-migrates-legacy-heading-test ()
  (org-jira-t-with-issue-file
   (with-temp-file (expand-file-name "T.org" org-jira-working-dir)
     (insert "** TODO T-1 an issue\n:PROPERTIES:\n:ID: T-1\n:END:\n"
             "*** Comment: Ann\n:PROPERTIES:\n:ID: 1\n:END:\n  legacy\n"
             "*** Worklog: someone\n:PROPERTIES:\n:ID: w1\n:END:\n"))
   (let ((text (org-jira-t-render
                (org-jira-t-comment "1" "2026-10-02T15:35:12.000+0000" "12345" "Ann" "body"))))
     (should-not (string-match-p "Comment: Ann" text))
     (should-not (string-match-p "legacy" text))
     (should (string-match-p "\\*\\*\\* Comments\n\\*\\*\\*\\* \\[\\[jira-user:12345\\]" text))
     (should (string-match-p "Worklog: someone" text)))))

(ert-deftest org-jira-ensure-on-comment-recognizes-nested-comment-test ()
  (with-temp-buffer
    (org-mode)
    (insert "** TODO T-1\n*** Comments\n**** [[jira-user:1][@A]] [2026-10-02 Fri 15:35]\n:PROPERTIES:\n:ID: 9\n:END:\n  hi\n")
    (should (equal "9" (org-jira-get-from-org 'comment 'id)))
    (goto-char (point-min))
    (re-search-forward "^\\*\\*\\* Comments")
    (should-error (org-jira-get-from-org 'comment 'id))))

(ert-deftest org-jira-user-link-follow-test ()
  (let ((jiralib-url "https://jira.example.com/") opened)
    (cl-letf (((symbol-function 'browse-url) (lambda (u) (setq opened u))))
      (funcall (org-link-get-parameter "jira-user" :follow) "12345" nil))
    (should (string= "https://jira.example.com/jira/people/12345" opened))))


;;; Account name lookup

(defmacro org-jira-t-with-account-names (users cache fetch &rest body)
  "Run BODY with USERS, CACHE and a `jiralib-get-user' stub returning FETCH.
Bind `fetched' to the list of ids the stub was asked for."
  `(let ((org-jira-users ,users)
         (jiralib-users-cache ,cache)
         (org-jira--account-names nil)
         (fetched nil))
     (cl-letf (((symbol-function 'jiralib-get-user)
                (lambda (id) (push id fetched) ,fetch)))
       ,@body)))

(ert-deftest org-jira-account-name-from-users-test ()
  (org-jira-t-with-account-names '(("Ann A" . "a1")) nil nil
    (should (string= "Ann A" (org-jira-account-name "a1")))
    (should-not fetched)))

(ert-deftest org-jira-account-name-from-users-cache-test ()
  (org-jira-t-with-account-names
   nil '(((accountId . "b2") (displayName . "Bob B"))) nil
   (should (string= "Bob B" (org-jira-account-name "b2")))
   (should-not fetched)))

(ert-deftest org-jira-account-name-fetches-once-test ()
  (org-jira-t-with-account-names nil nil '((displayName . "Cy C"))
    (should (string= "Cy C" (org-jira-account-name "c3")))
    (should (string= "Cy C" (org-jira-account-name "c3")))
    (should (equal '("c3") fetched))))

(ert-deftest org-jira-account-name-no-fetch-test ()
  (org-jira-t-with-account-names nil nil '((displayName . "Cy C"))
    (should-not (org-jira-account-name "c3" t))
    (should-not fetched)
    ;; A no-fetch miss is not remembered, so a later lookup may fetch.
    (should (string= "Cy C" (org-jira-account-name "c3")))))

(ert-deftest org-jira-account-name-remembers-failure-test ()
  (org-jira-t-with-account-names nil nil (error "boom")
    (should-not (org-jira-account-name "d4"))
    (should-not (org-jira-account-name "d4"))
    (should (equal '("d4") fetched))))


;;; Issue heading carries the key link; plain Description subheader

(defun org-jira-t-issue (summary)
  "Build an issue record for T-1 from raw Jira data."
  (org-jira-sdk-create-issue-from-data
   `((key . "T-1") (id . "10001")
     (fields . ((summary . ,summary) (description . "the text")
                (status . ((name . "To Do"))) (priority . ((name . "High")))
                (project . ((key . "T"))) (issuetype . ((name . "Task") (id . "3")))
                (assignee . ((displayName . "Ann"))) (reporter . ((displayName . "Bob")))
                (created . "2026-10-02T15:35:12.000+0000")
                (updated . "2026-10-02T15:35:12.000+0000")
                (labels . []) (components . []))))))

(defun org-jira-t-render-issue (summary)
  "Render T-1 with SUMMARY into the project file and return its text."
  (let ((org-jira-download-comments nil)
        (org-jira-worklog-sync-p nil))
    (cl-letf (((symbol-function 'switch-to-buffer) #'ignore))
      (org-jira--render-issue (org-jira-t-issue summary))))
  (with-current-buffer (find-buffer-visiting
                        (expand-file-name "T.org" org-jira-working-dir))
    (save-restriction (widen) (buffer-substring-no-properties
                               (point-min) (point-max)))))

(ert-deftest org-jira-render-issue-heading-has-key-link-test ()
  (org-jira-t-with-issue-file
   (let ((text (org-jira-t-render-issue "Fix the thing")))
     (should (string-match-p
              "^\\*\\* TODO \\(?:\\[#[A-Z]\\] \\)?\\[\\[jira:T-1\\]\\[T-1\\]\\] Fix the thing$" text))
     (should-not (string-match-p ":T_1:" text)))))

(ert-deftest org-jira-render-issue-description-subheader-test ()
  (org-jira-t-with-issue-file
   (let ((text (org-jira-t-render-issue "Fix the thing")))
     (should (string-match-p "^\\*\\*\\* Description\n  the text" text))
     (should-not (string-match-p "description:" text)))))

(ert-deftest org-jira-render-issue-migrates-legacy-test ()
  (org-jira-t-with-issue-file
   (with-temp-file (expand-file-name "T.org" org-jira-working-dir)
     (insert "* Project: [[file:T.org][T]]\n"
             "** TODO [#C] Old summary   :T_1:\n:PROPERTIES:\n:ID: T-1\n:END:\n"
             "*** description: [[https://x/browse/T-1][T-1]]\n  old text\n"))
   (let ((text (org-jira-t-render-issue "New summary")))
     (should-not (string-match-p ":T_1:" text))
     (should-not (string-match-p "description:" text))
     (should-not (string-match-p "old text" text))
     (should (= 1 (with-temp-buffer (insert text) (goto-char (point-min))
                                    (how-many "^\\*\\*\\* Description$"))))
     (should (string-match-p "\\[\\[jira:T-1\\]\\[T-1\\]\\] New summary$" text)))))

(ert-deftest org-jira-issue-summary-from-org-strips-key-link-test ()
  (with-temp-buffer
    (org-mode)
    (insert "** TODO [#B] [[jira:T-1][T-1]] Fix the thing\n:PROPERTIES:\n:ID: T-1\n:END:\n")
    (goto-char (point-min))
    (should (string= "Fix the thing"
                     (org-jira-strip-priority-tags
                      (org-jira-get-issue-val-from-org 'summary))))
    ;; Headings from before the link was added still work.
    (erase-buffer)
    (insert "** TODO [#B] Fix the thing\n:PROPERTIES:\n:ID: T-1\n:END:\n")
    (goto-char (point-min))
    (should (string= "Fix the thing"
                     (org-jira-strip-priority-tags
                      (org-jira-get-issue-val-from-org 'summary))))))

(ert-deftest org-jira-issue-description-from-org-reads-both-headings-test ()
  (dolist (heading '("Description" "description: [[https://x/browse/T-1][T-1]]"))
    (with-temp-buffer
      (org-mode)
      (insert "** TODO T-1\n:PROPERTIES:\n:ID: T-1\n:END:\n*** " heading "\n  the text\n")
      (goto-char (point-min))
      (should (string= "the text" (org-jira-get-issue-val-from-org 'description))))))

(ert-deftest org-jira-jira-link-follow-test ()
  (let ((jiralib-url "https://jira.example.com/") opened)
    (cl-letf (((symbol-function 'browse-url) (lambda (u) (setq opened u))))
      (funcall (org-link-get-parameter "jira" :follow) "T-1" nil))
    (should (string= "https://jira.example.com/browse/T-1" opened))))

(ert-deftest org-jira-jira-link-export-test ()
  (let ((jiralib-url "https://jira.example.com")
        (export (org-link-get-parameter "jira" :export)))
    (should (string= "<a href=\"https://jira.example.com/browse/T-1\">Look</a>"
                     (funcall export "T-1" "Look" 'html nil)))
    (should (string= "<a href=\"https://jira.example.com/browse/T-1\">T-1</a>"
                     (funcall export "T-1" nil 'html nil)))
    (should (string= "\\href{https://jira.example.com/browse/T-1}{T-1}"
                     (funcall export "T-1" nil 'latex nil)))
    (should (string= "T-1" (funcall export "T-1" nil 'ascii nil)))))

(ert-deftest org-jira-jira-link-insert-description-test ()
  (cl-letf (((symbol-function 'jiralib-get-issue)
             (lambda (key &optional _) `((fields . ((summary . ,(concat "S of " key))))))))
    (should (string= "T-1: S of T-1"
                     (funcall (org-link-get-parameter "jira" :insert-description)
                              "jira:T-1" nil)))))


;;; Top-level issues: migrating the legacy PROJ-Tickets wrapper

(ert-deftest org-jira-migrate-tickets-heading-promotes-subtree-test ()
  (with-temp-buffer
    (org-mode)
    (insert "#+title: T\n* T-Tickets\n** TODO [[jira:T-1][T-1]] one\n:PROPERTIES:\n:ID: T-1\n:END:\n"
            "*** description: [[x][T-1]]\n  text\n*** Comments\n**** @Ann [2026-10-02 Fri 15:35]\n"
            "** TODO [[jira:T-2][T-2]] two\n")
    (org-jira--migrate-tickets-heading "T")
    (should (string= (buffer-string)
                     (concat "#+title: T\n* TODO [[jira:T-1][T-1]] one\n:PROPERTIES:\n:ID: T-1\n:END:\n"
                             "** description: [[x][T-1]]\n  text\n** Comments\n*** @Ann [2026-10-02 Fri 15:35]\n"
                             "* TODO [[jira:T-2][T-2]] two\n")))))

(ert-deftest org-jira-migrate-tickets-heading-is-idempotent-test ()
  (with-temp-buffer
    (org-mode)
    (insert "* T-Tickets\n** TODO one\n*** Comments\n")
    (org-jira--migrate-tickets-heading "T")
    (let ((once (buffer-string)))
      (org-jira--migrate-tickets-heading "T")
      (should (string= once (buffer-string)))
      (should (string= "* TODO one\n** Comments\n" once)))))

(ert-deftest org-jira-migrate-tickets-heading-leaves-other-headings-test ()
  (with-temp-buffer
    (org-mode)
    (insert "* Notes\n** keep me\n* T-Tickets\n** TODO one\n* Other\n** also kept\n")
    (org-jira--migrate-tickets-heading "T")
    (should (string= "* Notes\n** keep me\n* TODO one\n* Other\n** also kept\n"
                     (buffer-string))))
  ;; A different project's wrapper is not ours to remove.
  (with-temp-buffer
    (org-mode)
    (insert "* X-Tickets\n** TODO one\n")
    (org-jira--migrate-tickets-heading "T")
    (should (string= "* X-Tickets\n** TODO one\n" (buffer-string)))))

(ert-deftest org-jira-migrate-tickets-heading-keeps-text-under-wrapper-test ()
  ;; Nothing a person wrote under the wrapper heading may be lost.
  (with-temp-buffer
    (org-mode)
    (insert "* T-Tickets\nmy own note\n** TODO one\n")
    (org-jira--migrate-tickets-heading "T")
    (should (string= "my own note\n* TODO one\n" (buffer-string)))))

(ert-deftest org-jira-migrate-tickets-heading-ignores-narrowing-test ()
  (with-temp-buffer
    (org-mode)
    (insert "* T-Tickets\n** TODO one\n** TODO two\n")
    (goto-char (point-min))
    (forward-line 2)
    (org-narrow-to-subtree)
    (org-jira--migrate-tickets-heading "T")
    (should (string= "* TODO one\n* TODO two\n"
                     (save-restriction (widen) (buffer-string))))))

;;; Top-level issues: reading works at any heading level

(defconst org-jira-t-new-layout
  (concat "* TODO [[jira:T-1][T-1]] one\n:PROPERTIES:\n:ID: T-1\n:END:\n"
          "** Description\n  text\n"
          "** Comments\n*** @Ann [2026-10-02 Fri 15:35]\n:PROPERTIES:\n:ID: 90\n:END:\n  hi\n"
          "** Attachments:\n*** [[u][f.png]]\n:PROPERTIES:\n:ID: 91\n:END:\n"
          "* TODO [[jira:T-2][T-2]] two\n:PROPERTIES:\n:ID: T-2\n:END:\n"))

(defconst org-jira-t-legacy-layout
  (concat "* T-Tickets\n"
          "** TODO [[jira:T-1][T-1]] one\n:PROPERTIES:\n:ID: T-1\n:END:\n"
          "*** Description\n  text\n"
          "*** Comments\n**** @Ann [2026-10-02 Fri 15:35]\n:PROPERTIES:\n:ID: 90\n:END:\n  hi\n"
          "*** Attachments:\n**** [[u][f.png]]\n:PROPERTIES:\n:ID: 91\n:END:\n"
          "** TODO [[jira:T-2][T-2]] two\n:PROPERTIES:\n:ID: T-2\n:END:\n"))

(defun org-jira-t-issue-id-at (text needle)
  "In TEXT, put point on the first NEEDLE and return the issue `ensure-on-issue' finds."
  (with-temp-buffer
    (org-mode)
    (insert text)
    (goto-char (point-min))
    (search-forward needle)
    (ensure-on-issue (org-jira-id))))

(ert-deftest org-jira-ensure-on-issue-any-level-test ()
  (dolist (text (list org-jira-t-new-layout org-jira-t-legacy-layout))
    (dolist (needle '("one" "Description" "  text" "@Ann" "  hi" "f.png" "Attachments:"))
      (should (equal "T-1" (org-jira-t-issue-id-at text needle))))
    (should (equal "T-2" (org-jira-t-issue-id-at text "two")))))

(ert-deftest org-jira-issue-key-p-test ()
  (dolist (key '("EX-22" "T-1" "AB2_C-10" "AUTO-9616"))
    (should (org-jira--issue-key-p key)))
  ;; Comment and worklog ids are numeric; nothing else should pass either.
  (dolist (key '("10001" "T-" "-1" "T-1x" "T-1\nX" "" nil))
    (should-not (org-jira--issue-key-p key))))

(ert-deftest org-jira-ensure-on-issue-outside-issue-errors-test ()
  (with-temp-buffer
    (org-mode)
    (insert "#+title: nothing here\n* Notes\n:PROPERTIES:\n:ID: 12\n:END:\n")
    (goto-char (point-max))
    (should-error (ensure-on-issue (org-jira-id)))
    (goto-char (point-min))
    (should-error (ensure-on-issue (org-jira-id)))))

(ert-deftest org-jira-ensure-on-issue-keeps-point-and-narrowing-test ()
  (with-temp-buffer
    (org-mode)
    (insert org-jira-t-new-layout)
    (goto-char (point-min))
    (search-forward "@Ann")
    (org-narrow-to-subtree)
    (let ((pos (point)) (min (point-min)) (max (point-max)))
      (ensure-on-issue (should (= 1 (point-min))))
      (should (= pos (point)))
      (should (= min (point-min)))
      (should (= max (point-max))))))

(ert-deftest org-jira-issue-ids-in-buffer-skips-non-issues-test ()
  (dolist (text (list org-jira-t-new-layout org-jira-t-legacy-layout))
    (with-temp-buffer
      (org-mode)
      (insert text)
      (should (equal '("T-1" "T-2") (org-jira--issue-ids-in-buffer))))))

(ert-deftest org-jira-issue-ids-in-buffer-ignores-level-2-numeric-ids-test ()
  ;; Worklog and attachment headings sit at level 2 under a level-1 issue
  ;; and carry numeric :ID: properties.
  (with-temp-buffer
    (org-mode)
    (insert "* TODO one\n:PROPERTIES:\n:ID: T-1\n:END:\n"
            "** Worklog: someone\n:PROPERTIES:\n:ID: 10001\n:END:\n")
    (should (equal '("T-1") (org-jira--issue-ids-in-buffer)))))

(ert-deftest org-jira-comment-heading-p-any-level-test ()
  (dolist (text (list org-jira-t-new-layout org-jira-t-legacy-layout))
    (with-temp-buffer
      (org-mode)
      (insert text)
      (goto-char (point-min))
      (search-forward "@Ann")
      (should (org-jira--comment-heading-p))
      (should (equal "90" (org-jira-get-from-org 'comment 'id)))
      (goto-char (point-min))
      (search-forward "Comments")
      (should-not (org-jira--comment-heading-p))
      (goto-char (point-min))
      (search-forward "f.png")
      (should-not (org-jira--comment-heading-p)))))

(ert-deftest org-jira-comment-heading-p-accepts-legacy-heading-test ()
  (with-temp-buffer
    (org-mode)
    (insert "* TODO one\n:PROPERTIES:\n:ID: T-1\n:END:\n** Comment: Ann\n:PROPERTIES:\n:ID: 90\n:END:\n")
    (goto-char (point-min))
    (search-forward "Comment:")
    (beginning-of-line)
    (should (org-jira--comment-heading-p))))

(provide 'org-jira-t)
;;; org-jira-t.el ends here
