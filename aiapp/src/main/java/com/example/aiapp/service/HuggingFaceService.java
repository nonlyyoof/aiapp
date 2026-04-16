package com.example.aiapp.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.*;

@Service
public class HuggingFaceService {

    @Value("${hf.api.key}")
    private String apiKey;

    private final RestTemplate restTemplate = new RestTemplate();

    public String askAI(String prompt) {

        String url = "https://router.huggingface.co/hf-inference/models/HuggingFaceH4/zephyr-7b-beta";

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth(apiKey);

        Map<String, Object> message = new HashMap<>();
        message.put("role", "user");
        message.put("content", prompt);

        Map<String, Object> body = new HashMap<>();
        body.put("model", "HuggingFaceH4/zephyr-7b-beta");
        body.put("inputs", prompt);
        body.put("max_tokens", 500);

        HttpEntity<Map<String, Object>> request = new HttpEntity<>(body, headers);
        
        ResponseEntity<List> response = restTemplate.exchange(
                url,
                HttpMethod.POST,
                request,
                List.class
        );

        List result = response.getBody();

        if (result != null && !result.isEmpty()) {
            Map first = (Map) result.get(0);
            return first.get("generated_text").toString();
        }

        return "AI error";
    }
}