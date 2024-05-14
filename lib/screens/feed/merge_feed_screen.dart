import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/material.dart';

import '../../model/feed_model.dart';

class MergedVideoView extends StatefulWidget {
  @override
  _MergedVideoViewState createState() => _MergedVideoViewState();
}

class _MergedVideoViewState extends State<MergedVideoView> {
  late CachedVideoPlayerPlusController _controller;

  int _currentVideoIndex = 0;
  List<String> _videoUrls = [
    'https://firebasestorage.googleapis.com/v0/b/brix-ide.appspot.com/o/videos%2FDC51B388-6111-4FCB-BEF8-5787283C532D_L0_001_1713316951.453841_IMG_0024.MP4?alt=media&token=99728672-5b6c-4ff3-a868-3751c544fea8',
    'https://firebasestorage.googleapis.com/v0/b/brix-ide.appspot.com/o/videos%2F2AB6A725-EE4D-4345-B0C6-C278A23D75F2_L0_001_1713316964.042207_IMG_0022.MP4?alt=media&token=d42eb56b-6df9-456a-b119-4680c93bdcf0'
  ];

  final List<FeedModel> feeds = [];

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    _controller = CachedVideoPlayerPlusController.networkUrl(
        Uri.parse(_videoUrls[_currentVideoIndex]))
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
    _controller.addListener(_onVideoPlayerStateChanged);
  }

  _onVideoPlayerStateChanged() {
    if (_controller.value.isPlaying) {
      // Video is playing
    } else if (_controller.value.isBuffering) {
      // Video is buffering
    } else if (_controller.value.isCompleted) {
      print('Video completed');
      // Video playback completed, play the next video
      if (_currentVideoIndex < _videoUrls.length - 1) {
        _currentVideoIndex++;
        _controller.dispose();
        _initializeVideoPlayer();
      } else {
        // All videos played, do something else or loop back to the first video
        _currentVideoIndex = 0;
        _controller.dispose();
        _initializeVideoPlayer();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 첫번째 영상 끝나면 다음 영상 보여주기
    return Scaffold(
      body: _controller.value.isInitialized
          ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: PageView.builder(
                scrollDirection: Axis.vertical,
                itemCount: _videoUrls.length,
                itemBuilder: (context, index) {
                  return CachedVideoPlayerPlus(_controller);
                },
              ))
          : Center(child: const CircularProgressIndicator()),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
