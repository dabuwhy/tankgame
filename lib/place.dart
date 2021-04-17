import 'dart:ui';
import 'package:flame/game.dart';
import 'package:flame/src/text_config.dart';
import 'package:tankgame/widgets/explosion.dart';
import 'package:tankgame/widgets/tank.dart';
import 'package:tankgame/widgets/bullet.dart';
import 'package:tankgame/widgets/wall.dart';
import 'package:flame/keyboard.dart';
import 'package:flutter/services.dart' show RawKeyDownEvent, RawKeyEvent, RawKeyUpEvent,LogicalKeyboardKey;
import 'dart:math';
import 'package:just_audio/just_audio.dart';

class Place extends Game with KeyboardEvents{
  static double placeWidth=480;
  static double placeHeight=320;
  final AudioPlayer player=AudioPlayer();
  final AudioPlayer bgm=AudioPlayer();
  final AudioPlayer move=AudioPlayer();
  TextConfig tScore;
  TextConfig tLife,tTime;
  int score=0,life=0;
  Tank tank;
  List<Tank> enemys=[];
  double baseX;
  List<Bullet> bullets= [];
  List<Wall> walls= [];
  List<OrangeExplosion> explosions = [];
  int startTime,addTime,nowTime;
  // Offset upperLeft=Offset(Tank.tankHalfWidth,Tank.tankHalfWidth),lowerright;
  int rightpadCount=0;
  var rand = Random();
  @override
  void render(Canvas c) {
    // 绘制草坪
    c.drawRect(
      Rect.fromLTWH(
        0,
        0,
        size.x,
        size.y,
      ),
      Paint()..color = Color(0xAf3CB371),
    );
    walls.forEach((element) {
      element.render(c);
    });
    tank.render(c);
    enemys.forEach((element) {element.render(c);});
    bullets.forEach((Bullet b) {
      b.render(c);
    });
    explosions.forEach((element) {
      element.render(c);
    });
    tScore.render(c,"kill:"+ this.score.toString(), Vector2(1,16));
    tLife.render(c,"cost:"+ this.life.toString(), Vector2(1,26));
    tTime.render(c,"time:"+ ((this.nowTime-this.startTime)~/1e6).toString(), Vector2(1,36));
  }

  @override
  void update(double t) {
    if (size == null) {
      // 如果screenSize为null, 直接结束执行即可.
      return;
    }
    nowTime=DateTime.now().microsecondsSinceEpoch;
    tank.update(t);
    bullets.forEach((Bullet b) {
      b.update(t);
    });
    bullets.removeWhere((Bullet b) {
      return b.isExplode;
    });
    //爆炸
    explosions.forEach((element) {element.update(t);});
    //移除爆炸
    explosions.removeWhere((element) => element.playDone);
    
    enemys.forEach((element) {
      // element.turretAngle=element.tankAngle;
      element.update(t);
      if(nowTime-element.prePosTime>0.5e6){ 
        element.prePosTime=nowTime;
        if(rand.nextInt(10)>6){
          element.handAngle=element.rightHandAngle;
        }
        if((element.prePosition-element.position).distanceSquared<=50*t||rand.nextInt(10)>5) {
          // print("change angle,dis:"+(element.prePosition-element.position).distanceSquared.toString());
          element.handAngle+=(rand.nextInt(3)-2);
          // element.handAngle=(element.handAngle>pi)?element.handAngle-2*pi:element.handAngle;
          // element.handAngle=(element.handAngle<=-pi)?element.handAngle+2*pi:element.handAngle;
        }
        else{
          element.prePosition=element.position;
        }
      }
      if(nowTime-element.preShotTime>=1e6){
        element.rightHandAngle=(tank.position-element.position).direction+2*(rand.nextDouble()-0.5);
        element.preShotTime=nowTime;
        if(rand.nextInt(10)>3){
          bullets.add(
            Bullet(this,position: element.getBulletOffset(),angle: element.getBulletAngle()),
          );
        }
      }
    });
    if(this.enemys.length<10&&(nowTime-this.addTime)>5e6){
      this.addTime=nowTime;
      this.enemys.add(Tank(this,Offset(placeWidth/2+Wall.brickWidth+baseX,placeHeight/2+Wall.brickWidth),nowTime,
        type:0,tankAngle: 3*(rand.nextDouble()-0.5),handAngle: 3*(rand.nextDouble()-0.5),turretAngle:3*(rand.nextDouble()-0.5),speedPercent: 0.6));
    }
  }

