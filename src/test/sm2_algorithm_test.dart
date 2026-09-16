import 'package:flutter_test/flutter_test.dart';
import 'package:my_cards/data/local/models/card.dart';
import 'package:my_cards/core/utils/sm2_algorithm.dart';

void main() {
  group('SM-2 Algorithm Tests', () {
    test('Initial card should have correct default values', () {
      final card = Card(
        id: 'test-1',
        question: 'Question',
        answer: 'Answer',
      );

      expect(card.easeFactor, 2.5);
      expect(card.interval, 0);
      expect(card.repetitions, 0);
      expect(card.nextReviewDate, isNull);
    });

    test('Grade 5 (Perfect) should increase interval and repetitions', () {
      final card = Card(
        id: 'test-2',
        question: 'Q',
        answer: 'A',
        easeFactor: 2.5,
        interval: 1,
        repetitions: 1,
      );

      final updatedCard = SM2Algorithm.calculate(card, grade: 5);

      expect(updatedCard.repetitions, 2);
      expect(updatedCard.interval, greaterThan(1));
      expect(updatedCard.easeFactor, greaterThanOrEqualTo(2.5));
      expect(updatedCard.nextReviewDate, isNotNull);
    });

    test('Grade 3 (Hard) should keep repetitions but increase interval slightly', () {
      final card = Card(
        id: 'test-3',
        question: 'Q',
        answer: 'A',
        easeFactor: 2.5,
        interval: 3,
        repetitions: 2,
      );

      final updatedCard = SM2Algorithm.calculate(card, grade: 3);

      expect(updatedCard.repetitions, 3);
      expect(updatedCard.interval, greaterThan(0));
      expect(updatedCard.easeFactor, lessThan(2.5)); // EF decreases
    });

    test('Grade 2 (Pass) should reset repetitions and interval', () {
      final card = Card(
        id: 'test-4',
        question: 'Q',
        answer: 'A',
        easeFactor: 2.5,
        interval: 5,
        repetitions: 3,
      );

      final updatedCard = SM2Algorithm.calculate(card, grade: 2);

      expect(updatedCard.repetitions, 0);
      expect(updatedCard.interval, 1);
      expect(updatedCard.easeFactor, greaterThanOrEqualTo(1.3)); // Minimum EF
    });

    test('Grade 1 (Fail) should reset repetitions and interval', () {
      final card = Card(
        id: 'test-5',
        question: 'Q',
        answer: 'A',
        easeFactor: 2.5,
        interval: 4,
        repetitions: 2,
      );

      final updatedCard = SM2Algorithm.calculate(card, grade: 1);

      expect(updatedCard.repetitions, 0);
      expect(updatedCard.interval, 1);
    });

    test('Ease Factor should not go below 1.3', () {
      final card = Card(
        id: 'test-6',
        question: 'Q',
        answer: 'A',
        easeFactor: 1.5,
        interval: 2,
        repetitions: 1,
      );

      final updatedCard = SM2Algorithm.calculate(card, grade: 1);

      expect(updatedCard.easeFactor, 1.3);
    });

    test('Next review date should be in the future', () {
      final card = Card(
        id: 'test-7',
        question: 'Q',
        answer: 'A',
        easeFactor: 2.5,
        interval: 1,
        repetitions: 1,
      );

      final updatedCard = SM2Algorithm.calculate(card, grade: 5);
      final now = DateTime.now();

      expect(updatedCard.nextReviewDate!.isAfter(now), true);
    });
  });
}
