package gameplay;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.FlxCamera;
import flixel.util.FlxColor;
import misc.CoolUtil;
import lime.utils.Assets;

using StringTools;

typedef SlideShowPoint = {
    var portrait:String;
    var side:Int;
    var flipX:Bool;
    var text:String;
}

/*
    This isn't written to well.
    I might do a re-write myself sometime.
*/

#if !debug @:noDebug #end
class DialogueSubstate extends MusicBeatSubstate {
    public var chars:Array<String> = [];
    public var curChar:Int = 0;
    public var curSlide:Int = -1;

    public var slides:Array<SlideShowPoint> = [];

    var char1  :FlxSprite;
    var char2  :FlxSprite;
    var graySpr:StaticSprite;
    var boxSpr :StaticSprite;
    var clsFnc :Void->Void;
    var pState :PlayState;
    var voicesText:FlxText;
    var camRef :FlxCamera;

    public static function crDialogue(cam:FlxCamera, close:Void->Void, dPath:String, ps:PlayState, retState:Array<DialogueSubstate>):Bool
    {
        if (PlayState.storyWeek == -1 || !Assets.exists('assets/songs-data/' + dPath) || PlayState.seenCutscene){
            PlayState.seenCutscene = true;
            return true;
        }

        retState[0] = new DialogueSubstate(cam, close, dPath, ps);
        retState[0].openCallback = function(){
            // take a look at pausesubstate pls
            CoolUtil.copyCameraToData(CoolUtil.canvas, FlxG.camera);
            retState[0].pState.persistentDraw = false;
        };

        return false;
    }

    public function new(camera:FlxCamera, closeFunc:Void->Void, dPath:String, pState:PlayState){
        super();

        CoolUtil.newCanvas();

        var gspr:StaticSprite = new StaticSprite(0,0).loadGraphic(CoolUtil.canvas);
        gspr.screenCenter();
        gspr.scrollFactor.set();
        gspr.scale.set(1 / FlxG.camera.zoom, 1 / FlxG.camera.zoom);
        add(gspr);

        graySpr = new StaticSprite(0,0).makeGraphic(FlxG.width,FlxG.height, FlxColor.GRAY);
		graySpr.screenCenter();
		graySpr.alpha = 0;

        char1 = new FlxSprite(-50,-50);
        char1.centerOffsets();
        char1.centerOrigin ();
        char2 = new FlxSprite(-50,-50);
        char2.centerOffsets();
        char2.centerOrigin ();

        boxSpr = new StaticSprite(0,0).loadGraphic(Paths.lImage('gameplay/dialoguebox'));
        boxSpr.setGraphicSize(Std.int(boxSpr.width * 4), Std.int(boxSpr.height * 1.75));
        boxSpr.updateHitbox();
        boxSpr.screenCenter();
        boxSpr.y += 230;
        boxSpr.alpha = 0;

        voicesText = new FlxText(boxSpr.x + 30, boxSpr.y + 10, 0, '', 30);
        voicesText.color = FlxColor.BLACK;

        ///////////////

        add(graySpr);
        add(char1);
        add(char2);
        add(boxSpr);
        add(voicesText);
        graySpr.cameras    =
        char1.cameras      =
        char2.cameras      =
        boxSpr.cameras     =
        voicesText.cameras = [camera];

        clsFnc = closeFunc;
        this.pState = pState;

        var lines:Array<String> = Paths.lText(dPath).split(',');
        for(i in 0...lines.length){
            var splitL:Array<String> = lines[i].split(':');

            var tSide:Int = Std.parseInt(splitL[0].trim().replace('\n', ''));
            var tFlip:Int = Std.parseInt(splitL[3].trim().replace('\n', ''));
            var tPort:String = splitL[2].trim().replace('\n', '');
            var tText:String = splitL[1].trim();

            var tmp:SlideShowPoint = {
                portrait: tPort,
                side: tSide,
                text: tText,
                flipX: tFlip == 1
            };
            slides.push(tmp);
        }

        postEvent(2.8, function(){ textSlide(); });
    }

    private var leaving:Bool = false;
    public inline function exit(){
        if(leaving) return;

        leaving = true;
        postEvent(1, function(){
            PlayState.seenCutscene = true;
            pState.paused          = false;
            pState.persistentDraw  = true;
            close();
            clsFnc();
        });
    }

    public function textSlide(){
        curSlide++;
        if(curSlide == slides.length){
            exit();
            return;
        }
        
        events = [];
        voicesText.text = '';
        chars = slides[curSlide].text.split('');

        char1.alpha = char2.alpha = 0.4;

        var charSpr:FlxSprite = [char1,char2][slides[curSlide].side];
        charSpr.loadGraphic(Paths.lImage('characters/' + slides[curSlide].portrait));
        charSpr.screenCenter();
        charSpr.x -= slides[curSlide].side != 1 ? 230 : -230;
        charSpr.alpha = 1;

        // if this isn't here the dialouge will skip the first character
        postEvent(0.2, function(){trace('huh');});

        var prevTime:Float = 0;

        for(i in 0...chars.length){
            prevTime += 0.04;
            if(chars[i] == '`'){
                prevTime += 0.4 - 0.04;
                continue;
            }

            postEvent(prevTime, function(){
                voicesText.text += chars[i];
                FlxG.sound.play(Paths.lSound('menu/pixelText'));
            });
        }
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        // yuck.
        if(leaving){
            graySpr   .alpha = CoolUtil.boundTo(graySpr   .alpha - elapsed, 0, 1);
            boxSpr    .alpha = CoolUtil.boundTo(boxSpr    .alpha - elapsed, 0, 1);
            voicesText.alpha = CoolUtil.boundTo(voicesText.alpha - elapsed, 0, 1);
            char1     .alpha = CoolUtil.boundTo(char1     .alpha -(elapsed*4), 0, 1);
            char2     .alpha = CoolUtil.boundTo(char2     .alpha -(elapsed*4), 0, 1);
            return;
        }
        if(graySpr.alpha < 0.6){
            graySpr.alpha = CoolUtil.boundTo(graySpr.alpha + (elapsed * 0.5), 0, 0.6);
            return;
        }
        if(boxSpr.alpha < 1)
            boxSpr.alpha = CoolUtil.boundTo(boxSpr.alpha + (elapsed * 2), 0, 1);
    }
    override function keyHit(ev:KeyboardEvent){
        if(leaving) 
            return;

        if(ev.keyCode.hardCheck(Binds.UI_ACCEPT) && boxSpr.alpha == 1){
            textSlide();
            FlxG.sound.play(Paths.lSound('menu/clickText'));
            return;
        }

        if(!ev.keyCode.hardCheck(Binds.UI_BACK)) 
            return;

        exit();
    }
}