# Design System (Система дизайна)

## 1. Цветовая палитра

### Основные цвета
```yaml
Primary:
  main: "#4CAF50"       # Зеленый - успех, изучено
  light: "#81C784"
  dark: "#388E3C"

Secondary:
  main: "#2196F3"       # Синий - действия, информация
  light: "#64B5F6"
  dark: "#1976D2"

Accent:
  main: "#FF9800"       # Оранжевый - предупреждения, новые карточки
  light: "#FFB74D"
  dark: "#F57C00"

Error:
  main: "#F44336"       # Красный - ошибки, не знаю
  light: "#E57373"
  dark: "#D32F2F"

Neutral:
  white: "#FFFFFF"
  gray-50: "#FAFAFA"
  gray-100: "#F5F5F5"
  gray-200: "#EEEEEE"
  gray-300: "#E0E0E0"
  gray-400: "#BDBDBD"
  gray-500: "#9E9E9E"
  gray-600: "#757575"
  gray-700: "#616161"
  gray-800: "#424242"
  gray-900: "#212121"
  black: "#000000"
```

### Семантика цветов
| Элемент | Цвет | HEX |
|---------|------|-----|
| Фон приложения | Neutral gray-50 | #FAFAFA |
| Фон карточки | White | #FFFFFF |
| Текст основной | Neutral gray-900 | #212121 |
| Текст вторичный | Neutral gray-600 | #757575 |
| Кнопка "Знаю" | Primary main | #4CAF50 |
| Кнопка "Не знаю" | Error main | #F44336 |
| Кнопка действия | Secondary main | #2196F3 |
| Прогресс-бар | Primary main | #4CAF50 |
| Границы | Neutral gray-300 | #E0E0E0 |

---

## 2. Типографика

### Шрифты
- **Основной шрифт:** Roboto (стандарт Material Design для Flutter)
- **Альтернатива:** San Francisco (iOS), Roboto (Android)

### Размерная сетка
```yaml
Display:
  size: 32px
  weight: 700 (Bold)
  line-height: 40px
  
Heading 1:
  size: 24px
  weight: 600 (SemiBold)
  line-height: 32px
  
Heading 2:
  size: 20px
  weight: 600 (SemiBold)
  line-height: 28px
  
Body Large:
  size: 16px
  weight: 400 (Regular)
  line-height: 24px
  
Body:
  size: 14px
  weight: 400 (Regular)
  line-height: 20px
  
Caption:
  size: 12px
  weight: 400 (Regular)
  line-height: 16px
  
Button:
  size: 14px
  weight: 500 (Medium)
  line-height: 16px
  text-transform: uppercase
```

### Иерархия текста
| Элемент | Стиль | Размер | Вес |
|---------|-------|--------|-----|
| Заголовок приложения | Display | 32px | Bold |
| Заголовок экрана | H1 | 24px | SemiBold |
| Заголовок карточки | H2 | 20px | SemiBold |
| Текст вопроса | Body Large | 16px | Regular |
| Текст ответа | Body | 14px | Regular |
| Подписи кнопок | Button | 14px | Medium |
| Вторичный текст | Caption | 12px | Regular |

---

## 3. Сетка и отступы

### Базовая сетка
- **Базовая единица:** 4px
- Все отступы кратны 4px

### Отступы
```yaml
xs: 4px
sm: 8px
md: 16px
lg: 24px
xl: 32px
xxl: 48px
```

### Макет экрана
```
+----------------------------------+
|  Safe Area Top (24-44px)         |
+----------------------------------+
|  App Bar (56px)                  |
|  - Отступы по бокам: 16px        |
+----------------------------------+
|                                  |
|  Content Area                    |
|  - Отступы по бокам: 16px        |
|  - Отступ между элементами: 16px |
|                                  |
+----------------------------------+
|  Bottom Nav Bar (56-80px)        |
+----------------------------------+
|  Safe Area Bottom (24-34px)      |
+----------------------------------+
```

---

## 4. Компоненты

