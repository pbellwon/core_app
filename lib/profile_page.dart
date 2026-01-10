// lib/profile_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'widgets/main_app_bar.dart';
import 'models/user_model.dart';

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

  @override
  void initState() {
    super.initState();
    
    // 🔄 Inicjalizacja kontrolerów z aktualnymi danymi użytkownika
    _initializeControllers();
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
    
    _phoneNumberController = TextEditingController(
      text: user?.phoneNumber ?? ''
    );
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
    
    try {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      
      // 📅 Parsowanie daty urodzenia
      DateTime? dateOfBirth;
      if (_dateOfBirthController.text.isNotEmpty) {
        dateOfBirth = _parseDate(_dateOfBirthController.text);
      }
      
      // ✏️ Aktualizacja profilu (używamy updateUserProfile, nie updateProfile)
      await authProvider.updateUserProfile(
        displayName: _displayNameController.text.isNotEmpty
            ? _displayNameController.text.trim()
            : null,
        dateOfBirth: dateOfBirth,
        phoneNumber: _phoneNumberController.text.isNotEmpty
            ? _phoneNumberController.text.trim()
            : null,
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
        title: 'My Profile',
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
              children: [
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
                      
                      // 📱 NUMER TELEFONU
                      TextFormField(
                        controller: _phoneNumberController,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          hintText: 'Enter your phone number',
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
                            // Prosta walidacja numeru telefonu
                            final phoneRegex = RegExp(r'^[+]?[0-9\s\-]{9,15}$');
                            if (!phoneRegex.hasMatch(value)) {
                              return 'Please enter a valid phone number';
                            }
                          }
                          return null;
                        },
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
                
                // 🚪 PRZYCISK WYLOGOWANIA
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      authProvider.signOut();
                    },
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}