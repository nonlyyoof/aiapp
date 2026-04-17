package com.example.aiapp.service;

import com.example.aiapp.model.Message;

import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

import org.apache.logging.log4j.message.Message;

@Service
public class MessageService {
    private List<Message> messages = new ArrayList<>();
    public void addMessage(Message message) {
        messages.add(message);
    }
    public List<Message> getAllMessages() {
        
    }
}
