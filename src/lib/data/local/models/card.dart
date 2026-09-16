import 'package:hive/hive.dart';

part 'card.g.dart';

@HiveType(typeId: 0)
class Card extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String question; // Слово на английском

  @HiveField(2)
  String answer;   // Перевод на русский

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  DateTime? lastReviewedAt;

  @HiveField(5)
  int repetitionCount; // Количество повторений

  @HiveField(6)
  double easeFactor; // Фактор легкости (SM-2)

  @HiveField(7)
  int intervalDays; // Интервал до следующего повторения (в днях)

  @HiveField(8)
  bool isLearned; // Выучено ли слово

  Card({
    required this.id,
    required this.question,
    required this.answer,
    required this.createdAt,
    this.lastReviewedAt,
    this.repetitionCount = 0,
    this.easeFactor = 2.5,
    this.intervalDays = 0,
    this.isLearned = false,
  });
}
