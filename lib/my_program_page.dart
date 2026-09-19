import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/videos_data.dart';
import 'providers/auth_provider.dart';
import 'providers/menu_provider.dart';
import 'widgets/main_app_bar.dart';
import 'pages/video_detail_page.dart';
import 'widgets/menu_overlay.dart';

class MyProgramPage extends StatefulWidget {
  const MyProgramPage({super.key});

  @override
  State<MyProgramPage> createState() => _MyProgramPageState();
}

class _MyProgramPageState extends State<MyProgramPage> {
  String _modalSearchQuery = '';
  bool _isSearchModalOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MenuProvider>(context, listen: false)
          .setCurrentPage('MyProgram');
    });
  }

  /// Get search-only results
  List<_VideoData> _getSearchOnlyVideos() {
    if (_modalSearchQuery.isEmpty) {
      return videosData
          .map((video) => _VideoData(
                url: video['url'] as String,
                title: video['title'] as String,
                summary: video['summary'] as String? ?? '',
                duration: video['duration'] as String? ?? '15-20 minutes',
                props: video['props'] as String? ?? 'No props',
              ))
          .toList();
    }

    final query = _modalSearchQuery.toLowerCase();
    return videosData
        .map((video) => _VideoData(
              url: video['url'] as String,
              title: video['title'] as String,
              summary: video['summary'] as String? ?? '',
              duration: video['duration'] as String? ?? '15-20 minutes',
              props: video['props'] as String? ?? 'No props',
            ))
        .where((video) {
          return video.title.toLowerCase().contains(query) ||
              video.summary.toLowerCase().contains(query) ||
              video.duration.toLowerCase().contains(query) ||
              video.props.toLowerCase().contains(query);
        })
        .toList();
  }

  /// Show search results modal
  void _showSearchResultsModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Search Videos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF860E66),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _isSearchModalOpen = false;
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (value) {
                        setStateModal(() => _modalSearchQuery = value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search in all videos...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _modalSearchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setStateModal(() => _modalSearchQuery = '');
                              },
                            )
                          : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _getSearchOnlyVideos().isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.video_library_outlined,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _modalSearchQuery.isEmpty
                                    ? 'Start typing to search...'
                                    : 'No videos found for "$_modalSearchQuery"',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : Consumer<AppAuthProvider>(
                            builder: (context, authProvider, child) {
                              return LayoutBuilder(
                                builder: (context, constraints) {
                                  final widthFactor = constraints.maxWidth > 1200 
                                    ? 0.30 
                                    : (constraints.maxWidth > 900 ? 0.45 : 0.9);

                                  return SingleChildScrollView(
                                    child: Wrap(
                                      alignment: WrapAlignment.center,
                                      spacing: 20,
                                      runSpacing: 20,
                                      children: [
                                        for (final video in _getSearchOnlyVideos())
                                          SizedBox(
                                            width: constraints.maxWidth * widthFactor,
                                            child: Builder(
                                              builder: (context) {
                                                final videoId = video.url;
                                                final isFav = authProvider.isFavourite(videoId);
                                                final isInProg = authProvider.isInProgram(videoId);
                                                return _buildVideoCard(
                                                  context,
                                                  video,
                                                  isFav,
                                                  () => authProvider.toggleFavouriteVideo(videoId),
                                                  isInProg,
                                                  () => authProvider.toggleProgramVideo(videoId),
                                                  1.0,
                                                );
                                              },
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                    ),
                  ],
                ),
              ),
              contentPadding: const EdgeInsets.all(20),
              insetPadding: const EdgeInsets.all(16),
            );
          },
        );
      },
    ).then((_) {
      setState(() {
        _isSearchModalOpen = false;
        _modalSearchQuery = '';
      });
    });
  }

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
                                  label: isInProgram ? 'Remove from my program' : 'Add to Program',
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      onTap: () {
                        if (!_isSearchModalOpen) {
                          _isSearchModalOpen = true;
                          _showSearchResultsModal(context);
                        }
                      },
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: 'Search all videos...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  Builder(
                    builder: (context) {
                      final programIds = authProvider.currentUser?.programVideos ?? [];
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
                      final programVideos = allVideos.where((v) => programIds.contains(v.url)).toList();
                      if (programVideos.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'You have no videos in your program yet.',
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
                                  for (int index = 0; index < programVideos.length; index++)
                                    SizedBox(
                                      width: constraints.maxWidth * widthFactor,
                                      child: Builder(
                                        builder: (context) {
                                          final video = programVideos[index];
                                          final isFav = authProvider.isFavourite(video.url);
                                          final isInProg = programIds.contains(video.url);
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

  _VideoData({
    required this.url,
    required this.title,
    required this.summary,
    required this.duration,
    required this.props,
  });
}

