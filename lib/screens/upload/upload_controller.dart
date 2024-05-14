import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as googlemap;
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:native_exif/native_exif.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../model/feed_model.dart';
import '../../utils/app_routes.dart';
import '../login/user_store.dart';
import '../map/map_controller.dart';

class UploadController extends GetxController {
  static UploadController get to => Get.find();

  final _logger = Logger();

  late googlemap.GoogleMapController mapController;
  late CachedVideoPlayerPlusController videoController;
  late FocusNode focusNode;

  late TextEditingController hashtagController;
  late TextEditingController storeNameController;
  late TextEditingController storeAddressController;
  late TextEditingController storeVideoTitleController;
  late TextEditingController storeDescriptionController;

  late String storeName;
  late String storeAddress;
  late String storeVideoTitle;
  late String storeDescription;

  late Subscription _subscription;

  RxList<AssetEntity> assets = <AssetEntity>[].obs;
  RxList<String> searchResults = <String>[].obs;

  Rx<File> uploadFile = File('').obs;
  RxList<File> uploadFiles = <File>[].obs;
  RxInt selected = 0.obs;

  // list selected
  RxList<int> selectedList = <int>[].obs;
  RxInt total = 0.obs;
  RxInt duration = 0.obs;

  RxString uploadTitle = ''.obs;
  RxString uploadRating = ''.obs;
  RxString uploadContent = ''.obs;

  RxInt selectedCategoryIndex = 0.obs;
  RxString selectedCategory = ''.obs;

  RxList<String> hashtagList = <String>[
    '음식이 맛있어요 😍',
    '분위기가 맛집 😋',
    '데이트코스 💕',
    '가성비 갑 💰',
    '서비스 최고 👍',
    '친구들과 함께하기 좋아요 👫',
    '가족들과 함께하기 좋아요 👨‍👩‍👧‍👦',
    '연인과 함께하기 좋아요 💑',
    '술 한잔하기 좋아요 🍻',
  ].obs;

  /// 선택된 해시태그 리스트
  RxList<String> selectedHashtagStringList = <String>[].obs;

  // 주소 검색시 타이머 지정해서 디바운스 처리
  Timer? _debounce;

  @override
  Future<void> onInit() async {
    super.onInit();
    storeNameController = TextEditingController();
    storeAddressController = TextEditingController();
    storeVideoTitleController = TextEditingController();
    storeDescriptionController = TextEditingController();
    hashtagController = TextEditingController();
    focusNode = FocusNode();
    _subscription = VideoCompress.compressProgress$.subscribe((progress) {
      debugPrint('progress: $progress');
    });
  }

  @override
  dispose() {
    super.dispose();
    _logger.d('uploadcontroller dispose');
    videoController.dispose();
    hashtagList.clear();
    _subscription.unsubscribe();
    storeNameController.clear();
    storeAddressController.clear();
    storeVideoTitleController.clear();
    storeDescriptionController.clear();
    hashtagController.clear();

    MapController.to.storeList.clear();
    MapController.to.searchAddress.value = '';

  }

  /// 동영상 압축
  Future<MediaInfo?> compressVideo(File? files) async {
    try {
      final MediaInfo? compressVideoFile = await VideoCompress.compressVideo(
        files!.path,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false,
        includeAudio: true,
      );
      _logger.i('compressVideoFile: ${compressVideoFile?.filesize}');
      return compressVideoFile;
    } catch (e) {
      _logger.e('compressVideo error: $e');
      return null;
    }
    return null;
  }

