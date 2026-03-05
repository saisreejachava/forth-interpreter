# FORTH Assignment

## Build and run

1. Install dependencies (once):
   ```bash
   cabal install
   cabal install hbase
   ```
2. Build:
   ```bash
   cabal build
   ```
3. Run one functional test file:
   ```bash
   cabal run tests/t1.4TH
   ```

## Unit tests

Run the HSpec suites:

```bash
runhaskell ValSpec.hs
runhaskell EvalSpec.hs
runhaskell InterpretSpec.hs
```

## Functional tests

The folder `tests/` contains input/output pairs:

- `t1.4TH` ... `t10.4TH`
- `t1.out` ... `t10.out`

To verify all quickly:

```bash
for i in {1..10}; do
  cabal run tests/t${i}.4TH > /tmp/t${i}.actual
  diff -u tests/t${i}.out /tmp/t${i}.actual || exit 1
  echo "t${i} OK"
done
```

## Implemented features

- Arithmetic built-ins: `*`, `+`, `-`, `/`, `^`
- Stack/printing built-ins: `DUP`, `.`, `EMIT`, `CR`
- String built-ins: `STR`, `CONCAT2`, `CONCAT3`
- End-of-run stack reporting in `Main.hs` when stack is not empty
- Bonus implemented: **Yes**
- Bonus: user-defined words using FORTH-like syntax:
  ```forth
  : SQR DUP * ;
  9 SQR .
  ```

## Notes and situations encountered

- The original project depended on `flow` only for a pipeline operator in `Interpret.hs`. The interpreter was refactored to plain recursive processing so it can support user-defined functions and dictionary state.
- To support `STR`/`CONCAT*` correctly, a dedicated `Str` value type was added so strings are distinct from unresolved identifiers.
- Functional output files were written manually as required and include a case validating the non-empty stack message.
