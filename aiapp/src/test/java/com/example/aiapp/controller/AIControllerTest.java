package com.example.aiapp.controller;
import com.example.aiapp.dto.AnswerDTO;
import com.example.aiapp.dto.QuestionDTO;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class AIControllerTest {

    @Autowired
    private TestRestTemplate rest;

    @Test
    void testApi() {
        QuestionDTO q = new QuestionDTO();
        q.text = "Hello";

        AnswerDTO response = rest.postForObject(
                "/api/ask",
                q,
                AnswerDTO.class
        );

        assertNotNull(response);
        assertNotNull(response.answer);
    }
}
