import 'dart:ui';
import 'package:flame/game.dart';
import 'package:tankgame/place.dart';
import 'package:tankgame/widgets/wall.dart';
import 'package:tankgame/widgets/bullet.dart';
import 'dart:math';

class Tank {
  final Place place;
  int type=0,prePosTime;     //0:enemy 1:self
  Offset position = Offset.zero,prePosition= Offset.zero,lastPos;
  static double tankHalfWidth=15;
  double tankAngle = 0,cha;
  double turretAngle = 0;
  double handAngle;//=null;
  double rightHandAngle;
  double radian;
  bool rightTouch=false;
  double speedPercent=0,shotInterval=1;
  int preShotTime=0;
  Set<Wall> sWall;
  List<Paint> tankPaints=[];
  bool bInside;
  Tank(this.place, this.position,this.prePosTime,{this.type,this.tankAngle,this.handAngle,this.turretAngle,this.speedPercent}){
    this.prePosition=this.position;
    this.turretAngle=this.tankAngle;
    sWall=Set();
    this.shotInterval=1e6;
    this.preShotTime=place.nowTime;
    this.rightHandAngle=this.handAngle;
    this.rightTouch=false;
  }
  int poNeg;
  // 准备Paint对象
  Paint lightPaint = Paint()..color = Color(0xffdddddd);
  Paint yellowPaint = Paint()..color = Color(0xafCD6600);
  Paint enemyPaint = Paint()..color = Color(0xefCD3700);
  void render(Canvas c) {
    // 将canvas的原点设置在坦克的坐标上
    c.save();
    c.translate(position.dx, position.dy);
    // rotate the whole tank
    c.rotate(tankAngle);
    // 绘制坦克主体
    c.drawRect(Rect.fromLTWH(-12, -10, 24, 20),lightPaint);
    // 绘制轮子
    c.drawRect(Rect.fromLTWH(-15, -15, 30, 5),yellowPaint);
    c.drawRect(Rect.fromLTWH(-15, 10, 30, 5),yellowPaint);


    // 旋转炮台
    c.rotate(turretAngle-tankAngle);
    // 绘制炮塔
    c.drawRect(Rect.fromLTWH(7, -2, 13, 4),yellowPaint);
    c.drawRect(Rect.fromLTWH(20, -3, 4, 6),yellowPaint);
    if(this.type==0){
      c.drawCircle(Offset(0,0), 7, enemyPaint);
    }
    else if(this.type==1){
      c.drawRect(Rect.fromLTWH(-8, -7, 15, 14),yellowPaint);
    }
    c.restore();
  }