  @override
  Future<void> onLoad() async {
    this.rightpadCount=0;
    startTime=addTime=nowTime=DateTime.now().microsecondsSinceEpoch;
    tScore=TextConfig(fontSize: 18, textAlign: TextAlign.left,lineHeight: 0,fontFamily:'Awesome Font' );
    tLife=TextConfig(fontSize: 18, textAlign: TextAlign.left,lineHeight: 1,fontFamily:'Awesome Font' );
    tTime=TextConfig(fontSize: 18, textAlign: TextAlign.left,lineHeight: 2,fontFamily:'Awesome Font' );

    print(size);   //360,640   392.7,825.4   placeSize:placeHeight,placeWidth
    baseX=(size.y-placeWidth-2*Wall.brickWidth)/2;
    if (tank == null) {
      tank = Tank(this,Offset(baseX+Tank.tankHalfWidth+Wall.brickWidth,Tank.tankHalfWidth+Wall.brickWidth),startTime,type: 1,tankAngle: 0,turretAngle: 0);
    }
    // this.lowerright=Offset(size.y-Tank.tankHalfWidth,size.x-Tank.tankHalfWidth);
    //border
    this.addWalls(Offset(baseX,0),Offset(placeWidth+2*Wall.brickWidth+baseX,Wall.brickWidth),WallType.steel);
    this.addWalls(Offset(baseX,placeHeight+Wall.brickWidth),Offset(placeWidth+2*Wall.brickWidth+baseX,placeHeight+2*Wall.brickWidth),WallType.steel);
    this.addWalls(Offset(baseX,Wall.brickWidth),Offset(Wall.brickWidth+baseX,placeHeight+Wall.brickWidth),WallType.steel);
    this.addWalls(Offset(placeWidth+Wall.brickWidth+baseX,Wall.brickWidth),Offset(placeWidth+2*Wall.brickWidth+baseX,placeHeight+Wall.brickWidth),WallType.steel);
    //////map//////
    this.addWalls(Offset(baseX+Wall.brickWidth,Wall.brickWidth*6),Offset(baseX+200,320-Wall.brickWidth),WallType.brick);
    this.addWalls(Offset(baseX+300,100),Offset(baseX+350,250),WallType.steel);
    this.addWalls(Offset(baseX+400,100),Offset(baseX+450,250),WallType.water);
    // walls.add(Wall(this,Offset(50,50),Offset(150,150)));
    this.bgm.setAudioSource(ProgressiveAudioSource(Uri.parse("asset:///assets/sounds/bgm.mp3")));
    // this.bgm.setLoopMode(LoopMode.all);
    this.bgm.setVolume(0.2);
    this.bgm.play();
    this.move.setAudioSource(ProgressiveAudioSource(Uri.parse("asset:///assets/sounds/move.wav")));
    this.move.setLoopMode(LoopMode.all);
    this.move.setVolume(0.1);
  }

