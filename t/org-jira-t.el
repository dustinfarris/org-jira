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


(provide 'org-jira-t)
;;; org-jira-t.el ends here
