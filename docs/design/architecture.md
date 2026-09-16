# Architecture Document (Архитектура приложения)

## 1. Обзор архитектуры

### 1.1 Тип архитектуры
**Clean Architecture + BLoC Pattern** для Flutter приложения с локальным хранением данных.

```
┌─────────────────────────────────────────┐
│           Presentation Layer            │
│  (Widgets, Screens, BLoCs, States)      │
├─────────────────────────────────────────┤
│           Domain Layer                  │
│  (Entities, Use Cases, Repos Interfaces)│
├─────────────────────────────────────────┤
│           Data Layer                    │
│  (Repositories Impl, Local Data Source) │
└─────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│        Local Storage (SharedPreferences)│
└─────────────────────────────────────────┘
```

### 1.2 Обоснование выбора
| Паттерн | Плюсы | Минусы |
|---------|-------|--------|
| **Clean Architecture** | Разделение ответственности, тестируемость, независимость от фреймворков | Больше файлов, сложнее для простых проектов |
| **BLoC** | Явное управление состоянием, тестируемость, реактивность | Больше boilerplate кода |
| **Repository Pattern** | Абстракция источника данных, легкая замена реализации | Дополнительный слой абстракции |

**Альтернативы рассмотренные:**
- **MVVM**: Проще, но менее явное разделение бизнес-логики
- **Provider**: Легче в изучении, но менее масштабируемый
- **GetX**: Очень просто, но смешивает логику и UI, сложно тестировать

---

## 2. Структура проекта

```
lib/
├── main.dart                    # Точка входа, инициализация
├── core/
│   ├── constants/
│   │   ├── app_constants.dart   # Константы приложения
│   │   └── storage_keys.dart    # Ключи для localStorage
│   ├── errors/
│   │   ├── exceptions.dart      # Кастомные исключения
│   │   └── failures.dart        # Классы ошибок
│   ├── utils/
│   │   ├── id_generator.dart    # Генерация UUID
│   │   └── json_converter.dart  # Утилиты сериализации
│   └── theme/
│       ├── app_colors.dart      # Цветовая палитра
│       ├── app_text_styles.dart # Типографика
│       └── app_theme.dart       # Тема Material
├── data/
│   ├── models/
│   │   ├── deck_model.dart      # Модель набора (сериализация)
│   │   ├── card_model.dart      # Модель карточки
│   │   └── study_stats_model.dart # Модель статистики
│   ├── datasources/
│   │   └── local_storage_datasource.dart # Работа с SharedPreferences
│   └── repositories/
│       └── repository_impl.dart # Реализация репозиториев
├── domain/
│   ├── entities/
│   │   ├── deck.dart            # Бизнес-объект набора
│   │   ├── card.dart            # Бизнес-объект карточки
│   │   └── card_status.dart     # Enum: new, learning, learned
│   ├── repositories/
│   │   └── repository.dart      # Интерфейс репозитория
│   └── usecases/
│       ├── deck/
│       │   ├── create_deck.dart
│       │   ├── get_all_decks.dart
│       │   ├── update_deck.dart
│       │   ├── delete_deck.dart
│       │   └── duplicate_deck.dart
│       ├── card/
│       │   ├── create_card.dart
│       │   ├── get_cards_by_deck.dart
│       │   ├── update_card.dart
│       │   ├── delete_card.dart
│       │   └── duplicate_card.dart
│       └── study/
│           ├── start_study_session.dart
│           ├── mark_card_known.dart
│           ├── mark_card_unknown.dart
│           └── get_study_progress.dart
├── presentation/
│   ├── blocs/
│   │   ├── deck/
│   │   │   ├── deck_bloc.dart
│   │   │   ├── deck_event.dart
│   │   │   └── deck_state.dart
│   │   ├── card/
│   │   │   ├── card_bloc.dart
│   │   │   ├── card_event.dart
│   │   │   └── card_state.dart
│   │   └── study/
│   │       ├── study_bloc.dart
│   │       ├── study_event.dart
│   │       └── study_state.dart
│   ├── screens/
│   │   ├── home/
│   │   │   └── home_screen.dart
│   │   ├── deck_list/
│   │   │   └── deck_list_screen.dart
│   │   ├── deck_detail/
│   │   │   └── deck_detail_screen.dart
│   │   ├── card_form/
│   │   │   └── card_form_screen.dart
│   │   ├── study/
│   │   │   └── study_screen.dart
│   │   ├── study_result/
│   │   │   └── study_result_screen.dart
│   │   └── settings/
│   │       └── settings_screen.dart
│   └── widgets/
│       ├── deck_card.dart       # Виджет карточки набора
│       ├── flashcard.dart       # Виджет учебной карточки
│       ├── custom_button.dart   # Кастомная кнопка
│       ├── progress_bar.dart    # Прогресс-бар
│       └── empty_state.dart     # Пустое состояние
└── injection_container.dart     # Dependency Injection
```

