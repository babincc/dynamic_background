import 'dart:math';

import 'package:collection/collection.dart';
import 'package:dynamic_background/domain/enums/lava_direction.dart';
import 'package:dynamic_background/utils/math_tools.dart';
import 'package:flutter/material.dart';

/// This is the data needed to paint a circle in the lava lamp pattern.
class Lava {
  /// Creates a new [Lava] object.
  Lava({
    required this.width,
    required this.widthTolerance,
    required this.growAndShrink,
    required this.growthRate,
    required this.growthRateTolerance,
    required this.blurLevel,
    required this.colors,
    required this.allSameColor,
    required this.fadeBetweenColors,
    required this.changeColorsTogether,
    required this.speed,
    required this.speedTolerance,
  })  : assert(width > 0.0),
        assert(width - widthTolerance > 0.0),
        assert(growthRate >= 0.0),
        assert(growthRate - growthRateTolerance >= 0.0),
        assert(blurLevel >= 0.0),
        assert(colors.isNotEmpty, true),
        assert(speed >= 0),
        assert(speed - speedTolerance >= 0),
        _originalWidth = width,
        color =
            allSameColor ? colors[0] : colors[randInt(0, colors.length - 1)],
        _colorIndex = 0,
        _isGrowing = randInt(0, 9) % 2 == 0,
        position = initPosition,
        direction = LavaDirection.values[randInt(
          0,
          LavaDirection.values.length - 1,
        )],
        _previousAnimationValue = 10.0,
        _previousStep = 10,
        _fadePhase = allSameColor
            ? 0.0
            : changeColorsTogether
                ? 0.0
                : randDouble(0.0, 1.0) {
    // Randomly set the size of the circle.
    width += randDouble(-widthTolerance, widthTolerance);

    // Randomly set the speed of the circle.
    speed += randDouble(-speedTolerance, speedTolerance);

    // Randomly set the growth rate of the circle.
    growthRate += randDouble(-growthRateTolerance, growthRateTolerance);

    // Set the next color.
    if (colors.length == 1) {
      __nextColorIndex = 0;
    } else {
      if (allSameColor) {
        __nextColorIndex = (_colorIndex + 1) % colors.length;
      } else {
        __nextColorIndex = randInt(0, colors.length - 1);
      }
    }
  }

  /// The initial position of the circle when a new circle is created.
  ///
  /// This is used to determine if the circle has been given a proper starting
  /// position based on available screen space.
  static const Offset initPosition = Offset(-99999.99999, -99999.99999);

  /// The width of this circle.
  double width;

  /// The original width of this circle.
  final double _originalWidth;

  /// The amount more or less than the set [width] that the circles can be.
  ///
  /// This is used to give the circles a bit of randomness in their size.
  ///
  /// For example, if [width] is `24.0` and [widthTolerance] is `4.0`, the
  /// circles can be anywhere from `20.0` to `28.0` pixels wide.
  ///
  /// The default value is `0.0`.
  final double widthTolerance;

  /// Whether or not the circles should grow and shrink.
  ///
  /// If this is `true`, the circles will grow and shrink. If this is `false`,
  /// the circles will remain a static size.
  final bool growAndShrink;

  /// Whether or not the circle is growing.
  ///
  /// If this is `true`, the circle is growing. If this is `false`, the circle
  /// is shrinking.
  bool _isGrowing;

  /// The rate at which the circle will grow and shrink.
  double growthRate;

  /// The amount more or less than the set [growthRate] that the circles can
  /// grow and shrink.
  ///
  /// This is used to give the circles a bit of randomness in their growth rate.
  ///
  /// For example, if [growthRate] is `20.0` and [growthRateTolerance] is `5.0`,
  /// the circles can grow and shrink at a rate of anywhere from `15.0` to
  /// `25.0`.
  ///
  /// The default value is `0.0`.
  final double growthRateTolerance;

  /// How extreme the blur effect should be. The higher the number, the more
  /// extreme the blur effect.
  final double blurLevel;

