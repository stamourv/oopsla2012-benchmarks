#lang typed/racket
;;; heapsort.scm

;; Prints 0.9990640717878372 instead of 0.9990640718 when n=1000.
;; Updated by Justin Smith
;;
;; Updated by Brent Fulgham to provide proper output formatting

(require (only-in srfi/13 string-index string-pad-right)
         (only-in mzlib/string real->decimal-string)
         racket/unsafe/ops)

(define IM   139968)
(define IA     3877)
(define IC    29573)

(: LAST Integer)
(define LAST 42)
(: gen_random (Float -> Float))
(define (gen_random max)
  (set! LAST (modulo (+ (* LAST IA) IC) IM))
  (/ (* max (exact->inexact LAST)) (exact->inexact IM)))

(: heapsort (Integer (Vectorof Float) -> (U Void True)))
(define (heapsort n ra)
  (let: ((ir : Integer n)
         (l : Integer (+ (quotient n 2) 1))
         (i : Integer 0)
         (j : Integer 0)
         (rra : Float 0.0))
    (let/ec: return : True
      (do: : Void
           ((bar : True #t))
           ((= 1 0))
        (cond ((> l 1)
               (set! l (- l 1))
               (set! rra (unsafe-vector-ref ra l)))
              (else
               (set! rra (unsafe-vector-ref ra ir))
               (unsafe-vector-set! ra ir (unsafe-vector-ref ra 1))
               (set! ir (- ir 1))
               (cond ((<= ir 1)
                      (unsafe-vector-set! ra 1 rra)
                      (return #t)))))
        (set! i l)
        (set! j (* l 2))
        (do ((foo #t))
            ((> j ir))
          (cond ((and (< j ir) (< (unsafe-vector-ref ra j) (unsafe-vector-ref ra (+ j 1))))
                 (set! j (+ j 1))))
          (cond ((< rra (unsafe-vector-ref ra j))
                 (unsafe-vector-set! ra i (unsafe-vector-ref ra j))
                 (set! i j)
                 (set! j (+ j i)))
                (else
                 (set! j (+ ir 1)))))
        (unsafe-vector-set! ra i rra)))))

(: main ((Vectorof String) -> Void))
(define (main args)
  (let*: ((n : Integer
             (or (and (= (unsafe-vector-length args) 1)
                      (assert (string->number (unsafe-vector-ref args 0)) exact-nonnegative-integer?))
                 1))
          (last : Integer (+ n 1))
          (ary : (Vectorof Float) (make-vector last 0.0)))
    (do ((i 1 (+ i 1)))
        ((= i last))
      (unsafe-vector-set! ary i (gen_random 1.0)))
    (heapsort n ary)
    (printf "~a\n"
            (real->decimal-string (unsafe-vector-ref ary n) 10))))

(main (current-command-line-arguments))
