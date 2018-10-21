;;; nes2sprite.el ---
;; Author: grugrut <grugruglut+github@gmail.com>
;; URL:
;; Version: 1.00

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Package-Requires: ((f "0.10.0")) (gamegrid "1.02")

;;; Code:

(require 'f)
(require 'gamegrid)

(defvar n2s/NES_HEADER_SIZE #x0010)
(defvar n2s/PROGRAM_ROM_SIZE #x4000)
(defvar n2s/CHARACTOR_ROM_SIZE #x2000)
(defvar n2s/SPRITE_WIDTH 256)
(defvar n2s/SPRITE_PER_ROW (/ n2s/SPRITE_WIDTH 8))
(defvar n2s/buffer-name "*NES*")

(defun nes2sprite (nespath)
  (interactive "fnesfile: ")
  (setq nes (f-read-bytes nespath))

  ;; validate
  (if (not (string= (substring nes 0 3) "NES"))
      (error "This is not valid nes file"))

  (defvar n2s/PROGRAM_ROM_PAGES (aref nes 4))
  (defvar n2s/CHARACTOR_ROM_PAGES (aref nes 5))
  (defvar n2s/SPRITE_NUM (/ (* n2s/CHARACTOR_ROM_SIZE n2s/CHARACTOR_ROM_PAGES) 16))
  (defvar n2s/ROW_NUM (+ (/ n2s/SPRITE_NUM n2s/SPRITE_PER_ROW) 1))
  (defvar n2s/height (* n2s/ROW_NUM 8))

  (defvar n2s/CHARACTOR_ROM_START (+ (* n2s/PROGRAM_ROM_PAGES n2s/PROGRAM_ROM_SIZE) n2s/NES_HEADER_SIZE))

  (switch-to-buffer n2s/buffer-name)
  (setq gamegrid-use-glyphs nil)
  (gamegrid-init (make-vector 256 nil))
  (gamegrid-init-buffer n2s/SPRITE_WIDTH
                        n2s/height
                        ? )
  (gamegrid-initialize-display)
  (dotimes (s n2s/SPRITE_NUM)
    (let ((sprite (make-vector (* 8 8) 0)))
      (dotimes (i 16)
        (dotimes (j 8)
          (if (/= (logand (aref nes (+ n2s/CHARACTOR_ROM_START (* s 16) i)) (lsh #x80 (* -1 j))) 0)
              (aset sprite (+ (* (mod i 8) 8) j) (lsh #x01 (/ i 8))))
          ))
      (dotimes (i 8)
        (dotimes (j 8)
          (let ((x (+ j (* (mod s n2s/SPRITE_PER_ROW) 8)))
                (y (+ i (* (/ s n2s/SPRITE_PER_ROW) 8))))
            (if (> (* 85 (aref sprite (+ (* i 8) j))) 128)
                (gamegrid-set-cell x y ?@))))))))

(provide 'nes2sprite)

;;; nes2sprite.el ends here
