import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:onlinemusic/models/audio.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class SearchService {
  static List<SongModel> fetchMusicFromQuery(
      String query, BuildContext context) {
//cihaz daki müzikleri ara
    List<SongModel> songs = [];
    if (query.isEmpty) {
      return context.myData.songs;
    }
    for (SongModel i in context.myData.songs) {
      if (i.displayNameWOExt.toLowerCase().contains(query)) {
        songs.add(i);
      }
    }

    return songs;
  }

  static Future<List<Audio>> fetchAudiosFromQuery(String query) async {
//Firebase deki müzikleri ara
    List<Audio> audios = [];
    List<Audio> findAudios = [];
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    if (query.isEmpty) {
      return [];
    }
    var result = await firestore.collection("audios").get();

    audios = result.docs.map((e) => Audio.fromMap(e.data())).toList();

    for (Audio i in audios) {
      String search = "";
      search = i.title.toLowerCase() + i.artist.toLowerCase();
      if (search.contains(query)) {
        findAudios.add(i);
      }
    }
    return findAudios;
  }

  static Future<List<Video>> fetchVideos(String query) async {
//Youtube deki müzikleri ara

    if (query.isEmpty) {
      return [];
    }
    final YoutubeExplode yt = YoutubeExplode();

    final List<Video> searchResults = await yt.search.getVideos(query);

    return searchResults;
  }
}
