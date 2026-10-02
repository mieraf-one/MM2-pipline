(DEF run-valuation
    (, (PATTERN $id $ptrn))
    (O
        (pure (INDEXED-PATTERN $id $idx-ptrn) $idx-ptrn
            (vars_to_indices (' $ptrn))
        )
    )
)


(exec (0 1)
    (, (PATTERN $id $ptrn)
        (FACT $ptrn)
        (INDEXED-PATTERN $id $idx-ptrn)
        (DEF take-first $tf-p $tf-t)
    )
    (O
        (+ (WALK $id $ptrn $idx-ptrn))
        (+ (exec (0 2) $tf-p $tf-t))
    )
)


; Peels the head and tail from both the pattern and fact lists simultaneously.
; take: (WALK $id $ptrn $idx-ptrn)
; put: P-HEAD, P-TAIL, F-HEAD, F-TAIL
(DEF take-first
    (, (WALK $id $ptrn $idx-ptrn)
        (DEF check-head $ch-p $ch-t))
    (O
        (pure (P-HEAD $id $ptrn $idx-ptrn $ph) $ph (car-atom (' $idx-ptrn)))
        (pure (P-TAIL $id $ptrn $idx-ptrn $pt) $pt (cdr-atom (' $idx-ptrn)))

        (pure (F-HEAD $id $ptrn $idx-ptrn $fh) $fh (car-atom (' $ptrn)))
        (pure (F-TAIL $id $ptrn $idx-ptrn $ft) $ft (cdr-atom (' $ptrn)))

        (- (WALK $id $ptrn $idx-ptrn))
        (+ (exec (0 3) $ch-p $ch-t))
    )
)

;
(DEF check-head
    (, (P-HEAD $id $ptrn $idx-ptrn $ph)
        (P-TAIL $id $ptrn $idx-ptrn $pt)
        (F-HEAD $id $ptrn $idx-ptrn $fh)
        (F-TAIL $id $ptrn $idx-ptrn $ft)
        (DEF nested-ptrn $np-p $np-t)
        (DEF create-walk $cw-p $cw-t))
    (O
        ; Check whether the p-head is an expression
        (pure (IS-EXP $id $ph $pt $fh $ft $is-exp) $is-exp
            (i8_to_string (is_exp (' $ph))))

        ; Check whether the p-head is a var
        (pure (IS-VAR $id $ph $fh $is-var) $is-var
            (i8_to_string (is_var (' $ph))))

        (- (P-HEAD $id $ptrn $idx-ptrn $ph))
        (- (P-TAIL $id $ptrn $idx-ptrn $pt))
        (- (F-HEAD $id $ptrn $idx-ptrn $fh))
        (- (F-TAIL $id $ptrn $idx-ptrn $ft))

        ; Call nested and create-walk
        (+ (exec (0 4) $np-p $np-t))
        (+ (exec (0 4) $cw-p $cw-t))
    )
)


(DEF nested-ptrn
    (, (IS-EXP $id $ph $pt $fh $ft 1)
        (DEF take-first $tf-p $tf-t)
    )

    (O
        ; Create walk for nested fact
        (+ (WALK $id $fh $ph))

        ; Create walk for normal fact
        (+ (WALK $id $ft $pt))

        (- (IS-EXP $id $ph $pt $fh $ft 1))

        ; call take-first - loop
        (+ (exec (0 2) $tf-p $tf-t))

    )
)


(DEF create-walk
    (, (IS-EXP $id $ph $pt $fh $ft 0)
        (DEF take-first $tf-p $tf-t)
    )
    (O
        (+ (WALK $id $ft $pt))

        ; call take-first
        (+ (exec (0 2) $tf-p $tf-t))
        (- (IS-EXP $id $ph $pt $fh $ft 0))
    )
)


; final output
(exec (0 5)
    (, (IS-VAR $id $ph $fh 1))
    (O
        (+ (valuation $id $ph $fh))
        (- (IS-VAR $id $ph $fh 1))
    )
)


(exec (0 5)
    (, (IS-VAR $id $ph $fh 0))
    (O
        (- (IS-VAR $id $ph $fh 0))
    )
)

; clear def after finished executing
;
; (exec 1
;     (, (DEF take-first $tf-p $tf-t)
;         (DEF check-head $ch-p $ch-t)
;         (DEF nested-ptrn $np-p $np-t)
;         (DEF create-walk $cw-p $cw-t)
;     )
;     (O
;         (- (DEF take-first $tf-p $tf-t))
;         (- (DEF check-head $ch-p $ch-t))
;         (- (DEF nested-ptrn $np-p $np-t))
;         (- (DEF create-walk $cw-p $cw-t))
;     )
; )


(exec (0 0)
    (, (DEF run-valuation $rv-p $rv-t))
    (O
        (+ (exec (0 0) $rv-p $rv-t))
    )
)
