import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
import 'data/videos_data.dart';
import 'providers/auth_provider.dart';
import 'widgets/main_app_bar.dart';
import 'widgets/menu_overlay.dart';

class MyFavouritesPage extends StatelessWidget {
  const MyFavouritesPage({super.key});

  Widget _buildVideoCard(BuildContext context, _VideoData video, bool isFav, VoidCallback onFavToggle, double widthFactor) {
    return Center(
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        video.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isFav ? Icons.star : Icons.star_border,
                        color: isFav ? Colors.amber : Colors.grey,
                      ),
                      onPressed: onFavToggle,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Builder(
                  builder: (context) {
                    final videoId = _extractYoutubeId(video.url);
                    if (videoId.isEmpty) {
                      return Container(
                        height: 120,
                        color: Colors.grey[300],
                        child: const Center(child: Icon(Icons.error, color: Colors.red)),
                      );
                    }
                    return InkWell(
                      onTap: () => _openVideoPage(context, video.url),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            'https://img.youtube.com/vi/$videoId/hqdefault.jpg',
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                color: Colors.grey[200],
                                child: const Center(child: CircularProgressIndicator()),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: Colors.grey[300],
                              child: const Center(child: Icon(Icons.broken_image, color: Colors.red)),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openVideoPage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => VideoPlayerDialog(videoUrl: url),
    );
  }

  String _extractYoutubeId(String url) {
    final regex = RegExp(
      r'(?:youtube\.com\/watch\?v=|youtu\.be\/)([^&\n?#]+)',
      caseSensitive: false,
    );
    final match = regex.firstMatch(url);
    return match?.group(1) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return MenuOverlay(
      child: Scaffold(
        appBar: const MainAppBar(
          title: '',
          showBackButton: true,
        ),
        body: Consumer<AppAuthProvider>(
          builder: (context, authProvider, child) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  Builder(
                    builder: (context) {
                      final favIds = authProvider.currentUser?.favouriteVideos ?? [];
                      // Konwertuj videosData do listy _VideoData
                      final allVideos = videosData
                          .map((v) => _VideoData(
                                url: v['url'] as String,
                                title: v['title'] as String,
                              ))
                          .toList();
                      final favVideos = allVideos.where((v) => favIds.contains(v.url)).toList();
                      if (favVideos.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'You have no favourite videos yet.',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        );
                      }
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final isWide = constraints.maxWidth > 900;
                              final widthFactor = isWide ? 0.28 : 0.9;

                              return Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 20,
                                runSpacing: 20,
                                children: [
                                  for (int index = 0; index < favVideos.length; index++)
                                    SizedBox(
                                      width: constraints.maxWidth * widthFactor,
                                      child: Builder(
                                        builder: (context) {
                                          final video = favVideos[index];
                                          final isFav = favIds.contains(video.url);
                                          return _buildVideoCard(context, video, isFav, () {
                                            authProvider.toggleFavouriteVideo(video.url);
                                          }, 1.0);
                                        },
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _VideoData {
  final String url;
  final String title;
  const _VideoData({required this.url, required this.title});
}

class VideoPlayerDialog extends StatefulWidget {
  final String videoUrl;
  const VideoPlayerDialog({super.key, required this.videoUrl});

  @override
  State<VideoPlayerDialog> createState() => _VideoPlayerDialogState();
}

class _VideoPlayerDialogState extends State<VideoPlayerDialog> {
  bool _webViewFailed = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    try {
      final videoId = _extractYoutubeId(widget.videoUrl);
      if (videoId.isEmpty) {
        setState(() => _webViewFailed = true);
        return;
      }
    } catch (e) {
      setState(() => _webViewFailed = true);
      debugPrint('WebView initialization failed: $e');
    }
  }

  String _extractYoutubeId(String url) {
    final regex = RegExp(
      r'(?:youtube\.com\/watch\?v=|youtu\.be\/)([^&\n?#]+)',
      caseSensitive: false,
    );
    final match = regex.firstMatch(url);
    return match?.group(1) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    if (_webViewFailed) {
      return Dialog(
        insetPadding: const EdgeInsets.all(16),
        backgroundColor: Colors.black,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 32,
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          color: Colors.black,
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.video_library, color: Colors.white, size: 64),
                    const SizedBox(height: 20),
                    Text(
                      'Otwórz film na YouTube',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        final uri = Uri.parse(widget.videoUrl);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                        if (mounted) Navigator.pop(context);
                      },
                      child: const Text('Otwórz w przeglądarce'),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(200),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.close, color: Colors.black, size: 24),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final videoId = _extractYoutubeId(widget.videoUrl);

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      backgroundColor: Colors.black,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 32,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        color: Colors.black,
        child: Stack(
          children: [
            // InAppWebView z YouTube - Direct embed URL
            InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri('https://www.youtube.com/embed/$videoId?autoplay=1&modestbranding=1&rel=0&fs=1'),
              ),
              onLoadError: (controller, url, code, message) {
                debugPrint('WebView error: $code - $message');
                setState(() => _webViewFailed = true);
              },
            ),
            // Close button - na wierzchu
            Positioned(
              top: 8,
              right: 8,
              child: Material(
                color: Colors.transparent,
                child: IconButton(
                  icon: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(200),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.close, color: Colors.black, size: 20),
                  ),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Zamknij',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
