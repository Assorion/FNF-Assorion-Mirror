package ui;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.FlxBasic;
import flixel.FlxG;
import gameplay.HealthIcon;

/*
    A helper class that others can inherit from.
    Like freeplay or optionsstate.
*/

class MenuTemplate extends MusicBeatState {
    public var curSel:Int = 0;
    public var curAlt:Int = 0;

    var objGroup:Array<MenuObject> = [];
    var arrIcons:Array<HealthIcon> = [];

    var background:FlxSprite;
    var splitNumb:Int = 1;
    var adds:Array<Int> = [];

    override function create(){
        background = new FlxSprite(0,0).loadGraphic(Paths.lImage('ui/menuDesat'));
		//background.color = FlxColor.fromRGB(145, 113, 255);
		background.antialiasing = Settings.pr.antialiasing;
        background.screenCenter();

        add(background);

        super.create();
        postEvent(0, ()->{
            changeSelection(0);
        });
    }

    private var objNumb:Int = 0;
    public inline function pushObject(spr:FlxBasic){
        var cr:MenuObject = {
            obj: cast spr,
            targetX: 60 + (objNumb * 30),
            targetY: Math.round((110 + (objNumb * 110)) / splitNumb),
            //targetX: 0,
            //targetY: 0,
            targetA: 0.4
        };

        cr.obj.alpha = 0.4;

        objGroup.push(cr);
        add(spr);
        objNumb++;
    }
    public inline function pushIcon(icn:HealthIcon){
        arrIcons.push(icn);
        icn.scale.set(0.85, 0.85);
        add(icn);
    }

    public function changeSelection(to:Int = 0){
        FlxG.sound.play(Paths.lSound('menu/scrollMenu'));

        var loopNum = Math.floor(objGroup.length / splitNumb);
        curSel += to + loopNum;
		curSel %= loopNum;

        for(i in 0...Math.floor(objGroup.length / splitNumb)){
            var item = objGroup[i * splitNumb];

            item.targetX = (i - curSel) * 20;
            item.targetX += 60;
            item.targetY = (i - curSel) * 110;
            item.targetY += 110;
            item.targetA = i == curSel ? 1 : 0.4;

            if(splitNumb <= 1) continue;

            for(x in 1...splitNumb){
                var mem = objGroup[(i * splitNumb) + x];
                mem.obj.screenCenter(X);
                mem.obj.x += adds[x - 1];
                
                mem.targetY = item.targetY;
                mem.targetX = Math.round(mem.obj.x);
                mem.targetA = i == curSel && x - 1 == curAlt ? 1 : 0.4;
            }
        }
    }

    public function exitFunc(){
        if(leaving){
            skipTrans();
            return;
        }

        leaving = true;
        FlxG.switchState(new MainMenuState());
        FlxG.sound.play(Paths.lSound('menu/cancelMenu'));
    }

    public function altChange(change:Int = 0){
        if(splitNumb <= 2) return;

        curAlt += change;
        curAlt += splitNumb - 1;
        curAlt %= splitNumb - 1;
        changeSelection(0);
    } 

    private var leaving:Bool = false;
    override function keyHit(ev:KeyboardEvent){
        super.keyHit(ev);

        var button = key.deepCheck([NewControls.UI_U, NewControls.UI_D, NewControls.UI_L, NewControls.UI_R, NewControls.UI_BACK]);
        if(button == -1) return;

        switch(button){
            case 0, 1:
                changeSelection((button * 2) - 1);
                return;
            case 2, 3:
                altChange(((button - 2) * 2) - 1);
                return;
            case 4:
                exitFunc();
                return;
        }
    }

    override function update(elapsed:Float){
        var lerpVal = 1 - Math.pow(0.5, elapsed * 15);
        for(i in 0...Std.int(objGroup.length / splitNumb))
            for(x in 0...splitNumb){
                var mem = objGroup[(i * splitNumb) + x];
                mem.obj.alpha = FlxMath.lerp(mem.obj.alpha, mem.targetA, lerpVal);
                mem.obj.y     = FlxMath.lerp(mem.obj.y, mem.targetY, lerpVal);
                mem.obj.x     = FlxMath.lerp(mem.obj.x, mem.targetX, lerpVal);

                var icn:HealthIcon = arrIcons[i * splitNumb];

                if(x > 1 || icn == null) continue;

                icn.x = mem.obj.width + mem.obj.x;
                icn.y = mem.obj.y;
                icn.y += (mem.obj.height / 2) - (icn.height / 2);
                icn.alpha = mem.obj.alpha;
            }

        super.update(elapsed);
    }

    public function clearEverything(){
        for(i in 0...objGroup.length){
            objGroup[i].obj.destroy();
            remove(objGroup[i].obj);
        }
        for(i in 0...arrIcons.length){
            arrIcons[i].destroy();
            remove(arrIcons[i]);
        }

        objGroup = [];
        arrIcons = [];
        objNumb = 0;
    }
}