import 'package:hive/hive.dart';
import '../models/deck.dart';
import '../models/card.dart';

class DeckAdapter extends TypeAdapter<Deck> {
  @override
  final int typeId = 1;

  @override
  Deck read(BinaryReader reader) {
    final id = reader.readString();
    final title = reader.readString();
    final description = reader.readString();
    final createdAt = reader.readDateTime();
    final lastStudiedAt = reader.readNullableDateTime();
    final numOfCards = reader.readInt();
    
    final cards = <Card>[];
    for (int i = 0; i < numOfCards; i++) {
      cards.add(reader.readHiveObject() as Card);
    }

    return Deck(
      id: id,
      title: title,
      description: description,
      createdAt: createdAt,
      lastStudiedAt: lastStudiedAt,
      cards: cards,
    );
  }

  @override
  void write(BinaryWriter writer, Deck obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.description);
    writer.writeDateTime(obj.createdAt);
    writer.writeNullableDateTime(obj.lastStudiedAt);
    writer.writeInt(obj.cards.length);
    
    for (final card in obj.cards) {
      writer.writeHiveObject(card);
    }
  }
}