  /// The colors of the circles that will be moving on the screen.
  ///
  /// Note: There is no guarantee that all colors will be used. If the list is
  /// too long, some colors may be skipped.
  ///
  /// Note: If [allSameColor] is `true`, the order of this list matter;
  /// otherwise, the order does not matter.
  final List<Color> colors;

  /// The current color of this circle.
  Color color;

  /// The index of the current color of this circle.
  int _colorIndex;

  /// The index of the next color of this circle.
  ///
  /// This is the color this circle is fading to.
  late int __nextColorIndex;

  /// Whether or not all circles should be the same color.
  ///
  /// If this is `true`, all circles will be the same color. If this is `false`,
  /// the circles will randomly select their colors from the [colors] list.
  final bool allSameColor;

  /// Whether or not each circle should fade between colors.
  final bool fadeBetweenColors;

  /// Whether or not the circles should change colors together.
  ///
  /// If this is `true`, all circles will change colors at the same time. If
  /// this is `false`, each circle will change colors at its own pace.
  final bool changeColorsTogether;

  /// When the color should start to change.
  ///
  /// This is a value between `0.0` and `1.0`. It can keep the other colors in
  /// sync, or it can make the colors change at different times.
  final double _fadePhase;

  /// The speed that the lava blobs will move across the screen.
  ///
  /// The higher the number, the faster the blobs will move.
  double speed;

  /// The tolerance for the speed of the lava blobs.
  ///
  /// This is used to give the circles a bit of randomness in their movement
  /// speed.
  ///
  /// For example, if [speed] is `5.0` and [speedTolerance] is `4.0`, the
  /// circles can have a speed anywhere from `1.0` to `9.0`.
  ///
  /// The default value is `0`.
  final double speedTolerance;

  /// The current position of this circle.
  Offset position;

  /// The direction this circle is moving.
  LavaDirection direction;

  /// The previous value of the animation.
  double _previousAnimationValue;

  /// The previous step for color fading.
  int _previousStep;

  /// Returns the data for the next step of this circle in the lava lamp
  /// pattern.
  ///
  /// It uses the current data to calculate the next position of the circle.
  ///
  /// THIS IS DESTRUCTIVE. This method will update the data of this object so
  /// next time it can be used to get the next position of the circle.
  void stepForward(double animationValue) {
    final double rawPhase = animationValue + _fadePhase;
    animationValue = rawPhase == 1.0 ? 1.0 : rawPhase % 1.0;

    if (animationValue < _previousAnimationValue) {
      _previousAnimationValue = 0.0;
      _previousStep = -1;
    }

    // Calculate the next width of the circle.
    if (growAndShrink) {
      const double growthRateMultiplier = 0.01;
      if (_isGrowing) {
        width += growthRate * growthRateMultiplier;
        if (width >= _originalWidth + widthTolerance) {
          _isGrowing = false;
          width = _originalWidth + widthTolerance;
        }
      } else {
        width -= growthRate * growthRateMultiplier;
        if (width <= _originalWidth - widthTolerance) {
          _isGrowing = true;
          width = _originalWidth - widthTolerance;
        }
      }
    }

    // Calculate the next color of the circle.
    if (fadeBetweenColors) {
      final double stepLength = 1.0 / colors.length;
      final int step =
          min((animationValue / stepLength).floor(), colors.length - 1);

      if (_previousStep < step || _previousStep < 0) {
        _previousStep = step;
        _colorIndex = __nextColorIndex;
        _setNextColor();
      }

      color = Color.lerp(
            colors[_colorIndex],
            colors[__nextColorIndex],
            (animationValue - (step * stepLength)) / stepLength,
          ) ??
          colors[_colorIndex];
    }

    // Calculate the next position of the circle.
    const double speedMultiplier = 0.075;
    final double radians = direction.degrees * (pi / 180);
    final double x = position.dx + ((speed * speedMultiplier) * cos(radians));
    final double y = position.dy + ((speed * speedMultiplier) * sin(radians));
    position = Offset(x, y);

    _previousAnimationValue = animationValue;
  }