  void update(double t) {
    if(rightHandAngle!=null){
      final double rotationRate = pi*2*t;
      cha=(rightHandAngle-turretAngle);
      cha=(cha>pi)?cha-2*pi:cha;
      cha=(cha<-pi)?cha+2*pi:cha;
      if(cha!=0) {
        poNeg=cha~/cha.abs();
        turretAngle+=poNeg*rotationRate;
        turretAngle=((rightHandAngle-turretAngle)*poNeg<0&&turretAngle*rightHandAngle>0)?rightHandAngle:turretAngle;
        turretAngle=(turretAngle>pi)?turretAngle-2*pi:turretAngle;
        turretAngle=(turretAngle<=-pi)?turretAngle+2*pi:turretAngle;
      }
      if(place.nowTime-this.preShotTime>3e5+5e5*this.shotInterval){
        this.preShotTime=place.nowTime;
        place.bullets.add(
          Bullet(place,
            position: this.getBulletOffset(),
            angle: this.getBulletAngle(),
          ),
        );
      }
    }
    if(handAngle!=null){
      final double rotationRate = pi*2*t;
      cha=(handAngle-tankAngle);
      cha=(cha>pi)?cha-2*pi:cha;
      cha=(cha<-pi)?cha+2*pi:cha;
      if(cha!=0){ 
        poNeg=cha~/cha.abs();
        tankAngle+=poNeg*rotationRate;
        tankAngle=((handAngle-tankAngle)*poNeg<0&&tankAngle*handAngle>0)?handAngle:tankAngle;
        tankAngle=(tankAngle>pi)?tankAngle-2*pi:tankAngle;
        tankAngle=(tankAngle<=-pi)?tankAngle+2*pi:tankAngle;
      }
      bInside=false;
      for(var element in place.walls){
        if(element.judgeIn(position,Tank.tankHalfWidth)){
          radian=atan2(position.dy-element.mid.dy,position.dx-element.mid.dx);
          if(-3*pi/4<=radian&&radian<-pi/4){
            position+=Offset(0,(element.leftTopPos.dy-Tank.tankHalfWidth)-position.dy);
          }else if(pi/4<=radian&&radian<3*pi/4){
            position+=Offset(0,(element.rightBottomPos.dy+Tank.tankHalfWidth)-position.dy);
          }else if(-pi/4<=radian&&radian<pi/4){
            position+=Offset((element.rightBottomPos.dx+Tank.tankHalfWidth)-position.dx,0);
          }else{
            position+=Offset((element.leftTopPos.dx-Tank.tankHalfWidth)-position.dx,0);
          }
          // print("positon:"+position.toString());
          bInside=true;
        }
      }
      lastPos=position;
      if(bInside){
        sWall.clear();
        for(var element in place.walls){
          if(element.judgeIn(position,Tank.tankHalfWidth)){
            sWall.add(element);
          }
        }
        // if(sWall.length>1){
        //   var safeDis=Tank.tankHalfWidth+Wall.brickWidth/2;
        //   if(sWall.first.mid.dy==sWall.last.mid.dy){
        //     var subY=sWall.first.mid.dy-position.dy;
        //     if(safeDis>subY.abs()){    //插入缝隙
        //       if(tankAngle.abs()>pi/2){
        //         position=Offset(position.dx-0.1,sWall.first.mid.dy-subY/subY.abs()*safeDis);
        //       }else if(tankAngle.abs()<pi/2){
        //         position=Offset(position.dx+0.1,sWall.first.mid.dy-subY/subY.abs()*safeDis);
        //       }
        //     }
        //   }
        //   else if(sWall.first.mid.dx==sWall.last.mid.dx){
        //     var subX=sWall.first.mid.dx-position.dx;
        //     if(safeDis>subX.abs()){ //插入缝隙
        //       if(tankAngle>0){
        //         position=Offset(sWall.first.mid.dx-subX/subX.abs()*safeDis,position.dy+0.1);
        //       }if(tankAngle<0){
        //         position=Offset(sWall.first.mid.dx-subX/subX.abs()*safeDis,position.dy-0.1);
        //       }
        //     }
        //   }
        //   else{
        //     // print("not as my thought:"+sWall.first.mid.toString()+sWall.last.mid.toString());  //no move
        //   }
        // }
        if(sWall.length>0&&sWall.first.judgeContrast(position,tankAngle)){
          if(sWall.first.judgeX(position)){
            position+=Offset.fromDirection(0,(80-20*cha.abs())*t*cos(tankAngle)*speedPercent);
          }
          else{
            position+=Offset.fromDirection(pi/2,(80-20*cha.abs())*t*sin(tankAngle)*speedPercent);
          }
        }
        else position+=Offset.fromDirection(tankAngle,(80-20*cha.abs())*t*speedPercent);
      }
      else position+=Offset.fromDirection(tankAngle,(80-20*cha.abs())*t*speedPercent);
      place.enemys.forEach((element) {
        if(this!=element&&(this.position-element.position).distanceSquared<4*Tank.tankHalfWidth*Tank.tankHalfWidth){
          position=element.position+Offset.fromDirection((this.position-element.position).direction,2*Tank.tankHalfWidth);
          // position=lastPos;
        }
      });
      if(type==0){
        if((this.position-place.tank.position).distanceSquared<4*Tank.tankHalfWidth*Tank.tankHalfWidth){
          position=place.tank.position+Offset.fromDirection((this.position-place.tank.position).direction,2*Tank.tankHalfWidth);
          // position=lastPos;
        }
      }
    }
    if(position.dx<place.baseX||position.dx>place.baseX+Place.placeWidth+2*Wall.brickWidth||
       position.dy<0 || position.dy>Place.placeHeight+2*Wall.brickWidth){
      place.enemys.remove(this);
    }
  }

  double getBulletAngle() {
    return turretAngle;
  }
  Offset getBulletOffset() {
    return position + Offset.fromDirection(getBulletAngle(),16);
  }
}