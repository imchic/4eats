import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../../model/feed_model.dart';

class FeedDetailController extends GetxController {
  static FeedDetailController get to => Get.find();

  final _logger = Logger();
  final FeedModel feedDetail = Get.arguments['detailFeed'];

  late CachedVideoPlayerPlusController? videoController;
  Future<void> initializeVideoPlayerFuture = Future.value();

  int _currentVideoIndex = 0;

  final List<String> _videoUrls = [
    'https://firebasestorage.googleapis.com/v0/b/brix-ide.appspot.com/o/videos%2FDC51B388-6111-4FCB-BEF8-5787283C532D_L0_001_1713316951.453841_IMG_0024.MP4?alt=media&token=99728672-5b6c-4ff3-a868-3751c544fea8',
    'https://firebasestorage.googleapis.com/v0/b/brix-ide.appspot.com/o/videos%2F2AB6A725-EE4D-4345-B0C6-C278A23D75F2_L0_001_1713316964.042207_IMG_0022.MP4?alt=media&token=d42eb56b-6df9-456a-b119-4680c93bdcf0'
  ];
  get videoUrls => _videoUrls;

  @override
  onInit() async {
    super.onInit();
    await initializeVideoPlayer();

  }

  @override
  void dispose() {
    videoController?.dispose();
    super.dispose();
  }

  Future<void> initializeVideoPlayer() async {
    try {

      // videoUrls.clear();
      // videoUrls.addAll(feedDetail.videoUrl!);

      videoController = CachedVideoPlayerPlusController.networkUrl(
          Uri.parse(videoUrls[_currentVideoIndex]))
        ..initialize().then((_) {
          if(!videoController!.value.isPlaying){
            videoController?.play();
          }
        });

      videoController?.addListener(_onVideoPlayerStateChanged);

    } catch (e) {
      _logger.e('_initializeVideoPlayer error: $e');
    }
  }

  Future<void> _onVideoPlayerStateChanged() async {
    try {

      if (videoController!.value.isPlaying) {
        // Video is playing
      } else if (videoController!.value.isBuffering) {
        // Video is buffering
      } else if (videoController!.value.isCompleted) {
        print('Video completed');
        // Video playback completed, play the next video
        if (_currentVideoIndex < videoUrls.length - 1) {
          _currentVideoIndex++;

          videoController?.dispose();
          await initializeVideoPlayer();

        } else {
          // All videos played, do something else or loop back to the first video
          _currentVideoIndex = 0;

          videoController?.dispose();
          await initializeVideoPlayer();
        }
      }

    } catch (e) {
      _logger.e('_onVideoPlayerStateChanged error: $e');
    }
  }

}
