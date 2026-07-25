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
          borderRadius: BorderRadius.circular(12),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 📌 TITLE WITH FAVORITE BUTTON
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        video.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isFav ? Icons.star : Icons.star_border,
                        color: isFav ? Colors.amber : Colors.grey,
                        size: 28,
                      ),
                      onPressed: onFavToggle,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // 📺 THUMBNAIL AND INFO ROW
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // THUMBNAIL
                    Builder(
                      builder: (context) {
                        final videoId = _extractYoutubeId(video.url);
                        if (videoId.isEmpty) {
                          return Container(
                            width: 140,
                            height: 110,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.error, color: Colors.red, size: 28),
                          );
                        }
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            'https://img.youtube.com/vi/$videoId/hqdefault.jpg',
                            width: 140,
                            height: 110,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                width: 140,
                                height: 110,
                                color: Colors.grey[200],
                                child: const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 140,
                              height: 110,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.broken_image, color: Colors.red, size: 28),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    // INFO COLUMN
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // SUMMARY
                          _buildInfoRow(
                            'SUMMARY:',
                            video.summary,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 8),
                          // PROPS
                          _buildInfoRow(
                            'PROPS:',
                            video.props,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 8),
                          // DURATION
                          _buildInfoRow(
                            'DURATION:',
                            video.duration,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 10),
                          // EXPLORE NOW BUTTON
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _openVideoPage(context, video.url),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF9800),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Explore Now',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Helper widget to build info rows
  Widget _buildInfoRow(String label, String value, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF860E66),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black87,
          ),
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
        ),
      ],
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
                                summary: v['summary'] as String? ?? '',
                                duration: v['duration'] as String? ?? '15-20 minutes',
                                props: v['props'] as String? ?? 'No props',
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
                              final widthFactor = isWide ? 0.45 : 0.9;

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
  final String summary;
  final String duration;
  final String props;
  const _VideoData({
    required this.url,
    required this.title,
    this.summary = '',
    this.duration = '15-20 minutes',
    this.props = 'No props',
  });
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
        child: Column(
          children: [
            // Close button header
            Container(
              height: 50,
              color: Colors.black,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 48), // Placeholder for left
                  const Text(
                    'YouTube',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  SizedBox(
                    width: 48,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Zamknij',
                    ),
                  ),
                ],
              ),
            ),
            // WebView - Expanded
            Expanded(
              child: InAppWebView(
                initialUrlRequest: URLRequest(
                  url: WebUri('https://www.youtube.com/embed/$videoId?autoplay=1&modestbranding=1&rel=0&fs=1'),
                ),
                onLoadError: (controller, url, code, message) {
                  debugPrint('WebView error: $code - $message');
                  setState(() => _webViewFailed = true);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
