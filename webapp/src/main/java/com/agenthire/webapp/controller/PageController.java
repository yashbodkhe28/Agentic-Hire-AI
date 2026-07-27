package com.agenthire.webapp.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * Page Controller - maps URL paths to JSP views.
 * Auth is handled client-side via JWT in localStorage.
 */
@Controller
public class PageController {

    @GetMapping("/")
    public String index() {
        return "index";
    }

    @GetMapping("/login")
    public String login(@RequestParam(required = false) String error, Model model) {
        if (error != null) model.addAttribute("error", "Invalid credentials");
        return "login";
    }

    @GetMapping("/register")
    public String register(@RequestParam(required = false) String role, Model model) {
        if (role != null) model.addAttribute("role", role);
        return "register";
    }

    @GetMapping("/dashboard")
    public String dashboard() {
        return "dashboard";
    }

    @GetMapping("/jobs")
    public String jobs() {
        return "jobs";
    }

    @GetMapping("/candidates")
    public String candidates() {
        return "candidates";
    }

    @GetMapping("/interviews")
    public String interviews() {
        return "interviews";
    }

    @GetMapping("/agents")
    public String agents() {
        return "agents";
    }

    @GetMapping("/analytics")
    public String analytics() {
        return "analytics";
    }

    @GetMapping("/profile")
    public String profile() {
        return "profile";
    }

    @GetMapping("/notifications")
    public String notifications() {
        return "dashboard";
    }

    @GetMapping("/admin")
    public String admin() {
        return "dashboard";
    }

    // OAuth2 success redirect
    @GetMapping("/oauth2/success")
    public String oauth2Success() {
        return "redirect:/dashboard";
    }
}
