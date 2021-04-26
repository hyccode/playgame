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

import 'components/house_fly.dart';

class LangawGame extends Game with TapDetector {
  Size screenSize;

  double tileSize;

  List<Fly> flies;
  Random rnd;

  Backyard backyard;

  LangawGame() {
    initialize();
  }

  void initialize() async {
    flies = [];
    resize(await Flame.util.initialDimensions());

     backyard= Backyard(this);

    rnd = Random();
    spawnFly();
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

    flies.forEach((Fly fly) => fly.render(canvas));
  }

  @override
  void update(double t) {
    flies.forEach((Fly fly) => fly.update(t));
    flies.removeWhere((Fly fly) => fly.isOffScreen);
  }

  @override
  void onTapDown(TapDownDetails d) {
    flies.forEach((Fly fly) {
      if (fly.flyRect.contains(d.globalPosition)) {
        fly.onTapDown();
      }
    });
  }

  void spawnFly() {
    double x = rnd.nextDouble() * (screenSize.width - (tileSize * 2.025));
    double y = rnd.nextDouble() * (screenSize.height - (tileSize * 2.025));
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
    }  }
}
