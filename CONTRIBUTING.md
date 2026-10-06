# Contributing

Keep the core deterministic, offline, and independent of the machine's local timezone. Use Lua 5.1-compatible syntax unless there is a documented reason to change the support range. Add tests for edge cases and invariants, then run `lua spec/run.lua` and the CLI smoke checks from the repository root.

Please explain compatibility effects and recurrence semantics in pull requests. Do not add a worldwide holiday dataset or a runtime dependency without a clear use case.
