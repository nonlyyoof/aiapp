package com.example.aiapp.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "students")
public class Student {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(unique = true, nullable = false)
    private String studentId; // Номер студенческого
    
    @Column(nullable = false)
    private String fullName;
    
    private String groupName;
    private String email;
    private String phone;
    
    @Column(length = 5000)
    private String faceEncoding; // Base64 лицо для распознавания
    
    @Column(length = 5000)
    private String faceEncoding2; // Второе фото для точности
    
    @OneToMany(mappedBy = "student", cascade = CascadeType.ALL)
    private List<ScheduleItem> schedule = new ArrayList<>();
    
    private LocalDateTime createdAt;
    private LocalDateTime lastLoginAt;
    
    // Конструкторы
    public Student() {}
    
    public Student(String studentId, String fullName, String groupName) {
        this.studentId = studentId;
        this.fullName = fullName;
        this.groupName = groupName;
        this.createdAt = LocalDateTime.now();
    }
    
    // Геттеры и сеттеры
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public String getStudentId() { return studentId; }
    public void setStudentId(String studentId) { this.studentId = studentId; }
    
    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    
    public String getGroupName() { return groupName; }
    public void setGroupName(String groupName) { this.groupName = groupName; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    
    public String getFaceEncoding() { return faceEncoding; }
    public void setFaceEncoding(String faceEncoding) { this.faceEncoding = faceEncoding; }
    
    public String getFaceEncoding2() { return faceEncoding2; }
    public void setFaceEncoding2(String faceEncoding2) { this.faceEncoding2 = faceEncoding2; }
    
    public List<ScheduleItem> getSchedule() { return schedule; }
    public void setSchedule(List<ScheduleItem> schedule) { this.schedule = schedule; }
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    
    public LocalDateTime getLastLoginAt() { return lastLoginAt; }
    public void setLastLoginAt(LocalDateTime lastLoginAt) { this.lastLoginAt = lastLoginAt; }
}