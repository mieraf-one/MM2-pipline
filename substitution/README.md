# MM2 Recursive Substitution

A pattern substitution written in MM2.

---

## Features

1. **Simple patterns**: Replaces variables in basic patterns, like `(Inheritance $a $b)` with `(nati bob)`.
2. **Nested patterns**: Replaces variables inside nested expressions of any depth, like `(Inheritance (Inheritance $a $b) (Inheritance $c $d))`.
3. **Empty pattern**: If the pattern is empty `()`, it returns `()`.
4. **Empty values**: If values are empty `()`, it leaves the pattern unchanged.
5. **Not enough values**: If values run out early, it fills what it can and leaves the remaining variables as they are.
6. **Excess values**: If there are extra values, it fills all variables and ignores the rest.
7. **Different variable types**: Supports both standard variables (like `$x`) and marker variables (like `(var x)`).
8. **Keeps constants**: Keeps symbols and words as they are without using up values.
9. **Clean memory**: Automatically removes all temporary rules from memory when done.

---

## Format

### Input Format
Each substitution task is defined as:
```metta
(SUBSTITUTE <id> <pattern> <values>)
```
- `<id>`: Unique name or identifier (e.g. `p1`, `p2`).
- `<pattern>`: Expression containing variables (e.g. `(Inheritance $a $b)`).
- `<values>`: List of values to plug into the variables (e.g. `(nati bob)`).

**Example:**
```metta
(SUBSTITUTE p1 (Inheritance $a $b) (nati bob))
```

### Output Format
The engine produces the substituted result as:
```metta
(SUBSTITUTED <id> <result>)
```
- `<id>`: The matching identifier from the input.
- `<result>`: The pattern with its variables replaced by the values.

**Example:**
```metta
(SUBSTITUTED p1 (Inheritance nati bob))
```

*(The original `(SUBSTITUTE ...)` input fact is also kept in the output).*

---

## Files

- **`subs.metta`**: The substitution rules.
- **`test/test.metta`**: The test inputs (`p1` through `p18`).
- **`test/output.metta`**: The output file with the results.

---

## How to Run the Tests


### From the main folder
```bash
mork run subs.metta --aux-path test/test.metta test/output.metta
```

### Check the Results
```bash
cat test/output.metta
```