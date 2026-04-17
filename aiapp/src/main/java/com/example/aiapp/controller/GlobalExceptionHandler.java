package com.example.aiapp.controller;

import org.springframework.web.bind.annotation.*;

@RestControllerAdvice
public class GlobalExceptionHandler{

    @ExceptionHandler(Exception.class)
    public String handleError(Exception e){
        return "Ошибка: " + e.getMessage();
    }
}