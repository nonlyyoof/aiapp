package com.example.aiapp.entity;

import jakarta.persistence.*;

import java.security.PublicKey;

@Entity
public class Message{

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String role;
    private String text;
    public Message() {}
    public Message(String role, String text) {
        this.role = role;
        this.text = text;
    }
    public Long getId() {return id; }
    public String getRole() {return role; }
    public String getText() {return text; }

    public void setRole(String role) { this.role = role; }
    public void setText(String text) { this.text = text; }
}