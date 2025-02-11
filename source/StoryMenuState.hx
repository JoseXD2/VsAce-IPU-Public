package;

import flixel.system.FlxSound;
import flixel.input.gamepad.FlxGamepad;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;

using StringTools;

class StoryMenuState extends MusicBeatState
{
	var scoreText:FlxFixedText;

	var weekData:Array<Dynamic> = [
		['Concrete-Jungle', 'Noreaster', 'Sub-Zero'],
		['Groundhog-Day', 'Cold-Front', 'Cryogenic'],
		['Running-Laps', 'Icing-Tensions', 'Chill-Out', 'No-homo']
	];
	var curChar:Int = 0;
	var curDifficulty:Int = 1;
	public static var weekUnlocked:Array<Bool> = [true, true, true, true];
	public static var characterUnlocked:Array<Bool> = [true, true, true];

	//public static var unlockedSongs:Array<String> = [];
	//public static var unlockedChars:Array<String> = [];

	var unlocking:Bool = false;
	var unlockSprites:FlxTypedGroup<FlxSprite>;
	var unlockSprites2:FlxTypedGroup<FlxSprite>;
	var unlockSprites3:FlxTypedGroup<FlxSprite>;



	var weekCharacters:Array<Dynamic> = [
		['ace', 'bf', 'gf'],
		['ace', 'bf', 'gf'],
		['mace', 'mbf', '']
	];

	var weekNames:Array<String> = [
		"Ace",
		"Ace (Again)",
		"Mace"
	];

	var txtWeekTitle:FlxFixedText;

	public static var curWeek:Int = 0;

	var txtTracklist:FlxFixedText;

	var grpWeekText:FlxTypedGroup<StoryMenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	var grpLocks:FlxTypedGroup<AttachedSprite>;

	var characterSelectors:FlxGroup;
	var leftCharArrow:FlxSprite;
	var rightCharArrow:FlxSprite;
	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	// Unlock variables
	var shadeBG:FlxSprite;
	var aceIcon:HealthIcon;
	var unlockText:FlxFixedText;

	function unlockWeeks():Array<Bool>
	{
		var weeks:Array<Bool> = [true, true, true, true, true];

		weeks.push(true);

		for(i in 0...FlxG.save.data.weekUnlocked)
		{
			weeks.push(true);
		}
		return weeks;
	}

	override function create()
	{
		weekUnlocked = unlockWeeks();

		if(Stickers.newMenuItem.contains("storymode")) {
			Stickers.newMenuItem.remove("storymode");
			Stickers.save();
		}

		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Story Mode Menu", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (FlxG.sound.music == null || !FlxG.sound.music.playing)
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		Conductor.changeBPM(90);

		persistentUpdate = persistentDraw = true;

		scoreText = new FlxFixedText(10, 10, 0, "SCORE: 49324858", 36);
		scoreText.setFormat("VCR OSD Mono", 32);

		txtWeekTitle = new FlxFixedText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		var yellowBG:FlxSpriteExtra = new FlxSpriteExtra(0, 56).makeSolid(FlxG.width, 400, 0xFF8298EF); //totally yellow, yeah
		yellowBG.active = false;

		grpWeekText = new FlxTypedGroup<StoryMenuItem>();
		add(grpWeekText);

		var stickerItems = new FlxTypedGroup<AttachedSprite>();
		add(stickerItems);

		grpLocks = new FlxTypedGroup<AttachedSprite>();
		add(grpLocks);

		var blackBarThingie:FlxSpriteExtra = new FlxSpriteExtra().makeSolid(FlxG.width, 56, FlxColor.BLACK);
		blackBarThingie.active = false;
		add(blackBarThingie);

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		for (i in 0...weekData.length)
		{
			var weekThing:StoryMenuItem = new StoryMenuItem(0, yellowBG.y + yellowBG.height + 10, i);
			weekThing.y += ((weekThing.height + 20) * i);
			weekThing.targetY = i;
			grpWeekText.add(weekThing);

			weekThing.screenCenter(X);
			weekThing.antialiasing = FlxG.save.data.antialiasing;

			// Needs an offset thingie
			if (!weekUnlocked[i])
			{
				var lock:AttachedSprite = new AttachedSprite(/*weekThing.width + 10 + weekThing.x*/);
				lock.frames = ui_tex;
				lock.xAdd = weekThing.width + 10;
				lock.animation.addByPrefix('lock', 'lock');
				lock.animation.play('lock');
				lock.sprTracker = weekThing;
				lock.ID = i;
				lock.antialiasing = FlxG.save.data.antialiasing;
				grpLocks.add(lock);
			}

			if(Stickers.newWeeks.contains(i)) {
				var newSticker:AttachedSprite = new AttachedSprite(/*menuItem.width + 300, FlxG.height * 1.6*/);
				newSticker.frames = Paths.getSparrowAtlas('new_text', 'preload');
				newSticker.animation.addByPrefix('Animate', 'NEW', 24);
				newSticker.animation.play('Animate');
				newSticker.scrollFactor.set();
				newSticker.scale.set(0.33, 0.33);
				newSticker.updateHitbox();
				newSticker.sprTracker = weekThing;
				newSticker.xAdd = weekThing.width - newSticker.width/2;
				newSticker.yAdd = -newSticker.height/2;
				newSticker.copyVisible = true;
				//newSticker.useFrameWidthDiff = true;
				newSticker.antialiasing = FlxG.save.data.antialiasing;
				stickerItems.add(newSticker);
			}
		}

		grpWeekCharacters.add(new MenuCharacter(0, 100, 0.5, false));
		grpWeekCharacters.add(new MenuCharacter(450, 25, 0.9, true));
		grpWeekCharacters.add(new MenuCharacter(850, 100, 0.5, true));

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);
		difficultySelectors.visible = false;

