package com.example.demo.controller;

import com.example.demo.entity.User;
import com.example.demo.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/user-profile")
public class UserProfileController {
    @Autowired
    private UserService userService;

    @GetMapping("/{userId}")
    public User getUserProfile(@PathVariable Long userId) {
        return userService.findById(userId).orElse(null);
    }

    @PutMapping("/{userId}")
    public User updateUserProfile(@PathVariable Long userId, @RequestBody User update) {
        return userService.updateUserProfile(
                userId,
                update.getNickname(),
                update.getAvatar(),
                update.getDietaryPreference(),
                update.getLanguage()
        );
    }
} 