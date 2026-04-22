# 🚀 Ollama + TTS/STT - Quick Start (5 minutes)

## Step 1: Install Ollama (2 min)
Download and install from: https://ollama.ai/download

## Step 2: Download a Model (2 min)
```bash
ollama pull mistral
```

## Step 3: Start Ollama Server (automatic)
```bash
ollama serve
# Listen on http://localhost:11434
```

## Step 4: Start Java Backend
```bash
cd c:\aiapp\aiapp
mvn spring-boot:run
# Starts on http://localhost:8080
```

## Step 5: Test the API (1 min)
```bash
# Test via curl
curl -X POST http://localhost:8080/api/ask \
  -H "Content-Type: application/json" \
  -d '{"text":"Hello! What is 2+2?"}'

# Or via PowerShell
$response = Invoke-WebRequest -Uri "http://localhost:8080/api/ask" `
  -Method Post `
  -Headers @{"Content-Type"="application/json"} `
  -Body '{"text":"Hello! What is 2+2?"}'
echo $response.Content
```

## ✅ Done!
You now have:
- ✅ Local LLM running (no internet needed)
- ✅ TTS working properly (callbacks, not delays)
- ✅ No API keys required
- ✅ Full privacy

---

## 📋 Other Available Models
```bash
ollama pull llama2           # Larger, more capable
ollama pull neural-chat      # Chat optimized
ollama pull orca-mini        # Lightweight (3.3GB)
ollama pull dolphin-mixtral  # Advanced reasoning
```

## 🔄 Switch Models at Runtime
```bash
# Get current model
curl http://localhost:8080/api/ai/provider

# Change model
curl -X POST http://localhost:8080/api/ai/model \
  -H "Content-Type: application/json" \
  -d '{"model":"llama2:latest"}'

# List available models
curl http://localhost:8080/api/ai/models
```

## 🆘 If Something Doesn't Work

### "Ollama not running"
```bash
ollama serve
# Then try API again
```

### "Connection refused"
- Make sure port 11434 is free
- Check Windows Firewall allows Java

### "Model not found"
```bash
ollama pull mistral
ollama list  # Verify it's there
```

### "Slow responses"
- Use smaller model: `ollama pull orca-mini`
- Check available RAM (8GB+ recommended)
- Enable GPU if available

---

## 📚 Full Documentation
See `OLLAMA_SETUP.md` for:
- Complete installation guide
- Troubleshooting
- Performance tips
- Model comparisons
- Architecture overview
