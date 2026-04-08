package com.example.aiapp.controller;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
import com.example.aiapp.model.Question;
import com.example.aiapp.model.Answer;

@SpringBootTest
class AIControllerTest {

    @Autowired
    private TestRestTemplate rest;

    @Test
    void testApi() {
        Question q = new Question();
        q.text = "Hello";

        Answer response = rest.postForObject(
                "/api/ask",
                q,
                Answer.class
        );

        assertNotNull(response);
        assertNotNull(response.answer);
    }
}