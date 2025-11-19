// Структура данных приложения
let appData = {
    sets: [],
    syncToken: null // Для синхронизации между браузерами
};

// Текущий режим приложения
let currentView = 'sets'; // 'sets', 'cards', 'repetition'
let currentSetId = null;
let currentRepetitionSession = null;

// Инициализация приложения
document.addEventListener('DOMContentLoaded', () => {
    loadData();
    renderMainContent();
});

// Загрузка данных из localStorage
function loadData() {
    const savedData = localStorage.getItem('cardAppData');
    if (savedData) {
        appData = JSON.parse(savedData);
    } else {
        // Создаем пример данных, если данных нет
        appData = {
            sets: [
                {
                    id: generateId(),
                    title: 'Пример набора',
                    cards: [
                        {
                            id: generateId(),
                            question: 'Что такое smoke-тестирование?',
                            answer: 'Проверка основного функционала приложения на работоспособность.',
                            status: 'new' // 'new', 'known', 'unknown'
                        },
                        {
                            id: generateId(),
                            question: 'Что такое regression testing?',
                            answer: 'Проверка того, что новые изменения не сломали существующий функционал.',
                            status: 'new'
                        }
                    ]
                }
            ]
        };
        saveData();
    }
}

// Сохранение данных в localStorage
function saveData() {
    localStorage.setItem('cardAppData', JSON.stringify(appData));
}

// Функция экспорта данных
function exportData() {
    const dataStr = JSON.stringify(appData, null, 2);
    const dataUri = 'data:application/json;charset=utf-8,'+ encodeURIComponent(dataStr);
    
    const exportFileDefaultName = 'my-cards-data.json';
    
    const linkElement = document.createElement('a');
    linkElement.setAttribute('href', dataUri);
    linkElement.setAttribute('download', exportFileDefaultName);
    linkElement.click();
}

// Функция импорта данных
function importData() {
    const inputElement = document.createElement('input');
    inputElement.type = 'file';
    inputElement.accept = '.json';
    
    inputElement.onchange = function(event) {
        const file = event.target.files[0];
        const reader = new FileReader();
        
        reader.onload = function(e) {
            try {
                const importedData = JSON.parse(e.target.result);
                if (confirm('Вы уверены, что хотите заменить все текущие данные?')) {
                    appData = importedData;
                    saveData();
                    renderMainContent(); // Обновляем интерфейс
                    alert('Данные успешно импортированы!');
                }
            } catch (error) {
                alert('Ошибка при импорте данных: Неверный формат файла');
            }
        };
        
        reader.readAsText(file);
    };
    
    inputElement.click();
}

// Генерация уникального ID
function generateId() {
    return Date.now().toString(36) + Math.random().toString(36).substr(2);
}

// Основная функция рендеринга контента
function renderMainContent() {
    const mainContent = document.getElementById('main-content');
    
    switch(currentView) {
        case 'sets':
            renderSetsView(mainContent);
            break;
        case 'cards':
            renderCardsView(mainContent);
            break;
        case 'repetition':
            renderRepetitionView(mainContent);
            break;
    }
}

// Рендеринг главной страницы (список наборов)
function renderSetsView(container) {
    container.innerHTML = `
        <h2>Мои наборы карточек</h2>
        <div class="controls-container">
            <button class="btn btn-success" id="new-set-btn">+ Новый набор</button>
            <div class="import-export-buttons">
                <button class="btn btn-info" id="export-btn">📥 Экспорт данных</button>
                <button class="btn btn-info" id="import-btn">📤 Импорт данных</button>
            </div>
        </div>
        <div id="sets-list">
            ${appData.sets.map(set => {
                const totalCards = set.cards.length;
                const knownCards = set.cards.filter(card => card.status === 'known').length;
                const unknownCards = set.cards.filter(card => card.status === 'unknown').length;
                const newCards = set.cards.filter(card => card.status === 'new').length;
                
                return `
                    <div class="card-set" data-set-id="${set.id}">
                        <div class="card-set-info">
                            <div class="card-set-title">${set.title}</div>
                            <div class="card-set-stats">
                                <div class="card-set-count">${totalCards} карточек</div>
                                <div class="card-set-progress">Изучено: ${knownCards} | Не изучено: ${unknownCards} | Новых: ${newCards}</div>
                            </div>
                        </div>
                        <div class="card-set-actions">
                            <button class="btn btn-warning edit-set-btn" data-set-id="${set.id}">📝 Редактировать</button>
                            <button class="btn btn-success copy-set-btn" data-set-id="${set.id}">📄 Копировать</button>
                            <button class="btn btn-danger delete-set-btn" data-set-id="${set.id}">🗑️ Удалить</button>
                        </div>
                    </div>
                `;
            }).join('')}
        </div>
    `;
    
    // Добавляем обработчики событий
    document.getElementById('new-set-btn').addEventListener('click', showNewSetForm);
    document.getElementById('export-btn').addEventListener('click', exportData);
    document.getElementById('import-btn').addEventListener('click', importData);
    document.querySelectorAll('.edit-set-btn').forEach(btn => {
        btn.addEventListener('click', (e) => {
            const setId = e.target.getAttribute('data-set-id');
            showEditSetForm(setId);
        });
    });
    document.querySelectorAll('.copy-set-btn').forEach(btn => {
        btn.addEventListener('click', (e) => {
            const setId = e.target.getAttribute('data-set-id');
            copySet(setId);
        });
    });
    document.querySelectorAll('.delete-set-btn').forEach(btn => {
        btn.addEventListener('click', (e) => {
            const setId = e.target.getAttribute('data-set-id');
            deleteSet(setId);
        });
    });
    document.querySelectorAll('.card-set').forEach(cardSet => {
        cardSet.addEventListener('click', (e) => {
            // Проверяем, что клик не по кнопке
            if (!e.target.classList.contains('btn')) {
                const setId = cardSet.getAttribute('data-set-id');
                openSet(setId);
            }
        });
    });
}

