import 'dart:ui';
import 'package:flame/game.dart';
import 'package:tankgame/place.dart';
import 'dart:math';

enum WallType{
  brick,
  steel,
  water,
}
class Wall {
  final Place place;
  WallType type;
  Offset leftTopPos,rightBottomPos,mid;
  static double brickWidth=16;
  double radian;
  List<Paint> paints=[];
  Paint brickPaint = Paint()..color = Color(0x9fD2691E);
  Paint steelPaint = Paint()..color = Color(0x9f8B7D7B);
  Paint waterPaint = Paint()..color = Color(0x9f1E70BF);
  Wall(this.place, this.leftTopPos,this.rightBottomPos,this.type){
    this.mid=(leftTopPos+rightBottomPos)/2;
    paints.add(brickPaint);
    paints.add(steelPaint);
    paints.add(waterPaint);
  }
  void render(Canvas c) {
    c.drawRect(
      Rect.fromLTRB(leftTopPos.dx,leftTopPos.dy,rightBottomPos.dx,rightBottomPos.dy),
      paints[this.type.index],
    );
  }

  void update(double t) {
    
  }
  bool judgeIn(Offset pos,double width){
    if(pos.dx>=leftTopPos.dx-width&&pos.dx<=rightBottomPos.dx+width&&
       pos.dy>=leftTopPos.dy-width&&pos.dy<=rightBottomPos.dy+width){
      return true;
    }
    else return false;
  }
  bool judgeContrast(Offset pos,double tankAngle){
    radian=atan2(pos.dy-mid.dy,pos.dx-mid.dx);
    // print(radian);
    if(pi/4<=radian.abs()&&radian.abs()<pi*3/4){
      if(radian*tankAngle<0){
        return true;
      }
      else return false;
    }
    else{
      if((radian.abs()-pi/4)*(tankAngle.abs()-pi/2)<0){
        return true;
      }
      else return false;
    }
  }
  bool judgeX(Offset pos){
    double tankTan=(pos.dy-mid.dy)/(pos.dx-mid.dx);
    double wallTan=(rightBottomPos.dy-leftTopPos.dy)/(rightBottomPos.dx-leftTopPos.dx);
    if(tankTan.abs()>=wallTan){
      return true;
    }
    else return false;
  }
}