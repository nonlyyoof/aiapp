package com.example.aiapp.service;
import java.util.List;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.example.aiapp.entity.Message;
import com.example.aiapp.repository.MessageRepository;

/**
 * AI Service - Routes to either Ollama (default) or HuggingFace for LLM queries
 * Ollama is preferred for local/offline operation
 */
@Service
public class AIService {
    private final MessageRepository messageRepository;
    private final OllamaService ollamaService;
    private final HuggingFaceService hfService;
    
    @Value("${ai.provider:ollama}")
    private String aiProvider;

    public AIService(MessageRepository messageRepository, OllamaService ollamaService, HuggingFaceService hfService) {
        this.messageRepository = messageRepository;
        this.ollamaService = ollamaService;
        this.hfService = hfService;
    }

    /**
     * Get AI response - uses Ollama by default, falls back to HuggingFace if configured
     */
    public String getAnswer(String text) {
        Message userMessage = new Message("user", text);
        messageRepository.save(userMessage);
        
        String response = "ollama".equalsIgnoreCase(aiProvider) 
            ? ollamaService.askAI(text)
            : hfService.askAI(text);
            
        Message aiMessage = new Message("ai", response);
        messageRepository.save(aiMessage);
        return response;
    }

    /**
     * Switch AI provider at runtime
     */
    public void setAIProvider(String provider) {
        if ("ollama".equalsIgnoreCase(provider) || "huggingface".equalsIgnoreCase(provider)) {
            this.aiProvider = provider.toLowerCase();
        }
    }

    /**
     * Get current AI provider
     */
    public String getCurrentProvider() {
        return aiProvider;
    }

    /**
     * Get conversation history
     */
    public List<Message> getHistory() {
        return messageRepository.findAll();
    }
}