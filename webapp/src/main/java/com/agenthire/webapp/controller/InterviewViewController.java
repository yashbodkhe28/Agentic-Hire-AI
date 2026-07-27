package com.agenthire.webapp.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@Controller
public class InterviewViewController {

    @GetMapping("/interview/{id}")
    public String interviewRoom(@PathVariable("id") Long id) {
        return "interview/room";
    }

    @GetMapping("/coding/{sessionId}")
    public String codingEditor(@PathVariable("sessionId") String sessionId) {
        return "interview/coding-editor";
    }
}
