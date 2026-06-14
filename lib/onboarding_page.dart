// lib/onboarding_page.dart - ONBOARDING DIALOG Z 9 STRONAMI
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';

/// 🗺️ Mapa krajów do stref czasowych (UTC)
const Map<String, String> countryTimezoneMap = {
  'Abu Dhabi': 'UTC+04:00',
  'Adelaide': 'UTC+10:30',
  'Alaska': 'UTC-08:00',
  'Almaty': 'UTC+05:00',
  'Amsterdam': 'UTC+01:00',
  'Ankara': 'UTC+02:00',
  'Arizona': 'UTC-07:00',
  'Astana': 'UTC+06:00',
  'Athens': 'UTC+02:00',
  'Auckland': 'UTC+13:00',
  'Azores': 'UTC-01:00',
  'Baghdad': 'UTC+03:00',
  'Baku': 'UTC+04:00',
  'Bali': 'UTC+08:00',
  'Bangkok': 'UTC+07:00',
  'Beijing': 'UTC+08:00',
  'Belgrade': 'UTC+01:00',
  'Berlin': 'UTC+01:00',
  'Bern': 'UTC+01:00',
  'Bogota': 'UTC-05:00',
  'Bratislava': 'UTC+01:00',
  'Brasilia': 'UTC-03:00',
  'Brisbane': 'UTC+10:00',
  'Brussels': 'UTC+01:00',
  'Bucharest': 'UTC+02:00',
  'Budapest': 'UTC+01:00',
  'Buenos Aires': 'UTC-03:00',
  'Cairo': 'UTC+02:00',
  'Canary Islands': 'UTC+00:00',
  'Canberra': 'UTC+11:00',
  'Cape Verde Islands': 'UTC-01:00',
  'Caracas': 'UTC-04:00',
  'Casablanca': 'UTC+00:00',
  'Central America': 'UTC-06:00',
  'Central Time (US and Canada)': 'UTC-05:00',
  'Chennai': 'UTC+05:30',
  'Chihuahua': 'UTC-06:00',
  'Chongqing': 'UTC+08:00',
  'Copenhagen': 'UTC+01:00',
  'Darwin': 'UTC+09:30',
  'Dhaka': 'UTC+06:00',
  'Dublin': 'UTC+00:00',
  'Eastern Time (US and Canada)': 'UTC-04:00',
  'Edinburgh': 'UTC+00:00',
  'Ekaterinburg': 'UTC+05:00',
  'Fiji Islands': 'UTC+12:00',
  'Georgetown': 'UTC-03:00',
  'Greenland': 'UTC-02:00',
  'Guadalajara': 'UTC-06:00',
  'Guam': 'UTC+10:00',
  'Hanoi': 'UTC+07:00',
  'Harare': 'UTC+02:00',
  'Hawaii': 'UTC-10:00',
  'Helsinki': 'UTC+02:00',
  'Hobart': 'UTC+11:00',
  'Hong Kong SAR': 'UTC+08:00',
  'Indiana (East)': 'UTC-04:00',
  'International Date Line West': 'UTC-12:00',
  'Irkutsk': 'UTC+08:00',
  'Islamabad': 'UTC+05:00',
  'Istanbul': 'UTC+02:00',
  'Jakarta': 'UTC+07:00',
  'Jerusalem': 'UTC+02:00',
  'Kabul': 'UTC+04:30',
  'Kamchatka': 'UTC+12:00',
  'Karachi': 'UTC+05:00',
  'Kathmandu': 'UTC+05:45',
  'Kiev': 'UTC+02:00',
  'Kolkata': 'UTC+05:30',
  'Krasnoyarsk': 'UTC+07:00',
  'Kuala Lumpur': 'UTC+08:00',
  'Kuwait': 'UTC+03:00',
  'La Paz': 'UTC-04:00',
  'Lima': 'UTC-05:00',
  'Lisbon': 'UTC+00:00',
  'Ljubljana': 'UTC+01:00',
  'London': 'UTC+00:00',
  'Magadan': 'UTC+11:00',
  'Madrid': 'UTC+01:00',
  'Marshall Islands': 'UTC+12:00',
  'Mazatlán': 'UTC-06:00',
  'Melbourne': 'UTC+11:00',
  'Mexico City': 'UTC-06:00',
  'Mid-Atlantic': 'UTC-02:00',
  'Midway Island': 'UTC-11:00',
  'Minsk': 'UTC+02:00',
  'Monrovia': 'UTC+00:00',
  'Monterrey': 'UTC-06:00',
  'Moscow': 'UTC+03:00',
  'Mountain Time (US and Canada)': 'UTC-06:00',
  'Mumbai': 'UTC+05:30',
  'Muscat': 'UTC+04:00',
  'Nairobi': 'UTC+03:00',
  'New Caledonia': 'UTC+11:00',
  'New Delhi': 'UTC+05:30',
  'Newfoundland and Labrador': 'UTC-03:30',
  'Novosibirsk': 'UTC+05:00',
  "Nuku'alofa": 'UTC+13:00',
  'Osaka': 'UTC+09:00',
  'Pacific Time (US and Canada)': 'UTC-07:00',
  'Paris': 'UTC+01:00',
  'Perth': 'UTC+08:00',
  'Port Moresby': 'UTC+10:00',
  'Prague': 'UTC+01:00',
  'Pretoria': 'UTC+02:00',
  'Quito': 'UTC-05:00',
  'Riga': 'UTC+02:00',
  'Riyadh': 'UTC+03:00',
  'Rome': 'UTC+01:00',
  'Samoa': 'UTC-11:00',
  'Santiago': 'UTC-03:00',
  'Sapporo': 'UTC+09:00',
  'Sarajevo': 'UTC+01:00',
  'Saskatchewan': 'UTC-06:00',
  'Seoul': 'UTC+09:00',
  'Singapore': 'UTC+08:00',
  'Skopje': 'UTC+01:00',
  'Sofia': 'UTC+02:00',
  'Solomon Islands': 'UTC+11:00',
  'Sri Jayawardenepura': 'UTC+05:30',
  'St. Petersburg': 'UTC+03:00',
  'Stockholm': 'UTC+01:00',
  'Sydney': 'UTC+11:00',
  'Taipei': 'UTC+08:00',
  'Tallinn': 'UTC+02:00',
  'Tashkent': 'UTC+05:00',
  'Tbilisi': 'UTC+04:00',
  'Tehran': 'UTC+03:30',
  'Tokyo': 'UTC+09:00',
  'Ulaanbaatar': 'UTC+08:00',
  'Urumqi': 'UTC+08:00',
  'Vancouver': 'UTC-07:00',
  'Vienna': 'UTC+01:00',
  'Vladivostok': 'UTC+10:00',
  'Volgograd': 'UTC+04:00',
  'Warsaw': 'UTC+01:00',
  'Wellington': 'UTC+13:00',
  'West Central Africa': 'UTC+01:00',
  'Yakutsk': 'UTC+09:00',
  'Yangon': 'UTC+06:30',
  'Yekaterinburg': 'UTC+05:00',
  'Yukon': 'UTC-07:00',
  'Zagreb': 'UTC+01:00',
  'Zurich': 'UTC+01:00',
};

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  OnboardingPageState createState() => OnboardingPageState();
}