// Показать форму для нового набора
function showNewSetForm() {
    const formHtml = `
        <h2>Новый набор</h2>
        <div class="form-group">
            <label for="set-title">Название набора:</label>
            <input type="text" id="set-title" placeholder="Введите название набора">
        </div>
        <div class="form-controls">
            <button class="btn btn-success" id="save-set-btn">Сохранить</button>
            <button class="btn back-btn" id="cancel-set-btn">Отмена</button>
        </div>
    `;
    
    document.getElementById('main-content').innerHTML = formHtml;
    
    document.getElementById('save-set-btn').addEventListener('click', () => {
        const title = document.getElementById('set-title').value.trim();
        if (title) {
            const newSet = {
                id: generateId(),
                title: title,
                cards: []
            };
            appData.sets.push(newSet);
            saveData();
            currentView = 'sets';
            renderMainContent();
        } else {
            alert('Пожалуйста, введите название набора');
        }
    });
    
    document.getElementById('cancel-set-btn').addEventListener('click', () => {
        currentView = 'sets';
        renderMainContent();
    });
}

// Показать форму для редактирования набора
function showEditSetForm(setId) {
    const set = appData.sets.find(s => s.id === setId);
    if (!set) return;
    
    const formHtml = `
        <h2>Редактировать набор</h2>
        <div class="form-group">
            <label for="edit-set-title">Название набора:</label>
            <input type="text" id="edit-set-title" value="${set.title}" placeholder="Введите название набора">
        </div>
        <div class="form-controls">
            <button class="btn btn-success" id="update-set-btn">Сохранить</button>
            <button class="btn back-btn" id="cancel-edit-set-btn">Отмена</button>
        </div>
    `;
    
    document.getElementById('main-content').innerHTML = formHtml;
    
    document.getElementById('update-set-btn').addEventListener('click', () => {
        const title = document.getElementById('edit-set-title').value.trim();
        if (title) {
            set.title = title;
            saveData();
            currentView = 'sets';
            renderMainContent();
        } else {
            alert('Пожалуйста, введите название набора');
        }
    });
    
    document.getElementById('cancel-edit-set-btn').addEventListener('click', () => {
        currentView = 'sets';
        renderMainContent();
    });
}

// Копировать набор
function copySet(setId) {
    const originalSet = appData.sets.find(s => s.id === setId);
    if (!originalSet) return;
    
    const newSet = {
        id: generateId(),
        title: `${originalSet.title} (копия)`,
        cards: originalSet.cards.map(card => ({
            id: generateId(),
            question: card.question,
            answer: card.answer
        }))
    };
    
    appData.sets.push(newSet);
    saveData();
    renderMainContent();
}

// Удалить набор
function deleteSet(setId) {
    if (confirm('Удалить набор и все его карточки?')) {
        appData.sets = appData.sets.filter(s => s.id !== setId);
        saveData();
        renderMainContent();
    }
}

// Открыть набор карточек
function openSet(setId) {
    currentSetId = setId;
    currentView = 'cards';
    renderMainContent();
}

