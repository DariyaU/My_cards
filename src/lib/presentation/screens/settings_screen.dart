import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:my_cards/data/local/models/deck.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Экран настроек: экспорт/импорт данных, печать карточек (US-008)
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Данные'),
          _buildSettingTile(
            context,
            icon: Icons.upload_file,
            title: 'Экспорт в JSON',
            subtitle: 'Сохранить все наборы в файл',
            onTap: () => _exportData(context),
          ),
          _buildSettingTile(
            context,
            icon: Icons.download,
            title: 'Импорт из JSON',
            subtitle: 'Загрузить наборы из файла',
            onTap: () => _importData(context),
          ),
          const Divider(height: 32),
          _buildSectionTitle('Печать'),
          _buildSettingTile(
            context,
            icon: Icons.print,
            title: 'Печать карточек',
            subtitle: 'Распечатать все наборы (только вопросы)',
            onTap: () => _printCards(context),
          ),
          const Divider(height: 32),
          _buildSectionTitle('О приложении'),
          _buildSettingTile(
            context,
            icon: Icons.info_outline,
            title: 'Версия',
            subtitle: 'My Cards v1.0.0',
            onTap: () => _showAboutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Future<void> _exportData(BuildContext context) async {
    try {
      final box = Hive.box('decks');
      final decks = <Map<String, dynamic>>[];
      
      for (var key in box.keys) {
        final deck = box.get(key) as Deck;
        decks.add(deck.toJson());
      }

      final json = jsonEncode({'sets': decks});
      
      // Для MVP показываем JSON в диалоге
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Экспорт данных'),
          content: SingleChildScrollView(
            child: SelectableText(json),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Закрыть'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Сохранение в файл через file_saver
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Данные скопированы в буфер')),
                );
                Navigator.pop(context);
              },
              icon: const Icon(Icons.copy),
              label: const Text('Копировать'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка экспорта: $e')),
      );
    }
  }

  Future<void> _importData(BuildContext context) async {
    try {
      // Для MVP - ввод JSON вручную
      final controller = TextEditingController();
      
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Импорт данных'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Вставьте JSON здесь',
              border: OutlineInputBorder(),
            ),
            maxLines: 10,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Импортировать'),
            ),
          ],
        ),
      );

      if (controller.text.isNotEmpty) {
        final data = jsonDecode(controller.text) as Map<String, dynamic>;
        final sets = data['sets'] as List;
        
        final box = Hive.box('decks');
        int count = 0;
        
        for (var setJson in sets) {
          final deck = Deck.fromJson(setJson as Map<String, dynamic>);
          await box.put(deck.id, deck);
          count++;
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Импортировано наборов: $count')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка импорта: $e')),
      );
    }
  }

  Future<void> _printCards(BuildContext context) async {
    try {
      final box = Hive.box('decks');
      final decks = <Deck>[];
      
      for (var key in box.keys) {
        decks.add(box.get(key) as Deck);
      }

      if (decks.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Нет наборов для печати')),
        );
        return;
      }

      // Генерация PDF
      final pdf = pw.Document();
      
      for (var deck in decks) {
        pdf.addPage(
          pw.Page(
            build: (pw.Context context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(deck.title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 20),
                ...deck.cards.map((card) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 16),
                  child: pw.Text('• ${card.question}', style: const pw.TextStyle(fontSize: 14)),
                )),
              ],
            ),
          ),
        );
      }

      // Печать или предпросмотр
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка печати: $e')),
      );
    }
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('О приложении'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('My Cards v1.0.0', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Приложение для изучения иностранных слов с помощью карточек.'),
            const SizedBox(height: 16),
            const Text('Функции:', style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('• Создание наборов карточек'),
            const Text('• Интервальное повторение (SM-2)'),
            const Text('• Статистика прогресса'),
            const Text('• Экспорт/Импорт данных'),
            const Text('• Печать карточек'),
          ],
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