class OnboardingPageState extends State<OnboardingPage> {
  int _currentPage = 0;
  final int _totalPages = 9;

  // 👤 DISPLAY NAME (strona 1)
  final TextEditingController _displayNameController = TextEditingController();

  // 📅 BIRTH DATE (strona 2)
  DateTime? _selectedBirthDate;
  final TextEditingController _birthDateController = TextEditingController();

  // 🕐 TIMEZONE (strona 3)
  String? _selectedCountry;
  final TextEditingController _countryTimezoneSearchController = TextEditingController();
  List<String> _filteredTimezoneCountries = countryTimezoneMap.keys.toList();
  bool _showTimezoneSuggestions = false;
  final FocusNode _countryTimezoneFocusNode = FocusNode();

  // 📋 MOVEMENT CONSIDERATIONS (strona 5)
  final Set<String> _selectedMovementConsiderations = <String>{};

  static const List<String> _movementConsiderationLabels = <String>[
    'Knee injury/pain',
    'Wrist injury/pain',
    'Shoulder injury/pain',
    'Lower-back injury/pain',
    'Upper back/neck injury/pain',
    'POTS / Blood pressure related dizziness',
  ];

  // 🎯 EXERCISE TYPE (strona 6)
  final Set<String> _selectedExerciseTypes = <String>{};
  static const List<String> _exerciseTypeLabels = <String>[
    'Cardio',
    'Strength',
    'Flexibility',
    'Balance',
    'Functional',
    'Sports',
  ];

  // 🎯 FITNESS GOALS (strona 7)
  final Set<String> _selectedGoals = <String>{};
  static const List<String> _goalsLabels = <String>[
    'Weight Loss',
    'Build Muscle',
    'Increase Endurance',
    'Improve Flexibility',
    'Injury Recovery',
    'General Health',
  ];

  // 🕐 EXPERIENCE LEVEL (strona 8) - single choice
  String? _selectedExperienceLevel;
  static const List<String> _experienceLevelLabels = <String>[
    'Beginner',
    'Intermediate',
    'Advanced',
  ];

