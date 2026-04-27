# 📚 Repository Паттерн в Проекте (Spring Data JPA)

---

## 🎯 Что такое Repository?

**Repository** - это интерфейс (как посредник) между приложением и базой данных.

Вместо того, чтобы писать SQL запросы вручную, Repository **автоматически** создает методы для работы с данными.

---

## 📊 Архитектура: Как это работает

```
┌─────────────────────────────────────────┐
│  Controller                             │
│  (обрабатывает HTTP запросы)            │
└────────────────┬────────────────────────┘
                 │ Использует
                 ▼
┌─────────────────────────────────────────┐
│  Service                                │
│  (бизнес логика)                        │
└────────────────┬────────────────────────┘
                 │ Использует
                 ▼
┌─────────────────────────────────────────┐
│  Repository (ЭТО)                       │
│  (общение с БД)                         │
└────────────────┬────────────────────────┘
                 │ SQL запросы
                 ▼
┌─────────────────────────────────────────┐
│  Database (H2)                          │
│  (хранит данные)                        │
└─────────────────────────────────────────┘
```

---

## 🗂️ Repository в Проекте

### **1. MessageRepository** - Хранит сообщения чатов

**Файл**: `aiapp/src/main/java/.../repository/MessageRepository.java`

```java
public interface MessageRepository extends JpaRepository<Message, Long> {
}
```

**Что это значит:**
- `MessageRepository` - интерфейс для работы с таблицей Message
- `extends JpaRepository<Message, Long>` - наследует методы из Spring:
  - `Message` - тип данных (сообщение)
  - `Long` - тип ID (первичный ключ)

**Автоматические методы (даром!):**
```
save(message)              → INSERT в БД
findById(1)               → SELECT по ID
findAll()                 → SELECT все
delete(message)           → DELETE
update(message)           → UPDATE
```

**Когда используется:**
- Когда пользователь задает вопрос → сохраняется в БД
- Когда AI дает ответ → сохраняется в БД
- Когда запрашивается история → fetches из БД

**Пример использования в AIService:**
```java
Message userMessage = new Message("user", "Привет!");
messageRepository.save(userMessage);  // ← Автоматический INSERT

Message aiMessage = new Message("ai", "Ответ!");
messageRepository.save(aiMessage);    // ← Автоматический INSERT

List<Message> history = messageRepository.findAll();  // ← SELECT все
```

---

### **2. UserRepository** - Хранит пользователей

**Файл**: `aiapp/src/main/java/.../repository/UserRepository.java`

```java
public interface UserRepository extends JpaRepository<User, Long>{
}
```

**Для чего:**
- Сохранение информации о пользователях
- Проверка пользователей при авторизации
- История действий пользователя

**Основные методы:**
```
userRepository.save(newUser)         → Создать пользователя
userRepository.findById(userId)      → Получить по ID
userRepository.findAll()             → Все пользователи
userRepository.delete(user)          → Удалить пользователя
```

---

### **3. ScheduleRepository** - Хранит расписание

**Файл**: `aiapp/src/main/java/.../repository/ScheduleRepository.java`

```java
public interface ScheduleRepository extends JpaRepository<Schedule, Long>{
    List<Schedule> findByUserId(Long userId);  // ← КАСТОМНЫЙ метод
}
```

**Особенность:** `findByUserId()` - это **КАСТОМНЫЙ метод** (написан вручную)

**Что он делает:**
```sql
-- Spring автоматически генерирует SQL:
SELECT * FROM schedule WHERE user_id = ?
```

**Пример:**
```java
// Получить все расписания для пользователя ID=5
List<Schedule> userSchedules = scheduleRepository.findByUserId(5L);
```

---

## 📋 Entity (Данные) ↔️ Repository (Доступ к данным)

### **Message Entity:**
```java
@Entity              // ← Это таблица в БД
public class Message {
    @Id
    @GeneratedValue  // ← Автоматический ID (AUTO INCREMENT)
    private Long id;
    
    private String role;  // ← Колонка "role" (user, ai)
    private String text;  // ← Колонка "text" (содержание)
}
```

