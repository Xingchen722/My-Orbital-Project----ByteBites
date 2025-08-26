package com.example.demo.dto;

import com.example.demo.entity.User;

public class AuthResponse {

    private String status;
    private String message;
    private String token;
    private User user;

    public AuthResponse(String status, String message, String token, User user) {
        this.status = status;
        this.message = message;
        this.token = token;
        this.user = user;
    }

    // Getters and Setters
}
