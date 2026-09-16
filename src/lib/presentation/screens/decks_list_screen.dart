import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/local/models/deck.dart';

class DecksListScreen extends StatelessWidget {
  const DecksListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои Наборы'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateDeckDialog(context),
          ),
        ],
      ),
      body: ValueListenableBuilder<Box>(
        valueListenable: Hive.box('decks').listenable(),
        builder: (context, box, _) {
          final decks = box.values.cast<Deck>().toList();
          
          if (decks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Нет наборов',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Создайте первый набор карточек',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: decks.length,
            itemBuilder: (context, index) {
              final deck = decks[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(deck.title),
                  subtitle: Text('${deck.totalCards} карточек'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.play_arrow),
                        onPressed: () => Navigator.pushNamed(context, '/study/${deck.id}'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _navigateToDeckDetail(context, deck.id),
                      ),
                    ],
                  ),
                  onTap: () => _navigateToDeckDetail(context, deck.id),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _navigateToDeckDetail(BuildContext context, String deckId) {
    Navigator.pushNamed(context, '/deck/$deckId');
  }

  void _showCreateDeckDialog(BuildContext context) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Новый набор'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Название набора',
            hintText: 'Например: Основные слова',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                _createDeck(controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Создать'),
          ),
        ],
      ),
    );
  }

  void _createDeck(String title) {
    final box = Hive.box('decks');
    final deck = Deck(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      createdAt: DateTime.now(),
    );
    box.add(deck);
  }
}
