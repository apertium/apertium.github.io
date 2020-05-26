#lang scribble/base

@(require scribble/core
          scribble/html-properties)

@(provide strikethrough sout colorize red)

@(define strikethrough
  (make-style "strikethrough"
    (list (make-css-addition "strikethrough.css"))))

@(define (sout . words)
   (elem #:style strikethrough words))

@(define (colorize #:color c . content)
  (elem #:style (style #f (list (color-property c)))
        content))

@(define (red . content)
  (colorize #:color "red" content))