  void onLeftJoypadChange(Offset offset) {
    if (offset == Offset.zero) {
      tank.handAngle = null;
      this.move.pause();
    } else {
      tank.handAngle = offset.direction;
      if(!tank.rightTouch){
        tank.rightHandAngle=tank.handAngle;
      }
      this.move.play();
    }
    tank.speedPercent=sqrt(1-(offset.distanceSquared-2500)*(offset.distanceSquared-2500)/625e4); //offset.distanceSquared/2500;
  }
  void onRightJoypadChange(Offset offset){
    if (offset == Offset.zero) {
      tank.rightHandAngle = tank.handAngle;
      tank.rightTouch=false;
      tank.shotInterval=1e6;
    } else {
      tank.rightHandAngle = offset.direction;
      tank.rightTouch=true;
      tank.shotInterval=1-sqrt(1-(offset.distanceSquared-2500)*(offset.distanceSquared-2500)/625e4);
    }
    
    // rightpadCount++;
    // if(rightpadCount%128==2){
    //   rightpadCount+=(110*sqrt(1-(offset.distanceSquared-2500)*(offset.distanceSquared-2500)/625e4)).toInt(); //(offset.distanceSquared*100)~/2500;
    //   bullets.add(
    //     Bullet(this,
    //       position: tank.getBulletOffset(),
    //       angle: tank.getBulletAngle(),
    //     ),
    //   );
    // }
  }
  void onButtonTap() {
    tank.preShotTime=nowTime;
    bullets.add(
      Bullet(this,
        position: tank.getBulletOffset(),
        angle: tank.getBulletAngle(),
      ),
    );
  }
  void onLeftTapDown(){

  }
  void addWalls(Offset leftUp,Offset rightDown,WallType type){
    for(int i=0;i<(rightDown.dx-leftUp.dx)~/Wall.brickWidth;i++){
      for(int j=0;j<(rightDown.dy-leftUp.dy)~/Wall.brickWidth;j++){
        // print(i.toString()+' '+j.toString());
        walls.add(Wall(this,leftUp.translate(Wall.brickWidth*i,Wall.brickWidth*j),leftUp.translate(Wall.brickWidth*(i+1),Wall.brickWidth*(j+1)),type));
      }
    }
  }
  List<int> mKey=[0,0,0,0];
  @override
  void onKeyEvent(RawKeyEvent e) {
    final isKeyDown = e is RawKeyDownEvent;
    final isKeyUp=e is RawKeyUpEvent;
    if(isKeyDown){
      this.tank.speedPercent=1;
      if (e.data.logicalKey == LogicalKeyboardKey.keyW||e.data.logicalKey == LogicalKeyboardKey.arrowUp) {
        mKey[0]=1;
      } else if (e.data.logicalKey == LogicalKeyboardKey.keyS||e.data.logicalKey == LogicalKeyboardKey.arrowDown) {
        mKey[1]=1;
      } else if (e.data.logicalKey == LogicalKeyboardKey.keyA||e.data.logicalKey == LogicalKeyboardKey.arrowLeft) {
        mKey[2]=1;
      } else if (e.data.logicalKey == LogicalKeyboardKey.keyD||e.data.logicalKey == LogicalKeyboardKey.arrowRight) {
        mKey[3]=1;
      }else if(e.data.logicalKey==LogicalKeyboardKey.space||e.data.logicalKey==LogicalKeyboardKey.enter){
        this.onButtonTap();
      }
    }
    if(isKeyUp){
      this.tank.speedPercent=0;
      if (e.data.logicalKey == LogicalKeyboardKey.keyW||e.data.logicalKey == LogicalKeyboardKey.arrowUp) {
        mKey[0]=0;
      } else if (e.data.logicalKey == LogicalKeyboardKey.keyS||e.data.logicalKey == LogicalKeyboardKey.arrowDown) {
        mKey[1]=0;
      } else if (e.data.logicalKey == LogicalKeyboardKey.keyA||e.data.logicalKey == LogicalKeyboardKey.arrowLeft) {
        mKey[2]=0;
      } else if (e.data.logicalKey == LogicalKeyboardKey.keyD||e.data.logicalKey == LogicalKeyboardKey.arrowRight) {
        mKey[3]=0;
      }
    }
    if(mKey[0]==1&&mKey[2]==0&&mKey[3]==0){
      tank.handAngle=-pi/2;
    }else if(mKey[1]==1&&mKey[2]==0&&mKey[3]==0){
      tank.handAngle=pi/2;
    }else if(mKey[2]==1&&mKey[0]==0&&mKey[1]==0){
      tank.handAngle=pi;
    }else if(mKey[3]==1&&mKey[0]==0&&mKey[1]==0){
      tank.handAngle=0;
    }else if(mKey[0]==1&&mKey[2]==1){
      tank.handAngle=-3*pi/4;
    }else if(mKey[0]==1&&mKey[3]==1){
      tank.handAngle=-pi/4;
    }else if(mKey[1]==1&&mKey[3]==1){
      tank.handAngle=pi/4;
    }else if(mKey[1]==1&&mKey[2]==1){
      tank.handAngle=3*pi/4;
    }else{
      tank.handAngle = null;
    }
  }
}