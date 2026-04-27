# 📌 Repository Cheat Sheet

## Что такое Repository? (Быстро)

**Repository** = Интерфейс для работы с БД

```
Без Repository:        С Repository:
════════════════════   ══════════════════════
String sql = "SELECT   messageRepository
* FROM message";       .findById(1)
ResultSet rs = 
conn.executeQuery(sql);
Message m = new 
Message(...);          ← Одна строка!
```

---

## 3 Repository в Проекте

### 1. MessageRepository
```java
public interface MessageRepository extends JpaRepository<Message, Long> {
}

// Сохраняет чаты (вопросы и ответы)
messageRepository.save(message);      // INSERT
messageRepository.findAll();          // SELECT все
```

### 2. UserRepository  
```java
public interface UserRepository extends JpaRepository<User, Long> {
}

// Сохраняет пользователей
userRepository.save(user);            // INSERT
userRepository.findById(userId);      // SELECT по ID
```

### 3. ScheduleRepository
```java
public interface ScheduleRepository extends JpaRepository<Schedule, Long> {
    List<Schedule> findByUserId(Long userId);  // ← КАСТОМНЫЙ!
}

// Сохраняет расписание
scheduleRepository.findByUserId(5);   // SELECT WHERE user_id = 5
```

---

## Встроенные Методы (Даром!)

```java
// SAVE
repo.save(object)                    // INSERT / UPDATE
repo.saveAll(list)                   // Multiple INSERT

// GET
repo.findById(1)                     // SELECT WHERE id = 1
repo.findAll()                       // SELECT ALL
repo.getById(1)                      // Like findById

// DELETE
repo.delete(object)                  // DELETE
repo.deleteById(1)                   // DELETE WHERE id = 1
repo.deleteAll()                     // DELETE ALL

// CHECK
repo.existsById(1)                   // EXISTS?
repo.count()                         // COUNT

// SORT
repo.findAll(Sort.by("name"))        // ORDER BY
```

---

## Entity → Repository → Database

```
Message Entity          MessageRepository      H2 Database
═══════════════════════════════════════════════════════════
@Entity                 extends              CREATE TABLE
public Message {        JpaRepository         MESSAGE (
  @Id                   <Message, Long>       ID AUTO_INCREMENT,
  Long id;                                    ROLE VARCHAR,
  
  String role;          save()          →    INSERT
  String text;          findAll()       →    SELECT
}                       delete()        →    DELETE
```

---

## Кастомные Методы (findByUserId)

```java
// Spring ПОНИМАЕТ названия методов:

findByUserId(id)
    ↓
SELECT * FROM schedule WHERE user_id = ?

findByTitleAndUserId(title, id)
    ↓
SELECT * FROM schedule WHERE title = ? AND user_id = ?

findByCreatedDateAfter(date)
    ↓
SELECT * FROM schedule WHERE created_date > ?

countByUserId(id)
    ↓
SELECT COUNT(*) FROM schedule WHERE user_id = ?
```

---

## Как Это Работает?

```
1. Ты пишешь интерфейс:
   public interface MessageRepository 
       extends JpaRepository<Message, Long> { }

2. Spring генерирует реализацию автоматически:
   public class MessageRepositoryImpl {
       public void save(Message m) { /* SQL */ }
       public Message findById(Long id) { /* SQL */ }
       public List<Message> findAll() { /* SQL */ }
       // + 20 других методов
   }

3. Ты используешь:
   messageRepository.save(msg);
   messageRepository.findAll();
   
4. Spring выполняет SQL в H2:
   INSERT INTO message (role, text) VALUES (...)
   SELECT * FROM message
```

---

## Полный Пример: Сохрани и Получи

