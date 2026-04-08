package com.example.aiapp.controller;

import com.example.aiapp.dto.QuestionDTO;
import com.example.aiapp.dto.AnswerDTO;
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
    public AnswerDTO ask(@RequestBody QuestionDTO question){
        String result = aiService.getAnswer(question.text);
        return new AnswerDTO(result);
    }

    @GetMapping("/history")
    public Object history(){
        return aiService.getHistory();
    }
}

