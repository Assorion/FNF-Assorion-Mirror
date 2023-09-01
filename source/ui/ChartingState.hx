package ui;

import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import openfl.display.BitmapData;
import flixel.util.FlxColor;
import openfl.events.KeyboardEvent;
import openfl.geom.Rectangle;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.FlxCamera;
import flixel.text.FlxText;
import gameplay.Note;
import gameplay.PlayState;
import misc.Song;
import ui.CustomChartUI;
import sys.io.File;
import gameplay.HealthIcon;
import flixel.tweens.FlxTween;

using StringTools;

#if !debug @:noDebug #end
class ChartingState extends MusicBeatState {
    public static function colorFromRGBArray(array:Array<Int>):Int
        return FlxColor.fromRGB(array[0], array[1], array[2]);

    public static var uiColours:Array<Array<Int>> = [
        [155, 100, 160], // dark
        [200, 120, 210], // light
        [240, 150, 250]  // button light
    ];
    public static var gridColours:Array<Array<Array<Int>>> = [
        [[255, 200, 200], [255, 215, 215]], // Red
        [[200, 200, 255], [215, 215, 255]], // Blue
        [[240, 240, 200], [240, 240, 215]], // Yellow / White
        [[200, 255, 200], [215, 255, 215]], // Green
    ];
    public static var selectNoteColour:Array<Int> = [170, 170, 170];

    public static inline var gridSize:Int = 40;
    public static inline var noteRange:Int = 0;

    public var selectedNotes:Array<Array<Dynamic>> = [];

    var gridSpr:FlxSprite;
    var gridSel:FlxSprite;
    var selectSpr:FlxSprite;
    var curSec:Int = 0;
    private var vocals:FlxSound;
    public var musicLine:FlxSprite;

    public var zooms:Array<Float> = [0.5, 0.75, 1, 1.5, 2, 3, 4, 6, 8];
    public var zoomDivs:Array<Int>= [2,   3,    4,   3, 4, 3, 4, 3, 4];
    public var curZoom:Int = 2;

    public var notes:FlxTypedGroup<Note>;
    public var uiElements:FlxTypedGroup<FlxSprite>;

    public var camUI:FlxCamera;
    public var camGR:FlxCamera;
    var iconP1:HealthIcon;
    var iconP2:HealthIcon;

    public static var blockInput:Bool = false;
    // this is used to stop conflicts with other UI elements
    public static var activeUIElement:Dynamic;
    public static var curNoteType:Int = 0;

    var uiBG:FlxSprite;
    var uiFront:FlxSprite;

