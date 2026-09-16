import 'package:hive/hive.dart';
import '../models/card.dart';

class CardAdapter extends TypeAdapter<Card> {
  @override
  final int typeId = 0;

  @override
  Card read(BinaryReader reader) {
    final id = reader.readString();
    final question = reader.readString();
    final answer = reader.readString();
    final createdAt = reader.readDateTime();
    final lastReviewedAt = reader.readNullableDateTime();
    final repetitionCount = reader.readInt();
    final easeFactor = reader.readDouble();
    final intervalDays = reader.readInt();
    final isLearned = reader.readBool();

    return Card(
      id: id,
      question: question,
      answer: answer,
      createdAt: createdAt,
      lastReviewedAt: lastReviewedAt,
      repetitionCount: repetitionCount,
      easeFactor: easeFactor,
      intervalDays: intervalDays,
      isLearned: isLearned,
    );
  }

  @override
  void write(BinaryWriter writer, Card obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.question);
    writer.writeString(obj.answer);
    writer.writeDateTime(obj.createdAt);
    writer.writeNullableDateTime(obj.lastReviewedAt);
    writer.writeInt(obj.repetitionCount);
    writer.writeDouble(obj.easeFactor);
    writer.writeInt(obj.intervalDays);
    writer.writeBool(obj.isLearned);
  }
}
