import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/widgets/search_cards.dart';

class SearchedAllQueue extends StatefulWidget {
  final List<MediaItem> queue;
  final String searchText;
  const SearchedAllQueue(
      {Key? key, required this.queue, required this.searchText})
      : super(key: key);

  @override
  State<SearchedAllQueue> createState() => _SearchedAllQueueState();
}

class _SearchedAllQueueState extends State<SearchedAllQueue> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.searchText),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: widget.queue
              .map((e) => buildMusicItem(e, widget.queue, context))
              .toList(),
        ),
      ),
    );
  }
}
