package funkin.util;

import flixel.math.FlxMath;
import flixel.group.FlxGroup.FlxTypedGroup;

/**
 * Utilities for performing mathematical operations.
 */
class MathUtil
{
  /**
   * Euler's constant and the base of the natural logarithm.
   * Math.E is not a constant in Haxe, so we'll just define it ourselves.
   */
  public static final E:Float = 2.71828182845904523536;

  /**
   * Perform linear interpolation between the base and the target, based on the current framerate.
   * @param base The starting value, when `progress <= 0`.
   * @param target The ending value, when `progress >= 1`.
   * @param ratio Value used to interpolate between `base` and `target`.
   *
   * @return The interpolated value.
   */
  // @:deprecated('Use smoothLerp instead')
  public static inline function coolLerp(base:Float, target:Float, ratio:Float):Float
  {
    return base + cameraLerp(ratio) * (target - base);
  }

  /**
   * Perform linear interpolation based on the current framerate.
   * @param lerp Value used to interpolate between `base` and `target`.
   *
   * @return The interpolated value.
   */
  // @:deprecated('Use smoothLerp instead')
  public static inline function cameraLerp(lerp:Float):Float
  {
    return lerp * (FlxG.elapsed / (1 / 60));
  }

  /**
   * Simple way to wrap the curSelection index variable, used in menus
   * @param curSelection Value of the current selected index.
   * @param increment Value of the number you want the index to be incremented by.
   * @param target The array or group used in the wrapping procedure.
   * @return The wrapped value.
   */
  public static inline function curSelectionWrap(curSelection, increment, target):Int
  {
    return FlxMath.wrap(curSelection + increment, 0, target.length - 1);
  }

  /**
   * Get the logarithm of a value with a given base.
   * @param base The base of the logarithm.
   * @param value The value to get the logarithm of.
   * @return `log_base(value)`
   */
  public static inline function logBase(base:Float, value:Float):Float
  {
    return Math.log(value) / Math.log(base);
  }

  public static inline function fpsLerp(v1:Float, v2:Float, ratio:Float):Float
  {
    return flixel.math.FlxMath.lerp(v1, v2, getFPSRatio(ratio));
  }

  public static inline function getFPSRatio(ratio:Float):Float
  {
    return flixel.math.FlxMath.bound(ratio * 60 * FlxG.elapsed, 0, 1);
  }

  inline public static function quantize(f:Float, interval:Float)
  {
    return Std.int((f + interval / 2) / interval) * interval;
  }

  public static function numberArray(max:Int, ?min = 0):Array<Int>
  {
    var dumbArray:Array<Int> = [];
    for (i in min...max)
      dumbArray.push(i);
    return dumbArray;
  }

  public static function truncateFloat(number:Float, precision:Int):Float
  {
    var num = number;
    num = num * Math.pow(10, precision);
    num = Math.round(num) / Math.pow(10, precision);
    return num;
  }

  public static function easeInOutCirc(x:Float):Float
  {
    if (x <= 0.0) return 0.0;
    if (x >= 1.0) return 1.0;
    var result:Float = (x < 0.5) ? (1 - Math.sqrt(1 - 4 * x * x)) / 2 : (Math.sqrt(1 - 4 * (1 - x) * (1 - x)) + 1) / 2;
    return (result == Math.NaN) ? 1.0 : result;
  }

  public static function easeInOutBack(x:Float, ?c:Float = 1.70158):Float
  {
    if (x <= 0.0) return 0.0;
    if (x >= 1.0) return 1.0;
    var result:Float = (x < 0.5) ? (2 * x * x * ((c + 1) * 2 * x - c)) / 2 : (1 - 2 * (1 - x) * (1 - x) * ((c + 1) * 2 * (1 - x) - c)) / 2;
    return (result == Math.NaN) ? 1.0 : result;
  }

  public static function easeInBack(x:Float, ?c:Float = 1.70158):Float
  {
    if (x <= 0.0) return 0.0;
    if (x >= 1.0) return 1.0;
    return (1 + c) * x * x * x - c * x * x;
  }

  public static function easeOutBack(x:Float, ?c:Float = 1.70158):Float
  {
    if (x <= 0.0) return 0.0;
    if (x >= 1.0) return 1.0;
    return 1 + (c + 1) * Math.pow(x - 1, 3) + c * Math.pow(x - 1, 2);
  }

  public static inline function addZeros(str:String, num:Int)
  {
    while (str.length < num)
      str = '0${str}';
    return str;
  }

  inline public static function GCD(a, b)
    return b == 0 ? FlxMath.absInt(a) : GCD(b, a % b);

  /**
   * Get the base-2 logarithm of a value.
   * @param x value
   * @return `2^x`
   */
  inline public static function exp2(x:Float):Float
  {
    return Math.pow(2, x);
  }

  /**
   * Linearly interpolate between two values.
   *
   * @param base The starting value, when `progress <= 0`.
   * @param target The ending value, when `progress >= 1`.
   * @param progress Value used to interpolate between `base` and `target`.
   * @return The interpolated value.
   */
  public static function lerp(base:Float, target:Float, progress:Float):Float
  {
    return base + progress * (target - base);
  }

  /**
   * Perform a framerate-independent linear interpolation between the base value and the target.
   * @param current The current value.
   * @param target The target value.
   * @param elapsed The time elapsed since the last frame.
   * @param duration The total duration of the interpolation. Nominal duration until remaining distance is less than `precision`.
   * @param precision The target precision of the interpolation. Defaults to 1% of distance remaining.
   * @see https://twitter.com/FreyaHolmer/status/1757918211679650262
   *
   * @return A value between the current value and the target value.
   */
  public static function smoothLerp(current:Float, target:Float, elapsed:Float, duration:Float, precision:Float = 1 / 100):Float
  {
    // An alternative algorithm which uses a separate half-life value:
    // var halfLife:Float = -duration / logBase(2, precision);
    // lerp(current, target, 1 - exp2(-elapsed / halfLife));

    if (current == target) return target;

    var result:Float = lerp(current, target, 1 - Math.pow(precision, elapsed / duration));

    // TODO: Is there a better way to ensure a lerp which actually reaches the target?
    // Research a framerate-independent PID lerp.
    if (Math.abs(result - target) < (precision * target)) result = target;

    return result;
  }

  inline public static function boundInt(value:Int, ?min:Int, ?max:Int):Int
  {
    final lowerBound = (min != null && value < min) ? min : value;
    return (max != null && lowerBound > max) ? max : lowerBound;
  }
}
