class SM2Algorithm {
  /// Calculates the next review date and updates card statistics based on the grade.
  /// 
  /// [grade] ranges from 1 to 5:
  /// - 1: Complete blackout (fail)
  /// - 2: Incorrect response, but correct upon seeing answer
  /// - 3: Correct response recalled with serious difficulty
  /// - 4: Correct response after a hesitation
  /// - 5: Perfect response
  static Card calculate(Card card, {required int grade}) {
    // Validate grade
    if (grade < 1 || grade > 5) {
      throw ArgumentError('Grade must be between 1 and 5');
    }

    double easeFactor = card.easeFactor;
    int repetitions = card.repetitions;
    int interval = card.interval;

    // Update Ease Factor (EF)
    // EF' = EF + 0.1 - (5 - q) * (0.08 + (5 - q) * 0.02)
    easeFactor = easeFactor + 0.1 - (5 - grade) * (0.08 + (5 - grade) * 0.02);
    
    // Ensure EF doesn't go below 1.3
    if (easeFactor < 1.3) {
      easeFactor = 1.3;
    }

    // Update Repetitions and Interval
    if (grade >= 3) {
      // Successful recall
      repetitions++;
      
      if (repetitions == 1) {
        interval = 1;
      } else if (repetitions == 2) {
        interval = 6;
      } else {
        interval = (interval * easeFactor).round();
      }
    } else {
      // Failed recall - reset
      repetitions = 0;
      interval = 1;
    }

    // Calculate next review date
    final nextReviewDate = DateTime.now().add(Duration(days: interval));

    return card.copyWith(
      easeFactor: easeFactor,
      repetitions: repetitions,
      interval: interval,
      nextReviewDate: nextReviewDate,
    );
  }

  /// Returns cards that are due for review today or earlier.
  static List<Card> getDueCards(List<Card> cards) {
    final now = DateTime.now();
    return cards.where((card) {
      // If nextReviewDate is null, it's a new card
      if (card.nextReviewDate == null) return true;
      return card.nextReviewDate!.isBefore(now) || 
             card.nextReviewDate!.isAtSameMomentAs(now);
    }).toList();
  }

  /// Shuffles a list of cards for random presentation.
  static List<Card> shuffleCards(List<Card> cards) {
    final shuffled = List<Card>.from(cards);
    shuffled.shuffle();
    return shuffled;
  }
}
