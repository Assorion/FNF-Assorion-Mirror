package backend;

import flixel.FlxG;
import flixel.FlxCamera;
import lime.utils.Assets;
import openfl.geom.Matrix;
import flixel.util.FlxColor;
import openfl.geom.Rectangle;
import openfl.display.BitmapData;
import flixel.graphics.frames.FlxFramesCollection;
import gameplay.PlayState;

using StringTools;

#if !debug @:noDebug #end
class CoolUtil
{
	public static var canvas:BitmapData;

	// Change if adding a custom difficulty.
	public static inline var diffNumb:Int = 3;
	public static var diffArr:Array<String> = [
		// file names
		'easy',
		'normal',
		'hard',
		// formatted names.
		'Easy',
		'Normal',
		'Hard'
	];

	// Used for getting a difficulty value out of the array above.
	public static function diffString(diff:Int, mode:Int):String
		return diffArr[diff + (diffNumb * mode)];

	// Clamps a value to be between to other values.
	public static function boundTo(val:Float, min:Float, max:Float):Float
		return Math.min(Math.max(val, min), max);

	public static inline function intBoundTo(val:Float, min:Float, max:Float):Int
		return Math.round(boundTo(val, min, max));

	// Used for converting arrays of integers to colours.
	public inline static function cfArray(array:Array<Int>):Int
        return FlxColor.fromRGB(array[0], array[1], array[2]);

	// Copy camera to bitmap data keeping rotation and zoom.
	// TODO: Increase accuracy. Some things are still not 1 to 1.

	public static function copyCameraToData(bitmapDat:BitmapData, camera:FlxCamera){
		var matr:Matrix = new Matrix(camera.zoom, 0, 0, camera.zoom, 0, 0);
			matr.translate(-(camera.width * 0.5), -(camera.height * 0.5));
			matr.rotate   (( camera.angle * Math.PI) / 180);
			matr.translate(  camera.width * 0.5, camera.height * 0.5);
			matr.translate(((camera.width * camera.zoom) - camera.width) * -0.5, ((camera.height * camera.zoom) - camera.height) * -0.5);

		bitmapDat.draw(camera.canvas, matr, null, null, null, true);
	}

	public static function exitPlaystate(){
		MusicBeatState.changeState(PlayState.storyWeek >= 0 ? new frontend.StoryMenuState() : new frontend.FreeplayState());
	}

	public static function getKeyNameFromString(code:Int, literal:Bool = false, shiftable:Bool = true):String{
        var shifted:Bool = false;
        if(shiftable)
            shifted = FlxG.keys.pressed.SHIFT;

        switch(code){
            case -2:
                return 'ALL';
            case -1:
                return 'NONE';
            case 65:
                return 'A';
            case 66:
                return 'B';
            case 67:
                return 'C';
            case 68:
                return 'D';
            case 69:
                return 'E';
            case 70:
                return 'F';
            case 71:
                return 'G';
            case 72:
                return 'H';
            case 73:
                return 'I';
            case 74:
                return 'J';
            case 75:
                return 'K';
            case 76:
                return 'L';
            case 77:
                return 'M';
            case 78:
                return 'N';
            case 79:
                return 'O';
            case 80:
                return 'P';
            case 81:
                return 'Q';
            case 82:
                return 'R';
            case 83:
                return 'S';
            case 84:
                return 'T';
            case 85:
                return 'U';
            case 86:
                return 'V';
            case 87:
                return 'W';
            case 88:
                return 'X';
            case 89:
                return 'Y';
            case 90:
                return 'Z';

            case 48:
                if(shifted){
                    if(literal) return ')';
                    return 'CLOSED BRACKET';
                }
                    
                return '0';
            case 49:
                if(shifted){
                    if(literal) return '!';
                    return 'EXCLAIMATION';
                }

                return '1';
            case 50:
                if(shifted){
                    if(literal) return '@';
                    return 'AT SIGN';
                }
                return '2';
            case 51:
                if(shifted){
                    if(literal) return '#';
                    return 'HASHTAG';
                }
                return '3';
            case 52:
                if(shifted){
                    if(literal) return '$';
                    return 'DOLLAR SIGN';
                }
                return '4';
            case 53:
                if(shifted){
                    if(literal) return '%';
                    return 'PERCENT';
                }
                return '5';
            case 54:
                if(shifted){
                    if(literal) return '^';
                    return 'CARET';
                }
                return '6';
            case 55:
                if(shifted){
                    if(literal) return '&';
                    return 'AMPERSAND';
                }
                return '7';
            case 56:
                if(shifted){
                    if(literal) return '*';
                    return 'ASTERISK';
                }
                return '8';
            case 57:
                if(shifted){
                    if(literal) return '(';
                    return 'OPEN BRACKET';
                }
                return '9';   
                
            case 13:
                return 'ENTER';
            case 33:
                return 'PAGE UP';
            case 34:
                return 'PAGE DOWN';
            case 35:
                return 'END';
            case 36:
                return 'HOME';
            case 45:
                return 'INSERT';
            case 46:
                return 'DELETE';
            case 27:
                return 'ESCAPE';
            case 189:
                if(shifted){
                    if(literal) return '_';
                    return 'UNDERSCORE';
                }
                if(literal)
                    return '-';
                return 'MINUS';
            case 187:
                if(shifted){
                    if(literal) return '+';
                    return 'PLUS';
                }
                if(literal)
                    return '=';
                return 'EQUALS'; 
            case 8:
                return 'BACK';
            case 219:
                if(shifted){
                    if(literal) return '{';
                    return 'OPEN BRACE';
                }
                if(literal)
                    return '[';
                return 'OPEN BRACE';
            case 221:
                if(shifted){
                    if(literal) return '}';
                    return 'CLOSED BRACE';
                }
                if(literal)
                    return ']';
                return 'CLOSED BRACE';
            case 220:
                return '\\';
            case 222:
                if(shifted){
                    if(literal) return '"';
                    return "QUOTE";
                }
                if(literal)
                    return "'";
                return "APOSTROPHE";
            case 188:
                if(shifted)
                    return '<';
                return ',';
            case 191:
                if(shifted)
                    return '?';
                return '/';
            case 18:
                return 'ALT';
            case 17:
                return 'CONTROL';
            case 190:
                if(shifted)
                    return '>';
                return '.';
            case 16:
                return 'SHIFT';
            case 32:
                if(literal)
                    return ' ';
                return 'SPACE';
            case 37:
                return 'LEFT';
            case 40:
                return 'DOWN';
            case 38:
                return 'UP';
            case 39:
                return 'RIGHT';
            case 186:
                if(shifted){
                    if(literal) return ':';
                    return 'COLON';
                }
                if(literal)
                    return ';';
                return 'SEMICOLON';
        }

        trace('Couldn\'t find the character');
        return 'UNKNOWN';
    }
}
