package ui;

import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import openfl.display.BitmapData;
import openfl.events.KeyboardEvent;
import openfl.geom.Rectangle;
import openfl.events.MouseEvent;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.FlxCamera;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import gameplay.Note;
import gameplay.PlayState;
import misc.Song;
import ui.CustomChartUI;
#if desktop
import sys.io.File;
#end
import gameplay.HealthIcon;
import flixel.tweens.FlxTween;

using StringTools;

#if !debug @:noDebug #end
class ChartingState extends MusicBeatState {
    public static var uiColours:Array<Array<Int>> = [
        [155, 100, 160], // dark
        [200, 120, 210], // light
        [240, 150, 250], // 3d light
        [170, 170, 200], // note select colour
        [0,   40,  8  ], // swamp green background colour
    ];
    public static var gridColours:Array<Array<Array<Int>>> = [
        [[255, 200, 200], [255, 215, 215]], // Red
        [[200, 200, 255], [215, 215, 255]], // Blue
        [[240, 240, 200], [240, 240, 215]], // Yellow / White
        [[200, 255, 200], [215, 255, 215]], // Green
    ];
    public static inline var gridSize:Int = 40;

    public static var zooms:Array<Float> = [0.5, 0.75, 1, 1.5, 2, 3, 4, 6, 8];
    public var curZoom:Int = 2;

    public var selectedNotes:Array<Array<Dynamic>> = [];
    public static var curNoteType:Int = 0;

    var gridLayer:FlxTypedGroup<StaticSprite>;
    var noteHighlight:StaticSprite;
    var blueSelectBox:StaticSprite;

    public var curSec:Int = 0;
    public var musicLine:StaticSprite;

    public var notes:FlxTypedGroup<Note>;
    public var uiElements:FlxTypedSpriteGroup<ChartUI_Generic>;

    public var camUI:FlxCamera;
    public var camGR:FlxCamera;

    public static var activeUIElement:ChartUI_Generic;
    public static var inputBlock:ChartUI_Persistent;
    public var currentUI:Void->Void;

    var uiBG:ChartUI_Generic;

    private var vocals:FlxSound;
    private var song:SwagSong;

