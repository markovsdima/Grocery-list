# Название проекта: Grocery-list-IOS

## Автор: Дмитрий Марковский

Date1: Dec, 13  
Date2: Dec, 22  
Telegram: [https://t.me/markovsdima]  
GitHub: [https://github.com/AS115522/Grocery-list-IOS/pull/1]  

## Общая информация о проекте

- Платформа: iPhone, iPad, Mac, aVision
- Архитектура: MVVM реализован правильно
- Используемые фреймворки: SwiftUI, Swift Data
- Минимальная iOS: 17.0

## Оценка по критериям

### 1. Архитектура и дизайн паттерны (0–4 балла)

- Оценка: 4
- Комментарий:
- Структура проекта (папки, слои приложения):
  - да;
- Соблюдение MVVM: отделение логики от UI, наличие ViewModel, читаемый и тестируемый код:
  - да, но с недостатками;
- Наличие вспомогательных модулей (например, сервисный слой для работы с данными, роутеры/координаторы для навигации):
  - да;
- Применение дизайна и шаблонов проектирования (например, Dependency Injection, Observer, Protocol-Oriented Programming):
  - да;
- Плюсы:
  - внедрение зависимостей через инит;
- Минусы:
  - конвертация моделей во вью модели;
  - навигация не вынесена из вьюшек;

### 2. Использование языка Swift (0–4 балла)

- Оценка: 4
- Комментарии:
  - Использование мощных конструкций Swift или "сахарка" Swift:
    - нет;
  - Чистота и понятность кода, следование Swift API Design Guidelines:
    - да;
  - Правильное использование Swift Concurrency (если применимо), async/await, Combine:
    - да, но только один вызов;
    - есть использование gcd;
  - Плюсы:
  - Минусы:
    - не весь "сахар" языка использован, есть место для сокращения записи (например, if после guard)

### 3. Стилистика и качество кода (0–4 балла)

- Оценка: 4
- Комментарии:
  - Согласованность стиля: camelCase, отступы, комментарии:
    - да;
  - Понятные имена переменных и методов:
    - да;
  - Отсутствие лишнего дублирования кода:
    - дублирование отсутствует;
  - Документирование ключевых компонентов (комментарии, MARK, документация):
    - да;
  - Плюсы:
  - Минусы:

### 4. Техническая реализация функционала по ТЗ

#### Блок “Списки”

- Создание, переименование, удаление списков (UI/UX + тех. аспекты):
  - да
- Использование модальных окон для ввода данных:
  - да
- Валидация ввода: проверка дубликатов, пустой строки
  - валидация есть, но пробел пропускает;
- UI-компоненты:
  - подходящие;
  - есть кастомный поиск;
- Навигация и архитектура: правильно ли разделены Views и ViewModel?
  - разделены правильно;
  - вьюхи слегка большеваты, можно было разбить посильнее;
- Плюсы:
- Минусы:

#### Блок “Товары”

- Добавление, редактирование, удаление товара
  - да;
- Реализация валидации, проверка дубликатов, пустой строки
  - валидация есть, но пробел пропускает;
- UI-компоненты:
  - подходящие;
  - есть и кастомный поиск;
- Отметка купленного: использование State (в SwiftUI)
  - да
- Плюсы:
  - настроен экспорт "поделиться";
- Минусы:
  - выделение выбранного нажатием не по всей строке;
  
##### Сортировка и организация данных

- Сортировка по алфавиту:
  - да;
- Ручная сортировка:
  - да;
- Плюсы:
  - сортируется не столько список товаров, но и список листов;
- Минусы:

##### Сохранение данных (Core Data)

- Корректная настройка Core Data:
  - да;
- Правильная работа с контекстами:
  - да;
- Плюсы:
  - использована SwiftData;
- Минусы:

##### Дополнительная функциональность

- Тёмная/светлая тема:
  - реализовано;
- Дублирование списка, корректность операции копирования:
  - да, но с недостатками
- Проверить, нет ли несогласованностей в UI после копирования
  - при копирования списка с отмеченными айтемами, отметка тоже копируется, но счётчик равен нулю;
- Плюсы:
  - интуитивно;
- Минусы:

### 5. Производительность и оптимизации (0–4 балла)

- Оценка: 4
- Комментарии:
  - Время запуска приложения:
    - всё норм;
  - Отзывчивость UI при добавлении, редактировании и сортировке:
    - всё норм;
  - Оптимизация Core Data запросов, lazy loading изображений (если есть)
    - нет;
  - Использование Background Threads, GCD, async/await для тяжёлых операций:
    - нет;
- Плюсы:
- Минусы:

### 6. UI/UX и соответствие HIG

- Соответствие Human Interface Guidelines
  - да;
- Адаптация под разные устройства, размер экрана, разные темы
  - есть визуальные недостатки на мелких экранах;
- Интуитивная навигация, удобный пользовательский опыт:
  - да;
- Проверить наличие анимаций, плавности переходов:
  - да;
- Плюсы:
- Минусы:
  - при создании списка кидает на главный экран, но не в сам список;
  - кнопка назад срабатывает не целиком, а только картинка со стрелочкой влево;
  - экран добавления товара открывается не весь экран, при этом большая часть доступного места пустая;
  - при открытии клавиатуры подскроливает интерфейс позади активного окна и это заметно;

### 7. Стабильность и тестирование

- Unit-тесты, UI-тесты (наличие, качество, покрытие)
  - нет;
- Отсутствие вылетов, проверка edge-кейсов
  - стабильно;
- Обработка ошибок и исключений (ошибки сети, пустые данные, некорректный ввод)
  - да;
- Плюсы:
- Минусы:

## Итоговая оценка

- Применимость общего результата: 3
- Архитектура: 4
- Язык Swift: 4
- Стилистика кода: 4
- Техническая реализация функциональности: 4
- Производительность: 4
- UI/UX: 4
- Стабильность: 4
- Тесты: 0

**Общая итоговая оценка:** 3+4+4+4+4+4+4+4+0 = 31

**Замечания и комментарии:**

- на мелком экране верхнюю часть экрана создания списка выдавливает на статус бар;
- нет иконки приложения;

**Субъективно:**

- приложение очень понравилось, сам бы пользовался;

