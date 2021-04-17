import 'dart:ui';
import 'package:tankgame/place.dart';
import 'package:tankgame/widgets/explosion.dart';
import 'package:tankgame/widgets/wall.dart';
import 'package:tankgame/widgets/tank.dart';
import 'package:flame/src/assets/assets_cache.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:just_audio/just_audio.dart';

class Bullet {
  final Place place;
  final double speed = 300;
  Offset position;
  double angle = 0;
  int timeCount=0;
  bool isExplode = false;

  Bullet(this.place, {this.position, this.angle}){
    timeCount=0;
    // place.player.setAudioSource(ProgressiveAudioSource(Uri.parse("asset:///assets/sounds/explosion0.ogg"),duration:Duration(milliseconds: 500)));
    // place.player.play();
  }

  void render(Canvas c) {
    c.save();
    c.translate(position.dx, position.dy);
    // rotate the canvas
    c.rotate(angle);
    c.drawRect(
      Rect.fromLTWH(-2, -1, 4, 2),
      Paint()..color = Color(0xEE2C2C00),
    );
    c.restore();
  }

  void update(double t) {
    timeCount++;
    if (isExplode) {
      return;
    }
    position += Offset.fromDirection(angle, speed * t);
    if (position.dx <= 0||position.dx >= place.size.x ||
        position.dy <= 0||position.dy >= place.size.y ) {
      isExplode = true;
      place.explosions.add(OrangeExplosion(place,position));
    }
    else{
      for(var element in place.walls){
        if(element.type!=WallType.water){
          if(element.judgeIn(position,0)){
            isExplode = true;
            // print(timeCount);
            place.explosions.add(OrangeExplosion(place,position));
            // place.player.setAudioSource(ProgressiveAudioSource(Uri.parse("asset:///assets/sounds/explosion.wav"),duration:Duration(milliseconds: 500)));
            // place.player.play();
            if(element.type==WallType.brick){
              place.walls.remove(element);
            }
            return;
          }
        }
      }
      for(var element in place.enemys){
        if((element.position-this.position).distanceSquared<Tank.tankHalfWidth*Tank.tankHalfWidth){
          isExplode = true;
          place.explosions.add(OrangeExplosion(place,position));
          place.enemys.remove(element);
          place.score++;
          place.player.setVolume(1-timeCount/300);
          place.player.setAudioSource(ProgressiveAudioSource(Uri.parse("asset:///assets/sounds/explosion.wav")));
          place.player.play();
          return;
        }
      }
      if((place.tank.position-this.position).distanceSquared<Tank.tankHalfWidth*Tank.tankHalfWidth){
        isExplode = true;
        place.explosions.add(OrangeExplosion(place,position));
        place.tank.position = Offset(place.baseX+Tank.tankHalfWidth+Wall.brickWidth,Tank.tankHalfWidth+Wall.brickWidth);
        place.life++;
        place.player.setAudioSource(ProgressiveAudioSource(Uri.parse("asset:///assets/sounds/explosion.wav")));
        place.player.play();
        return;
      }
    }
  }
}