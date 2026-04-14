package com.nackorea.backend.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.sql.DataSource;
import java.sql.Connection;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api")
public class HealthController {

    @Autowired
    private DataSource dataSource;

    // 기본 상태 체크
    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> health() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "UP");
        response.put("message", "NAC KOREA API 서버 정상 동작 중");
        response.put("timestamp", LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        response.put("version", "1.0.0");
        return ResponseEntity.ok(response);
    }

    // DB 연결 상태 포함 상세 체크
    @GetMapping("/health/detail")
    public ResponseEntity<Map<String, Object>> healthDetail() {
        Map<String, Object> response = new HashMap<>();
        Map<String, Object> db = new HashMap<>();

        // DB 연결 체크
        try (Connection conn = dataSource.getConnection()) {
            db.put("status", "UP");
            db.put("database", conn.getCatalog());
            db.put("url", conn.getMetaData().getURL());
        } catch (Exception e) {
            db.put("status", "DOWN");
            db.put("error", e.getMessage());
            response.put("status", "DOWN");
            response.put("message", "DB 연결 실패");
            response.put("db", db);
            response.put("timestamp", LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
            return ResponseEntity.status(503).body(response);
        }

        // 서버 정보
        Map<String, Object> server = new HashMap<>();
        server.put("javaVersion", System.getProperty("java.version"));
        server.put("osName", System.getProperty("os.name"));
        server.put("freeMemory", Runtime.getRuntime().freeMemory() / 1024 / 1024 + "MB");
        server.put("totalMemory", Runtime.getRuntime().totalMemory() / 1024 / 1024 + "MB");

        response.put("status", "UP");
        response.put("message", "모든 서비스 정상 동작 중");
        response.put("timestamp", LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        response.put("version", "1.0.0");
        response.put("db", db);
        response.put("server", server);

        return ResponseEntity.ok(response);
    }

    // ping 체크
    @GetMapping("/ping")
    public ResponseEntity<Map<String, String>> ping() {
        Map<String, String> response = new HashMap<>();
        response.put("result", "pong");
        response.put("timestamp", LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        return ResponseEntity.ok(response);
    }
}