package com.example.aiapp.repository;

import com.example.aiapp.entity.Schedule;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ScheduleRepository extends JpaRepository<Schedule, Long>{
    List<Schedule> findByUserId(Long userId);
}