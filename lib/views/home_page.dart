import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/main.dart';
import 'package:onlinemusic/models/audio.dart';
import 'package:onlinemusic/models/genre.dart';
import 'package:onlinemusic/models/head_music.dart';
import 'package:onlinemusic/models/youtube_genre.dart';
import 'package:onlinemusic/models/youtube_playlist.dart';
import 'package:onlinemusic/services/audios_bloc.dart';
import 'package:onlinemusic/services/auth.dart';
import 'package:onlinemusic/services/youtube_service.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/views/playing_screen/playing_screen.dart';
import 'package:onlinemusic/views/playing_screen/playlists_screen.dart';
import 'package:onlinemusic/views/profile_screen.dart';
import 'package:onlinemusic/views/search_page.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../models/usermodel.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _YoutubeHomePageState();
}

class _YoutubeHomePageState extends State<HomePage> {
  YoutubeExplode yt = YoutubeExplode();
  final _currentPageNotifier = ValueNotifier<int>(0);
  List<YoutubeGenre> genres = [];
  Genre selectedGenre = Genre(id: 1, name: "Rock");
  List<HeadMusic> headSongs = [];
  late PageController _pageController;
  List<Color> colors = [];
  Timer? timer;
  bool showHeadMusic = true;
  int? r, g, b;

