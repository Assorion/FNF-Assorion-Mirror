package gameplay;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.system.FlxSound;
import flixel.graphics.FlxGraphic;
import flixel.input.keyboard.FlxKey;
import flixel.group.FlxGroup.FlxTypedGroup;
import lime.utils.Assets;
import gameplay.HealthIcon;
import backend.Highscore;
import backend.Song.SongData;
import backend.Song.SectionData;
import frontend.FreeplayState;
import frontend.ChartingState;

using StringTools;

typedef RatingData = {
	var score:Int;
	var threshold:Float;
	var name:String;
	var value:Int;
}

#if !debug @:noDebug #end
class PlayState extends MusicBeatState
{
	public static inline var beatHalfingTime:Int = 190;
	public static inline var inputRange:Float = 1.25; // The input range is measured in steps. By default it is 1 and a quarter steps of input range. 
	public static var sDir:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];

	public static var songName:String = '';
	public static var SONG:SongData;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var curDifficulty:Int = 1;
	public static var totalScore:Int = 0;
	public static var lastSeenCutscene:Int;

	public var strumLineY:Int;
	public var vocals:FlxSound;
	public var followPos:FlxObject;
	public var backwardsChartNotes:Array<Note> = [];

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var playerStrums:Array<StrumNote> = [];
	public var notes:FlxTypedGroup<Note>;

	// health now goes from 0 - 100, unlike the base game
	public var health   :Int = 50;
	public var combo    :Int = 0;
	public var hitCount :Int = 0;
	public var missCount:Int = 0;
	public var fcValue  :Int = 0;

	public var healthBarBG:StaticSprite;
	public var healthBar:HealthBar;
	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;

	public var paused:Bool = false;
	public var songScore:Int = 0;
	public var scoreTxt:FlxText;

	// TODO: Un-hardcode this. I admit this is terrible!
	private var characterPositions:Array<Int> = [
		100, 100, // Dad
		770, 450, // BF 
		400, 130  // GF
	];
	private var playerPos:Int = 1;
	private var allCharacters:Array<Character> = [];

	private static var stepTime:Float = 0;

	override public function create() {
		// # Camera Setup
		camGame = new FlxCamera();
		camHUD  = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		followPos = new FlxObject(0, 0, 1, 1);
		followPos.setPosition(FlxG.width / 2, FlxG.height / 2);

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxCamera.defaultCameras = [camGame];
		FlxG.camera.follow(followPos, LOCKON, 0.067);
		
		super.create();
		
		// # Song Setup
		songName = SONG.song.toLowerCase();
		Song.musicSet(SONG.bpm);

		vocals = new FlxSound();
		if (SONG.needsVoices)
			vocals.loadEmbedded(Paths.playableSong(songName, true));

		FlxG.sound.list.add(vocals);
		FlxG.sound.playMusic(Paths.playableSong(songName), 1, false);
		FlxG.sound.music.onComplete = endSong;
		FlxG.sound.music.stop();

		// # BG & UI setup
		playerPos = SONG.activePlayer;
		handleStage();

		strumLineY = Settings.downscroll ? FlxG.height - 150 : 50;
		strumLineNotes = new FlxTypedGroup<StrumNote>();
		notes = new FlxTypedGroup<Note>();
		add(strumLineNotes);
		add(notes);

		generateChart();
		for(i in 0...SONG.playLength)
			generateStrumArrows(i);

		// # Score setup
		for(i in 0...possibleScores.length)
			FlxGraphic.fromAssetKey(Paths.lImage('gameplay/${possibleScores[i].name}'), false, null, true).persist = true;

		ratingSpr = new StaticSprite(0,0);
		ratingSpr.scale.set(0.7, 0.7);
		ratingSpr.alpha = 0;
		add(ratingSpr);

		for(i in 0...3){
			var sRef = comboSprs[i] = new StaticSprite(0,0);
			sRef.frames = Paths.lSparrow('gameplay/comboNumbers');
			for(i in 0...10) 
				sRef.animation.addByPrefix('$i', '${i}num', 1, false);
			sRef.animation.play('0');
			sRef.centerOrigin();
			sRef.screenCenter();
			sRef.y += 120;
			sRef.x += (i - 1) * 60;
			sRef.scale.set(0.6, 0.6);
			sRef.alpha = 0;
			add(sRef);
		}

		// # UI Setup
		var baseY:Int = Settings.downscroll ? 80 : 650;

		healthBarBG = new StaticSprite(0, baseY).loadGraphic(Paths.lImage('gameplay/healthBar'));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();

		var healthColours:Array<Int> = [0xFFFF0000, 0xFF66FF33];
		healthBar = new HealthBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8));
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(healthColours[0], healthColours[1]);

		scoreTxt = new FlxText(0, baseY + 40, 0, PauseSubstate.botplayText, 20);
		scoreTxt.setFormat("assets/fonts/vcr.ttf", 16, 0xFFFFFFFF, CENTER, OUTLINE, 0xFF000000);
		scoreTxt.scrollFactor.set();
		scoreTxt.screenCenter(X);

		iconP1 = new HealthIcon(SONG.characters[1], true, true);
		iconP2 = new HealthIcon(SONG.characters[0], false, true);
		iconP1.y = baseY - (iconP1.height / 2);
		iconP2.y = baseY - (iconP2.height / 2);

		// # Add to cameras
		strumLineNotes.cameras = [camHUD];
		notes.cameras          = [camHUD];
		if(Settings.show_hud){
			add(healthBarBG);
			add(healthBar);
			add(scoreTxt);
			add(iconP1);
			add(iconP2);

			healthBar.cameras =
			healthBarBG.cameras =
			iconP1.cameras =
			iconP2.cameras = 
			scoreTxt.cameras = [camHUD];
		}

		stepTime = -16 - (((SONG.beginTime * 1000) + Settings.audio_offset) * Song.division);
		updateHealth(0);

		Song.beatHooks.push(beatHit);
		Song.stepHooks.push(stepHit);

		// If storyWeek is equal to -1 then it means that it's Freeplay. So if it's higher that means we're in story mode.
		if(storyWeek >= 0 && lastSeenCutscene != storyPlaylist.length){	
			lastSeenCutscene = storyPlaylist.length;

			var dialoguePath:String = 'assets/songs-data/${songName}/dialogue.json';			
			var potentialJson:Null<String> = Assets.exists(dialoguePath) ? Assets.getText(dialoguePath) : null;

			if(potentialJson != null) {
				// The delay is purely for the transitions. If your transitions are longer or shorter then change the event delay.	
				postEvent(0.5, function(){ pauseAndOpenState(new DialogueSubstate(this, camHUD, potentialJson)); });
				return;
			}
			
		}

		postEvent(SONG.beginTime + 0.1, startCountdown);
	}

	public inline function addCharacters() {
		for(i in 0...SONG.characters.length)
			allCharacters.push(new Character(characterPositions[i * 2], characterPositions[(i * 2) + 1], SONG.characters[i], i == 1));
		
		for(i in 0...SONG.characters.length)
			add(allCharacters[SONG.renderBackwards ? i : (SONG.characters.length - 1) - i]);
	}

	// If you need, you can edit the 'characterPositions' variable in here.
	public inline function handleStage() {
		switch(SONG.stage){
			case 'stage', '':
				FlxG.camera.zoom = 0.9;

				var bg:StaticSprite = new StaticSprite(-600, -200).loadGraphic(Paths.lImage('stages/stageback'));
					bg.setGraphicSize(Std.int(bg.width * 2));
					bg.updateHitbox();
					bg.scrollFactor.set(0.9, 0.9);
				add(bg);
				var stageFront:StaticSprite = new StaticSprite(-650, 600).loadGraphic(Paths.lImage('stages/stagefront'));
					stageFront.setGraphicSize(Std.int(stageFront.width * 2.2));
					stageFront.updateHitbox();
					stageFront.scrollFactor.set(0.9, 0.9);
				add(stageFront);
				var curtainLeft:StaticSprite = new StaticSprite(-500, -165).loadGraphic(Paths.lImage('stages/curtainLeft'));
					curtainLeft.setGraphicSize(Std.int(curtainLeft.width * 1.8));
					curtainLeft.updateHitbox();
					curtainLeft.scrollFactor.set(1.3, 1.3);
				add(curtainLeft);
				var curtainRight:StaticSprite = new StaticSprite(1406, -165).loadGraphic(Paths.lImage('stages/curtainRight'));
					curtainRight.setGraphicSize(Std.int(curtainRight.width * 1.8));
					curtainRight.updateHitbox();
					curtainRight.scrollFactor.set(1.3, 1.3);
				add(curtainRight);

				addCharacters();
		}
	}

	private inline function generateChart():Void {
		for(section in SONG.notes)
			for(fNote in section.sectionNotes){
				var time:Float = fNote[0];
				var noteData :Int = Std.int(fNote[1]);
				var susLength:Int = Std.int(fNote[2]);
				var player   :Int = CoolUtil.intBoundTo(Std.int(fNote[3]), 0, SONG.playLength - 1);
				var ntype    :Int = Std.int(fNote[4]);

				var newNote = new Note(time, noteData, ntype, false, false);
				newNote.scrollFactor.set();
				newNote.player = player;
				backwardsChartNotes.insert(0, newNote);

				if(susLength > 1)
					for(i in 0...susLength+1){
						var susNote = new Note(time + i + 0.5, noteData, ntype, true, i == susLength);
						susNote.scrollFactor.set();
						susNote.player = player;
						backwardsChartNotes.insert(0, susNote);
					}
			}

		// Sort the array backwards, and then pop it and insert that into the first index.
		backwardsChartNotes.sort((A,B) -> Std.int(B.strumTime - A.strumTime));
		backwardsChartNotes.insert(0, backwardsChartNotes.pop());
	}

	private function generateStrumArrows(player:Int):Void
	for (i in 0...Note.keyCount)
	{
		var babyArrow:StrumNote = new StrumNote(0, strumLineY - 10, i, player);
		babyArrow.alpha = 0;

		strumLineNotes.add(babyArrow);
		if(SONG.activePlayer == player) 
			playerStrums[i] = babyArrow;
	}
	
	public function startCountdown():Void {
		for(i in 0...strumLineNotes.length)
			FlxTween.tween(strumLineNotes.members[i], {alpha: 1, y: strumLineNotes.members[i].y + 10}, 0.5, {startDelay: ((i % Note.keyCount) + 1) * 0.2});

		var introSprites:Array<StaticSprite> = [];
		var introSounds:Array<FlxSound>   = [];
		var introAssets :Array<String>    = [
			'ready', 'set', 'go', '',
			'intro3', 'intro2', 'intro1', 'introGo'
		];
 
		for(i in 0...4){
			var snd:FlxSound = new FlxSound().loadEmbedded(Paths.lSound('gameplay/' + introAssets[i + Std.int(introAssets.length * 0.5)]));
				snd.volume = 0.6;
			introSounds[i] = snd;

			if(introAssets[i] == '') continue;

			var spr:StaticSprite = new StaticSprite().loadGraphic(Paths.lImage('gameplay/${ introAssets[i] }'));
				spr.cameras = [camHUD];
				spr.screenCenter();
				spr.alpha = 0;
			add(spr);

			introSprites[i+1] = spr;
		}

		var swagCounter:Int = 0;
		for(i in 0...5)
			postEvent(((Song.crochet * (i + 1)) + Settings.audio_offset) * 0.001, function(){
				if(swagCounter >= 4){
					FlxG.sound.music.play();
					FlxG.sound.music.volume = 1;
					Song.millisecond = -Settings.audio_offset;
	
					vocals.play();
					vocals.time = FlxG.sound.music.time = 0;
					return;
				}

				for(pc in allCharacters)
					pc.dance();
	
				stepTime = (swagCounter - 4) * 4;
				stepTime -= Settings.audio_offset * Song.division;
	
				introSounds[swagCounter].play();
				if(introSprites[swagCounter] != null)
					introSpriteTween(introSprites[swagCounter], 3, Song.stepCrochet, true);
	
				swagCounter++;
			});
	}

	override public function update(elapsed:Float) if(!paused) {
		Song.update(FlxG.sound.music.time);
		stepTime += elapsed * 1000 * Song.division;

		if(backwardsChartNotes.length > 1 && backwardsChartNotes[0].strumTime - stepTime < 32){
			// To be clear, the notes appear backwards (so earlier notes in the chart are furthest in the array). But the first index of the
			// array is always equal to the last note that was popped. If you don't know what pop means, it removes the last element and returns it
			notes.add(backwardsChartNotes[0]);
			backwardsChartNotes[0] = backwardsChartNotes.pop();	
		}

		notes.forEachAlive(scrollNotes);

		super.update(elapsed);
	}

	public function beatHit() {
		#if (flixel < "5.4.0")
		FlxG.camera.followLerp = (1 - Math.pow(0.5, FlxG.elapsed * 6)) * (60 / Settings.framerate);
		#end

		var sec:SectionData = SONG.notes[Song.currentBeat >> 2]; // "curBeat >> 2" is the same as "Math.floor(curBeat / 4)", but faster
		if(Song.currentBeat & 3 == 0 && FlxG.sound.music.playing){
			// prevent the Int from being null, if it is it will just be 0.
			var tFace:Int = sec != null ? cast(sec.cameraFacing, Int) : 0;
			var char = allCharacters[CoolUtil.intBoundTo(tFace, 0, SONG.playLength - 1)];

			followPos.x = char.getMidpoint().x + char.camOffset[0];
			followPos.y = char.getMidpoint().y + char.camOffset[1];
		}
	}
	public function stepHit() 
		if(FlxG.sound.music.playing)
			stepTime = (Song.millisecond * Song.division * 0.25) + (stepTime * 0.75);

	private static inline var iconSpacing:Int = 52;
	public function updateHealth(change:Int) {
		if(!Settings.botplay) {
			var fcText:String = ['?', 'SFC', 'GFC', 'FC', '(Bad) FC', 'SDCB', 'Clear'][fcValue];
			var accuracyCount:Float = CoolUtil.boundTo(Math.floor((songScore * 100) / ((hitCount + missCount) * 3.5)) * 0.01, 0, 100);

			scoreTxt.text = 'Notes Hit: $hitCount | Notes Missed: $missCount | Accuracy: $accuracyCount% - $fcText | Score: $songScore';
		}
		scoreTxt.screenCenter(X);
		
		health = CoolUtil.intBoundTo(health + change, 0, 100);
		healthBar.percent = health;
		
		var calc = ((0 - ((health - 50) * 0.01)) * healthBar.width) + 565;
		iconP1.x = calc + iconSpacing; 
		iconP2.x = calc - iconSpacing;
		iconP1.changeState(health < 20 ? 0 : 1);
		iconP2.changeState(health > 80 ? 0 : 1);

		if(health != 0)
			return;

		remove(allCharacters[playerPos]);
		pauseAndOpenState(new GameOverSubstate(allCharacters[playerPos], camHUD, this));
	}

	function hitNote(note:Note):Void {
		destroyNote(note, 0);

		if(!note.curType.mustHit){
			missNote(note.noteData);
			return;
		}

		playerStrums[note.noteData].playAnim(2);
		allCharacters[playerPos].playAnim('sing' + sDir[note.noteData]);
		vocals.volume = 1;

		if(!note.isSustainNote){
			hitCount++;
			popUpScore(note.strumTime);
		}
		
		updateHealth(5);
	}

	function missNote(direction:Int = 1):Void {
		combo = 0;
		songScore -= 50;
		missCount++;
		vocals.volume = 0.5;

		FlxG.sound.play(Paths.lSound('gameplay/missnote' + (Math.round(Math.random() * 2) + 1)), 0.2);

		allCharacters[playerPos].playAnim('sing' + sDir[direction] + 'miss');
		fcValue = missCount >= 10 ? 6 : 5;

		updateHealth(-10);
	}

	// For anything that would require keyboard input, please put it here, not in update.

	public var hittableNotes:Array<Note> = [null, null, null, null];
	public var keysPressed:Array<Bool>   = [false, false, false, false];
	public var keysArray:Array<Array<Int>> = [Binds.NOTE_LEFT, Binds.NOTE_DOWN, Binds.NOTE_UP, Binds.NOTE_RIGHT];
	override function keyHit(ev:KeyboardEvent) if(!paused) {
		// Assorions "Fast" input system
		var nkey = ev.keyCode.deepCheck(keysArray);
		if(nkey >= 0 && !keysPressed[nkey] && !Settings.botplay){
			var strumRef = playerStrums[nkey];
			keysPressed[nkey] = true;
			
			if(hittableNotes[nkey] != null){
				hitNote(hittableNotes[nkey]);
				strumRef.pressTime = Song.stepCrochet * 0.00075;
			} 
			else if(strumRef.pressTime <= 0){
				strumRef.playAnim(1);

				if(!Settings.ghost_tapping)
					missNote(nkey);
			}

			return;
		}

		var k = ev.keyCode.deepCheck([Binds.UI_ACCEPT, Binds.UI_BACK, [FlxKey.SEVEN]]);
		
		switch(k){
			case 0, 1:
				if(FlxG.sound.music.playing)
					pauseAndOpenState(new PauseSubstate(camHUD, this));
			case 2:
				MusicBeatState.changeState(new ChartingState());
		}
	}
	override public function keyRel(ev:KeyboardEvent) {
		var nkey = ev.keyCode.deepCheck(keysArray);

		if (nkey != -1 && !paused){
			keysPressed[nkey] = false;
			playerStrums[nkey].playAnim();
		}
	}

	private inline function scrollNotes(daNote:Note) {
		var nDiff:Float = stepTime - daNote.strumTime;
		daNote.y = (Settings.downscroll ? 45 : -45) * nDiff * SONG.speed;
		daNote.y += strumLineY + daNote.offsetY;

		daNote.visible = Settings.downscroll ? (daNote.y >= -daNote.height * daNote.scale.y) : (daNote.y <= FlxG.height);
		if(!daNote.visible) 
			return;

		var strumRef = strumLineNotes.members[daNote.noteData + (Note.keyCount * daNote.player)];

		daNote.x = strumRef.x + daNote.offsetX;
		daNote.angle = strumRef.angle;
		
		// # NPC Note Logic
		if((daNote.player != playerPos || Settings.botplay) && stepTime >= daNote.strumTime && daNote.curType.mustHit){
			allCharacters[daNote.player].playAnim('sing' + sDir[daNote.noteData]);
			strumRef.playAnim(2);
			strumRef.pressTime = Song.stepCrochet * 0.001;
			vocals.volume = 1;

			notes.remove(daNote, true);
			daNote.destroy();
			return;
		}

		// # Player Note Logic
		if(daNote.player != playerPos || Settings.botplay) 
			return;

		if(nDiff > inputRange){
			if(daNote.curType.mustHit)
				missNote(daNote.noteData);
			
			destroyNote(daNote, 1);
			return;
		}

		// Input range checks
		if (hittableNotes[daNote.noteData] == null && !daNote.isSustainNote && Math.abs(nDiff) <= inputRange * daNote.curType.rangeMul){
			hittableNotes[daNote.noteData] = daNote;
			return;
		}

		if(daNote.isSustainNote && Math.abs(nDiff) < 0.8 && keysPressed[daNote.noteData])
			hitNote(daNote);
	}

	public static var possibleScores:Array<RatingData> = [
		{
			score: 350,  
			threshold: 0,
			name: 'sick',
			value: 1
		},
		{
			score: 200,      // Points to give
			threshold: 0.45, // Threshold of a step where you get the score, E:G less than half a step.
			name: 'good',    // Asset to load
			value: 2         // FC Value
		},
		{
			score: 100,
			threshold: 0.65,
			name: 'bad',
			value: 3
		},
		{
			score: 25,
			threshold: 1,
			name: 'superbad',
			value: 4
		}
	];
	private var ratingSpr:StaticSprite;
	private var previousValue:Int;
	private var comboSprs:Array<StaticSprite> = [];
	private var scoreTweens:Array<FlxTween> = [];
	private inline function popUpScore(strumtime:Float):Void {
		var noteDiff:Float = Math.abs(strumtime - (stepTime - (Settings.input_offset * Song.division)));
		var pscore:RatingData = possibleScores[0];

		for(i in 1...possibleScores.length)
			if(noteDiff >= possibleScores[i].threshold){
				pscore   = possibleScores[i];
			} else break;

		songScore += pscore.score;
		combo = pscore.score > 50 && combo < 1000 ? combo + 1 : 0;

		if(pscore.value > fcValue)
			fcValue = pscore.value;

		// Everything below here is to handle graphics.

		if(scoreTweens[0] != null)
			for(i in 0...4) scoreTweens[i].cancel();

		if(previousValue != pscore.value){
			ratingSpr.loadGraphic(Paths.lImage('gameplay/' + pscore.name));
			ratingSpr.centerOrigin();
			previousValue = pscore.value;
		}
		ratingSpr.screenCenter();

		var comsplit:Array<String> = Std.string(combo).split('');
		for(i in 0...3){
			var sRef = comboSprs[i];
			sRef.animation.play((3 - comsplit.length <= i) ? comsplit[i + (comsplit.length - 3)] : '0');
			sRef.screenCenter(Y);
			sRef.y += 120;

			scoreTweens[i+1] = introSpriteTween(sRef, 3, Song.stepCrochet * 0.5, false);
		}
		scoreTweens[0] = introSpriteTween(ratingSpr, 3,  Song.stepCrochet * 0.5, false);
	}

	function endSong():Void {
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		paused = true;

		Highscore.saveScore(SONG.song, songScore, curDifficulty);

		if (storyWeek == -1){ // If it's freeplay
			CoolUtil.exitPlaystate();
			return;
		}
		
		totalScore += songScore;
		storyPlaylist.shift();

		if (storyPlaylist.length <= 0){ // If the story week is out of songs
			Highscore.saveScore('week-$storyWeek', totalScore, curDifficulty);
			CoolUtil.exitPlaystate();
			return;
		}

		SONG = Song.loadFromJson(storyPlaylist[0], curDifficulty);
		FlxG.sound.music.stop();
		MusicBeatState.changeState(new PlayState());
	}

	function pauseAndOpenState(state:MusicBeatSubstate) {
		paused = true;
		FlxG.sound.music.pause();
		vocals.pause();

		openSubState(state);
	}

	inline function destroyNote(note:Note, act:Int) {
		note.typeAction(act);
		notes.remove(note, true);
		note.destroy();

		if (hittableNotes[note.noteData] == note)
			hittableNotes[note.noteData] = null;
	}

	private inline function introSpriteTween(spr:StaticSprite, steps:Int, delay:Float = 0, destroy:Bool):FlxTween {
		spr.alpha = 1;
		return FlxTween.tween(spr, {y: spr.y + 10, alpha: 0}, (steps * Song.stepCrochet) / 1000, { ease: FlxEase.cubeInOut, startDelay: delay * 0.001,
			onComplete: function(twn:FlxTween)
			{
				if(destroy)
					spr.destroy();
			}
		});
	}

	override function onFocusLost() {
		super.onFocusLost();

		if(!paused && FlxG.sound.music.playing)
			pauseAndOpenState(new PauseSubstate(camHUD, this));
	}
}