    override public function create(){
        if(FlxG.sound.music.playing){
            FlxG.sound.music.pause();
            FlxG.sound.music.time = 0;
            FlxG.sound.music.onComplete = function(){
                FlxG.sound.music.pause();
                FlxG.sound.music.time = 0;
            };
        }
        song = PlayState.SONG;

        // # cam code

        camUI = new FlxCamera();
        camGR = new FlxCamera(100,50, 0, 0);
        camGR.bgColor.alpha = camUI.bgColor.alpha = 0;

        FlxG.cameras.reset(camUI);
		FlxG.cameras.add(camGR);
		FlxCamera.defaultCameras = [camUI];

        // # create bg

        var bgspr:StaticSprite = new StaticSprite(0,0).loadGraphic(Paths.lImage('ui/menuDesat'));
            bgspr.screenCenter();
            bgspr.color = CoolUtil.cfArray(uiColours[4]);
        add(bgspr);

        // # create grid

        gridLayer = new FlxTypedGroup<StaticSprite>();
        noteHighlight = new StaticSprite(0,0).makeGraphic(gridSize, gridSize, 0xFFFFFFFF);
        add(gridLayer);
        add(noteHighlight);

        // # UI

        uiBG = new ChartUI_Generic(camGR.x + camGR.width + 25, 0, 520, 600, false, '');
        uiBG.drawSquare(0,   0, 410, 600);
        uiBG.drawSquare(410, 0, 110, 600);
        uiBG.screenCenter(Y);
        uiElements = new FlxTypedSpriteGroup<ChartUI_Generic>();
        uiElements.y = uiBG.y + 10;

        add(uiBG);
        add(uiElements);

        tabButtons.push(new ChartUI_Button(400, uiBG.y    , 110, 30, createSongUI, 'SONG'));
        tabButtons.push(new ChartUI_Button(400, uiBG.y+30 , 110, 30, createTestUI, 'TEST'));
        tabButtons.push(new ChartUI_Button(400, uiBG.y+570, 110, 30, createInfoUI, 'HELP'));

        createSongUI();

        // # create line and notes

        makeGrid();

        notes     = new FlxTypedGroup<Note>();
        musicLine = new StaticSprite(0, 0).makeGraphic(960, 4, 0xFFFFFFFF);
        add(notes);
        add(musicLine);

        noteHighlight.cameras =
        gridLayer.cameras =
        notes    .cameras =
        musicLine.cameras = [camGR];

        // # Creates vocals.

        vocals = new FlxSound();
		if (song.needsVoices)
			vocals.loadEmbedded(Paths.playableSong(PlayState.curSong, true));

        vocals.time = 0;
		FlxG.sound.list.add(vocals);
        FlxG.mouse.visible = true;

        reloadNotes();

        // # Create Selection box

        blueSelectBox = new StaticSprite(-1,-1).makeGraphic(1,1, FlxColor.fromRGB(140,225,255));
		blueSelectBox.origin.set(0,0);
		blueSelectBox.alpha = 0.55;
        blueSelectBox.cameras = [camGR];
		add(blueSelectBox);

        correctMusic = false;

        FlxG.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveEvent);
        FlxG.stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownEvent);
        FlxG.stage.addEventListener(MouseEvent.MOUSE_UP  , mouseUpEvent);

        super.create();
    }

    public inline function pauseSong(){
        FlxG.sound.music.pause();
        vocals.pause();
    }
    public inline function changeSec(changeTo:Int){
        curSec = CoolUtil.boundTo(changeTo, 0, song.notes.length + 1);
        expandCheck();
        reloadNotes();
        currentUI();
    }

    // for changing zoom level
    public function makeGrid(){
        var gridSprite:StaticSprite = new ChartUI_Grid(gridSize, gridSize, Note.keyCount * (song.playLength), Math.floor(16 * zooms[curZoom]), (curZoom + 1) % 2 + 3);

        gridLayer.clear();
        gridLayer.add(gridSprite);

        for(i in 0...song.playLength){
            if(song.characters.length - 1 < i) break;

            var tmpIcon = new HealthIcon(song.characters[i]);
            tmpIcon.x = gridSize * i * Note.keyCount + gridSize;
            tmpIcon.y = gridSprite.height + 10;
            tmpIcon.scale.set(0.5, 0.5);
            tmpIcon.updateHitbox();

            gridLayer.add(tmpIcon);
        }

        camGR.width  = Math.round(gridSprite.width);
        camGR.height = Math.round(gridSprite.height + 85);

        uiBG.x = camGR.width + camGR.x + 25;
        uiElements.x = uiBG.x + 10;
    }

    // # Keyboard input

    private var holdingControl:Bool = false;
    private var holdingShift:Bool   = false;
    override function keyHit(ev:KeyboardEvent){
        super.keyHit(ev);

        if(inputBlock != null) {
            if(key == FlxKey.ENTER){
                inputBlock.clickedOff();
                return;
            }

            inputBlock.insertChar(key);
            return;
        }

        if(key == FlxKey.SHIFT){
            holdingShift = true;
            return;
        }

        // ONLY FOR CONTROL. READ AHEAD!

        if(holdingControl){
            var T:Int = key.deepCheck([
                [FlxKey.J],
                [FlxKey.L],
                [FlxKey.I],
                [FlxKey.K],

                [FlxKey.C],
                [FlxKey.V],
                [FlxKey.A]
            ]);

            switch(T){
                case 0:
                    for(nt in selectedNotes){
                        nt[1]--;
                        if (nt[1] < 0) {
                            nt[1] = Note.keyCount - 1;
                            nt[3] = ((nt[3] - 1) + song.playLength) % song.playLength;
                        }
                    }
                case 1:
                    for(nt in selectedNotes){
                        nt[1]++;
                        if (nt[1] > Note.keyCount - 1){
                            nt[1] = 0;
                            nt[3] = (nt[3] + 1) % song.playLength;
                        }
                    }
                case 2:
                    for(nt in selectedNotes){
                        song.notes[Math.floor(nt[0] / 16)].sectionNotes.remove(nt);
                        nt[0]--;
                        if(nt[0] < 0) nt[0] = 0;
                        song.notes[Math.floor(nt[0] / 16)].sectionNotes.push(nt);
                    }
                case 3:
                    for(nt in selectedNotes){
                        song.notes[Math.floor(nt[0] / 16)].sectionNotes.remove(nt);
                        nt[0]++;
                        song.notes[Math.floor(nt[0] / 16)].sectionNotes.push(nt);
                    }
                // other stuff
                case 4:
                    var dupeNotes:Array<Array<Dynamic>> = [];
                    for(nt in selectedNotes){
                        var dupe = [nt[0], nt[1], nt[2], nt[3]];
                        dupeNotes.push(dupe);
                        song.notes[Math.floor(nt[0] / 16)].sectionNotes.push(dupe);
                    }
                    selectedNotes = dupeNotes;
                case 5:
                    for(nt in selectedNotes)
                        nt[1] = (Note.keyCount - 1) - nt[1];
                
                case 6:
                    selectedNotes = [];
                    for(nt in song.notes[curSec].sectionNotes)
                        selectedNotes.push(nt);
            }
            if(T >= 0)
                reloadNotes();

            return;
        }

        var T:Int = key.deepCheck([ 
            Binds.UI_BACK, 
            Binds.UI_ACCEPT, 
            [FlxKey.SPACE],
            Binds.UI_L, 
            Binds.UI_R, 
            [FlxKey.B],
            [FlxKey.N], 
            [FlxKey.Q],
            [FlxKey.E],
            [FlxKey.X],
            [FlxKey.Z],
            [FlxKey.CONTROL]
        ]);

        switch(T){
            case 0, 1:
                FlxG.mouse.visible = false;
                MusicBeatState.changeState(new PlayState());

                FlxG.stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveEvent);
                FlxG.stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownEvent);
                FlxG.stage.removeEventListener(MouseEvent.MOUSE_UP  , mouseUpEvent);

                inputBlock = null;
                activeUIElement = null; 

                PlayState.SONG = song;
            case 2:
                if(FlxG.sound.music.playing)
                    pauseSong();
                else {
                    FlxG.sound.music.play();

                    vocals.play();
                    vocals.time = FlxG.sound.music.time;
                }
                return;
            case 3, 4:
                pauseSong();
                changeSec(curSec + (((T - 3) * 2) - 1));

                var offTime = curSec * Conductor.crochet * 4;
                    offTime += Settings.pr.audio_offset;

                // this is to make sure there are no trashy rounding errors.
                while(Math.floor((offTime + Settings.pr.audio_offset) / (Conductor.crochet * 4)) < curSec)
                    offTime += 0.01;

                Conductor.songPosition = vocals.time = FlxG.sound.music.time = offTime;
                Conductor.songPosition -= Settings.pr.audio_offset;

                expandCheck();
                reloadNotes();
                return;
            case 5, 6:
                curNoteType += ((T - 5) * 2) - 1;
                curNoteType = CoolUtil.boundTo(curNoteType, 0, Note.possibleTypes.length - 1);

                for(nt in selectedNotes)
                    nt[4] = curNoteType;

                reloadNotes();
                return;
            case 7, 8:
                for(nt in selectedNotes)
                    nt[2] = CoolUtil.boundTo(nt[2] + ((T - 7) * 2 - 1), 0, 1000);
    
                reloadNotes();
                return;
            case 9, 10:
                curZoom += ((T - 9) * 2) - 1;
                curZoom = CoolUtil.boundTo(curZoom, 0, 8);

                makeGrid();
                reloadNotes();

                return;
            case 11:
                holdingControl = true;
        }
    }
    override public function keyRel(ev:KeyboardEvent){
        super.keyRel(ev);

        if(key == FlxKey.CONTROL)
            holdingControl = false;

        if(key == FlxKey.SHIFT)
            holdingShift = false;
    }

    // # Note rendering code.

    public inline function reloadNotes(){
        notes.clear();
        for(newnote in song.notes[curSec].sectionNotes){
            var daNote = new Note(newnote[0], newnote[1], newnote[4]);
            daNote.setGraphicSize(gridSize, gridSize);
            daNote.updateHitbox();
            daNote.x  = gridSize * daNote.noteData;
            daNote.x += gridSize * Note.keyCount * newnote[3];
            daNote.y  = (daNote.strumTime - (curSec * 16)) * zooms[curZoom] * gridSize;
            daNote.player = newnote[3];

            if(selectedNotes.contains(newnote)) 
                daNote.color = CoolUtil.cfArray(uiColours[3]);
            
            notes.add(daNote);

            for(i in 1...Math.floor((newnote[2] * zooms[curZoom]) + 1)){
                var susNote = new Note(newnote[0] + (i / zooms[curZoom]), newnote[1], newnote[4], true, i == Math.floor(newnote[2]*zooms[curZoom]));
                if(Settings.pr.downscroll)
                    susNote.flipY = false;

                susNote.setGraphicSize(Std.int(gridSize / 2.5), gridSize);
                susNote.updateHitbox();
                susNote.x = daNote.x;
                susNote.y = (susNote.strumTime - (curSec * 16)) * zooms[curZoom] * gridSize;

                susNote.x += (gridSize / 2) - (susNote.width / 2);

                notes.add(susNote);
            }
        }
    }

    // # Note functions

    public function delNote(nn:Array<Dynamic>):Bool {
        for(findNote in song.notes[curSec].sectionNotes)
            if(Math.abs(findNote[0] - nn[0]) < 1 / zooms[curZoom]
            && findNote[3] == nn[3] && findNote[1] == nn[1]){
                song.notes[curSec].sectionNotes.remove(findNote);
                reloadNotes();

                return true;
            }
        return false;
    }
    public function addNote(x:Int, y:Int){
        var newnote:Array<Dynamic> = [
            (Math.floor(y / gridSize) / zooms[curZoom]) + (curSec * 16),
            Math.floor(x / gridSize) % Note.keyCount,
            0,
            Math.floor(x / (gridSize * Note.keyCount)),
            curNoteType
        ];

        if(FlxG.mouse.x > camGR.x + camGR.width || delNote(newnote)) return;

        song.notes[curSec].sectionNotes.push(newnote);
        selectedNotes = [newnote];

        reloadNotes();
    }

    // # Mouse Events.

    var mouseHookX:Int = -1;
    var mouseHookY:Int = -1;

    public function mouseMoveEvent(ev:MouseEvent){
        noteHighlight.x = CoolUtil.boundTo(Math.floor((FlxG.mouse.x - camGR.x) / gridSize), 0, (song.playLength * Note.keyCount) - 1) * gridSize;
        noteHighlight.y = CoolUtil.boundTo(Math.floor((FlxG.mouse.y - camGR.y) / gridSize), 0, Math.floor(16 * zooms[curZoom]) - 1) * gridSize;

        // # Ui stuff

        if(FlxG.mouse.x >= uiBG.x){
            var foundMember:Bool = false;

            for(i in 0...uiElements.length){
                var member = uiElements.members[(uiElements.length - 1) - i];
                if(member == null) 
                    continue;

                if (FlxG.mouse.x < member.x || FlxG.mouse.y < member.y ||
                    FlxG.mouse.x >= member.x + member.width  ||
                    FlxG.mouse.y >= member.y + member.height || foundMember){
                    member.color = 0xFFFFFFFF;
                    continue;
                }

                foundMember = true;

                if (activeUIElement == member) 
                    continue;

                activeUIElement = member;
                member.color = 0xFFE5E5E5;
                member.mouseOverlaps();
            }
            if(!foundMember)
                activeUIElement = null;

            return;
        }

        // # Selecting

        if(!holdingControl || mouseHookX == -1) return;

        var fakeX = FlxG.mouse.x - camGR.x;
        var fakeY = FlxG.mouse.y - camGR.y;
        if(fakeX < mouseHookX) blueSelectBox.x = fakeX;
        if(fakeY < mouseHookY) blueSelectBox.y = fakeY;

        blueSelectBox.scale.x = fakeX - mouseHookX;
        blueSelectBox.scale.y = fakeY - mouseHookY;
        blueSelectBox.updateHitbox();

        if(!holdingShift)
            selectedNotes = [];

        var relativeNote:Note = null;
        for(ppNote in song.notes[curSec].sectionNotes){
            notes.forEachAlive(function(daNote:Note){
                if (ppNote[0] != daNote.strumTime || daNote.isSustainNote ||
                    ppNote[1] != daNote.noteData  || ppNote[3] != daNote.player)
                    return;
                
                relativeNote = daNote;
            });
            relativeNote.color = 0xFFFFFFFF;

            if(selectedNotes.contains(ppNote)) {
                relativeNote.color = CoolUtil.cfArray(uiColours[3]);
                continue;
            }
            if (relativeNote.x < blueSelectBox.x || relativeNote.x + gridSize >= blueSelectBox.x + blueSelectBox.width ||
                relativeNote.y < blueSelectBox.y || relativeNote.y + gridSize >= blueSelectBox.y + blueSelectBox.height)
                continue;

            selectedNotes.push(ppNote);
            relativeNote.color = CoolUtil.cfArray(uiColours[3]);
        }
    }
    public function mouseDownEvent(ev:MouseEvent){
        if(activeUIElement != null){
            activeUIElement.mouseClicked();
            return;
        }
        if (inputBlock != null){
            inputBlock.clickedOff();
            return;
        }
        ////////////////////

        if(!holdingControl){
            addNote(Math.round(noteHighlight.x), Math.round(noteHighlight.y));
            return;
        }

        blueSelectBox.x = mouseHookX = Math.floor(FlxG.mouse.x - camGR.x);
        blueSelectBox.y = mouseHookY = Math.floor(FlxG.mouse.y - camGR.y);
    }
    public function mouseUpEvent(ev:MouseEvent){
        blueSelectBox.x = blueSelectBox.y = 
        mouseHookX = mouseHookY = -1;
        blueSelectBox.scale.set(0.1,0.1);
    }
    
    /////////////////////////////////////////////////

    override public function update(elapsed:Float){
        var secRef:Float = CoolUtil.boundTo(Conductor.songPosition / (Conductor.crochet * 4), 0, FlxG.sound.music.length);

        // # Right click

        if(FlxG.mouse.justPressedRight){
            for(rem in selectedNotes)
                PlayState.SONG.notes[Math.floor(rem[0] / 16)].sectionNotes.remove(rem);

            selectedNotes = [];
            reloadNotes();
            return;
        }
        // # Scrolling

        var wheel = FlxG.mouse.wheel * -50;
        if(wheel != 0 && inputBlock == null){
            pauseSong();

            vocals.time = 
            FlxG.sound.music.time = 
            CoolUtil.boundTo(FlxG.sound.music.time + wheel, 0, FlxG.sound.music.length);
        }

        // # Changing Sections

        if(secRef >= curSec + 1 || secRef < curSec)
            changeSec(Math.floor(secRef));

        var calcY:Float = secRef - curSec;
            camGR.y = calcY * zooms[curZoom] * 2 * -250;
            camGR.y += 75;
        musicLine.y = calcY * gridLayer.members[0].height;

        super.update(elapsed);
    }

    private inline function expandCheck()
        if(curSec >= song.notes.length){
            trace('NEW SEC');
            song.notes.push({
                sectionNotes: [],
                mustHitSection: false,
                bpmChange: 0
            });
        }

    // # UI Tabs.

    private inline function genText(ref:ChartUI_Generic, txt:String):ChartUI_Text
    {
        var tmpText:ChartUI_Text = new ChartUI_Text(ref.x + ref.width + 5, ref.y, txt);
            tmpText.y += (ref.height - tmpText.height) / 2;
            tmpText.y -= uiElements.y;
            tmpText.x -= uiElements.x;
        uiElements.add(tmpText);

        return tmpText;
    }

    private var tabButtons:Array<ChartUI_Button> = [];
    private inline function secStart(area:Void->Void){
        currentUI = area;
        activeUIElement = null;
        inputBlock = null;

        for(i in 0...tabButtons.length) uiElements.remove(tabButtons[i]);

        uiElements.clear();

        for(i in 0...tabButtons.length) uiElements.add(tabButtons[i]);
    }

    public function createInfoUI():Void
    {
        secStart(createInfoUI);

        var text:String = '
        About / Info / How to use:\n
        Left Click - Add note
        Left Click on note - Delete note
        Right Click - Delete selected notes
        Ctrl + Left Click - Select multiple notes
        Q / E - Decrease / add length of selected notes
        Z / X - Zoom in or zoom out grid
        B / N - Change note types
        SPACE - Pause / Play song\n
        Ctrl \"Power Moves\" (on selected notes):\n
        Ctrl + J / L - Moves notes left / right on the grid
        Ctrl + I / K - Moves notes up / down on the grid
        Ctrl + C - Makes of copy of selected notes
        Ctrl + V mirrors selected notes
        ';

        var aboutText:ChartUI_Text = new ChartUI_Text(-35, -30, text);
        uiElements.add(aboutText);
    }

    public function createTestUI():Void
    {
        secStart(createTestUI);

        var coolButton   = new   ChartUI_Button(0 , 0, 120, function(){ trace('CoolBeans!'); }, 'Print!');
        var coolCheckBox = new ChartUI_CheckBox(0 , 35, 30, false, function(ch:Bool){ trace('T: $ch'); });
        var coolCh2ckBox = new ChartUI_CheckBox(35, 35, 30, true , function(ch:Bool){ trace('T: $ch'); });
        var coolDropdown = new ChartUI_DropDown(0 , 70, 90, ['Cool1', 'COol2', 'Cool3'], 'pens', function(index:Int, item:String){
            trace('I: $index O: $item');
        }, uiElements);

        var coolInputBox = new ChartUI_InputBox(0, 105, 120, 'test', function(ch:String){ trace(ch); });

        uiElements.add(coolButton);
        uiElements.add(coolCheckBox);
        uiElements.add(coolCh2ckBox);
        uiElements.add(coolDropdown);
        uiElements.add(coolInputBox);
    }

    public function createSongUI():Void
    {
        secStart(createSongUI);

        // Top stuff

        var nameBox:ChartUI_InputBox = new ChartUI_InputBox(0, 0, 190, 30, song.song, function(ch:String){
            song.song = ch;
            PlayState.curSong = ch.toLowerCase();
        });
        var bpmBox:ChartUI_InputBox = new ChartUI_InputBox(200, 0, 90, 30, Std.string(song.bpm), function(ch:String){
            song.bpm = Std.parseInt(ch);
            Conductor.changeBPM(song.bpm);
        });

        var playerBox:ChartUI_InputBox = new ChartUI_InputBox(0, 40, 90, 30, Std.string(song.activePlayer), function(ch:String){
            song.activePlayer = Std.parseInt(ch);
        });
        var delayBox:ChartUI_InputBox = new ChartUI_InputBox(200, 40, 70, 30, Std.string(song.beginTime), function(ch:String){
            song.beginTime = Std.parseFloat(ch);
        });

        var stageDrop:ChartUI_DropDown = new ChartUI_DropDown(0, 80, 160, 30, CoolUtil.textFileLines('stageList'), song.stage, function(index:Int, ch:String){
            song.stage = ch;
        }, uiElements);
        var speedBox:ChartUI_InputBox = new ChartUI_InputBox(200, 80, 90, 30, Std.string(song.speed), function(ch:String){
            song.speed = Std.parseFloat(ch);
        });

        // Bottom stuff

        var voicesCheck:ChartUI_CheckBox = new ChartUI_CheckBox(0, 550, song.needsVoices, function(ch:Bool){
            song.needsVoices = ch;

            vocals = new FlxSound();
            vocals.time = FlxG.sound.music.time;
            FlxG.sound.list.add(vocals);

            if(!ch) return;

            vocals.loadEmbedded(Paths.playableSong(song.song, true));
        });

        var reloadButton:ChartUI_Button = new ChartUI_Button(260, 430, 130, 30, function(){
            FlxG.sound.playMusic(Paths.playableSong(song.song, false));

            FlxG.sound.music.pause();
            FlxG.sound.music.time = 0;
            if(!song.needsVoices) return;

            vocals = new FlxSound();
            vocals.time = 0;
            vocals.loadEmbedded(Paths.playableSong(song.song, true));

            FlxG.sound.list.add(vocals);
        }, 'Reload Audio');

        var selectButton:ChartUI_Button = new ChartUI_Button(260, 470, 130, 30, function(){
            selectedNotes = [];

            for(sec in song.notes)
                for(nt in sec.sectionNotes)
                    selectedNotes.push(nt);

            reloadNotes();
        }, 'Select All');

        var resetButton:ChartUI_Button = new ChartUI_Button(260, 510, 130, 30, function(){
            song.notes = [];
            song.bpm = 120;
            song.needsVoices = false;
            song.speed = 1;

            expandCheck();
            reloadNotes();
        }, 'Reset Song');

        var saveSong:ChartUI_Button = new ChartUI_Button(260, 550, 130, 30, function(){
            var path = 'assets/songs-data/${PlayState.curSong}/${PlayState.curSong}-edited.json';
            var saveString:String = 'You cannot save charts in web build.';

            #if desktop
            saveString = 'Saved song to "$path"';

            var stringedSong:String = haxe.Json.stringify({"song": song.song}, '\t');
            File.saveContent(path,stringedSong);
            #end
            
            var newText:FlxText = new FlxText(uiBG.x, uiBG.y - 30, 0, saveString, 16);
            add(newText);

            FlxTween.tween(newText, {alpha: 0}, 1, {onComplete: function(t:FlxTween){
                if(newText == null) return;

                remove(newText);
                newText.destroy();
                newText = null;
            }});
        }, 'Save Song');


        uiElements.add(nameBox);
        uiElements.add(bpmBox);
        uiElements.add(playerBox);
        uiElements.add(delayBox);
        uiElements.add(stageDrop);
        uiElements.add(speedBox);

        uiElements.add(voicesCheck);
        uiElements.add(reloadButton);
        uiElements.add(selectButton);
        uiElements.add(resetButton);
        uiElements.add(saveSong);

        genText(playerBox, 'Main Player');
        genText(bpmBox,    'BPM');
        genText(delayBox,  'Start Delay');
        genText(speedBox,  'Scroll Speed');
        genText(voicesCheck, 'Use Voices');
    }

    private var inSecUi:Bool = false;
    private var copyLastInt:Int = 2;
    public static inline var textOffset:Int = -5;
    public function createSecUI():Void
    {
        /*uiElements.clear();
        inSecUi = true;
        blockInput = false;
        //activeUIElement = null;

        var mustHitSection:CharFlxG.mouse.visible = false;
            MusicBeatState.changeState(new PlayState());tUI_CheckBox = new ChartUI_CheckBox(uiBG.x + 10, uiBG.y + 10, PlayState.SONG.notes[curSec].mustHitSection, (c:Bool)->{
            PlayState.SONG.notes[curSec].mustHitSection = c;
        });

        var clearButton:ChartUI_Button = new ChartUI_Button(uiBG.x + 10, uiBG.height+uiBG.y - 40, true, ()->{
            PlayState.SONG.notes[curSec].sectionNotes = [];
            selectedNotes = [];
            loadNotes();
        }, 'Clear', 110);
        var copyLast:ChartUI_InputBox = new ChartUI_InputBox(uiBG.x + 10, clearButton.y - 80, 110, Std.string(copyLastInt), (str:String)->{
            copyLastInt = Std.parseInt(str);
        });
        var copyButton:ChartUI_Button = new ChartUI_Button(uiBG.x + 10, clearButton.y - 40, true, ()->{
            if(curSec - copyLastInt < 0) return;

            for(nt in PlayState.SONG.notes[curSec-copyLastInt].sectionNotes)
                PlayState.SONG.notes[curSec].sectionNotes.push([nt[0]+(copyLastInt*16), nt[1], nt[2], nt[3]]);
            loadNotes();
        }, 'Copy Last', 110);
        var swapButton:ChartUI_Button = new ChartUI_Button(uiBG.x + 10, copyLast.y - 40, true, ()->{
            for(nt in PlayState.SONG.notes[curSec].sectionNotes)
                // % 2 or how ever many characters you want
                nt[3] = (nt[3] + 1) % 2;
            selectedNotes = [];
            loadNotes();
        }, 'Swap', 110);
        var snButton:ChartUI_Button = new ChartUI_Button(uiBG.x + 10, swapButton.y - 40, true, ()->{
            selectedNotes = [];
            for(nt in PlayState.SONG.notes[curSec].sectionNotes)
                selectedNotes.push(nt);

            loadNotes();
        }, 'Select', 110);
        var mhText:FlxText = new FlxText(mustHitSection.x+mustHitSection.width + 5, mustHitSection.y + 10 + textOffset, 0, 'Move Camera to BF', 16);
        var clText:FlxText = new FlxText(copyLast.x + copyLast.width + 5, copyLast.y + 10 + textOffset, 0, 'Copy Last sections back', 16);
        
        uiElements.add(clText);
        uiElements.add(mhText);
        uiElements.add(mustHitSection);
        uiElements.add(clearButton);
        uiElements.add(copyLast);
        uiElements.add(copyButton);
        uiElements.add(swapButton);
        uiElements.add(snButton);*/
    }
}