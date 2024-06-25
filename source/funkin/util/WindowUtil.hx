package funkin.util;

import flixel.util.FlxSignal.FlxTypedSignal;
import funkin.util.tools.Windows;
import lime.app.Application;

using StringTools;

/**
 * Utilities for operating on the current window, such as changing the title.
 */
#if (cpp && windows)
@:cppFileCode('
#include <iostream>
#include <windows.h>
#include <psapi.h>
')
#end
class WindowUtil
{
  /**
   * Gets the specified file's (or folder) attribute.
   */
  public static function getFileAttribute(path:String, useAbsol:Bool = true):FileAttribute
  {
    #if windows
    if (useAbsol) path = sys.FileSystem.absolutePath(path);
    return WindowUtil.getFileAttribute(path);
    #else
    return NORMAL;
    #end
  }

  /**
   * Sets the specified file's (or folder) attribute. If it fails, the return value is `0`.
   */
  public static function setFileAttribute(path:String, attrib:FileAttribute, useAbsol:Bool = true):Int
  {
    #if windows
    if (useAbsol) path = sys.FileSystem.absolutePath(path);
    return WindowUtil.setFileAttribute(path, attrib);
    #else
    return 0;
    #end
  }


  /**
   * Runs platform-specific code to open a URL in a web browser.
   * @param targetUrl The URL to open.
   */
  public static function openURL(targetUrl:String):Void
  {
    #if CAN_OPEN_LINKS
    #if linux
    Sys.command('/usr/bin/xdg-open $targetUrl &');
    #else
    // This should work on Windows and HTML5.
    FlxG.openURL(targetUrl);
    #end
    #else
    throw 'Cannot open URLs on this platform.';
    #end
  }

  /**
   * Runs platform-specific code to open a path in the file explorer.
   * @param targetPath The path to open.
   */
  public static function openFolder(targetPath:String):Void
  {
    #if CAN_OPEN_LINKS
    #if windows
    Sys.command('explorer', [targetPath.replace('/', '\\')]);
    #elseif mac
    Sys.command('open', [targetPath]);
    #elseif linux
    Sys.command('open', [targetPath]);
    #end
    #else
    throw 'Cannot open URLs on this platform.';
    #end
  }

  /**
   * Runs platform-specific code to open a file explorer and select a specific file.
   * @param targetPath The path of the file to select.
   */
  public static function openSelectFile(targetPath:String):Void
  {
    #if CAN_OPEN_LINKS
    #if windows
    Sys.command('explorer', ['/select,' + targetPath.replace('/', '\\')]);
    #elseif mac
    Sys.command('open', ['-R', targetPath]);
    #elseif linux
    // TODO: unsure of the linux equivalent to opening a folder and then "selecting" a file.
    Sys.command('open', [targetPath]);
    #end
    #else
    throw 'Cannot open URLs on this platform.';
    #end
  }

  /**
   * Dispatched when the game window is closed.
   */
  public static final windowExit:FlxTypedSignal<Int->Void> = new FlxTypedSignal<Int->Void>();

  /**
   * Wires up FlxSignals that happen based on window activity.
   * For example, we can run a callback when the window is closed.
   */
  public static function initWindowEvents():Void
  {
    // onUpdate is called every frame just before rendering.

    // onExit is called when the game window is closed.
    openfl.Lib.current.stage.application.onExit.add(function(exitCode:Int) {
      windowExit.dispatch(exitCode);
    });

    openfl.Lib.current.stage.addEventListener(openfl.events.KeyboardEvent.KEY_DOWN, (e:openfl.events.KeyboardEvent) -> {
      for (key in PlayerSettings.player1.controls.getKeysForAction(WINDOW_FULLSCREEN))
      {
        if (e.keyCode == key)
        {
          openfl.Lib.application.window.fullscreen = !openfl.Lib.application.window.fullscreen;
        }
      }
    });
  }

  /**
   * Turns off that annoying "Report to Microsoft" dialog that pops up when the game crashes.
   */
  public static function disableCrashHandler():Void
  {
    #if (cpp && windows)
    untyped __cpp__('SetErrorMode(SEM_FAILCRITICALERRORS | SEM_NOGPFAULTERRORBOX);');
    #else
    // Do nothing.
    #end
  }

  /**
   * Sets the title of the application window.
   * @param value The title to use.
   */
  public static function setWindowTitle(value:String):Void
  {
    lime.app.Application.current.window.title = value;
  }
}

enum abstract FileAttribute(Int)
{
  // Settables
  var ARCHIVE = 0x20;
  var HIDDEN = 0x2;
  var NORMAL = 0x80;
  var NOT_CONTENT_INDEXED = 0x2000;
  var OFFLINE = 0x1000;
  var READONLY = 0x1;
  var SYSTEM = 0x4;
  var TEMPORARY = 0x100;

  // Non Settables
  var COMPRESSED = 0x800;
  var DEVICE = 0x40;
  var DIRECTORY = 0x10;
  var ENCRYPTED = 0x4000;
  var REPARSE_POINT = 0x400;
  var SPARSE_FILE = 0x200;
}
