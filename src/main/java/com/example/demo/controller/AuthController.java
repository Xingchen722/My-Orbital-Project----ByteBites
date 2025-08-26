package com.example.demo.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.demo.dto.AuthResponse;
import com.example.demo.dto.LoginRequest;
import com.example.demo.dto.RegisterRequest;
import com.example.demo.entity.User;
import com.example.demo.service.AuthService;
import com.example.demo.service.UserService;
import com.example.demo.util.JwtUtils;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    @Autowired
    private AuthenticationManager authenticationManager;

    @Autowired
    private UserService userService;

    @Autowired
    private AuthService authService;

    @Autowired
    private JwtUtils jwtUtil;

    @PostMapping("/register")
    public ResponseEntity<?> register(@Valid @RequestBody RegisterRequest request) {
        try {
            // 检查用户名是否已存在
            if (userService.existsByUsername(request.getUsername())) {
                return ResponseEntity.badRequest()
                        .body(new AuthResponse("error", "用户名已存在", null, null));
            }

            // 检查邮箱是否已存在
            if (userService.existsByEmail(request.getEmail())) {
                return ResponseEntity.badRequest()
                        .body(new AuthResponse("error", "邮箱已存在", null, null));
            }

            // 创建用户
            User user = authService.register(request);

            // 生成 JWT token
            String token = jwtUtil.generateJwtToken(user.getUsername());

            return ResponseEntity.ok(new AuthResponse("success", "注册成功", token, user));

        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(new AuthResponse("error", "注册失败: " + e.getMessage(), null, null));
        }
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody LoginRequest request) {
        try {
            // 认证用户
            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(request.getUsername(), request.getPassword())
            );

            // 获取用户详情
            UserDetails userDetails = (UserDetails) authentication.getPrincipal();
            User user = userService.findByUsername(userDetails.getUsername()).orElseThrow(() -> new RuntimeException("用户不存在"));

            // 生成 JWT token
            String token = jwtUtil.generateJwtToken(userDetails.getUsername());

            return ResponseEntity.ok(new AuthResponse("success", "登录成功", token, user));

        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(new AuthResponse("error", "用户名或密码错误", null, null));
        }
    }

    @PostMapping("/logout")
    public ResponseEntity<?> logout(@RequestHeader("Authorization") String token) {
        // 实现注销逻辑，如撤销Token等
        return ResponseEntity.ok(new AuthResponse("success", "注销成功", null, null));
    }
}
