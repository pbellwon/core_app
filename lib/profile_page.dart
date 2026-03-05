// lib/profile_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'widgets/main_app_bar.dart';
import 'models/user_model.dart';
import 'client_profile_quiz.dart';

/// 🌍 Model dla kodu kierunkowego kraju
class CountryCode {
  final String name;
  final String code;

  CountryCode({
    required this.name,
    required this.code,
  });
}

/// 🌍 Lista kodów kierunkowych dla wszystkich krajów świata
final List<CountryCode> allCountryCodes = [
    CountryCode(name: 'Afghanistan', code: '+93'),
  CountryCode(name: 'Albania', code: '+355'),
  CountryCode(name: 'Algeria', code: '+213'),
  CountryCode(name: 'Andorra', code: '+376'),
  CountryCode(name: 'Angola', code: '+244'),
  CountryCode(name: 'Antigua and Barbuda', code: '+1268'),
  CountryCode(name: 'Argentina', code: '+54'),
  CountryCode(name: 'Armenia', code: '+374'),
  CountryCode(name: 'Australia', code: '+61'),
  CountryCode(name: 'Austria', code: '+43'),
  CountryCode(name: 'Azerbaijan', code: '+994'),
  CountryCode(name: 'Bahamas', code: '+1242'),
  CountryCode(name: 'Bahrain', code: '+973'),
  CountryCode(name: 'Bangladesh', code: '+880'),
  CountryCode(name: 'Barbados', code: '+1246'),
  CountryCode(name: 'Belarus', code: '+375'),
  CountryCode(name: 'Belgium', code: '+32'),
  CountryCode(name: 'Belize', code: '+501'),
  CountryCode(name: 'Benin', code: '+229'),
  CountryCode(name: 'Bhutan', code: '+975'),
  CountryCode(name: 'Bolivia', code: '+591'),
  CountryCode(name: 'Bosnia and Herzegovina', code: '+387'),
  CountryCode(name: 'Botswana', code: '+267'),
  CountryCode(name: 'Brazil', code: '+55'),
  CountryCode(name: 'Brunei', code: '+673'),
  CountryCode(name: 'Bulgaria', code: '+359'),
  CountryCode(name: 'Burkina Faso', code: '+226'),
  CountryCode(name: 'Burundi', code: '+257'),
  CountryCode(name: 'Cabo Verde', code: '+238'),
  CountryCode(name: 'Cambodia', code: '+855'),
  CountryCode(name: 'Cameroon', code: '+237'),
  CountryCode(name: 'Canada', code: '+1'),
  CountryCode(name: 'Central African Republic', code: '+236'),
  CountryCode(name: 'Chad', code: '+235'),
  CountryCode(name: 'Chile', code: '+56'),
  CountryCode(name: 'China', code: '+86'),
  CountryCode(name: 'Colombia', code: '+57'),
  CountryCode(name: 'Comoros', code: '+269'),
  CountryCode(name: 'Congo', code: '+242'),
  CountryCode(name: 'Costa Rica', code: '+506'),
  CountryCode(name: 'Croatia', code: '+385'),
  CountryCode(name: 'Cuba', code: '+53'),
  CountryCode(name: 'Cyprus', code: '+357'),
  CountryCode(name: 'Czech Republic', code: '+420'),
  CountryCode(name: 'Denmark', code: '+45'),
  CountryCode(name: 'Djibouti', code: '+253'),
  CountryCode(name: 'Dominica', code: '+1767'),
  CountryCode(name: 'Dominican Republic', code: '+1809'),
  CountryCode(name: 'DR Congo', code: '+243'),
  CountryCode(name: 'Ecuador', code: '+593'),
  CountryCode(name: 'Egypt', code: '+20'),
  CountryCode(name: 'El Salvador', code: '+503'),
  CountryCode(name: 'Equatorial Guinea', code: '+240'),
  CountryCode(name: 'Eritrea', code: '+291'),
  CountryCode(name: 'Estonia', code: '+372'),
  CountryCode(name: 'Eswatini', code: '+268'),
  CountryCode(name: 'Ethiopia', code: '+251'),
  CountryCode(name: 'Fiji', code: '+679'),
  CountryCode(name: 'Finland', code: '+358'),
  CountryCode(name: 'France', code: '+33'),
  CountryCode(name: 'Gabon', code: '+241'),
  CountryCode(name: 'Gambia', code: '+220'),
  CountryCode(name: 'Georgia', code: '+995'),
  CountryCode(name: 'Germany', code: '+49'),
  CountryCode(name: 'Ghana', code: '+233'),
  CountryCode(name: 'Greece', code: '+30'),
  CountryCode(name: 'Grenada', code: '+1473'),
  CountryCode(name: 'Guatemala', code: '+502'),
  CountryCode(name: 'Guinea', code: '+224'),
  CountryCode(name: 'Guinea-Bissau', code: '+245'),
  CountryCode(name: 'Guyana', code: '+592'),
  CountryCode(name: 'Haiti', code: '+509'),
  CountryCode(name: 'Honduras', code: '+504'),
  CountryCode(name: 'Hong Kong', code: '+852'),
  CountryCode(name: 'Hungary', code: '+36'),
  CountryCode(name: 'Iceland', code: '+354'),
  CountryCode(name: 'India', code: '+91'),
  CountryCode(name: 'Indonesia', code: '+62'),
  CountryCode(name: 'Iran', code: '+98'),
  CountryCode(name: 'Iraq', code: '+964'),
  CountryCode(name: 'Ireland', code: '+353'),
  CountryCode(name: 'Israel', code: '+972'),
  CountryCode(name: 'Italy', code: '+39'),
  CountryCode(name: 'Ivory Coast', code: '+225'),
  CountryCode(name: 'Jamaica', code: '+1876'),
  CountryCode(name: 'Japan', code: '+81'),
  CountryCode(name: 'Jordan', code: '+962'),
  CountryCode(name: 'Kazakhstan', code: '+7'),
  CountryCode(name: 'Kenya', code: '+254'),
  CountryCode(name: 'Kiribati', code: '+686'),
  CountryCode(name: 'Kosovo', code: '+383'),
  CountryCode(name: 'Kuwait', code: '+965'),
  CountryCode(name: 'Kyrgyzstan', code: '+996'),
  CountryCode(name: 'Laos', code: '+856'),
  CountryCode(name: 'Latvia', code: '+371'),
  CountryCode(name: 'Lebanon', code: '+961'),
  CountryCode(name: 'Lesotho', code: '+266'),
  CountryCode(name: 'Liberia', code: '+231'),
  CountryCode(name: 'Libya', code: '+218'),
  CountryCode(name: 'Liechtenstein', code: '+423'),
  CountryCode(name: 'Lithuania', code: '+370'),
  CountryCode(name: 'Luxembourg', code: '+352'),
  CountryCode(name: 'Macau', code: '+853'),
  CountryCode(name: 'Madagascar', code: '+261'),
  CountryCode(name: 'Malawi', code: '+265'),
  CountryCode(name: 'Malaysia', code: '+60'),
  CountryCode(name: 'Maldives', code: '+960'),
  CountryCode(name: 'Mali', code: '+223'),
  CountryCode(name: 'Malta', code: '+356'),
  CountryCode(name: 'Marshall Islands', code: '+692'),
  CountryCode(name: 'Mauritania', code: '+222'),
  CountryCode(name: 'Mauritius', code: '+230'),
  CountryCode(name: 'Mexico', code: '+52'),
  CountryCode(name: 'Micronesia', code: '+691'),
  CountryCode(name: 'Moldova', code: '+373'),
  CountryCode(name: 'Monaco', code: '+377'),
  CountryCode(name: 'Mongolia', code: '+976'),
  CountryCode(name: 'Montenegro', code: '+382'),
  CountryCode(name: 'Morocco', code: '+212'),
  CountryCode(name: 'Mozambique', code: '+258'),
  CountryCode(name: 'Myanmar', code: '+95'),
  CountryCode(name: 'Namibia', code: '+264'),
  CountryCode(name: 'Nauru', code: '+674'),
  CountryCode(name: 'Nepal', code: '+977'),
  CountryCode(name: 'Netherlands', code: '+31'),
  CountryCode(name: 'New Zealand', code: '+64'),
  CountryCode(name: 'Nicaragua', code: '+505'),
  CountryCode(name: 'Niger', code: '+227'),
  CountryCode(name: 'Nigeria', code: '+234'),
  CountryCode(name: 'North Korea', code: '+850'),
  CountryCode(name: 'North Macedonia', code: '+389'),
  CountryCode(name: 'Norway', code: '+47'),
  CountryCode(name: 'Oman', code: '+968'),
  CountryCode(name: 'Pakistan', code: '+92'),
  CountryCode(name: 'Palau', code: '+680'),
  CountryCode(name: 'Palestine', code: '+970'),
  CountryCode(name: 'Panama', code: '+507'),
  CountryCode(name: 'Papua New Guinea', code: '+675'),
  CountryCode(name: 'Paraguay', code: '+595'),
  CountryCode(name: 'Peru', code: '+51'),
  CountryCode(name: 'Philippines', code: '+63'),
  CountryCode(name: 'Poland', code: '+48'),
  CountryCode(name: 'Portugal', code: '+351'),
  CountryCode(name: 'Qatar', code: '+974'),
  CountryCode(name: 'Romania', code: '+40'),
  CountryCode(name: 'Russia', code: '+7'),
  CountryCode(name: 'Rwanda', code: '+250'),
  CountryCode(name: 'Saint Kitts and Nevis', code: '+1869'),
  CountryCode(name: 'Saint Lucia', code: '+1758'),
  CountryCode(name: 'Saint Vincent and the Grenadines', code: '+1784'),
  CountryCode(name: 'Samoa', code: '+685'),
  CountryCode(name: 'San Marino', code: '+378'),
  CountryCode(name: 'Sao Tome and Principe', code: '+239'),
  CountryCode(name: 'Saudi Arabia', code: '+966'),
  CountryCode(name: 'Senegal', code: '+221'),
  CountryCode(name: 'Serbia', code: '+381'),
  CountryCode(name: 'Seychelles', code: '+248'),
  CountryCode(name: 'Sierra Leone', code: '+232'),
  CountryCode(name: 'Singapore', code: '+65'),
  CountryCode(name: 'Slovakia', code: '+421'),
  CountryCode(name: 'Slovenia', code: '+386'),
  CountryCode(name: 'Solomon Islands', code: '+677'),
  CountryCode(name: 'Somalia', code: '+252'),
  CountryCode(name: 'South Africa', code: '+27'),
  CountryCode(name: 'South Korea', code: '+82'),
  CountryCode(name: 'South Sudan', code: '+211'),
  CountryCode(name: 'Spain', code: '+34'),
  CountryCode(name: 'Sri Lanka', code: '+94'),
  CountryCode(name: 'Sudan', code: '+249'),
  CountryCode(name: 'Suriname', code: '+597'),
  CountryCode(name: 'Sweden', code: '+46'),
  CountryCode(name: 'Switzerland', code: '+41'),
  CountryCode(name: 'Syria', code: '+963'),
  CountryCode(name: 'Taiwan', code: '+886'),
  CountryCode(name: 'Tajikistan', code: '+992'),
  CountryCode(name: 'Tanzania', code: '+255'),
  CountryCode(name: 'Thailand', code: '+66'),
  CountryCode(name: 'Timor-Leste', code: '+670'),
  CountryCode(name: 'Togo', code: '+228'),
  CountryCode(name: 'Tonga', code: '+676'),
  CountryCode(name: 'Trinidad and Tobago', code: '+1868'),
  CountryCode(name: 'Tunisia', code: '+216'),
  CountryCode(name: 'Turkey', code: '+90'),
  CountryCode(name: 'Turkmenistan', code: '+993'),
  CountryCode(name: 'Tuvalu', code: '+688'),
  CountryCode(name: 'Uganda', code: '+256'),
  CountryCode(name: 'Ukraine', code: '+380'),
  CountryCode(name: 'United Arab Emirates', code: '+971'),
  CountryCode(name: 'United Kingdom', code: '+44'),
  CountryCode(name: 'United States', code: '+1'),
  CountryCode(name: 'Uruguay', code: '+598'),
  CountryCode(name: 'Uzbekistan', code: '+998'),
  CountryCode(name: 'Vanuatu', code: '+678'),
  CountryCode(name: 'Vatican City', code: '+379'),
  CountryCode(name: 'Venezuela', code: '+58'),
  CountryCode(name: 'Vietnam', code: '+84'),
  CountryCode(name: 'Yemen', code: '+967'),
  CountryCode(name: 'Zambia', code: '+260'),
  CountryCode(name: 'Zimbabwe', code: '+263'),
];

