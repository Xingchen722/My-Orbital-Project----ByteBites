package com.example.demo.entity;

import java.time.LocalDateTime;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;

@Entity
public class Review {
    @Id
    private String id;
    private String canteenId;
    private String username;
    private String nickname;
    private double rating;
    private String comment;
    private LocalDateTime createdAt;
    private String reply;

    // Getter/Setter 省略，为简洁可用 Lombok 或 IDE 自动生成
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getCanteenId() { return canteenId; }
    public void setCanteenId(String canteenId) { this.canteenId = canteenId; }
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public String getNickname() { return nickname; }
    public void setNickname(String nickname) { this.nickname = nickname; }
    public double getRating() { return rating; }
    public void setRating(double rating) { this.rating = rating; }
    public String getComment() { return comment; }
    public void setComment(String comment) { this.comment = comment; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public String getReply() { return reply; }
    public void setReply(String reply) { this.reply = reply; }
}