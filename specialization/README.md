# Specialization

## What this file handles:

* **Handles nested patterns**: Can specialize variables at any depth, even inside deep nested expressions.
* **Prunes at each step**: Checks support right after each specialization step, and only specializes again if the pattern is over `MIN-SUPPORT`.

---

## How to run:

Inside `specialization` folder:

```bash
mork run specialization.mm2 --aux-path test/icog-val-sha-abs.mm2 --aux-path test/2arg-100-facts.mm2 output.mm2
```

* `specialization.mm2`: The specialization code.
* `--aux-path test/icog-val-sha-abs.mm2`: Valuation and shallow abstraction.
* `--aux-path test/2arg-100-facts.mm2`: Facts and `MIN-SUPPORT`.
* `output.mm2`: The output file saved in this folder.

---