package com.example.aiapp.service;
import com.example.aiapp.entity.Schedule;
import com.example.aiapp.repository.UserRepository;
import org.springframework.stereotype.Service;
import com.example.aiapp.entity.User;

import java.util.*;

@Service
public class UserService{
    private final UserRepository repo;

    public UserService(UserRepository repo){
        this.repo = repo;
    }

    public List<User> getAll(){
        return repo.findAll();
    }

    public User getById(Long id){
        return repo.findById(id).orElse(null);
    }
    public User save(User u){
        return repo.save(u);
    }
}