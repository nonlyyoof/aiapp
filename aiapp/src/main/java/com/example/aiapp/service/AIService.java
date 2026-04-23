package com.example.aiapp.service;
import java.util.List;

import org.springframework.stereotype.Service;

import com.example.aiapp.entity.Message;
import com.example.aiapp.repository.MessageRepository;

/**
 * AI Service - Uses Ollama for all LLM queries
 * Local-first, offline-capable architecture
 */
@Service
public class AIService {
    private final MessageRepository messageRepository;
    private final OllamaService ollamaService;

    public AIService(MessageRepository messageRepository, OllamaService ollamaService) {
        this.messageRepository = messageRepository;
        this.ollamaService = ollamaService;
    }

    /**
     * Get AI response using Ollama
     */
    public String getAnswer(String text) {
        Message userMessage = new Message("user", text);
        messageRepository.save(userMessage);
        
        String response = ollamaService.askAI(text);
            
        Message aiMessage = new Message("ai", response);
        messageRepository.save(aiMessage);
        return response;
    }

    /**
     * Get conversation history
     */
    public List<Message> getHistory() {
        return messageRepository.findAll();
    }
}