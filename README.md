# Windows Ledger Binaries
A fully automated Windows build for the [Ledger CLI](https://www.ledger-cli.org/) using
GitHub Actions with a Linux-hosted MinGW cross-compiler.

Ledger is a double-entry accounting system with a command-line reporting interface.

Main project is located here: https://github.com/ledger/ledger

The only purpose this repo serves is to provide a location for Windows binaries.

This repo also currently supplies the Windows binaries for the [Chocolatey](https://chocolatey.org/packages/ledger) package.

## How it works

The `build-linux.yml` workflow runs on `ubuntu-latest` and:

1. Cross-compiles GMP, MPFR, and Boost from source for the `x86_64-w64-mingw32` target.
2. Clones the `ledger` submodule and patches its CMake link order so that
   `-lmpfr` precedes `-lgmp` (required by GNU ld for static archives).
3. Configures and builds `ledger.exe` with CMake + the MinGW toolchain.
4. Uploads `ledger.exe` as a build artifact.

To trigger a build, use the **Run workflow** button on the
[Actions page](../../actions/workflows/build-linux.yml).

