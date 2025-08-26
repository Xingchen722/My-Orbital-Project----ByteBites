package com.example.demo.service;

import java.util.Optional;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.demo.entity.User;
import com.example.demo.repository.UserRepository;

@Service
@Transactional
public class UserService {
    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    public User createUser(User user) {
        // 加密密码
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        return userRepository.save(user);
    }

    public Optional<User> findByUsername(String username) {
        return userRepository.findByUsername(username);
    }

    public Optional<User> findByEmail(String email) {
        return userRepository.findByEmail(email);
    }

    public Optional<User> findById(Long userId) {
        return userRepository.findById(userId);
    }

    public User updateUser(User user) {
        return userRepository.save(user);
    }

    public User updateUserProfile(Long userId, String nickname, String avatar,
                                  User.DietaryPreference dietaryPreference,
                                  User.Language language) {
        Optional<User> userOpt = userRepository.findById(userId);
        if (userOpt.isPresent()) {
            User user = userOpt.get();
            if (nickname != null) user.setNickname(nickname);
            if (avatar != null) user.setAvatar(avatar);
            if (dietaryPreference != null) user.setDietaryPreference(dietaryPreference);
            if (language != null) user.setLanguage(language);
            return userRepository.save(user);
        }
        throw new RuntimeException("用户不存在");
    }

    public boolean existsByUsername(String username) {
        return userRepository.existsByUsername(username);
    }

    public boolean existsByEmail(String email) {
        return userRepository.existsByEmail(email);
    }

    public User addFavoriteCanteen(Long userId, String canteenId) {
        Optional<User> userOpt = userRepository.findById(userId);
        if (userOpt.isPresent()) {
            User user = userOpt.get();
            if (user.getFavoriteCanteenIds() == null) {
                user.setFavoriteCanteenIds(Set.of());
            }
            user.getFavoriteCanteenIds().add(canteenId);
            return userRepository.save(user);
        }
        throw new RuntimeException("用户不存在");
    }

    public User removeFavoriteCanteen(Long userId, String canteenId) {
        Optional<User> userOpt = userRepository.findById(userId);
        if (userOpt.isPresent()) {
            User user = userOpt.get();
            if (user.getFavoriteCanteenIds() != null) {
                user.getFavoriteCanteenIds().remove(canteenId);
                return userRepository.save(user);
            }
        }
        throw new RuntimeException("用户不存在");
    }

    public User save(User user) {
        return userRepository.save(user);
    }
}

