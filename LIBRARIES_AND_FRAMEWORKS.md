# 📚 Полный Справочник Библиотек и Фреймворков Проекта

---

## 🔴 **JAVA BACKEND (Spring Boot 3.5.13)**

### Framework & Core
| Библиотека | Версия | Назначение | Что делает |
|------------|--------|-----------|-----------|
| **Spring Boot Starter Web** | 3.5.13 | REST API framework | Создает HTTP endpoints, обрабатывает запросы/ответы |
| **Spring Boot Starter Data JPA** | 3.5.13 | ORM (Object-Relational Mapping) | Работа с базой данных через объектно-ориентированный подход |

### Database
| Библиотека | Версия | Назначение | Что делает |
|------------|--------|-----------|-----------|
| **H2 Database** | 1.4.200 | In-memory DB | Хранит сообщения в памяти (теряются при перезагрузке) |

### Development Tools
| Библиотека | Версия | Назначение | Что делает |
|------------|--------|-----------|-----------|
| **Spring Boot DevTools** | 3.5.13 | Hot Reload | Автоматическая перезагрузка при изменении кода |
| **Spring Boot Test** | 3.5.13 | Testing Framework | Модульное тестирование (JUnit, Mockito) |

### Build & Compilation
| Tool | Версия | Назначение | Что делает |
|------|--------|-----------|-----------|
| **Maven** | 3.x | Build Manager | Управляет зависимостями, собирает JAR файлы |
| **Java Compiler** | 25* | Компилятор | Преобразует .java в .class (bytecode) |

*⚠️ **Проблема**: Java версия = 25 в compiler plugin, но 17 в properties → Нужно привести в соответствие к 21!

### Jackson (JSON Processing)
| Библиотека | Версия | Назначение | Что делает |
|------------|--------|-----------|-----------|
| **Jackson Core** | 2.17.x | JSON сериализация | Преобразует объекты ↔ JSON |
| **Jackson Databind** | 2.17.x | JSON маппинг | Преобразует API responses в Java объекты |

*(включены автоматически через Spring Boot)*

### HTTP Client
| Библиотека | Версия | Назначение | Что делает |
|------------|--------|-----------|-----------|
| **Spring RestTemplate** | 3.5.13 | HTTP Client | Делает HTTP запросы к Ollama и другим сервисам |

---

## 🟢 **PYTHON ML SERVICE (FastAPI)**

### Web Framework
| Библиотека | Версия | Назначение | Что делает |
|------------|--------|-----------|-----------|
| **FastAPI** | 0.116.1 | REST API Framework | Создает REST endpoints, автоматическая валидация данных |
| **Uvicorn** | 0.35.0 | ASGI Server | HTTP сервер, запускает FastAPI приложение |

### AI/ML Models
| Библиотека | Версия | Назначение | Что делает |
|------------|--------|-----------|-----------|
| **OpenAI Whisper** | 20250625 | Speech-to-Text | Распознает речь из аудиофайлов (STT) |
| **face-recognition** | 1.3.0 | Face Detection/Recognition | Обнаруживает, распознает и сравнивает лица на фото |

### Computer Vision
| Библиотека | Версия | Назначение | Что делает |
|------------|--------|-----------|-----------|
| **OpenCV** | 4.12.0.88 | Image Processing | Обработка изображений, компьютерное зрение |
| **Pillow** | 11.3.0 | Image Library | Работа с форматами изображений (PNG, JPEG, etc) |
| **pytesseract** | 0.3.13 | OCR (Optical Character Recognition) | Извлечение текста из изображений |

### Configuration & Utilities
| Библиотека | Версия | Назначение | Что делает |
|------------|--------|-----------|-----------|
| **python-dotenv** | 1.1.1 | Environment Variables | Загружает переменные из .env файла |
| **python-multipart** | 0.0.20 | File Uploads | Парсит multipart/form-data для загрузки файлов |

---

## 💙 **FLUTTER MOBILE APP**