---

## 3. Модель данных

### 3.1 Сущности (Domain Layer)

#### Card (Карточка)
```dart
class Card {
  final String id;              // UUID
  final String deckId;          // ID родительского набора
  final String question;        // Вопрос (английское слово)
  final String answer;          // Ответ (перевод)
  final CardStatus status;      // new, learning, learned
  final DateTime createdAt;     // Дата создания
  final DateTime? updatedAt;    // Дата обновления
  final int reviewCount;        // Количество повторений
  final int correctCount;       // Количество правильных ответов
}

enum CardStatus {
  new_,         // Новая карточка
  learning,     // В процессе изучения
  learned       // Выучена
}
```

#### Deck (Набор)
```dart
class Deck {
  final String id;              // UUID
  final String title;           // Название набора
  final List<Card> cards;       // Список карточек
  final DateTime createdAt;     // Дата создания
  final DateTime? updatedAt;    // Дата обновления
}
```

#### StudySession (Сессия обучения)
```dart
class StudySession {
  final String deckId;
  final List<Card> cardsToReview;  // Карточки для повторения
  int currentIndex;
  int knownCount;
  int unknownCount;
}
```

### 3.2 Модели (Data Layer)

Модели наследуются от сущностей и добавляют методы сериализации:

```dart
class CardModel extends Card {
  // Методы для JSON
  Map<String, dynamic> toJson();
  factory CardModel.fromJson(Map<String, dynamic> json);
  
  // Метод преобразования в сущность
  Card toEntity();
}
```

---

## 4. Хранение данных

### 4.1 Локальное хранилище
**Технология:** `SharedPreferences` (для MVP)

**Структура данных в хранилище:**
```json
{
  "flashcards_data": "{\"decks\":[...]}",
  "app_settings": "{\"language\":\"ru\",\"theme\":\"light\"}"
}
```

**Обоснование выбора:**
| Технология | Плюсы | Минусы | Выбор |
|------------|-------|--------|-------|
| **SharedPreferences** | Просто, быстро, встроен в Flutter | Только ключ-значение, нет запросов | ✅ MVP |
| **Hive** | Быстро, типизировано, NoSQL | Дополнительная зависимость | ⏭️ v1.1 |
| **SQLite (sqflite)** | Реляционная БД, запросы | Сложнее, избыточно для MVP | ❌ |
| **Isar** | Очень быстро, типизировано | Новая, меньше документации | ⏭️ v1.2 |

**План миграции:** При росте данных (>1000 карточек) перейти на Hive.

### 4.2 Формат хранения
Все данные хранятся как один JSON-объект в ключе `flashcards_data`:

```json
{
  "decks": [
    {
      "id": "deck-uuid-1",
      "title": "Английский - Еда",
      "createdAt": "2024-01-15T10:00:00Z",
      "cards": [
        {
          "id": "card-uuid-1",
          "question": "Apple",
          "answer": "Яблоко",
          "status": "learned",
          "reviewCount": 5,
          "correctCount": 4
        }
      ]
    }
  ]
}
```

---

## 5. Бизнес-логика (Use Cases)

### 5.1 Управление наборами

#### CreateDeck
```
Input: String title
Output: Deck
Process:
  1. Generate UUID for deck
  2. Create Deck entity with empty cards list
  3. Save to repository
  4. Return created deck
```

#### GetAllDecks
```
Input: none
Output: List<Deck>
Process:
  1. Load data from local storage
  2. Parse JSON to List<Deck>
  3. Return list sorted by updatedAt (desc)
```

#### DeleteDeck
```
Input: String deckId
Output: bool
Process:
  1. Find deck by id
  2. Remove from list
  3. Save updated list
  4. Return true
```

### 5.2 Управление карточками

#### CreateCard
```
Input: String deckId, String question, String answer
Output: Card
Process:
  1. Validate input (not empty)
  2. Generate UUID
  3. Create Card with status=new_
  4. Add to deck.cards
  5. Save to repository
  6. Return card
```

#### UpdateCardStatus
```
Input: String cardId, CardStatus newStatus
Output: Card
Process:
  1. Find card in all decks
  2. Update status
  3. Update reviewCount, correctCount
  4. Save to repository
  5. Return updated card
```

### 5.3 Обучение

#### StartStudySession
```
Input: String deckId
Output: StudySession
Process:
  1. Get deck by id
  2. Filter cards: status != learned OR status == learning
  3. Shuffle cards randomly
  4. Create StudySession with filtered cards
  5. Return session
```

#### MarkCardKnown
```
Input: String cardId
Output: Card
Process:
  1. Find card
  2. If reviewCount >= 3 AND correctCount/reviewCount >= 0.8:
       status = learned
     Else:
       status = learning
  3. Increment reviewCount, correctCount
  4. Save
  5. Return card
```

