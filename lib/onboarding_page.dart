// lib/onboarding_page.dart - ONBOARDING DIALOG Z 8 STRONAMI
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  OnboardingPageState createState() => OnboardingPageState();
}

class OnboardingPageState extends State<OnboardingPage> {
  int _currentPage = 0;
  final int _totalPages = 8;

  // 📋 MOVEMENT CONSIDERATIONS (strona 2)
  final Set<String> _selectedMovementConsiderations = <String>{};

  static const List<String> _movementConsiderationLabels = <String>[
    'Knee injury/pain',
    'Wrist injury/pain',
    'Shoulder injury/pain',
    'Lower-back injury/pain',
    'Upper back/neck injury/pain',
    'POTS / Blood pressure related dizziness',
  ];

  // 🎯 EXERCISE TYPE (strona 3)
  final Set<String> _selectedExerciseTypes = <String>{};
  static const List<String> _exerciseTypeLabels = <String>[
    'Cardio',
    'Strength',
    'Flexibility',
    'Balance',
    'Functional',
    'Sports',
  ];

  // 🎯 FITNESS GOALS (strona 4)
  final Set<String> _selectedGoals = <String>{};
  static const List<String> _goalsLabels = <String>[
    'Weight Loss',
    'Build Muscle',
    'Increase Endurance',
    'Improve Flexibility',
    'Injury Recovery',
    'General Health',
  ];

  // 🕐 EXPERIENCE LEVEL (strona 5) - single choice
  String? _selectedExperienceLevel;
  static const List<String> _experienceLevelLabels = <String>[
    'Beginner',
    'Intermediate',
    'Advanced',
  ];

  // ⏱️ AVAILABLE TIME (strona 6) - single choice
  String? _selectedAvailableTime;
  static const List<String> _availableTimeLabels = <String>[
    '15-30 minutes',
    '30-45 minutes',
    '45-60 minutes',
    '60+ minutes',
  ];

  // 📍 PREFERRED LOCATION (strona 7) - multiple choice
  final Set<String> _selectedLocations = <String>{};
  static const List<String> _locationLabels = <String>[
    'Home',
    'Gym',
    'Outdoor',
    'Park',
    'Beach',
    'Studio',
  ];

  bool _isLoading = false;

