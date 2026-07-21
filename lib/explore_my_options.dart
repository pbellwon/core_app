import 'package:flutter/material.dart';
import 'widgets/main_app_bar.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
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
  final Set<String> _selectedMovementConsiderationButtons = <String>{};
  bool _isMovementConsiderationExpanded = false;
  bool _isFiltersExpanded = false;
  
  // Filter selections
  final Set<String> _selectedPracticeTypes = <String>{};
  final Set<String> _selectedDurations = <String>{};
  final Set<String> _selectedPositions = <String>{};
  final Set<String> _selectedProps = <String>{};

  static const List<String> _movementConsiderationLabels = <String>[
    'Knee injury/pain',
    'Wrist injury/pain',
    'Shoulder injury/pain',
    'Lower-back injury/pain',
    'Upper back/neck injury/pain',
    'POTS / Blood pressure related dizziness',
  ];

  static const List<String> _practiceTypeLabels = <String>[
    'Meditation/visualisation',
    'Movement Practice',
  ];

  static const List<String> _durationLabels = <String>[
    '0-5 minutes',
    '5-15 minutes',
    '15-20 minutes',
    '20-30 minutes',
    '30+ minutes',
  ];

  static const List<String> _positionLabels = <String>[
    'Standing',
    'Sitting on a chair',
    'Sitting on a floor',
    'Laying down',
  ];

  static const List<String> _propsLabels = <String>[
    'No props',
    'Towel',
    'Pillow or bolster',
    'Mattress',
    'Tennis ball/massage ball',
    'Wall',
  ];

  @override
  void initState() {
    super.initState();
    // Convert videosData from Map to _VideoData objects
    _videos = videosData
        .map((video) => _VideoData(
              url: video['url'] as String,
              title: video['title'] as String,
              tags: List<String>.from(video['tags_movementconsiderations'] as List? ?? []),
              practiceType: video['practice_type'] as String? ?? 'Movement Practice',
              duration: video['duration'] as String? ?? '15-20 minutes',
              position: video['position'] as String? ?? 'Standing',
              props: video['props'] as String? ?? 'No props',
            ))
        .toList();

    // 🎯 Load movement consideration preferences from profile
    _loadMovementConsiderationPreferences();
  }

  /// 🎯 Load movement consideration preferences from user profile
  void _loadMovementConsiderationPreferences() {
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user?.movementConsiderations != null) {
      _selectedMovementConsiderationButtons
        ..clear()
        ..addAll(user!.movementConsiderations ?? []);
    } else {
      _selectedMovementConsiderationButtons.clear();
    }
  }

  /// 🎬 Get filtered videos based on selected filters
  List<_VideoData> _getFilteredVideos() {
    return _videos.where((video) {
      // Movement Considerations filter
      if (_selectedMovementConsiderationButtons.isNotEmpty) {
        final matchesMovement = video.tags
            .any((tag) => _selectedMovementConsiderationButtons.contains(tag));
        if (!matchesMovement) return false;
      }

      // Practice Type filter
      if (_selectedPracticeTypes.isNotEmpty) {
        if (!_selectedPracticeTypes.contains(video.practiceType)) return false;
      }

      // Duration filter
      if (_selectedDurations.isNotEmpty) {
        if (!_selectedDurations.contains(video.duration)) return false;
      }

      // Position filter
      if (_selectedPositions.isNotEmpty) {
        if (!_selectedPositions.contains(video.position)) return false;
      }

      // Props filter
      if (_selectedProps.isNotEmpty) {
        if (!_selectedProps.contains(video.props)) return false;
      }

      return true;
    }).toList();
  }

  /// 🔘 Build movement consideration toggle button
  Widget _buildMovementConsiderationToggleButton(String label) {
    final isSelected = _selectedMovementConsiderationButtons.contains(label);
    void onPressed() {
      setState(() {
        if (isSelected) {
          _selectedMovementConsiderationButtons.remove(label);
        } else {
          _selectedMovementConsiderationButtons.add(label);
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

  /// 🔍 Build movement consideration filter buttons group
  Widget _buildMovementConsiderationFilterButtons() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 520;

        if (isNarrow) {
          return Column(
            children: [
              for (final label in _movementConsiderationLabels) ...[
                SizedBox(
                  width: double.infinity,
                  child: _buildMovementConsiderationToggleButton(label),
                ),
                if (label != _movementConsiderationLabels.last)
                  const SizedBox(height: 8),
              ],
            ],
          );
        }

        return Column(
          children: [
            for (var i = 0; i < _movementConsiderationLabels.length; i += 2) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildMovementConsiderationToggleButton(
                      _movementConsiderationLabels[i],
                    ),
                  ),
                  if (i + 1 < _movementConsiderationLabels.length) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildMovementConsiderationToggleButton(
                        _movementConsiderationLabels[i + 1],
                      ),
                    ),
                  ] else ...[
                    const SizedBox(width: 8),
                    const Expanded(child: SizedBox.shrink()),
                  ],
                ],
              ),
              if (i + 2 < _movementConsiderationLabels.length)
                const SizedBox(height: 8),
            ],
          ],
        );
      },
    );
  }

  /// 🔘 Build filter checkbox
  Widget _buildFilterCheckbox(
    String label,
    bool isSelected,
    Function(bool?) onChanged,
  ) {
    return Row(
      children: [
        Checkbox(
          value: isSelected,
          onChanged: onChanged,
          activeColor: const Color(0xFF860E66),
        ),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  /// 🔍 Build filter checkbox group
  Widget _buildFilterCheckboxGroup(
    String title,
    List<String> labels,
    Set<String> selectedItems,
    Function(String) onToggle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF860E66),
          ),
        ),
        const SizedBox(height: 8),
        ...labels.map((label) {
          return _buildFilterCheckbox(
            label,
            selectedItems.contains(label),
            (_) => onToggle(label),
          );
        }).toList(),
        const SizedBox(height: 12),
      ],
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
                      // Movement Considerations Filter Button
                        OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _isMovementConsiderationExpanded = !_isMovementConsiderationExpanded;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF860E66),
                          side: const BorderSide(color: Color(0xFF860E66), width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Movement Considerations',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              _isMovementConsiderationExpanded ? Icons.expand_less : Icons.expand_more,
                            ),
                          ],
                        ),
                      ),
                      // Expanded Filters Section
                      if (_isMovementConsiderationExpanded) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: _buildMovementConsiderationFilterButtons(),
                        ),
                      ],
                      // Filters Button
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _isFiltersExpanded = !_isFiltersExpanded;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF860E66),
                          side: const BorderSide(color: Color(0xFF860E66), width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Filters',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              _isFiltersExpanded ? Icons.expand_less : Icons.expand_more,
                            ),
                          ],
                        ),
                      ),
                      // Expanded Filters Content
                      if (_isFiltersExpanded) ...[
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFilterCheckboxGroup(
                                'PRACTICE TYPE',
                                _practiceTypeLabels,
                                _selectedPracticeTypes,
                                (label) {
                                  setState(() {
                                    if (_selectedPracticeTypes.contains(label)) {
                                      _selectedPracticeTypes.remove(label);
                                    } else {
                                      _selectedPracticeTypes.add(label);
                                    }
                                  });
                                },
                              ),
                              _buildFilterCheckboxGroup(
                                'DURATION',
                                _durationLabels,
                                _selectedDurations,
                                (label) {
                                  setState(() {
                                    if (_selectedDurations.contains(label)) {
                                      _selectedDurations.remove(label);
                                    } else {
                                      _selectedDurations.add(label);
                                    }
                                  });
                                },
                              ),
                              _buildFilterCheckboxGroup(
                                'POSITION',
                                _positionLabels,
                                _selectedPositions,
                                (label) {
                                  setState(() {
                                    if (_selectedPositions.contains(label)) {
                                      _selectedPositions.remove(label);
                                    } else {
                                      _selectedPositions.add(label);
                                    }
                                  });
                                },
                              ),
                              _buildFilterCheckboxGroup(
                                'PROPS',
                                _propsLabels,
                                _selectedProps,
                                (label) {
                                  setState(() {
                                    if (_selectedProps.contains(label)) {
                                      _selectedProps.remove(label);
                                    } else {
                                      _selectedProps.add(label);
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
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
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 900;
                          final widthFactor = isWide ? 0.45 : 0.9;

                          return Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 20,
                            runSpacing: 20,
                            children: [
                              for (int index = 0; index < filteredVideos.length; index++)
                                SizedBox(
                                  width: constraints.maxWidth * widthFactor,
                                  child: Builder(
                                    builder: (context) {
                                      final video = filteredVideos[index];
                                      final videoId = video.url;
                                      final isFav = authProvider.isFavourite(videoId);
                                      return _buildVideoCard(video, isFav, () {
                                        authProvider.toggleFavouriteVideo(videoId);
                                      }, 1.0);
                                    },
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
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
  Widget _buildVideoCard(_VideoData video, bool isFav, VoidCallback onFavToggle, double widthFactor) {
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
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openVideoPage(String url) {
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

class _VideoData {
  final String url;
  final String title;
  final List<String> tags; // Tagi dla preferencji emocjonalnych
  final String practiceType;
  final String duration;
  final String position;
  final String props;
  const _VideoData({
    required this.url,
    required this.title,
    this.tags = const [],
    this.practiceType = 'Movement Practice',
    this.duration = '15-20 minutes',
    this.position = 'Standing',
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
    final htmlContent = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    body {
      margin: 0;
      padding: 0;
      background-color: black;
    }
    .video-container {
      position: relative;
      width: 100%;
      padding-bottom: 56.25%;
      height: 0;
      overflow: hidden;
    }
    .video-container iframe {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      border: none;
    }
  </style>
</head>
<body>
  <div class="video-container">
    <iframe 
      src="https://www.youtube.com/embed/$videoId?autoplay=1&modestbranding=1&rel=0"
      title="YouTube video player"
      frameborder="0"
      allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
      allowfullscreen>
    </iframe>
  </div>
</body>
</html>
''';

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
            // InAppWebView z YouTube
            InAppWebView(
              initialData: InAppWebViewInitialData(data: htmlContent),
              onLoadError: (controller, url, code, message) {
                setState(() => _webViewFailed = true);
              },
            ),
            // Close button
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
}

class YoutubePlayerScreen extends StatefulWidget {
  final String videoUrl;
  const YoutubePlayerScreen({super.key, required this.videoUrl});

  @override
  State<YoutubePlayerScreen> createState() => _YoutubePlayerScreenState();
}

class _YoutubePlayerScreenState extends State<YoutubePlayerScreen> {
  @override
  void initState() {
    super.initState();
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
    final videoId = _extractYoutubeId(widget.videoUrl);
    final htmlContent = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    body {
      margin: 0;
      padding: 0;
      background-color: black;
    }
    .video-container {
      position: relative;
      width: 100%;
      padding-bottom: 56.25%;
      height: 0;
      overflow: hidden;
    }
    .video-container iframe {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      border: none;
    }
  </style>
</head>
<body>
  <div class="video-container">
    <iframe 
      src="https://www.youtube.com/embed/$videoId?autoplay=1&modestbranding=1&rel=0"
      title="YouTube video player"
      frameborder="0"
      allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
      allowfullscreen>
    </iframe>
  </div>
</body>
</html>
''';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Odtwarzacz YouTube'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: InAppWebView(
        initialData: InAppWebViewInitialData(data: htmlContent),
      ),
    );
  }
}