## ADDED Requirements

### Requirement: Domain entity IDs use UUID v4

All new domain entity identifiers (currently `WorkLog.id` and `Exercise.id`) SHALL be generated using `Uuid().v4()`. UUID v1 SHALL NOT be used because it embeds the host MAC address and a timestamp, creating an unnecessary device-fingerprinting vector even in an offline app.

#### Scenario: New WorkLog gets a v4 ID

- **WHEN** a new `WorkLog` instance is constructed
- **THEN** its `id` field is a valid UUID v4 string (version digit `4` at position 14 of the canonical form)

#### Scenario: New Exercise gets a v4 ID

- **WHEN** a new `Exercise` instance is constructed
- **THEN** its `id` field is a valid UUID v4 string

### Requirement: Existing v1 IDs remain valid

Entity IDs previously generated with `Uuid().v1()` and persisted to the local sqflite database SHALL continue to function as primary keys without migration. IDs are treated as opaque strings.

#### Scenario: Existing v1 IDs are read back correctly

- **WHEN** the app starts and loads workouts that were created before this change
- **THEN** the v1 IDs are read from sqflite and used unchanged in subsequent updates and deletes
