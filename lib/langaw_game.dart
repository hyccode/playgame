import 'dart:math';
import 'dart:ui';

import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flutter/gestures.dart';
import 'package:playgame/components/backyard.dart';
import 'package:playgame/components/fly.dart';
import 'package:playgame/components/agile_fly.dart';
import 'package:playgame/components/drooler_fly.dart';
import 'package:playgame/components/hungry_fly.dart';
import 'package:playgame/components/macho_fly.dart';
import 'package:playgame/view.dart';
import 'package:playgame/views/credits-view.dart';
import 'package:playgame/views/help-view.dart';
import 'package:playgame/views/home-view.dart';
import 'package:playgame/views/lost-view.dart';

import 'components/credits-button.dart';
import 'components/help-button.dart';
import 'components/highscore-display.dart';
import 'components/house_fly.dart';
import 'components/music-button.dart';
import 'components/score-display.dart';
import 'components/sound-button.dart';
import 'components/start_button.dart';
import 'controllers/spawner.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

class LangawGame extends Game with TapDetector {
  Size screenSize;

  double tileSize;

  View activeView = View.home;

  HomeView homeView;

  List<Fly> flies;
  Random rnd;

  Backyard backyard;

  StartButton startButton;
  LostView lostView;

  FlySpawner spawner;

  HelpButton helpButton;
  CreditsButton creditsButton;
  HelpView helpView;
  CreditsView creditsView;

  ScoreDisplay scoreDisplay;

  int score;
  final SharedPreferences storage;

  HighscoreDisplay highscoreDisplay;

  AudioPlayer homeBGM;
  AudioPlayer playingBGM;

  MusicButton musicButton;
  SoundButton soundButton;

  LangawGame(this.storage) {
    initialize();
  }

  void initialize() async {
    score = 0;
    flies = [];
    rnd = Random();
    resize(await Flame.util.initialDimensions());

    spawner = FlySpawner(this);
    backyard = Backyard(this);
    homeView = HomeView(this);
    lostView = LostView(this);
    startButton = StartButton(this);

    helpButton = HelpButton(this);
    creditsButton = CreditsButton(this);

    musicButton = MusicButton(this);
    soundButton = SoundButton(this);

    helpView = HelpView(this);
    creditsView = CreditsView(this);

    scoreDisplay = ScoreDisplay(this);

    highscoreDisplay = HighscoreDisplay(this);

    homeBGM = await Flame.audio.loop('bgm/home.mp3', volume: .25);
    homeBGM.pause();
    playingBGM = await Flame.audio.loop('bgm/playing.mp3', volume: .25);
    playingBGM.pause();

    playHomeBGM();
  }

  void playHomeBGM() {
    playingBGM.pause();
    // playingBGM.seek(Duration.zero);
    homeBGM.resume();
  }

  void playPlayingBGM() {
    homeBGM.pause();
    // homeBGM.seek(Duration.zero);
    playingBGM.resume();
  }

  @override
  void resize(Size size) {
    screenSize = size;
    tileSize = screenSize.width / 9;
    super.resize(size);
  }

  @override
  void render(Canvas canvas) {
    backyard.render(canvas);
    highscoreDisplay.render(canvas);
    if (activeView == View.playing) scoreDisplay.render(canvas);

    flies.forEach((Fly fly) => fly.render(canvas));

    if (activeView == View.home) homeView.render(canvas);

    if (activeView == View.home || activeView == View.lost) {
      startButton.render(canvas);

      helpButton.render(canvas);
      creditsButton.render(canvas);
    }
    if (activeView == View.lost) lostView.render(canvas);

    musicButton.render(canvas);
    soundButton.render(canvas);

    if (activeView == View.help) helpView.render(canvas);
    if (activeView == View.credits) creditsView.render(canvas);
  }

  @override
  void update(double t) {
    flies.forEach((Fly fly) => fly.update(t));
    flies.removeWhere((Fly fly) => fly.isOffScreen);
    spawner.update(t);
    if (activeView == View.playing) scoreDisplay.update(t);
  }

  @override
  void onTapDown(TapDownDetails d) {
    bool isHandled = false;

    // 弹窗
    if (!isHandled) {
      if (activeView == View.help || activeView == View.credits) {
        activeView = View.home;
        isHandled = true;
      }
    }

    // 音乐按钮
    if (!isHandled && musicButton.rect.contains(d.globalPosition)) {
      musicButton.onTapDown();
      isHandled = true;
    }

    // 音效按钮
    if (!isHandled && soundButton.rect.contains(d.globalPosition)) {
      soundButton.onTapDown();
      isHandled = true;
    }

    //开始游戏按钮
    if (!isHandled && startButton.rect.contains(d.globalPosition)) {
      if (activeView == View.home || activeView == View.lost) {
        startButton.onTapDown();
        isHandled = true;
      }
    }

    //小飞蝇
    if (!isHandled) {
      bool didHitAFly = false;
      flies.forEach((Fly fly) {
        if (fly.flyRect.contains(d.globalPosition)) {
          fly.onTapDown();
          isHandled = true;
          didHitAFly = true;
        }
      });
      if (activeView == View.playing && !didHitAFly) {
        if (soundButton.isEnabled) {
          Flame.audio
              .play('sfx/haha' + (rnd.nextInt(5) + 1).toString() + '.ogg');
        }
        playHomeBGM();
        activeView = View.lost;
      }
    }

    // 教程按钮
    if (!isHandled && helpButton.rect.contains(d.globalPosition)) {
      if (activeView == View.home || activeView == View.lost) {
        helpButton.onTapDown();
        isHandled = true;
      }
    }

    // 感谢按钮
    if (!isHandled && creditsButton.rect.contains(d.globalPosition)) {
      if (activeView == View.home || activeView == View.lost) {
        creditsButton.onTapDown();
        isHandled = true;
      }
    }
  }

  void spawnFly() {
    double x = rnd.nextDouble() * (screenSize.width - (tileSize * 1.35));
    double y = (rnd.nextDouble() * (screenSize.height - (tileSize * 2.85))) +
        (tileSize * 1.5);
    switch (rnd.nextInt(5)) {
      case 0:
        flies.add(HouseFly(this, x, y));
        break;
      case 1:
        flies.add(DroolerFly(this, x, y));
        break;
      case 2:
        flies.add(AgileFly(this, x, y));
        break;
      case 3:
        flies.add(MachoFly(this, x, y));
        break;
      case 4:
        flies.add(HungryFly(this, x, y));
        break;
    }
  }
}
