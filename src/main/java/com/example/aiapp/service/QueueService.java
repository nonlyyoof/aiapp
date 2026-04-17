package com.example.aiapp.service;

import java.util.LinkedList;
import java.util.Queue;

import org.springframework.stereotype.Service;

@Service
public class QueueService {

    private Queue<String> messageQueue = new LinkedList<>();

    public void addToQueue(String message) {
        messageQueue.add(message);
    }

    public String getNextMessage() {
        return messageQueue.poll();
    }

    public Queue<String> getAll() {
        return messageQueue;
    }
}