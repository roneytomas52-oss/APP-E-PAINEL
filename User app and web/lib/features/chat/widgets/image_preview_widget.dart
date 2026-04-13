import 'package:flutter/material.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/chat/domain/models/chat_model.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/file_type_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class ImagePreviewWidget extends StatefulWidget {
  final Message currentMessage;
  final int currentIndex;
  const ImagePreviewWidget({super.key, required this.currentMessage, this.currentIndex = 0});

  @override
  State<ImagePreviewWidget> createState() => _ImagePreviewWidgetState();
}

class _ImagePreviewWidgetState extends State<ImagePreviewWidget> {
  PageController _pageController = PageController();
  int _currentIndex = 0;
  Map<int, VideoPlayerController?> _videoControllers = {};
  Map<int, ChewieController?> _chewieControllers = {};

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _initializeCurrentVideo();
  }

  Future<void> _initializeCurrentVideo() async {
    final currentUrl = widget.currentMessage.fileFullUrl![_currentIndex];
    final fileType = FileTypeHelper.getFileType(currentUrl);
    
    if (fileType == FileType.video && !_videoControllers.containsKey(_currentIndex)) {
      await _initializeVideo(_currentIndex, currentUrl);
    }
  }

  Future<void> _initializeVideo(int index, String url) async {
    try {
      final videoController = VideoPlayerController.networkUrl(Uri.parse(url));
      await videoController.initialize();
      
      final chewieController = ChewieController(
        videoPlayerController: videoController,
        autoPlay: true,
        looping: false,
        aspectRatio: videoController.value.aspectRatio,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.white, size: 48),
                const SizedBox(height: 8),
                Text(
                  'Error loading video',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          );
        },
      );

      if (mounted) {
        setState(() {
          _videoControllers[index] = videoController;
          _chewieControllers[index] = chewieController;
        });
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
    }
  }

  void _onPageChanged(int index) async {
    // Pause previous video if any
    if (_videoControllers[_currentIndex] != null) {
      _videoControllers[_currentIndex]?.pause();
    }

    setState(() {
      _currentIndex = index;
    });

    // Initialize new video if it's a video type
    final currentUrl = widget.currentMessage.fileFullUrl![index];
    final fileType = FileTypeHelper.getFileType(currentUrl);
    
    if (fileType == FileType.video && !_videoControllers.containsKey(index)) {
      await _initializeVideo(index, currentUrl);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Dispose all video controllers
    for (var controller in _chewieControllers.values) {
      controller?.dispose();
    }
    for (var controller in _videoControllers.values) {
      controller?.dispose();
    }
    super.dispose();
  }

  Widget _buildMediaItem(String url, int index) {
    final fileType = FileTypeHelper.getFileType(url);

    if (fileType == FileType.video) {
      final chewieController = _chewieControllers[index];
      
      if (chewieController != null) {
        return Center(
          child: Chewie(controller: chewieController),
        );
      } else {
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      }
    } else {
      // Default to image for images and other files
      return CustomImage(
        image: url,
        fit: BoxFit.fitWidth,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Container(
      width: isDesktop ? 500 : MediaQuery.of(context).size.width,
      height: isDesktop ? 600 : MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: isDesktop ? const BorderRadius.all(Radius.circular(Dimensions.radiusExtraLarge)) : null,
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: Dimensions.paddingSizeLarge),

        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),

        Stack(
          children: [
            SizedBox(
              height: isDesktop ? 500 : MediaQuery.of(context).size.height - 70,
              width: double.infinity,
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.currentMessage.fileFullUrl!.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  return _buildMediaItem(widget.currentMessage.fileFullUrl![index], index);
                },
              ),
            ),

            Positioned(
              top: 0, left: 0, right: 0, bottom: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                child: Row(children: [
                  if (_currentIndex > 0)
                  InkWell(
                    onTap: () {
                      if (_currentIndex > 0) {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white),
                        color: Colors.black54,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  const Spacer(),

                  if (_currentIndex < widget.currentMessage.fileFullUrl!.length - 1)
                  InkWell(
                    onTap: () {
                      if (_currentIndex < widget.currentMessage.fileFullUrl!.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white),
                        color: Colors.black54,
                      ),
                      child: const Icon(Icons.arrow_forward, color: Colors.white),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ]),
    );
  }
}
