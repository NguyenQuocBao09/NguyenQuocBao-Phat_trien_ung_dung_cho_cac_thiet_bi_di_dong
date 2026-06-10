package com.nguyenquocbao.back_end.controller;

import com.nguyenquocbao.back_end.payload.request.LoginRequest;
import com.nguyenquocbao.back_end.payload.request.RegisterRequest;
import com.nguyenquocbao.back_end.payload.request.TokenRequest;
import com.nguyenquocbao.back_end.payload.response.AuthResponse;
import com.nguyenquocbao.back_end.service.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    // 1. API Đăng ký bằng Email & Password truyền thống
    @PostMapping("/register")
    public ResponseEntity<String> register(@RequestBody RegisterRequest request) {
        String result = authService.register(request);
        return ResponseEntity.ok(result);
    }

    // 2. API Đăng nhập bằng Email & Password truyền thống -> Trả về mã JWT
    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@RequestBody LoginRequest request) {
        AuthResponse response = authService.login(request);
        return ResponseEntity.ok(response);
    }

    // 3. API Đăng nhập / Đăng ký bằng Tài khoản Google (OAuth2)
    @PostMapping("/google")
    public ResponseEntity<AuthResponse> loginWithGoogle(@RequestBody TokenRequest request) {
        AuthResponse response = authService.loginWithGoogle(request.getToken());
        return ResponseEntity.ok(response);
    }

    // 4. API Đăng nhập / Đăng ký bằng Tài khoản Facebook (OAuth2)
    @PostMapping("/facebook")
    public ResponseEntity<AuthResponse> loginWithFacebook(@RequestBody TokenRequest request) {
        AuthResponse response = authService.loginWithFacebook(request.getToken());
        return ResponseEntity.ok(response);
    }
}