### Core Packages
| Пакет | Версия | Назначение | Что делает |
|-------|--------|-----------|-----------|
| **Flutter SDK** | Latest | UI Framework | Создает кроссплатформенный UI (iOS/Android) |
| **Provider** | 6.0.0 | State Management | Управление состоянием приложения (паттерн ChangeNotifier) |

### Speech & Audio
| Пакет | Версия | Назначение | Что делает |
|-------|--------|-----------|-----------|
| **flutter_tts** | 8.0.0 | Text-to-Speech | Синтез речи (говорит текст) |
| **speech_to_text** | 6.3.0 | Speech-to-Text | Распознавание речи (слушает и преобразует) |

### Permissions
| Пакет | Версия | Назначение | Что делает |
|-------|--------|-----------|-----------|
| **permission_handler** | 11.4.4 | Runtime Permissions | Запрос доступа к микрофону, камере, хранилищу |

### Development
| Пакет | Назначение | Что делает |
|-------|-----------|-----------|
| **flutter_test** | Testing Framework | Модульное тестирование Dart кода |

---

## 🌐 **WEB APP (React/Vite)**

*⚠️ Исходные файлы потеряны, но структура была:*

### Build Tool
| Tool | Версия | Назначение | Что делает |
|------|--------|-----------|-----------|
| **Vite** | 5.x | Build Tool & Dev Server | Быстрая разработка, сборка оптимизированного код |

### UI Framework
| Библиотека | Версия | Назначение | Что делает |
|------------|--------|-----------|-----------|
| **React** | 18.x | UI Library | Создает интерактивные компоненты |
| **TypeScript** | 5.x | Type-safe JavaScript | JavaScript + статическая типизация |

### HTTP Client
| Библиотека | Версия | Назначение | Что делает |
|------------|--------|-----------|-----------|
| **Axios** или **Fetch API** | - | HTTP Requests | Связь с Java backend API |

---

## 🗂️ **ДОПОЛНИТЕЛЬНЫЕ ИНСТРУМЕНТЫ**

### Version Control
| Tool | Назначение |
|------|-----------|
| **Git** | Управление версиями кода |

### Local LLM
| Tool | Версия | Назначение | Что делает |
|------|--------|-----------|-----------|
| **Ollama** | Latest | LLM Runtime | Запускает открытые модели (Mistral, LLaMA2, LLaVA) |

### Database Management
| Tool | Назначение |
|------|-----------|
| **H2 Console** | Web интерфейс для просмотра БД |

---

## 📊 **АРХИТЕКТУРА: КАК ВСЕ РАБОТАЕТ ВМЕСТЕ**

```
┌─────────────────────────────────────┐
│     MOBILE (Flutter)                │
│  ├─ provider      (State)           │
│  ├─ flutter_tts   (TTS)             │
│  └─ speech_to_text (STT)            │
└────────────────┬────────────────────┘
                 │ REST API
                 ▼
┌─────────────────────────────────────┐
│     JAVA BACKEND (Spring Boot)      │
│  ├─ Spring Web   (HTTP)             │
│  ├─ Spring JPA   (Database)         │
│  ├─ H2           (In-memory DB)     │
│  └─ RestTemplate (HTTP Client)      │
└────────────────┬────────────────────┘
                 │ HTTP
                 ├─────────────────────┐
                 ▼                     ▼
        ┌──────────────────┐   ┌──────────────────┐
        │ OLLAMA SERVER    │   │ PYTHON ML SERVICE│
        │ (localhost:11434)│   │ (localhost:8001) │
        │                  │   ├─ FastAPI        │
        │ Models:          │   ├─ Whisper (STT)  │
        │ - Mistral 7B     │   ├─ face_recognition
        │ - LLaMA2         │   ├─ OpenCV         │
        │ - LLaVA (Vision) │   ├─ Tesseract (OCR)│
        └──────────────────┘   └──────────────────┘
```

---

## 🎯 **ЧТО ДЕЛАЕТ КАЖДАЯ ЧАСТЬ**

