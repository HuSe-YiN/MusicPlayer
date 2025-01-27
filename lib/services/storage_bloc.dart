import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:onlinemusic/models/media_reference.dart';

class StorageBloc {
  StorageBloc() {
    _storage = FirebaseStorage.instance;
    _reference = _storage.ref();
  }

  late Reference _reference;
  late FirebaseStorage _storage;

  Reference get reference => _reference;

  Reference get audiosRef {
    return reference.child("audio");
  }

  Reference get audioImagesRef {
    return reference.child("audio_images");
  }

  Future<MediaReference> uploadAudio({
    required File file,
    required String userUid,
    int index = 0,
    String? timeStamp,
    String? ext,
  }) async {
    ext = ext ?? fileExt(file.path);
    timeStamp = timeStamp ?? DateTime.now().millisecondsSinceEpoch.toString();
    String ref = "$timeStamp-$index.$ext";
    UploadTask task = audiosRef
        .child(userUid)
        .child(ref)
        .putFile(file, SettableMetadata(contentType: 'audio/$ext'));
    await task.whenComplete(() => null);
    String downloadURL = await task.snapshot.ref.getDownloadURL();
    return MediaReference(ref: ref, downloadURL: downloadURL);
  }

  static String fileExt(String name) {
    return name.split(".").last;
  }

  // ref = MediaReference deki ref
  Future<void> deleteAudio(String uid, String ref) async {
    await audiosRef.child(uid).child(ref).delete();
  }

  void dispose() {}

  Future<String?> uploadImage(
    String imagePath,
    String userId, {
    String? timeStamp,
  }) async {
    String ext = fileExt(imagePath);
    timeStamp = timeStamp ?? DateTime.now().millisecondsSinceEpoch.toString();
    String ref = "$timeStamp.$ext";
    try {
      UploadTask task = audioImagesRef.child(userId).child(ref).putFile(
          File(imagePath), SettableMetadata(contentType: 'image/$ext'));
      await task.whenComplete(() => null);
      String downloadURL = await task.snapshot.ref.getDownloadURL();
      return downloadURL;
    } on Exception catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }
}