		leftArrow = new FlxSprite(grpWeekText.members[0].x + grpWeekText.members[0].width + 10, grpWeekText.members[0].y + 10);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		difficultySelectors.add(leftArrow);

		sprDifficulty = new FlxSprite(leftArrow.x + 130, leftArrow.y);
		sprDifficulty.frames = ui_tex;
		sprDifficulty.animation.addByPrefix('easy', 'EASY');
		sprDifficulty.animation.addByPrefix('normal', 'NORMAL');
		sprDifficulty.animation.addByPrefix('hard', 'HARD');
		sprDifficulty.animation.addByPrefix('swapped', 'SWAPPED');
		sprDifficulty.animation.play('easy');
		changeDifficulty();

		difficultySelectors.add(sprDifficulty);

		rightArrow = new FlxSprite(sprDifficulty.x + sprDifficulty.width + 50, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		difficultySelectors.add(rightArrow);

		add(yellowBG);
		add(grpWeekCharacters);

		characterSelectors = new FlxGroup();
		add(characterSelectors);

		leftCharArrow = new FlxSprite(400, 200);
		leftCharArrow.frames = ui_tex;
		leftCharArrow.animation.addByPrefix('idle', "arrow left");
		leftCharArrow.animation.addByPrefix('press', "arrow push left");
		leftCharArrow.animation.play('idle');
		characterSelectors.add(leftCharArrow);

		rightCharArrow = new FlxSprite(850, 200);
		rightCharArrow.frames = ui_tex;
		rightCharArrow.animation.addByPrefix('idle', "arrow right");
		rightCharArrow.animation.addByPrefix('press', "arrow push right");
		rightCharArrow.animation.play('idle');
		characterSelectors.add(rightCharArrow);

		txtTracklist = new FlxFixedText(FlxG.width * 0.05, yellowBG.x + yellowBG.height + 100, Std.int(1280/3), "Tracks", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.font = Paths.font("vcr.ttf");
		txtTracklist.color = 0xFFBAE2FF;
		add(txtTracklist);
		add(scoreText);
		add(txtWeekTitle);

		//updateText();

		/*if (unlockedSongs.length > 0 || unlockedChars.length > 0)
		{
			shadeBG = new FlxSprite(0, 0).makeGraphic(1280, 720, FlxColor.BLACK);
			shadeBG.alpha = 0.9;
			shadeBG.visible = false;
			add(shadeBG);

			unlockSprites = new FlxTypedGroup<FlxSprite>();
			unlockSprites2 = new FlxTypedGroup<FlxSprite>();
			unlockSprites3 = new FlxTypedGroup<FlxSprite>();
			add(unlockSprites);
			add(unlockSprites2);
			add(unlockSprites3);

			unlockText = new FlxText(0, 500, 0, '', 42);
			unlockText.screenCenter(X);
			unlockText.visible = false;
			add(unlockText);

			displayUnlocks();
		}*/

		changeWeek(0, false);

		#if android
addVirtualPad(FULL, A_B);
#end
	
		super.create();
	}

	public var isChangingCharacter(get, never):Bool;
	function get_isChangingCharacter() {
		return characterSelectors.visible && characterSelectors.exists;
	}
	public var isChangingDifficulty(get, never):Bool;
	function get_isChangingDifficulty() {
		return !isChangingCharacter;
	}

	override function update(elapsed:Float)
	{
		// For animations on beat
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.5));

