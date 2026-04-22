package com.example.aiapp.service;

import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClientResponseException;
import org.springframework.web.client.RestTemplate;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

/**
 * Ollama AI Service - Local LLM replacement for HuggingFace
 * Provides chat-based Q&A using locally running Ollama instance
 */
@Service
public class OllamaService {

    @Value("${ollama.api.url:http://localhost:11434}")
    private String ollamaUrl;

    @Value("${ollama.model:mistral}")
    private String modelName;

    private final RestTemplate restTemplate = new RestTemplate();
    private final ObjectMapper objectMapper = new ObjectMapper();

    /**
     * Ask question to locally running Ollama model
     * Falls back gracefully if Ollama is not available
     */
    public String askAI(String prompt) {
        try {
            // Verify Ollama is available
            if (!isOllamaAvailable()) {
                return fallbackResponse("Ollama service is not running", prompt);
            }

            return generateResponse(prompt);
        } catch (RestClientResponseException ex) {
            return fallbackResponse("Ollama API error: " + ex.getStatusCode(), prompt);
        } catch (Exception ex) {
            return fallbackResponse("Error connecting to Ollama: " + ex.getMessage(), prompt);
        }
    }

    /**
     * Check if Ollama service is available
     */
    private boolean isOllamaAvailable() {
        try {
            String url = ollamaUrl + "/api/tags";
            ResponseEntity<String> response = restTemplate.getForEntity(url, String.class);
            return response.getStatusCode().is2xxSuccessful();
        } catch (Exception ex) {
            return false;
        }
    }

    /**
     * Generate response from Ollama model
     */
    private String generateResponse(String prompt) throws Exception {
        String url = ollamaUrl + "/api/generate";

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        // Build request body
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("model", modelName);
        body.put("prompt", prompt);
        body.put("stream", false);
        body.put("temperature", 0.7);
        body.put("num_predict", 500);
        body.put("top_p", 0.9);
        body.put("top_k", 40);

        HttpEntity<Map<String, Object>> request = new HttpEntity<>(body, headers);

        ResponseEntity<String> response = restTemplate.exchange(
                url,
                HttpMethod.POST,
                request,
                String.class
        );

        if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
            JsonNode jsonNode = objectMapper.readTree(response.getBody());
            String generatedText = jsonNode.get("response").asText();
            
            if (generatedText != null && !generatedText.isBlank()) {
                return generatedText.trim();
            }
        }

        return fallbackResponse("Empty response from Ollama", prompt);
    }

    /**
     * Get list of available models from Ollama
     */
    public List<String> getAvailableModels() {
        try {
            String url = ollamaUrl + "/api/tags";
            ResponseEntity<String> response = restTemplate.getForEntity(url, String.class);
            
            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                JsonNode jsonNode = objectMapper.readTree(response.getBody());
                JsonNode models = jsonNode.get("models");
                
                List<String> modelList = new ArrayList<>();
                if (models != null && models.isArray()) {
                    for (JsonNode model : models) {
                        modelList.add(model.get("name").asText());
                    }
                }
                return modelList;
            }
        } catch (Exception ex) {
            // Silent fail for model listing
        }
        
        return Collections.emptyList();
    }

    /**
     * Set the model to use for generation
     */
    public void setModel(String newModel) {
        this.modelName = newModel;
    }

    /**
     * Get currently configured model
     */
    public String getCurrentModel() {
        return modelName;
    }

    /**
     * Fallback response when Ollama is unavailable
     */
    private String fallbackResponse(String reason, String prompt) {
        return String.format(
            "Local AI service (%s) is unavailable. " +
            "Please ensure Ollama is running on %s with model '%s'. " +
            "Prompt: %s",
            reason, ollamaUrl, modelName, prompt
        );
    }
}
