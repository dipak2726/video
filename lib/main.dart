import 'package:flutter/material.dart';
import 'package:native_video_view/native_video_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Video(),
    );
  }
}

class Video extends StatefulWidget {
  const Video({Key key}) : super(key: key);

  @override
  _VideoState createState() => _VideoState();
}

class _VideoState extends State<Video> {
  List _videos = [
    'assets/giraffe.mp4',
    'assets/earth.mp4',
    'assets/small.mp4',
    'assets/summer.mp4',
  ];

  VideoViewController _controller;

  int _playingIndex = 0;
  var _progress = 0.0;

  void replay() {
    setState(() {
      _playingIndex = 0;
      _progress = 0;

      _controller.setVideoSource(
        _videos[_playingIndex],
        sourceType: VideoSourceType.asset,
      );
      _controller.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width / _videos.length;

    double progress = _progress * width + _playingIndex * width;
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 9,
            child: NativeVideoView(
              enableVolumeControl: false,
              keepAspectRatio: true,
              showMediaController: false,
              onCreated: (controller) {
                _controller = controller;
                controller.setVideoSource(
                  _videos[_playingIndex],
                  sourceType: VideoSourceType.asset,
                );
              },
              onPrepared: (controller, info) {
                controller.play();
              },
              onError: (controller, what, extra, message) {
                print('Player Error ($what | $extra | $message)');
              },
              onCompletion: (controller) {
                print('Video completed');
                if (_playingIndex > _videos.length - 1) {
                  print('-------------------played all----');
                  return;
                }
                setState(() {
                  _playingIndex++;
                });

                controller.setVideoSource(
                  _videos[_playingIndex],
                  sourceType: VideoSourceType.asset,
                );
                controller.play();
              },
              onProgress: (progress, duration) {
                setState(() {
                  _progress = progress / duration;
                });
                print('$progress | $duration');
              },
            ),
          ),
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                Placeholder(),
                Padding(
                  padding: EdgeInsets.only(left: progress),
                  child: Container(
                    width: 10,
                    color: Colors.black,
                  ),
                )
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: ReorderableListView(
              scrollDirection: Axis.horizontal,
              onReorder: (int oldIndex, int newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final items = _videos.removeAt(oldIndex);
                  _videos.insert(newIndex, items);
                });
                replay();
              },
              children: _videos
                  .asMap()
                  .entries
                  .map((item) => Padding(
                        key: ValueKey(item.key),
                        padding: const EdgeInsets.all(12.0),
                        child: VideoItem(
                          asset: item.value,
                          active: _playingIndex == item.key,
                          width: 50,
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: replay,
        child: Icon(Icons.play_arrow),
      ),
    );
  }
}

// ignore: must_be_immutable
class VideoItem extends StatefulWidget {
  VideoItem({key, this.active, this.width, this.asset});

  bool active;
  double width;
  String asset;

  @override
  _VideoItemState createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 50,
        width: widget.width,
        decoration: widget.active
            ? BoxDecoration(
                border: Border.all(width: 5, color: Colors.pink),
                borderRadius: BorderRadius.all(Radius.circular(10)))
            : BoxDecoration(),
        child: Placeholder());
  }
}
