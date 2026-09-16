import 'package:hive/hive.dart';
import 'card.dart';

part 'deck.g.dart';

@HiveType(typeId: 1)
class Deck extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  DateTime? lastStudiedAt;

  @HiveField(5)
  List<Card> cards;

  Deck({
    required this.id,
    required this.title,
    this.description = '',
    required this.createdAt,
    this.lastStudiedAt,
    List<Card>? cards,
  }) : cards = cards ?? [];

  int get totalCards => cards.length;
  
  int get learnedCards => cards.where((c) => c.isLearned).length;
  
  int get newCards => cards.where((c) => c.repetitionCount == 0).length;
  
  int get reviewCards => cards.where((c) => !c.isLearned && c.repetitionCount > 0).length;
}
