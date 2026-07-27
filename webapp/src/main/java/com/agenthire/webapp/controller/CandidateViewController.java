package com.agenthire.webapp.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/candidate")
public class CandidateViewController {

    @GetMapping("/dashboard")
    public String dashboard() {
        return "candidate/dashboard";
    }

    @GetMapping("/profile")
    public String profile() {
        return "candidate/profile";
    }

    @GetMapping("/resume")
    public String resume() {
        return "candidate/resume-upload";
    }

    @GetMapping("/jobs")
    public String jobs() {
        return "candidate/job-portal";
    }
}