    override public function create(){
        if(FlxG.sound.music.playing){
            FlxG.sound.music.pause();
            FlxG.sound.music.time = 0;
            FlxG.sound.music.onComplete = function(){
                FlxG.sound.music.pause();
                FlxG.sound.music.time = 0;
            };
        }

        // # cam code

        camUI = new FlxCamera();
        camGR = new FlxCamera(0,0, 1280, 800);
        camGR.x += 100;
        camGR.y += 50;
        camGR.bgColor.alpha = 0;

        FlxG.cameras.reset(camUI);
		FlxG.cameras.add(camGR);
		FlxCamera.defaultCameras = [camUI];

        // # create bg

        var bgspr:FlxSprite = new FlxSprite(0,0).loadGraphic(Paths.lImage('ui/menuDesat'));
        bgspr.screenCenter();
        bgspr.color = FlxColor.fromRGB(0, 40, 8);
        add(bgspr);

        // # create grid
        var fColArr:Array<Array<Int>> = [];
        for(i in gridColours)
            fColArr.push([colorFromRGBArray(i[0]), colorFromRGBArray(i[1])]);

        gridSpr = createGrid(gridSize, gridSize, 8, 16, fColArr);
        gridSel = new FlxSprite(0,0).makeGraphic(gridSize, gridSize, FlxColor.WHITE);
        add(gridSpr);
        add(gridSel);

        // # create line and notes

        iconP1 = new HealthIcon('face');
        iconP2 = new HealthIcon('bf');
        iconP1.x = gridSize * 1;
        iconP2.x = gridSize * 5;
        iconP1.y = iconP2.y = gridSpr.height + 10;
        iconP1.cameras = iconP2.cameras = [camGR];
        iconP1.scale.set(0.5, 0.5);
        iconP2.scale.set(0.5, 0.5);
        iconP1.updateHitbox();
        iconP2.updateHitbox();

        notes = new FlxTypedGroup<Note>();
        musicLine = new FlxSprite(gridSpr.x, gridSpr.y).makeGraphic(Std.int(gridSpr.width), 4, FlxColor.WHITE);
        add(iconP1);
        add(iconP2);
        add(notes);
        add(musicLine);

        gridSpr.cameras = [camGR];
        gridSel.cameras = [camGR];
        notes  .cameras = [camGR];
        musicLine.cameras=[camGR];

        // # Creates vocals.

        vocals = new FlxSound();
		if (PlayState.SONG.needsVoices)
			vocals.loadEmbedded(Paths.playableSong(PlayState.curSong, true));

        vocals.time = 0;
		FlxG.sound.list.add(vocals);

        FlxG.mouse.visible = true;

        // # create ui

        uiElements = new FlxTypedGroup<FlxSprite>();
        uiBG    = new FlxSprite(0,0).makeGraphic(420, 550, colorFromRGBArray(uiColours[0]));
        uiBG.screenCenter();
        uiBG.x += 100;
        uiFront = new FlxSprite(0,0).makeGraphic(412, 542, colorFromRGBArray(uiColours[1]));
        uiFront.screenCenter();
        uiFront.x += 100;
        add(uiBG);
        add(uiFront);
        add(uiElements);

        var songButton:ChartUI_Button = new ChartUI_Button(uiBG.x + uiBG.width - 4, uiBG.y + 20, false, createSongUI, 'SONG');
        var infoButton:ChartUI_Button = new ChartUI_Button(uiBG.x + uiBG.width - 4, uiBG.y +500, false, createInfoUI, 'ABOUT');
        var secButton :ChartUI_Button = new ChartUI_Button(uiBG.x + uiBG.width - 4, uiBG.y + 60, false, createSecUI , 'SECTION');
        add(secButton );
        add(songButton);
        add(infoButton);

        createSongUI();
        loadNotes();

        selectSpr = new FlxSprite(-1,-1).makeGraphic(1,1, FlxColor.fromRGB(140,225,255));
		selectSpr.origin.set(0,0);
		selectSpr.alpha = 0.55;
        selectSpr.cameras = [camGR];
		add(selectSpr);

        super.create();
    }

    public inline function pauseSong(){
        FlxG.sound.music.pause();
        vocals.pause();
    }

    // for changing zoom level
    public function makeGrid(){
        remove(notes);
        remove(musicLine);
        remove(gridSel);

        var fColArr:Array<Array<FlxColor>> = [];
        for(i in gridColours)
            fColArr.push([colorFromRGBArray(i[0]), colorFromRGBArray(i[1])]);

        gridSpr.destroy();
        gridSpr = createGrid(gridSize, gridSize, 8, Math.floor(16 * zooms[curZoom]), fColArr, zoomDivs[curZoom]);
        gridSpr.cameras = [camGR];
        camGR.height = Std.int(710 * zooms[curZoom]);

        iconP1.y = iconP2.y = gridSpr.height + 10;
        
        add(gridSpr);
        add(gridSel);
        add(notes);
        add(musicLine);
    }

