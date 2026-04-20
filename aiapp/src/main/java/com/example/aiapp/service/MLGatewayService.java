package com.example.aiapp.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Map;

@Service
public class MLGatewayService {

    private final RestTemplate restTemplate = new RestTemplate();

    @Value("${ml.service.url:http://localhost:8001}")
    private String mlServiceUrl;

    public Map<String, Object> health() {
        return exchange(mlServiceUrl + "/health", HttpMethod.GET, null);
    }

    public Map<String, Object> detectFaces(MultipartFile file) {
        return upload(file, "/vision/face/detect");
    }

    public Map<String, Object> recognizeText(MultipartFile file) {
        return upload(file, "/vision/text/ocr");
    }

    public Map<String, Object> transcribeSpeech(MultipartFile file) {
        return upload(file, "/audio/speech/transcribe");
    }

    private Map<String, Object> upload(MultipartFile file, String path) {
        try {
            ByteArrayResource resource = new ByteArrayResource(file.getBytes()) {
                @Override
                public String getFilename() {
                    return file.getOriginalFilename();
                }
            };

            HttpHeaders fileHeaders = new HttpHeaders();
            fileHeaders.setContentType(MediaType.APPLICATION_OCTET_STREAM);

            MultiValueMap<String, Object> body = new LinkedMultiValueMap<>();
            body.add("file", new HttpEntity<>(resource, fileHeaders));

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.MULTIPART_FORM_DATA);

            HttpEntity<MultiValueMap<String, Object>> request = new HttpEntity<>(body, headers);
            return exchange(mlServiceUrl + path, HttpMethod.POST, request);
        } catch (IOException ex) {
            throw new IllegalStateException("Failed to read uploaded file.", ex);
        }
    }

    private Map<String, Object> exchange(String url, HttpMethod method, HttpEntity<?> request) {
        try {
            ResponseEntity<Map> response = restTemplate.exchange(url, method, request, Map.class);
            return response.getBody();
        } catch (RestClientException ex) {
            throw new IllegalStateException("ML service request failed: " + ex.getMessage(), ex);
        }
    }
}