  void _setNextColor() {
    if (colors.length == 1) {
      __nextColorIndex = 0;
    } else {
      if (allSameColor) {
        __nextColorIndex = (__nextColorIndex + 1) % colors.length;
      } else {
        __nextColorIndex = randIntExcluding(
          0,
          colors.length - 1,
          __nextColorIndex,
        );
      }
    }
  }

  /// Returns a copy of this object.
  Lava copy() => copyWith();

  /// Returns a copy of this object with its field values replaced by the ones
  /// provided to this method.
  ///
  /// Special note: The colors list is not copied. It is passed by reference.
  Lava copyWith({
    double? width,
    double? widthTolerance,
    bool? growAndShrink,
    double? growthRate,
    double? growthRateTolerance,
    double? blurLevel,
    List<Color>? colors,
    bool? allSameColor,
    bool? fadeBetweenColors,
    bool? changeColorsTogether,
    double? speed,
    double? speedTolerance,
  }) {
    return Lava(
      width: width ?? this.width,
      widthTolerance: widthTolerance ?? this.widthTolerance,
      growAndShrink: growAndShrink ?? this.growAndShrink,
      growthRate: growthRate ?? this.growthRate,
      growthRateTolerance: growthRateTolerance ?? this.growthRateTolerance,
      blurLevel: blurLevel ?? this.blurLevel,
      colors: colors ?? this.colors,
      allSameColor: allSameColor ?? this.allSameColor,
      fadeBetweenColors: fadeBetweenColors ?? this.fadeBetweenColors,
      changeColorsTogether: changeColorsTogether ?? this.changeColorsTogether,
      speed: speed ?? this.speed,
      speedTolerance: speedTolerance ?? this.speedTolerance,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other.runtimeType != runtimeType) return false;

    return other is Lava &&
        identical(other.width, width) &&
        identical(other.widthTolerance, widthTolerance) &&
        identical(other.growAndShrink, growAndShrink) &&
        identical(other._isGrowing, _isGrowing) &&
        identical(other.growthRate, growthRate) &&
        identical(other.growthRateTolerance, growthRateTolerance) &&
        identical(other.blurLevel, blurLevel) &&
        const DeepCollectionEquality().equals(other.colors, colors) &&
        identical(other._colorIndex, _colorIndex) &&
        identical(other.__nextColorIndex, __nextColorIndex) &&
        identical(other.allSameColor, allSameColor) &&
        identical(other.fadeBetweenColors, fadeBetweenColors) &&
        identical(other.changeColorsTogether, changeColorsTogether) &&
        identical(other.speed, speed) &&
        identical(other.speedTolerance, speedTolerance) &&
        other.position == position &&
        identical(other.direction, direction);
  }

  @override
  int get hashCode => Object.hash(
        width,
        widthTolerance,
        growAndShrink,
        _isGrowing,
        growthRate,
        growthRateTolerance,
        blurLevel,
        const DeepCollectionEquality().hash(colors),
        _colorIndex,
        __nextColorIndex,
        allSameColor,
        fadeBetweenColors,
        changeColorsTogether,
        speed,
        speedTolerance,
        position,
        direction,
      );

  @override
  String toString() => 'Instance of Lava: {'
      'width: $width, '
      'widthTolerance: $widthTolerance, '
      'growAndShrink: $growAndShrink, '
      '_isGrowing: $_isGrowing, '
      'growthRate: $growthRate, '
      'growthRateTolerance: $growthRateTolerance, '
      'blurLevel: $blurLevel, '
      'colors: $colors'
      '_colorIndex: $_colorIndex, '
      '__nextColorIndex: $__nextColorIndex, '
      'allSameColor: $allSameColor, '
      'fadeBetweenColors: $fadeBetweenColors, '
      'changeColorsTogether: $changeColorsTogether, '
      'speed: $speed, '
      'speedTolerance: $speedTolerance, '
      'position: $position, '
      'direction: $direction'
      '}';
}