    // # Semi Input code. Mouse still gets handled by Update.
    override function keyHit(ev:KeyboardEvent){
        super.keyHit(ev);

        if(blockInput) return;

        // pausing and playing
        if(key == FlxKey.SPACE){
            if(FlxG.sound.music.playing)
                pauseSong();
            else {
                FlxG.sound.music.play();
                vocals.play();
                
                vocals.time = FlxG.sound.music.time;
            }
            return;
        }

        // changing sections
        var T:Int = key.deepCheck([NewControls.UI_L, NewControls.UI_R]);
        if(T != -1){
            curSec += (T * 2) - 1;
            if(curSec < 0) curSec = 0;
            FlxG.sound.music.time = curSec * Conductor.crochet * 4;

            expandCheck();
            if(inSecUi) createSecUI();

            pauseSong();
            loadNotes();
            return;
        }

        // note types
        T = key.deepCheck([[FlxKey.B], [FlxKey.N]]);
        if(T != -1){
            curNoteType += (T * 2) - 1;
            curNoteType = CoolUtil.boundTo(curNoteType, 0, noteRange);

            for(nt in selectedNotes)
                nt[4] = curNoteType;

            loadNotes();
            return;
        }

        // change note sustains
        T = key.deepCheck([[FlxKey.Q], [FlxKey.E]]);
        if(T != -1){
            for(nt in selectedNotes)
                nt[2] = CoolUtil.boundTo(nt[2] + (T * 2 - 1), 0, 1000);

            loadNotes();
            return;
        }
        // Zoom
        T = key.deepCheck([ [FlxKey.X], [FlxKey.Z] ]);
        if(T != -1){
            curZoom += (T * 2) - 1;
            curZoom = CoolUtil.boundTo(curZoom, 0, 8);
            //zoomLevel = zooms[curZoom];

            makeGrid();
            loadNotes();

            return;
        }

        if(key.hardCheck(NewControls.UI_BACK) || key.hardCheck(NewControls.UI_ACCEPT)){
            FlxG.mouse.visible = false;
            FlxG.switchState(new PlayState());
        }

        if(!FlxG.keys.pressed.CONTROL || key == FlxKey.CONTROL) return;

        if(key == FlxKey.J)
            for(nt in selectedNotes){
                nt[1]--;
                if (nt[1] < 0) {
                    nt[1] = 3;
                    nt[3] = ((nt[3] - 1) + 2) % 2;
                }
            }
        if(key == FlxKey.L)
            for(nt in selectedNotes){
                nt[1]++;
                if (nt[1] > 3){
                    nt[1] = 0;
                    nt[3] = (nt[3] + 1) % 2;
                }
            }
        if(key == FlxKey.I)
            for(nt in selectedNotes){
                PlayState.SONG.notes[Math.floor(nt[0] / 16)].sectionNotes.remove(nt);
                nt[0]--;
                if(nt[0] < 0) nt[0] = 0;
                PlayState.SONG.notes[Math.floor(nt[0] / 16)].sectionNotes.push(nt);
            }
        if(key == FlxKey.K)
            for(nt in selectedNotes){
                PlayState.SONG.notes[Math.floor(nt[0] / 16)].sectionNotes.remove(nt);
                nt[0]++;
                PlayState.SONG.notes[Math.floor(nt[0] / 16)].sectionNotes.push(nt);
            }
        if(key == FlxKey.C){
            var dupeNotes:Array<Array<Dynamic>> = [];
            for(nt in selectedNotes){
                var dupe = [nt[0], nt[1], nt[2], nt[3]];
                dupeNotes.push(dupe);
                PlayState.SONG.notes[Math.floor(nt[0] / 16)].sectionNotes.push(dupe);
            }
            selectedNotes = dupeNotes;
        }
        if(key == FlxKey.V)
            for(nt in selectedNotes)
                nt[1] = 3 - nt[1];

        loadNotes();
    }

    // # Note rendering code.
    public function loadNotes(){
        notes.clear();
        for(newnote in PlayState.SONG.notes[curSec].sectionNotes){
            var daNote = new Note(newnote[0], newnote[1], newnote[4]);
            daNote.setGraphicSize(gridSize, gridSize);
            daNote.x = gridSize * daNote.noteData;
            daNote.x += gridSize * 4 * newnote[3];
            daNote.y = (daNote.strumTime - (curSec * 16)) * zooms[curZoom] * gridSize;
            daNote.chartRef = newnote;

            if(selectedNotes.contains(newnote)) daNote.color = colorFromRGBArray(selectNoteColour);
            
            daNote.updateHitbox();
            notes.add(daNote);

            for(i in 1...Math.floor((newnote[2] * zooms[curZoom]) + 1)){
                var susNote = new Note(newnote[0] + (i / zooms[curZoom]), newnote[1], newnote[4], true, i == Math.floor(newnote[2]*zooms[curZoom]));
                if(Settings.pr.downscroll) susNote.flipY = false;
                susNote.setGraphicSize(Std.int(gridSize / 2.5), gridSize);
                susNote.x = daNote.x;
                susNote.y = (susNote.strumTime - (curSec * 16)) * zooms[curZoom] * gridSize;
                susNote.updateHitbox();

                susNote.x += (gridSize / 2) - (susNote.width / 2);

                notes.add(susNote);
            }
        }
    }

