package lowend.util;

import flixel.FlxG;
import flixel.group.FlxGroup;
import lime.app.Application;
import openfl.Lib;
import lime.utils.Assets;
import sys.FileSystem;
import flixel.tweens.FlxEase;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;

using StringTools;

/**
 * Utility functions, most that aren't in the OG game, can be used for scripts maybe.
 */
class CoolUtil
{
  public static function dominantColor(sprite:flixel.FlxSprite):Int
  {
    var countByColor:Map<Int, Int> = [];
    for (col in 0...sprite.frameWidth)
    {
      for (row in 0...sprite.frameHeight)
      {
        var colorOfThisPixel:Int = sprite.pixels.getPixel32(col, row);
        if (colorOfThisPixel != 0)
        {
          if (countByColor.exists(colorOfThisPixel))
          {
            countByColor[colorOfThisPixel] = countByColor[colorOfThisPixel] + 1;
          }
          else if (countByColor[colorOfThisPixel] != 13520687 - (2 * 13520687))
          {
            countByColor[colorOfThisPixel] = 1;
          }
        }
      }
    }
    var maxCount = 0;
    var maxKey:Int = 0; // after the loop this will store the max color
    countByColor[flixel.util.FlxColor.BLACK] = 0;
    for (key in countByColor.keys())
    {
      if (countByColor[key] >= maxCount)
      {
        maxCount = countByColor[key];
        maxKey = key;
      }
    }
    return maxKey;
  }

  public static function floorDecimal(value:Float, decimals:Int):Float
  {
    if (decimals < 1) return Math.floor(value);

    var tempMult:Float = 1;
    for (_ in 0...decimals)
      tempMult *= 10;

    var newValue:Float = Math.floor(value * tempMult);
    return newValue / tempMult;
  }

  /**
   * :)
   */
  public static function crash()
  {
    throw new Exception("no bitches error (690)");
  }

  public static function getLargestKeyInMap(map:Map<String, Float>):String
  {
    var largestKey:String = null;
    for (key in map.keys())
    {
      if (largestKey == null || map.get(key) > map.get(largestKey))
      {
        largestKey = key;
      }
    }
    return largestKey;
  }

  public static function isLibrary(lib:String)
  {
    return OpenFlAssets.hasLibrary(lib);
  }

  inline public static function numberArray(max:Int, ?min = 0):Array<Int>
  {
    // max+1 because in haxe for loops stop before reaching the max number
    return [
      for (n in min...max + 1)
      {
        n;
      }
    ];
  }

  inline public static function getUsername():String
  {
    #if windows
    return Sys.environment()["USERNAME"].trim();
    #elseif (linux || macos)
    return Sys.environment()["USER"].trim();
    #else
    return 'User';
    #end
  }

  static inline var markplier = 10000000;

  // The number of zeros in the following value
  // corresponds to the number of decimals rounding precision
  public static function roundFloat(underValue:Float):Float
    return Math.round(underValue * markplier) / markplier;

  public static var a1 = 0.254829592;
  public static var a2 = -0.284496736;
  public static var a3 = 1.421413741;
  public static var a4 = -1.453152027;
  public static var a5 = 1.061405429;
  public static var p = 0.3275911;

  public static function erf(x:Float):Float
  {
    // Save the sign of x
    var sign = 1;
    if (x < 0) sign = -1;
    x = Math.abs(x);

    // A&S formula 7.1.26
    var t = 1.0 / (1.0 + p * x);
    var y = 1.0 - (((((a5 * t + a4) * t) + a3) * t + a2) * t + a1) * t * Math.exp(-x * x);

    return sign * y;
  }

  // Wife3 is from Eterna Rhythm, or whatever...
  // I promise you, it's not porn! :(
  public static function wife3(maxms:Float, ts:Float)
  {
    var max_points = 1.0;
    var miss_weight = -5.5;
    var ridic = 5;
    var max_boo_weight = 180;
    var ts_pow = 0.75;
    var zero = 65 * (Math.pow(1, ts_pow));
    var power = 2.5;
    var dev = 22.7 * (Math.pow(1, ts_pow));

    if (maxms <= ridic) // anything below this (judge scaled) threshold is counted as full pts
      return max_points;
    else if (maxms <= zero) // ma/pa region, exponential
      return max_points * erf((zero - maxms) / dev);
    else if (maxms <= max_boo_weight) // cb region, linear
      return (maxms - zero) * miss_weight / (max_boo_weight - zero);
    else
      return miss_weight;
  }

