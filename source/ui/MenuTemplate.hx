package ui;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.FlxBasic;
import flixel.FlxG;
import gameplay.HealthIcon;
import flixel.FlxObject;

/*
    A helper class that others can inherit from.
    Like freeplay or optionsstate.
*/

typedef MenuObject = {
	var obj:FlxSprite;
	var targetX:Int;
	var targetY:Int;
	var targetA:Float;
}

class MenuTemplate extends MusicBeatState {
    public var curSel:Int = 0;
    public var curAlt:Int = 0;

    var objGroup:FlxTypedGroup<FlxSprite>;
    var arrIcons:FlxTypedGroup<HealthIcon>;
    var arrGroup:Array<MenuObject> = [];

    public var background:StaticSprite;
    public var splitNumb:Int = 1;
    public var adds:Array<Int> = [400];

    var camFollow:FlxObject;

    override function create(){
        background = new StaticSprite(0,0).loadGraphic(Paths.lImage('ui/menuDesat'));
		background.antialiasing = Settings.pr.antialiasing;
        background.scale.set(1.1, 1.1);
        background.screenCenter();
        background.scrollFactor.set(0, 0.5);
        add(background);

        objGroup = new FlxTypedGroup<FlxSprite>();
        arrIcons = new FlxTypedGroup<HealthIcon>();
        add(objGroup);
        add(arrIcons);

        camFollow = new FlxObject(0,0,1,1);
        alignCamera = true;
        FlxG.camera.follow(camFollow, null, 0.06);

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
            targetA: 0.4
        };

        arrGroup.push(cr);
        cr.obj.alpha = 0.4;
        cr.obj.scrollFactor.set();
        cr.targetA = 0.4;
        objGroup.add(cr.obj);
        objNumb++;
    }
    public inline function pushIcon(icn:HealthIcon){
        arrIcons.add(icn);
        icn.scale.set(0.85, 0.85);
    }

    // so basically cause of the background scrolling effect, 
    // every object added needs it's scrollfactor set to 0
    public inline function sAdd(crap:FlxBasic){
        add(crap);

        var scrap:FlxSprite = cast crap;
        if(scrap == null) return;

        scrap.scrollFactor.set();
    }

    public function changeSelection(to:Int = 0){
        FlxG.sound.play(Paths.lSound('menu/scrollMenu'));

        var loopNum = Math.floor(arrGroup.length / splitNumb);
        curSel += to + loopNum;
		curSel %= loopNum;

        for(i in 0...Math.floor(arrGroup.length / splitNumb)){
            var item = arrGroup[i * splitNumb];

            item.targetX = (i - curSel) * 20;
            item.targetX += 60;
            item.targetY = (i - curSel) * 110;
            item.targetY += 110;
            item.targetA = i == curSel ? 1 : 0.4;

            if(splitNumb <= 1) continue;

            for(x in 1...splitNumb){
                var m1a = arrGroup[(i * splitNumb) + x];
                var m2g = objGroup.members[(i * splitNumb) + x];
                m2g.screenCenter(X);
                m2g.x += adds[x - 1];
                
                m1a.targetY = item.targetY;
                m1a.targetX = Math.round(m2g.x);
                m1a.targetA = i == curSel && x - 1 == curAlt ? 1 : 0.4;
            }
        }

        camFollow.y = (curSel / loopNum) * 80;
        camFollow.y += 320;
    }

    // Will mostly likely not need changing for a lot of states.
    public function exitFunc(){
        if(leaving){
            skipTrans();
            return;
        }

        leaving = true;
        FlxG.switchState(new MainMenuState());
        FlxG.sound.play(Paths.lSound('menu/cancelMenu'));
    }

    // you can override this with something more useful.
    public function altChange(change:Int = 0){
        if(splitNumb <= 2) return;

        curAlt += change;
        curAlt += splitNumb - 1;
        curAlt %= splitNumb - 1;
        changeSelection(0);
    } 

    // # Input code

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
        for(i in 0...Std.int(arrGroup.length / splitNumb))
            for(x in 0...splitNumb){
                var m2g = objGroup.members[(i * splitNumb) + x];
                var m1a = arrGroup[(i * splitNumb) + x];
                m2g.alpha = FlxMath.lerp(m2g.alpha, m1a.targetA, lerpVal);
                m2g.y     = FlxMath.lerp(m2g.y    , m1a.targetY, lerpVal);
                m2g.x     = FlxMath.lerp(m2g.x    , m1a.targetX, lerpVal);

                var icn:HealthIcon = arrIcons.members[i * splitNumb];

                if(x > 1 || icn == null) continue;

                icn.x = m2g.width + m2g.x;
                icn.y = m2g.y;
                icn.y += (m2g.height / 2) - (icn.height / 2);
                icn.alpha = m2g.alpha;
            }

        super.update(elapsed);
    }

    // # Remove every object and reset.

    public function clearEverything(){
        objGroup.clear();
        arrIcons.clear();
        arrGroup = [];

        objNumb = 0;
    }
}