    // # Add note code.
    public function addNote(){
        // 1280 / 3
        if(FlxG.mouse.x > 426) return;
        if(delNote()) return;

        var newnote:Array<Dynamic> = [
            (Math.floor(gridSel.y / gridSize) / zooms[curZoom]) + (curSec * 16),
             Math.floor(gridSel.x / gridSize) % 4,
            0,
            Math.floor(gridSel.x / (gridSize * 4)),
            curNoteType
        ];

        PlayState.SONG.notes[curSec].sectionNotes.push(newnote);
        selectedNotes = [newnote];
        loadNotes();
    }

    public function delNote():Bool
    {
        for(nt in notes.members)
            if(nt.x == gridSel.x && nt.y == gridSel.y){
                PlayState.SONG.notes[curSec].sectionNotes.remove(nt.chartRef);
                selectedNotes = [];
                loadNotes();
                return true;
            }
        return false;
    }
    var mouseHookX:Int = -1;
    var mouseHookY:Int = -1;
            
    override public function update(elapsed:Float){

        // handle music timing crap.
        var fakeTime:Float = FlxG.sound.music.time;
        var fakeSec :Float = fakeTime / (Conductor.crochet * 4);

        if(FlxG.mouse.wheel != 0 && !blockInput){
            vocals.time = fakeTime = FlxG.sound.music.time = CoolUtil.boundTo(fakeTime + (-FlxG.mouse.wheel * 50), 0, FlxG.sound.music.length);
            pauseSong();
        }

        if(fakeSec >= curSec+1 || fakeSec < curSec){
            curSec = Math.floor(fakeSec);
            expandCheck();
            loadNotes();
            if(inSecUi) createSecUI();
        }

        gridSel.x = CoolUtil.boundTo(Math.floor((FlxG.mouse.x - camGR.x) / gridSize) * gridSize, 0, gridSpr.width  - gridSize);
        gridSel.y = CoolUtil.boundTo(Math.floor((FlxG.mouse.y - camGR.y) / gridSize) * gridSize, 0, gridSpr.height - gridSize);

        // grid Y code.
        var calcY:Float = fakeSec - curSec;
        camGR.y = calcY * zooms[curZoom] * 2 * -250;
        camGR.y += 75;
        musicLine.y = calcY * gridSpr.height;

        // this entire bit here actually handles all the mouse code.
        // I'm not sure if there's a mouse event, but even if so,
        // I don't think it really matters here.
        if(FlxG.keys.pressed.CONTROL && FlxG.mouse.pressed){
            if(FlxG.mouse.justPressed){
                mouseHookX = Math.floor(FlxG.mouse.x - camGR.x);
                mouseHookY = Math.floor(FlxG.mouse.y - camGR.y);
                selectSpr.x = mouseHookX;
                selectSpr.y = mouseHookY;
                return;
            }
            var fakeX = FlxG.mouse.x - camGR.x;
            var fakeY = FlxG.mouse.y - camGR.y;
            if(fakeX < mouseHookX) selectSpr.x = fakeX;
            if(fakeY < mouseHookY) selectSpr.y = fakeY;

            selectSpr.scale.x = fakeX - mouseHookX;
            selectSpr.scale.y = fakeY - mouseHookY;
            selectSpr.updateHitbox();

            var shift = !FlxG.keys.pressed.SHIFT;
            if(shift)
                selectedNotes = [];

            for(i in 0...notes.length){
                var nt = notes.members[i];
                if(shift)
                    nt.color = colorFromRGBArray([255,255,255]);
                ////////////////////////////////////////////////
                if(nt.x >= selectSpr.x && nt.y >= selectSpr.y &&
                    nt.x + nt.width < selectSpr.x + selectSpr.width  &&
                    nt.y + nt.height< selectSpr.y + selectSpr.height && !nt.isSustainNote){
                        if(!selectedNotes.contains(nt.chartRef))
                            selectedNotes.push(nt.chartRef);
                        nt.color = colorFromRGBArray(selectNoteColour);
                    }
            }

            return;
        }

        if(mouseHookX != -1){
            mouseHookX = mouseHookY = -1;
            selectSpr.x = selectSpr.y = -1;
            selectSpr.scale.set(0.1,0.1);

            return;
        }

        if(FlxG.mouse.justPressed)
            addNote();
        // delete all your selected notes.
        if(FlxG.mouse.justPressedRight){
            for(rem in selectedNotes)
                PlayState.SONG.notes[Math.floor(rem[0] / 16)].sectionNotes.remove(rem);

            selectedNotes = [];
            loadNotes();
        }
        
        super.update(elapsed);
    }

