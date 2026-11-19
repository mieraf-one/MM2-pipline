; Basic Patterns
(SUBSTITUTE p1 (Inheritance $a $b) (nati bob))
(SUBSTITUTE p2 (Inheritance $a (Inheritance $b $c)) (ela man jo))
(SUBSTITUTE p3 (Inheritance (Inheritance $a $b) (Inheritance (Inheritance $c $d) $e)) (1 2 3 4 5))

; Single & Multi-Branch Nesting
(SUBSTITUTE p4 (Inheritance $x $y) (Human Mortal))
(SUBSTITUTE p5 (Inheritance (Inheritance (Inheritance $x $y) $z) $w) (socrates human mammal animal))
(SUBSTITUTE p6 (Inheritance (Inheritance $l1 $l2) (Inheritance $r1 $r2)) (dog mammal cat mammal))

; Constants & Boundary Edge Cases
(SUBSTITUTE p7 (Inheritance Socrates Mortal) (Ignored1 Ignored2))
(SUBSTITUTE p8 () (Inheritance ela human))
(SUBSTITUTE p9 () ())
(SUBSTITUTE p10 (Inheritance $a $b) ())
(SUBSTITUTE p11 (Inheritance $a (Inheritance $b $c)) ())
(SUBSTITUTE p12 (Inheritance (Inheritance $a $b) (Inheritance $c $d)) (nati))
(SUBSTITUTE p13 (Inheritance $first $second) (ela human extra1 extra2 extra3))

; Marker Variables & Mixed Forms
(SUBSTITUTE p14 (Inheritance (var x) (Inheritance (var y) (var z))) (robin bird animal))
(SUBSTITUTE p15 (Inheritance (Inheritance $a (var b)) (Inheritance $c (var d))) (p1 p2 p3 p4))

; Complex & Deep Tree Structures
(SUBSTITUTE p16 ((Inheritance $a) (Inheritance $b)) (val1 val2))
(SUBSTITUTE p17 (Inheritance (Inheritance (Inheritance (Inheritance $a $b) $c) $d) $e) (v1 v2 v3 v4 v5))
(SUBSTITUTE p18 (Inheritance $top (Inheritance (Inheritance $leaf1 $leaf2) (Inheritance $mid (Inheritance $deep1 $deep2)))) (t l1 l2 m d1 d2))
