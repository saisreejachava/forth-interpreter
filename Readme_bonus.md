# Bonus Implementation Notes

## Bonus status

Implemented: **Yes**

This project implements user-defined FORTH words using standard FORTH-style syntax:

```forth
: NAME ... ;
```

## Supported behavior

- Define a new word with `:` and terminate with `;`
- Store definitions in an interpreter dictionary
- Invoke user-defined words later in the same program
- Compose definitions (a user-defined word can call another user-defined word)

## Example

```forth
: SQR DUP * ;
9 SQR .
```

Expected output:

```text
81
```

## Code references

- Definition parsing and dictionary handling: `Interpret.hs`
- Definition execution during token processing: `Interpret.hs`



### Unit tests (`InterpretSpec.hs`)

- `defines and uses a function`
- `supports multiple definitions and composition`

### Functional tests

- `tests/t8.4TH` + `tests/t8.out`
  - validates `: SQR DUP * ;`
- `tests/t9.4TH` + `tests/t9.out`
  - validates user-defined `STAR` composed with `EMIT`
