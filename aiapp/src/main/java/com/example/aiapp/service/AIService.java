package com.example.aiapp.service;
import com.example.aiapp.entity.Message;
import com.example.aiapp.repository.MessageRepository;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class AIService {
    private final MessageRepository messageRepository;
    private final HuggingFaceService hfService;
    public AIService(MessageRepository messageRepository, HuggingFaceService hfService) {
        this.messageRepository = messageRepository;
        this.hfService = hfService;
    }
    public String getAnswer(String text) {
        Message userMessage = new Message("user", text);
        messageRepository.save(userMessage);
        String response = hfService.askAI(text);
        Message aiMessage = new Message("ai", response);
        messageRepository.save(aiMessage);
        return response;
    }
    private String generateResponse(String text) {
        return "AI: " + text;
    }
    public List<Message> getHistory() {
        return messageRepository.findAll();
    }
}