  /// 동영상 불러오기
  fetchAssets() async {
    try {
      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      if (ps.isAuth) {
        total.value = await PhotoManager.getAssetCount();
        _logger.i('fetchAssets totalCount: ${total.value}');

        if (total.value > 0) {
          final List<AssetPathEntity> albums =
              await PhotoManager.getAssetPathList(
            type: RequestType.video,
            hasAll: true,
            onlyAll: false,
          );

          final List<AssetEntity> entities =
              await albums.first.getAssetListPaged(page: 0, size: total.value);
          entities.insert(0,
              AssetEntity(id: 'camera', typeInt: 1, width: 128, height: 250));
          assets.assignAll(entities);
        } else {
          _logger.w('No assets');
          List<AssetEntity> entities = [];
          entities.insert(0,
              AssetEntity(id: 'camera', typeInt: 1, width: 128, height: 250));
          assets.assignAll(entities);
        }
      } else if (ps.hasAccess) {
        Get.snackbar('권한 요청', '권한을 허용해주세요.');
      } else {
        Get.snackbar('권한 요청', '권한을 허용해주세요.');
      }
    } catch (e) {
      _logger.e('fetchAssets error: $e');
    }
  }

  /// 동영상 업로드 전 미리보기
  previewVideo() async {
    try {
      videoController = CachedVideoPlayerPlusController.file(uploadFile.value)
        ..initialize().then((_) {
          videoController.play();
          videoController.setLooping(true);
        });
      videoController.addListener(() {
        duration.value = videoController.value.position.inMilliseconds;
      });
    } catch (e) {
      _logger.e('previewVideo error: $e');
    }
  }

  /// 동영상 재생 시간
  showPlayTime() {
    try {
      final Duration position = videoController.value.position;
      final Duration duration = videoController.value.duration;
      return '${position.inMinutes}:${(position.inSeconds % 60).toString().padLeft(2, '0')} / ${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    } catch (e) {
      _logger.e('showPlayTime error: $e');
    }
  }

  /// 동영상 썸네일 생성
  Future<Uint8List> getThumbnail() async {
    try {
      final Uint8List? thumbnail = await VideoThumbnail.thumbnailData(
        video: uploadFile.value.path,
        imageFormat: ImageFormat.WEBP,
        maxWidth: 128,
        quality: 75,
      );
      //print('thumbnail: $thumbnail');
      return thumbnail!;
    } catch (e) {
      _logger.e('getThumbnail error: $e');
      return Uint8List(0);
    }
  }

