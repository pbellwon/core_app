// lib/client_profile_quiz.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/main_app_bar.dart';
import 'providers/auth_provider.dart';
import 'models/user_model.dart';

/// 🎯 STRONA QUIZU PROFILU KLIENTA
/// Zawiera 10 pytań z odpowiedziami A, B, C
class ClientProfileQuizPage extends StatefulWidget {
  const ClientProfileQuizPage({super.key});

  @override
  State<ClientProfileQuizPage> createState() => _ClientProfileQuizPageState();
}

class _ClientProfileQuizPageState extends State<ClientProfileQuizPage> {
  // 🗂️ Lista pytań - teraz inicjalizowana w initState
  late List<QuizQuestion> _questions;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Opóźniona inicjalizacja po zbudowaniu widgetu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeQuestions();
    });
  }

  /// 🎬 INICJALIZACJA PYTAŃ Z ZAPISANYMI ODPOWIEDZIAMI
  void _initializeQuestions() {
    final authProvider = Provider.of<AppAuthProvider>(
      context,
      listen: false,
    );

    final user = authProvider.currentUser;
    
    // Tworzymy 10 pytań
    _questions = List.generate(10, (index) {
      final questionId = index + 1;
      
      // Sprawdzamy czy użytkownik ma już zapisaną odpowiedź na to pytanie
      final savedAnswer = user?.getAnswerForQuestion(questionId);
      
      return QuizQuestion(
        id: questionId,
        text: 'Question $questionId',
        options: ['A', 'B', 'C'],
        selectedAnswer: savedAnswer,
      );
    });
    
    setState(() {
      _isInitialized = true;
    });
  }

  /// 🔢 LICZ ODPOWIEDZI A, B, C
  Map<String, int> _getAnswerCounts() {
    final counts = {'A': 0, 'B': 0, 'C': 0};
    
    for (final question in _questions) {
      if (question.selectedAnswer != null) {
        counts[question.selectedAnswer!] = counts[question.selectedAnswer!]! + 1;
      }
    }
    
    return counts;
  }

  /// 💾 ZAPISZ WYNIKI QUIZU DO FIREBASE
  Future<void> _submitQuiz() async {
    // Sprawdź czy wszystkie pytania mają odpowiedzi
    final unansweredQuestions = _questions.where((q) => q.selectedAnswer == null).toList();
    
    if (unansweredQuestions.isNotEmpty) {
      // Pokaż ostrzeżenie o nieodpowiedzeniu na wszystkie pytania
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please answer all ${unansweredQuestions.length} remaining questions',
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return;
    }
    
    try {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      
      // Zapisujemy wszystkie odpowiedzi na raz
      final quizAnswers = _questions.map((question) => QuizAnswer(
        questionId: question.id,
        answer: question.selectedAnswer!,
        answeredAt: DateTime.now(),
      )).toList();
      
      // Pokazujemy loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF860E66),
          ),
        ),
      );
      
      // Zapisujemy do Firebase
      await authProvider.saveAllQuizAnswers(quizAnswers);
      
      // Zamykamy loading indicator
      if (mounted) {
        Navigator.of(context).pop();
      }
      
      // Liczymy odpowiedzi A, B, C
      final answerCounts = _getAnswerCounts();
      
      // Przekierowujemy na proposals_page z wynikami
      if (mounted) {
        Navigator.pushNamed(
          context,
          '/proposals',
          arguments: {
            'answerCounts': answerCounts,
            'totalQuestions': _questions.length,
          },
        );
      }
    } catch (e) {
      // Zamykamy loading indicator jeśli wystąpił błąd
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error submitting quiz: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// 🔄 ZAZNACZ ODPOWIEDŹ (tylko lokalnie, bez zapisu do Firebase)
  void _selectAnswer(int questionId, String answer) {
    setState(() {
      final questionIndex = _questions.indexWhere((q) => q.id == questionId);
      if (questionIndex != -1) {
        _questions[questionIndex] = _questions[questionIndex].copyWith(
          selectedAnswer: answer,
        );
      }
    });
  }

  /// 🔄 RESETUJ ODPOWIEDŹ NA PYTANIE
  void _resetAnswer(int questionId) {
    setState(() {
      final questionIndex = _questions.indexWhere((q) => q.id == questionId);
      if (questionIndex != -1) {
        _questions[questionIndex] = _questions[questionIndex].copyWith(
          selectedAnswer: null,
        );
      }
    });
  }

  /// 📝 WIDGET POJEDYŃCZEGO PYTAINIA
  Widget _buildQuestionCard(QuizQuestion question) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📌 Numer pytania i treść
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF860E66).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Q${question.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF860E66),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question.text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 🅰️🅱️🅲 Przyciski odpowiedzi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: question.options.map((option) {
                final isSelected = question.selectedAnswer == option;
                
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      onPressed: () => _selectAnswer(question.id, option),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: isSelected
                            ? const Color(0xFF860E66)
                            : Colors.grey[200],
                        foregroundColor: isSelected
                            ? Colors.white
                            : Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFF860E66)
                                : Colors.grey[300]!,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        elevation: isSelected ? 2 : 0,
                      ),
                      child: Text(
                        option,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 8),
            
            // ✅ Wybrana odpowiedź (jeśli istnieje) + przycisk reset
            if (question.selectedAnswer != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF860E66),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Selected: ${question.selectedAnswer}',
                      style: const TextStyle(
                        color: Color(0xFF860E66),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    // Przycisk do resetowania odpowiedzi
                    TextButton(
                      onPressed: () => _resetAnswer(question.id),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.clear,
                            color: Colors.red,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Clear',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 12,
                            ),
                          ),
                        ],
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
          if (authProvider.isLoading || !_isInitialized) {
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
                    Icons.quiz_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Please log in to take the quiz',
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
          final savedAnswersCount = user.quizAnswers?.length ?? 0;
          final currentAnswersCount = _questions.where((q) => q.selectedAnswer != null).length;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // 📋 Nagłówek z informacjami
                Card(
                  elevation: 4,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.quiz,
                          size: 60,
                          color: Color(0xFF860E66),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Client Profile Quiz',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF860E66),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'Please answer all 10 questions to complete your client profile. '
                          'Your answers will be saved only when you click "Submit Quiz".',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        
                        // ℹ️ Informacja o zapisanych odpowiedziach
                        if (savedAnswersCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
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
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'You have $savedAnswersCount saved answer(s) from your previous quiz.',
                                    style: TextStyle(
                                      color: Colors.blue[800],
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        const SizedBox(height: 20),
                        
                        // 📊 Postęp
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF860E66).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Progress:',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '$currentAnswersCount/${_questions.length}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF860E66),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // 📝 Lista pytań
                ..._questions.map(_buildQuestionCard),
                
                const SizedBox(height: 32),
                
                // 📤 Przycisk submit
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitQuiz,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: const Color(0xFF860E66),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Submit Quiz',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // 💾 Informacja o zapisie
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.grey,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Answers will be saved to your profile only when you click "Submit Quiz".',
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

/// 📊 MODEL PYTAŃ QUIZU
class QuizQuestion {
  final int id;
  final String text;
  final List<String> options;
  final String? selectedAnswer;
  
  const QuizQuestion({
    required this.id,
    required this.text,
    required this.options,
    this.selectedAnswer,
  });
  
  QuizQuestion copyWith({
    int? id,
    String? text,
    List<String>? options,
    String? selectedAnswer,
  }) {
    return QuizQuestion(
      id: id ?? this.id,
      text: text ?? this.text,
      options: options ?? this.options,
      selectedAnswer: selectedAnswer ?? this.selectedAnswer,
    );
  }
}