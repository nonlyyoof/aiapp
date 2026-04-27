package com.example.aiapp.controller;

import com.example.aiapp.service.MLGatewayService;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.Map;

@RestController
@RequestMapping("/api/ml")
public class MLController {

    private final MLGatewayService mlGatewayService;

    public MLController(MLGatewayService mlGatewayService) {
        this.mlGatewayService = mlGatewayService;
    }

    @GetMapping("/health")
    public Map<String, Object> health() {
        return mlGatewayService.health();
    }

    @PostMapping(value = "/face/detect", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public Map<String, Object> detectFaces(@RequestParam("file") MultipartFile file) {
        return mlGatewayService.detectFaces(file);
    }

    @PostMapping(value = "/text/ocr", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public Map<String, Object> recognizeText(@RequestParam("file") MultipartFile file) {
        return mlGatewayService.recognizeText(file);
    }

    @PostMapping(value = "/speech/transcribe", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public Map<String, Object> transcribeSpeech(@RequestParam("file") MultipartFile file) {
        return mlGatewayService.transcribeSpeech(file);
    }
}
