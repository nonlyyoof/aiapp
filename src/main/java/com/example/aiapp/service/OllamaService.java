package com.example.ai.service;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

import org.springframework.stereotype.Service;

@Service
public class OllamaService {

    private final HttpClient client = HttpClient.newHttpClient();

    public String ask(String prompt) {
        try {
            String json = """
                {
                  "model": "llama3",
                  "prompt": "%s",
                  "stream": false
                }
                """.formatted(prompt.replace("\"", "\\\""));

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create("http://localhost:11434/api/generate"))
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(json))
                    .build();

            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

            String body = response.body();

            // Вытаскиваем ответ
            return body.split("\"response\":\"")[1].split("\"")[0];

        } catch (Exception e) {
            e.printStackTrace();
            return "Ошибка при работе с Ollama";
        }
    }
}