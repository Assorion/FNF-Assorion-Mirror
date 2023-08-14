package gameplay;

import gameplay.Song.SwagSong;
import gameplay.Song.SwagSection;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.filters.ShaderFilter;
import flixel.input.keyboard.FlxKey;
import ui.HealthIcon;
import misc.Highscore;
import ui.FreeplayState;
import ui.ChartingState;

using StringTools;

class PlayState extends MusicBeatState
{
	public static var curStage:String = '';
	public static var curSong :String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var campaignScore:Int = 0;

	public static var mustHitSection:Bool = false;

	private var vocals:FlxSound;

	private var dad:Character;
	private var gf:Character;
	private var boyfriend:Character;

	private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	private var strumLine:FlxObject;

	private var camFollow:FlxObject;
	private var strumLineNotes:FlxTypedGroup<FlxSprite>;
	private var playerStrums:FlxTypedGroup<FlxSprite>;

	// health now goes from 0 - 100, instead of 0 - 2
	private var health:Int = 50;
	private var combo:Int = 0;
	private var noteCount:Int = 0;

	private var healthBarBG:FlxSprite;
	private var healthBar:HealthBar;

	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;
	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;

	//var talking:Bool = true;
	var songScore:Int = 0;
	var scoreTxt:FlxText;

	var defaultCamZoom:Float = 1.05;
	private var paused:Bool = false;

	public static var sDir:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
	public var stageVars:Map <String, Dynamic> = new Map 
		#if (haxe < "4.0.0") <String, Dynamic> #end ();

	private var characterPositions:Array<Int> = [
		// gf
		400,
		130,
		// dad
		100, 100,
		//bf
		770,
		450
	];
	private var characterNames:Array<String> = [
		SONG.player3,
		SONG.player2,
		SONG.player1
	];
	// this should be the notes the the player is meant to hit.
	private var playerPos:Int = 1;
	private var playingCharacters:Array<Character> = [];

	private var songTime:Float = -12;
	private var songDiv :Float = 1;

	// last one should always be the player.
	private function createChar(pos:Int):Character
	{
		if(characterNames[pos] == '') {
			trace('name is empty bruh');
			return null;
		}

		var charRef = new Character(characterPositions[pos * 2], characterPositions[(pos * 2) + 1], characterNames[pos], pos == characterNames.length - 1);
		add(charRef);

		return charRef;
	}

