## ADDED Requirements

### Requirement: Domain entities are immutable value types

`WorkLog` and `Exercise` SHALL be freezed-generated immutable classes with value equality, `copyWith`, and generated `toJson` / `fromJson`. Their fields SHALL NOT have public setters.

#### Scenario: copyWith produces a new instance

- **WHEN** `original.copyWith(bodyWeight: 80)` is called on a `WorkLog`
- **THEN** a new `WorkLog` instance is returned, `original.bodyWeight` is unchanged, and `original != updated`

#### Scenario: Two value-equal entities compare equal

- **WHEN** two `Exercise` instances are constructed with the same id, name, and body parts
- **THEN** `a == b` returns `true` and `a.hashCode == b.hashCode`

### Requirement: BodyPart enum uses lowerCamelCase

The `BodyPart` enum SHALL use lowerCamelCase member names (`chest`, `back`, `arm`, `leg`, `abdominal`, `cardio`, `undefined`). The serialized form on disk SHALL be the result of `Enum.name`.

#### Scenario: Serializing a body part

- **WHEN** `BodyPart.chest` is serialized via the persistence layer
- **THEN** the persisted token is `"chest"`

### Requirement: BodyPart deserializer accepts legacy SCREAMING_CASE tokens

The `BodyPart` deserializer SHALL accept both new lowerCamelCase tokens (`"chest"`) and legacy SCREAMING_CASE tokens (`"CHEST"`) from existing on-device installs. Unknown tokens map to `BodyPart.undefined`.

#### Scenario: Legacy token deserializes

- **WHEN** a row containing `bodyPart = "CHEST&BACK&"` (legacy format from app version 1.2.3) is read
- **THEN** the resulting `Set<BodyPart>` contains `{chest, back}`

#### Scenario: Unknown token falls back

- **WHEN** a row containing `bodyPart = "NOSUCHPART&"` is read
- **THEN** the resulting `Set<BodyPart>` contains `{undefined}` and no exception is thrown

### Requirement: WorkLog series and load are strongly typed

`WorkLog.series` and `WorkLog.load` SHALL be typed `Map<String, String>` in memory. They SHALL continue to be persisted as JSON strings in the sqflite cell.

#### Scenario: getRepsSum on a populated series

- **WHEN** `workLog.series = {"1": "10", "2": "8", "3": "6"}`
- **THEN** `workLog.getRepsSum()` returns `"24"`

#### Scenario: Hostile legacy row coerces safely

- **WHEN** a row contains `series = '{"1":10,"2":"8"}'` (mixed int/string from legacy code)
- **THEN** deserialization coerces both values to `String` and reads back as `{"1": "10", "2": "8"}`
