package com.example.aiapp.service;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class AIServiceTest {

    private final AIService service = new AIService();

    @Test
    void shouldReturnAnswer() {
        String result = service.getAnswer("Привет");
        assertTrue(result.contains("Привет"));
    }
}