  @:keep inline public static function splitFilenameFromPath(str:String):Array<String>
  {
    return [str.substr(0, str.lastIndexOf("/")), str.substr(str.lastIndexOf("/") + 1)];
  }

  public inline static function getFilenameFromPath(str:String):String
  {
    if (str.lastIndexOf("/") == -1) return str;
    return str.substr(str.lastIndexOf("/") + 1);
  }

  public inline static function removeFileFromPath(str:String):String
  {
    if (str.lastIndexOf("/") == -1) return str;
    return str.substr(0, str.lastIndexOf("/"));
  }

  @:keep inline public static function orderList(list:Array<String>):Array<String>
  {
    haxe.ds.ArraySort.sort(list, (a, b) -> (a < b ? -1 : (a > b ? 1 : 0)));

    return list;
  }

  @:keep inline public static function clearFlxGroup(obj:FlxTypedGroup<Dynamic>):FlxTypedGroup<Dynamic>
  { // Destroys all objects inside of a FlxGroup
    while (obj.members.length > 0)
    {
      var e = obj.members.pop();
      if (e != null && e.destroy != null) e.destroy();
    }
    return obj;
  }

  @:keep inline public static function multiInt(?int:Int = 0)
    return (int == 1 ? '' : 's');

  @:keep inline public static function cleanJSON(input:String):String
  { // blud cant filter a comment in jsons
    return (~/\/\*[\s\S]*?\*\/|\/\/.*/g).replace(input.trim(), '');
  }

  public static function isStringInt(s:String)
  {
    var index = 0;
    if (s.startsWith("-"))
    {
      index = 1;
    }

    var splittedString = s.split("");
    switch (splittedString[index])
    {
      case "1", "2", "3", "4", "5", "6", "7", "8", "9", "0":
        return true;
    }
    return false;
  }

  public static function stringToOgType(s:String):Dynamic
  {
    // if is integer or float
    if (isStringInt(s))
    {
      if (s.contains("."))
      {
        return Std.parseFloat(s);
      }
      else
      {
        return Std.parseInt(s);
      }
    }
    // if is a bool
    if (s == "true") return true;
    if (s == "false") return false;

    // if it is null
    if (s == "null") return null;

    // else return the original string
    return s;
  }

  public static function strToBool(s:String):Dynamic
  {
    switch (s.toLowerCase())
    {
      case "true":
        return true;
      case "false":
        return false;
      default:
        return null;
    }
  }

  public static function toBool(d):Dynamic
  {
    var s = Std.string(d);
    switch (s.toLowerCase())
    {
      case "true":
        return true;
      case "false":
        return false;
      default:
        return null;
    }
  }

  inline public static function iclamp(val:Float, min:Int, max:Int):Int
    return Math.floor(Math.max(min, Math.min(max, val)));


  inline public static function curveNumber(input:Float = 1, ?curve:Float = 10):Float
    return Math.sqrt(input) * curve;

  public static function isEmpty(d:Dynamic):Bool
  {
    if (d == "" || d == 0 || d == null || d == "0" || d == "null" || d == "empty" || d == "none")
    {
      return true;
    }
    return false;
  }

  public static function makeOutlinedGraphic(Width:Int, Height:Int, Color:Int, LineThickness:Int, OutlineColor:Int)
  {
    var rectangle = flixel.graphics.FlxGraphic.fromRectangle(Width, Height, OutlineColor, true);
    rectangle.bitmap.fillRect(new openfl.geom.Rectangle(LineThickness, LineThickness, Width - LineThickness * 2, Height - LineThickness * 2), Color);

    return rectangle;
  };

  public static function rotate(x:Float, y:Float, angle:Float, ?point:FlxPoint):FlxPoint
  {
    var p = point == null ? FlxPoint.weak() : point;
    var sin = FlxMath.fastSin(angle);
    var cos = FlxMath.fastCos(angle);
    return p.set((x * cos) - (y * sin), (x * sin) + (y * cos));
  }

  inline public static function quantizeAlpha(f:Float, interval:Float)
  {
    return Std.int((f + interval / 2) / interval) * interval;
  }

  inline public static function quantize(f:Float, snap:Float)
  {
    // changed so this actually works lol
    var m:Float = Math.fround(f * snap);
    return (m / snap);
  }

  inline public static function snap(f:Float, snap:Float)
  {
    // changed so this actually works lol
    var m:Float = Math.fround(f / snap);
    return (m * snap);
  }

  inline public static function scale(x:Float, l1:Float, h1:Float, l2:Float, h2:Float):Float
    return ((x - l1) * (h2 - l2) / (h1 - l1) + l2);
}
