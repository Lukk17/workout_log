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

extension BodyPartName on BodyPart {
  /// User-facing label. Empty string for `undefined` so it can be
  /// dropped silently from row displays.
  String get displayName =>
      switch (this) {
        BodyPart.chest => 'chest',
        BodyPart.back => 'back',
        BodyPart.leg => 'leg',
        BodyPart.arm => 'arm',
        BodyPart.cardio => 'cardio',
        BodyPart.abdominal => 'abdominal',
        BodyPart.undefined => '',
      };
}
