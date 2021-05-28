import 'dart:ui';

import 'package:flame/sprite.dart';

import '../langaw_game.dart';
import 'fly.dart';

class MachoFly extends Fly {
  double get speed => game.tileSize * 2.5;

  MachoFly(LangawGame game, double x, double y) : super(game) {
    flyRect = Rect.fromLTWH(x, y, game.tileSize * 1.35, game.tileSize * 1.35);
    flyingSprite = [];
    flyingSprite.add(Sprite('flies/macho-fly-1.png'));
    flyingSprite.add(Sprite('flies/macho-fly-2.png'));
    deadSprite = Sprite('flies/macho-fly-dead.png');
  }
}
