import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/local/models/deck.dart';
import '../../data/local/models/card.dart';

class StudyScreen extends StatefulWidget {
  final String deckId;

  const StudyScreen({super.key, required this.deckId});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  List<Card> _studyCards = [];
  int _currentIndex = 0;
  bool _showAnswer = false;
  bool _isFinished = false;
  
  int _knownCount = 0;
  int _unknownCount = 0;

  @override
  void initState() {
    super.initState();
    _prepareStudySession();
  }

  void _prepareStudySession() {
    final box = Hive.box('decks');
    final deck = box.get(widget.deckId) as Deck?;
    
    if (deck == null) {
      setState(() => _isFinished = true);
      return;
    }
    
    // Берем только карточки, которые не выучены (не знают или требуют повторения)
    _studyCards = deck.cards.where((card) => !card.isLearned).toList();
    
    // Перемешиваем карточки
    _studyCards.shuffle();
    
    setState(() {});
  }

  void _flipCard() {
    setState(() => _showAnswer = true);
  }

  void _handleResult(bool known) {
    if (_currentIndex >= _studyCards.length) return;
    
    final card = _studyCards[_currentIndex];
    
    if (known) {
      // Карточка выучена
      card.isLearned = true;
      card.lastReviewedAt = DateTime.now();
      card.repetitionCount++;
      card.save();
      setState(() => _knownCount++);
    } else {
      // Карточка требует повторения - сбрасываем прогресс
      card.isLearned = false;
      card.repetitionCount = 0;
      card.intervalDays = 0;
      card.save();
      setState(() => _unknownCount++);
    }
    
    setState(() {
      _showAnswer = false;
      _currentIndex++;
      
      if (_currentIndex >= _studyCards.length) {
        _isFinished = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isFinished) {
      return _buildFinishedScreen();
    }
    
    if (_studyCards.isEmpty) {
      return _buildEmptyScreen();
    }
    
    final card = _studyCards[_currentIndex];
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Повторение (${_currentIndex + 1}/${_studyCards.length})'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Прогресс бар
            LinearProgressIndicator(
              value: (_currentIndex + 1) / _studyCards.length,
              minHeight: 8,
            ),
            const SizedBox(height: 24),
            
            // Карточка
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (!_showAnswer) _flipCard();
                },
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _showAnswer ? card.answer : card.question,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (_showAnswer) ...[
                            const SizedBox(height: 24),
                            Text(
                              _showAnswer ? card.question : '',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          if (!_showAnswer) ...[
                            const SizedBox(height: 32),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.flip),
                              label: const Text('Показать ответ'),
                              onPressed: _flipCard,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Кнопки ответа
            if (_showAnswer) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: const Icon(Icons.close),
                      label: const Text('Не знаю'),
                      onPressed: () => _handleResult(false),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: const Icon(Icons.check),
                      label: const Text('Знаю'),
                      onPressed: () => _handleResult(true),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFinishedScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Готово!'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.celebration,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Повторение завершено!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Знаю: $_knownCount\nНе знаю: $_unknownCount',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_back),
              label: const Text('Вернуться к набору'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Нет карточек'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green[400]),
            const SizedBox(height: 16),
            Text(
              'Все карточки выучены!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Добавьте новые слова для изучения',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_back),
              label: const Text('Вернуться к набору'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
