# Ollama Integration Guide

## Overview
This project now integrates with **Ollama** - a local LLM runtime for offline AI capabilities. Ollama replaces the HuggingFace external API dependency, providing:
- ✅ No internet required after model download
- ✅ No API keys needed
- ✅ Instant local inference
- ✅ Full privacy - all processing on your machine
- ✅ Multiple model support

---

## 🚀 Quick Start

### 1. Install Ollama
Download from: https://ollama.ai/download

### 2. Pull a Model
```bash
# Recommended: Mistral 7B (fast and capable)
ollama pull mistral

# Or other options:
ollama pull llama2          # Larger, more capable
ollama pull neural-chat     # Chat optimized
ollama pull dolphin-mixtral # Advanced reasoning
```

### 3. Start Ollama Server
```bash
ollama serve
# Server runs on http://localhost:11434
```

### 4. Start Java Backend
```bash
cd c:\aiapp\aiapp
mvn spring-boot:run
# Java backend automatically uses Ollama on startup
```

### 5. Test the Integration
```bash
# Ask a question
curl -X POST http://localhost:8080/api/ask \
  -H "Content-Type: application/json" \
  -d '{"text":"What is machine learning?"}'

# Expected response from local Ollama model
```

---

## ⚙️ Configuration

### Java Backend (application.properties)

```properties
# Default provider (ollama or huggingface)
ai.provider=ollama

# Ollama server URL and model
ollama.api.url=http://localhost:11434
ollama.model=mistral

# For switching to HuggingFace (optional)
hf.api.key=YOUR_API_KEY  # Keep empty or set to use HF as fallback
```

### Environment Variables (Optional)
```bash
export OLLAMA_API_URL=http://localhost:11434
export OLLAMA_MODEL=mistral
export AI_PROVIDER=ollama
```

---

## 🔄 Runtime API Endpoints

### Get Current Provider Info
```bash
GET /api/ai/provider
# Response:
{
  "provider": "ollama",
  "model": "mistral",
  "status": "active"
}
```

### Switch AI Provider
```bash
POST /api/ai/provider
Body: {"provider": "ollama"}  # or "huggingface"
# Response: {"message": "Provider switched to: ollama"}
```

### Get Available Models
```bash
GET /api/ai/models
# Response:
{
  "models": ["mistral:latest", "llama2:latest"],
  "current_model": "mistral"
}
```

### Change Active Model
```bash
POST /api/ai/model
Body: {"model": "llama2:latest"}
# Response: {"message": "Model changed to: llama2:latest"}
```

---

## 📊 Supported Models

| Model | Size | Speed | Quality | Use Case |
|-------|------|-------|---------|----------|
| **mistral** | 7B | ⚡ Fast | ⭐⭐⭐⭐ | General Q&A (Recommended) |
| **llama2** | 7B-70B | 🔄 Medium | ⭐⭐⭐⭐⭐ | Complex reasoning |
| **neural-chat** | 7B | ⚡ Fast | ⭐⭐⭐ | Chat optimized |
| **dolphin-mixtral** | 45B | 🐢 Slow | ⭐⭐⭐⭐⭐ | Advanced tasks |
| **orca-mini** | 3B | ⚡⚡ Very Fast | ⭐⭐⭐ | Lightweight |

### Download Model Sizes
```
mistral:latest      ~4.1 GB
llama2:latest       ~3.8 GB (7B)
neural-chat:latest  ~4.1 GB
dolphin-mixtral     ~26 GB (requires 32GB+ RAM)
```

---

## 🛠️ Troubleshooting

### Ollama Not Running
**Problem:** "Ollama service is not running"

**Solution:**
```bash
# Check if Ollama is running
curl http://localhost:11434/api/tags

# If not, start it
ollama serve

# Or on Windows, use the GUI application
# Ollama → System Tray → "Serve on 11434"
```

### Model Not Found
**Problem:** "Error generating response"

**Solution:**
```bash
# List available models
ollama list

# Pull the model
ollama pull mistral

# Verify it's available
ollama list
```

### Out of Memory
**Problem:** Model loads but is very slow or crashes

**Solution:**
```bash
# Use smaller model
ollama pull orca-mini

# Or free up RAM and use lighter model
ollama pull neural-chat

# Check system RAM and reduce model size accordingly
```

### Connection Refused
**Problem:** "Error connecting to Ollama: Connection refused"

