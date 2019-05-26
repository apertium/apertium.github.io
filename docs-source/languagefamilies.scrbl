#lang scribble/manual

@(require scribble/core
          scribble/html-properties)

@(define (status-badge url) 
   (elem
    #:style
    (make-style #f
                (list (alt-tag "img")
                      (attributes
                       `((src . ,url)))))))

@(define (monoling-status-badges lang)
  `(
    ,(status-badge (string-append "https://travis-ci.org/apertium/apertium-" lang ".svg?branch=master"))
    ,(status-badge (string-append "https://circleci.com/gh/apertium/apertium-" lang "/tree/master.svg?style=svg"))
    ,(status-badge (string-append "https://s3.eu-central-1.amazonaws.com/apertium/apertium-" lang "/cov.jam.svg"))
    ,(status-badge (string-append "https://s3.eu-central-1.amazonaws.com/apertium/apertium-" lang "/cov.udhr.svg"))
    ,(status-badge (string-append "https://s3.eu-central-1.amazonaws.com/apertium/apertium-" lang "/cov.bible.svg"))))

@title[#:tag "languagefamilies" #:version "3.5.2"]{Appendix E. Linguistic data repositories by language families}

@section{Turkic}

apertium-alt : @(monoling-status-badges "alt")

apertium-aze : @(monoling-status-badges "aze")

apertium-bak : @(monoling-status-badges "bak")

apertium-chv : @(monoling-status-badges "chv")

apertium-crh : @(monoling-status-badges "crh")

apertium-gag : @(monoling-status-badges "gag")

apertium-kaa : @(monoling-status-badges "kaa")

apertium-kaz : @(monoling-status-badges "kaz")

apertium-kir : @(monoling-status-badges "kir")

apertium-kjh : @(monoling-status-badges "kjh")

apertium-krc : @(monoling-status-badges "krc")

apertium-kum : @(monoling-status-badges "kum")

apertium-nog : @(monoling-status-badges "nog")

apertium-sah : @(monoling-status-badges "sah")

apertium-tat : @(monoling-status-badges "tat")

apertium-tur : @(monoling-status-badges "tur")

apertium-tuk : @(monoling-status-badges "tuk")

apertium-tyv : @(monoling-status-badges "tyv")

apertium-uig : @(monoling-status-badges "uig")

apertium-uzb : @(monoling-status-badges "uzb")
