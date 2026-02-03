import 'package:flutter/material.dart';

class AppBorderRadius {
  AppBorderRadius._();

  static const double xs = 6;
  static const double sm = 8;
  static const double md = 10;
  static const double card = 12;

  static BorderRadius get radiusXs => BorderRadius.circular(xs);
  static BorderRadius get radiusSm => BorderRadius.circular(sm);
  static BorderRadius get radiusMd => BorderRadius.circular(md);
  static BorderRadius get radiusCard => BorderRadius.circular(card);
}