**Solution:**
1. Verify Ollama server is running: `ollama serve`
2. Check default port 11434 is accessible
3. If using custom URL, verify in application.properties
4. Windows Firewall: Allow Java process network access

---

## 🔗 Integration Architecture

```
┌─────────────────────────────────────┐
│      Client (Mobile/Web)            │
└────────────┬────────────────────────┘
             │ REST API
             ▼
┌─────────────────────────────────────┐
│    Java Backend (Spring Boot)       │
│  http://localhost:8080              │
├─────────────────────────────────────┤
│ AIController                        │
│ ├─ /api/ask          (Q&A)          │
│ ├─ /api/ai/provider  (Config)       │
│ └─ /api/ai/models    (List models)  │
└────────────┬────────────────────────┘
             │ HTTP
             ▼
┌─────────────────────────────────────┐
│  Local Ollama Server                │
│  http://localhost:11434             │
├─────────────────────────────────────┤
│ Models: mistral, llama2, etc        │
│ No internet required                │
│ 100% private inference              │
└─────────────────────────────────────┘
```

---

## 📈 Performance Tips

### 1. Use GPU Acceleration (Optional)
```bash
# Ollama auto-detects NVIDIA/AMD GPUs
# For CUDA (NVIDIA): GPU automatically used if available
# For other GPUs, see: https://ollama.ai/library

# CPU-only mode (if needed):
OLLAMA_DISABLE_GPU=1 ollama serve
```

### 2. Preload Model for Faster Responses
```bash
# Pre-warm the model
ollama pull mistral

# First request: ~3-5 seconds
# Subsequent requests: ~1-2 seconds
```

### 3. Adjust Model Parameters
In OllamaService.java, tune:
```java
body.put("temperature", 0.7);      // Lower = more focused, Higher = more creative
body.put("top_p", 0.9);            // Diversity control
body.put("top_k", 40);             // Vocabulary diversity
body.put("num_predict", 500);      // Max response length
```

---

## 🆚 Migration from HuggingFace

### Before (External API)
- ❌ Requires API key
- ❌ Needs internet connection
- ❌ API rate limits
- ❌ Data sent to external servers
- ⏱️ 2-5 second latency

### After (Ollama)
- ✅ No API key required
- ✅ Works offline
- ✅ No rate limits
- ✅ All processing local
- ⏱️ 1-2 second latency

---

## 🔐 Security & Privacy

- **No data leaves your machine**: All processing is local
- **No tracking**: No telemetry or analytics
- **HTTPS not needed**: Communication is local (http://localhost)
- **Models are open source**: Inspect models on Hugging Face

---

## 📝 Files Modified

- `aiapp/src/main/java/com/example/aiapp/service/OllamaService.java` - ✨ New
- `aiapp/src/main/java/com/example/aiapp/service/AIService.java` - Updated to support Ollama
- `aiapp/src/main/java/com/example/aiapp/controller/AIController.java` - Added model management endpoints
- `aiapp/src/main/resources/application.properties` - Added Ollama configuration
- `ml-service/requirements.txt` - Removed unused dev dependencies (httpx, pytest)

---

## 🚀 Next Steps

1. **Download and install Ollama** from ollama.ai
2. **Pull a model**: `ollama pull mistral`
3. **Start Ollama**: `ollama serve`
4. **Start Java backend**: `mvn spring-boot:run`
5. **Test API**: `curl -X POST http://localhost:8080/api/ask -H "Content-Type: application/json" -d '{"text":"Hello!"}'`

---

## ❓ FAQ

**Q: Can I use multiple models?**
A: Yes! Use `/api/ai/models` to list available and `/api/ai/model` to switch.

**Q: What if Ollama crashes?**
A: The service gracefully falls back to showing error messages. Simply restart Ollama.

**Q: Can I still use HuggingFace?**
A: Yes! Set `ai.provider=huggingface` in application.properties and configure API key.

**Q: Do I need GPU?**
A: No, CPU works fine. GPU optional for faster inference on large models.

**Q: What's the minimum system requirement?**
A: 4GB RAM minimum. 8GB+ recommended for models like Mistral.

---

## 📚 Resources

- Ollama Documentation: https://ollama.ai
- Model Library: https://ollama.ai/library
- GitHub: https://github.com/jmorganca/ollama
- Discord Community: https://discord.gg/ollama
