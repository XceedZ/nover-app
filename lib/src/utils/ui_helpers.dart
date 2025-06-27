import 'package:flutter/material.dart';

// --- Responsive Font Size Helper ---
double responsiveFontSize(BuildContext context, double baseFontSize) {
  const double referenceWidth = 375.0; // Your design reference width
  double screenWidth = MediaQuery.of(context).size.width;
  double scaleFactor = screenWidth / referenceWidth;
  // Adjust clamp values as needed for your design's responsiveness
  return baseFontSize * scaleFactor.clamp(0.9, 1.2);
}