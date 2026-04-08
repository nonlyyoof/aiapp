package com.example.aiapp.controller;

import com.example.aiapp.model.Question;
import com.example.aiapp.service.AIService;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api")
public class AIController{
    private final AIService aiService;

    public AIController(AIService aiService){
        this.aiService = aiService;
    }

    @PostMapping("/ask")
    public String ask(@RequestBody Question question){
        return aiService.getAnswer(question.text);
    }
}

