import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/providers/data.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/views/playing_screen/playing_screen.dart';

class LibraryPage extends StatefulWidget {
  LibraryPage({Key? key}) : super(key: key);

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  @override
  Widget build(BuildContext context) {
    MyData data = context.myData;
    return Scaffold(
      appBar: AppBar(
        
        title: Text("Cihaz"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Center(child: Text(data.songs.length.toString())),
            ),
          )
        ],
      ),
      body: ListView.builder(
          physics: BouncingScrollPhysics(),
          itemCount: data.songs.length,
          itemBuilder: (context, int index) {
            MediaItem music = data.songs[index].toMediaItem;
            return Container(
              color: (index % 2 == 0)
                  ? Colors.white
                  : Const.kPurple.withOpacity(0.05),
              child: ListTile(
                leading: Container(
                  height: 50.0,
                  width: 50.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: Colors.grey.shade300,
                  ),
                  child: music.getImageWidget,
                  clipBehavior: Clip.antiAlias,
                ),
                title: Text(
                  music.title.toString(),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  music.artist.toString(),
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () async {
                  context.push(
                    PlayingScreen(
                      song: music,
                      queue: data.songs.map((e) => e.toMediaItem).toList(),
                    ),
                  );
                },
              ),
            );
          }),
    );
  }
      
}
