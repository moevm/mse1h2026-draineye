import 'package:flutter/material.dart';

const Color kConfidenceRed = Color(0xFFEF4444);
const Color kConfidenceYellow = Color(0xFFF59E0B);
const Color kConfidenceGreen = Color(0xFF22C55E);

/// Уверенность в процентах (0–100): &lt;70 красный, 70–89 жёлтый, ≥90 зелёный.
Color confidenceAccentColorFromPercent(num percent) {
  final p = percent.toDouble();
  if (p < 70) return kConfidenceRed;
  if (p < 90) return kConfidenceYellow;
  return kConfidenceGreen;
}
