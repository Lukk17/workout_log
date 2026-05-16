## MODIFIED Requirements

### Requirement: Domain entity IDs use UUID v4

All new domain entity identifiers (currently `WorkLog.id` and `Exercise.id`) SHALL be generated using `Uuid().v4()`. UUID v1 SHALL NOT be used because it embeds the host MAC address and a timestamp, creating an unnecessary device-fingerprinting vector even in an offline app. IDs SHALL be assigned at construction time and SHALL be immutable for the lifetime of the entity (enforced by freezed — no public setter for `id`).

#### Scenario: New WorkLog gets a v4 ID

- **WHEN** a new `WorkLog` instance is constructed via its default constructor
- **THEN** its `id` field is a valid UUID v4 string (version digit `4` at position 14 of the canonical form)

#### Scenario: New Exercise gets a v4 ID

- **WHEN** a new `Exercise` instance is constructed via its default constructor
- **THEN** its `id` field is a valid UUID v4 string

#### Scenario: ID cannot be reassigned after construction

- **WHEN** code attempts `workLog.id = "new-id"` on a freezed `WorkLog`
- **THEN** the compiler rejects the assignment (no public setter exists); to "change" the ID, `copyWith(id: ...)` must be used and a new instance is produced
