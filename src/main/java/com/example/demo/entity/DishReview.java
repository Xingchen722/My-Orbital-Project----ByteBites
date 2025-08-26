package com.example.demo.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDateTime;

@Entity
@Table(name = "dish_reviews")
public class DishReview {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "canteen_id", nullable = false)
    @NotBlank(message = "餐厅ID不能为空")
    private String canteenId;

    @Column(name = "dish_name", nullable = false)
    @NotBlank(message = "菜品名称不能为空")
    private String dishName;

    @Column(nullable = false)
    @NotBlank(message = "用户名不能为空")
    private String username;

    @Column(nullable = false)
    @NotBlank(message = "昵称不能为空")
    private String nickname;

    @Column(nullable = false)
    @NotNull(message = "评分不能为空")
    @DecimalMin(value = "1.0", message = "评分不能小于1")
    @DecimalMax(value = "5.0", message = "评分不能大于5")
    private Double rating;

    @Column(columnDefinition = "TEXT")
    @NotBlank(message = "评价内容不能为空")
    private String comment;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    // 构造函数
    public DishReview() {}

    public DishReview(String canteenId, String dishName, String username, String nickname, Double rating, String comment) {
        this.canteenId = canteenId;
        this.dishName = dishName;
        this.username = username;
        this.nickname = nickname;
        this.rating = rating;
        this.comment = comment;
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getCanteenId() { return canteenId; }
    public void setCanteenId(String canteenId) { this.canteenId = canteenId; }

    public String getDishName() { return dishName; }
    public void setDishName(String dishName) { this.dishName = dishName; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getNickname() { return nickname; }
    public void setNickname(String nickname) { this.nickname = nickname; }

    public Double getRating() { return rating; }
    public void setRating(Double rating) { this.rating = rating; }

    public String getComment() { return comment; }
    public void setComment(String comment) { this.comment = comment; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