  /// 🔧 WIDGET DO BUDOWANIA TOGGLE BUTTON
  Widget _buildToggleButton(String label, bool isSelected, VoidCallback onPressed) {
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

  /// 🔧 WIDGET DO BUDOWANIA GRUPY PRZYCISKÓW
  Widget _buildButtonGroup(List<String> labels, Set<String> selectedSet, bool multiSelect) {
    return Wrap(
      spacing: 8,
      runSpacing: 12,
      children: [
        for (final label in labels)
          SizedBox(
            width: (MediaQuery.of(context).size.width - 80) / 2,
            child: _buildToggleButton(
              label,
              selectedSet.contains(label),
              () {
                setState(() {
                  if (selectedSet.contains(label)) {
                    selectedSet.remove(label);
                  } else {
                    if (!multiSelect) {
                      selectedSet.clear();
                    }
                    selectedSet.add(label);
                  }
                });
              },
            ),
          ),
      ],
    );
  }

  /// 📄 STRONA 1: WELCOME
  Widget _buildPage1() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.celebration, size: 80, color: Color(0xFF860E66)),
          const SizedBox(height: 32),
          const Text(
            "Hey I'm glad you are here let's start",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF860E66),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'We will help you find the perfect workouts',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 📄 STRONA 2: MOVEMENT CONSIDERATIONS
  Widget _buildPage2() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Movement Considerations',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF860E66),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select any that apply to you',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          _buildButtonGroup(
            _movementConsiderationLabels,
            _selectedMovementConsiderations,
            true,
          ),
        ],
      ),
    );
  }

  /// 📄 STRONA 3: EXERCISE TYPES
  Widget _buildPage3() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What types of exercises do you enjoy?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF860E66),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select all that interest you',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          _buildButtonGroup(
            _exerciseTypeLabels,
            _selectedExerciseTypes,
            true,
          ),
        ],
      ),
    );
  }

  /// 📄 STRONA 4: FITNESS GOALS
  Widget _buildPage4() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What are your fitness goals?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF860E66),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select all that apply',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          _buildButtonGroup(
            _goalsLabels,
            _selectedGoals,
            true,
          ),
        ],
      ),
    );
  }

  /// 📄 STRONA 5: EXPERIENCE LEVEL
  Widget _buildPage5() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What is your fitness level?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF860E66),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select one that best describes you',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              for (final level in _experienceLevelLabels) ...[
                SizedBox(
                  width: double.infinity,
                  child: _buildToggleButton(
                    level,
                    _selectedExperienceLevel == level,
                    () {
                      setState(() {
                        _selectedExperienceLevel = level;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// 📄 STRONA 6: AVAILABLE TIME
  Widget _buildPage6() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How much time can you dedicate?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF860E66),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose your typical workout duration',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              for (final time in _availableTimeLabels) ...[
                SizedBox(
                  width: double.infinity,
                  child: _buildToggleButton(
                    time,
                    _selectedAvailableTime == time,
                    () {
                      setState(() {
                        _selectedAvailableTime = time;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// 📄 STRONA 7: PREFERRED LOCATIONS
  Widget _buildPage7() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Where do you prefer to exercise?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF860E66),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select all that apply',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          _buildButtonGroup(
            _locationLabels,
            _selectedLocations,
            true,
          ),
        ],
      ),
    );
  }

  /// 📄 STRONA 8: SUMMARY / COMPLETION
  Widget _buildPage8() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Icon(Icons.check_circle, size: 80, color: Colors.green),
          ),
          const SizedBox(height: 24),
          const Text(
            'All set!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF860E66),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "You're ready to start your fitness journey. Click 'Done' to continue.",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryRow(
                    'Movement Considerations',
                    _selectedMovementConsiderations.isEmpty
                        ? 'None selected'
                        : '${_selectedMovementConsiderations.length} selected',
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    'Exercise Types',
                    _selectedExerciseTypes.isEmpty
                        ? 'None selected'
                        : '${_selectedExerciseTypes.length} selected',
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    'Fitness Goals',
                    _selectedGoals.isEmpty
                        ? 'None selected'
                        : '${_selectedGoals.length} selected',
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    'Experience Level',
                    _selectedExperienceLevel ?? 'Not selected',
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    'Available Time',
                    _selectedAvailableTime ?? 'Not selected',
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    'Preferred Locations',
                    _selectedLocations.isEmpty
                        ? 'None selected'
                        : '${_selectedLocations.length} selected',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ],
    );
  }

  /// 🎯 RETURN CURRENT PAGE WIDGET
  Widget _buildCurrentPage() {
    switch (_currentPage) {
      case 0:
        return _buildPage1();
      case 1:
        return _buildPage2();
      case 2:
        return _buildPage3();
      case 3:
        return _buildPage4();
      case 4:
        return _buildPage5();
      case 5:
        return _buildPage6();
      case 6:
        return _buildPage7();
      case 7:
        return _buildPage8();
      default:
        return _buildPage1();
    }
  }

  /// 💾 SAVE ONBOARDING DATA TO FIREBASE
  Future<void> _completeOnboarding() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AppAuthProvider>();

      // Zapisz movement considerations
      await authProvider.updateUserProfile(
        movementConsiderations: _selectedMovementConsiderations.toList()..sort(),
      );

      // Oznacz onboarding jako ukończony
      await authProvider.markOnboardingComplete();

      // Close dialog i wróć do welcome page
      if (!mounted) return;
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Welcome! Your profile is ready.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 🚪 SKIP ONBOARDING
  Future<void> _skipOnboarding() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AppAuthProvider>();

      // Oznacz onboarding jako ukończony (bez zapisywania danych)
      await authProvider.markOnboardingComplete();

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 📄 CONTENT
            SizedBox(
              height: 400,
              child: _buildCurrentPage(),
            ),

            const SizedBox(height: 32),

            // 📊 PAGE INDICATOR (na dole)
            Text(
              '${_currentPage + 1} / $_totalPages',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 24),

            // 🔘 BUTTONS
            Row(
              children: [
                // BACK BUTTON (tylko od strony 2)
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              setState(() => _currentPage--);
                            },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF860E66),
                        side: const BorderSide(color: Color(0xFF860E66)),
                      ),
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentPage > 0) const SizedBox(width: 12),

                // SKIP / NEXT / DONE
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            if (_currentPage < _totalPages - 1) {
                              // Next page
                              setState(() => _currentPage++);
                            } else {
                              // Complete onboarding
                              await _completeOnboarding();
                            }
                          },
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            _currentPage == _totalPages - 1 ? 'Done' : 'Next',
                          ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // SKIP BUTTON (wszystkie strony oprócz ostatniej)
            if (_currentPage < _totalPages - 1)
              TextButton(
                onPressed: _isLoading ? null : _skipOnboarding,
                child: const Text(
                  'Skip for now',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
