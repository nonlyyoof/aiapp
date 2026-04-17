package com.example.aiapp.entity;

import jakarta.persistence.*;

public class User{

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;
    private String groupName;

    public User(String name, String groupName){
        this.name = name;
        this.groupName = groupName;
    }
}