# MM2 Support Counting & Frequency Pruning Pipeline

## How It Works (6-Step Chain)

### Step 1 — Launch
The launcher `exec (0 0)` retrieves the code for `run-check-support` from `DEF` and registers it as an active `exec`.

### Step 2 — Generate Active Pattern Matchers
`run-check-support` matches each specialized candidate template `(specialization $id $spec)` and converts its index tags `(var 0)`, `(var 1)` back into live unification metavariables (`$a`, `$b`) using `indices_to_vars`. It creates `(spec $id $spec $ptrn)` — keeping the constant template `$spec` as the grouping key and `$ptrn` as the active matcher. It then calls Stage `(0 1)`.

### Step 3 — Count Support Grouped by Template Key
Stage `(0 1)` unifies `$ptrn` against the knowledge base facts `(FACT $id $ptrn)`. Using the aggregation primitive `(count (spec support $id $spec $count) $count $ptrn)`, it groups all matching ground facts by their template `$spec` key and outputs the aggregated support count:
`(spec support $id $spec $count)`.

### Step 4 — Threshold Evaluation
Stage `(0 3)` compares each candidate's support `$sup` against `(min-support $min-sup)` in pure functional evaluation:
- Converts `$sup` and `$min-sup` from strings into 32-bit integers using `i32_from_string`.
- Tests `(ge_i32 $sup $min-sup)` to determine if the candidate meets or exceeds the threshold.
- Outputs `(spec is-over $id $spec $sup $is-over)` with `$is-over` being `true` or `false`.

### Step 5 — Emit Frequent Candidates
Stage `(0 4)` matches only candidates where `$is-over` evaluated to `true`, asserting the surviving frequent patterns:
`(candidate-pattern $id $spec)`. Sub-threshold candidates (where `$is-over` is `false`) are pruned and discarded.

### Step 6 — Test Verdict
A symmetric-difference test harness, spanning `(0 5)` through `(1 0)`, compares the generated frequent candidates against the expected patterns, `(expected-val ...)`, and reports either `(TEST-PASSED)` or `(TEST-FAILED $error)`.

---

## How the Test Works (3 Phases)

### Phase 1 — Union (0 5 & 0 6)
All generated frequent candidates and all expected values are added into a shared set, `MISTAKE`.

### Phase 2 — Cancel (0 8)
Any candidate pattern present in both the actual set and the expected set is canceled and removed from `MISTAKE`.

### Phase 3 — Verdict (0 9 & 1 0)
- `(0 9)` defaults to outputting `(TEST-PASSED)`.
- If anything remains in `MISTAKE`, `(1 0)` retracts `(TEST-PASSED)` and asserts `(TEST-FAILED $error)`, identifying the exact mismatched pattern.

---

## What It Can Handle

- **Arbitrary Arity Patterns**: Handles 1, 2, 3, 4, or 10+ variable templates.
- **Accurate Grouping**: Prevents variable collisions by pairing the abstract template `$spec` with the active matcher `$ptrn`.
- **Threshold Pruning**: Discards low-frequency patterns (support < min-support) while preserving frequent ones.
- **Zero-Match Safety**: Patterns with 0 ground fact matches are cleanly ignored.

---

## Entry Point Launcher

```clojure
(exec (0 0)
    (, (DEF run-check-support $rcs-p $rcs-t))
    (O
        (+ (exec (0 0) $rcs-p $rcs-t))
    )
)
```


## How to Run

**1. Run with MORK:**

```bash
mork run path/to/support_counting.mm2
```

**2. Expected Terminal Output:**
```
(candidate-pattern p1 (Inheritance mieraf (var 1)))
(candidate-pattern p1 (Inheritance nati (var 1)))
(TEST-PASSED)
```

---

## Requirements

- **MORK**: Built from source with nightly Rust.
- **`mm2-stdlib`**: Registered primitives (`ge_i32`, `i32_from_string`, `indices_to_vars`).
- **`count`**: Built-in MORK output aggregation primitive.
