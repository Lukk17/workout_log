enum BodyPart { chest, back, arm, leg, abdominal, cardio, undefined }

// Accepts both `Enum.name` tokens (current) and SCREAMING_CASE (the
// pre-1.2.3+8 format already on existing devices). Unknown -> undefined.
BodyPart decodeBodyPart(String token) {
  try {
    return BodyPart.values.byName(token.toLowerCase());
  } catch (_) {
    return BodyPart.undefined;
  }
}