/// 👤 STRONA PROFILU UŻYTKOWNIKA
/// Pozwala przeglądać i edytować dane profilowe
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // 🗝️ Klucz do formularza
  final _formKey = GlobalKey<FormState>();
  
  // 📝 Kontrolery pól tekstowych
  late TextEditingController _displayNameController;
  late TextEditingController _dateOfBirthController;
  late TextEditingController _phoneNumberController;
  
  // 🌍 Zmienne dla wyszukiwarki kraju
  CountryCode? _selectedCountryCode;
  final TextEditingController _countrySearchController = TextEditingController();
  List<CountryCode> _filteredCountries = allCountryCodes;
  bool _showCountrySuggestions = false;
  final FocusNode _countryFocusNode = FocusNode();
  
  // 📱 Kontroler dla samego numeru telefonu (bez kodu)
  late TextEditingController _phoneNumberOnlyController;

  @override
  void initState() {
    super.initState();
    
    // 🔄 Inicjalizacja kontrolerów z aktualnymi danymi użytkownika
    _initializeControllers();
    
    // Dodajemy listener do wyszukiwarki
    _countrySearchController.addListener(_filterCountries);
    
    // Listener do focus node
    _countryFocusNode.addListener(() {
      if (_countryFocusNode.hasFocus) {
        setState(() {
          _showCountrySuggestions = true;
        });
      }
    });
  }

  /// 🎬 INICJALIZACJA KONTROLERÓW
  void _initializeControllers() {
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    
    _displayNameController = TextEditingController(
      text: user?.displayName ?? ''
    );
    
    _dateOfBirthController = TextEditingController(
      text: user?.dateOfBirth != null
          ? _formatDate(user!.dateOfBirth!)
          : ''
    );
    
    // 📱 Rozdzielenie numeru telefonu na kod i numer właściwy
    _phoneNumberController = TextEditingController(
      text: user?.phoneNumber ?? ''
    );
    
    _phoneNumberOnlyController = TextEditingController();
    
    if (user?.phoneNumber != null && user!.phoneNumber!.isNotEmpty) {
      _parsePhoneNumber(user.phoneNumber!);
    } else {
      // Domyślnie wybierz Polskę (+48)
      _selectedCountryCode = allCountryCodes.firstWhere(
        (code) => code.code == '+48',
        orElse: () => allCountryCodes.first,
      );
    }
  }

  /// 🔍 Filtrowanie krajów na podstawie wpisanej nazwy
  void _filterCountries() {
    final query = _countrySearchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCountries = allCountryCodes;
      } else {
        _filteredCountries = allCountryCodes.where((country) {
          return country.name.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  /// ✅ Wybór kraju z listy
  void _selectCountry(CountryCode country) {
    setState(() {
      _selectedCountryCode = country;
      _countrySearchController.text = country.name;
      _showCountrySuggestions = false;
    });
    
    // Przenieś focus na pole numeru telefonu
    FocusScope.of(context).nextFocus();
  }

  /// 📱 Parsowanie numeru telefonu na kod i numer właściwy
  void _parsePhoneNumber(String fullPhoneNumber) {
    // Szukamy dopasowania kodu kierunkowego
    for (var country in allCountryCodes) {
      if (fullPhoneNumber.startsWith(country.code.substring(1))) { // bez '+'
        _selectedCountryCode = country;
        _countrySearchController.text = country.name;
        _phoneNumberOnlyController.text = fullPhoneNumber.substring(
          country.code.length - 1
        );
        return;
      }
    }
    
    // Jeśli nie znaleziono kodu, użyj domyślnego
    _selectedCountryCode = allCountryCodes.firstWhere(
      (code) => code.code == '+48',
      orElse: () => allCountryCodes.first,
    );
    _countrySearchController.text = '';
    _phoneNumberOnlyController.text = fullPhoneNumber;
  }

  /// 📅 FORMATOWANIE DATY (yyyy-MM-dd)
  String _formatDate(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// 📅 PARSOWANIE DATY (z yyyy-MM-dd)
  DateTime? _parseDate(String dateString) {
    if (dateString.isEmpty) return null;
    try {
      final parts = dateString.split('-');
      if (parts.length != 3) return null;
      final year = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final day = int.tryParse(parts[2]);
      if (year == null || month == null || day == null) return null;
      return DateTime(year, month, day);
    } catch (e) {
      return null;
    }
  }

  /// 📅 FORMATOWANIE DATY DO WYŚWIETLANIA (dd MMM yyyy)
  String _formatDisplayDate(DateTime date) {
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final day = date.day.toString().padLeft(2, '0');
    final month = monthNames[date.month - 1];
    final year = date.year.toString();
    return '$day $month $year';
  }

  /// 📅 FORMATOWANIE DATY Z GODZINĄ (dd MMM yyyy, HH:mm)
  String _formatDateTime(DateTime date) {
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final day = date.day.toString().padLeft(2, '0');
    final month = monthNames[date.month - 1];
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day $month $year, $hour:$minute';
  }

  @override
  void dispose() {
    // 🧹 Sprzątanie kontrolerów
    _displayNameController.dispose();
    _dateOfBirthController.dispose();
    _phoneNumberController.dispose();
    _phoneNumberOnlyController.dispose();
    _countrySearchController.dispose();
    _countryFocusNode.dispose();
    super.dispose();
  }

  /// 📅 WYBÓR DATY URODZENIA
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    
    if (pickedDate != null && mounted) {
      setState(() {
        _dateOfBirthController.text = _formatDate(pickedDate);
      });
    }
  }

  /// 💾 ZAPISZ ZMIANY W PROFILU
  Future<void> _saveProfile() async {
    // ✅ Walidacja formularza
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Sprawdź czy kraj został wybrany
    if (_selectedCountryCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Please select a country code'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    try {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      
      // 📅 Parsowanie daty urodzenia
      DateTime? dateOfBirth;
      if (_dateOfBirthController.text.isNotEmpty) {
        dateOfBirth = _parseDate(_dateOfBirthController.text);
      }
      
      // 📱 Połączenie kodu kierunkowego z numerem telefonu
      String? fullPhoneNumber;
      if (_phoneNumberOnlyController.text.isNotEmpty && _selectedCountryCode != null) {
        fullPhoneNumber = '${_selectedCountryCode!.code.substring(1)}${_phoneNumberOnlyController.text}';
      }
      
      // ✏️ Aktualizacja profilu
      await authProvider.updateUserProfile(
        displayName: _displayNameController.text.isNotEmpty
            ? _displayNameController.text.trim()
            : null,
        dateOfBirth: dateOfBirth,
        phoneNumber: fullPhoneNumber,
      );
      
      // 🎉 Powiadomienie o sukcesie
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Profile updated successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // ❌ Powiadomienie o błędzie
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// 🎯 NAWIGACJA DO QUIZU PROFILU KLIENTA
  void _navigateToClientQuiz() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ClientProfileQuizPage(),
      ),
    );
  }

  /// 👤 WIDGET AWATARA UŻYTKOWNIKA
  Widget _buildUserAvatar(AppUser user) {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: const Color(0xFF860E66),
          child: user.photoURL != null
              ? ClipOval(
                  child: Image.network(
                    user.photoURL!,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                )
              : Text(
                  user.initials,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
        const SizedBox(height: 16),
        Text(
          user.displayName ?? 'No display name',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF860E66),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: const TextStyle(color: Colors.grey),
        ),
        if (user.age != null) ...[
          const SizedBox(height: 4),
          Text(
            'Age: ${user.age}',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ],
    );
  }

  /// 📋 WIDGET INFORMACJI O KONCIE
  Widget _buildAccountInfo(AppUser user) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Account Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF860E66),
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('User ID', user.uid),
            _buildInfoRow('Email', user.email),
            _buildInfoRow(
              'Member since',
              _formatDisplayDate(user.createdAt),
            ),
            if (user.updatedAt != null)
              _buildInfoRow(
                'Last updated',
                _formatDateTime(user.updatedAt!),
              ),
            _buildInfoRow('Role', user.role.name.toUpperCase()),
          ],
        ),
      ),
    );
  }

  /// 📝 WIERSZ INFORMACJI
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
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
          // ⏳ Ładowanie
          if (authProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF860E66),
              ),
            );
          }
          
          // ❌ Nie zalogowany
          if (!authProvider.isLoggedIn || authProvider.currentUser == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person_off,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Please log in to view your profile',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF860E66),
                    ),
                    child: const Text('Go to Login'),
                  ),
                ],
              ),
            );
          }
          
          final user = authProvider.currentUser!;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // 🎯 PRZYCISK "TAKE QUIZ" - NA GÓRZE, NA ŚRODKU
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _navigateToClientQuiz,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFF860E66),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.quiz, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Take Quiz',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // 👤 AWATAR I PODSTAWOWE INFO
                Center(child: _buildUserAvatar(user)),
                
                const SizedBox(height: 32),
                
                // ✏️ FORMULARZ EDYCJI
                const Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF860E66),
                  ),
                ),
                const SizedBox(height: 16),
                
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // 👨‍💼 NAZWA WYŚWIETLANA
                      TextFormField(
                        controller: _displayNameController,
                        decoration: InputDecoration(
                          labelText: 'Display Name',
                          hintText: 'Enter your name',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (value) {
                          if (value != null && value.length > 50) {
                            return 'Name is too long (max 50 characters)';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // 📅 DATA URODZENIA
                      TextFormField(
                        controller: _dateOfBirthController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Date of Birth',
                          hintText: 'Select your birth date',
                          prefixIcon: const Icon(Icons.cake),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () => _selectDate(context),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        onTap: () => _selectDate(context),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // 📱 NUMER TELEFONU (pole wyboru kraju obok numeru)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🌍 Pole wyszukiwarki kraju (po lewej)
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.grey[50],
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _countrySearchController,
                                          focusNode: _countryFocusNode,
                                          decoration: InputDecoration(
                                            hintText: 'Country',
                                            prefixIcon: const Icon(Icons.public),
                                            border: InputBorder.none,
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 16,
                                            ),
                                          ),
                                          onSubmitted: (value) {
                                            if (_filteredCountries.isNotEmpty) {
                                              _selectCountry(_filteredCountries.first);
                                            }
                                          },
                                        ),
                                      ),
                                      if (_selectedCountryCode != null)
                                        Padding(
                                          padding: const EdgeInsets.only(right: 12),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF860E66).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            child: Text(
                                              _selectedCountryCode!.code,
                                              style: const TextStyle(
                                                color: Color(0xFF860E66),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                
                                // Lista podpowiedzi (pod polem kraju)
                                if (_showCountrySuggestions && _filteredCountries.isNotEmpty)
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    constraints: const BoxConstraints(
                                      maxHeight: 200,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: _filteredCountries.length,
                                      itemBuilder: (context, index) {
                                        final country = _filteredCountries[index];
                                        final isSelected = _selectedCountryCode?.name == country.name;
                                        
                                        return ListTile(
                                          title: Text(
                                            country.name,
                                            style: TextStyle(
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                              color: isSelected
                                                  ? const Color(0xFF860E66)
                                                  : null,
                                            ),
                                          ),
                                          subtitle: Text(country.code),
                                          onTap: () => _selectCountry(country),
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(width: 12),
                          
                          // 📱 Pole na numer telefonu (po prawej)
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _phoneNumberOnlyController,
                              decoration: InputDecoration(
                                labelText: 'Phone Number',
                                hintText: 'Enter number',
                                prefixIcon: const Icon(Icons.phone),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  if (value.length < 6) {
                                    return 'Too short';
                                  }
                                  if (!RegExp(r'^[0-9\s\-]+$').hasMatch(value)) {
                                    return 'Only numbers, spaces and hyphens';
                                  }
                                }
                                return null;
                              },
                              onTap: () {
                                // Ukryj podpowiedzi gdy klikamy w pole numeru
                                setState(() {
                                  _showCountrySuggestions = false;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // 💾 PRZYCISK ZAPISU
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveProfile,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: const Color(0xFF860E66),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 📋 INFORMACJE O KONCIE
                _buildAccountInfo(user),
              ],
            ),
          );
        },
      ),
    );
  }
}