// Рендеринг страницы набора (список карточек)
function renderCardsView(container) {
    const set = appData.sets.find(s => s.id === currentSetId);
    if (!set) {
        currentView = 'sets';
        renderMainContent();
        return;
    }
    
    // Подсчет статусов карточек
    const totalCards = set.cards.length;
    const knownCards = set.cards.filter(card => card.status === 'known').length;
    const unknownCards = set.cards.filter(card => card.status === 'unknown').length;
    const newCards = set.cards.filter(card => card.status === 'new').length;
    
    container.innerHTML = `
        <h2>${set.title}</h2>
        <div class="stats-container">
            <div class="stats">Всего: ${totalCards} | Изучено: ${knownCards} | Не изучено: ${unknownCards} | Новых: ${newCards}</div>
            <button class="btn print-btn" id="print-cards">🖨️ Печать</button>
        </div>
        <button class="btn back-btn" id="back-to-sets">← Назад к наборам</button>
        <button class="btn btn-success" id="new-card-btn">+ Новая карточка</button>
        <button class="btn btn-warning" id="start-repetition">Начать повторение</button>
        
        <div id="cards-list">
            ${set.cards.map(card => `
                <div class="card" data-card-id="${card.id}">
                    <div class="card-question">${card.question}</div>
                    <div class="card-answer">${card.answer}</div>
                    <div class="card-status">${getStatusIcon(card.status)}</div>
                    <div class="card-actions">
                        <button class="btn btn-warning show-answer-btn" data-card-id="${card.id}">Показать</button>
                        <button class="btn edit-card-btn" data-card-id="${card.id}">✏️ Редактировать</button>
                        <button class="btn btn-success copy-card-btn" data-card-id="${card.id}">📄 Копировать</button>
                        <button class="btn btn-danger delete-card-btn" data-card-id="${card.id}">🗑️ Удалить</button>
                    </div>
                </div>
            `).join('')}
        </div>
    `;
    
    // Добавляем обработчики событий
    document.getElementById('back-to-sets').addEventListener('click', () => {
        currentView = 'sets';
        currentSetId = null;
        renderMainContent();
    });
    
    document.getElementById('new-card-btn').addEventListener('click', showNewCardForm);
    
    document.getElementById('start-repetition').addEventListener('click', () => {
        currentView = 'repetition';
        renderMainContent();
    });
    
    document.getElementById('print-cards').addEventListener('click', () => {
        printCards(set);
    });
    
    document.querySelectorAll('.show-answer-btn').forEach(btn => {
        btn.addEventListener('click', (e) => {
            const cardId = e.target.getAttribute('data-card-id');
            const cardElement = document.querySelector(`.card[data-card-id="${cardId}"]`);
            cardElement.classList.toggle('answer-shown');
            e.target.textContent = cardElement.classList.contains('answer-shown') ? 'Скрыть' : 'Показать';
        });
    });
    
    document.querySelectorAll('.edit-card-btn').forEach(btn => {
        btn.addEventListener('click', (e) => {
            const cardId = e.target.getAttribute('data-card-id');
            showEditCardForm(cardId);
        });
    });
    
    document.querySelectorAll('.copy-card-btn').forEach(btn => {
        btn.addEventListener('click', (e) => {
            const cardId = e.target.getAttribute('data-card-id');
            copyCard(cardId);
        });
    });
    
    document.querySelectorAll('.delete-card-btn').forEach(btn => {
        btn.addEventListener('click', (e) => {
            const cardId = e.target.getAttribute('data-card-id');
            deleteCard(cardId);
        });
    });
}

// Функция для получения иконки статуса
function getStatusIcon(status) {
    switch(status) {
        case 'known': return '✅';
        case 'unknown': return '❌';
        case 'new': return '🆕';
        default: return '❓';
    }
}

// Функция печати карточек
function printCards(set) {
    // Создаем новое окно для печати
    const printWindow = window.open('', '_blank');
    printWindow.document.write(`
        <html>
            <head>
                <title>Печать карточек - ${set.title}</title>
                <style>
                    body { font-family: Arial, sans-serif; margin: 20px; }
                    .card { margin: 20px 0; padding: 15px; border: 1px solid #ccc; }
                    .question { font-weight: bold; margin-bottom: 10px; }
                    .answer { margin-top: 10px; display: none; }
                    @media print {
                        .page-break { page-break-before: always; }
                    }
                </style>
            </head>
            <body>
                <h1>Карточки: ${set.title}</h1>
                ${set.cards.map(card => `
                    <div class="card">
                        <div class="question">${card.question}</div>
                    </div>
                    <div class="page-break"></div>
                `).join('')}
            </body>
        </html>
    `);
    printWindow.document.close();
    printWindow.print();
}

