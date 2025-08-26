package com.example.demo.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.time.LocalDateTime;
import java.util.Set;
@Entity
@Table(name = "users")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long userId;

    @Column(unique = true, nullable = false)
    @NotBlank(message = "用户名不能为空")
    @Size(min = 3, max = 50, message = "用户名长度必须在3-50字符之间")
    private String username;

    @Column(nullable = false)
    @NotBlank(message = "密码不能为空")
    @Size(min = 6, message = "密码长度至少6位")
    @JsonIgnore
    private String password;

    @Column(unique = true, nullable = false)
    @Email(message = "邮箱格式不正确")
    @NotBlank(message = "邮箱不能为空")
    private String email;

    @Column(nullable = false)
    @NotBlank(message = "昵称不能为空")
    private String nickname;

    private String avatar;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private UserRole role = UserRole.STUDENT;

    @Enumerated(EnumType.STRING)
    private DietaryPreference dietaryPreference = DietaryPreference.NO_PREFERENCE;

    @Enumerated(EnumType.STRING)
    private Language language = Language.ENGLISH;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    // 用户收藏的餐厅
    @ElementCollection
    @CollectionTable(name = "user_favorite_canteens",
            joinColumns = @JoinColumn(name = "user_id"))
    @Column(name = "canteen_id")
    private Set<String> favoriteCanteenIds;

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
    public User() {}

    public User(String username, String password, String email, String nickname) {
        this.username = username;
        this.password = password;
        this.email = email;
        this.nickname = nickname;
    }

    // Getters and Setters
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getNickname() { return nickname; }
    public void setNickname(String nickname) { this.nickname = nickname; }

    public String getAvatar() { return avatar; }
    public void setAvatar(String avatar) { this.avatar = avatar; }

    public UserRole getRole() { return role; }
    public void setRole(UserRole role) { this.role = role; }

    public DietaryPreference getDietaryPreference() { return dietaryPreference; }
    public void setDietaryPreference(DietaryPreference dietaryPreference) {
        this.dietaryPreference = dietaryPreference;
    }

    public Language getLanguage() { return language; }
    public void setLanguage(Language language) { this.language = language; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public Set<String> getFavoriteCanteenIds() { return favoriteCanteenIds; }
    public void setFavoriteCanteenIds(Set<String> favoriteCanteenIds) {
        this.favoriteCanteenIds = favoriteCanteenIds;
    }

    // 枚举类型
    public enum UserRole {
        STUDENT, VENDOR
    }

    public enum DietaryPreference {
        NO_PREFERENCE, VEGETARIAN, VEGAN, HALAL, KOSHER,
        GLUTEN_FREE, NUT_ALLERGY, LACTOSE_INTOLERANT, PESCATARIAN
    }

    public enum Language {
        ENGLISH, CHINESE
    }
}