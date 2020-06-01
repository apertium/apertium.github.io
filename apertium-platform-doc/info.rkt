#lang info

(define collection "apertium-platform-doc")
(define deps '("base" "scribble-lib"))
(define build-deps '("scribble-lib" "racket-doc" "rackunit-lib"))
(define scribblings '(("index.scrbl" (multi-page))))
(define pkg-desc "Documentation of the Apertium machine translation platform")
(define pkg-authors '("Ilnar Salimzianov"))
(define version "3.5.2")
