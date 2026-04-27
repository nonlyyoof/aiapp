package com.example.aiapp.entity;

import jakarta.persistence.*;

@Entity
public class Schedule{

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String subject;
    private String room;
    private String time;

    private Long userId;

}