    private inline function expandCheck()
        if(curSec >= PlayState.SONG.notes.length){
            trace('NEW SEC');
            PlayState.SONG.notes.push({
                sectionNotes: [],
                mustHitSection: false
            });
        }

    public function createInfoUI():Void
    {
        uiElements.clear();
        inSecUi = false;

        var text:String = '
        About / Info / How to use:\n
        Left Click - Add note
        Left Click on note - Delete note
        Right Click - Delete selected notes
        Ctrl + Left Click - Select multiple notes
        Q / E - Decrease or add length of selected notes
        Z / X - Zoom in or zoom out grid
        B / N - Change note types (including selected notes)
        SPACE - Pause / Play song\n
        Ctrl \"Power Moves\" (on selected notes):\n
        Ctrl + J / L - Moves all notes left or right on the grid
        Ctrl + I / K - Moves all notes up or down on the grid
        Ctrl + C - Makes of copy of selected notes
        Ctrl + V mirrors selected notes
        ';
        var aboutText:FlxText = new FlxText(uiBG.x - 37, (uiBG.y - 10) + textOffset, 0, text, 12);
        aboutText.scale.set(0.95, 0.95);

        uiElements.add(aboutText);
    }

    private var inSecUi:Bool = false;
    private var copyLastInt:Int = 2;
    public static inline var textOffset:Int = -5;
    public function createSecUI():Void
    {
        uiElements.clear();
        inSecUi = true;

        var mustHitSection:ChartUI_CheckBox = new ChartUI_CheckBox(uiBG.x + 10, uiBG.y + 10, PlayState.SONG.notes[curSec].mustHitSection, (c:Bool)->{
            PlayState.SONG.notes[curSec].mustHitSection = c;
        });

        var clearButton:ChartUI_Button = new ChartUI_Button(uiBG.x + 10, uiBG.height+uiBG.y - 40, true, ()->{
            PlayState.SONG.notes[curSec].sectionNotes = [];
            selectedNotes = [];
            loadNotes();
        }, 'Clear');
        var copyLast:ChartUI_InputBox = new ChartUI_InputBox(uiBG.x + 10, clearButton.y - 80, 90, Std.string(copyLastInt), (str:String)->{
            copyLastInt = Std.parseInt(str);
        });
        var copyButton:ChartUI_Button = new ChartUI_Button(uiBG.x + 10, clearButton.y - 40, true, ()->{
            if(curSec - copyLastInt < 0) return;

            for(nt in PlayState.SONG.notes[curSec-copyLastInt].sectionNotes)
                PlayState.SONG.notes[curSec].sectionNotes.push([nt[0]+(copyLastInt*16), nt[1], nt[2], nt[3]]);
            loadNotes();
        }, 'Copy');
        var swapButton:ChartUI_Button = new ChartUI_Button(uiBG.x + 10, copyLast.y - 40, true, ()->{
            for(nt in PlayState.SONG.notes[curSec].sectionNotes)
                // % 2 or how ever many characters you want
                nt[3] = (nt[3] + 1) % 2;
            selectedNotes = [];
            loadNotes();
        }, 'Swap');
        var snButton:ChartUI_Button = new ChartUI_Button(uiBG.x + 10, swapButton.y - 40, true, ()->{
            selectedNotes = [];
            for(nt in PlayState.SONG.notes[curSec].sectionNotes)
                selectedNotes.push(nt);

            loadNotes();
        }, 'Select');
        var mhText:FlxText = new FlxText(mustHitSection.x+mustHitSection.width + 5, mustHitSection.y + textOffset, 0, 'Move Camera to BF', 16);

        uiElements.add(mhText);
        uiElements.add(mustHitSection);
        uiElements.add(clearButton);
        uiElements.add(copyLast);
        uiElements.add(copyButton);
        uiElements.add(swapButton);
        uiElements.add(snButton);
    }