#### MarkCardUnknown
```
Input: String cardId
Output: Card
Process:
  1. Find card
  2. status = learning (если была new_)
  3. Increment reviewCount only
  4. Save
  5. Return card
```

---

## 6. State Management (BLoC)

### 6.1 DeckBloc

**Events:**
```dart
abstract class DeckEvent {}

class LoadDecks extends DeckEvent {}
class CreateDeck extends DeckEvent { final String title; }
class UpdateDeck extends DeckEvent { final Deck deck; }
class DeleteDeck extends DeckEvent { final String deckId; }
class DuplicateDeck extends DeckEvent { final String deckId; }
```

**States:**
```dart
abstract class DeckState {}

class DeckInitial extends DeckState {}
class DeckLoading extends DeckState {}
class DeckLoaded extends DeckState { final List<Deck> decks; }
class DeckError extends DeckState { final String message; }
```

### 6.2 StudyBloc

**Events:**
```dart
abstract class StudyEvent {}

class StartStudy extends StudyEvent { final String deckId; }
class ShowAnswer extends StudyEvent {}
class MarkKnown extends StudyEvent {}
class MarkUnknown extends StudyEvent {}
class CompleteStudy extends StudyEvent {}
```

**States:**
```dart
abstract class StudyState {}

class StudyInitial extends StudyState {}
class StudyInProgress extends StudyState {
  final Card currentCard;
  final int currentIndex;
  final int totalCount;
  final bool isAnswerShown;
}
class StudyCompleted extends StudyState {
  final int totalCards;
  final int knownCount;
  final int unknownCount;
}
class StudyError extends StudyState { final String message; }
```

---

## 7. Dependency Injection

Используется `get_it` + `injectable` для DI.

```dart
// injection_container.dart
final sl = GetIt.instance;

Future<void> init() async {
  // BLoCs
  sl.registerFactory(() => DeckBloc(sl(), sl(), sl()));
  sl.registerFactory(() => CardBloc(sl(), sl()));
  sl.registerFactory(() => StudyBloc(sl()));
  
  // Use Cases
  sl.registerLazySingleton(() => CreateDeck(sl()));
  sl.registerLazySingleton(() => GetAllDecks(sl()));
  // ... другие use cases
  
  // Repository
  sl.registerLazySingleton<Repository>(() => RepositoryImpl(sl()));
  
  // Data Source
  sl.registerLazySingleton(() => LocalStorageDataSource());
  
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
}
```

---

## 8. Навигация

Используется `go_router` для декларативной навигации.

```dart
final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => HomeScreen()),
    GoRoute(path: '/deck/:id', builder: (_, state) => DeckDetailScreen(id: state.pathParameters['id']!)),
    GoRoute(path: '/study/:id', builder: (_, state) => StudyScreen(id: state.pathParameters['id']!')),
    GoRoute(path: '/card/new/:deckId', builder: (_, state) => CardFormScreen(deckId: state.pathParameters['deckId']!')),
  ],
);
```

---

## 9. ADR (Architecture Decision Records)

### ADR-001: Выбор локального хранилища
**Дата:** 2024-01-20  
**Статус:** Принято  
**Контекст:** Приложение работает оффлайн, нужно простое хранилище для MVP  
**Решение:** SharedPreferences  
**Последствия:** Простота реализации, ограничение на размер данных (~5MB), план миграции на Hive при росте

### ADR-002: Выбор стейт-менеджмента
**Дата:** 2024-01-20  
**Статус:** Принято  
**Контекст:** Нужно явное управление состоянием с хорошей тестируемостью  
**Решение:** BLoC Pattern  
**Последствия:** Больше boilerplate, но лучшая архитектура и тестируемость

### ADR-003: Отсутствие бэкенда
**Дата:** 2024-01-20  
**Статус:** Принято  
**Контекст:** MVP должно работать полностью оффлайн без интернета  
**Решение:** Все данные локально, синхронизация через экспорт/импорт JSON  
**Последствия:** Нет облачной синхронизации, пользователь сам управляет бэкапами

---

## 10. Безопасность

Так как приложение локальное и не имеет сетевого взаимодействия:
- Нет аутентификации
- Нет шифрования данных (данные не критичные)
- Нет обработки персональных данных
- Данные доступны только пользователю устройства

---

## 11. Производительность

### Целевые метрики
| Метрика | Значение |
|---------|----------|
| Время запуска приложения | < 2 сек |
| Время загрузки списка наборов | < 100 мс |
| Время открытия карточки | < 50 мс |
| FPS при анимациях | 60 FPS |
| Максимальное количество карточек без лагов | 1000+ |

### Оптимизации
- Ленивая загрузка списков (`ListView.builder`)
- Кэширование изображений (если будут добавлены)
- Debounce для поиска
- Избегание rebuild'ов через `const` конструкторы и `Equatable`