**Таблица в БД выглядит так:**
```
MESSAGE
┌────┬──────┬──────────────────┐
│ ID │ ROLE │ TEXT             │
├────┼──────┼──────────────────┤
│ 1  │ user │ "Привет"         │
│ 2  │ ai   │ "Привет! Как дел?"
│ 3  │ user │ "Хорошо, спасибо" │
└────┴──────┴──────────────────┘
```

**MessageRepository автоматически:**
- Создает эту таблицу
- Генерирует SQL для INSERT/SELECT/UPDATE/DELETE
- Преобразует результаты в объекты Java

---

## 🔄 Полный пример: Как Repository работает

### **Сценарий: Пользователь спрашивает AI**

```
1. User sends request:
   POST /api/ask
   {"text": "What is AI?"}

2. AIController receives it:
   @PostMapping("/ask")
   public AnswerDTO ask(@RequestBody QuestionDTO question) {
       return new AnswerDTO(aiService.getAnswer(question.text));
   }

3. AIService uses Repository:
   public String getAnswer(String text) {
       // Сохрани вопрос пользователя
       Message userMessage = new Message("user", text);
       messageRepository.save(userMessage);  // ← INSERT в Message table
       
       // Получи ответ от Ollama
       String response = ollamaService.askAI(text);
       
       // Сохрани ответ AI
       Message aiMessage = new Message("ai", response);
       messageRepository.save(aiMessage);  // ← INSERT в Message table
       
       return response;
   }

4. Database stores:
   MESSAGE
   ┌────┬──────┬────────────────┐
   │ ID │ ROLE │ TEXT           │
   ├────┼──────┼────────────────┤
   │ 1  │ user │ "What is AI?"  │
   │ 2  │ ai   │ "AI is..."     │
   └────┴──────┴────────────────┘

5. Next time user asks for history:
   GET /api/messages
   messageRepository.findAll()  // ← SELECT * FROM message
   
   Response: [
       {"id": 1, "role": "user", "text": "What is AI?"},
       {"id": 2, "role": "ai", "text": "AI is..."}
   ]
```

---

## 💡 Зачем Repository нужны?

| Без Repository | С Repository |
|---|---|
| Писать SQL вручную | Автоматические методы |
| `"SELECT * FROM message WHERE id = 1"` | `messageRepository.findById(1)` |
| Преобразовывать результаты вручную | Автоматическое преобразование в объекты |
| Следить за типами данных | Spring проверяет типы |
| Риск SQL ошибок | Меньше ошибок |

**Результат**: Код чище, быстрее писать, меньше багов ✅

---

## 🔍 Как Spring Работает с Repository

### **Behind the Scenes:**

Когда ты пишешь:
```java
public interface MessageRepository extends JpaRepository<Message, Long> {
}
```

Spring **автоматически** создает реализацию:
```java
public class MessageRepositoryImpl implements MessageRepository {
    
    public void save(Message message) {
        // Генерирует SQL: INSERT INTO message (role, text) VALUES (?, ?)
        // Сохраняет в БД
    }
    
    public Message findById(Long id) {
        // Генерирует SQL: SELECT * FROM message WHERE id = ?
        // Возвращает объект Message
    }
    
    public List<Message> findAll() {
        // Генерирует SQL: SELECT * FROM message
        // Возвращает List<Message>
    }
    
    // и еще 20+ методов...
}
```

**Ты не пишешь эту реализацию - Spring создает сам!** 🎉

---

## 📊 Встроенные методы JpaRepository

Все эти методы доступны **автоматически** для каждого Repository:

```java
// СОЗДАНИЕ
messageRepository.save(message)               // Сохранить/обновить
messageRepository.saveAll(messages)           // Сохранить несколько

// ПОЛУЧЕНИЕ
messageRepository.findById(1)                 // По ID
messageRepository.findAll()                   // Все
messageRepository.findAll(pageRequest)        // С пагинацией

// УДАЛЕНИЕ
messageRepository.delete(message)             // Удалить один
messageRepository.deleteById(1)               // Удалить по ID
messageRepository.deleteAll()                 // Удалить все

// ПРОВЕРКА
messageRepository.existsById(1)               // Существует ли?
messageRepository.count()                     // Количество

// СОРТИРОВКА
messageRepository.findAll(Sort.by("role"))    // Отсортировать
```

