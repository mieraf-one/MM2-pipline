# MM2 Valuation Pipeline

A pattern mining valuation extractor built in MM2 — extracts variable bindings from patterns matched against a knowledge base.

---

## How It Works (6-Step Chain)

Here is the exact chain of what happens from start to finish:

**Step 1 — Launch**

The launcher `exec (0 0)` fetches the code for `run-valuation` from `DEF` and adds it as an active `exec`.

**Step 2 — Index and Call Step 2**

`run-valuation` converts variables (`$x`, `$y`) into indexed tags `(var 0)`, `(var 1)` using `vars_to_indices`, then calls `take-first` at priority `(0 1)`.

**Step 3 — Match and Call Take-First**

`call-take-first` matches the pattern against real database facts `(FACT ...)`, creates the `check-var` task, and calls `take-first` at priority `(0 2)`.

**Step 4 — The Loop**

`take-first` (0 2) and `check-var` (0 3) ping-pong in a loop:

- `take-first` peels the head and tail using `car-atom` and `cdr-atom`
- `check-var` checks if the head is a variable using `is_var`, emits the result, and loops back to `take-first` for the next item until the list is empty `()`

**Step 5 — Emit Valuation**

Stage `(0 4)` sees `is-var ... 1` and writes `(valuation $id (var $n) $value)`.

**Step 6 — Test Verdict**

The test harness `(0 8)` to `(1 1)` compares the valuations against `(expected-val ...)` and prints `(TEST-PASSED)` or `(TEST-FAILED)`.

---

## How the Test Works (3 Phases)

**Phase 1 — Union (0 8)**

Adds ALL actual valuations AND expected valuations into `MISTAKE`.

**Phase 2 — Cancel (0 9)**

If a fact exists in both actual and expected → it is deleted from `MISTAKE`.

**Phase 3 — Verdict (1 0) and (1 1)**

- If 0 mistakes remain → outputs `(TEST-PASSED)` ✅
- If any mistake remains → outputs `(TEST-FAILED $error)` ❌

---

## What It Can Handle

This pipeline extracts valuations from **any pattern** — regardless of size or structure.

**Any tuple size:**
```clojure
(Inheritance $x)                       ; 1 variable
(Inheritance $x $y)                    ; 2 variables
(Inheritance $x $y $z)                 ; 3 variables
```

**Mixed static and variable elements:**
```clojure
(Inheritance human $x)   ; "human" is static, $x is variable
```

Only `$x` gets extracted — static symbols like `human` are skipped automatically.

**Example output:**
```
pattern: (PATTERN p1 (Inheritance human $x))
facts:   (FACT (Inheritance human Allen))
         (FACT (Inheritance human Lily))

valuation:
  (valuation p1 (var 0) Allen)
  (valuation p1 (var 0) Lily)
```


## How to Run

**1. Build MORK:**

```bash
cd MORK/kernel
RUSTFLAGS="-C target-cpu=native" cargo build --release
```

**2. Run the program:**

```bash
../target/release/mork run path/to/valuation.mm2
```

---

## Entry Point


```clojure
(exec (0 0)
    (, (DEF run-valuation $p $t))
    (O
        (+ (exec (0 0) $p $t))
    )
)
```

It does three things:

1. Finds the `run-valuation` function definition stored in the Space
2. Captures its pattern `$p` and template `$t`
3. Spawns it as an active rule that starts executing


---

## Requirements

- Rust (nightly)
- MORK built from source
- mm2-stdlib installed and registered
- MM2 Helper Extension (`vars_to_indices`, `is_var`)