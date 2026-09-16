import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:my_cards/data/local/models/card.dart';
import 'package:my_cards/data/local/models/deck.dart';
import 'package:my_cards/data/local/adapters/card_adapter.dart';
import 'package:my_cards/data/local/adapters/deck_adapter.dart';

void main() {
  group('Local Storage Tests', () {
    late Box<dynamic> deckBox;
    late Box<dynamic> cardBox;

    setUpAll(() async {
      Hive.init('test_hive');
      Hive.registerAdapter(CardAdapter());
      Hive.registerAdapter(DeckAdapter());
      deckBox = await Hive.openBox('decks_test');
      cardBox = await Hive.openBox('cards_test');
    });

    tearDownAll(() async {
      await deckBox.clear();
      await cardBox.clear();
      await deckBox.close();
      await cardBox.close();
    });

    test('Should create and save a deck', () async {
      final deck = Deck(
        id: 'deck-1',
        title: 'Test Deck',
        createdAt: DateTime.now(),
      );

      await deckBox.put(deck.id, deck);

      final savedDeck = deckBox.get(deck.id) as Deck?;

      expect(savedDeck, isNotNull);
      expect(savedDeck!.title, 'Test Deck');
    });

    test('Should create and save a card', () async {
      final card = Card(
        id: 'card-1',
        question: 'Test Question',
        answer: 'Test Answer',
      );

      await cardBox.put(card.id, card);

      final savedCard = cardBox.get(card.id) as Card?;

      expect(savedCard, isNotNull);
      expect(savedCard!.question, 'Test Question');
      expect(savedCard.answer, 'Test Answer');
    });

    test('Should update an existing card', () async {
      final card = Card(
        id: 'card-2',
        question: 'Old Question',
        answer: 'Old Answer',
      );

      await cardBox.put(card.id, card);

      final updatedCard = card.copyWith(
        question: 'New Question',
        repetitions: 1,
      );

      await cardBox.put(updatedCard.id, updatedCard);

      final retrievedCard = cardBox.get(card.id) as Card?;

      expect(retrievedCard!.question, 'New Question');
      expect(retrievedCard.repetitions, 1);
      expect(retrievedCard.answer, 'Old Answer'); // Unchanged
    });

    test('Should delete a deck', () async {
      final deck = Deck(
        id: 'deck-2',
        title: 'To Delete',
        createdAt: DateTime.now(),
      );

      await deckBox.put(deck.id, deck);
      await deckBox.delete(deck.id);

      final deletedDeck = deckBox.get(deck.id);

      expect(deletedDeck, isNull);
    });

    test('Should retrieve all decks', () async {
      await deckBox.clear();

      final deck1 = Deck(id: 'd1', title: 'Deck 1', createdAt: DateTime.now());
      final deck2 = Deck(id: 'd2', title: 'Deck 2', createdAt: DateTime.now());

      await deckBox.put(deck1.id, deck1);
      await deckBox.put(deck2.id, deck2);

      final allDecks = deckBox.values.cast<Deck>().toList();

      expect(allDecks.length, 2);
      expect(allDecks.map((d) => d.id).contains('d1'), true);
      expect(allDecks.map((d) => d.id).contains('d2'), true);
    });
  });
}
