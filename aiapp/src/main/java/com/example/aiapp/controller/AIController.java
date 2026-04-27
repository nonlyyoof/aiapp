package com.example.aiapp.controller;

import java.util.LinkedHashMap;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.aiapp.dto.AnswerDTO;
import com.example.aiapp.dto.QuestionDTO;
import com.example.aiapp.service.AIService;
import com.example.aiapp.service.OllamaService;

/**
 * AI Controller - Handles Q&A requests via Ollama
 * Local LLM inference - no external API required
 */
@RestController
@RequestMapping("/api")
public class AIController {
    private final AIService aiService;
    private final OllamaService ollamaService;

    public AIController(AIService aiService, OllamaService ollamaService) {
        this.aiService = aiService;
        this.ollamaService = ollamaService;
    }

    /**
     * Ask AI a question (using Ollama)
     */
    @PostMapping("/ask")
    public AnswerDTO ask(@RequestBody QuestionDTO question) {
        return new AnswerDTO(aiService.getAnswer(question.text));
    }

    /**
     * Get Ollama model info
     */
    @GetMapping("/ai/model")
    public ResponseEntity<Map<String, Object>> getModelInfo() {
        Map<String, Object> info = new LinkedHashMap<>();
        info.put("provider", "ollama");
        info.put("model", ollamaService.getCurrentModel());
        info.put("status", "active");
        return ResponseEntity.ok(info);
    }

    /**
     * Set Ollama model for inference
     */
    @PostMapping("/ai/model")
    public ResponseEntity<Map<String, String>> setModel(@RequestBody Map<String, String> request) {
        String model = request.get("model");
        ollamaService.setModel(model);
        
        Map<String, String> response = new LinkedHashMap<>();
        response.put("message", "Model changed to: " + model);
        response.put("model", ollamaService.getCurrentModel());
        return ResponseEntity.ok(response);
    }

    /**
     * Get available Ollama models
     */
    @GetMapping("/ai/models")
    public ResponseEntity<Map<String, Object>> getAvailableModels() {
        Map<String, Object> response = new LinkedHashMap<>();
        response.put("models", ollamaService.getAvailableModels());
        response.put("current_model", ollamaService.getCurrentModel());
        return ResponseEntity.ok(response);
    }
}

