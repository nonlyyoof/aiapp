package com.example.aiapp.service;

import java.util.HashSet;
import java.util.Set;

import org.springframework.stereotype.Service;

@Service
public class WordService {

    private Set<String> uniqueWords = new HashSet<>();

    public void addWords(String text) {
        String[] words = text.split(" ");
        for (String word : words) {
            uniqueWords.add(word.toLowerCase());
        }
    }

    public Set<String> getUniqueWords() {
        return uniqueWords;
    }
}