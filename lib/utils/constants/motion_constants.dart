import 'package:flutter/material.dart';


class AMotion {
  AMotion._();

  // ==========================================================================
  // EASING TOKENS
  // ==========================================================================


  static const Curve easingEmphasized = Curves.easeInOutCubicEmphasized;
  

  static const Curve easingEmphasizedDecelerate = Cubic(0.05, 0.7, 0.1, 1.0);
  

  static const Curve easingEmphasizedAccelerate = Cubic(0.3, 0.0, 0.8, 0.15);


  static const Curve easingStandard = Cubic(0.2, 0.0, 0, 1.0);
  

  static const Curve easingStandardDecelerate = Cubic(0, 0, 0, 1);
  

  static const Curve easingStandardAccelerate = Cubic(0.3, 0, 1, 1);

  // ==========================================================================
  // DURATION TOKENS
  // ==========================================================================

  // --- SHORT ---
  static const Duration durationShort1 = Duration(milliseconds: 50);
  static const Duration durationShort2 = Duration(milliseconds: 100);
  static const Duration durationShort3 = Duration(milliseconds: 150);
  static const Duration durationShort4 = Duration(milliseconds: 200);

  // --- MEDIUM ---
  static const Duration durationMedium1 = Duration(milliseconds: 250);
  static const Duration durationMedium2 = Duration(milliseconds: 300);
  static const Duration durationMedium3 = Duration(milliseconds: 350);
  static const Duration durationMedium4 = Duration(milliseconds: 400);

  // --- LONG ---
  static const Duration durationLong1 = Duration(milliseconds: 450);
  static const Duration durationLong2 = Duration(milliseconds: 500);
  static const Duration durationLong3 = Duration(milliseconds: 550);
  static const Duration durationLong4 = Duration(milliseconds: 600);

  // --- EXTRA LONG ---
  static const Duration durationExtraLong1 = Duration(milliseconds: 700);
  static const Duration durationExtraLong2 = Duration(milliseconds: 800);
  static const Duration durationExtraLong3 = Duration(milliseconds: 900);
  static const Duration durationExtraLong4 = Duration(milliseconds: 1000);


  // SPATIAL 
  static const Curve expressiveFastSpatial = Cubic(0.42, 1.67, 0.21, 0.90);
  static const Curve expressiveDefaultSpatial = Cubic(0.38, 1.21, 0.22, 1.00);
  static const Curve expressiveSlowSpatial = Cubic(0.39, 1.29, 0.35, 0.98);

  // EFFECTS 
  static const Curve expressiveFastEffects = Cubic(0.31, 0.94, 0.34, 1.00);
  static const Curve expressiveDefaultEffects = Cubic(0.34, 0.80, 0.34, 1.00);
  static const Curve expressiveSlowEffects = Cubic(0.34, 0.88, 0.34, 1.00);

  // DURATIONS
  static const Duration durationExpressiveFast = durationMedium3;       // 350ms
  static const Duration durationExpressiveDefault = durationLong2;    // 500ms
  static const Duration durationExpressiveSlow = Duration(milliseconds: 650);

  static const Duration durationExpressiveEffectsFast = durationShort3;    // 150ms
  static const Duration durationExpressiveEffectsDefault = durationShort4; // 200ms
  static const Duration durationExpressiveEffectsSlow = durationMedium2;    // 300ms


  /// md.sys.motion.spring.fast.spatial
  static Curve springFastSpatial({bool reduceMotion = false}) => 
    reduceMotion ? easingStandard : expressiveFastSpatial;

  /// md.sys.motion.spring.default.spatial
  static Curve springDefaultSpatial({bool reduceMotion = false}) => 
    reduceMotion ? easingStandard : expressiveDefaultSpatial;

  /// md.sys.motion.spring.slow.spatial
  static Curve springSlowSpatial({bool reduceMotion = false}) => 
    reduceMotion ? easingStandard : expressiveSlowSpatial;

  // ==========================================================================
  // SUGGESTED EASING & DURATION PAIRS (M3 Defaults)
  // ==========================================================================

  /// Begin and end on screen
  static const Duration durationStationaryEmphasized = durationLong2; // 500ms
  static const Curve curveStationaryEmphasized = easingEmphasized;

  ///Move onto the screen
  static const Duration durationEnterEmphasized = durationMedium4; // 400ms
  static const Curve curveEnterEmphasized = easingEmphasizedDecelerate;

  /// Move off the screen permanently
  static const Duration durationExitEmphasized = durationShort4; // 200ms
  static const Curve curveExitEmphasized = easingEmphasizedAccelerate;

  ///  Begin and end on screen
  static const Duration durationStationaryStandard = durationMedium2; // 300ms
  static const Curve curveStationaryStandard = easingStandard;

  ///  Move onto the screen
  static const Duration durationEnterStandard = durationMedium1; // 250ms
  static const Curve curveEnterStandard = easingStandardDecelerate;

  ///  Move off the screen permanently
  static const Duration durationExitStandard = durationShort4; // 200ms
  static const Curve curveExitStandard = easingStandardAccelerate;


  static Duration get fast => durationExpressiveFast; 
  static Duration get durationDefault => durationExpressiveDefault;
  static Duration get slow => durationExpressiveSlow;
  static Curve get effects => expressiveDefaultEffects;

  static const Curve emphasized = easingEmphasized;
  static const Curve emphasizedDecelerate = easingEmphasizedDecelerate;
  static const Curve emphasizedAccelerate = easingEmphasizedAccelerate;

  static const Duration durationEmphasized = durationStationaryEmphasized;
  static const Duration durationEmphasizedDecelerate = durationEnterEmphasized;
  static const Duration durationEmphasizedAccelerate = durationExitEmphasized;
}
