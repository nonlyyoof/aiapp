package com.example.aiapp.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import java.util.ArrayList;
import java.util.List;

@Service
public class AIService{

    private static final Logger log = LoggerFactory.getLogger(AIService.class);

    private final List<String> history = new ArrayList<>();

    public String getAnswer(String text){
        log.info("Вопрос: {}", text);
        history.add("User: " + text);
        String response = generateResponse(text);
        history.add("AI: " + response);
        return response;
    }

    private String generateResponse(String text){
        if(text.toLowerCase().contains("привет")){
            return "Привет! Я твое приложение!";
        }

        if(text.toLowerCase().contains("как дела")){
            return "Я работаю стабильно!";
        }

        return "Я пока учусь, ты сказал " + text;
    }

    public List<String> getHistory(){
        return history;
    }
}