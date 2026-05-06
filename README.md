# hake

A tiny `make`-like build tool written in Haskell.

It builds `test.out` from `test.c` only when the output is missing or one of its dependencies is newer. The rules are currently hardcoded in `app/Main.hs`.

## Run

```sh
cd app
bash run.sh
```

This compiles `Main.hs` with GHC, then builds the sample C program.

## How It Works

Each rule has three parts:

- target
- dependencies
- shell command

Current build chain:

```text
test.c -> test.o -> test.out
```

## Requirements

- GHC
- GCC
