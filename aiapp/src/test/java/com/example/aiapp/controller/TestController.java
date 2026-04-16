package com.example.aiapp.controller;

import com.example.aiapp.model.Message;
import com.example.aiapp.service.*;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Set;

@RestController
@RequestMapping("/test")
public class TestController {

    private final MessageService messageService;
    private final UserService userService;
    private final WordService wordService;
    private final QueueService queueService;

    public TestController(MessageService messageService,
                          UserService userService,
                          WordService wordService,
                          QueueService queueService) {
        this.messageService = messageService;
        this.userService = userService;
        this.wordService = wordService;
        this.queueService = queueService;
    }
    @PostMapping("/message")
    public void addMessage(@RequestBody Message message) {
        messageService.addMessage(message);
    }

    @GetMapping("/messages")
    public List<Message> getMessages() {
        return messageService.getAllMessages();
    }
    @PostMapping("/user")
    public void addUser(@RequestParam int id, @RequestParam String name) {
        userService.addUser(id, name);
    }

    @GetMapping("/users")
    public Map<Integer, String> getUsers() {
        return userService.getAllUsers();
    }

    @PostMapping("/words")
    public void addWords(@RequestBody String text) {
        wordService.addWords(text);
    }

    @GetMapping("/words")
    public Set<String> getWords() {
        return wordService.getUniqueWords();
    }

    @PostMapping("/queue")
    public void addQueue(@RequestBody String message) {
        queueService.addToQueue(message);
    }

    @GetMapping("/queue")
    public String getQueue() {
        return queueService.getNextMessage();
    }
}