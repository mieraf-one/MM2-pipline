# Pattern Mining Algorithm — MeTTa to MM2 Port

This repo is implementing a pattern mining algorithm, ported from MeTTa to
MM2 (Minimal Meta 2).

---

## Pattern Mining Algorithm — All Pipeline Steps

### **Step 1: Pattern Indexing**
- Converts generic variables (`$a`, `$b`, `$from`) into standardized 0-based indexed tags `(var 0)`, `(var 1)` using `vars_to_indices`.

---

### **Step 2: Valuation Extraction**
- Matches indexed patterns against database facts `(FACT ...)` to extract all observed ground values into valuation bindings:
  $$(valuation\ \$id\ (var\ 0)\ mieraf)$$

---

### **Step 3: Shallow Abstraction (Constant Specialization)**
- Loops through the pattern using `car-atom`, `cdr-atom`, and `cons` accumulation.
- Replaces the target `(var n)` slot with its valuation value, then calls `reverse` to emit the specialized candidate:
  $$(specialization\ \$id\ (Inheritance\ mieraf\ (var\ 1)))$$

---

### **Step 4: Variable Equality Specialization ($X = Y$)**
- Discovers self-relations and internal loops by equating variable slots that share the same value within a fact:
  $$(specialization\ \$id\ (Inheritance\ (var\ 0)\ (var\ 0)))$$

---

### **Step 5: Support Counting & Apriori Pruning**
- Counts occurrences of each candidate across the database using `(count ...)`.
- Filters using `ge_i32` against `min_support` to keep frequent patterns and immediately prune weak ones:
  $$(FREQUENT-PATTERN\ \$id\ (slot\ (var\ 0)\ mieraf)\ (Inheritance\ mieraf\ (var\ 1))\ (support\ 3))$$

---

### **Step 6: Conjunction Expansion (Pattern Joining)**
- Joins two or more verified frequent patterns together on shared variables into multi-atom rules:
  $$(,\ (Inheritance\ \$x\ human)\ (Likes\ \$x\ pizza))$$

---

### **Step 7: Surprisingness & Statistical Scoring**
- Uses combinatorial math (`factorial`, `falling_factorial`) to calculate the expected frequency vs actual support and score how statistically surprising/interesting the pattern is.

---

### **Step 8: Automated Symmetric-Difference Unit Testing**
- Computes $(A \cup B) \setminus (A \cap B) = A \Delta B$ against `expected-val`.
- Outputs **`(TEST-PASSED)`** if 0 mistakes remain, or **`(TEST-FAILED $error)`** on any discrepancy.