  @override
  void initState() {
    super.initState();
    genres = [];
    headSongs = [];
    _pageController = PageController();

    colors = List.generate(
      Const.genres.length,
      (index) => Color.fromARGB(
        180,
        Random().nextInt(255),
        Random().nextInt(255),
        Random().nextInt(255),
      ),
    );
    services.getMusicHome().then((value) {
      if (value != null) {
        genres = value.genres ?? [];
        headSongs = value.headMusics ?? [];
        if (mounted) setState(() {});

        if (headSongs.isNotEmpty)
          WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
            if (headSongs.isNotEmpty) {
              timer = Timer.periodic(Duration(seconds: 10), (timer) {
                if (_currentPageNotifier.value < headSongs.length - 1) {
                  if (_pageController.positions.isNotEmpty)
                    _pageController.nextPage(
                        duration: Duration(milliseconds: 350),
                        curve: Curves.linear);
                } else {
                  if (_pageController.positions.isNotEmpty)
                    _pageController.animateToPage(0,
                        duration: Duration(milliseconds: 350),
                        curve: Curves.linear);
                }
              });
            }
          });
      }
    });
  }

  @override
  void dispose() {
    yt.close();
    _currentPageNotifier.dispose();
    timer?.cancel();
    super.dispose();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color(0xff4F3453).withOpacity(1),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Stack(
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 17.5),
                    padding: EdgeInsets.only(left: 20),
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images/bg.jpg"),
                          fit: BoxFit.cover,
                        ),
                        color: Colors.black54,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 80,
                        ),
                        Text(
                          "Hoşgeldin",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w200),
                        ),
                        Text(
                          FirebaseAuth.instance.currentUser!.displayName!,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              letterSpacing: 0.3,
                              fontWeight: FontWeight.w900),
                        ),
                        SizedBox(
                          height: 64,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 10,
                    top: 25,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () async {
                            UserModel? userModel = await AuthService()
                                .getUserFromId(
                                    FirebaseAuth.instance.currentUser!.uid);
                            if (userModel != null) {
                              context.push(ProfileScreen(userModel: userModel));
                            }
                          },
                          icon: Icon(
                            Icons.account_circle_rounded,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                        Stack(
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.notifications_none_rounded,
                                size: 28,
                                color: Colors.white,
                              ),
                            ),
                            Positioned(
                              right: 12,
                              top: 10,
                              child: Container(
                                height: 9,
                                width: 9,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 30,
                    left: 16,
                    right: 16,
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        boxShadow: [
                          // BoxShadow(
                          //     color: Colors.white.withOpacity(0.5),
                          //     blurRadius: 3,
                          //     offset: Offset(0, -2)),
                          BoxShadow(
                              color:
                                  Color.fromARGB(255, 0, 0, 0).withOpacity(0.4),
                              blurRadius: 3,
                              offset: Offset(0, 2)),
                        ],
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: TextField(
                        onSubmitted: (c) {
                          if (c != "") {
                            context.push(SearchPage(searchText: c));
                          }
                        },
                        textInputAction: TextInputAction.search,
                        cursorColor: Const.kPurple,
                        cursorWidth: 0.5,
                        controller: controller,
                        style: TextStyle(
                            color: Const.kPurple,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.5),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.only(left: 20, top: 10),
                          border: InputBorder.none,
                          hintText: "Müzik ara",
                          hintStyle: TextStyle(
                              color: Const.kPurple.withOpacity(0.3),
                              fontSize: 14),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Const.kPurple,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
        body: ListView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            bottom: 16,
          ),
          children: [
            

             
            headSongs.isNotEmpty
                ? AnimatedCrossFade(
                    firstChild: SizedBox(),
                    secondChild: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.width / 2 + 50,
                          width: double.maxFinite,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: PageView.builder(
                                key: const PageStorageKey("headMusics"),
                                controller: _pageController,
                                physics: BouncingScrollPhysics(),
                                itemCount: headSongs.length,
                                onPageChanged: (s) {
                                  _currentPageNotifier.value = s;
                                },
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (c, i) {
                                  return InkWell(
                                    onTap: () async {
                                      //? oynatma ekranına gidilecek
                                    },
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned.fill(
                                          right: 5,
                                          left: 5,
                                          top: 15,
                                          bottom: 10,
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                      bottom: Radius.circular(
                                                          12)),
                                            ),
                                            shadowColor:
                                                Const.kPurple.withOpacity(0),
                                            elevation: 6,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                      bottom: Radius.circular(
                                                          12)),
                                              child: buildImage(
                                                headSongs[i]
                                                    .imageQuality(false),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 0,
                                          right: 9,
                                          left: 9,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Const.kPurple,
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                top: Radius.circular(12),
                                              ),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 5,
                                              vertical: 7,
                                            ),
                                            width: double.infinity,
                                            child: Center(
                                              child: Text(
                                                headSongs[i].title ?? "",
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),

                        //! burası yapılcak
                        Positioned(
                          bottom: 0,
                          right: 0,
                          left: 0,
                          child: Center(
                            child: SmoothPageIndicator(
                              controller: _pageController,
                              count: headSongs.length,
                              effect: ExpandingDotsEffect(
                                activeDotColor: Const.kPurple,
                                dotColor: Const.kPurple.withOpacity(0.2),
                                dotHeight: 10,
                                dotWidth: 10,
                                spacing: 15,
                              ),
                            ),
                          ),
                        )
                        // Positioned(
                        //   bottom: 0,
                        //   right: 0,
                        //   left: 0,
                        //   child: Text("yap"),
                        // ),
                      ],
                    ),
                    // currentPageNotifier: _currentPageNotifier,
                    //         itemCount: headSongs.length,
                    crossFadeState: showHeadMusic
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: Duration(milliseconds: 400),
                  )
                : SizedBox(),
            //!burdan aldım
            headTextWidget("Kullanıcı müzikleri"),
            Container(
              margin: EdgeInsets.only(
                left: 10,
                right: 10,
                bottom: 10,
              ),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(bottom:Radius.circular(12)),
                  color: Const.kWhite,
                  boxShadow: [
                    BoxShadow(
                      color: Const.kPurple.withOpacity(0.4),
                      blurRadius: 6,
                      offset: Offset(3, 3),
                    )
                  ]),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: getGenres(Const.genres),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: getGenreWidget(selectedGenre),
                  ),
                ],
              ),
            ),
            // Column(
            //   children: Const.genres.map((e) {
            //     return getGenreWidget(e);
            //   }).toList(),
            // ),
            // headTextWidget("Youtube müzik"),
            Column(
              children: genres.map((e) {
                return getYoutubeGenreWidget(e);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Image buildImage(String url) {
    if (isConnectivity!) {
      return Image.network(
        url,
        fit: BoxFit.cover,
      );
    }
    return Image.asset("assets/images/default_song_image.png");
  }

  Padding headTextWidget(String text,{bool paddingBottom=false}) {
    return Padding(
      padding: EdgeInsets.only(top: 18, right: 10, left: 10, bottom:paddingBottom ?18:0),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Const.kPurple,
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget getGenreWidget(Genre genre) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: context.myData.aB.getAudiosFromGenre(genre.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox();
        } else {
          List<Audio> audios =
              snapshot.data!.docs.map((e) => Audio.fromMap(e.data())).toList();
          if (audios.isEmpty) {
            return SizedBox();
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 16, bottom: 8, left: 12),
                    child: Text(
                      genre.name,
                      style: TextStyle(
                        color: Const.kPurple,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.push(PlaylistScreen.Genre(
                        genre: selectedGenre,
                      ));
                    },
                    child: Text(
                      audios.length.toString() + " müzik",
                      style: TextStyle(color: Const.kPurple),
                    ),
                  ),
                ],
              ),
              Container(
                height: 222,
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: audios.length,
                  itemBuilder: (c, i) {
                    Audio audio = audios[i];
                    return InkWell(
                      onTap: () {
                        context.push(
                          PlayingScreen(
                            song: audio.toMediaItem,
                            queue: audios.map((e) => e.toMediaItem).toList(),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(12),
                              bottom: Radius.circular(8),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Const.kPurple.withOpacity(0.2),
                                blurRadius: 5,
                                offset: Offset(-6, 5),
                              )
                            ]),
                        child: IntrinsicHeight(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 160,
                                height: 160,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(12)),
                                  child: buildImage(audio.image),
                                ),
                              ),
                              Divider(
                                height: 1,
                                thickness: 1,
                                color: Const.kPurple.withOpacity(0.5),
                              ),
                              Container(
                                height: 29,
                                width: 160,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.vertical(
                                    bottom: Radius.circular(8),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    audio.title,
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget getYoutubeGenreWidget(YoutubeGenre youtubeGenre) {
    if ((youtubeGenre.playlists ?? []).isEmpty) {
      return SizedBox();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              child: RichText(
                text: TextSpan(
                    text: youtubeGenre.title!,
                    style: TextStyle(
                      color: Const.kPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                    children: [
                      TextSpan(
                        text: "  " +
                            youtubeGenre.playlists!.length.toString() +
                            (!youtubeGenre.playlists!.first.isPlaylist
                                ? " Video"
                                : " liste"),
                        style: TextStyle(
                            color: Const.kPurple,
                            fontSize: 12,
                            fontWeight: FontWeight.w300),
                      ),
                    ]),
              ),
            ),
            TextButton(
              onPressed: () {
                context.push(
                    PlaylistScreen.YoutubeGenre(youtubeGenre: youtubeGenre));
              },
              child: Text(
                "Hepsini gör",
                style: TextStyle(color: Const.kPurple),
              ),
            ),
          ],
        ),
        Container(
          height: youtubeGenre.playlists!.first.isPlaylist ? 222 : 183,
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            scrollDirection: Axis.horizontal,
            itemCount: youtubeGenre.playlists?.length,
            itemBuilder: (c, i) {
              YoutubePlaylist myPlaylist = youtubeGenre.playlists![i];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                child: InkWell(
                  customBorder: RoundedRectangleBorder(
                      side: BorderSide(
                    color: Const.kPurple,
                    width: 3,
                  )),
                  splashColor: Const.kPurple,
                  radius: 0,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(12),
                    bottom: Radius.circular(8),
                  ),
                  onTap: () {},
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(12),
                          bottom: Radius.circular(8),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Const.kPurple.withOpacity(0.2),
                            blurRadius: 5,
                            offset: Offset(-6, 5),
                          )
                        ]),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          SizedBox(
                            width: myPlaylist.isPlaylist ? 160 : 214,
                            child: AspectRatio(
                              aspectRatio: myPlaylist.isPlaylist ? 1 : 16 / 9,
                              child: Builder(
                                builder: (context) {
                                  return ClipRRect(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(12)),
                                      child: buildImage(
                                        myPlaylist.imageQuality(
                                          true,
                                        ),
                                      ));
                                },
                              ),
                            ),
                          ),
                          Container(
                            width: myPlaylist.isPlaylist ? 160 : 214,
                            height: 20,
                            padding: EdgeInsets.only(bottom: 3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(8),
                              ),
                              color: Const.kWhite,
                            ),
                            child: Center(
                              child: Text(
                                myPlaylist.title ?? "",
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color.fromARGB(255, 0, 0, 0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Divider(
          height: 4,
          thickness: 4,
          color: Const.kPurple.withOpacity(0.08),
        ),
      ],
    );
  }

  Widget getGenres(List<Genre> genres) {
    return Container(
      height: 140,
      // color: Colors.orange.withOpacity(0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 12),
            child: Text(
              "Kategoriler",
              style: TextStyle(
                color: Const.kPurple,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
          Container(
            height: 112,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: genres.length,
                itemBuilder: (c, i) {
                  List<Audio> audios =
                      AudiosBloc().getAudioFromGenreId(genres[i].id);
                  bool isSelectedGenre = selectedGenre == genres[i];
                  return audios.isEmpty
                      ? SizedBox()
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () {
                                selectedGenre = genres[i];
                                setState(() {});
                              },
                              child: Stack(
                                children: [
                                  Container(
                                    height: 75,
                                    width: 75,
                                    margin: EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(audios.first.image),
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      // color: isSelectedGenre
                                      //     ? Const.kPurple
                                      //     : Const.kPurple.withOpacity(0.2),
                                    ),
                                    // child: Center(
                                    //   child: Text(
                                    //     genres[i].name,
                                    //     style: TextStyle(
                                    //       fontSize: isSelectedGenre ? 18 : 15,
                                    //       color: isSelectedGenre
                                    //           ? Colors.white
                                    //           : Const.kPurple,
                                    //       // shadows: [
                                    //       //   BoxShadow(
                                    //       //     color: Colors.grey.shade700,
                                    //       //     blurRadius: 3,
                                    //       //   )
                                    //       // ],
                                    //     ),
                                    //   ),
                                    // ),
                                  ),
                                  Positioned(
                                    left: 12,
                                    top: 12,
                                    child: Container(
                                      height: 75,
                                      width: 75,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: isSelectedGenre
                                            ? Colors.black38
                                            : Colors.black.withOpacity(0.75),
                                      ),
                                      child: Center(
                                        child: Text(
                                          genres[i].name,
                                          style: TextStyle(
                                            fontSize: isSelectedGenre ? 19 : 15,
                                            color: isSelectedGenre
                                                ? Colors.white
                                                : Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              audios.length.toString() + "  Müzik",
                              style: TextStyle(
                                  fontSize: 10,
                                  overflow: TextOverflow.ellipsis,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        );
                }),
          ),
        ],
      ),
    );
  }
}
