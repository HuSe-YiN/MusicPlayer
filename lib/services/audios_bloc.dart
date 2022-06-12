import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/models/audio.dart';
import 'package:rxdart/rxdart.dart';

class AudiosBloc {
  late final FirebaseFirestore _firestore;
  BehaviorSubject<List<Audio>> audios = BehaviorSubject.seeded([]);
  List<Audio> audioList = [];

  static AudiosBloc? _instance;

  CollectionReference<Map<String, dynamic>> get audiosReference =>
      _firestore.collection("audios");

  factory AudiosBloc() {
    return _instance ??= AudiosBloc._();
  }

  List<Audio> getAudioFromGenreId(int genreId){
    return audios.value.where((e) =>e.genreIds.any((element) => element==genreId)).toList();
  }

  void fetchAudios() {
    audiosReference.snapshots().listen((event) {
      audios.add(
        event.docs.map((e) => Audio.fromMap(e.data())).toList(),
      );
    });
  }

  AudiosBloc._() {
    _firestore = FirebaseFirestore.instance;
    fetchAudios();
  }

  void getAudiosMusic() async {
    await audiosReference.get().then((value) {
      audioList =
          value.docs.map((value) => Audio.fromMap(value.data())).toList();
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAudiosFromGenre(int genreId) {
    return audiosReference
        .where(
          "genreIds",
          arrayContains: genreId,
        )
        .snapshots();
  }

  Future<bool> saveAudioToFirebase(Audio audio) async {
    try {
      audiosReference.add(audio.toMap());
      return true;
    } on Exception catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<List<Audio>> getMySharedAudios() async {
    String myId = FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot<Map<String, dynamic>> query = await audiosReference
        .where("idOfTheSharingUser", isEqualTo: myId)
        .get();
    return query.docs.map((e) => Audio.fromMap(e.data())).toList();
  }
}
