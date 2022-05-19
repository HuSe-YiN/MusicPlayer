import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:onlinemusic/models/audio.dart';
import 'package:provider/provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../providers/data.dart';
import '../services/search_service.dart';
import '../util/const.dart';
import '../widgets/loading_widget.dart';
import '../widgets/search_cards.dart';
import '../widgets/snackbar.dart';

class SearchPage extends StatefulWidget {
  SearchPage({Key? key}) : super(key: key);

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
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: _searchBar(),
        ),
        key: scaffoldKey,
        body: SafeArea(
            child: ListView(
          children: [
            FutureBuilder<List<Audio>>(
              future: SearchService.fetchAudiosFromQuery("query"),
              builder:
                  (BuildContext context, AsyncSnapshot<List<Audio>> snapshot) {
                if (snapshot.hasData) {
                  //firebase
                  return Column(
                      children: snapshot.data!
                          .map((e) => firebaseCard(audio: e))
                          .toList());
                } else {
                  return Center(
                    child: CupertinoActivityIndicator(),
                  );
                }
              },
            ),
            Column(children: getMusicList.map((e) => localMusic(e)).toList()),
            FutureBuilder<List<Video>>(
              future: SearchService.fetchVideos("query"),
              builder:
                  (BuildContext context, AsyncSnapshot<List<Video>> snapshot) {
                if (snapshot.hasData) {
                  //youtube
                  return Column(
                    children: snapshot.data!
                        .map((e) => youtubeCard(video: e))
                        .toList(),
                  );
                } else {
                  return Center(
                    child: CupertinoActivityIndicator(),
                  );
                }
              },
            ),
          ],
        )));
  }

  Widget _searchBar() {
    return Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(color: Theme.of(context).backgroundColor),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                autofocus: true,
                controller: searcController,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Müzik Bul",
                  hintStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).secondaryHeaderColor),
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.close,
                      size: 25,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    onPressed: () {},
                  ),
                ),
                textInputAction: TextInputAction.search,
                onFieldSubmitted: (value) {
                  if (value == '') {
                    openSnacbar(scaffoldKey, 'Birşeyler yaz!');
                  } else {}
                },
              ),
            ),
            SizedBox(
              width: 5,
            ),
            MaterialButton(
              onPressed: () {},
              child: Center(child: Icon(Icons.search)),
            )
          ],
        ));
  }
}
