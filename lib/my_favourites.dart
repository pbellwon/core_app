import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'providers/auth_provider.dart';
import 'widgets/main_app_bar.dart';
import 'widgets/menu_overlay.dart';

class MyFavouritesPage extends StatelessWidget {
  const MyFavouritesPage({super.key});

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
            // Lista wszystkich dostępnych filmów (można wydzielić do osobnego pliku)
            final allVideos = [
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
            final favVideos = allVideos.where((v) => favIds.contains(v.url)).toList();
            if (favVideos.isEmpty) {
              return const Center(
                child: Text(
                  'You have no favourite videos yet.',
                  style: TextStyle(fontSize: 18),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: favVideos.length,
              separatorBuilder: (_, _) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                final video = favVideos[index];
                final videoId = YoutubePlayer.convertUrlToId(video.url);
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: videoId != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              'https://img.youtube.com/vi/$videoId/hqdefault.jpg',
                              width: 80,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(Icons.broken_image),
                    title: Text(video.title),
                    subtitle: Text(video.url),
                    onTap: () {
                      // Otwórz video jak w explore_my_options
                      final uri = Uri.parse(video.url);
                      launchUrl(uri, mode: LaunchMode.externalApplication);
                    },
                  ),
                );
              },
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