  /// 동영상 촬영
  pickVideoFromCamera() async {
    try {
      final XFile? video = await ImagePicker().pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(seconds: 10),
      );

      if (video != null) {
        _logger.i('video.path: ${video.path}');
      }
    } catch (e) {
      _logger.e('pickVideoFromCamera error: $e');
    }
  }

  /// 동영상 갤러리
  pickVideoFromGallery() async {
    try {
      final XFile? video = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        requestFullMetadata: false,
        //maxDuration: const Duration(seconds: 10),
      );

      if (video != null) {
        uploadFile.value = File(video.path);

        final exif = await Exif.fromPath(video.path);
        final originalDate = await exif.getOriginalDate();
        final latLong = await exif.getLatLong();
        final attributes = await exif.getAttributes();

        _logger.d('originalDate: $originalDate');
        _logger.d('latLong: $latLong');
        _logger.d('attributes: $attributes');
      }
    } catch (e) {
      _logger.e('pickVideoFromGallery error: $e');
    }
  }

  /// 동영상 파이어베이스 업로드
  uploadVideo() async {
    try {
      Get.dialog(
        Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      var videoUrls = <String>[];
      var videoPath = <String>[];

      UserStore.to.getUserProfile();

      for (int i = 0; i < uploadFiles.length; i++) {
        final MediaInfo? compressVideoFile = await compressVideo(uploadFiles[i]);
        _logger.i('uploadVideo > compressVideoFile: ${compressVideoFile?.filesize}');

        // 파일 업로드
        final String fileName = uploadFiles[i].path.split('/').last;
        _logger.i('uploadVideo > fileName: $fileName');

        final Reference ref = FirebaseStorage.instance.ref().child('videos/$fileName');
        final UploadTask uploadTask = ref.putFile(compressVideoFile!.file!);
        final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => _logger.i('uploadVideo > complete'));
        final String downloadUrl = await taskSnapshot.ref.getDownloadURL();

        _logger.i('uploadVideo > downloadUrl: $downloadUrl');

        videoUrls.add(downloadUrl);
        videoPath.add(compressVideoFile.file!.path);
      }

      var doc = FirebaseFirestore.instance.collection('feeds').doc();
      _logger.i('uploadVideo > storeName: ${MapController.to.storeContext}');

      var model = FeedModel(
        seq: doc.id,
        storeName: storeNameController.text,
        storeAddress: MapController.to.searchAddress.value,
        storeType: MapController.to.storeCategory.value,
        storeMenuInfo: MapController.to.storeMenuInfo.value,
        storeContext: MapController.to.storeContext.value,
        storeLontlat: '${MapController.to.currentLocation.value.latitude}, ${MapController.to.currentLocation.value.longitude}',
        videoUrls: videoUrls,
        videoPaths: videoPath,
        description: storeDescription,
        hashTags: selectedHashtagStringList,
        profilePhoto: UserStore.to.userProfile.photoUrl,
        user: UserStore.to.userProfile.id,
        uid: UserStore.to.userProfile.uid,
        createdAt: DateTime.now().toString(),
        likeCount: 0,
        bookmarkCount: 0,
        point: 0,
      );

      await FirebaseFirestore.instance.collection('feeds').add(model.toJson());

      // 가게 정보 등록
      await FirebaseFirestore.instance.collection('stores').doc(MapController.to.searchAddress.value).set({
        'storeName': storeNameController.text,
        'storeAddress': MapController.to.searchAddress.value,
        'storeType': MapController.to.storeCategory.value,
        'storeMenuInfo': MapController.to.storeMenuInfo.value,
        'storeContext': MapController.to.storeContext.value,
        'storeLontlat': '${MapController.to.currentLocation.value.latitude}, ${MapController.to.currentLocation.value.longitude}',
        'videoUrls': videoUrls,
        'videoPaths': videoPath,
        'description': storeDescription,
        'hashTags': selectedHashtagStringList,
        'profilePhoto': UserStore.to.userProfile.photoUrl,
        'user': UserStore.to.userProfile.id,
        'uid': UserStore.to.userProfile.uid,
        'createdAt': DateTime.now().toString(),
        'likeCount': 0,
        'bookmarkCount': 0,
        'point': 0,
      });

      Get.offAllNamed(AppRoutes.uploadDone);

    } catch (e) {
      _logger.e('uploadVideo error: $e');
    }
  }

  /// 해시태그 추가
  addHashtag(String hashtag) {

    if(selectedHashtagStringList.contains(hashtag)) {
      selectedHashtagStringList.remove(hashtag);
    } else {
      selectedHashtagStringList.add(hashtag);
    }

    _logger.d('selectedHashtagString: $selectedHashtagStringList');
  }


  /// 업로드 화면 내에서 선택된 동영상 리스트 내 선택삭제
  removeCustomGallerySelectedList(int index) {
    selectedList.remove(index);
  }

  /// 선택된 동영상 파일
  Future<void> setSelectVideoFiles() async {
    try {
      uploadFiles.clear();
      for (int i = 0; i < selectedList.length; i++) {
        //uploadFiles.add(assets[selectedList[i]]);
        final File? file = await assets[selectedList[i]].file;
        if (file != null) {
          _logger.i('selectedFile: $file');

          var date = assets[selectedList[i]].createDateTime;
          _logger.d('createDateTime: $date');

          // coordinates
          assets[selectedList[i]].latlngAsync().then((value) {
            _logger.d('latlngAsync: ${value.latitude}, ${value.longitude}');
          });

          uploadFiles.add(file);
        }
      }
    } catch (e) {
      _logger.e('setSelectVideoFiles error: $e');
    }
    _logger.d('setSelectVideoFiles: $uploadFiles');
  }

  /// 가게 상호 및 주소 검색
  Future<void> onPlaceSearchChanged(String value) async {
    MapController.to.searchPlace.value = value;
    try {
      MapController.to.storeList.clear();
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 800), () async {
        await MapController.to.fetchSearchPlace(value, page: 1);
      });
    } catch (e) {
      _logger.e('onPlaceSearchChanged error: $e');
    }
  }
}
