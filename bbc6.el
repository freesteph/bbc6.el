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
(defconst bbc6-latest-url "https://rms.api.bbc.co.uk/v2/services/bbc_6music/segments/latest?experience=domestic&offset=0&limit=1")

(defun bbc6-what-track-now ()
  "Fetch and print the current track playing on BBC6."
  (interactive)
  (save-excursion
    (with-current-buffer (url-retrieve-synchronously bbc6-latest-url)
      (let* ((payload (json-parse-buffer)))
        (message "Currently playing on BBC6: %s" (bbc6-parse-entry payload))))))

(defun bbc6-parse-entry (payload)
  "Parse a PAYLOAD from BBC6 and formats the artist and title."
  (let* ((titles (gethash "titles" (car (gethash "data" payload))))
         (artist (gethash "primary" titles))
         (track  (gethash "secondary" titles)))
    (format "%s - %s" artist track)))

(provide 'bbc6)
;;; bbc6.el ends here