	// # Create (obvious) where game starts.
	override public function create()
	{
		camGame = new FlxCamera();
		camHUD  = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxCamera.defaultCameras = [camGame];

		Conductor.changeBPM(SONG.bpm);
		// get a multiplier, since division is expensive.
		songDiv = 1 / Conductor.stepCrochet;

		handleStage();

		/*
			Would've loved to have put these characters in a for loop.
			Except haxe's infinite amount of BS means it would be worse,
			Than just manually setting the characters.
			
			Should still be easy to create more custom characters if needed though.
		*/

		gf 		  = createChar(0);
		dad		  = createChar(1);
		boyfriend = createChar(2);

		playingCharacters = [dad, boyfriend];

		///////////////////////////////////

		curSong = SONG.song.toLowerCase();
		Conductor.songPosition = -5 * Conductor.crochet;

		strumLine = new FlxObject(0, Settings.pr.downscroll ? FlxG.height - 150 : 50, 1, 1);

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		playerStrums   = new FlxTypedGroup<FlxSprite>();
		notes          = new FlxTypedGroup<Note>();
		add(strumLineNotes);
		add(notes);

		vocals = new FlxSound();
		if (SONG.needsVoices)
			vocals.loadEmbedded(Paths.playableSong(curSong, true));

		FlxG.sound.list.add(vocals);
		FlxG.sound.playMusic(Paths.playableSong(curSong), 1, false);
		FlxG.sound.music.onComplete = endSong;
		FlxG.sound.music.pause();

		generateSong();
		generateStaticArrows(0, false);
		generateStaticArrows(1,  true);

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(FlxG.width / 2, FlxG.height / 2);
		//add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		FlxG.camera.zoom = defaultCamZoom;

		var baseY:Int = Settings.pr.downscroll ? 80 : 650;

		// health bar
		healthBarBG = new FlxSprite(0, baseY).loadGraphic(Paths.lImage('gameplay/healthBar'));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.antialiasing = Settings.pr.antialiasing;
		add(healthBarBG);

		healthBar = new HealthBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8));
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		add(healthBar);

		// score
		scoreTxt = new FlxText(healthBarBG.x + healthBarBG.width - 190, baseY + 30, 0, "", 20);
		scoreTxt.setFormat("assets/fonts/vcr.ttf", 16, FlxColor.WHITE, RIGHT);
		scoreTxt.scrollFactor.set();
		add(scoreTxt);

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP2 = new HealthIcon(SONG.player2, false);
		iconP1.y = baseY - (iconP1.height / 2);
		iconP2.y = baseY - (iconP2.height / 2);
		add(iconP1);
		add(iconP2);

		// cameras.
		strumLineNotes.cameras = [camHUD];
		notes.cameras          = [camHUD];
		healthBar.cameras      = [camHUD];
		healthBarBG.cameras    = [camHUD];
		iconP1.cameras         = [camHUD];
		iconP2.cameras         = [camHUD];
		scoreTxt.cameras       = [camHUD];

		songTime = -12;
		songTime -= Settings.pr.offset * songDiv;

		postEvent(SONG.beginTime, () -> {
			startCountdown();
		});
		updateHealth(0);

		super.create();
	}

	// # stage code.
	// put things like gf and bf positions here.

	public inline function handleStage(){
		curStage = SONG.stage;

		switch(curStage){
			case 'stage', '':
				defaultCamZoom = 0.9;
				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.lImage('stages/stageback'));
					bg.antialiasing = Settings.pr.antialiasing;
					bg.scrollFactor.set(0.9, 0.9);
					bg.active = false;
				add(bg);

				var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.lImage('stages/stagefront'));
					stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
					stageFront.updateHitbox();
					stageFront.antialiasing = Settings.pr.antialiasing;
					stageFront.scrollFactor.set(0.9, 0.9);
					stageFront.active = false;
				add(stageFront);

				var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.lImage('stages/stagecurtains'));
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					stageCurtains.antialiasing = Settings.pr.antialiasing;
					stageCurtains.scrollFactor.set(1.3, 1.3);
					stageCurtains.active = false;

				add(stageCurtains);
		}
	}

	// remove repetitive code.
	private inline function introSpriteTween(spr:FlxSprite, steps:Int, delay:Float = 0){
		spr.alpha = 1;
		FlxTween.tween(spr, {y: spr.y + 10, alpha: 0}, (steps * Conductor.stepCrochet) / 1000, {
			ease: FlxEase.cubeInOut,
			startDelay: delay * 0.001,
			onComplete: function(twn:FlxTween)
			{
				spr.destroy();
			}
		});
	}

	// # start countdown

	function startCountdown():Void
	{
		countingDown = true;
		// make arrows appear.
		for(i in 0...strumLineNotes.length)
			FlxTween.tween(strumLineNotes.members[i], {alpha: 1}, 0.5, {startDelay: (i + 1) * 0.2});

		var introSprites:Array<FlxSprite> = [];
		var introAssets :Array<String>    = [
			'ready', 'set', 'go', '',
			'intro3', 'intro2', 'intro1', 'introGo'
		]; 

		for(i in 0...3){
			var spr:FlxSprite = new FlxSprite().loadGraphic(Paths.lImage('gameplay/${ introAssets[i] }'));
				spr.scrollFactor.set();
				spr.screenCenter();
				spr.antialiasing = Settings.pr.antialiasing;
				spr.alpha = 0;
			add(spr);

			introSprites[i+1] = spr;
		}

		var swagCounter:Int = 0;
		var startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			if(swagCounter >= 4){
				startSong();
				return;
			}

			dad.dance();
			 gf.dance();
			boyfriend.dance();

			FlxG.sound.play(Paths.lSound('gameplay/' + introAssets[swagCounter + 4]), 0.6);
			if(introSprites[swagCounter] != null)
				introSpriteTween(introSprites[swagCounter], 3, Conductor.stepCrochet);

			swagCounter += 1;
		}, 5);
	}

	// bruuh
	// if a function is called once.
	// you should probably inline it.
	inline function startSong():Void
	{
		countingDown = false;

		FlxG.sound.music.play();
		vocals.play();
		// set everything to 0
		FlxG.sound.music.time = vocals.time = 0;
		Conductor.songPosition = -Settings.pr.offset;
		songTime = (-Settings.pr.offset) * songDiv;
	}

	// # note spawning
	private inline function generateSong():Void
	{
		for(section in SONG.notes)
		for(fNote in section.sectionNotes){
			var time:Float = fNote[0];
			var noteData :Int = Std.int(fNote[1]);
			var susLength:Int = Std.int(fNote[2]);
			var player   :Int = Std.int(fNote[3]);

			var newNote = new Note(time, noteData, false, false);
			newNote.scrollFactor.set();
			newNote.player = player;
			unspawnNotes.push(newNote);

			if(susLength > 1)
				for(i in 0...susLength+1){
					var susNote = new Note(time + i + 1, noteData, true, i == susLength);
					susNote.scrollFactor.set();
					susNote.player = player;
					unspawnNotes.push(susNote);
				}
		}

		unspawnNotes.sort((A,B) -> Std.int(A.strumTime - B.strumTime));
	}

	private function generateStaticArrows(player:Int, playable:Bool):Void
		for (i in 0...4)
		{
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);
			babyArrow.frames = Paths.lSparrow('gameplay/NOTE_assets');
			babyArrow.setGraphicSize(Math.round(babyArrow.width * 0.7));
			babyArrow.updateHitbox();
			babyArrow.alpha = 0;
			babyArrow.antialiasing = Settings.pr.antialiasing;

			babyArrow.x += Note.swagWidth * i;
			babyArrow.animation.addByPrefix('static', 'arrow' + sDir[i]);
			babyArrow.animation.addByPrefix('pressed', Note.colArr[i] + ' press'  , 24, false);
			babyArrow.animation.addByPrefix('confirm', Note.colArr[i] + ' confirm', 24, false);

			// hopefully caches the animation.
			babyArrow.animation.play('confirm');
			babyArrow.animation.play('pressed');
			playAnimAndCenter(babyArrow, 'static');

			babyArrow.x += 98;
			babyArrow.x += (FlxG.width / 2) * player;

			strumLineNotes.add(babyArrow);

			if(playable)
				playerStrums.add(babyArrow);
		}

	override function closeSubState()
	{
		if(paused){
			paused = false;

			FlxG.sound.music.play();
			vocals.play();
			syncEverything();
		}

		super.closeSubState();
	}

	function syncEverything(){
		var roundedTime:Float = FlxG.sound.music.time + (Conductor.songPosition + Settings.pr.offset) + vocals.time;
		roundedTime /= 3;

		FlxG.sound.music.time  = roundedTime;
		vocals.time            = roundedTime;
		Conductor.songPosition = roundedTime - Settings.pr.offset;
		songTime = Conductor.songPosition * songDiv;
	}

	// basically just used for strumline notes.
	private inline function playAnimAndCenter(spr:FlxSprite, anim:String){
		spr.animation.play(anim, true);
		spr.centerOffsets();
		spr.centerOrigin ();
	}

	var countingDown:Bool = false;
	// input stuff
	public var staleNotes:Array<Bool>    = [false,false,false,false];
	public var hittableNotes:Array<Note> = [null, null, null, null];
	public var keysPressed:Array<Bool>   = [false, false, false, false];
	public var lingeringPresses:Array<Float> = [0,0,0,0 ,0,0,0,0];

	// # input code.
	// please add any keys or stuff you want to add here.
	override function keyHit(ev:KeyboardEvent){
		super.keyHit(ev);

		if(paused) return;

		if(key == FlxKey.SEVEN){
			FlxG.switchState(new ChartingState());
			return;
		}
		if(key.deepCheck([NewControls.UI_ACCEPT, NewControls.UI_BACK]) != -1 && FlxG.sound.music.playing){
			// ADD PAUSING LATER!!!
			paused = true;
			FlxG.sound.music.pause();
			vocals.pause();

			openSubState(new PauseSubState(camHUD));
			return;
		}

		// this is the entire input system. Yep, it's that small.
		var nkey = key.deepCheck([NewControls.NOTE_LEFT, NewControls.NOTE_DOWN, NewControls.NOTE_UP, NewControls.NOTE_RIGHT]);
		if(nkey == -1 || keysPressed[nkey]) return;

		var magicNumber = nkey + (4 * playerPos);
		var noteWasHit:Bool = false;
		if(hittableNotes[nkey] != null){
			goodNoteHit(hittableNotes[nkey]);
			noteWasHit = true;

			// this is like an anti-anti mash? It will stop you from spamming far to fast.
			// it's also used for the bot.
			lingeringPresses[magicNumber] = Conductor.stepCrochet * 0.001;
		}

		keysPressed[nkey] = true;
		// this is your strumline stuff
		if(noteWasHit || lingeringPresses[magicNumber] != 0) return;

		playAnimAndCenter(playerStrums.members[nkey], 'pressed');
		if(!Settings.pr.ghost_tapping)
			noteMiss(nkey);
	}
	// just for the key release on input
	override public function keyRel(ev:KeyboardEvent){
		super.keyRel(ev);

		var nkey = key.deepCheck([NewControls.NOTE_LEFT, NewControls.NOTE_DOWN, NewControls.NOTE_UP, NewControls.NOTE_RIGHT]);
		if (nkey == -1) return;

		keysPressed[nkey] = false;
		playAnimAndCenter(playerStrums.members[nkey], 'static');
	}

	// # THE GRAND UPDATE FUNCTION!!!

	override public function update(elapsed:Float)
	{
		// keep it consistent accross framerates.
		FlxG.camera.followLerp = (1 - Math.pow(0.5, elapsed * 6)) * (60 / Settings.pr.framerate);

		super.update(elapsed);

		if(FlxG.sound.music.playing)
			songTime = Conductor.songPosition * songDiv;
		else if(countingDown)
			songTime += (elapsed * 1000) * songDiv;

		// all note / input stuff.
		for(i in 0...8){
			staleNotes[i % 4] = true;
			/////////////////////////////
			if(lingeringPresses[i] > 0){
				lingeringPresses[i] -= elapsed;
				continue;
			}
			if(lingeringPresses[i] == 0) continue;

			lingeringPresses[i] = 0;
			if(Math.floor(i / 4) != playerPos)
				playAnimAndCenter(strumLineNotes.members[i], 'static');
		}

		if (unspawnNotes[noteCount] != null && unspawnNotes[noteCount].strumTime - songTime < 64)
		{
			notes.add(unspawnNotes[noteCount]);
			noteCount++;
		}
		//hittableNotes = [null, null, null, null];
		notes.forEachAlive(function(daNote:Note){
			var dir = Settings.pr.downscroll ? 45 : -45;
			daNote.y = dir * (songTime - daNote.strumTime) * SONG.speed;
			daNote.y += strumLine.y;

			// 1.5 because we need room for the player to miss.
			daNote.visible = daNote.active = (daNote.height > -daNote.height * SONG.speed * 1.5) && (daNote.y < FlxG.height + (daNote.height * SONG.speed * 1.5));
			// skip checks if the note doesn't exist.
			if(!daNote.active) return;

			var strumRef = strumLineNotes.members[daNote.noteData + (4 * daNote.player)];

			if((daNote.player != playerPos || Settings.pr.botplay) && songTime >= daNote.strumTime){
				playingCharacters[daNote.player].playAnim('sing' + sDir[daNote.noteData], true);
				playingCharacters[daNote.player].idleNextBeat = false;
				
				vocals.volume = 1;

				if(Settings.pr.light_bot_strums){
					playAnimAndCenter(strumRef, 'confirm');
					lingeringPresses[daNote.noteData + (4 * daNote.player)] = Conductor.stepCrochet * 0.001;
				}

				notes.remove(daNote, true);
				daNote.destroy();
				return;
			}

			daNote.x     = strumRef.x + daNote.offsetX;
			daNote.angle = strumRef.angle;
			daNote.y    += daNote.offsetY;

			if(daNote.player != playerPos) return;

			if(songTime - daNote.strumTime > 2){
				noteMiss(daNote.noteData);
				vocals.volume = 0.5;
	
				notes.remove(daNote, true);
				daNote.destroy();
				return;
			}

			// this tells the actual input system if note exist.
			if (Math.abs(daNote.strumTime - songTime) < 1.8 && !daNote.isSustainNote && staleNotes[daNote.noteData]){
				hittableNotes[daNote.noteData] = daNote;
				staleNotes[daNote.noteData]    = false;
				return;
			}
			if(daNote.strumTime - songTime < -1.8){
				hittableNotes[daNote.noteData] = null;
				staleNotes[daNote.noteData] = true;
				return;
			}

			// sustain note input.
			if(daNote.isSustainNote && Math.abs(daNote.strumTime - songTime) < 0.5 && keysPressed[daNote.noteData]){
				goodNoteHit(daNote);
				return;
			}

		});
	}

	// # On note miss

	function noteMiss(direction:Int = 1):Void
	{
		if (combo > 20)
			gf.playAnim('sad');

		combo = 0;
		songScore -= 25;

		var missRandom:Int = Math.round(Math.random() * 2) + 1;
		FlxG.sound.play(Paths.lSound('gameplay/missnote' + missRandom), 0.2);

		playingCharacters[playerPos].playAnim('sing' + sDir[direction] + 'miss', true);
		playingCharacters[playerPos].idleNextBeat = false;

		updateHealth(Math.round(-Settings.pr.miss_health * 0.5));
	}

	// # On note hit.

	function goodNoteHit(note:Note):Void
	{
		hittableNotes[note.noteData] = null;
		playAnimAndCenter(playerStrums.members[note.noteData], 'confirm');
		playingCharacters[playerPos].playAnim('sing' + sDir[note.noteData], true);
		playingCharacters[playerPos].idleNextBeat = false;
		vocals.volume = 1;

		notes.remove(note, true);
		note.destroy();

		updateHealth(10);

		if(note.isSustainNote) return;

		popUpScore(note.strumTime);
	}

	// you can add your own scores.
	public var possibleScores:Array<RatingThing> = [
		{
			score: 350,
			threshold: 0,
			name: 'sick'
		},
		{
			score: 200,
			threshold: 0.4,
			name: 'good'
		},
		{
			score: 100,
			threshold: 0.7,
			name: 'bad'
		},
		{
			score: 25,
			threshold: 1.5,
			name: 'superbad'
		}
	];

	private inline function popUpScore(strumtime:Float):Void
	{
		var noteDiff:Float = Math.abs(strumtime - songTime);
		combo++;

		var pscore:RatingThing = null;
		for(i in 0...possibleScores.length)
			if(noteDiff >= possibleScores[i].threshold){
				pscore   = possibleScores[i];
			} else break;

		songScore += pscore.score;

		if(pscore.score < 50 || combo > 999)
			combo = 0;

		var ratingSpr:FlxSprite = new FlxSprite(0,0).loadGraphic(Paths.lImage('gameplay/' + pscore.name));
		ratingSpr.updateHitbox();
		ratingSpr.centerOrigin();
		ratingSpr.screenCenter();
		ratingSpr.scale.set(0.7, 0.7);
		ratingSpr.antialiasing = Settings.pr.antialiasing;
		add(ratingSpr);

		var comsplit:Array<String> = Std.string(combo).split('');

		for(i in 0...3){
			var char = '0';
			if(3 - comsplit.length <= i) char = comsplit[i + (comsplit.length - 3)];

			var numbSpr:FlxSprite = new FlxSprite(0,0).loadGraphic(Paths.lImage('gameplay/num$char'));
			numbSpr.updateHitbox();
			numbSpr.centerOrigin();
			numbSpr.screenCenter();
			numbSpr.y += 120;
			numbSpr.x += (i - 1) * 60;
			numbSpr.scale.set(0.6, 0.6);
			numbSpr.antialiasing = Settings.pr.antialiasing;
			add(numbSpr);

			introSpriteTween(numbSpr, 2, Conductor.stepCrochet * 0.5);
		}
		introSpriteTween(ratingSpr, 2, Conductor.stepCrochet * 0.5);
	}

	private static inline var iconSpacing:Int = 200;
	public function updateHealth(change:Int){
		scoreTxt.text = 'SCORE: ' + songScore;

		health = CoolUtil.boundTo(health + change, 0, 100, true);
		healthBar.percent = health;

		iconP1.x = healthBar.x + ((1 - (health * 0.01)) * healthBar.width);
		iconP1.x -= iconSpacing;
		iconP2.x = iconP1.x - (iconSpacing / 2);
		//iconP1.x += iconSpacing;

		// p1 icon
		var animStr = health < 20 ? 'losing' : 'neutral';
		iconP1.animation.play(animStr);
		// p2.
		animStr = health > 80 ? 'losing' : 'neutral';
		iconP2.animation.play(animStr);

		if(health > 0) return; 

		// ....

		// ADD DEATH CODE!!
	}

	// unfnished
	function endSong():Void
	{
		//canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;

		Highscore.saveScore(SONG.song, songScore, storyDifficulty);

		if (!isStoryMode){

			campaignScore += songScore;
			storyPlaylist.splice(0,1);

			if (storyPlaylist.length <= 0){
				// sotry menu code.
				PauseSubState.exitToProperMenu();
				return;
			}

			SONG = Song.loadFromJson(storyPlaylist[0], storyDifficulty);
			FlxG.sound.music.stop();
			FlxG.resetState();

			return;
		}
		PauseSubState.exitToProperMenu();
	}

	override function beatHit()
	{
		super.beatHit();

		/*
			Sorry but this is just flat out retarded.
			The fact that Null shouldn't be possible on static platforms,
			EXCEPT IT IS???? IT HAPPENS???

			So we basically have to turn it into a string and check it that way.
			I have no idea how this even is possible but it is, and it sucks.
		*/
		if(FlxG.sound.music.playing && curBeat % 4 == 0){
			mustHitSection = false;
			if (Std.string(SONG.notes[Math.floor(curBeat / 4)].mustHitSection) != 'null')
				mustHitSection = SONG.notes[Math.floor(curBeat / 4)].mustHitSection;

			camFollow.x = dad.getMidpoint().x + dad.camOffset[0];
			camFollow.y = dad.getMidpoint().y + dad.camOffset[1];
			if(mustHitSection){
				camFollow.x = boyfriend.getMidpoint().x + boyfriend.camOffset[0];
				camFollow.y = boyfriend.getMidpoint().y + boyfriend.camOffset[1];
			}
		}

		gf.dance();

		for(pc in playingCharacters)
			if(pc.idleNextBeat)
				pc.dance(true);
			else
				pc.idleNextBeat = true;
	}

	/*
		Step hit is not needed in playstate.
		If YOU need the function, just add it back
		In yourself.
	*/
}
typedef RatingThing = {
	var score:Int;
	var threshold:Float;
	var name:String;
}