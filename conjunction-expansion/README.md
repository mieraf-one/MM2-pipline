# MM2 Conjunction Expansion & 2-Clause Pattern Mining Pipeline

A pattern mining conjunction expansion and multi-clause rule generation engine. combines frequent 1-clause patterns into 2-clause conjunctive rules, supports both **shared (connected)** and **distinct (disjoint)** variable semantics, calculates joint support across knowledge base facts, and filters surviving multi-clause rules with minimum support thresholding (`min-support`).

How it work
---

### Step 1 — Launch (`0 0`)
The launcher `exec (0 0)` retrieves the rule definition for `run-conj-exp` from `DEF` and registers it as an active execution step `(exec (0 0) $p $t)`.

### Step 2 — 1-Clause Variable Extraction (`run-conj-exp`)
`run-conj-exp` matches candidate pairs `(candidate-pattern $id1 $spec1)` and `(candidate-pattern $id2 $spec2)` that satisfy `(valid-pair $id1 $id2)`. Using `indices_to_vars`, it converts individual 1-clause indexed templates into live matchers `(ptrn $id1 $spec1 $ptrn1)` and `(ptrn $id2 $spec2 $ptrn2)` with independent variable scopes. It then activates Stage `(0 1)`.

### Step 3 — Shared Variable Conjunction Construction (`0 1`)
Stage `(0 1)` takes the paired indexed specifications `($spec1 $spec2)` and passes the entire tuple into `(indices_to_vars (' ($spec1 $spec2)))` in a **single evaluation**. Because `indices_to_vars` traverses the whole tuple at once, occurrences of `(var 0)` across both clauses map to the **same shared variable `$a`** $\implies$ `(conj-shared ($id1 $id2) ($spec1 $spec2) $live-conj)`.

### Step 4 — Distinct Variable Conjunction Construction (`0 2`)
Stage `(0 2)` pairs the independently converted live matchers `($ptrn1 $ptrn2)` (which hold `$a` in clause 1 and `$b` in clause 2) and runs `(vars_to_indices (' ($ptrn1 $ptrn2)))` to produce the indexed template with distinct variables `(var 0)` and `(var 1)` $\implies$ `(conj-distinct ($id1 $id2) $distinct-spec ($ptrn1 $ptrn2))`.

### Step 5 — Joint Support Counting (`0 3` & `0 4`)
* **Stage `(0 3)` (Shared Support)**: Unifies `conj-shared` against the knowledge base: `(FACT $ptrn1) (FACT $ptrn2)`. Using `(count (conj-shared $ids support $idx-vars $count) $count ($ptrn1 $ptrn2))`, it groups by `$idx-vars` and counts distinct joint ground solutions where the **same entity** satisfies both clauses.
* **Stage `(0 4)` (Distinct Support)**: Unifies `conj-distinct` against the knowledge base: `(FACT $ptrn1) (FACT $ptrn2)`. It counts distinct joint ground fact pairs across independent entities.

### Step 6 — Minimum Support Evaluation (`0 5` & `0 6`)
Stages `(0 5)` and `(0 6)` evaluate candidate support against `(min-support $min-sup)` in pure functional evaluation:
* Converts strings to 32-bit integers with `i32_from_string`.
* Evaluates `(ge_i32 (i32_from_string $support) (i32_from_string $min-sup))`.
* Outputs `(conj-shared is-valid-support ... true/false)` and `(conj-distinct is-valid-support ... true/false)`.

### Step 7 — Emit Surviving Frequent Conjunctions (`0 7` & `0 8`)
* **Stage `(0 7)`**: Asserts only frequent connected rules: `(frequent-shared-pattern $ids $idx-vars)`.
* **Stage `(0 8)`**: Asserts only frequent disconnected rules: `(frequent-distinct-pattern $ids $idx-vars)`.

---

## Shared vs. Distinct Variables: Core Concepts

| Mode | Variable Mapping | Semantic Meaning | Real-World Example |
|---|---|---|---|
| **Shared (`$a = $a`)** | `(var 0)` in both clauses | **Same Entity** (Connected Association) | *"A person who is a developer AND works at iCog"* |
| **Distinct (`$a \neq $b`)** | `(var 0)` & `(var 1)` | **Independent Entities** (Cartesian Product) | *"Some developer $x$ exists AND some coffee drinker $y$ exists"* |


## What It Can Handle

* **Arbitrary Predicates**: Works dynamically with ANY relations (`Inheritance`, `Likes`, `WorksAt`, `Parent`, etc.) without hardcoded relation names.
* **Symmetry Breaking**: Uses `(valid-pair p1 p2)` to eliminate mirror duplicates ($P_1 \wedge P_2 \equiv P_2 \wedge P_1$).
* **Collision-Free Variable Scoping**: Properly isolates live metavariables and abstract templates using `DEF` hygiene.
* **Accurate Aggregation**: Counts compound fact tuples `($ptrn1 $ptrn2)` to prevent undercounting.
* **Autonomous Testing**: Built-in 3-phase symmetric difference test harness.

---

## Entry point

```clojure

; ENTRY POINT
; ----------------------------------
(exec (0 0)
    (, (DEF run-conj-exp $rce-p $rce-t))
    (O
        (+ (exec (0 0) $rce-p $rce-t))
    )
)
```

Expected Output
```clojure

(frequent-shared-pattern (p1 p3) ((Inheritance (var 0) developer) (WorksAt (var 0) icog)))
(frequent-distinct-pattern (p1 p2) ((Inheritance (var 0) developer) (Likes (var 1) coffee)))
(frequent-distinct-pattern (p1 p3) ((Inheritance (var 0) developer) (WorksAt (var 1) icog)))
(frequent-distinct-pattern (p2 p3) ((Likes (var 0) coffee) (WorksAt (var 1) icog)))