  // ⏱️ AVAILABLE TIME - removed, was strona 6
  // 📍 PREFERRED LOCATION - removed from here

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // Listener dla filtrownia kraju timezone'u
    _countryTimezoneSearchController.addListener(_filterTimezoneCountries);
    _countryTimezoneFocusNode.addListener(() {
      if (_countryTimezoneFocusNode.hasFocus) {
        setState(() {
          _showTimezoneSuggestions = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _birthDateController.dispose();
    _countryTimezoneSearchController.dispose();
    _countryTimezoneFocusNode.dispose();
    super.dispose();
  }

  /// 🔍 Filtrowanie krajów dla strefy czasowej
  void _filterTimezoneCountries() {
    final query = _countryTimezoneSearchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredTimezoneCountries = countryTimezoneMap.keys.toList();
      } else {
        _filteredTimezoneCountries = countryTimezoneMap.keys
            .where((name) => name.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  /// ✅ Wybór kraju dla strefy czasowej
  void _selectTimezoneCountry(String countryName) {
    setState(() {
      _selectedCountry = countryName;
      _countryTimezoneSearchController.text = countryName;
      _showTimezoneSuggestions = false;
    });
  }

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

  /// 📄 STRONA 2: DISPLAY NAME
  Widget _buildPageNewOne() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What\'s your display name?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF860E66),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This is how others will see you',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _displayNameController,
            decoration: InputDecoration(
              hintText: 'Enter your display name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 📄 STRONA 3: BIRTH DATE
  Widget _buildPageNewTwo() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What\'s your birth date?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF860E66),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'We use this to personalize your experience',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _birthDateController,
            readOnly: true,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedBirthDate ?? DateTime(2000),
                firstDate: DateTime(1920),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() {
                  _selectedBirthDate = picked;
                  _birthDateController.text =
                      '${picked.day}/${picked.month}/${picked.year}';
                });
              }
            },
            decoration: InputDecoration(
              hintText: 'Select your birth date',
              suffixIcon: const Icon(Icons.calendar_today),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 📄 STRONA 4: TIMEZONE
  Widget _buildPageNewThree() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What\'s your timezone?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF860E66),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'So we can time reminders properly',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _countryTimezoneSearchController,
            focusNode: _countryTimezoneFocusNode,
            decoration: InputDecoration(
              hintText: 'Search timezone',
              prefixIcon: const Icon(Icons.timer),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onTap: () {
              setState(() {
                _showTimezoneSuggestions = true;
              });
            },
            onSubmitted: (value) {
              if (_filteredTimezoneCountries.isNotEmpty) {
                _selectTimezoneCountry(_filteredTimezoneCountries.first);
              }
            },
          ),
          if (_showTimezoneSuggestions && _filteredTimezoneCountries.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              constraints: const BoxConstraints(maxHeight: 250),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _filteredTimezoneCountries.length,
                itemBuilder: (context, index) {
                  final countryName = _filteredTimezoneCountries[index];
                  final isSelected = _selectedCountry == countryName;
                  return ListTile(
                    title: Text(
                      countryName,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? const Color(0xFF860E66) : null,
                      ),
                    ),
                    subtitle: Text(
                      countryTimezoneMap[countryName] ?? '',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    onTap: () => _selectTimezoneCountry(countryName),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  /// 📄 STRONA 1: WELCOME
  Widget _buildPage1() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.celebration, size: 60, color: Color(0xFF860E66)),
            const SizedBox(height: 32),
            const Text(
              """Hey! I’m really glad you’ve landed here. \n
              
  This space is designed to support you in the moment — whether
  you’re feeling anxious, overwhelmed, flat, or just not yourself.
              
  Before we begin, I’d love to get to know you a little better so the
  support you receive feels right for you.
              
  It only takes a few minutes and you can skip any questions you like. \n
  Ready to begin?""",
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 📄 STRONA 5: MOVEMENT CONSIDERATIONS
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

  /// 📄 STRONA 6: EXERCISE TYPES
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

  /// 📄 STRONA 7: FITNESS GOALS
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

  /// 📄 STRONA 8: EXPERIENCE LEVEL
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

  /// 📄 STRONA 9: SUMMARY / COMPLETION
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
                    'Display Name',
                    _displayNameController.text.isNotEmpty
                        ? _displayNameController.text
                        : 'Not provided',
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    'Birth Date',
                    _selectedBirthDate != null
                        ? '${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}'
                        : 'Not selected',
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    'Timezone',
                    _selectedCountry ?? 'Not selected',
                  ),
                  const SizedBox(height: 8),
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
        return _buildPage1(); // STRONA 1: Welcome
      case 1:
        return _buildPageNewOne(); // STRONA 2: Display Name
      case 2:
        return _buildPageNewTwo(); // STRONA 3: Birth Date
      case 3:
        return _buildPageNewThree(); // STRONA 4: Timezone
      case 4:
        return _buildPage2(); // STRONA 5: Movement Considerations
      case 5:
        return _buildPage3(); // STRONA 6: Exercise Types
      case 6:
        return _buildPage4(); // STRONA 7: Fitness Goals
      case 7:
        return _buildPage5(); // STRONA 8: Experience Level
      case 8:
        return _buildPage8(); // STRONA 9: Summary / Completion
      default:
        return _buildPage1();
    }
  }

  /// 💾 SAVE ONBOARDING DATA TO FIREBASE
  Future<void> _completeOnboarding() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AppAuthProvider>();

      // Zapisz wszystkie dane profilowe
      await authProvider.updateUserProfile(
        displayName: _displayNameController.text.isNotEmpty
            ? _displayNameController.text
            : null,
        dateOfBirth: _selectedBirthDate,
        timezone: _selectedCountry != null
            ? countryTimezoneMap[_selectedCountry]
            : null,
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