// Показать форму для новой карточки
function showNewCardForm() {
    const formHtml = `
        <h2>Новая карточка</h2>
        <button class="btn back-btn" id="back-to-cards">← Назад к карточкам</button>
        
        <div class="form-group">
            <label for="card-question">Вопрос:</label>
            <textarea id="card-question" rows="3" placeholder="Введите вопрос"></textarea>
        </div>
        
        <div class="form-group">
            <label for="card-answer">Ответ:</label>
            <textarea id="card-answer" rows="3" placeholder="Введите ответ"></textarea>
        </div>
        
        <div class="form-controls">
            <button class="btn btn-success" id="save-card-btn">Сохранить</button>
            <button class="btn back-btn" id="cancel-card-btn">Отмена</button>
        </div>
    `;
    
    document.getElementById('main-content').innerHTML = formHtml;
    
    document.getElementById('back-to-cards').addEventListener('click', () => {
        currentView = 'cards';
        renderMainContent();
    });
    
    document.getElementById('save-card-btn').addEventListener('click', () => {
        const question = document.getElementById('card-question').value.trim();
        const answer = document.getElementById('card-answer').value.trim();
        
        if (question && answer) {
            const set = appData.sets.find(s => s.id === currentSetId);
            if (set) {
                const newCard = {
                    id: generateId(),
                    question: question,
                    answer: answer,
                    status: 'new'
                };
                set.cards.push(newCard);
                saveData();
                currentView = 'cards';
                renderMainContent();
            }
        } else {
            alert('Пожалуйста, заполните оба поля: вопрос и ответ');
        }
    });
    
    document.getElementById('cancel-card-btn').addEventListener('click', () => {
        currentView = 'cards';
        renderMainContent();
    });
}

// Показать форму для редактирования карточки
function showEditCardForm(cardId) {
    const set = appData.sets.find(s => s.id === currentSetId);
    if (!set) return;
    
    const card = set.cards.find(c => c.id === cardId);
    if (!card) return;
    
    const formHtml = `
        <h2>Редактировать карточку</h2>
        <button class="btn back-btn" id="back-to-cards">← Назад к карточкам</button>
        
        <div class="form-group">
            <label for="edit-card-question">Вопрос:</label>
            <textarea id="edit-card-question" rows="3">${card.question}</textarea>
        </div>
        
        <div class="form-group">
            <label for="edit-card-answer">Ответ:</label>
            <textarea id="edit-card-answer" rows="3">${card.answer}</textarea>
        </div>
        
        <div class="form-controls">
            <button class="btn btn-success" id="update-card-btn">Сохранить</button>
            <button class="btn back-btn" id="cancel-edit-card-btn">Отмена</button>
        </div>
    `;
    
    document.getElementById('main-content').innerHTML = formHtml;
    
    document.getElementById('back-to-cards').addEventListener('click', () => {
        currentView = 'cards';
        renderMainContent();
    });
    
    document.getElementById('update-card-btn').addEventListener('click', () => {
        const question = document.getElementById('edit-card-question').value.trim();
        const answer = document.getElementById('edit-card-answer').value.trim();
        
        if (question && answer) {
            card.question = question;
            card.answer = answer;
            saveData();
            currentView = 'cards';
            renderMainContent();
        } else {
            alert('Пожалуйста, заполните оба поля: вопрос и ответ');
        }
    });
    
    document.getElementById('cancel-edit-card-btn').addEventListener('click', () => {
        currentView = 'cards';
        renderMainContent();
    });
}

// Копировать карточку
function copyCard(cardId) {
    const set = appData.sets.find(s => s.id === currentSetId);
    if (!set) return;
    
    const originalCard = set.cards.find(c => c.id === cardId);
    if (!originalCard) return;
    
    const newCard = {
        id: generateId(),
        question: originalCard.question,
        answer: originalCard.answer,
        status: originalCard.status || 'new'
    };
    
    set.cards.push(newCard);
    saveData();
    renderMainContent();
}

// Удалить карточку
function deleteCard(cardId) {
    if (confirm('Удалить карточку?')) {
        const set = appData.sets.find(s => s.id === currentSetId);
        if (set) {
            set.cards = set.cards.filter(c => c.id !== cardId);
            saveData();
            renderMainContent();
        }
    }
}

