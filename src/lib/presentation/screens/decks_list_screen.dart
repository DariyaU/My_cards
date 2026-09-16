import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/local/models/deck.dart';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DecksListScreen extends StatelessWidget {
  const DecksListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои Наборы'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: () => _showImportDialog(context),
            tooltip: 'Импорт',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _exportAllData(context),
            tooltip: 'Экспорт',
          ),
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
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) => _handleDeckAction(context, deck, value),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('✏️ Редактировать')),
                      const PopupMenuItem(value: 'duplicate', child: Text('📄 Копировать')),
                      const PopupMenuItem(value: 'export', child: Text('📥 Экспорт набора')),
                      const PopupMenuItem(value: 'print', child: Text('🖨️ Печать')),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('🗑️ Удалить', style: TextStyle(color: Colors.red)),
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

  void _handleDeckAction(BuildContext context, Deck deck, String action) async {
    switch (action) {
      case 'edit':
        _showEditDeckDialog(context, deck);
        break;
      case 'duplicate':
        _duplicateDeck(deck);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Набор "${deck.title}" скопирован')),
        );
        break;
      case 'export':
        _exportDeck(deck, context);
        break;
      case 'print':
        _showPrintDialog(context, deck);
        break;
      case 'delete':
        _confirmDeleteDeck(context, deck);
        break;
    }
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

  void _showEditDeckDialog(BuildContext context, Deck deck) {
    final controller = TextEditingController(text: deck.title);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Редактировать набор'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Название набора',
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
                _updateDeck(deck, controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Сохранить'),
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

  void _updateDeck(Deck deck, String newTitle) {
    final box = Hive.box('decks');
    deck.title = newTitle;
    box.put(deck.id, deck);
  }

  void _duplicateDeck(Deck deck) {
    final box = Hive.box('decks');
    final duplicate = Deck(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '${deck.title} (копия)',
      createdAt: DateTime.now(),
      cards: List.from(deck.cards),
    );
    box.add(duplicate);
  }

  void _confirmDeleteDeck(BuildContext context, Deck deck) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удаление набора'),
        content: Text('Удалить набор "${deck.title}" и все его карточки?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteDeck(deck);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Набор "${deck.title}" удален')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Удалить', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _deleteDeck(Deck deck) {
    final box = Hive.box('decks');
    box.delete(deck.id);
  }

  Future<void> _exportDeck(Deck deck, BuildContext context) async {
    try {
      final data = {
        'title': deck.title,
        'createdAt': deck.createdAt.toIso8601String(),
        'cards': deck.cards.map((c) => {
          'question': c.question,
          'answer': c.answer,
          'status': c.status,
        }).toList(),
      };
      
      final json = JsonEncoder.withIndent('  ').convert(data);
      
      // Сохраняем в файл через File Picker
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Экспорт набора',
        fileName: '${deck.title.replaceAll(' ', '_')}.json',
        bytes: utf8.encode(json),
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      
      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Набор успешно экспортирован')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка экспорта: $e')),
      );
    }
  }

  Future<void> _exportAllData(BuildContext context) async {
    try {
      final box = Hive.box('decks');
      final decks = box.values.cast<Deck>().toList();
      
      final data = {
        'exportedAt': DateTime.now().toIso8601String(),
        'decks': decks.map((d) => {
          'id': d.id,
          'title': d.title,
          'createdAt': d.createdAt.toIso8601String(),
          'cards': d.cards.map((c) => {
            'id': c.id,
            'question': c.question,
            'answer': c.answer,
            'status': c.status,
          }).toList(),
        }).toList(),
      };
      
      final json = JsonEncoder.withIndent('  ').convert(data);
      
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Экспорт всех данных',
        fileName: 'flashcards_backup_${DateTime.now().millisecondsSinceEpoch}.json',
        bytes: utf8.encode(json),
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      
      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Все данные успешно экспортированы')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка экспорта: $e')),
      );
    }
  }

  void _showImportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Импорт данных'),
        content: const Text('Выберите JSON файл с данными для импорта'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton.icon(
            onPressed: () => _importFromFile(context),
            icon: const Icon(Icons.folder_open),
            label: const Text('Выбрать файл'),
          ),
        ],
      ),
    );
  }

  Future<void> _importFromFile(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      
      if (result == null || result.files.single.path == null) {
        return;
      }
      
      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;
      
      final box = Hive.box('decks');
      
      // Проверяем формат: один набор или несколько
      if (data.containsKey('decks')) {
        // Импорт нескольких наборов
        for (var deckData in data['decks'] as List) {
          await _importDeckFromData(box, deckData);
        }
      } else if (data.containsKey('title')) {
        // Импорт одного набора
        await _importDeckFromData(box, data);
      }
      
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Данные успешно импортированы')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка импорта: $e')),
      );
    }
  }

  Future<void> _importDeckFromData(Box box, Map<String, dynamic> data) async {
    final existingDeck = box.values.cast<Deck>().firstWhere(
      (d) => d.id == data['id'],
      orElse: () => Deck(id: '', title: '', createdAt: DateTime.now()),
    );
    
    if (existingDeck.id.isNotEmpty) {
      // Набор уже существует, обновляем
      // Можно добавить логику слияния или пропуска
      return;
    }
    
    final deck = Deck(
      id: data['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: data['title'] ?? 'Импортированный набор',
      createdAt: data['createdAt'] != null 
          ? DateTime.parse(data['createdAt']) 
          : DateTime.now(),
    );
    
    if (data['cards'] != null) {
      for (var cardData in data['cards'] as List) {
        deck.cards.add(CardModel(
          id: cardData['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
          question: cardData['question'] ?? '',
          answer: cardData['answer'] ?? '',
          status: cardData['status'] ?? 'new',
        ));
      }
    }
    
    box.add(deck);
  }

  void _showPrintDialog(BuildContext context, Deck deck) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Печать карточек'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Формат печати:'),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.print),
              title: const Text('Только вопросы'),
              subtitle: const Text('Для самостоятельного заполнения'),
              onTap: () {
                Navigator.pop(context);
                _printCards(deck, questionsOnly: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.view_list),
              title: const Text('Вопросы и ответы'),
              subtitle: const Text('Полный список для проверки'),
              onTap: () {
                Navigator.pop(context);
                _printCards(deck, questionsOnly: false);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
        ],
      ),
    );
  }

  void _printCards(Deck deck, {bool questionsOnly = false}) {
    // В реальном приложении здесь была бы интеграция с printing package
    // Для MVP показываем диалог с инструкцией
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Печать'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Набор: ${deck.title}'),
              const SizedBox(height: 16),
              Text(questionsOnly ? 'Вопросы:' : 'Карточки:'),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: deck.cards.length,
                  itemBuilder: (context, index) {
                    final card = deck.cards[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '${index + 1}. ${card.question}${questionsOnly ? '' : '\n   Ответ: ${card.answer}'}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '💡 Совет: Используйте функцию "Поделиться" в браузере или сделайте скриншот для печати.',
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }
}
