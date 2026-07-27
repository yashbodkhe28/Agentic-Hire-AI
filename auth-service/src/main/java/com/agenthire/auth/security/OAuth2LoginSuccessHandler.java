package com.agenthire.auth.security;

import com.agenthire.auth.dto.AuthResponse;
import com.agenthire.auth.entity.AuthProvider;
import com.agenthire.auth.entity.Role;
import com.agenthire.auth.entity.RoleName;
import com.agenthire.auth.entity.User;
import com.agenthire.auth.repository.RoleRepository;
import com.agenthire.auth.repository.UserRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.security.web.authentication.SimpleUrlAuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.util.Map;

@Component
@RequiredArgsConstructor
@Slf4j
public class OAuth2LoginSuccessHandler extends SimpleUrlAuthenticationSuccessHandler {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final JwtTokenProvider jwtTokenProvider;
    private final CustomUserDetailsService userDetailsService;
    private final ObjectMapper objectMapper;

    @Override
    public void onAuthenticationSuccess(HttpServletRequest request,
                                        HttpServletResponse response,
                                        Authentication authentication) throws IOException, ServletException {
        OAuth2User oAuth2User = (OAuth2User) authentication.getPrincipal();
        Map<String, Object> attributes = oAuth2User.getAttributes();

        String email = (String) attributes.get("email");
        String firstName = (String) attributes.getOrDefault("given_name", "");
        String lastName = (String) attributes.getOrDefault("family_name", "");
        String avatarUrl = (String) attributes.getOrDefault("picture", null);
        String providerId = (String) attributes.get("sub");

        // Find or create user
        User user = userRepository.findByEmail(email).orElseGet(() -> {
            Role candidateRole = roleRepository.findByName(RoleName.CANDIDATE)
                    .orElseThrow(() -> new RuntimeException("Default role not found"));
            return User.builder()
                    .email(email)
                    .firstName(firstName)
                    .lastName(lastName)
                    .avatarUrl(avatarUrl)
                    .provider(AuthProvider.GOOGLE)
                    .providerId(providerId)
                    .role(candidateRole)
                    .isActive(true)
                    .isEmailVerified(true)
                    .build();
        });

        // Update OAuth fields if changed
        user.setAvatarUrl(avatarUrl);
        user.setProviderId(providerId);
        userRepository.save(user);

        // Generate tokens
        var userDetails = userDetailsService.loadUserByUsername(email);
        String accessToken = jwtTokenProvider.generateAccessToken(userDetails);
        String refreshToken = jwtTokenProvider.generateRefreshToken(userDetails);

        response.setContentType("application/json");
        response.setStatus(HttpServletResponse.SC_OK);
        objectMapper.writeValue(response.getOutputStream(), AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .expiresIn(jwtTokenProvider.getExpirationMs())
                .build());
    }
}
