; 1. Facts & Patterns Under Test
; ------------------------------------------------------------------------------

; p1 (Unary)
(FACT (IsHuman Elyas))
(PATTERN p1 (IsHuman $x))

; p2 (Binary)
(FACT (Inheritance Mieraf Tadesse))
(PATTERN p2 (Inheritance $a $b))

; p3 (5-ary)
(FACT (Flight NYC London BritishAirways Boeing777 600))
(PATTERN p3 (Flight $from $to $airline $plane $price))

; p4 (6-ary)
(FACT (Transaction Alice Bob 500 USD Ethereum 2026))
(PATTERN p4 (Transaction $sender $receiver $amount $currency $chain $year))

; p5 (Nested Middle)
(FACT (Transfer (Account Alice Checking) Bob 250 USD))
(PATTERN p5 (Transfer (Account $owner $type) $to $amount $currency))

; p6 (Deep 3-Level Nesting)
(FACT (Record Alice (Contact (Email user microsoft) (Phone 12345)) Active))
(PATTERN p6 (Record $name (Contact (Email $user $domain) (Phone $num)) $status))

; p7 (Sibling Nested)
(FACT (Trade (Buyer Alice USA) (Seller Bob UK) (Item Gold 100)))
(PATTERN p7 (Trade (Buyer $b_name $b_country) (Seller $s_name $s_country) (Item $asset $qty)))

; p8 (Mixed Constants/Vars)
(FACT (Affiliation (University Oxford Physics) (Researcher Alan Professor) 2026))
(PATTERN p8 (Affiliation (University Oxford $dept) (Researcher $who Professor) $year))


; ------------------------------------------------------------------------------
; 2. EXPECTED OUTPUT
; ------------------------------------------------------------------------------
; p1 (Unary)
(EXPECTED (valuation p1 (var 0) Elyas))

; p2 (Binary)
(EXPECTED (valuation p2 (var 0) Mieraf))
(EXPECTED (valuation p2 (var 1) Tadesse))

; p3 (5-ary)
(EXPECTED (valuation p3 (var 0) NYC))
(EXPECTED (valuation p3 (var 1) London))
(EXPECTED (valuation p3 (var 2) BritishAirways))
(EXPECTED (valuation p3 (var 3) Boeing777))
(EXPECTED (valuation p3 (var 4) 600))

; p4 (6-ary)
(EXPECTED (valuation p4 (var 0) Alice))
(EXPECTED (valuation p4 (var 1) Bob))
(EXPECTED (valuation p4 (var 2) 500))
(EXPECTED (valuation p4 (var 3) USD))
(EXPECTED (valuation p4 (var 4) Ethereum))
(EXPECTED (valuation p4 (var 5) 2026))

; p5 (Nested Middle)
(EXPECTED (valuation p5 (var 0) Alice))
(EXPECTED (valuation p5 (var 1) Checking))
(EXPECTED (valuation p5 (var 2) Bob))
(EXPECTED (valuation p5 (var 3) 250))
(EXPECTED (valuation p5 (var 4) USD))

; p6 (Deep 3-Level Nesting)
(EXPECTED (valuation p6 (var 0) Alice))
(EXPECTED (valuation p6 (var 1) user))
(EXPECTED (valuation p6 (var 2) microsoft))
(EXPECTED (valuation p6 (var 3) 12345))
(EXPECTED (valuation p6 (var 4) Active))

; p7 (Sibling Nested)
(EXPECTED (valuation p7 (var 0) Alice))
(EXPECTED (valuation p7 (var 1) USA))
(EXPECTED (valuation p7 (var 2) Bob))
(EXPECTED (valuation p7 (var 3) UK))
(EXPECTED (valuation p7 (var 4) Gold))
(EXPECTED (valuation p7 (var 5) 100))

; p8 (Mixed Constants/Vars)
(EXPECTED (valuation p8 (var 0) Physics))
(EXPECTED (valuation p8 (var 1) Alan))
(EXPECTED (valuation p8 (var 2) 2026))


; ---------------------------------------------------
;                   TESTING
; ---------------------------------------------------

; Match actual valuations against EXPECTED -> return TEST-PASSED
(exec (0 7)
    (, (EXPECTED (valuation $id $var $val))
        (valuation $id $var $val))
    (O
        (+ (TEST-PASSED (valuation $id $var $val)))
        (- (EXPECTED (valuation $id $var $val)))
    )
)

; Any remaining EXPECTED atoms missing a valuation -> return TEST-FAILED
(exec (0 8)
    (, (EXPECTED (valuation $id $var $val)))
    (O
        (+ (TEST-FAILED-MISSING (valuation $id $var $val)))
        (- (EXPECTED (valuation $id $var $val)))
    )
)
