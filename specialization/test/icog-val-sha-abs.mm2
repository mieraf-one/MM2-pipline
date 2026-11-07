;; One-generation frequent candidate miner.
;;
;; Inputs:
;;   (INPUT MIN-SUPPORT n)
;;   (FACT $database-expression)
;;
;; Public request:
;;   (run-frequent-miner $generation-id $pattern)
;;
;; Public result:
;;   (candidate-pattern $generation-id $indexed-pattern $support)
;;
;; `iterative-miner.metta` supplies generation scoping and recursive depth.

(DEF gv-expand
  (, (gv-visit $id $path $node))
  (O
    (- (gv-visit $id $path $node))
    (pure (gv-var-check $id $path $node $is-var) $is-var
      (i8_to_string (is_var (' $node))))

    (+ (exec (freq f030 gv-record)
         (, (gv-var-check $record-id $record-path $var-node 1))
         (O
           (- (gv-var-check $record-id $record-path $var-node 1))
           (+ (get-vars-for-tree-result $record-id $record-path $var-node)))))

    (+ (exec (freq f031 gv-split-pair)
         (, (gv-var-check $split-id $split-path ($a $b) 0)
            (DEF gv-expand $expand-p $expand-t))
         (O
           (- (gv-var-check $split-id $split-path ($a $b) 0))
           (+ (gv-visit $split-id ($split-path arg/0) $a))
           (+ (gv-visit $split-id ($split-path arg/1) $b))
           (+ (exec (freq f020 gv-expand) $expand-p $expand-t)))))

    (+ (exec (freq f032 gv-split-triplet)
         (, (gv-var-check $split-id $split-path ($a $b $c) 0)
            (DEF gv-expand $expand-p $expand-t))
         (O
           (- (gv-var-check $split-id $split-path ($a $b $c) 0))
           (+ (gv-visit $split-id ($split-path arg/0) $a))
           (+ (gv-visit $split-id ($split-path arg/1) $b))
           (+ (gv-visit $split-id ($split-path arg/2) $c))
           (+ (exec (freq f020 gv-expand) $expand-p $expand-t)))))

    (+ (exec (freq f039 gv-discard-non-var)
         (, (gv-var-check $discard-id $discard-path $node 0))
         (O
           (- (gv-var-check $discard-id $discard-path $node 0)))))
  )
)

; Reusable variable-extraction function.
;
; To call it from another miner stage, match/create:
;   (get-vars-for-tree $id $tree)
;   (DEF get-vars-for-tree-fn $gv-p $gv-t)
; then emit:
;   (+ (exec (freq f010 run-get-vars) $gv-p $gv-t))
(DEF get-vars-for-tree-fn
  (, (get-vars-for-tree $id $tree)
     (DEF gv-expand $expand-p $expand-t))
  (O
    (- (get-vars-for-tree $id $tree))
    (pure (gv-visit $id root $indexed-tree) $indexed-tree
      (vars_to_indices (' $tree)))
    (+ (exec (freq f020 gv-expand) $expand-p $expand-t)))
)

; Example call, kept inactive so this file can be loaded as a library:
; (get-vars-for-tree sample (Inheritance $x (Evaluation $x $y)))
; (exec (freq f000 call-get-vars-example)
;   (, (get-vars-for-tree sample (Inheritance $x (Evaluation $x $y)))
;      (DEF get-vars-for-tree-fn $gv-p $gv-t))
;   (O (+ (exec (freq f010 run-get-vars) $gv-p $gv-t))))

; get-value-at-position
;
; Recursive positional lookup. It walks only the requested path:
;   root                      -> the whole expression
;   ($parent arg/0)           -> first child of value at $parent
;   ($parent arg/1)           -> second child of value at $parent
;   ($parent arg/2)           -> third child of value at $parent
;
; Request:
;   (get-value-at-position $id $expr $path)
;
; Result:
;   (get-value-at-position-result $id $path $value)
;
; Internal:
;   (gap-task $id $expr $path)
;   (gap-wait $id $path $parent $arg)
;   (gap-value $id $path $value)

(gap-arg-index arg/0 0)
(gap-arg-index arg/1 1)
(gap-arg-index arg/2 2)
; Accept the short-lived optimized encoding too, so external callers can
; migrate independently while the miner continues to publish its legacy paths.
(gap-arg-index (arg 0) 0)
(gap-arg-index (arg 1) 1)
(gap-arg-index (arg 2) 2)

(DEF get-value-at-position-select
  (, (gap-value $id $parent $parent-value))
  (O
    ; Keep variables in generated nested rules distinct from the outer rule.
    ; Otherwise substitution can capture them and multiply the join work.
    (+ (exec (freq f130 gap-select-by-index)
         (, (gap-wait $sel-id $path $sel-parent $arg)
            (gap-value $sel-id $sel-parent $sel-parent-value)
            (gap-arg-index $arg $index)
            (DEF get-value-at-position-select $select-p $select-t))
         (O
           (- (gap-wait $sel-id $path $sel-parent $arg))
           (- (gap-value $sel-id $sel-parent $sel-parent-value))
           (pure (gap-value $sel-id $path $value) $value
             (index-atom $index (' $sel-parent-value)))
           (+ (exec (freq f120 gap-select) $select-p $select-t)))))

    (+ (exec (freq f190 gap-result)
         (, (gap-value $result-id $result-path $result-value)
            (gap-target $result-id $result-path))
         (O
           (- (gap-target $result-id $result-path))
           (- (gap-value $result-id $result-path $result-value))
           (+ (get-value-at-position-result $result-id $result-path $result-value)))))
  )
)

(DEF get-value-at-position-step
  (, (gap-task $id $expr $path))
  (O
    (+ (exec (freq f110 gap-root)
         (, (gap-task $root-id $root-expr root)
            (DEF get-value-at-position-select $select-p $select-t))
         (O
           (- (gap-task $root-id $root-expr root))
           (+ (gap-value $root-id root $root-expr))
           (+ (exec (freq f120 gap-select) $select-p $select-t)))))

    (+ (exec (freq f111 gap-descend)
         (, (gap-task $desc-id $desc-expr ($parent $arg))
            (DEF get-value-at-position-step $step-p $step-t))
         (O
           (- (gap-task $desc-id $desc-expr ($parent $arg)))
           (+ (gap-wait $desc-id ($parent $arg) $parent $arg))
           (+ (gap-task $desc-id $desc-expr $parent))
           (+ (exec (freq f100 gap-step) $step-p $step-t)))))
  )
)

; Reusable get-value-at-position function.
;
; To call it from another miner stage, match/create:
;   (get-value-at-position $id $expr $path)
;   (DEF get-value-at-position-fn $gap-p $gap-t)
; then emit:
;   (+ (exec (freq f101 run-get-value-at-position) $gap-p $gap-t))
(DEF get-value-at-position-fn
  (, (get-value-at-position $id $expr $path)
     (DEF get-value-at-position-step $step-p $step-t))
  (O
    (- (get-value-at-position $id $expr $path))
    (+ (gap-target $id $path))
    (+ (gap-task $id $expr $path))
    (+ (exec (freq f100 gap-step) $step-p $step-t)))
)
; Example call, kept inactive:
; (get-value-at-position gap-example
;   (Inheritance Allen (Evaluation (Var 1) (like (we sodaDrinker) dean)))
;   (((root (arg 2)) (arg 1)) (arg 0)))
; (exec (freq f000 call-gap-example)
;   (, (get-value-at-position gap-example
;        (Inheritance Allen (Evaluation (Var 1) (like (we sodaDrinker) dean)))
;        (((root (arg 2)) (arg 1)) (arg 0)))
;      (DEF get-value-at-position-fn $gap-p $gap-t))
;   (O (+ (exec (freq f101 run-get-value-at-position) $gap-p $gap-t))))

; valuation
;
; Valuation pipeline:
;   1. Extract variables and their paths from the pattern.
;   2. Match the raw pattern against loaded FACT rows.
;   3. For each satisfying expression and each variable path, get the value at
;      that path.
;   4. Emit variable bindings for the valuation request.
;
; Request:
;   (valuation $id $pattern)
;
; Knowledge base facts:
;   (FACT $expr)
;
; Results:
;   (valuation-satisfying-set $id $candidate-expr)
;   (valuation-binding $id $path $var $value)
;
; Candidate ids are intentionally not part of the valuation result model.

(DEF valuation-start
  (, (valuation $id $pattern))
  (O
    (- (valuation $id $pattern))
    (+ (get-vars-for-tree (VAL-VARS $id) $pattern))
    (+ (valuation-pattern $id $pattern)))
)

(DEF valuation-match
  (, (valuation-pattern $id $pattern)
     (FACT $pattern))
  (O
    (+ (valuation-satisfying-set $id $pattern)))
)

(DEF valuation-bind
  (, (valuation-satisfying-set $id $candidate-expr)
     (get-vars-for-tree-result (VAL-VARS $id) $path $var)
     (DEF get-value-at-position-fn $gap-p $gap-t))
  (O
    (- (get-vars-for-tree-result (VAL-VARS $id) $path $var))
    (- (valuation-satisfying-set $id $candidate-expr))
    (+ (valuation-position-wait $id $candidate-expr $path $var))
    (+ (get-value-at-position ($id $candidate-expr $path) $candidate-expr $path))
    (+ (exec (freq f230 valuation-get-value) $gap-p $gap-t))))

(DEF valuation-position-finish
  (, (valuation-position-wait $id $candidate-expr $path $var)
     (get-value-at-position-result ($id $candidate-expr $path) $path $value))
  (O
    (- (valuation-position-wait $id $candidate-expr $path $var))
    (- (get-value-at-position-result ($id $candidate-expr $path) $path $value))
    (+ (valuation-position-value $id $candidate-expr $path $var $value))))

(DEF valuation-binding-finish
  (, (valuation-position-value $id $candidate-expr $path $var $value))
  (O
    (- (valuation-position-value $id $candidate-expr $path $var $value))
    (+ (valuation-binding $id $path $var $value))
    (+ (valuation-binding $id $path $var $var))))

; Reusable valuation function.
;
; To call it from another miner stage, match/create:
;   (valuation $id $pattern)
;   (FACT $candidate-expr)
;   (DEF valuation-fn $val-p $val-t)
; then emit:
;   (+ (exec (freq f200 run-valuation) $val-p $val-t))
(DEF valuation-fn
  (, (valuation $id $pattern)
     (DEF valuation-start $start-p $start-t)
     (DEF valuation-match $match-p $match-t)
     (DEF valuation-bind $bind-p $bind-t)
     (DEF valuation-position-finish $position-p $position-t)
     (DEF valuation-binding-finish $finish-p $finish-t)
     (DEF get-vars-for-tree-fn $gv-p $gv-t)
     (DEF get-value-at-position-fn $gap-p $gap-t))
  (O
    (+ (exec (freq f200 valuation-start) $start-p $start-t))
    (+ (exec (freq f210 valuation-get-vars) $gv-p $gv-t))
    (+ (exec (freq f220 valuation-match) $match-p $match-t))
    (+ (exec (freq f230 valuation-bind) $bind-p $bind-t))
    (+ (exec (freq f235 valuation-position-finish) $position-p $position-t))
    (+ (exec (freq f240 valuation-finish) $finish-p $finish-t)))
)

; Example call, kept inactive:
; (valuation val-example (Inheritance $x $y))
; (FACT (Inheritance Allen human))
; (FACT (Inheritance Lily human))
; (FACT (Inheritance Allen sodaDrinker))
; (exec (freq f000 call-example)
;   (, (valuation val-example (Inheritance $x human))
;      (DEF valuation-fn $val-p $val-t))
;   (O (+ (exec (freq f001 run-valuation) $val-p $val-t))))


; shallow abstraction for valuation bindings
;
; This is intentionally shallow:
;   - symbols/atoms stay unchanged
;   - variables stay unchanged
;   - pair/triplet expressions keep their link unchanged
;   - only direct arguments are replaced by split variables
;
; Example:
;   (valuation-binding $id $path (var 0) (Eval Allen soda))
; becomes:
;   (shallow-abstraction-binding $id $path (var 0)
;      (Eval (var (0 1)) (var (0 2))))
;
; Nested expression arguments are treated as one shallow child for now.
(sae-index-next 0 1)
(sae-index-next 1 2)
(sae-index-next 2 3)
(sae-index-next 3 4)
(sae-index-next 4 5)
(sae-index-next 5 6)
(sae-index-next 6 7)
(sae-index-next 7 8)
(sae-index-next 8 9)

(DEF sae-start
  (, (shallow-abstract-expression (SAE $parent-id $path $expr) $path (var $source-index) $expr)
     (DEF sae-start-shape $shape-p $shape-t))
  (O
    (- (shallow-abstract-expression (SAE $parent-id $path $expr) $path (var $source-index) $expr))
    (pure (sae-shape-link $parent-id $path (var $source-index) $expr $link) $link (car-atom (' $expr)))
    (pure (sae-shape-arity $parent-id $path (var $source-index) $expr $arity) $arity
      (size-atom (cdr-atom (' $expr))))
    (+ (exec (freq f301 sae-start-shape) $shape-p $shape-t))))

(DEF sae-start-shape
  (, (sae-shape-link $parent-id $path (var $source-index) $expr $link)
     (sae-shape-arity $parent-id $path (var $source-index) $expr $arity))
  (O
    (- (sae-shape-link $parent-id $path (var $source-index) $expr $link))
    (- (sae-shape-arity $parent-id $path (var $source-index) $expr $arity))
    (+ (sae-link (SAE $parent-id $path (var $source-index) $link $arity) $link))
    (+ (sae-args-arity (SAE $parent-id $path (var $source-index) $link $arity) $parent-id (var $source-index) $arity))
    (+ (shallow-abstraction-wait $parent-id $path (var $source-index) (SAE $parent-id $path (var $source-index) $link $arity)))))

(DEF sae-start-walk
  (, (sae-args-arity $id $parent-id (var $source-index) $arity))
  (O
    (- (sae-args-arity $id $parent-id (var $source-index) $arity))
    (+ (sae-slot-value $id (var $source-index) 1 1))
    (+ (sae-walk $id (var $source-index) $arity 1 ()))))

(DEF sae-step
  (, (sae-walk $id (var $source-index) $remaining $pos $acc)
     (sae-index-next $next-remaining $remaining)
     (sae-index-next $pos $next-pos)
     (DEF sae-slot-append $append-p $append-t))
  (O
    (- (sae-walk $id (var $source-index) $remaining $pos $acc))
    (+ (sae-slot-pending $id (var $source-index) $pos $next-pos $next-remaining $acc))
    (+ (exec (freq f320 sae-slot-append) $append-p $append-t))))

(DEF sae-slot-append
  (, (sae-slot-pending $id (var $source-index) $pos $next-pos $next-remaining $acc)
     (sae-slot-value $id (var $source-index) $pos $slot)
     (DEF sae-continue $cont-p $cont-t))
  (O
    (- (sae-slot-pending $id (var $source-index) $pos $next-pos $next-remaining $acc))
    (pure (sae-step-acc $id (var $source-index) $pos $next-pos $next-remaining $next-acc) $next-acc
      (append (' ($acc ((var ($source-index $slot)))))))
    (+ (sae-slot-value $id (var $source-index) $next-pos $slot))
    (+ (sae-slot-value $id (var $source-index) $next-pos $next-pos))
    (+ (exec (freq f330 sae-continue) $cont-p $cont-t))))

(DEF sae-continue
  (, (sae-step-acc $id (var $source-index) $pos $next-pos $next-remaining $next-acc)
     (DEF sae-finish $finish-p $finish-t)
     (DEF sae-step $step-p $step-t))
  (O
    (- (sae-step-acc $id (var $source-index) $pos $next-pos $next-remaining $next-acc))
    (+ (sae-walk $id (var $source-index) $next-remaining $next-pos $next-acc))
    (+ (exec (freq f305 sae-finish) $finish-p $finish-t))
    (+ (exec (freq f310 sae-step) $step-p $step-t))))

(DEF sae-finish
  (, (sae-walk $id (var $source-index) 0 $pos $acc)
     (sae-link $id $link))
  (O
    (- (sae-walk $id (var $source-index) 0 $pos $acc))
    (pure (sae-step-result $id (var $source-index) $res) $res (append (' (($link) $acc))))))

(DEF shallow-abstract-expression-fn
  (, (shallow-abstract-expression $id $path (var $source-index) $expr)
     (DEF sae-start $start-p $start-t)
     (DEF sae-start-shape $shape-p $shape-t)
     (DEF sae-start-walk $walk-p $walk-t)
     (DEF sae-step $step-p $step-t))
  (O
    (+ (exec (freq f300 sae-start) $start-p $start-t))
    (+ (exec (freq f301 sae-start-shape) $shape-p $shape-t))
    (+ (exec (freq f303 sae-start-walk) $walk-p $walk-t))
    (+ (exec (freq f310 sae-step) $step-p $step-t))))



(DEF shallow-abstraction-start
  (, (run-shallow-abstraction $id) (valuation-binding $id $path (var $source-index) $value))
  (O (pure (shallow-abstraction-request-var $id $path (var $source-index) $value $is-var)
       $is-var (i8_to_string (is_var (' $value))))
     (pure (shallow-abstraction-request-expr $id $path (var $source-index) $value $is-exp)
       $is-exp (i8_to_string (is_exp (' $value))))))

(DEF shallow-abstraction-step
  (, (shallow-abstraction-request-var $id $path (var $source-index) $value $is-var)
     (shallow-abstraction-request-expr $id $path (var $source-index) $value $is-exp))
  (O
    (+ (exec (freq f351 shallow-keep-var)
         (, (shallow-abstraction-request-var $keep-id $keep-path (var $keep-source-index) $keep-value 1))
         (O (- (shallow-abstraction-request-var $keep-id $keep-path (var $keep-source-index) $keep-value 1))
            (+ (shallow-abstraction-binding $keep-id $keep-path (var $keep-source-index) $keep-value)))))
    (+ (exec (freq f352 shallow-abstract-expression)
         (, (shallow-abstraction-request-var $expr-id $expr-path (var $expr-source-index) $expr-value 0)
            (shallow-abstraction-request-expr $expr-id $expr-path (var $expr-source-index) $expr-value 1)
            (DEF shallow-abstract-expression-fn $sae-p $sae-t)
            (DEF shallow-abstraction-expression-finish $finish-p $finish-t))
         (O
            (- (shallow-abstraction-request-expr $expr-id $expr-path (var $expr-source-index) $expr-value 1))
            (+ (shallow-abstract-expression (SAE $expr-id $expr-path $expr-value) $expr-path (var $expr-source-index) $expr-value))
            (+ (exec (freq f353 shallow-run-sae) $sae-p $sae-t))
            (+ (exec (freq f390 shallow-finish-expression) $finish-p $finish-t)))))
    (+ (exec (freq f359 shallow-keep-atom)
         (, (shallow-abstraction-request-var $atom-id $atom-path (var $atom-source-index) $atom-value 0)
           (shallow-abstraction-request-expr $atom-id $atom-path (var $atom-source-index) $atom-value 0))
         (O (- (shallow-abstraction-request-expr $atom-id $atom-path (var $atom-source-index) $atom-value 0))
            (- (shallow-abstraction-request-var $atom-id $atom-path (var $atom-source-index) $atom-value 0))
            (+ (shallow-abstraction-binding $atom-id $atom-path (var $atom-source-index) $atom-value)))))))



(DEF shallow-abstraction-expression-finish
  (, (shallow-abstraction-wait $id $path (var $source-index) $sae-id)
     (sae-step-result $sae-id (var $source-index) $abstracted-value))
  (O
    (- (shallow-abstraction-wait $id $path (var $source-index) $sae-id))
    (- (sae-step-result $sae-id (var $source-index) $abstracted-value))
    (+ (shallow-abstraction-binding $id $path (var $source-index) $abstracted-value))))

(DEF shallow-abstraction-fn
  (, (run-shallow-abstraction $id)
     (DEF shallow-abstraction-start $start-p $start-t)
     (DEF shallow-abstraction-step $step-p $step-t))
  (O
    (+ (exec (freq f350 shallow-start) $start-p $start-t))
    (+ (exec (freq f360 shallow-step) $step-p $step-t))))

; ==============================================================================
; RUNNER: VALUATION -> SHALLOW ABSTRACTION
; ==============================================================================

(DEF val-sha-abs-fn
  (, (run-val-sha-abs $id $pattern)
     (DEF valuation-fn $valuation-p $valuation-t)
     (DEF shallow-abstraction-fn $shallow-p $shallow-t))
  (O
    (+ (valuation $id $pattern))
    (+ (run-shallow-abstraction $id))
    (+ (exec (freq f200 run-val) $valuation-p $valuation-t))
    (+ (exec (freq f350 run-sha) $shallow-p $shallow-t))))

(exec (freq f001 call-val-sha-abs)
  (, (run-val-sha-abs $id $pattern)
     (DEF val-sha-abs-fn $fn-p $fn-t))
  (O
    (+ (exec (freq f002 run-val-sha-abs) $fn-p $fn-t))))

; Also trigger directly if you write (valuation $id $pattern)
(DEF val-sha-abs-from-val-fn
  (, (valuation $id $pattern)
     (DEF valuation-fn $valuation-p $valuation-t)
     (DEF shallow-abstraction-fn $shallow-p $shallow-t))
  (O
    (+ (run-shallow-abstraction $id))
    (+ (exec (freq f200 run-val) $valuation-p $valuation-t))
    (+ (exec (freq f350 run-sha) $shallow-p $shallow-t))))

(exec (freq f001 call-val-from-valuation)
  (, (valuation $id $pattern)
     (DEF val-sha-abs-from-val-fn $fn-p $fn-t))
  (O
    (+ (exec (freq f002 run-val-from-val) $fn-p $fn-t))))