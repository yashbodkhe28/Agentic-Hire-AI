package com.agenthire.auth.service;

import com.agenthire.auth.dto.*;
import com.agenthire.auth.entity.*;
import com.agenthire.auth.exception.ResourceNotFoundException;
import com.agenthire.auth.exception.TokenRefreshException;
import com.agenthire.auth.exception.UserAlreadyExistsException;
import com.agenthire.auth.kafka.UserEventProducer;
import com.agenthire.auth.repository.*;
import com.agenthire.auth.security.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class AuthService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final LoginHistoryRepository loginHistoryRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;
    private final JwtTokenProvider jwtTokenProvider;
    private final CustomUserDetailsService userDetailsService;
    private final RedisTokenBlacklistService tokenBlacklistService;
    private final UserEventProducer userEventProducer;

    public AuthResponse register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new UserAlreadyExistsException("User already exists with email: " + request.getEmail());
        }

        RoleName roleName;
        try {
            roleName = RoleName.valueOf(request.getRole().toUpperCase());
            if (roleName == RoleName.ADMIN) {
                roleName = RoleName.CANDIDATE; // Prevent self-registration as admin
            }
        } catch (IllegalArgumentException e) {
            roleName = RoleName.CANDIDATE;
        }

        final RoleName roleNameFinal = roleName;
        Role role = roleRepository.findByName(roleName)
                .orElseThrow(() -> new ResourceNotFoundException("Role not found: " + roleNameFinal));

        User user = User.builder()
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .firstName(request.getFirstName())
                .lastName(request.getLastName())
                .phone(request.getPhone())
                .role(role)
                .provider(AuthProvider.LOCAL)
                .isActive(true)
                .isEmailVerified(false)
                .build();

        userRepository.save(user);
        log.info("New user registered: {} with role {}", user.getEmail(), roleName);

        // Publish Kafka event
        userEventProducer.publishUserRegistered(user);

        UserDetails userDetails = userDetailsService.loadUserByUsername(user.getEmail());
        String accessToken = jwtTokenProvider.generateAccessToken(userDetails, user.getId());
        String refreshToken = saveRefreshToken(user, userDetails);

        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .expiresIn(jwtTokenProvider.getExpirationMs())
                .user(mapToUserDto(user))
                .build();
    }

    public AuthResponse login(LoginRequest request, String ipAddress, String userAgent) {
        try {
            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword())
            );

            UserDetails userDetails = (UserDetails) authentication.getPrincipal();
            User user = userRepository.findByEmail(userDetails.getUsername())
                    .orElseThrow(() -> new ResourceNotFoundException("User not found"));

            // Save login history - success
            saveLoginHistory(user, ipAddress, userAgent, LoginStatus.SUCCESS);

            // Publish Kafka event
            userEventProducer.publishUserLoggedIn(user);

            String accessToken = jwtTokenProvider.generateAccessToken(userDetails, user.getId());
            String refreshToken = saveRefreshToken(user, userDetails);

            return AuthResponse.builder()
                    .accessToken(accessToken)
                    .refreshToken(refreshToken)
                    .expiresIn(jwtTokenProvider.getExpirationMs())
                    .user(mapToUserDto(user))
                    .build();

        } catch (Exception e) {
            // Log failed attempt
            userRepository.findByEmail(request.getEmail()).ifPresent(user ->
                    saveLoginHistory(user, ipAddress, userAgent, LoginStatus.FAILED)
            );
            throw e;
        }
    }

    public AuthResponse refreshToken(TokenRefreshRequest request) {
        String tokenStr = request.getRefreshToken();

        RefreshToken refreshToken = refreshTokenRepository.findByToken(tokenStr)
                .orElseThrow(() -> new TokenRefreshException("Refresh token not found"));

        if (refreshToken.getIsRevoked() || refreshToken.isExpired()) {
            refreshTokenRepository.delete(refreshToken);
            throw new TokenRefreshException("Refresh token was expired or revoked. Please sign in again.");
        }

        User user = refreshToken.getUser();
        UserDetails userDetails = userDetailsService.loadUserByUsername(user.getEmail());
        String newAccessToken = jwtTokenProvider.generateAccessToken(userDetails, user.getId());
        String newRefreshToken = saveRefreshToken(user, userDetails);

        // Revoke old refresh token
        refreshToken.setIsRevoked(true);
        refreshTokenRepository.save(refreshToken);

        return AuthResponse.builder()
                .accessToken(newAccessToken)
                .refreshToken(newRefreshToken)
                .expiresIn(jwtTokenProvider.getExpirationMs())
                .user(mapToUserDto(user))
                .build();
    }

    public void logout(String accessToken) {
        // Blacklist the access token in Redis until it expires
        if (jwtTokenProvider.validateToken(accessToken)) {
            tokenBlacklistService.blacklistToken(accessToken, jwtTokenProvider.getExpirationMs());
        }

        // Revoke all refresh tokens for user
        try {
            String email = jwtTokenProvider.getUserEmailFromToken(accessToken);
            userRepository.findByEmail(email).ifPresent(user ->
                    refreshTokenRepository.revokeAllByUserId(user.getId())
            );
        } catch (Exception e) {
            log.warn("Could not revoke refresh tokens during logout: {}", e.getMessage());
        }
    }

    @Transactional(readOnly = true)
    public UserDto getCurrentUser(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + email));
        return mapToUserDto(user);
    }

    private String saveRefreshToken(User user, UserDetails userDetails) {
        // Revoke all existing refresh tokens
        refreshTokenRepository.revokeAllByUserId(user.getId());

        String tokenStr = jwtTokenProvider.generateRefreshToken(userDetails);
        RefreshToken refreshToken = RefreshToken.builder()
                .user(user)
                .token(tokenStr)
                .expiryDate(LocalDateTime.now().plusDays(7))
                .isRevoked(false)
                .build();
        refreshTokenRepository.save(refreshToken);
        return tokenStr;
    }

    private void saveLoginHistory(User user, String ipAddress, String userAgent, LoginStatus status) {
        try {
            LoginHistory history = LoginHistory.builder()
                    .user(user)
                    .ipAddress(ipAddress != null ? ipAddress : "unknown")
                    .userAgent(userAgent)
                    .status(status)
                    .build();
            loginHistoryRepository.save(history);
        } catch (Exception e) {
            log.error("Failed to save login history: {}", e.getMessage());
        }
    }

    private UserDto mapToUserDto(User user) {
        return UserDto.builder()
                .id(user.getId())
                .email(user.getEmail())
                .firstName(user.getFirstName())
                .lastName(user.getLastName())
                .phone(user.getPhone())
                .role(user.getRole().getName().name())
                .avatarUrl(user.getAvatarUrl())
                .isActive(user.getIsActive())
                .isEmailVerified(user.getIsEmailVerified())
                .build();
    }
}
