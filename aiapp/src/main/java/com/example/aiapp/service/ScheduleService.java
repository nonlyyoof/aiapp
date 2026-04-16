package com.example.aiapp.service;

import com.example.aiapp.entity.Schedule;
import com.example.aiapp.repository.ScheduleRepository;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class ScheduleService{
    private final ScheduleRepository repo;

    public ScheduleService(ScheduleRepository repo){
        this.repo = repo;
    }

    public List<Schedule> getByUser(Long userId){
        return repo.findByUserId(userId);
    }

    public Schedule save(Schedule s){
        return repo.save(s);
    }
}