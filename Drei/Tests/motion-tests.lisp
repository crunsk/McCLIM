;;; -*- Mode: Lisp; Package: COMMON-LISP-USER -*-

;;;  (c) copyright 2005 by
;;;           Aleksandar Bakic (a_bakic@yahoo.com)
;;;  (c) copyright 2006 by
;;;           Troels Henriksen (athas@sigkill.dk)

;;; This library is free software; you can redistribute it and/or
;;; modify it under the terms of the GNU Library General Public
;;; License as published by the Free Software Foundation; either
;;; version 2 of the License, or (at your option) any later version.
;;;
;;; This library is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;;; Library General Public License for more details.
;;;
;;; You should have received a copy of the GNU Library General Public
;;; License along with this library; if not, write to the
;;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;;; Boston, MA  02111-1307  USA.

(cl:in-package :drei-tests)

(def-suite motion-tests :description "The test suite for
DREI-MOTION related tests.")

(in-suite motion-tests)

(test error-limit-action
  (with-buffer (buffer)
    (signals motion-limit-error
      (error-limit-action (point buffer) 0 0 "foo" (syntax buffer)))))

(test forward-to-word-boundary
  (with-buffer (buffer :initial-contents "  climacs
climacs")
    (let ((syntax (syntax buffer))
          (m0l (clone-mark (low-mark buffer) :left))
          (m0r (clone-mark (low-mark buffer) :right))
          (m1l (clone-mark (low-mark buffer) :left))
          (m1r (clone-mark (low-mark buffer) :right))
          (m2l (clone-mark (low-mark buffer) :left))
          (m2r (clone-mark (low-mark buffer) :right)))
      (setf (offset m0l) 0
            (offset m0r) 0
            (offset m1l) 5
            (offset m1r) 5
            (offset m2l) 17
            (offset m2r) 17)
      (forward-to-word-boundary m0l syntax)
      (is (= (offset m0l) 2))
      (forward-to-word-boundary m0r syntax)
      (is (= (offset m0r) 2))
      (forward-to-word-boundary m1l syntax)
      (is (= (offset m1l) 5))
      (forward-to-word-boundary m1r syntax)
      (is (= (offset m1r) 5))
      (forward-to-word-boundary m2l syntax)
      (is (= (offset m2l) 17))
      (forward-to-word-boundary m2r syntax)
      (is (= (offset m2r) 17)))))

(test backward-to-word-boundary
  (with-buffer (buffer :initial-contents "climacs
climacs  ")
    (let ((syntax (syntax buffer))
          (m0l (clone-mark (low-mark buffer) :left))
          (m0r (clone-mark (low-mark buffer) :right))
          (m1l (clone-mark (low-mark buffer) :left))
          (m1r (clone-mark (low-mark buffer) :right))
          (m2l (clone-mark (low-mark buffer) :left))
          (m2r (clone-mark (low-mark buffer) :right)))
      (setf (offset m0l) 17
            (offset m0r) 17
            (offset m1l) 10
            (offset m1r) 10
            (offset m2l) 0
            (offset m2r) 0)
      (backward-to-word-boundary m0l syntax)
      (is (= (offset m0l) 15))
      (backward-to-word-boundary m0r syntax)
      (is (= (offset m0r) 15))
      (backward-to-word-boundary m1l syntax)
      (is (= (offset m1l) 10))
      (backward-to-word-boundary m1r syntax)
      (is (= (offset m1r) 10))
      (backward-to-word-boundary m2l syntax)
      (is (= (offset m2l) 0))
      (backward-to-word-boundary m2r syntax)
      (is (= (offset m2r) 0)))))

(defmacro motion-fun-one-test (unit (forward-begin-offset
                                     backward-end-offset
                                     (offset goal-forward-offset goal-backward-offset)
                                     initial-contents
                                     &key (syntax ''drei-fundamental-syntax:fundamental-syntax)))
  (check-type forward-begin-offset integer)
  (check-type backward-end-offset integer)
  (check-type offset integer)
  (check-type goal-forward-offset integer)
  (check-type goal-backward-offset integer)
  (let ((forward (intern (format nil "FORWARD-ONE-~S" unit)))
        (backward (intern (format nil "BACKWARD-ONE-~S" unit))))
    `(progn
       (test ,forward
         (with-buffer (buffer :initial-contents ,initial-contents
                              :syntax ,syntax)
           (let ((syntax (syntax buffer))
                 (m0l (clone-mark (low-mark buffer) :left))
                 (m0r (clone-mark (low-mark buffer) :right))
                 (m1l (clone-mark (low-mark buffer) :left))
                 (m1r (clone-mark (low-mark buffer) :right))
                 (m2l (clone-mark (low-mark buffer) :left))
                 (m2r (clone-mark (low-mark buffer) :right)))
             (setf (offset m0l) 0
                   (offset m0r) 0
                   (offset m1l) ,offset
                   (offset m1r) ,offset
                   (offset m2l) (size buffer)
                   (offset m2r) (size buffer))
             (is-true (,forward m0l syntax))
             (is (= (offset m0l) ,forward-begin-offset))
             (is-true (,forward m0r syntax))
             (is (= (offset m0r) ,forward-begin-offset))
             (is-true (,forward m1l syntax))
             (is (= (offset m1l) ,goal-forward-offset))
             (is-true (,forward m1r syntax))
             (is (= (offset m1r) ,goal-forward-offset))
             (is-false (,forward m2l syntax))
             (is (= (offset m2l) (size buffer)))
             (is-false (,forward m2r syntax))
             (is (= (offset m2r) (size buffer))))))
       (test ,backward
         (with-buffer (buffer :initial-contents ,initial-contents
                              :syntax ,syntax)
           (let ((syntax (syntax buffer))
                 (m0l (clone-mark (low-mark buffer) :left))
                 (m0r (clone-mark (low-mark buffer) :right))
                 (m1l (clone-mark (low-mark buffer) :left))
                 (m1r (clone-mark (low-mark buffer) :right))
                 (m2l (clone-mark (low-mark buffer) :left))
                 (m2r (clone-mark (low-mark buffer) :right)))
             (setf (offset m0l) 0
                   (offset m0r) 0
                   (offset m1l) ,offset
                   (offset m1r) ,offset
                   (offset m2l) (size buffer)
                   (offset m2r) (size buffer))
             (is-false (,backward m0l syntax))
             (is (= (offset m0l) 0))
             (is-false (,backward m0r syntax))
             (is (= (offset m0r) 0))
             (is-true (,backward m1l syntax))
             (is (= (offset m1l) ,goal-backward-offset))
             (is-true (,backward m1r syntax))
             (is (= (offset m1r) ,goal-backward-offset))
             (is-true (,backward m2l syntax))
             (is (= (offset m2l) ,backward-end-offset))
             (is-true (,backward m2r syntax))
             (is (= (offset m2r) ,backward-end-offset))))))))

(motion-fun-one-test word (9 10 (5 9 2)
                             "  climacs
climacs"))

(motion-fun-one-test line (17 22 (25 47 8)
                              "Climacs-Climacs!
climacsclimacsclimacs...
Drei!"))

(motion-fun-one-test page (19 42 (22 40 21)
                              "This is about Drei!
Drei is Cool Stuff.

"))

(motion-fun-one-test paragraph (21 67 (30 64 23)
                                   "Climacs is an editor.

It is based on the Drei editor substrate.


Run, Climacs, Run!
Preferably a bit faster."))

(defmacro motion-fun-test (unit ((forward-begin-offset1
                                  forward-begin-offset2)
                                 (backward-end-offset1
                                  backward-end-offset2)
                                 (offset unit-count
                                         goal-forward-offset
                                         goal-backward-offset)
                                 initial-contents
                                 &key (syntax ''drei-fundamental-syntax:fundamental-syntax)))
  (check-type forward-begin-offset1 integer)
  (check-type forward-begin-offset2 integer)
  (check-type backward-end-offset1 integer)
  (check-type backward-end-offset2 integer)
  (check-type offset integer)
  (check-type goal-forward-offset integer)
  (check-type goal-backward-offset integer)
  (let ((forward (intern (format nil "FORWARD-~S" unit)))
        (backward (intern (format nil "BACKWARD-~S" unit))))
    `(progn
       (test ,forward
         (with-buffer (buffer :initial-contents ,initial-contents
                              :syntax ,syntax)
           (let ((syntax (syntax buffer))
                 (m0l (clone-mark (low-mark buffer) :left))
                 (m0r (clone-mark (low-mark buffer) :right))
                 (m1l (clone-mark (low-mark buffer) :left))
                 (m1r (clone-mark (low-mark buffer) :right))
                 (m2l (clone-mark (low-mark buffer) :left))
                 (m2r (clone-mark (low-mark buffer) :right)))
             (setf (offset m0l) 0
                   (offset m0r) 0
                   (offset m1l) ,offset
                   (offset m1r) ,offset
                   (offset m2l) (size buffer)
                   (offset m2r) (size buffer))
             (is-true (,forward m0l syntax 1 nil))
             (is (= (offset m0l) ,forward-begin-offset1))
             (beginning-of-buffer m0l)
             (is-true (,forward m0l syntax 2 nil))
             (is (= (offset m0l) ,forward-begin-offset2))

             (is-true (,forward m0r syntax 1 nil))
             (is (= (offset m0r) ,forward-begin-offset1))
             (beginning-of-buffer m0r)
             (is-true (,forward m0r syntax 2 nil))
             (is (= (offset m0r) ,forward-begin-offset2))
                 
             (is-true (,forward m1l syntax ,unit-count nil))
             (is (= (offset m1l) ,goal-forward-offset))
             (is-true (,forward m1r syntax ,unit-count nil))
             (is (= (offset m1r) ,goal-forward-offset))

             (is-false (,forward m2l syntax 1 nil))
             (is (= (offset m2l) (size buffer)))
             (is-false (,forward m2r syntax 2 nil))
             (is (= (offset m2r) (size buffer))))))
       (test ,backward
         (with-buffer (buffer :initial-contents ,initial-contents
                              :syntax ,syntax)
           (let ((syntax (syntax buffer))
                 (m0l (clone-mark (low-mark buffer) :left))
                 (m0r (clone-mark (low-mark buffer) :right))
                 (m1l (clone-mark (low-mark buffer) :left))
                 (m1r (clone-mark (low-mark buffer) :right))
                 (m2l (clone-mark (low-mark buffer) :left))
                 (m2r (clone-mark (low-mark buffer) :right)))
             (setf (offset m0l) 0
                   (offset m0r) 0
                   (offset m1l) ,offset
                   (offset m1r) ,offset
                   (offset m2l) (size buffer)
                   (offset m2r) (size buffer))
             (is-false (,backward m0l syntax 1 nil))
             (is (= (offset m0l) 0))
             (is-false (,backward m0r syntax 2 nil))
             (is (= (offset m0r) 0))
                 
             (is-true (,backward m1l syntax ,unit-count nil))
             (is (= (offset m1l) ,goal-backward-offset))
             (is-true (,backward m1r syntax ,unit-count nil))
             (is (= (offset m1r) ,goal-backward-offset))

             (is-true (,backward m2l syntax 1 nil))
             (is (= (offset m2l) ,backward-end-offset1))
             (end-of-buffer m2l)
             (is-true (,backward m2l syntax 2 nil))
             (is (= (offset m2l) ,backward-end-offset2))

             (is-true (,backward m2r syntax 1 nil))
             (is (= (offset m2r) ,backward-end-offset1))
             (end-of-buffer m2r)
             (is-true (,backward m2r syntax 2 nil))
             (is (= (offset m2r) ,backward-end-offset2))))))))

(motion-fun-test word ((2 7) (21 16) (10 3 15 0)
                       "My word, it's a
good word!"))

(motion-fun-test line ((21 29) (67 55) (53 2 67 7)
                       "The fun part of this
is that
column position has to be
maintained.

How can this lead to anything but joy?"))

(motion-fun-test page ((19 21) (159 133) (30 2 157 21)
                       "I am testing pages.


By default, the page seperator is a newline followed by a .
A single  should not cause the page to shift.

If it does, it's a bug.

Please fix it."))

(motion-fun-test paragraph ((24 70) (248 223) (100 2 246 26)
                            "I am testing paragraphs.

Paragraphs are seperated by double newlines.

That really just looks like a single blank line, but is must not
contain space characters.

If this rule is not followed, that is, as always, a bug.

And it should be fixed.

This is the last paragraph."))
