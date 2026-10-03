# MM2 Valuation

A universal pattern mining valuation extractor built in MM2 — extracts variable bindings from flat, $N$-ary, and deeply nested patterns matched against a knowledge base.

---

## What It Can Handle

This pipeline extracts valuations from **any pattern structure** — regardless of tuple size, mixed constants, or nesting depth.

### Flat, Nested & $N$-ary Patterns
```clojure
(IsHuman $x)                           ; Unary (1 variable)
(Inheritance $x $y)                    ; Binary (2 variables)
(Flight $from $to $airline $plane)     ; 4 variables
(Transaction $a $b $c $d $e $f)        ; 6 variables

; Single nested expression at the tail:
(knows $a (Inheritance $b $c))

; Nested expression in the middle:
(Transfer (Account $owner $type) $to $amount $currency)

; Multi-level deep nesting:
(Record $name (Contact (Email $user $domain) (Phone $num)) $status)

; Multiple sibling nested expressions:
(Trade (Buyer $b_name $b_country) (Seller $s_name $s_country) (Item $asset $qty))
```

### Entry Point
```
(exec (0 0)
    (, (DEF run-valuation $p $t))
    (O
        (+ (exec (0 0) $p $t))
    )
)
```
### Input format
```clojure
(FACT (Inheritance Mieraf Tadesse))
(PATTERN p1 (Inheritance $child $father))  ; p1 represents an ID

; Expected output
(valuation p1 (var 0) Mieraf)
(valuation p1 (var 1) Tadesse)
```
### How to run
```
../target/release/mork run test-valuation.metta --aux-path valution.metta
```