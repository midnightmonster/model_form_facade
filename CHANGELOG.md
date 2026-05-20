## [Unreleased]

## [0.3.0] - 2026-05-20

### Fixed

- **Breaking:** Fields on forms backed by multi-word class names (e.g. `FooBar`) now generate correctly parameterized field names (`foo_bar[field]` instead of `foobar[field]`).

### Added

- Array fields now accept both a plain array and a numeric-keyed hash (Rails strong params style), making it easier to handle form submissions without manual coercion.

## [0.2.0] - 2025-08-30

### Added

- Nested forms with custom `read:`, `write:`, and `attribute:` mappings now work correctly — nested object and array fields are routed through the inner form's write logic.
- `as_written(hash)` class method returns the attributes hash as they would be written to the backing object, without needing a real model instance.
- `#errors` now joins multiple validation messages with a readable separator.

### Fixed

- `Field type: :array` write method no longer errors on assignment.

## [0.1.0] - 2025-08-27

- Initial release
