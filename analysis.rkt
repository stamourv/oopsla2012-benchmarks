#lang racket

;; Output: (benchmark orig-avg-time pr-opt-avg-time hand-opt-avg-time
;;                    1 pr-opt-avg-norm-time hand-opt-avg-norm-time)

(define (analyze)
  ;; First, group the timings by benchmark in a tables for each mode.
  ;; Both of these map benchmark names (symbols) to lists of timings.
  ;; TODO table (keyed by orig/hand-opt/...) of tables, to generalize to n
  (define orig-table     (make-hasheq))
  (define pr-opt-table   (make-hasheq))
  (define hand-opt-table (make-hasheq))
  (for ([x (in-port)])
    (match x
      [`(,name ,kind ,timing)
       (dict-update! (cond [(eq? kind 'orig)     orig-table]
                           [(eq? kind 'pr-opt)   pr-opt-table]
                           [(eq? kind 'hand-opt) hand-opt-table]
                           [else (error "no such benchmark kind") kind])
                     name
                     (lambda (l) (cons timing l))
                     '())]))
  ;; Then we compute the averages, and compare.
  (for ([k (in-dict-keys orig-table)]) ; We assume the same set of keys.
    (define (avg l) (exact->inexact (/ (apply + l) (length l))))
    (define orig-avg     (avg (dict-ref orig-table     k)))
    (define pr-opt-avg   (avg (dict-ref pr-opt-table   k)))
    (define hand-opt-avg (avg (dict-ref hand-opt-table k)))
    (displayln (list k orig-avg pr-opt-avg hand-opt-avg
                     ;; normalize to orig (slowest in theory)
                     1 (/ pr-opt-avg orig-avg) (/ hand-opt-avg orig-avg)))))

;; Analyze all the dumps, all the time. Whathever, fast enough, and saves us
;; from having to specify which of the very similarly-named files we want.
(for ([dump (in-directory "dumps")]
      #:unless (regexp-match ".analysis$" (path->string dump)))
  (with-input-from-file dump
    (lambda ()
      (with-output-to-file (path-add-suffix dump ".analysis")
        #:exists 'replace
        analyze))))
