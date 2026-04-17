package com.example.aiapp.service;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.beans.factory.annotation.Autowired;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
class AIServiceTest {

    @Autowired
    private AIService service;

    @Test
    void shouldReturnAnswer() {
        String result = service.getAnswer("Привет");
        assertNotNull(result);
    }
}