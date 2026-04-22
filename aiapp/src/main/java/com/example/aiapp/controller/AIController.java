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
 * AI Controller - Handles Q&A requests
 * Supports multiple AI providers (Ollama, HuggingFace)
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
     * Ask AI a question
     */
    @PostMapping("/ask")
    public AnswerDTO ask(@RequestBody QuestionDTO question) {
        return new AnswerDTO(aiService.getAnswer(question.text));
    }

    /**
     * Get current AI provider and model info
     */
    @GetMapping("/ai/provider")
    public ResponseEntity<Map<String, Object>> getProviderInfo() {
        Map<String, Object> info = new LinkedHashMap<>();
        info.put("provider", aiService.getCurrentProvider());
        info.put("model", ollamaService.getCurrentModel());
        info.put("status", "active");
        return ResponseEntity.ok(info);
    }

    /**
     * Switch AI provider (ollama or huggingface)
     */
    @PostMapping("/ai/provider")
    public ResponseEntity<Map<String, String>> switchProvider(@RequestBody Map<String, String> request) {
        String provider = request.get("provider");
        aiService.setAIProvider(provider);
        
        Map<String, String> response = new LinkedHashMap<>();
        response.put("message", "Provider switched to: " + provider);
        response.put("provider", aiService.getCurrentProvider());
        return ResponseEntity.ok(response);
    }

    /**
     * Set Ollama model
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

