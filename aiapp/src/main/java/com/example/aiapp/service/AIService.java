package com.example.aiapp.service;

import org.springframework.stereotype.Service;

@Service
public class AIService{
    public String getAnswer(String text){
        return "AI: " + text;
    }
}