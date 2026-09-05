# MM2 Shallow Abstraction Pipeline

## How It Works (6-Step Chain)

**Step 1 — Launch**

The launcher `exec (0 0)` retrieves the code for `run-shallow-abs` from
`DEF` and registers it as an active `exec`.

**Step 2 — Index the Pattern**

`run-shallow-abs` converts the pattern's variables (`$a`, `$b`, ...) into
indexed tags — `(var 0)`, `(var 1)`, and so on — using `vars_to_indices`,
run once per pattern. It then calls `start-shallow-abstraction` at
priority `(0 1)`.

**Step 3 — Match Valuations and Start the Walk**

`start-shallow-abstraction` matches the indexed pattern against the
available valuations, `(valuation $id $var $val)`. It initializes the
walk state, `(walk $id $var $val $idx-ptrn ())`, and calls `take-first`
at priority `(0 1)`.

**Step 4 — The Specialization Loop**

`take-first` (0 1), `step-2` (0 3), and `step-3` (0 4) form a recursive
loop:

- `take-first` splits off the first item of the pattern and the
  remaining tail, using `car-atom` and `cdr-atom`.
- `step-2` (**Target Match**): if the item just peeled off matches
  `$var`, the new value `$val` is prepended to the accumulator with
  `cons`.
- `step-3` (**Fallback Match**): if the item is any other variable or
  symbol, the original node is prepended to the accumulator instead.

Either branch then triggers `final-out` (0 3) to check whether the
pattern has been fully consumed, or loops back to `take-first` (0 4) to
process the next item.

**Step 5 — Emit the Specialization**

Once the remaining list is empty (`()`), `final-out` reverses the
accumulator — which was built in reverse order — using `reverse`, and
writes out the completed candidate as `(specialization $id
$new-pattern)`.

**Step 6 — Test Verdict**

A symmetric-difference test harness, spanning `(0 5)` through `(0 8)`,
compares the generated specializations against the expected values,
`(expected-val ...)`, and reports either `(TEST-PASSED)` or
`(TEST-FAILED $error)`.

---

## How the Test Works (3 Phases)

**Phase 1 — Union (0 5)**

All actual specializations and all expected specializations are added
into a shared set, `MISTAKE`.

**Phase 2 — Cancel (0 6)**

Any candidate pattern present in both the actual and expected sets is
removed from `MISTAKE`.

**Phase 3 — Verdict (0 7) and (0 8)**

- If `MISTAKE` is empty, the harness outputs `(TEST-PASSED)`.
- If anything remains in `MISTAKE`, it outputs `(TEST-FAILED $error)`,
  identifying the mismatch.

---

## What It Can Handle

This pipeline specializes **any pattern**, regardless of size, arity, or
which slot is being targeted.

**Any tuple size:**

```clojure
(Inheritance $a)                       ; 1 variable
(Inheritance $a $b)                    ; 2 variables
(Inheritance $a $b $c)                 ; 3 variables
(Inheritance $a $b $c $d)              ; 4 variables
(Inheritance $a ... $z)               ; 10+ variables
```

**Any target variable slot:**

- Specializes `(var 0)` while leaving `(var 1)` untouched
- Specializes `(var 1)` while leaving `(var 0)` untouched
- Specializes `(var 9)` in a 10-variable record

**Example output:**

```
pattern:    (PATTERN p1 (Inheritance $a $b $c))
valuations: (valuation p1 (var 0) mieraf)
            (valuation p1 (var 1) dave)
            (valuation p1 (var 2) nati)

specializations:
  (specialization p1 (Inheritance mieraf (var 1) (var 2)))
  (specialization p1 (Inheritance (var 0) dave (var 2)))
  (specialization p1 (Inheritance (var 0) (var 1) nati))
```

---

## How to Run

**1. Build MORK:**

```bash
cd MORK/kernel
RUSTFLAGS="-C target-cpu=native" cargo build --release
```

**2. Run the program:**

```bash
../target/release/mork run path/to/shallow_abstraction.mm2
```

---

## How to run

```clojure
(exec (0 0)
    (, (DEF run-shallow-abs $rsa-p $rsa-t))
    (O
        (+ (exec (0 0) $rsa-p $rsa-t))
    )
)
```

This performs three actions:

match run-shallow-abs from the fact then add to an active exec.

---

## Requirements

- Rust (nightly)
- MORK, built from source
- mm2-stdlib installed and registered (`car-atom`, `cdr-atom`, `cons`,
  `reverse`)
- MM2 Helper Extension (`vars_to_indices`)