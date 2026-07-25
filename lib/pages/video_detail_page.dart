import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../providers/auth_provider.dart';
import '../widgets/main_app_bar.dart';

class VideoDetailPage extends StatefulWidget {
  final Map<String, dynamic> videoData;

  const VideoDetailPage({
    super.key,
    required this.videoData,
  });

  @override
  State<VideoDetailPage> createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _updateFavoriteStatus();
  }

  void _updateFavoriteStatus() {
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    _isFavorite = authProvider.isFavourite(widget.videoData['url'] as String);
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.videoData['title'] as String;
    final summary = widget.videoData['summary'] as String? ?? '';
    final description = widget.videoData['description'] as String? ?? '';
    final duration = widget.videoData['duration'] as String? ?? '15-20 minutes';
    final position = widget.videoData['position'] as String? ?? 'Standing';
    final props = widget.videoData['props'] as String? ?? 'No props';
    final practiceType = widget.videoData['practice_type'] as String? ?? 'Movement Practice';
    final url = widget.videoData['url'] as String;

    return Scaffold(
      appBar: const MainAppBar(
        title: '',
        showBackButton: true,
      ),
      body: Consumer<AppAuthProvider>(
        builder: (context, authProvider, child) {
          _isFavorite = authProvider.isFavourite(url);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 📌 TITLE AND FAVORITE BUTTON
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              _isFavorite ? Icons.star : Icons.star_border,
                              color: _isFavorite ? Colors.amber : Colors.grey,
                              size: 32,
                            ),
                            onPressed: () {
                              authProvider.toggleFavouriteVideo(url);
                              setState(() {
                                _isFavorite = !_isFavorite;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 🎥 VIDEO PLAYER
                      Builder(
                        builder: (context) {
                          final videoId = _extractYoutubeId(url);
                          if (videoId.isEmpty) {
                            return Center(
                              child: Container(
                                width: 400,
                                height: 280,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Icon(Icons.error, color: Colors.red, size: 48),
                                ),
                              ),
                            );
                          }
                          return Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: GestureDetector(
                                onTap: () => _openVideoPlayer(context, url),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Image.network(
                                      'https://img.youtube.com/vi/$videoId/maxresdefault.jpg',
                                      width: 400,
                                      height: 280,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, progress) {
                                        if (progress == null) return child;
                                        return Container(
                                          width: 400,
                                          height: 280,
                                          color: Colors.grey[200],
                                          child: const Center(
                                            child: SizedBox(
                                              width: 32,
                                              height: 32,
                                              child:
                                                  CircularProgressIndicator(strokeWidth: 2),
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) =>
                                          Container(
                                        width: 400,
                                        height: 280,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.broken_image,
                                            color: Colors.red, size: 48),
                                      ),
                                    ),
                                    Container(
                                      width: 400,
                                      height: 280,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.9),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.play_arrow,
                                            color: Color(0xFF860E66),
                                            size: 48,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Text(
                                          'PLAY NOW',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // 📋 SUMMARY SECTION
                      if (summary.isNotEmpty) ...[
                        Text(
                          'Summary',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF860E66),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          summary,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // 📝 DESCRIPTION SECTION
                      if (description.isNotEmpty) ...[
                        Text(
                          'Description',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF860E66),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // ℹ️ DETAILS SECTION
                      Text(
                        'Details',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF860E66),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow('Practice Type:', practiceType),
                      const SizedBox(height: 12),
                      _buildDetailRow('Duration:', duration),
                      const SizedBox(height: 12),
                      _buildDetailRow('Position:', position),
                      const SizedBox(height: 12),
                      _buildDetailRow('Props:', props),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Helper widget to build detail rows
  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF860E66),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  void _openVideoPlayer(BuildContext context, String url) {
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
                    const Icon(Icons.video_library,
                        color: Colors.white, size: 64),
                    const SizedBox(height: 20),
                    const Text(
                      'Unable to load video',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9800),
                      ),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final videoId = _extractYoutubeId(widget.videoUrl);
    final embedUrl = 'https://www.youtube.com/embed/$videoId';

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      backgroundColor: Colors.black,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 32,
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        color: Colors.black,
        child: Stack(
          children: [
            InAppWebView(
              initialSettings: InAppWebViewSettings(
                mediaPlaybackRequiresUserGesture: false,
                allowsInlineMediaPlayback: true,
              ),
              initialUrlRequest: URLRequest(url: WebUri(embedUrl)),
              onWebViewCreated: (controller) {},
              onLoadError: (controller, url, code, message) {
                debugPrint('WebView load error: $message');
              },
            ),
          ],
        ),
      ),
    );
  }
}
