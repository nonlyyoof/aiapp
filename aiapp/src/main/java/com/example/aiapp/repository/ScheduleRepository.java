package com.example.aiapp.repository;

import com.example.aiapp.entity.ScheduleItem;
import com.example.aiapp.entity.Student;
import org.springframework.data.jpa.repository.JpaRepository;
import java.time.LocalTime;
import java.util.List;

public interface ScheduleItemRepository extends JpaRepository<ScheduleItem, Long> {
    List<ScheduleItem> findByStudentAndDayOfWeek(Student student, String dayOfWeek);
    List<ScheduleItem> findByStudentOrderByStartTime(Student student);
}