import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/main.dart';
import 'package:onlinemusic/providers/data.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/views/playing_screen/widgets/seekbar.dart';
import 'package:onlinemusic/views/playing_screen/widgets/stream_media_item.dart';
import 'package:onlinemusic/views/queue_screen.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../video_player_page.dart';

class PlayingScreen extends StatefulWidget {
  final MediaItem? song;
  final List<MediaItem>? queue;
  PlayingScreen({
    Key? key,
    this.song,
    this.queue,
  }) : super(key: key);

  static bool isRunning = false;

  @override
  _PlayingScreenState createState() => _PlayingScreenState();
}

class _PlayingScreenState extends State<PlayingScreen>
    with TickerProviderStateMixin {
  late bool isFavorite;
  late PageController pageController;
  final YoutubeExplode yt = YoutubeExplode();

  MediaItem? get song => widget.song;
  MyData get myData => context.myData;

  @override
  void initState() {
    super.initState();
    isFavorite = myData.getFavoriteSong().any((element) => element == song);
    PlayingScreen.isRunning = true;
    pageController = PageController();
    setMediaItem(updateQueue: true);
  }

  @override
  void dispose() {
    PlayingScreen.isRunning = false;
    super.dispose();
  }

  Future<void> updateQueue() async {
    if (widget.queue != null) {
      await handler.updateQueue(widget.queue!);
      await handler.setShuffleMode(AudioServiceShuffleMode.none);
      await handler.setRepeatMode(AudioServiceRepeatMode.none);
    }
  }

  void setMediaItem({MediaItem? mediaItem, bool updateQueue = false}) async {
    if (updateQueue) {
      await this.updateQueue();
    }
    MediaItem? newItem = mediaItem ?? song;
    if (newItem != null) {
      await handler.playMediaItem(newItem);
      await handler.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade300,
        elevation: 0,
        iconTheme: IconThemeData(color: Const.kPurple),
        title: StreamMediaItem(builder: (song) {
          isFavorite =
              myData.getFavoriteSong().any((element) => element == song);
          return AnimatedSwitcher(
            duration: Duration(milliseconds: 500),
            child: isFavorite
                ? Text(
                    "Favori Müziğiniz",
                    style: TextStyle(color: Const.kPurple),
                  )
                : SizedBox(),
          );
        }),
        centerTitle: true,
      ),
      body: playingScreenBody(context),
    );
  }

  Stack playingScreenBody(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: PageView(
            controller: pageController,
            children: [
              ListView(
                physics: NeverScrollableScrollPhysics(),
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    padding: EdgeInsets.all(16),
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Const.kPurple,
                          blurRadius: 12,
                          spreadRadius: 0,
                        ),

                        // BoxShadow(

                        //     color: Const.kPurple.withOpacity(0.4),
                        //     blurRadius: -6,
                        //     offset: Offset(0, -6)),
                        // BoxShadow(
                        //     color: Const.kPurple.withOpacity(0.4),
                        //     blurRadius: -6,
                        //     offset: Offset(0, -6)),
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(48),
                      ),
                    ),
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          physics: NeverScrollableScrollPhysics(),
                          child: Column(
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 24, horizontal: 16),
                                margin: EdgeInsets.symmetric(
                                    horizontal: 0, vertical: 16),
                                decoration: BoxDecoration(
                                  color: Const.kPurple.withOpacity(0.3),
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(44),
                                      bottom: Radius.circular(24)),
                                ),
                                child: Column(
                                  children: [
                                    buildImageWidget(),
                                    buildTitleWidget(),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 32),
                                margin: EdgeInsets.symmetric(
                                    horizontal: 0, vertical: 16),
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Const.kPurple.withOpacity(0.8),
                                        blurRadius: 5,
                                      ),
                                    ]),
                                child: Column(
                                  children: [
                                    buildSliderWidget(),
                                    buildActionsWidget(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              StreamBuilder<List<MediaItem>>(
                stream: handler.queue,
                initialData: handler.queue.value,
                builder: (context, snapshot) {
                  return QueuePage(
                    queue: snapshot.data ?? [],
                    changeItem: (newSong) {
                      setMediaItem(mediaItem: newSong);
                      pageController.animateToPage(
                        0,
                        duration: Duration(milliseconds: 350),
                        curve: Curves.linear,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Padding buildImageWidget() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: StreamMediaItem(
        builder: (song) {
          isFavorite =
              myData.getFavoriteSong().any((element) => element == song);
          if (song == null) return SizedBox();
          return GestureDetector(
            onDoubleTap: () {
              if (isFavorite) {
                myData.removeFavoritedSong(song);
              } else {
                myData.addFavoriteSong(song);
              }
              setState(() {});
            },
            child: Container(
                height: MediaQuery.of(context).size.width / 1.4,
                width: MediaQuery.of(context).size.width / 1.4,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(150),
                    boxShadow: [
                      BoxShadow(
                          color: Const.kPurple.withOpacity(0.4),
                          blurRadius: 12,
                          offset: Offset(5, 7)),
                    ]),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(150),
                    child: song.getImageWidget)),
          );
        },
      ),
    );
  }

  StreamMediaItem buildActionsWidget() {
    return StreamMediaItem(
      builder: (song) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            StreamBuilder<bool>(
              stream: handler.playbackState
                  .map((event) =>
                      event.shuffleMode == AudioServiceShuffleMode.all)
                  .distinct(),
              initialData: false,
              builder: (context, snapshot) {
                bool isShuffleMode = snapshot.data!;
                return IconButton(
                  onPressed: () {
                    handler.setShuffleMode(isShuffleMode
                        ? AudioServiceShuffleMode.none
                        : AudioServiceShuffleMode.all);
                    setState(() {});
                  },
                  icon: Icon(Icons.shuffle),
                  iconSize: 20,
                  color: isShuffleMode ? Colors.black : Colors.black54,
                );
              },
            ),
            Row(
              children: [
                IconButton(
                  onPressed: !handler.hasPrev
                      ? null
                      : () async {
                          await handler.skipToPrevious();
                          handler.play();
                        },
                  icon: Icon(Icons.skip_previous),
                ),
                StreamBuilder<bool>(
                  stream: handler.playingStream,
                  builder: (context, snapshot) {
                    bool isPlaying = snapshot.data ?? false;
                    return IconButton(
                      onPressed: () async {
                        if (isPlaying) {
                          handler.pause();
                        } else {
                          handler.play();
                        }
                      },
                      icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                    );
                  },
                ),
                IconButton(
                  onPressed: !handler.hasNext
                      ? null
                      : () async {
                          await handler.skipToNext();
                          handler.play();
                        },
                  icon: Icon(Icons.skip_next),
                ),
              ],
            ),
            StreamBuilder<AudioServiceRepeatMode>(
              stream: handler.playbackState
                  .map((event) => event.repeatMode)
                  .distinct(),
              builder: (context, snapshot) {
                return IconButton(
                  onPressed: () {
                    myData.setRepeatMode();
                    setState(() {});
                  },
                  icon: myData.getRepeatModeIcon(
                      snapshot.data ?? AudioServiceRepeatMode.none),
                  iconSize: 20,
                );
              },
            ),
          ],
        );
      },
    );
  }

  SizedBox buildSliderWidget() {
    return SizedBox(
      height: 70,
      width: double.maxFinite,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 16,
            left: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StreamBuilder<Duration>(
                    stream: AudioService.position,
                    builder: (context, snapshot) {
                      return Text(
                        Const.getDurationString(
                            handler.playbackState.value.position),
                      );
                    }),
                StreamMediaItem(
                  builder: (song) {
                    return Text(
                      Const.getDurationString(
                        song?.duration ?? Duration.zero,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Positioned(
            top: 20,
            right: 16,
            left: 16,
            child: StreamMediaItem(
              builder: (song) {
                return StreamBuilder<Duration>(
                  stream: AudioService.position,
                  builder: (context, snapshot) {
                    Duration position = handler.playbackState.value.position;

                    Duration bufferedPosition =
                        handler.playbackState.value.bufferedPosition;
                    return SeekBar(
                      duration: song?.duration ?? Duration.zero,
                      bufferedPosition: bufferedPosition,
                      position: position,
                      onChangeEnd: (position) {
                        handler.seek(position);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  StreamMediaItem buildTitleWidget() {
    return StreamMediaItem(
      builder: (song) {
        return Container(
          width: double.maxFinite,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: "title",
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    song?.title.trim() ?? "Title",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis
                    ),
                  ),
                ),
              ),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Hero(
                    tag: "artist",
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        song?.artist ?? "Artist",
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                onPressed: () {},
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border_rounded,
                  color: isFavorite ? Colors.redAccent : Const.kPurple,
                ),
              ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
