import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/link.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
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
                    final videoId = YoutubePlayer.convertUrlToId(video.url);
                    if (videoId == null) {
                      return Container(
                        height: 120,
                        color: Colors.grey[300],
                        child: const Center(child: Icon(Icons.error, color: Colors.red)),
                      );
                    }
                    if (kIsWeb) {
                      return Link(
                        uri: Uri.parse(video.url),
                        target: LinkTarget.blank,
                        builder: (context, followLink) => AspectRatio(
                          aspectRatio: 16 / 9,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: followLink,
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
                        ),
                      );
                    } else {
                      return InkWell(
                        onTap: () => _openVideoPage(video.url),
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
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openVideoPage(String url) async {
    final uri = Uri.parse(url);
    if (kIsWeb) {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return;
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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
                child: Text(
                  'You have no favourite videos yet.',
                  style: TextStyle(fontSize: 18),
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
      ),
    );
  }
}

class _VideoData {
  final String url;
  final String title;
  const _VideoData({required this.url, required this.title});
}
