import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/main.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/views/favorite_page.dart';
import 'package:onlinemusic/views/home_page.dart';
import 'package:onlinemusic/views/library_page.dart';
import 'package:onlinemusic/views/playing_screen/playing_screen.dart';
import 'package:onlinemusic/views/share_song_page.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class RootApp extends StatefulWidget {
  RootApp({Key? key}) : super(key: key);

  @override
  State<RootApp> createState() => _RootAppState();
}

class _RootAppState extends State<RootApp> {
  PageController _pageController = PageController();
  final _bottomPageNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    AudioService.notificationClicked.listen((clicked) {
      if (clicked) {
        BuildContext? navigatorContext = MyApp.navigatorKey.currentContext;
        if (navigatorContext != null) {
          print(PlayingScreen.isRunning);
          if (!PlayingScreen.isRunning) {
            navigatorContext.push(PlayingScreen());
          }
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        onPageChanged: (s) {
          _bottomPageNotifier.value = s;
        },
        children: [
          if(isConnectivity!)
          HomePage(),
          FavoritePage(),
          
          LibraryPage(),
        ],
      ),
      
      floatingActionButton: isConnectivity!? ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 5,
            sigmaY: 5,
          ),
          child: FloatingActionButton.extended(
            extendedIconLabelSpacing: 0,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
                side: BorderSide(
                  color: Const.kPurple,
                  width: 2,
                )),
            backgroundColor: Const.kPurple.withOpacity(0.5),
            label: Text(
              "Yayınla ",
              style: TextStyle(
                  color: Const.kWhite,
                  fontWeight: FontWeight.bold,
                  
                  letterSpacing: 0.4,
                  fontSize: 16),
            ),
            onPressed: () {
              context.push(ShareSongPage());
            },
            icon: Icon(Icons.add, color: Const.kWhite,),
          ),
        ),
      ) :SizedBox(),
      bottomNavigationBar: ValueListenableBuilder<int>(
          valueListenable: _bottomPageNotifier,
          builder: (context, v, snapshot) {
            return Container(
              margin: EdgeInsets.only(left:8,right: 8,bottom: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                BoxShadow(
                  color: Const.kPurple.withOpacity(0.4),
                  blurRadius: 2,
                  offset: Offset(0, 0),
                ),
              ], color: Colors.white),
              child: SalomonBottomBar(
                itemPadding: EdgeInsets.symmetric(vertical: 7, horizontal: 20),
                currentIndex: v,
                onTap: (i) {
                  _pageController.jumpToPage(i);
                },
                items: [
                  if(isConnectivity!)
                  SalomonBottomBarItem(
                    selectedColor: Const.kPurple,
                    unselectedColor: Const.kPurple.withOpacity(0.4),
                    title: Text("Ana Sayfa"),
                    icon: Icon(Icons.audiotrack_rounded),
                  ),
                  SalomonBottomBarItem(
                    selectedColor: Const.kPurple,
                    unselectedColor: Const.kPurple.withOpacity(0.4),
                    title: Text("Favoriler"),
                    icon: Icon(Icons.favorite),
                  ),
                  // SalomonBottomBarItem(
                  //   selectedColor: Const.kWhite,
                  //   unselectedColor: Const.kWhite.withOpacity(0.4),
                  //   title: Text("Ara"),
                  //   icon: Icon(Icons.search_outlined),
                  // ),
                  SalomonBottomBarItem(
                    selectedColor: Const.kPurple,
                    unselectedColor: Const.kPurple.withOpacity(0.4),
                    title: Text("Cihaz"),
                    icon: Icon(Icons.library_music_rounded),
                  ),
                ],
              ),
            );
          }),
    );
  }
}
