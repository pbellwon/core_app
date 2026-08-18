import 'package:flutter/material.dart';
import 'widgets/main_app_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'data/videos_data.dart';
import 'providers/auth_provider.dart';
import 'pages/video_detail_page.dart';



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
              summary: video['summary'] as String? ?? '',
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
                          final widthFactor = constraints.maxWidth > 1200 
                            ? 0.30 
                            : (constraints.maxWidth > 900 ? 0.45 : 0.9);

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
                                      final isInProg = authProvider.isInProgram(videoId);
                                      return _buildVideoCard(
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
  Widget _buildVideoCard(
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
                            onPressed: () {
                              // Find the video data from videosData
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
                            },
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
    );
  }

  /// Helper widget to build action buttons
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: isActive ? const Color(0xFFFF9800) : Colors.white,
        size: 20,
      ),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFB31288),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
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
  final String summary;
  final List<String> tags; // Tagi dla preferencji emocjonalnych
  final String practiceType;
  final String duration;
  final String position;
  final String props;
  const _VideoData({
    required this.url,
    required this.title,
    this.summary = '',
    this.tags = const [],
    this.practiceType = 'Movement Practice',
    this.duration = '15-20 minutes',
    this.position = 'Standing',
    this.props = 'No props',
  });
}