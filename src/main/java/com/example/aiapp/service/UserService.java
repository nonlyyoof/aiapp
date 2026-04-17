package com.example.aiapp.service;

import java.util.HashMap;
import java.util.Map;

import org.springframework.stereotype.Service;

@Service
public class UserService {

    private Map<Integer, String> users = new HashMap<>();

    public void addUser(int id, String name) {
        users.put(id, name);
    }

    public String getUser(int id) {
        return users.get(id);
    }

    public Map<Integer, String> getAllUsers() {
        return users;
    }
}