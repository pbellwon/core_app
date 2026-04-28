// lib/explore_my_options.dart

import 'package:flutter/material.dart';
import 'widgets/main_app_bar.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/link.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';



class ExploreMyOptionsPage extends StatefulWidget {
  const ExploreMyOptionsPage({super.key});

  @override
  State<ExploreMyOptionsPage> createState() => _ExploreMyOptionsPageState();
}

class _ExploreMyOptionsPageState extends State<ExploreMyOptionsPage> {
  final List<_VideoData> _videos = [
    _VideoData(
      url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      title: 'Vid 1',
    ),
    _VideoData(
      url: 'https://www.youtube.com/watch?v=5qap5aO4i9A',
      title: 'Vid 2',
    ),
    _VideoData(
      url: 'https://www.youtube.com/watch?v=V-_O7nl0Ii0',
      title: 'Vid 3',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(
        title: '',
        showBackButton: true,
      ),
      body: Consumer<AppAuthProvider>(
        builder: (context, authProvider, child) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _videos.length,
            separatorBuilder: (_, _) => const SizedBox(height: 20),
            itemBuilder: (context, index) {
              final video = _videos[index];
              final videoId = video.url; // lub YoutubePlayer.convertUrlToId(video.url) ?? video.url
              final isFav = authProvider.isFavourite(videoId);
              return _buildVideoCard(video, isFav, () {
                authProvider.toggleFavouriteVideo(videoId);
              });
            },
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
  const _VideoData({required this.url, required this.title});
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