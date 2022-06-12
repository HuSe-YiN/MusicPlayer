import 'package:flutter/material.dart';
import 'package:onlinemusic/models/genre.dart';
import 'package:onlinemusic/models/youtube_genre.dart';
import 'package:onlinemusic/models/youtube_playlist.dart';
import 'package:onlinemusic/util/const.dart';

class PlaylistScreen extends StatefulWidget {
  final bool isYoutube;
  final YoutubeGenre? youtubeGenre;
  final Genre? genre;
  const PlaylistScreen.YoutubeGenre({Key? key, required this.youtubeGenre})
      : genre = null,
        isYoutube = true,
        super(key: key);
  const PlaylistScreen.Genre({Key? key, this.genre})
      : youtubeGenre = null,
        isYoutube = false,
        super(key: key);

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  String get title {
    return (widget.isYoutube
            ? widget.youtubeGenre?.title
            : widget.genre?.name) ??
        "Title";
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          centerTitle: true,
        ),
        // height: widget.youtubeGenre!.playlists!.first.isPlaylist
        //       ? 170
        //       : 250 / 16 * 9 + 16,
        body: ListView.builder(
          physics: BouncingScrollPhysics(),
          itemCount: (widget.youtubeGenre!.playlists!.length / 2).round(),
          itemBuilder: (c, i) {
            print((widget.youtubeGenre!.playlists!.length / 2).round());
            int start = i * 2;
            print("index: "+i.toString());
            YoutubePlaylist p1 = widget.youtubeGenre!.playlists![start];
            YoutubePlaylist? p2 = (start+1)<widget.youtubeGenre!.playlists!.length ? widget.youtubeGenre!.playlists![start + 1] : null;
            return Row(
              children: [
                Expanded(child: buildItem(p1)),
                if(p2!=null) Expanded(child: buildItem(p2)),
              ],
            );
          },
        ),
      ),
    );
  }

  Padding buildItem(YoutubePlaylist e) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          //? playlist ekranına gidicek
        },
        child: Card(
          margin: EdgeInsets.zero,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 5,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                        child: Image.network(
                          e.imageQuality(
                            true,
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(8),
                  ),
                  color: Colors.white,
                ),
                child: Center(
                  child: Text(
                    e.title ?? "",
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
  }
}
