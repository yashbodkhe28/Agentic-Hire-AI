package com.agenthire.webapp.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/recruiter")
public class RecruiterViewController {

    @GetMapping("/dashboard")
    public String dashboard() {
        return "recruiter/dashboard";
    }

    @GetMapping("/jobs/new")
    public String createJob() {
        return "recruiter/create-job";
    }

    @GetMapping("/applications")
    public String applications() {
        return "recruiter/applications";
    }

    @GetMapping("/copilot")
    public String copilot() {
        return "recruiter/copilot";
    }
}
