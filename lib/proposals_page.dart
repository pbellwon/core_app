// lib/proposals_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/main_app_bar.dart';
import 'providers/auth_provider.dart';

/// 🎯 STRONA PROPOZYCJI
/// Pokazuje propozycje na podstawie wyników quizu
class ProposalsPage extends StatefulWidget {
  const ProposalsPage({super.key});

  @override
  State<ProposalsPage> createState() => _ProposalsPageState();
}

class _ProposalsPageState extends State<ProposalsPage> {
  Map<String, int> _answerCounts = {'A': 0, 'B': 0, 'C': 0};
  bool _isDataLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadQuizResults();
  }

  /// 📥 ŁADUJ WYNIKI QUIZU Z ARGUMENTÓW NAWIGACJI
  void _loadQuizResults() {
    if (_isDataLoaded) return;

    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    
    if (args != null) {
      setState(() {
        _answerCounts = args['answerCounts'] as Map<String, int>;
        _isDataLoaded = true;
      });
    } else {
      // Jeśli nie ma argumentów, pokaż pusty stan
      setState(() {
        _isDataLoaded = true;
      });
    }
  }

  /// 🅰️ SPRAWDŹ CZY POKAZAĆ PRZYCISK A
  bool get _showButtonA => _answerCounts['A']! >= 4;

  /// 🅱️ SPRAWDŹ CZY POKAZAĆ PRZYCISK B
  bool get _showButtonB => _answerCounts['B']! >= 4;

  /// 🅲 SPRAWDŹ CZY POKAZAĆ PRZYCISK C
  bool get _showButtonC => _answerCounts['C']! >= 4;

  /// 📊 WIDGET STATYSTYK ODPOWIEDZI
  Widget _buildStatsCard() {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.analytics_outlined,
              size: 50,
              color: Color(0xFF860E66),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your Quiz Results',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF860E66),
              ),
            ),
            const SizedBox(height: 16),
            
            // 📈 Statystyki odpowiedzi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('A', _answerCounts['A']!),
                _buildStatItem('B', _answerCounts['B']!),
                _buildStatItem('C', _answerCounts['C']!),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // ℹ️ Informacja o progu
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Buttons are shown when you have 4 or more answers of that type.',
                      style: TextStyle(
                        color: Color(0xFF1565C0),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📊 POJEDYNCZY ELEMENT STATYSTYKI
  Widget _buildStatItem(String letter, int count) {
    final isActive = count >= 4;
    
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isActive 
                ? const Color(0xFF860E66).withOpacity(0.1)
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isActive ? const Color(0xFF860E66) : Colors.grey[300]!,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              letter,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isActive ? const Color(0xFF860E66) : Colors.grey,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$count answers',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isActive ? const Color(0xFF860E66) : Colors.grey,
          ),
        ),
      ],
    );
  }

  /// 🅰️🅱️🅲 WIDGET PRZYCISKÓW PROPOZYCJI
  Widget _buildProposalsButtons() {
    final buttons = <Widget>[];
    
    if (_showButtonA) {
      buttons.add(_buildProposalButton('A', 'Proposal A Details'));
    }
    
    if (_showButtonB) {
      buttons.add(_buildProposalButton('B', 'Proposal B Details'));
    }
    
    if (_showButtonC) {
      buttons.add(_buildProposalButton('C', 'Proposal C Details'));
    }
    
    // Jeśli nie ma żadnych przycisków
    if (buttons.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.quiz_outlined,
              size: 50,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No proposals available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'You need at least 4 answers of one type to see proposals.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }
    
    return Column(
      children: buttons,
    );
  }

  /// 📝 PRZYCISK POJEDYNCZEJ PROPOZYCJI
  Widget _buildProposalButton(String letter, String description) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF860E66),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      letter,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Proposal $letter',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Tutaj można dodać akcję dla przycisku
                  _showProposalDetails(letter);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: const Color(0xFF860E66),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'View Details',
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
    );
  }

  /// 🔍 POKAŻ SZCZEGÓŁY PROPOZYCJI
  void _showProposalDetails(String letter) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Proposal $letter Details',
          style: const TextStyle(
            color: Color(0xFF860E66),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You selected ${_answerCounts[letter]} answers of type $letter.',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Based on your quiz results, this proposal is tailored to your preferences.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(
        title: 'Proposals',
        showBackButton: true,
      ),
      body: Consumer<AppAuthProvider>(
        builder: (context, authProvider, child) {
          // ⏳ Ładowanie
          if (authProvider.isLoading || !_isDataLoaded) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF860E66),
              ),
            );
          }
          
          // ❌ Nie zalogowany
          if (!authProvider.isLoggedIn) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock_outline,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Please log in to view proposals',
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
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // 📊 Karta ze statystykami
                _buildStatsCard(),
                
                const SizedBox(height: 32),
                
                // 🎯 Nagłówek propozycji
                const Text(
                  'Available Proposals',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF860E66),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Based on your quiz answers, here are your personalized proposals:',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 🅰️🅱️🅲 Przyciski propozycji
                _buildProposalsButtons(),
                
                const SizedBox(height: 32),
                
                // 🔙 Przycisk powrotu do quizu
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/client_quiz');
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFF860E66)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Retake Quiz',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF860E66),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // ℹ️ Informacja
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.grey,
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Proposals are generated based on your quiz answers. Retake the quiz to see different proposals.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
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