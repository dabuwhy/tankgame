import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'package:tankgame/widgets/joypad.dart';
import 'package:tankgame/widgets/button.dart';
import 'package:flame/src/assets/assets_cache.dart';
import 'package:tankgame/place.dart';
import 'package:flame/flame.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 禁止所有UI层(设置全屏)
  SystemChrome.setEnabledSystemUIOverlays([]);
  loadAssets();
  final Place p=Place();
  // 设置屏幕方向(设置屏幕方向为横向) 
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((value) =>{
    runApp(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          children: [
            // 为游戏提供占位符
            GameWidget(
              game:p,
            ),
            // 摇杆层
            Column(
              children: [
                Spacer(),
                Row(
                  children: [
                    SizedBox(width: 30),
                    Joypad(
                      onChange: p.onLeftJoypadChange,
                      onTapD: p.onLeftTapDown,
                    ),
                    Spacer(),
                    // Button(
                    //   onTap: p.onButtonTap,
                    // ),  
                    Joypad(
                      onChange: p.onRightJoypadChange,
                      onTapD: p.onButtonTap,
                    ),                                                                     
                    SizedBox(width: 30),
                  ],
                ),
                SizedBox(height: 128),
              ],
            ),
          ],
        ),
      ),
    )
  });
  
  // 隐藏底部按钮栏
  // SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);
  // 隐藏状态栏
  // SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);

  // 运行APP
  
  
}
void loadAssets(){
  Flame.images.loadAll([
    'explosion/explosion1.webp',
    'explosion/explosion2.webp',
    'explosion/explosion3.webp',
    'explosion/explosion4.webp',
    'explosion/explosion5.webp',
  ]);
  // Flame.assets.readBinaryFile("explosion0.ogg");
  // Flame.assets.readBinaryFile("explosion1.wav");
}