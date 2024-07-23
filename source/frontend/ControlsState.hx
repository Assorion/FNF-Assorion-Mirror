package frontend;

import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.group.FlxGroup.FlxTypedGroup;
import backend.MenuTemplate;
import backend.NewTransition;

/*
    Just a modified -
    Optionstate for controls
*/

#if !debug @:noDebug #end
class ControlsState extends MenuTemplate {
	var controlList:Array<String> = [
        'NOTE_LEFT',
        'NOTE_DOWN',
        'NOTE_UP',
        'NOTE_RIGHT',
        '',
        'UI_LEFT',
        'UI_DOWN',
        'UI_UP',
        'UI_RIGHT',
        '',
        'UI_ACCEPT',
        'UI_BACK'
    ];
    var rebinding:Bool = false;

	override function create()
	{
        addBG(FlxColor.fromRGB(0,255,110));
        columns = 3;
		super.create();

		createNewList();
	}

	public function createNewList(){
		clearEverything();

		for(i in 0...controlList.length){
			pushObject(new Alphabet(0, MenuTemplate.yOffset+20, controlList[i], true));

            var str:String = '';
            var s2r:String = '';

            if(controlList[i] != ''){
                var val:Dynamic = Reflect.field(Binds, controlList[i]);
                str = CoolUtil.getKeyNameFromString(val[0], false, false);
                s2r = CoolUtil.getKeyNameFromString(val[1], false, false);
            }

			pushObject(new Alphabet(0, MenuTemplate.yOffset+20, str, true));
			pushObject(new Alphabet(0, MenuTemplate.yOffset+20, s2r, true));
		}

		changeSelection();
	}

	override public function exitFunc(){
		if(NewTransition.skip())
            return;

        MusicBeatState.changeState(new OptionsState());
	}

    // Skip blank space
	override public function changeSelection(to:Int = 0){
		if(curSel + to >= 0 && controlList[curSel + to] == '')
			to *= 2;

		super.changeSelection(to);
	}

	override public function keyHit(ev:KeyboardEvent){
		if(rebinding){ 
            var original:Dynamic = Reflect.field(Binds, controlList[curSel]);
                original[curAlt] = ev.keyCode;
            Reflect.setField(Binds, '${controlList[curSel]}', original);

            rebinding = false;
            createNewList();
            return;
        }

        super.keyHit(ev);

		if(ev.keyCode.hardCheck(Binds.UI_ACCEPT) && controlList[curSel] != ''){
            for(i in 0...arrGroup.length)
                if(Math.floor(i / columns) != curSel)
                    arrGroup[i].targetA = 0;

            rebinding = true;
        }
	}
}