---

## 🎯 Кастомные Методы (Как в ScheduleRepository)

Если встроенных методов не хватает, можно добавить свои:

```java
public interface ScheduleRepository extends JpaRepository<Schedule, Long> {
    
    // Spring автоматически генерирует SQL:
    // SELECT * FROM schedule WHERE user_id = ?
    List<Schedule> findByUserId(Long userId);
    
    // SELECT * FROM schedule WHERE created_date > ? ORDER BY created_date DESC
    List<Schedule> findByCreatedDateAfterOrderByCreatedDateDesc(Date date);
    
    // SELECT COUNT(*) FROM schedule WHERE user_id = ?
    long countByUserId(Long userId);
    
    // SELECT * FROM schedule WHERE title LIKE ? AND user_id = ?
    List<Schedule> findByTitleContainsAndUserId(String title, Long userId);
}
```

**Spring умный - понимает названия методов и генерирует SQL! 🧠**

---

## 🗄️ Таблицы БД в Проекте

```sql
-- H2 создает 3 таблицы автоматически:

CREATE TABLE MESSAGE (
    ID LONG PRIMARY KEY AUTO_INCREMENT,
    ROLE VARCHAR(255),
    TEXT CLOB
);

CREATE TABLE USER (
    ID LONG PRIMARY KEY AUTO_INCREMENT,
    EMAIL VARCHAR(255),
    NAME VARCHAR(255),
    ...
);

CREATE TABLE SCHEDULE (
    ID LONG PRIMARY KEY AUTO_INCREMENT,
    USER_ID LONG,
    TITLE VARCHAR(255),
    CREATED_DATE TIMESTAMP,
    FOREIGN KEY (USER_ID) REFERENCES USER(ID)
);
```

**H2 создает таблицы АВТОМАТИЧЕСКИ из Entity классов!** ✅

---

## 🔗 Связь: Controller → Service → Repository

```
AIController
├─ askAI()
│  └─ Uses AIService.getAnswer()
│
AIService
├─ getAnswer()
│  ├─ messageRepository.save(userMessage)    ← Сохрани вопрос
│  ├─ ollamaService.askAI(text)              ← Получи ответ
│  ├─ messageRepository.save(aiMessage)      ← Сохрани ответ
│  └─ return response
│
MessageRepository (автоматически)
├─ save()
├─ findAll()
├─ findById()
└─ ... 20+ методов
```

---

## 📝 Практический Пример: Получить историю

```java
// В Controller
@GetMapping("/messages")
public List<MessageDTO> getHistory() {
    return messageRepository.findAll();  // Получи все сообщения
}

// H2 выполняет:
// SELECT * FROM MESSAGE

// Результат:
[
    {"id": 1, "role": "user", "text": "What is AI?"},
    {"id": 2, "role": "ai", "text": "AI is an acronym..."},
    {"id": 3, "role": "user", "text": "Can you explain ML?"},
    {"id": 4, "role": "ai", "text": "ML stands for..."}
]
```

---

## ✅ Итоги: Repository для чего?

1. **Простота** - Не писать SQL вручную
2. **Безопасность** - SQL injection защита
3. **Продуктивность** - Одна строка вместо 10
4. **Тестирование** - Легко мокировать
5. **Консистентность** - Одинаковый код везде
6. **Type-safety** - Spring проверяет типы

---

## 🚀 Резюме

| Файл | Назначение | Используется где |
|------|-----------|------------------|
| **MessageRepository** | Сохранение чатов | AIService |
| **UserRepository** | Сохранение пользователей | UserService (если есть) |
| **ScheduleRepository** | Сохранение расписания | ScheduleService (если нужно) |

**Все Repository работают с H2 in-memory базой (теряются при перезагрузке)**

Если нужна **постоянная БД** - замени H2 на PostgreSQL/MySQL в pom.xml! 💾
