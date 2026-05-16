enum BodyPart { chest, back, arm, leg, abdominal, cardio, undefined }

/// Decode a single token (from either the legacy SCREAMING_CASE format used by
/// pre-1.2.3+8 installs, or the new `Enum.name` format) into a [BodyPart].
/// Unknown tokens map to [BodyPart.undefined].
BodyPart decodeBodyPart(String token) {
  try {
    return BodyPart.values.byName(token.toLowerCase());
  } catch (_) {
    return BodyPart.undefined;
  }
}
