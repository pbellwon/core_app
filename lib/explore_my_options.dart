// lib/explore_my_options.dart

import 'package:flutter/material.dart';
import 'widgets/main_app_bar.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/link.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'data/videos_data.dart';
import 'providers/auth_provider.dart';



class ExploreMyOptionsPage extends StatefulWidget {
  const ExploreMyOptionsPage({super.key});

  @override
  State<ExploreMyOptionsPage> createState() => _ExploreMyOptionsPageState();
}

class _ExploreMyOptionsPageState extends State<ExploreMyOptionsPage> {
  late final List<_VideoData> _videos;
  final Set<String> _selectedEmotionalEnergyButtons = <String>{};

  static const List<String> _emotionalEnergyLabels = <String>[
    'Easing feelings of anxiety or overwhelm',
    'Lifting low energy or finding motivation again',
    'Moving through feeling stuck or frozen',
    'Reconnecting with calm, joy, or steady energy',
  ];

  @override
  void initState() {
    super.initState();
    // Convert videosData from Map to _VideoData objects
    _videos = videosData
        .map((video) => _VideoData(
              url: video['url'] as String,
              title: video['title'] as String,
              tags: List<String>.from(video['tags'] as List),
            ))
        .toList();
  }

  /// 🎬 Get filtered videos based on selected emotional energy buttons
  List<_VideoData> _getFilteredVideos() {
    if (_selectedEmotionalEnergyButtons.isEmpty) {
      return _videos;
    }
    return _videos
        .where((video) => video.tags
            .any((tag) => _selectedEmotionalEnergyButtons.contains(tag)))
        .toList();
  }

  /// 🔘 Build emotional energy toggle button
  Widget _buildEmotionalEnergyToggleButton(String label) {
    final isSelected = _selectedEmotionalEnergyButtons.contains(label);
    void onPressed() {
      setState(() {
        if (isSelected) {
          _selectedEmotionalEnergyButtons.remove(label);
        } else {
          _selectedEmotionalEnergyButtons.add(label);
        }
      });
    }

    final buttonChild = Text(
      label,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
      textAlign: TextAlign.center,
    );

    if (isSelected) {
      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: buttonChild,
      );
    }

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF860E66),
        side: const BorderSide(color: Color(0xFF860E66)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: buttonChild,
    );
  }

  /// 🔍 Build emotional energy filter buttons group
  Widget _buildEmotionalEnergyFilterButtons() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 520;

        if (isNarrow) {
          return Column(
            children: [
              for (final label in _emotionalEnergyLabels) ...[
                SizedBox(
                  width: double.infinity,
                  child: _buildEmotionalEnergyToggleButton(label),
                ),
                if (label != _emotionalEnergyLabels.last)
                  const SizedBox(height: 8),
              ],
            ],
          );
        }

        return Column(
          children: [
            for (var i = 0; i < _emotionalEnergyLabels.length; i += 2) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildEmotionalEnergyToggleButton(
                      _emotionalEnergyLabels[i],
                    ),
                  ),
                  if (i + 1 < _emotionalEnergyLabels.length) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildEmotionalEnergyToggleButton(
                        _emotionalEnergyLabels[i + 1],
                      ),
                    ),
                  ] else ...[
                    const SizedBox(width: 8),
                    const Expanded(child: SizedBox.shrink()),
                  ],
                ],
              ),
              if (i + 2 < _emotionalEnergyLabels.length)
                const SizedBox(height: 8),
            ],
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(
        title: '',
        showBackButton: true,
      ),
      body: Consumer<AppAuthProvider>(
        builder: (context, authProvider, child) {
          final filteredVideos = _getFilteredVideos();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔽 FILTERS AT THE TOP
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Filter by emotional support:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF860E66),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildEmotionalEnergyFilterButtons(),
                      if (_selectedEmotionalEnergyButtons.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            'Showing ${filteredVideos.length} video(s)',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // 📺 VIDEOS LIST
                if (filteredVideos.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.video_library_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No videos found for this filter',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        for (int index = 0; index < filteredVideos.length; index++) ...[
                          Builder(
                            builder: (context) {
                              final video = filteredVideos[index];
                              final videoId = video.url;
                              final isFav = authProvider.isFavourite(videoId);
                              return _buildVideoCard(video, isFav, () {
                                authProvider.toggleFavouriteVideo(videoId);
                              });
                            },
                          ),
                          if (index < filteredVideos.length - 1)
                            const SizedBox(height: 20),
                        ],
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  // Zmieniam sygnaturę _buildVideoCard
  Widget _buildVideoCard(_VideoData video, bool isFav, VoidCallback onFavToggle) {
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.5,
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
    // Na webie i desktopie otwieraj w przeglądarce, na Android/iOS player
    if (kIsWeb) {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nie można otworzyć linku.')),
        );
      }
      return;
    }
    // Rozpoznanie platformy mobilnej przez Theme.of(context).platform
    final platform = Theme.of(context).platform;
    if (platform == TargetPlatform.android || platform == TargetPlatform.iOS) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => YoutubePlayerScreen(videoUrl: url),
        ),
      );
    } else {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nie można otworzyć linku.')),
        );
      }
    }
  }
}

class _VideoData {
  final String url;
  final String title;
  final List<String> tags; // Tagi dla preferencji emocjonalnych
  const _VideoData({
    required this.url,
    required this.title,
    this.tags = const [],
  });
}

class YoutubePlayerScreen extends StatefulWidget {
  final String videoUrl;
  const YoutubePlayerScreen({super.key, required this.videoUrl});

  @override
  State<YoutubePlayerScreen> createState() => _YoutubePlayerScreenState();
}

class _YoutubePlayerScreenState extends State<YoutubePlayerScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl)!;
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Odtwarzacz YouTube'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Colors.blueAccent,
          ),
        ),
      ),
    );
  }
}