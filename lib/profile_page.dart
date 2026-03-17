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

/// 🗺️ Mapa krajów do stref czasowych (UTC)
/// Zawiera wszystkie kraje z listy allCountryCodes z poprawnymi strefami UTC.
const Map<String, String> countryTimezoneMap = {
  'Afghanistan': 'UTC+4:30',
  'Albania': 'UTC+1',
  'Algeria': 'UTC+1',
  'Andorra': 'UTC+1',
  'Angola': 'UTC+1',
  'Antigua and Barbuda': 'UTC-4',
  'Argentina': 'UTC-3',
  'Armenia': 'UTC+4',
  'Australia': 'UTC+10',
  'Austria': 'UTC+1',
  'Azerbaijan': 'UTC+4',
  'Bahamas': 'UTC-5',
  'Bahrain': 'UTC+3',
  'Bangladesh': 'UTC+6',
  'Barbados': 'UTC-4',
  'Belarus': 'UTC+3',
  'Belgium': 'UTC+1',
  'Belize': 'UTC-6',
  'Benin': 'UTC+1',
  'Bhutan': 'UTC+6',
  'Bolivia': 'UTC-4',
  'Bosnia and Herzegovina': 'UTC+1',
  'Botswana': 'UTC+2',
  'Brazil': 'UTC-3',
  'Brunei': 'UTC+8',
  'Bulgaria': 'UTC+2',
  'Burkina Faso': 'UTC+0',
  'Burundi': 'UTC+2',
  'Cabo Verde': 'UTC-1',
  'Cambodia': 'UTC+7',
  'Cameroon': 'UTC+1',
  'Canada': 'UTC-5',
  'Central African Republic': 'UTC+1',
  'Chad': 'UTC+1',
  'Chile': 'UTC-3',
  'China': 'UTC+8',
  'Colombia': 'UTC-5',
  'Comoros': 'UTC+3',
  'Congo': 'UTC+1',
  'Costa Rica': 'UTC-6',
  'Croatia': 'UTC+1',
  'Cuba': 'UTC-5',
  'Cyprus': 'UTC+2',
  'Czech Republic': 'UTC+1',
  'Denmark': 'UTC+1',
  'Djibouti': 'UTC+3',
  'Dominica': 'UTC-4',
  'Dominican Republic': 'UTC-4',
  'DR Congo': 'UTC+2', // Kinshasa UTC+1, ale część wschodnia UTC+2, wybieramy UTC+2 jako reprezentatywne
  'Ecuador': 'UTC-5',
  'Egypt': 'UTC+2',
  'El Salvador': 'UTC-6',
  'Equatorial Guinea': 'UTC+1',
  'Eritrea': 'UTC+3',
  'Estonia': 'UTC+2',
  'Eswatini': 'UTC+2',
  'Ethiopia': 'UTC+3',
  'Fiji': 'UTC+12',
  'Finland': 'UTC+2',
  'France': 'UTC+1',
  'Gabon': 'UTC+1',
  'Gambia': 'UTC+0',
  'Georgia': 'UTC+4',
  'Germany': 'UTC+1',
  'Ghana': 'UTC+0',
  'Greece': 'UTC+2',
  'Grenada': 'UTC-4',
  'Guatemala': 'UTC-6',
  'Guinea': 'UTC+0',
  'Guinea-Bissau': 'UTC+0',
  'Guyana': 'UTC-4',
  'Haiti': 'UTC-5',
  'Honduras': 'UTC-6',
  'Hong Kong': 'UTC+8',
  'Hungary': 'UTC+1',
  'Iceland': 'UTC+0',
  'India': 'UTC+5:30',
  'Indonesia': 'UTC+7', // Dżakarta UTC+7
  'Iran': 'UTC+3:30',
  'Iraq': 'UTC+3',
  'Ireland': 'UTC+0',
  'Israel': 'UTC+2',
  'Italy': 'UTC+1',
  'Ivory Coast': 'UTC+0',
  'Jamaica': 'UTC-5',
  'Japan': 'UTC+9',
  'Jordan': 'UTC+3',
  'Kazakhstan': 'UTC+5',
  'Kenya': 'UTC+3',
  'Kiribati': 'UTC+12',
  'Kosovo': 'UTC+1',
  'Kuwait': 'UTC+3',
  'Kyrgyzstan': 'UTC+6',
  'Laos': 'UTC+7',
  'Latvia': 'UTC+2',
  'Lebanon': 'UTC+2',
  'Lesotho': 'UTC+2',
  'Liberia': 'UTC+0',
  'Libya': 'UTC+2',
  'Liechtenstein': 'UTC+1',
  'Lithuania': 'UTC+2',
  'Luxembourg': 'UTC+1',
  'Macau': 'UTC+8',
  'Madagascar': 'UTC+3',
  'Malawi': 'UTC+2',
  'Malaysia': 'UTC+8',
  'Maldives': 'UTC+5',
  'Mali': 'UTC+0',
  'Malta': 'UTC+1',
  'Marshall Islands': 'UTC+12',
  'Mauritania': 'UTC+0',
  'Mauritius': 'UTC+4',
  'Mexico': 'UTC-6',
  'Micronesia': 'UTC+11',
  'Moldova': 'UTC+2',
  'Monaco': 'UTC+1',
  'Mongolia': 'UTC+8',
  'Montenegro': 'UTC+1',
  'Morocco': 'UTC+1',
  'Mozambique': 'UTC+2',
  'Myanmar': 'UTC+6:30',
  'Namibia': 'UTC+2',
  'Nauru': 'UTC+12',
  'Nepal': 'UTC+5:45',
  'Netherlands': 'UTC+1',
  'New Zealand': 'UTC+12',
  'Nicaragua': 'UTC-6',
  'Niger': 'UTC+1',
  'Nigeria': 'UTC+1',
  'North Korea': 'UTC+9',
  'North Macedonia': 'UTC+1',
  'Norway': 'UTC+1',
  'Oman': 'UTC+4',
  'Pakistan': 'UTC+5',
  'Palau': 'UTC+9',
  'Palestine': 'UTC+2',
  'Panama': 'UTC-5',
  'Papua New Guinea': 'UTC+10',
  'Paraguay': 'UTC-4',
  'Peru': 'UTC-5',
  'Philippines': 'UTC+8',
  'Poland': 'UTC+1',
  'Portugal': 'UTC+0',
  'Qatar': 'UTC+3',
  'Romania': 'UTC+2',
  'Russia': 'UTC+3',
  'Rwanda': 'UTC+2',
  'Saint Kitts and Nevis': 'UTC-4',
  'Saint Lucia': 'UTC-4',
  'Saint Vincent and the Grenadines': 'UTC-4',
  'Samoa': 'UTC+13',
  'San Marino': 'UTC+1',
  'Sao Tome and Principe': 'UTC+0',
  'Saudi Arabia': 'UTC+3',
  'Senegal': 'UTC+0',
  'Serbia': 'UTC+1',
  'Seychelles': 'UTC+4',
  'Sierra Leone': 'UTC+0',
  'Singapore': 'UTC+8',
  'Slovakia': 'UTC+1',
  'Slovenia': 'UTC+1',
  'Solomon Islands': 'UTC+11',
  'Somalia': 'UTC+3',
  'South Africa': 'UTC+2',
  'South Korea': 'UTC+9',
  'South Sudan': 'UTC+2',
  'Spain': 'UTC+1',
  'Sri Lanka': 'UTC+5:30',
  'Sudan': 'UTC+2',
  'Suriname': 'UTC-3',
  'Sweden': 'UTC+1',
  'Switzerland': 'UTC+1',
  'Syria': 'UTC+3',
  'Taiwan': 'UTC+8',
  'Tajikistan': 'UTC+5',
  'Tanzania': 'UTC+3',
  'Thailand': 'UTC+7',
  'Timor-Leste': 'UTC+9',
  'Togo': 'UTC+0',
  'Tonga': 'UTC+13',
  'Trinidad and Tobago': 'UTC-4',
  'Tunisia': 'UTC+1',
  'Turkey': 'UTC+3',
  'Turkmenistan': 'UTC+5',
  'Tuvalu': 'UTC+12',
  'Uganda': 'UTC+3',
  'Ukraine': 'UTC+2',
  'United Arab Emirates': 'UTC+4',
  'United Kingdom': 'UTC+0',
  'United States': 'UTC-5',
  'Uruguay': 'UTC-3',
  'Uzbekistan': 'UTC+5',
  'Vanuatu': 'UTC+11',
  'Vatican City': 'UTC+1',
  'Venezuela': 'UTC-4',
  'Vietnam': 'UTC+7',
  'Yemen': 'UTC+3',
  'Zambia': 'UTC+2',
  'Zimbabwe': 'UTC+2',
};

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
  
  // 🌍 Zmienne dla wyszukiwarki kraju (dla numeru telefonu)
  CountryCode? _selectedCountryCode;
  final TextEditingController _countrySearchController = TextEditingController();
  List<CountryCode> _filteredCountries = allCountryCodes;
  bool _showCountrySuggestions = false;
  final FocusNode _countryFocusNode = FocusNode();
  
  // 📱 Kontroler dla samego numeru telefonu (bez kodu)
  late TextEditingController _phoneNumberOnlyController;

  // 🌍 Nowe pole: wybrany kraj (dla strefy czasowej)
  String? _selectedCountry;
  // Dodajemy kontrolery i zmienne dla nowego pola
  final TextEditingController _countryTimezoneSearchController = TextEditingController();
  List<CountryCode> _filteredTimezoneCountries = allCountryCodes;
  bool _showTimezoneSuggestions = false;
  final FocusNode _countryTimezoneFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    
    // 🔄 Inicjalizacja kontrolerów z aktualnymi danymi użytkownika
    _initializeControllers();
    
    // Dodajemy listener do wyszukiwarki kraju telefonu
    _countrySearchController.addListener(_filterCountries);
    
    // Listener do focus node kraju telefonu
    _countryFocusNode.addListener(() {
      if (_countryFocusNode.hasFocus) {
        setState(() {
          _showCountrySuggestions = true;
        });
      }
    });

    // Listener dla nowego pola kraju (strefa czasowa)
    _countryTimezoneSearchController.addListener(_filterTimezoneCountries);
    _countryTimezoneFocusNode.addListener(() {
      if (_countryTimezoneFocusNode.hasFocus) {
        setState(() {
          _showTimezoneSuggestions = true;
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

    // 🌍 Inicjalizacja wybranego kraju (dla strefy czasowej)
    _selectedCountry = user?.country;
    if (_selectedCountry != null) {
      _countryTimezoneSearchController.text = _selectedCountry!;
    }
  }

  /// 🔍 Filtrowanie krajów na podstawie wpisanej nazwy (dla telefonu)
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

  /// 🔍 Filtrowanie krajów dla strefy czasowej
  void _filterTimezoneCountries() {
    final query = _countryTimezoneSearchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredTimezoneCountries = allCountryCodes;
      } else {
        _filteredTimezoneCountries = allCountryCodes.where((country) {
          return country.name.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  /// ✅ Wybór kraju z listy (dla numeru telefonu)
  void _selectCountry(CountryCode country) {
    setState(() {
      _selectedCountryCode = country;
      _countrySearchController.text = country.name;
      _showCountrySuggestions = false;
    });
    
    // Przenieś focus na pole numeru telefonu
    FocusScope.of(context).nextFocus();
  }

  /// ✅ Wybór kraju dla strefy czasowej
  void _selectTimezoneCountry(CountryCode country) {
    setState(() {
      _selectedCountry = country.name;
      _countryTimezoneSearchController.text = country.name;
      _showTimezoneSuggestions = false;
    });
    // Opcjonalnie: ukryj klawiaturę lub przenieś focus dalej
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
    _countryTimezoneSearchController.dispose();
    _countryTimezoneFocusNode.dispose();
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
    
    // Sprawdź czy kraj został wybrany (dla numeru telefonu)
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

    // Sprawdź czy kraj dla strefy czasowej został wybrany
    if (_selectedCountry == null || _selectedCountry!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Please select your country for timezone'),
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
      
      // 🌍 Pobranie strefy czasowej na podstawie wybranego kraju
      String? timezone;
      if (_selectedCountry != null) {
        timezone = countryTimezoneMap[_selectedCountry] ?? 'UTC+0'; // domyślnie UTC+0
      }

      // ✏️ Aktualizacja profilu (wraz z nowymi polami)
      await authProvider.updateUserProfile(
        displayName: _displayNameController.text.isNotEmpty
            ? _displayNameController.text.trim()
            : null,
        dateOfBirth: dateOfBirth,
        phoneNumber: fullPhoneNumber,
        country: _selectedCountry,   // nowe pole
        timezone: timezone,           // nowe pole
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
            if (user.country != null)
              _buildInfoRow('Country', user.country!),
            if (user.timezone != null)
              _buildInfoRow('Timezone', user.timezone!),
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
                      
                      // 📱 NUMER TELEFONU (pole wyboru kraju obok numeru) - styl jak pole Timezone
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🌍 Pole wyboru kodu kraju
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  controller: _countrySearchController,
                                  focusNode: _countryFocusNode,
                                  decoration: InputDecoration(
                                    labelText: 'Country Code',
                                    hintText: 'Search country',
                                    prefixIcon: const Icon(Icons.public),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                    suffixIcon: _selectedCountryCode != null
                                        ? Padding(
                                            padding: const EdgeInsets.only(right: 8),
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
                                          )
                                        : null,
                                  ),
                                  readOnly: false,
                                  onTap: () {
                                    setState(() {
                                      _showCountrySuggestions = true;
                                    });
                                  },
                                  onFieldSubmitted: (value) {
                                    if (_filteredCountries.isNotEmpty) {
                                      _selectCountry(_filteredCountries.first);
                                    }
                                  },
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
                                setState(() {
                                  _showCountrySuggestions = false;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),

                      // 🌍 NOWE POLE: WYBÓR KRAJU (DLA STREFY CZASOWEJ) - styl jak pole na numer telefonu
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _countryTimezoneSearchController,
                            focusNode: _countryTimezoneFocusNode,
                            decoration: InputDecoration(
                              labelText: 'Timezone',
                              hintText: 'Search country',
                              prefixIcon: const Icon(Icons.timer),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            readOnly: false,
                            onTap: () {
                              setState(() {
                                _showTimezoneSuggestions = true;
                              });
                            },
                            onFieldSubmitted: (value) {
                              if (_filteredTimezoneCountries.isNotEmpty) {
                                _selectTimezoneCountry(_filteredTimezoneCountries.first);
                              }
                            },
                          ),
                          // Lista podpowiedzi
                          if (_showTimezoneSuggestions && _filteredTimezoneCountries.isNotEmpty)
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
                                itemCount: _filteredTimezoneCountries.length,
                                itemBuilder: (context, index) {
                                  final country = _filteredTimezoneCountries[index];
                                  final isSelected = _selectedCountry == country.name;
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
                                    onTap: () => _selectTimezoneCountry(country),
                                  );
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