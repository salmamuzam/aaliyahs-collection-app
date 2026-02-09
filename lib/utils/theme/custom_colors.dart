import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';

@immutable
class AaliyahCustomColors extends ThemeExtension<AaliyahCustomColors> {
  const AaliyahCustomColors({
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.caution,
    required this.onCaution,
    required this.cautionContainer,
    required this.onCautionContainer,
  });

  final Color? success;
  final Color? onSuccess;
  final Color? successContainer;
  final Color? onSuccessContainer;
  
  final Color? caution;
  final Color? onCaution;
  final Color? cautionContainer;
  final Color? onCautionContainer;

  @override
  AaliyahCustomColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? caution,
    Color? onCaution,
    Color? cautionContainer,
    Color? onCautionContainer,
  }) {
    return AaliyahCustomColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      caution: caution ?? this.caution,
      onCaution: onCaution ?? this.onCaution,
      cautionContainer: cautionContainer ?? this.cautionContainer,
      onCautionContainer: onCautionContainer ?? this.onCautionContainer,
    );
  }

  @override
  AaliyahCustomColors lerp(ThemeExtension<AaliyahCustomColors>? other, double t) {
    if (other is! AaliyahCustomColors) {
      return this;
    }
    return AaliyahCustomColors(
      success: Color.lerp(success, other.success, t),
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t),
      successContainer: Color.lerp(successContainer, other.successContainer, t),
      onSuccessContainer: Color.lerp(onSuccessContainer, other.onSuccessContainer, t),
      caution: Color.lerp(caution, other.caution, t),
      onCaution: Color.lerp(onCaution, other.onCaution, t),
      cautionContainer: Color.lerp(cautionContainer, other.cautionContainer, t),
      onCautionContainer: Color.lerp(onCautionContainer, other.onCautionContainer, t),
    );
  }


  AaliyahCustomColors harmonized(ColorScheme dynamicScheme) {
    return copyWith(
      success: success?.harmonizeWith(dynamicScheme.primary),
      onSuccess: onSuccess?.harmonizeWith(dynamicScheme.primary),
      successContainer: successContainer?.harmonizeWith(dynamicScheme.primary),
      onSuccessContainer: onSuccessContainer?.harmonizeWith(dynamicScheme.primary),
      caution: caution?.harmonizeWith(dynamicScheme.primary),
      onCaution: onCaution?.harmonizeWith(dynamicScheme.primary),
      cautionContainer: cautionContainer?.harmonizeWith(dynamicScheme.primary),
      onCautionContainer: onCautionContainer?.harmonizeWith(dynamicScheme.primary),
    );
  }
}


class StaticColors {
  // Brand Green (Success)
  static const success = Color(0xFF2E7D32);
  static const lightSuccess = Color(0xFF2E7D32);
  static const lightOnSuccess = Color(0xFFFFFFFF);
  static const lightSuccessContainer = Color(0xFFC8E6C9);
  static const lightOnSuccessContainer = Color(0xFF003300);

  static const darkSuccess = Color(0xFF81C784);
  static const darkOnSuccess = Color(0xFF003300);
  static const darkSuccessContainer = Color(0xFF1B5E20);
  static const darkOnSuccessContainer = Color(0xFFC8E6C9);

  // Caution (Yellow/Orange)
  static const caution = Color(0xFFF9A825);
  static const lightCaution = Color(0xFFF9A825);
  static const lightOnCaution = Color(0xFFFFFFFF);
  static const lightCautionContainer = Color(0xFFFFF9C4);
  static const lightOnCautionContainer = Color(0xFF5F4300);

  static const darkCaution = Color(0xFFFBC02D);
  static const darkOnCaution = Color(0xFF432C00);
  static const darkCautionContainer = Color(0xFFF57F17);
  static const darkOnCautionContainer = Color(0xFFFFF9C4);

  static AaliyahCustomColors getLight(ColorScheme? scheme) {
    const colors = AaliyahCustomColors(
      success: lightSuccess,
      onSuccess: lightOnSuccess,
      successContainer: lightSuccessContainer,
      onSuccessContainer: lightOnSuccessContainer,
      caution: lightCaution,
      onCaution: lightOnCaution,
      cautionContainer: lightCautionContainer,
      onCautionContainer: lightOnCautionContainer,
    );
    return scheme != null ? colors.harmonized(scheme) : colors;
  }

  static AaliyahCustomColors getDark(ColorScheme? scheme) {
    const colors = AaliyahCustomColors(
      success: darkSuccess,
      onSuccess: darkOnSuccess,
      successContainer: darkSuccessContainer,
      onSuccessContainer: darkOnSuccessContainer,
      caution: darkCaution,
      onCaution: darkOnCaution,
      cautionContainer: darkCautionContainer,
      onCautionContainer: darkOnCautionContainer,
    );
    return scheme != null ? colors.harmonized(scheme) : colors;
  }
}