### Java Backend (Основной API)
```
Входит: HTTP запрос (JSON)
   ↓
Spring Web обрабатывает запрос
   ↓
RestTemplate вызывает Ollama или Python сервис
   ↓
Результат сохраняется в H2 (база)
   ↓
Jackson преобразует ответ в JSON
   ↓
Выходит: HTTP ответ (JSON)
```

### Python ML Service (Обработка данных)
```
Входит: Файл или текст через FastAPI
   ↓
Multipart парсит загруженный файл
   ↓
OpenCV/Pillow обрабатывает изображение
   ↓
face-recognition обнаруживает лица
   ↓
Whisper распознает речь
   ↓
Tesseract извлекает текст
   ↓
Выходит: Результаты (JSON)
```

### Flutter Mobile (UI & Voice)
```
Входит: Пользователь касается кнопки
   ↓
speech_to_text слушает голос
   ↓
Результат отправляется в Java backend
   ↓
Provider обновляет состояние UI
   ↓
java backend вызывает Ollama/Python
   ↓
Ответ приходит обратно
   ↓
flutter_tts синтезирует речь
   ↓
Выходит: Аудио на динамике
```

---

## 💡 **КЛЮЧЕВЫЕ КОНЦЕПЦИИ**

### **REST API**
API которая использует HTTP методы (GET, POST, PUT, DELETE) для общения между компонентами.

### **ORM (Object-Relational Mapping)**
Spring JPA автоматически преобразует объекты Java ↔ Таблицы БД

### **State Management**
Provider в Flutter отслеживает изменения данных и обновляет UI

### **Async/Await**
Асинхронные операции в Dart/Java позволяют не блокировать UI при долгих операциях

### **JSON Serialization**
Преобразование структурированных данных для отправки через HTTP

---

## 📈 **ЗАВИСИМОСТИ МЕЖДУ СЕРВИСАМИ**

```
┌─────────────┐
│   Client    │ (Mobile/Web)
└──────┬──────┘
       │ Depends on:
       ▼
┌─────────────────────────┐
│   Java Backend REST API │ Depends on:
├─────────────────────────┤ ├→ Spring Boot
│  /api/ask               │ ├→ RestTemplate
│  /api/ml/*              │ └→ H2 Database
│  /api/ai/*              │
└──┬──────────────────────┘
   │
   ├─→ Ollama (llama2, mistral, llava)
   │
   └─→ Python ML Service Depends on:
       ├─ FastAPI
       ├─ OpenCV
       ├─ Whisper
       ├─ face-recognition
       └─ Tesseract
```

---

## 🔧 **ВЕРСИЯ JAVA - НУЖНО ПРИВЕСТИ В ПОРЯДОК**

| Файл | Текущее | Должно быть | Статус |
|------|---------|-----------|--------|
| pom.xml (properties) | 17 | **21** | ❌ Нужно обновить |
| pom.xml (maven-compiler) | 25 | **21** | ❌ Нужно обновить |
| Runtime | ? | **21** | ⚠️ Нужно установить |

---

## 📋 **ЗАЧЕМ КАЖДАЯ БИБЛИОТЕКА**

### **Если бы её не было:**

**Spring Boot** → Писать HTTP сервер с нуля на Java
**FastAPI** → Писать HTTP сервер с нуля на Python
**Whisper** → Писать алгоритм распознавания речи
**face-recognition** → Писать детектор лиц с нуля
**Flutter** → Писать Android и iOS приложение отдельно
**Ollama** → Покупать доступ к облачному LLM (OpenAI, Google)
**H2** → Использовать сложную PostgreSQL/MySQL
**Provider** → Писать сложный state management вручную

---

## ✅ **ИТОГИ**

- ✅ **Java**: 6 основных зависимостей (Spring Boot ecosystem)
- ✅ **Python**: 9 зависимостей (ML + Web)
- ✅ **Flutter**: 5 пакетов (UI + Voice + State)
- ✅ **Web**: 3+ (Vite + React + TypeScript)
- ✅ **Total**: ~25 основных библиотек/фреймворков

**Все согласованы и работают вместе для создания полнофункционального AI приложения!**
