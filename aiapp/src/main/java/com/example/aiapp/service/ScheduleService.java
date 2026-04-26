package com.example.aiapp.service;

import com.example.aiapp.entity.ScheduleItem;
import com.example.aiapp.entity.Student;
import com.example.aiapp.repository.ScheduleItemRepository;
import org.springframework.stereotype.Service;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

@Service
public class ScheduleService {
    
    private final ScheduleItemRepository repository;
    
    public ScheduleService(ScheduleItemRepository repository) {
        this.repository = repository;
    }
    
    public List<ScheduleItem> getByStudentAndDay(Student student, String dayOfWeek) {
        return repository.findByStudentAndDayOfWeek(student, dayOfWeek);
    }
    
    public List<ScheduleItem> getByStudent(Student student) {
        return repository.findByStudentOrderByStartTime(student);
    }
    
    public ScheduleItem save(ScheduleItem item) {
        return repository.save(item);
    }
    
    public void saveAll(List<ScheduleItem> items) {
        repository.saveAll(items);
    }
}