### 4.1 Карточка (Card)
```
┌─────────────────────────────────┐
│                                 │
│  Вопрос (16px, Regular)         │
│                                 │
│  ───────────────── (divider)    │
│                                 │
│  Ответ (14px, Regular)          │
│  (скрыт по умолчанию)           │
│                                 │
└─────────────────────────────────┘
```
- **Размер:** Ширина 100% - 32px, Высота мин. 120px
- **Фон:** White (#FFFFFF)
- **Тень:** elevation 2dp
- **Скругление:** 8px
- **Отступы внутри:** 16px
- **Состояния:**
  - Default: тень 2dp
  - Pressed: тень 4dp, scale 0.98
  - Disabled: opacity 50%

### 4.2 Кнопка (Button)
```
┌───────────────────┐
│   TEXT LABEL      │
└───────────────────┘
```
- **Высота:** 48px
- **Мин. ширина:** 64px
- **Скругление:** 24px (pill shape)
- **Отступы:** horizontal 24px, vertical 12px
- **Типографика:** 14px, Medium, UPPERCASE

**Варианты:**
| Тип | Фон | Текст | Обводка |
|-----|-----|-------|---------|
| Contained (Primary) | Primary main | White | none |
| Contained (Secondary) | Secondary main | White | none |
| Outlined | transparent | Primary main | 1px Primary main |
| Text | transparent | Primary main | none |

**Состояния:**
- Default: opacity 100%
- Hover: opacity 90%
- Pressed: opacity 70%, scale 0.98
- Disabled: opacity 38%

### 4.3 Поле ввода (TextField)
```
┌─────────────────────────────────┐
│ Label                           │
│ ─────────────────────────────── │
│ Input text                      │
└─────────────────────────────────┘
```
- **Высота:** 56px
- **Фон:** transparent
- **Нижняя граница:** 1px Neutral gray-400
- **Фокус:** 2px Primary main
- **Ошибка:** 2px Error main
- **Отступы:** 16px horizontal

### 4.4 Нижняя навигация (Bottom Navigation Bar)
```
┌─────────────────────────────────┐
│  🏠      📊      ⚙️            │
│ Home   Stats   Settings         │
└─────────────────────────────────┘
```
- **Высота:** 56px (без safe area)
- **Фон:** White (#FFFFFF)
- **Тень:** elevation 8dp
- **Иконки:** 24x24px
- **Текст:** 12px, Medium
- **Активный элемент:** Primary main
- **Неактивный:** Neutral gray-500

### 4.5 Модальное окно (Dialog)
```
┌─────────────────────────────────┐
│  Заголовок (H2)                 │
│                                 │
│  Текст описания (Body)          │
│                                 │
│  ─────────────────────────────  │
│                                 │
│  [ОТМЕНА]     [ПОДТВЕРДИТЬ]     │
└─────────────────────────────────┘
```
- **Фон:** White
- **Скругление:** 8px
- **Тень:** elevation 24dp
- **Макс. ширина:** 320px
- **Отступы:** 24px
- **Кнопки:** выровнены вправо

### 4.6 Прогресс-бар (Linear Progress)
```
┌─────────────────────────────────┐
│ ████████████░░░░░░░░░░ 67%     │
└─────────────────────────────────┘
```
- **Высота:** 4px
- **Фон трека:** Neutral gray-200
- **Заполнение:** Primary main
- **Скругление:** 2px

---

## 5. Иконки

### Библиотека
- **Material Icons** (стандарт для Flutter)
- Размер: 24x24px (крупные), 16x16px (мелкие)
- Цвет: наследуется от контекста или Neutral gray-600

### Используемые иконки
| Иконка | Название | Контекст |
|--------|----------|----------|
| 🏠 | home | Главная |
| 📊 | bar_chart | Статистика |
| ⚙️ | settings | Настройки |
| ➕ | add | Добавить |
| ✏️ | edit | Редактировать |
| 🗑️ | delete | Удалить |
| 📄 | file_copy | Копировать |
| ✅ | check_circle | Знаю |
| ❌ | cancel | Не знаю |
| 📚 | library_books | Набор |
| 🃏 | cards | Карточка |
| 🔙 | arrow_back | Назад |
| 📤 | upload | Экспорт |
| 📥 | download | Импорт |

---

## 6. Адаптивность

### Breakpoints
| Устройство | Ширина | Особенности |
|------------|--------|-------------|
| Phone (portrait) | 320-414px | Базовый layout |
| Phone (landscape) | 640-736px | Горизонтальная ориентация |
| Tablet | 768-1024px | Увеличенные отступы |

### Правила адаптивности
1. **Отступы по бокам:**
   - Phone: 16px
   - Tablet: 24px

2. **Списки:**
   - Phone: 1 колонка
   - Tablet: 2 колонки (для наборов)

3. **Модальные окна:**
   - Phone: 90% ширины
   - Tablet: фиксировано 400px

4. **Шрифты:**
   - Не масштабируются автоматически
   - Используются фиксированные размеры из типографики

---

## 7. Темы (светлая/тёмная)

### Светлая тема (Default)
```yaml
background: "#FAFAFA"
surface: "#FFFFFF"
text-primary: "#212121"
text-secondary: "#757575"
divider: "#E0E0E0"
```

### Тёмная тема (Future)
```yaml
background: "#121212"
surface: "#1E1E1E"
text-primary: "#FFFFFF"
text-secondary: "#B0B0B0"
divider: "#2C2C2C"
```

*Примечание: Тёмная тема не входит в MVP, добавляется в v1.1*

---

## 8. Анимации

### Длительность
| Тип | Длительность | Easing |
|-----|--------------|--------|
| Micro-interaction | 150ms | ease-in-out |
| Button press | 100ms | ease-out |
| Card flip | 300ms | ease-in-out |
| Page transition | 250ms | ease-out |
| Modal appear | 200ms | ease-out |

### Эффекты
- **Card Flip:** rotateY 0° → 180°
- **Button Press:** scale 1.0 → 0.98
- **Modal:** opacity 0 → 1, translateY 20px → 0
- **Progress:** width 0% → X%

---

## 9. Доступность (Accessibility)

### Требования
- **Контрастность:** минимум 4.5:1 для текста
- **Размер тач-целей:** мин. 48x48px
- **Поддержка TalkBack/VoiceOver:** все интерактивные элементы имеют labels
- **Навигация с клавиатуры:** логический порядок фокуса

### ARIA Labels (для Flutter Semantics)
```dart
Semantics(
  label: 'Карточка: Apple. Нажмите чтобы показать ответ',
  button: true,
  child: Card(...)
)
```
