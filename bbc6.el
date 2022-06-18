;;; bbc6.el --- A mode that quickly tells you what's playing on BBC6  -*- lexical-binding: t; -*-

;; Copyright (C) 2021  Stéphane Maniaci

;; Author: Stéphane Maniaci <stephane.maniaci@digital.cabinet-office.gov.uk>
;; Keywords: multimedia, internal, convenience

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; This mode will lookup the BBC6 website and find the latest track for you

;;; Code:
(require 'seq)
(require 'json)
(require 'article)

(defconst bbc6-latest-url "https://rms.api.bbc.co.uk/v2/services/bbc_6music/segments/latest?experience=domestic&offset=0&limit=1")

(defgroup bbc6 () "Variables related to the bbc6 package."
  :group 'convenience
  :link '(url-link "https://github.com/freesteph/bbc6.el"))

(defcustom bbc6-file-record nil
  "If non-nil, append every successful lookup to the file along
with the date."
  :group 'bbc6
  :type 'file)

(defun bbc6--save-track (track)
  "Save TRACK to the file living at `bbc6-file-record'."
  (with-current-buffer (find-file-noselect bbc6-file-record)
    (goto-char (point-max))
    (newline)
    (insert (format "%s: %s" (current-time-string) track))
    (save-buffer)))

(defun bbc6--log-track (track)
  "Log the TRACK."
  (message "Currently playing on BBC6: %s" track))

(defun bbc6-parse-entry (payload)
  "Parse a PAYLOAD from BBC6 and formats the artist and title."
  (let* ((data (seq-first (alist-get 'data payload)))
         (titles (alist-get 'titles data))
         (artist (alist-get 'primary titles))
         (track  (alist-get 'secondary titles)))
    (format "%s - %s" artist track)))

;;;###autoload
(defun bbc6-what-track-now ()
  "Fetch and print the current track playing on BBC6."
  (interactive)
  (save-excursion
    (with-current-buffer (url-retrieve-synchronously bbc6-latest-url)
      (article-goto-body)
      (let* ((payload (json-read))
             (track (bbc6-parse-entry payload)))
        (and bbc6-file-record
             (bbc6--save-track track))
        (bbc6--log-track track)))))

(provide 'bbc6)
;;; bbc6.el ends here