		scoreText.text = "WEEK SCORE:" + lerpScore;

		txtWeekTitle.text = weekNames[curWeek].toUpperCase();
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		//grpLocks.forEach(function(lock:FlxSprite)
		//{
		//	lock.y = grpWeekText.members[lock.ID].y;
		//});

		/*if (unlocking && !stopspamming)
		{
			if (controls.ACCEPT || controls.BACK)
			{
				stopspamming = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));

				// Remove the unlock group
				/*if (unlockedSongs.length > 0)
				{
					unlockedSongs = [];
				}*\/
				/*else if (unlockedChars.length > 0)
				{
					unlockedChars = [];
				}*\/

				for (i in 0...unlockSprites.length)
				{
					FlxTween.tween(unlockSprites.members[i], {alpha: 0}, 0.5);
					FlxTween.tween(unlockSprites2.members[i], {alpha: 0}, 0.5);
					FlxTween.tween(unlockSprites3.members[i], {alpha: 0}, 0.5);

				}
				FlxTween.tween(unlockText, {alpha: 0}, 0.5, {
					onComplete: function(flx:FlxTween)
					{
						unlockSprites.clear();
						//displayUnlocks();
					}
				});
			}
		}
		else*/
		{
			if (!movedBack)
			{
				if (!selectedWeek)
				{
					if (controls.RIGHT)
					{
						rightArrow.animation.play('press');
						rightCharArrow.animation.play('press');
					}
					else
					{
						rightArrow.animation.play('idle');
						rightCharArrow.animation.play('idle');
					}

					if (controls.LEFT)
					{
						leftArrow.animation.play('press');
						leftCharArrow.animation.play('press');
					}
					else
					{
						leftArrow.animation.play('idle');
						leftCharArrow.animation.play('idle');
					}

					if (controls.RIGHT_P)
					{
						if (isChangingDifficulty)
							changeDifficulty(1);
						else
							changeCharacter(1);
					}

					else if (controls.LEFT_P)
					{
						if (isChangingDifficulty)
							changeDifficulty(-1);
						else
							changeCharacter(-1);
					}

					if (controls.UP_P)
					{
						changeWeek(-1);
					}

					if (controls.DOWN_P)
					{
						changeWeek(1);
					}
				}

				if (controls.ACCEPT)
				{
					if (isChangingDifficulty || curWeek == 2)
						selectWeek();
					else
						changeSelection();
				}
			}

			if (controls.BACK && !movedBack && !selectedWeek)
			{
				if (isChangingDifficulty && curWeek != 2)
					changeSelection();
				else
				{
					FlxG.sound.play(Paths.sound('cancelMenu'));
					movedBack = true;
					FlxG.switchState(new MainMenuState());
				}
			}
		}

