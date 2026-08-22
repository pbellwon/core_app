import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/videos_data.dart';
import 'providers/auth_provider.dart';
import 'widgets/main_app_bar.dart';
import 'widgets/menu_overlay.dart';
import 'pages/video_detail_page.dart';

class MyFavouritesPage extends StatelessWidget {
  const MyFavouritesPage({super.key});

  void _openVideoDetail(BuildContext context, _VideoData video) {
    final videoData = videosData.firstWhere(
      (v) => v['url'] == video.url,
      orElse: () => {},
    );
    if (videoData.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => VideoDetailPage(
            videoData: videoData,
          ),
        ),
      );
    }
  }

  Widget _buildVideoCard(
    BuildContext context,
    _VideoData video,
    bool isFav,
    VoidCallback onFavToggle,
    bool isInProgram,
    VoidCallback onProgramToggle,
    double widthFactor,
  ) {
    return Center(
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        child: InkWell(
          onTap: () => _openVideoDetail(context, video),
          borderRadius: BorderRadius.circular(12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 📌 TITLE
                  Text(
                    video.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  // 📺 THUMBNAIL AND INFO COLUMN
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // THUMBNAIL
                      Builder(
                        builder: (context) {
                          final videoId = _extractYoutubeId(video.url);
                          if (videoId.isEmpty) {
                            return Container(
                              height: 180,
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
                              height: 180,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  height: 180,
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
                                height: 180,
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
                      const SizedBox(height: 12),
                      // INFO COLUMN
                      Column(
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
                              onPressed: () => _openVideoDetail(context, video),
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
                          const SizedBox(height: 12),
                          // ACTION BUTTONS ROW
                          Row(
                            children: [
                              Expanded(
                                child: _buildActionButton(
                                  icon: Icons.star,
                                  label: 'Add to Favourites',
                                  isActive: isFav,
                                  onPressed: onFavToggle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildActionButton(
                                  icon: Icons.check_box,
                                  label: 'Add to Program',
                                  isActive: isInProgram,
                                  onPressed: onProgramToggle,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Helper widget to build info rows
  /// Helper widget to build action buttons (icon + text, clickable)
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFFFF9800) : Colors.grey[600],
            size: 20,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? const Color(0xFFFF9800) : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

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
          showBackButton: false,
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
                              final widthFactor = constraints.maxWidth > 1200 
                                ? 0.30 
                                : (constraints.maxWidth > 900 ? 0.45 : 0.9);

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
                                          final isInProg = authProvider.isInProgram(video.url);
                                          return _buildVideoCard(
                                            context,
                                            video,
                                            isFav,
                                            () => authProvider.toggleFavouriteVideo(video.url),
                                            isInProg,
                                            () => authProvider.toggleProgramVideo(video.url),
                                            1.0,
                                          );
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
