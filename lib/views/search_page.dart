import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:onlinemusic/models/audio.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/views/playing_screen/searched_all_queue.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../services/search_service.dart';
import '../widgets/search_cards.dart';

class SearchPage extends StatefulWidget {
  String searchText;
  SearchPage({Key? key, required this.searchText}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController searcController = TextEditingController();

  bool findMusic = false;
  bool searchStarted = false;
  List<SongModel> getMusicList = [];
  @override
  void initState() {
    searcController.text = widget.searchText;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: BackButton(color: Const.kPurple),
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Padding(
          padding: EdgeInsets.only(right: 8.0),
          child: _searchBar(),
        ),
      ),
      key: scaffoldKey,
      body: SafeArea(
        child: ListView(
          children: [
            FutureBuilder<List<Audio>>(
              future: SearchService.fetchAudiosFromQuery(
                  searcController.text.toLowerCase()),
              builder:
                  (BuildContext context, AsyncSnapshot<List<Audio>> snapshot) {
                if (snapshot.hasData) {
                  if ((snapshot.data ?? []).isEmpty) {
                    return SizedBox();
                  }
                  List<MediaItem> queue =
                      snapshot.data!.map((e) => e.toMediaItem).toList();
                  List<MediaItem> filteredList = [];
                  if (queue.length > 3) {
                    filteredList = queue.sublist(0, 4);
                  } else {
                    filteredList = queue;
                  }
                  //firebase
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildTitle("Kullanıcıların Yükledikleri Müzikler:"),
                          if (queue.length > 3)
                            TextButton(
                              onPressed: () {
                                context.push(
                                  SearchedAllQueue(
                                      queue: queue,
                                      searchText: searcController.text),
                                );
                              },
                              child: Text(
                                "Hepsini gör",
                                style: TextStyle(color: Const.kPurple),
                              ),
                            ),
                        ],
                      ),
                      Column(
                          children: filteredList
                              .map((e) => buildMusicItem(e, queue, context))
                              .toList()),
                    ],
                  );
                } else {
                  return Center(
                    child: CupertinoActivityIndicator(),
                  );
                }
              },
            ),
            buildLocalAudios(context),
            buildYoutubeAudios(),
          ],
        ),
      ),
    );
  }

  FutureBuilder<List<Video>> buildYoutubeAudios() {
    return FutureBuilder<List<Video>>(
      future: SearchService.fetchVideos(searcController.text.toLowerCase()),
      builder: (BuildContext context, AsyncSnapshot<List<Video>> snapshot) {
        if ((snapshot.data ?? []).isEmpty) {
          return SizedBox();
        }
        List<MediaItem> queue =
            snapshot.data!.map((e) => e.toMediaItem).toList();
        List<MediaItem> filteredList = [];

        if (queue.length > 3) {
          filteredList = queue.sublist(0, 3);
        } else {
          filteredList = queue;
        }

        //youtube
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildTitle("Youtube Müzikleri:"),
                if (queue.length > 3)
                  TextButton(
                    onPressed: () {
                      context.push(
                        SearchedAllQueue(
                            queue: queue, searchText: searcController.text),
                      );
                    },
                    child: Text(
                      "Hepsini gör",
                      style: TextStyle(color: Const.kPurple),
                    ),
                  ),
              ],
            ),
            Column(
              children: filteredList
                  .map((e) => buildMusicItem(
                      e,
                      snapshot.data!.map((e) => e.toMediaItem).toList(),
                      context))
                  .toList(),
            ),
          ],
        );
      },
    );
  }

  Widget buildLocalAudios(BuildContext context) {
    List<MediaItem>? filteredList = [];
    List<MediaItem> queue = SearchService.fetchMusicFromQuery(
            searcController.text.toLowerCase(), context)
        .map((y) => y.toMediaItem)
        .toList();
    if (queue.isEmpty) {
      return SizedBox();
    }
    if (queue.length > 3) {
      filteredList = queue.sublist(0, 3);
    } else {
      filteredList = queue;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildTitle("Cihazdaki Müzikler:"),
            if (queue.length > 3)
              TextButton(
                onPressed: () {
                  context.push(
                    SearchedAllQueue(
                        queue: queue, searchText: searcController.text),
                  );
                },
                child: Text(
                  "Hepsini gör",
                  style: TextStyle(color: Const.kPurple),
                ),
              ),
          ],
        ),
        Column(
            children: filteredList
                .map((e) => buildMusicItem(e, queue, context))
                .toList()),
      ],
    );
  }

  Widget buildTitle(String text) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IntrinsicWidth(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            Divider(
              color: Colors.black,
              thickness: 1,
              height: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchBar() {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: Const.kPurple,
      ),
      child: TextField(
        onSubmitted: (c) {
          setState(() {});
        },
        textInputAction: TextInputAction.search,
        cursorColor: Color.fromARGB(255, 255, 255, 255),
        cursorWidth: 0.5,
        controller: searcController,
        style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.only(left: 20, top: 10),
          border: InputBorder.none,
          hintText: "Müzik ara",
          hintStyle: TextStyle(
              color: Color.fromARGB(255, 255, 255, 255).withOpacity(0.7),
              fontSize: 14),
          suffixIcon: AnimatedBuilder(
            builder: ((context, child) {
              return AnimatedCrossFade(
                firstChild: IconButton(
                  icon: Icon(
                    Icons.close,
                  ),
                  onPressed: () {
                    searcController.clear();
                  },
                  color: Colors.white,
                ),
                secondChild: SizedBox(width: 36,height: 36,),
                duration: Duration(milliseconds: 300),
                crossFadeState: searcController.text.isEmpty
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
              );
            }),
            animation: searcController,
          ),
        ),
      ),
    );
  }
}

// searcController!=""? InkWell(
//             onTap: () {
//               searcController.clear();
//             },
//             child: Icon(
//               Icons.close,
//               color: Const.kWhite,
//             ),
//           ):SizedBox(),