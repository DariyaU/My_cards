import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/local/models/deck.dart';
import '../../data/local/models/card.dart';

class DeckDetailScreen extends StatelessWidget {
  final String deckId;

  const DeckDetailScreen({super.key, required this.deckId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Набор карточек'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCardDialog(context),
          ),
        ],
      ),
      body: ValueListenableBuilder<Box>(
        valueListenable: Hive.box('decks').listenable(),
        builder: (context, box, _) {
          final deck = box.get(deckId) as Deck?;
          
          if (deck == null) {
            return const Center(child: Text('Набор не найден'));
          }
          
          return Column(
            children: [
              // Статистика
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Всего', deck.totalCards.toString()),
                    _buildStatItem('Новых', deck.newCards.toString()),
                    _buildStatItem('Выучено', deck.learnedCards.toString()),
                  ],
                ),
              ),
              
              // Список карточек
              Expanded(
                child: deck.cards.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notes, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'Нет карточек',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('Добавить первую карточку'),
                              onPressed: () => _showAddCardDialog(context),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: deck.cards.length,
                        itemBuilder: (context, index) {
                          final card = deck.cards[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text(card.question),
                              subtitle: Text(card.answer),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) => _handleCardAction(context, deck, card, value),
                                itemBuilder: (context) => [
                                  const PopupMenuItem(value: 'edit', child: Text('Редактировать')),
                                  const PopupMenuItem(value: 'delete', child: Text('Удалить')),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  void _showAddCardDialog(BuildContext context) {
    final questionController = TextEditingController();
    final answerController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Новая карточка'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: questionController,
              decoration: const InputDecoration(
                labelText: 'Вопрос (EN)',
                hintText: 'Слово на английском',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: answerController,
              decoration: const InputDecoration(
                labelText: 'Ответ (RU)',
                hintText: 'Перевод на русский',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              if (questionController.text.trim().isNotEmpty && 
                  answerController.text.trim().isNotEmpty) {
                _addCard(questionController.text.trim(), answerController.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _addCard(String question, String answer) {
    final box = Hive.box('decks');
    final deck = box.get(deckId) as Deck;
    
    final card = Card(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      question: question,
      answer: answer,
      createdAt: DateTime.now(),
    );
    
    deck.cards.add(card);
    deck.save(); // Сохраняем изменения в Hive
  }

  void _handleCardAction(BuildContext context, Deck deck, Card card, String action) {
    switch (action) {
      case 'edit':
        _showEditCardDialog(context, deck, card);
        break;
      case 'delete':
        _confirmDeleteCard(context, deck, card);
        break;
    }
  }

  void _showEditCardDialog(BuildContext context, Deck deck, Card card) {
    final questionController = TextEditingController(text: card.question);
    final answerController = TextEditingController(text: card.answer);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Редактировать карточку'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: questionController,
              decoration: const InputDecoration(labelText: 'Вопрос (EN)'),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: answerController,
              decoration: const InputDecoration(labelText: 'Ответ (RU)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              if (questionController.text.trim().isNotEmpty && 
                  answerController.text.trim().isNotEmpty) {
                card.question = questionController.text.trim();
                card.answer = answerController.text.trim();
                card.save();
                Navigator.pop(context);
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCard(BuildContext context, Deck deck, Card card) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить карточку?'),
        content: Text('Вы уверены, что хотите удалить "${card.question}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              deck.cards.remove(card);
              deck.save();
              Navigator.pop(context);
            },
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}