```java
// Controller получил запрос
@PostMapping("/ask")
public void ask(String question) {
    
    // Service использует Repository
    Message userMsg = new Message("user", question);
    messageRepository.save(userMsg);  // ← СОХРАНИТЬ
    
    String answer = ollama.getAnswer(question);
    Message aiMsg = new Message("ai", answer);
    messageRepository.save(aiMsg);    // ← СОХРАНИТЬ
}

// Later: История всех сообщений
@GetMapping("/history")
public List<Message> getHistory() {
    return messageRepository.findAll();  // ← ПОЛУЧИТЬ ВСЕ
}
```

---

## Database (H2 In-Memory)

```sql
-- Spring создает таблицы АВТОМАТИЧЕСКИ

-- MESSAGE table (для messageRepository)
MESSAGE
┌────┬──────┬─────────────────────┐
│ ID │ ROLE │ TEXT                │
├────┼──────┼─────────────────────┤
│ 1  │ user │ "What is AI?"       │
│ 2  │ ai   │ "AI is artificial..." │
└────┴──────┴─────────────────────┘

-- USER table (для userRepository)
USER
┌────┬──────────────┬──────────┐
│ ID │ EMAIL        │ NAME     │
├────┼──────────────┼──────────┤
│ 1  │ user@mail.ru │ "John"   │
└────┴──────────────┴──────────┘

-- SCHEDULE table (для scheduleRepository)
SCHEDULE
┌────┬─────────┬──────────┬──────────────┐
│ ID │ USER_ID │ TITLE    │ CREATED_DATE │
├────┼─────────┼──────────┼──────────────┤
│ 1  │ 1       │ "Meeting"│ 2025-04-23   │
└────┴─────────┴──────────┴──────────────┘
```

---

## Почему Repository Нужны?

| Проблема | Решение |
|----------|---------|
| 🚫 Писать SQL вручную | ✅ Автоматические методы |
| 🚫 SQL ошибки | ✅ Type-safe код |
| 🚫 Преобразовывать результаты | ✅ Автоматическое преобразование |
| 🚫 SQL injection | ✅ Безопасная параметризация |
| 🚫 Много кода | ✅ Одна строка кода |

---

## Где Repository Используются?

```
AIService
    ├─ messageRepository.save(userMessage)
    ├─ messageRepository.save(aiMessage)
    └─ messageRepository.findAll() (в истории)

UserService
    ├─ userRepository.save(user)
    ├─ userRepository.findById(id)
    └─ userRepository.findAll()

ScheduleService
    ├─ scheduleRepository.save(schedule)
    ├─ scheduleRepository.findByUserId(userId)
    └─ scheduleRepository.findAll()
```

---

## Repository == ORM (Object-Relational Mapping)

```
Java Objects          ←→        Database Tables
═════════════════════════════════════════════════
Message object                 MESSAGE table
├─ id                         ├─ ID
├─ role                       ├─ ROLE
├─ text                       └─ TEXT

User object                    USER table
├─ id                         ├─ ID
├─ email                      ├─ EMAIL
└─ name                       └─ NAME
```

**Repository автоматически преобразует между ними!** 🔄

---

## Памятка

✅ **Repository** = Интерфейс для БД операций

✅ **Spring автоматически** создает реализацию

✅ **JpaRepository** дает 20+ встроенных методов

✅ **Кастомные методы** - Spring генерирует SQL по названию

✅ **Entity классы** = Таблицы в БД

✅ **H2** = In-memory БД (теряется при перезагрузке)

✅ **Type-safe** = Spring проверяет типы данных

---

## Быстрый Старт: Создать Свой Repository

```java
// 1. Создай Entity
@Entity
public class Product {
    @Id
    @GeneratedValue
    private Long id;
    private String name;
    private double price;
}

// 2. Создай Repository
public interface ProductRepository extends JpaRepository<Product, Long> {
    List<Product> findByPriceLessThan(double price);
}

// 3. Используй в Service
@Service
public class ProductService {
    @Autowired
    private ProductRepository repo;
    
    public List<Product> getCheap() {
        return repo.findByPriceLessThan(100);  // ← Готово!
    }
}
```

**Вот и всё! Spring создаст таблицу и SQL автоматически!** 🎉