// Рендеринг режима повторения
function renderRepetitionView(container) {
    const set = appData.sets.find(s => s.id === currentSetId);
    if (!set) {
        currentView = 'cards';
        renderMainContent();
        return;
    }
    
    // Берем только карточки со статусом 'new' или 'unknown' для повторения
    const cardsToRepeat = set.cards.filter(card => card.status === 'new' || card.status === 'unknown');
    
    if (cardsToRepeat.length === 0) {
        container.innerHTML = `
            <h2>Повторение: ${set.title}</h2>
            <button class="btn back-btn" id="back-to-cards">← Назад к карточкам</button>
            <div class="repetition-container">
                <div class="repetition-message">
                    <h3>Нет карточек для повторения!</h3>
                    <p>Все карточки в этом наборе отмечены как изученные.</p>
                </div>
            </div>
        `;
        
        document.getElementById('back-to-cards').addEventListener('click', () => {
            currentView = 'cards';
            renderMainContent();
        });
        return;
    }
    
    // Подготовим сессию повторения
    currentRepetitionSession = {
        cards: [...cardsToRepeat], // копия карточек для повторения
        currentIndex: 0,
        knownCount: 0,
        totalCount: cardsToRepeat.length,
        originalSetId: currentSetId
    };
    
    // Перемешаем карточки
    shuffleArray(currentRepetitionSession.cards);
    
    showNextRepetitionCard(container);
}

// Показать следующую карточку в режиме повторения
function showNextRepetitionCard(container) {
    if (currentRepetitionSession.currentIndex >= currentRepetitionSession.cards.length) {
        // Все карточки пройдены
        showRepetitionResult(container);
        return;
    }
    
    const currentCard = currentRepetitionSession.cards[currentRepetitionSession.currentIndex];
    
    container.innerHTML = `
        <h2>Повторение: ${currentCard.question}</h2>
        <button class="btn back-btn" id="back-to-cards-from-rep">← Назад к карточкам</button>
        
        <div class="repetition-container">
            <div class="repetition-card">
                <div class="repetition-question">${currentCard.question}</div>
                <button class="btn btn-warning" id="show-answer-rep">Показать ответ</button>
                <div class="repetition-answer" id="repetition-answer">${currentCard.answer}</div>
                <div class="repetition-controls" id="repetition-controls" style="display: none;">
                    <button class="btn btn-success" id="know-btn">✅ Знаю</button>
                    <button class="btn btn-danger" id="dont-know-btn">❌ Не знаю</button>
                </div>
            </div>
        </div>
    `;
    
    document.getElementById('back-to-cards-from-rep').addEventListener('click', () => {
        currentView = 'cards';
        currentRepetitionSession = null;
        renderMainContent();
    });
    
    document.getElementById('show-answer-rep').addEventListener('click', () => {
        document.getElementById('repetition-answer').classList.add('shown');
        document.getElementById('repetition-controls').style.display = 'block';
        document.getElementById('show-answer-rep').style.display = 'none';
    });
    
    document.getElementById('know-btn').addEventListener('click', () => {
        // Обновляем статус карточки на 'known'
        const currentCard = currentRepetitionSession.cards[currentRepetitionSession.currentIndex];
        updateCardStatus(currentCard.id, 'known');
        
        currentRepetitionSession.knownCount++;
        currentRepetitionSession.currentIndex++;
        showNextRepetitionCard(container);
    });
    
    document.getElementById('dont-know-btn').addEventListener('click', () => {
        // Обновляем статус карточки на 'unknown'
        const currentCard = currentRepetitionSession.cards[currentRepetitionSession.currentIndex];
        updateCardStatus(currentCard.id, 'unknown');
        
        // Для простоты, карточка остается в сессии, просто переходим к следующей
        currentRepetitionSession.currentIndex++;
        showNextRepetitionCard(container);
    });
}

// Показать результаты повторения
function showRepetitionResult(container) {
    container.innerHTML = `
        <h2>Результаты повторения</h2>
        <button class="btn back-btn" id="back-to-cards-result">← Назад к карточкам</button>
        
        <div class="repetition-result">
            <h3>Повторение завершено!</h3>
            <p>Повторено: ${currentRepetitionSession.knownCount} из ${currentRepetitionSession.totalCount} карточек</p>
        </div>
    `;
    
    document.getElementById('back-to-cards-result').addEventListener('click', () => {
        currentView = 'cards';
        currentRepetitionSession = null;
        renderMainContent();
    });
}

// Вспомогательная функция для перемешивания массива
function shuffleArray(array) {
    for (let i = array.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [array[i], array[j]] = [array[j], array[i]];
    }
}

// Функция для обновления статуса карточки
function updateCardStatus(cardId, status) {
    for (const set of appData.sets) {
        const card = set.cards.find(c => c.id === cardId);
        if (card) {
            card.status = status;
            saveData(); // Сохраняем изменения
            break;
        }
    }
}