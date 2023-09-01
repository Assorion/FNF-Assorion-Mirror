package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import misc.Alphabet;

/*
    Just a modified
    Optionstate for controls
*/

#if !debug @:noDebug #end
class ControlsState extends MusicBeatState {
	var controlList:Array<String> = [
        'note_left',
        'note_down',
        'note_up',
        'note_right',
        '',
        'ui_l',
        'ui_d',
        'ui_u',
        'ui_r',
        '',
        'ui_accept',
        'ui_back'
    ];

	var activeTextGroup:FlxTypedGroup<Alphabet>;
    var rebinding:Bool = false;
    var dontCancel:Bool = false;
	public static var curSel:Int = 0;
    public static var curAlt:Int = 0;

	override function create()
	{
		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.lImage('ui/menuDesat'));
		menuBG.color = 0xFFea71fd;
		menuBG.antialiasing = Settings.pr.antialiasing;
		add(menuBG);

		activeTextGroup = new FlxTypedGroup<Alphabet>();
		add(activeTextGroup);

		createNewList();

		super.create();
	}

	private function quicklyAddText(str:String, p:Int){
		var opT:Alphabet = new Alphabet(0, (60 * p) + 30, str, true);
			opT.alpMult = 0.4;
			opT.alpha = 0;
			opT.lerpPos = true;
			activeTextGroup.add(opT);
	}
	public function createNewList(){
		activeTextGroup.clear();

		for(i in 0...controlList.length){
			quicklyAddText(controlList[i], i);

            var str:String = '';
            var s2r:String = '';

            if(controlList[i] != ''){
                var val:Dynamic = Reflect.field(Settings.pr, controlList[i]);
                str = misc.InputString.getKeyNameFromString(val[0], true, false);
                s2r = misc.InputString.getKeyNameFromString(val[1], true, false);
            }

			quicklyAddText(str, i);
            quicklyAddText(s2r, i);
		}
		for(i in 0...activeTextGroup.length)
			if(Math.floor(i / 2) != curSel)
				activeTextGroup.members[i].alpMult = 1;
		/////////////////////

		changeSel();
	}

    override function update(elasped:Float){
        super.update(elasped);

        if(!rebinding || !FlxG.keys.justPressed.ANY) return;
        if(dontCancel){
            dontCancel = false;
            return;
        }

        var k:Int = FlxG.keys.firstJustPressed();
        var original:Dynamic = Reflect.field(Settings.pr, controlList[curSel]);
            original[curAlt] = k;
        Reflect.setField(Settings.pr, '${controlList[curSel]}', original);

        rebinding = false;
        createNewList();

        trace(k);
    }

	override public function keyHit(ev:KeyboardEvent){
		super.keyHit(ev);

        if(rebinding) return;

		var t = key.deepCheck([NewControls.UI_U,NewControls.UI_D]);
		if(t != -1){
			changeSel((t * 2) - 1);
			return;
		}
        t = key.deepCheck([NewControls.UI_L,NewControls.UI_R]);
        if(t != -1){
			//changeAlt((t * 2) - 1);
            curAlt += (t * 2) - 1;
            curAlt = CoolUtil.boundTo(curAlt, 0, 1, true);
            changeSel(0);
			return;
		}

        if(key.hardCheck(NewControls.UI_ACCEPT)){
            if(controlList[curSel] == '')
                return;

			for(i in 0...activeTextGroup.length)
				if(Math.floor(i / 3) != curSel)
					activeTextGroup.members[i].alpMult = 0;

            dontCancel = true;
            rebinding = true;
            return;
        }

		// escapes

		if(key.hardCheck(NewControls.UI_BACK)){
			Settings.apply();
			Settings.flush();
			FlxG.sound.play(Paths.lSound('menu/cancelMenu'));
			FlxG.switchState(new OptionsState());
		}
	}

	private inline function recenterBind(grp:Alphabet, alt:Int){
		grp.screenCenter(X);
		grp.x += 150 + (300 * alt);
		grp.targetX = grp.x;
	}

	function changeSel(to:Int = 0)
	{
		FlxG.sound.play(Paths.lSound('menu/scrollMenu'), 0.4);

		curSel += to;
		curSel %= controlList.length;
		if(curSel < 0) curSel = controlList.length - 1;

		for(i in 0...Math.floor(activeTextGroup.length / 3)){
			var item = activeTextGroup.members[i * 3];
			var it2m = activeTextGroup.members[(i * 3) + 1];
            var it3m = activeTextGroup.members[(i * 3) + 2];

			it3m.alpMult = it2m.alpMult = item.alpMult = 0.4;
			if(i == curSel) {
                item.alpMult = 1;
                [it2m, it3m][curAlt].alpMult = 1;
            }

			it3m.targetY = it2m.targetY = item.targetY = (i - curSel) * 90;
			it3m.targetY = it2m.targetY = item.targetY = item.targetY + 160;
			item.targetX = (i - curSel) * 15;
			item.targetX += 30;

			recenterBind(it2m, 0);
            recenterBind(it3m, 1);
		}
	}
}
