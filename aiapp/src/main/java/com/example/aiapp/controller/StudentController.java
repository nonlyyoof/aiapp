package com.example.aiapp.controller;

import com.example.aiapp.entity.ScheduleItem;
import com.example.aiapp.entity.Student;
import com.example.aiapp.service.ScheduleService;
import com.example.aiapp.service.StudentRecognitionService;
import com.example.aiapp.service.StudentService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/student")
public class StudentController {
    
    private final StudentService studentService;
    private final ScheduleService scheduleService;
    private final StudentRecognitionService recognitionService;
    
    public StudentController(StudentService studentService, 
                             ScheduleService scheduleService,
                             StudentRecognitionService recognitionService) {
        this.studentService = studentService;
        this.scheduleService = scheduleService;
        this.recognitionService = recognitionService;
    }
    
    @PostMapping("/register")
    public ResponseEntity<Student> register(@RequestBody Student student) {
        return ResponseEntity.ok(studentService.save(student));
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<Student> getStudent(@PathVariable Long id) {
        Student student = studentService.getById(id);
        return student != null ? ResponseEntity.ok(student) : ResponseEntity.notFound().build();
    }
    
    @PostMapping("/recognize")
    public ResponseEntity<Map<String, Object>> recognizeByFace(@RequestBody Map<String, String> request) {
        String faceEncoding = request.get("faceEncoding");
        Student student = recognitionService.findStudentByFace(faceEncoding);
        
        Map<String, Object> response = new HashMap<>();
        if (student != null) {
            response.put("success", true);
            response.put("student", student);
            response.put("message", "Здравствуйте, " + student.getFullName() + "!");
        } else {
            response.put("success", false);
            response.put("message", "Студент не найден. Пожалуйста, зарегистрируйтесь.");
        }
        return ResponseEntity.ok(response);
    }
    
    @GetMapping("/{id}/schedule/today")
    public ResponseEntity<List<ScheduleItem>> getTodaySchedule(@PathVariable Long id) {
        Student student = studentService.getById(id);
        if (student == null) return ResponseEntity.notFound().build();
        
        String today = LocalDate.now().getDayOfWeek().name();
        List<ScheduleItem> schedule = scheduleService.getByStudentAndDay(student, today);
        return ResponseEntity.ok(schedule);
    }
    
    @GetMapping("/{id}/schedule/current")
    public ResponseEntity<Map<String, Object>> getCurrentLesson(@PathVariable Long id) {
        Student student = studentService.getById(id);
        if (student == null) return ResponseEntity.notFound().build();
        
        String today = LocalDate.now().getDayOfWeek().name();
        LocalTime now = LocalTime.now();
        
        List<ScheduleItem> schedule = scheduleService.getByStudentAndDay(student, today);
        ScheduleItem currentLesson = schedule.stream()
            .filter(lesson -> now.isAfter(lesson.getStartTime()) && now.isBefore(lesson.getEndTime()))
            .findFirst()
            .orElse(null);
        
        Map<String, Object> response = new HashMap<>();
        if (currentLesson != null) {
            response.put("hasLesson", true);
            response.put("subject", currentLesson.getSubjectName());
            response.put("room", currentLesson.getRoomNumber());
            response.put("startTime", currentLesson.getStartTime().toString());
            response.put("endTime", currentLesson.getEndTime().toString());
            response.put("message", String.format("Сейчас идёт %s в аудитории %s", 
                currentLesson.getSubjectName(), currentLesson.getRoomNumber()));
        } else {
            response.put("hasLesson", false);
            response.put("message", "Сейчас нет пар");
        }
        return ResponseEntity.ok(response);
    }
    
    @GetMapping("/{id}/schedule/next")
    public ResponseEntity<Map<String, Object>> getNextLesson(@PathVariable Long id) {
        Student student = studentService.getById(id);
        if (student == null) return ResponseEntity.notFound().build();
        
        String today = LocalDate.now().getDayOfWeek().name();
        LocalTime now = LocalTime.now();
        
        List<ScheduleItem> schedule = scheduleService.getByStudentAndDay(student, today);
        ScheduleItem nextLesson = schedule.stream()
            .filter(lesson -> now.isBefore(lesson.getStartTime()))
            .findFirst()
            .orElse(null);
        
        Map<String, Object> response = new HashMap<>();
        if (nextLesson != null) {
            response.put("hasNext", true);
            response.put("subject", nextLesson.getSubjectName());
            response.put("room", nextLesson.getRoomNumber());
            response.put("startTime", nextLesson.getStartTime().toString());
            response.put("message", String.format("Следующая пара: %s в %s в аудитории %s",
                nextLesson.getSubjectName(), nextLesson.getStartTime(), nextLesson.getRoomNumber()));
        } else {
            response.put("hasNext", false);
            response.put("message", "Сегодня больше нет пар");
        }
        return ResponseEntity.ok(response);
    }
}