		super.update(elapsed);
	}

	override function beatHit()
	{
		super.beatHit();

		for (i in 0...grpWeekCharacters.length)
		{
			grpWeekCharacters.members[0].bopHead();
			grpWeekCharacters.members[1].bopHead();
			grpWeekCharacters.members[2].bopHead();
		}
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if(!weekUnlocked[curWeek]) return;
		if(stopspamming) return;

		FlxG.sound.play(Paths.sound('confirmMenu'));

		grpWeekText.members[curWeek].startFlashing();
		if (curWeek == 2) {// Minus Week
			//grpWeekCharacters.members[1].animation.play('mbfConfirm');
		} else if (curChar == 0) // BF
			grpWeekCharacters.members[1].animation.play('bfConfirm');
		else if (curChar == 1) // Ace BF
			grpWeekCharacters.members[1].animation.play('ace-bfConfirm');
		else // Retro BF
			grpWeekCharacters.members[1].animation.play('retro-bfConfirm');
		stopspamming = true;

		PlayState.storyPlaylist = weekData[curWeek];
		PlayState.isStoryMode = true;
		selectedWeek = true;

		PlayState.storyDifficulty = curDifficulty;

		if(Stickers.newWeeks.contains(curWeek)) {
			Stickers.newWeeks.remove(curWeek);
			Stickers.save();
		}

		// adjusting the song name to be compatible
		var songFormat = StringTools.replace(PlayState.storyPlaylist[0], " ", "-");

		var poop:String = Highscore.formatSong(songFormat, curDifficulty);
		PlayState.sicks = 0;
		PlayState.bads = 0;
		PlayState.shits = 0;
		PlayState.goods = 0;
		PlayState.campaignMisses = 0;
		PlayState.SONG = Song.loadFromJson(poop, PlayState.storyPlaylist[0]);
		PlayState.storyChar = curChar;
		PlayState.storyWeek = curWeek;
		PlayState.campaignScore = 0;
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			LoadingState.loadAndSwitchState(new PlayState(), true);
		});
	}

	function changeCharacter(change:Int = 0):Void
	{
		if (curWeek != 2)
		{
			curChar += change;

			if (curChar < 0)
				curChar = 2;
			if (curChar > 2)
				curChar = 0;

			switch (curChar)
			{
				case 0:
					grpWeekCharacters.members[1].setCharacter('bf');
				case 1:
					grpWeekCharacters.members[1].setCharacter('ace-bf');
				case 2:
					grpWeekCharacters.members[1].setCharacter('retro-bf');
			}

			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
	}

	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 3;
		if (curDifficulty > 3)
			curDifficulty = 0;

		/*if (curDifficulty < 0 && curWeek == 2)
			curDifficulty = 2;
		if (curDifficulty > 2 && curWeek == 2)
			curDifficulty = 0;*/

		sprDifficulty.offset.x = 0;

		switch (curDifficulty)
		{
			case 0:
				sprDifficulty.animation.play('easy');
				sprDifficulty.offset.x = 20;
			case 1:
				sprDifficulty.animation.play('normal');
				sprDifficulty.offset.x = 70;
			case 2:
				sprDifficulty.animation.play('hard');
				sprDifficulty.offset.x = 20;
			case 3:
				sprDifficulty.animation.play('swapped');
				sprDifficulty.offset.x = 70;
		}

		sprDifficulty.alpha = 0;

		// USING THESE WEIRD VALUES SO THAT IT DOESNT FLOAT UP
		sprDifficulty.y = leftArrow.y - 15;
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);

		FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07);
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	var isChangingChar = true;

	function changeSelection(silent:Bool = false)
	{
		//if (!characterUnlocked[curChar])
			//return;

		if (!isChangingChar)
		{
			difficultySelectors.visible = false;
			characterSelectors.visible = true;

			isChangingChar = true;

			if(!silent) FlxG.sound.play(Paths.sound('cancelMenu'));
		}
		else
		{
			difficultySelectors.visible = true;
			characterSelectors.visible = false;

			isChangingChar = false;

			if(!silent) FlxG.sound.play(Paths.sound('confirmMenu'));
		}
	}

	function changeWeek(change:Int = 0, playSound:Bool = true):Void
	{
		curWeek += change;

		if (curWeek >= weekData.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = weekData.length - 1;

		var bullShit:Int = 0;

		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			if (item.targetY == 0 && weekUnlocked[curWeek])
				item.alpha = 1;
			else
				item.alpha = 0.6;
			bullShit++;
		}

		if(curWeek == 2) {
			difficultySelectors.visible = true;
			characterSelectors.visible = false;
		} else {
			changeSelection(true);
			changeSelection(true);
		}

		if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'));

		updateText();
	}

	function updateText()
	{
		grpWeekCharacters.members[0].setCharacter(weekCharacters[curWeek][0]);
		grpWeekCharacters.members[1].setCharacter(weekCharacters[curWeek][1]);
		grpWeekCharacters.members[2].setCharacter(weekCharacters[curWeek][2]);

		txtTracklist.text = "Tracks\n";
		var stringThing:Array<String> = weekData[curWeek];

		for (i in stringThing)
			txtTracklist.text += "\n" + i;

		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;

		txtTracklist.text += "\n";

		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
	}

	// No
	/*public static function unlockNextWeek(week:Int):Void
	{
		if(week <= weekData.length - 1 && FlxG.save.data.weekUnlocked == week)
		{
			weekUnlocked.push(true);
			trace('Week ' + week + ' beat (Week ' + (week + 1) + ' unlocked)');
		}

		FlxG.save.data.weekUnlocked = weekUnlocked.length - 1;
		FlxG.save.flush();
	}*/

	/**
	 * Goes through the justUnlocked array and displays all of it in a little neat UI.
	 */
	/*function displayUnlocks()
	{
		unlocking = true;

		// Nothing left to unlock
		if (unlockedChars.length == 0)
		{
			FlxTween.tween(shadeBG, {alpha: 0}, 0.5);
			for (i in 0...unlockSprites.length)
			{
				FlxTween.tween(unlockSprites.members[i], {alpha: 0}, 0.5);
			}
			FlxTween.tween(unlockText, {alpha: 0}, 0.5, {
				onComplete: function(flx:FlxTween)
				{
					shadeBG.visible = false;
					unlockSprites.visible = false;
					unlockSprites2.visible = false;
					unlockSprites3.visible = false;
					unlockText.visible = false;
					remove(shadeBG);
					remove(unlockSprites);
					remove(unlockSprites2);
					remove(unlockSprites3);
					remove(unlockText);

					unlocking = false;
					stopspamming = false;
				}
			});
			return;
		}

		/*if (unlockedSongs.length <= 1)
			{
				FlxTween.tween(shadeBG, {alpha: 0}, 0.5);
				for (i in 0...unlockSprites.length)
				{
					FlxTween.tween(unlockSprites.members[i], {alpha: 0}, 0.5);
				}
				FlxTween.tween(unlockText, {alpha: 0}, 0.5, {
					onComplete: function(flx:FlxTween)
					{
						shadeBG.visible = false;
						unlockSprites.visible = false;
						unlockSprites2.visible = false;
						unlockSprites3.visible = false;
						unlockText.visible = false;
						remove(shadeBG);
						remove(unlockSprites);
						remove(unlockSprites2);
						remove(unlockSprites3);
						remove(unlockText);

						unlocking = false;
						stopspamming = false;
					}
				});
				return;
			}*/

	/*if (curWeek == 0)
	{
		if (unlockedSongs.length > 1)
		{
			// There's only one unlockable song (not anymore :( )
			var unlockSprite = new HealthIcon('ace-frost');
			unlockSprite.animation.curAnim.curFrame = 2;
			unlockSprite.screenCenter(XY);
			unlockSprites.add(unlockSprite);

			var unlockSprite2 = new HealthIcon('retro');
			unlockSprite2.animation.curAnim.curFrame = 1;
			unlockSprite2.screenCenter(XY);
			unlockSprite2.x += 200;
			unlockSprites2.add(unlockSprite2);

			var unlockSprite3 = new HealthIcon('sakuroma');
			unlockSprite3.animation.curAnim.curFrame = 1;
			unlockSprite3.screenCenter(XY);
			unlockSprite3.x -= 200;
			unlockSprites3.add(unlockSprite3);

			if (unlockSprite.alpha == 0)
			{
				FlxTween.tween(unlockSprite, {alpha: 1}, 0.5);
			}

			if (unlockSprite3.alpha == 0)
				{
					FlxTween.tween(unlockSprite, {alpha: 1}, 0.5);
				}

			if (unlockSprite2.alpha == 0)
				{
					FlxTween.tween(unlockSprite, {alpha: 1}, 0.5);
				}

			unlockText.text = 'New storms appear in Freeplay!';
			unlockText.screenCenter(X);

			if (unlockText.alpha == 0)
			{
				FlxTween.tween(unlockText, {alpha: 1}, 0.5);
			}

			shadeBG.visible = true;
			unlockText.visible = true;
			stopspamming = false;
			return;
		}
		else
		{
			for (i in 0...unlockedChars.length)
			{
				var unlockSprite = new FlxSprite();
				switch(unlockedChars[i])
				{
					// Characters
					case 'bf-retro':
						unlockSprite = new Character(0, 0, 'bf-retro');
						unlockSprite.scale.set(0.5, 0.5);
						var tex = Paths.getSparrowAtlas('characters/bf-retro', 'shared');
						unlockSprite.frames = tex;
						unlockSprite.animation.addByPrefix('idle', 'BF idle dance', 24, true); // Make it looped
						unlockSprite.animation.play('idle');
					case 'bf-ace':
						unlockSprite = new Character(0, 0, 'bf-ace');
						var tex = Paths.getSparrowAtlas('characters/bf-ace', 'shared');
						unlockSprite.scale.set(0.5, 0.5);
						unlockSprite.frames = tex;
						unlockSprite.animation.addByPrefix('idle', 'BF idle dance', 24, true); // Make it looped
						unlockSprite.animation.play('idle');
				}

				unlockSprite.screenCenter();
				unlockSprite.alpha = 0;
				if (unlockedChars.length % 2 == 1)
				{
					unlockSprite.x += (i - (unlockedChars.length - 1) / 2) * 350;
				}
				else
				{
					unlockSprite.x += 175 + ((i - (unlockedChars.length / 2)) * 350);
				}
				unlockSprites.add(unlockSprite);

				if (unlockSprite.alpha == 0)
				{
					FlxTween.tween(unlockSprite, {alpha: 1}, 0.5);
				}
			}

			unlockText.text = "New story character" + (unlockedChars.length == 1 ? '' : 's') + " unlocked!";
			unlockText.screenCenter(X);

			if (unlockText.alpha == 0)
			{
				FlxTween.tween(unlockText, {alpha: 1}, 0.5);
			}

			shadeBG.visible = true;
			unlockText.visible = true;
			stopspamming = false;
			return;
		}
	}

	else if (curWeek == 1)
		{
			if (unlockedSongs.length > 0)
			{
				// There's only one unlockable song (not anymore :( )
				var unlockSprite = new HealthIcon('ace-frost');
				unlockSprite.animation.curAnim.curFrame = 2;
				unlockSprite.screenCenter(XY);
				unlockSprites.add(unlockSprite);

				var unlockSprite2 = new HealthIcon('retro');
				unlockSprite2.animation.curAnim.curFrame = 1;
				unlockSprite2.screenCenter(XY);
				unlockSprite2.x += 200;
				unlockSprites2.add(unlockSprite2);

				var unlockSprite3 = new HealthIcon('sakuroma');
				unlockSprite3.animation.curAnim.curFrame = 1;
				unlockSprite3.screenCenter(XY);
				unlockSprite3.x -= 200;
				unlockSprites3.add(unlockSprite3);

				if (unlockSprite.alpha == 0)
				{
					FlxTween.tween(unlockSprite, {alpha: 1}, 0.5);
				}

				if (unlockSprite3.alpha == 0)
					{
						FlxTween.tween(unlockSprite, {alpha: 1}, 0.5);
					}

				if (unlockSprite2.alpha == 0)
					{
						FlxTween.tween(unlockSprite, {alpha: 1}, 0.5);
					}

				unlockText.text = 'New storms appear in Freeplay!';
				unlockText.screenCenter(X);

				if (unlockText.alpha == 0)
				{
					FlxTween.tween(unlockText, {alpha: 1}, 0.5);
				}

				shadeBG.visible = true;
				unlockText.visible = true;
				stopspamming = false;
				return;
			}
			else
				{
					for (i in 0...unlockedChars.length)
					{
						var unlockSprite = new FlxSprite();
						switch(unlockedChars[i])
						{
							// Characters
							case 'bf-retro':
								unlockSprite = new Character(0, 0, 'bf-retro');
								unlockSprite.scale.set(0.5, 0.5);
								var tex = Paths.getSparrowAtlas('characters/bf-retro', 'shared');
								unlockSprite.frames = tex;
								unlockSprite.animation.addByPrefix('idle', 'BF idle dance', 24, true); // Make it looped
								unlockSprite.animation.play('idle');
							case 'bf-ace':
								unlockSprite = new Character(0, 0, 'bf-ace');
								var tex = Paths.getSparrowAtlas('characters/bf-ace', 'shared');
								unlockSprite.scale.set(0.5, 0.5);
								unlockSprite.frames = tex;
								unlockSprite.animation.addByPrefix('idle', 'BF idle dance', 24, true); // Make it looped
								unlockSprite.animation.play('idle');
						}

						unlockSprite.screenCenter();
						unlockSprite.alpha = 0;
						if (unlockedChars.length % 2 == 1)
						{
							unlockSprite.x += (i - (unlockedChars.length - 1) / 2) * 350;
						}
						else
						{
							unlockSprite.x += 175 + ((i - (unlockedChars.length / 2)) * 350);
						}
						unlockSprites.add(unlockSprite);

						if (unlockSprite.alpha == 0)
						{
							FlxTween.tween(unlockSprite, {alpha: 1}, 0.5);
						}
					}

					unlockText.text = "New story character" + (unlockedChars.length == 1 ? '' : 's') + " unlocked!";
					unlockText.screenCenter(X);

					if (unlockText.alpha == 0)
					{
						FlxTween.tween(unlockText, {alpha: 1}, 0.5);
					}

					shadeBG.visible = true;
					unlockText.visible = true;
					stopspamming = false;
					return;
				}
		}*/
	//}*/
}