    public function createSongUI():Void
    {
        uiElements.clear();
        inSecUi = false;

        var nameBox:ChartUI_InputBox = new ChartUI_InputBox(uiBG.x + 10, uiBG.y + 10, 150, PlayState.SONG.song, (str:String) -> {
            PlayState.SONG.song = str;
            PlayState.curSong = str.toLowerCase();
        });
        var bpmBox:ChartUI_InputBox = new ChartUI_InputBox(nameBox.x + nameBox.width + 10, uiBG.y + 10, 50, Std.string(PlayState.SONG.bpm), (str:String) -> {
            PlayState.SONG.bpm = Std.parseInt(str);
            Conductor.changeBPM(PlayState.SONG.bpm);
        });
        var voicesCheck:ChartUI_CheckBox = new ChartUI_CheckBox(uiBG.x + 10, (uiBG.y+uiBG.height) - 40, PlayState.SONG.needsVoices, (c:Bool) -> {
            PlayState.SONG.needsVoices = c;
            vocals.destroy();

            vocals = new FlxSound();
            vocals.time = FlxG.sound.music.time;
            if(c)
                vocals.loadEmbedded(Paths.playableSong(PlayState.curSong, true));

            FlxG.sound.list.add(vocals);
        });
        var playerBox:ChartUI_InputBox = new ChartUI_InputBox(voicesCheck.x, voicesCheck.y - 40, 30, Std.string(PlayState.SONG.activePlayer), (str:String) -> {
            PlayState.SONG.activePlayer = Std.parseInt(str);
        });
        var delayBox:ChartUI_InputBox = new ChartUI_InputBox(uiBG.x + 10, uiBG.y + 50, 70, Std.string(PlayState.SONG.beginTime), (str:String) -> {
            PlayState.SONG.beginTime = Std.parseFloat(str);
        });
        var speedBox:ChartUI_InputBox = new ChartUI_InputBox(delayBox.x+delayBox.width + 10, uiBG.y + 50, 70, Std.string(PlayState.SONG.speed), (str:String) -> {
            PlayState.SONG.speed = Std.parseFloat(str);
        });

        var lines = CoolUtil.textFileLines('characterList');
        var p1Drop:ChartUI_DropDown = new ChartUI_DropDown(uiBG.x + 10, uiBG.y + 90, 150, lines, PlayState.SONG.characters[1], (str:String) -> {
            PlayState.SONG.characters[1] = str;
        });
        var p2Drop:ChartUI_DropDown = new ChartUI_DropDown(uiBG.x + 10, uiBG.y + 130, 150, lines, PlayState.SONG.characters[0], (str:String) -> {
            PlayState.SONG.characters[0] = str;
        });
        var p3Drop:ChartUI_DropDown = new ChartUI_DropDown(uiBG.x + 10, uiBG.y + 170, 150, lines, PlayState.SONG.characters[2], (str:String) -> {
            PlayState.SONG.characters[2] = str;
        });

        var stageDrop:ChartUI_DropDown = new ChartUI_DropDown(uiBG.x + 10, uiBG.y + 210, 150, CoolUtil.textFileLines('stageList'), PlayState.SONG.stage, (str:String) -> {
            PlayState.SONG.stage = str;
        });

        var reloadAudio:ChartUI_Button = new ChartUI_Button((uiBG.x+uiBG.width - 120) - 10, (uiBG.y+uiBG.height - 120) - 10, true, ()->{
            FlxG.sound.playMusic(Paths.playableSong(PlayState.SONG.song, false));
            FlxG.sound.music.pause();
            FlxG.sound.music.time = 0;
        }, 'Reload Inst', 120);
        var clearAllNotes:ChartUI_Button = new ChartUI_Button(reloadAudio.x, reloadAudio.y + 40, true, ()->{
            // hopefully removes stupid crap that old charts leave behind.
            var osong:SwagSong = PlayState.SONG;
            PlayState.SONG = {
                song:        osong.song,
                notes:       osong.notes,
                bpm:         osong.bpm,
                needsVoices: osong.needsVoices,
                speed:       osong.speed,
                characters:  osong.characters,
                stage:       osong.stage,
                beginTime:   osong.beginTime,
                activePlayer:osong.activePlayer
            };
            for(i in 0...PlayState.SONG.notes.length){
                var osec = PlayState.SONG.notes[i];
                PlayState.SONG.notes[i] = {
                    sectionNotes: [],
                    mustHitSection: osec.mustHitSection
                };
            }

            loadNotes();
        }, 'Clear Song', 120); 
        var saveSong:ChartUI_Button = new ChartUI_Button(reloadAudio.x, clearAllNotes.y + 40, true, ()->{
            var path = 'assets/songs-data/${PlayState.curSong}/${PlayState.curSong}-edited.json';
            var stringedSong:String = haxe.Json.stringify({"song": PlayState.SONG}, '\t');
            File.saveContent(path,stringedSong);
            var newText:FlxText = new FlxText(uiBG.x - 10, (uiBG.y + uiBG.height + 30) + textOffset, 0, 'Saved song to "$path"', 16);
            add(newText);

            FlxTween.tween(newText, {alpha: 0}, 1);
            postEvent(1.1, ()->{
                if(newText != null){
                    remove(newText);
                    newText.destroy();
                    newText = null;
                }
            });
        }, 'Save Song', 120);
        var voicesText:FlxText = new FlxText(voicesCheck.x + voicesCheck.width+5,voicesCheck.y + 10 + textOffset,0,'Enable Vocals',16);
        var sSpeedText:FlxText = new FlxText(speedBox.x+speedBox.width+5        ,   speedBox.y + 10 + textOffset,0,'Scroll Speed', 16);
        var playerText:FlxText = new FlxText(voicesText.x+5, voicesText.y - 40,0,'Player', 16);

        var bfText:FlxText = new FlxText(p1Drop.x+p1Drop.width+5, p1Drop.y + 10 + textOffset, 0, 'BF',  16);
        var dadTxt:FlxText = new FlxText(p2Drop.x+p2Drop.width+5, p2Drop.y + 10 + textOffset, 0, 'DAD', 16);
        var gfText:FlxText = new FlxText(p3Drop.x+p3Drop.width+5, p3Drop.y + 10 + textOffset, 0, 'GF',  16);

        uiElements.add(bfText);
        uiElements.add(gfText);
        uiElements.add(dadTxt);
        uiElements.add(voicesText);
        uiElements.add(sSpeedText);
        uiElements.add(playerText);
        
        uiElements.add(nameBox);
        uiElements.add(bpmBox);
        uiElements.add(voicesCheck);
        uiElements.add(speedBox);
        uiElements.add(delayBox);
        uiElements.add(stageDrop);
        uiElements.add(p3Drop);
        uiElements.add(p2Drop);
        uiElements.add(p1Drop);
        uiElements.add(reloadAudio);
        uiElements.add(clearAllNotes);
        uiElements.add(saveSong);
        uiElements.add(playerBox);
    }

    // basically stolen from FlxGridOverlay
    public static function createGrid(cWidth:Int, cHeight:Int, columns:Int, rows:Int, Colours:Array<Array<FlxColor>>, division:Int = 4):FlxSprite
    {
        var emptySprite:BitmapData = new BitmapData(cWidth * columns, cHeight * rows, true);
        var colOffset:Int = 0;

        for(i in 0...columns)
            for(j in 0...rows){
                emptySprite.fillRect(new Rectangle(i * cWidth, j * cHeight, cWidth, cHeight), Colours[j % division][(i + colOffset) % 2]);
                colOffset++;
            }

        emptySprite.fillRect(new Rectangle(((cWidth * columns) / 2) - 2, 0, 4, cHeight * rows), FlxColor.BLACK);

        var retSprite = new FlxSprite().loadGraphic(emptySprite);
        return retSprite;
    }
}