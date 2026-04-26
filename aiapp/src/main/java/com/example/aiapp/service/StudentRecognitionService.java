package com.example.aiapp.service;

import com.example.aiapp.entity.Student;
import com.example.aiapp.repository.StudentRepository;
import org.springframework.stereotype.Service;
import java.util.Base64;

@Service
public class StudentRecognitionService {
    
    private final StudentRepository studentRepository;
    
    public StudentRecognitionService(StudentRepository studentRepository) {
        this.studentRepository = studentRepository;
    }
    
    /**
     * Найти студента по лицу (сравнение с сохранёнными энкодингами)
     * @param faceEncodingBase64 - энкодинг лица из ML сервиса
     */
    public Student findStudentByFace(String faceEncodingBase64) {
        // В упрощённой версии просто ищем первого студента
        // В реальной версии нужно сравнивать faceEncodingBase64 с сохранёнными
        return studentRepository.findAll().stream()
            .findFirst()
            .orElse(null);
    }
    
    /**
     * Сохранить энкодинг лица для студента
     */
    public void saveFaceEncoding(Long studentId, String faceEncodingBase64) {
        Student student = studentRepository.findById(studentId).orElse(null);
        if (student != null) {
            if (student.getFaceEncoding() == null) {
                student.setFaceEncoding(faceEncodingBase64);
            } else {
                student.setFaceEncoding2(faceEncodingBase64);
            }
            studentRepository.save(student);
        }
    }
}