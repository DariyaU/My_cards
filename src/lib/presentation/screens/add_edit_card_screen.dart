import 'package:flutter/material.dart';
import 'package:my_cards/data/local/models/card.dart';

/// Экран добавления/редактирования карточки (US-007)
class AddEditCardScreen extends StatefulWidget {
  final CardModel? card; // Если null -> создание, иначе -> редактирование

  const AddEditCardScreen({Key? key, this.card}) : super(key: key);

  @override
  State<AddEditCardScreen> createState() => _AddEditCardScreenState();
}

class _AddEditCardScreenState extends State<AddEditCardScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _questionController;
  late TextEditingController _answerController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.card != null;
    _questionController = TextEditingController(text: widget.card?.question ?? '');
    _answerController = TextEditingController(text: widget.card?.answer ?? '');
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Редактировать карточку' : 'Новая карточка'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Поле "Вопрос"
              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(
                  labelText: 'Вопрос (английский)',
                  hintText: 'Например: Apple',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.question_answer),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите вопрос';
                  }
                  return null;
                },
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              // Поле "Ответ"
              TextFormField(
                controller: _answerController,
                decoration: const InputDecoration(
                  labelText: 'Ответ (перевод)',
                  hintText: 'Например: Яблоко',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.translate),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите ответ';
                  }
                  return null;
                },
                maxLines: 3,
              ),
              const Spacer(),
              // Кнопки
              ElevatedButton(
                onPressed: _saveCard,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text(_isEditing ? 'Сохранить изменения' : 'Добавить карточку'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Отмена'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveCard() {
    if (_formKey.currentState!.validate()) {
      // Здесь будет логика сохранения через BLoC/Repository
      // Для MVP возвращаем данные обратно в предыдущий экран
      final newCard = CardModel(
        id: widget.card?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        question: _questionController.text.trim(),
        answer: _answerController.text.trim(),
        deckId: widget.card?.deckId ?? '',
        status: widget.card?.status ?? CardStatus.newCard,
        createdAt: widget.card?.createdAt ?? DateTime.now(),
        lastReviewedAt: widget.card?.lastReviewedAt,
        nextReviewAt: widget.card?.nextReviewAt,
        sm2Interval: widget.card?.sm2Interval ?? 0,
        sm2Repetition: widget.card?.sm2Repetition ?? 0,
        sm2EaseFactor: widget.card?.sm2EaseFactor ?? 2.5,
      );

      Navigator.pop(context, newCard);
    }
  }
}
