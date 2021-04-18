import 'dart:ui';
import 'package:flame/components.dart';
import 'package:tankgame/place.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/cupertino.dart';
import 'package:flame/flame.dart';

class OrangeExplosion {
  final Place place;
  final List<Sprite> sprites = [];
  Offset position;
  Vector2 pos;

  int playIndex =0;

  bool playDone = false;

  OrangeExplosion(this.place,this.position){
    pos = Vector2(position.dx-15, position.dy-15); 
    for(int i=1;i<=5;i++){
      sprites.add(Sprite(Flame.images.fromCache('explosion/explosion'+i.toString()+'.webp')));
    }
  }


  void render(Canvas canvas) {
    if(playDone)return;
    if(playIndex<5){
      sprites[playIndex].render(canvas,position:pos,size:new Vector2(30,30));
    }
  }


  double passedTime = 0;

  void update(double t) {
    if(playDone) return;
    if(playIndex<5){
      //1秒 5张图片
      passedTime +=t;
      playIndex = passedTime ~/ 0.1;
    }else{
      playDone = true;
    }
  }
}