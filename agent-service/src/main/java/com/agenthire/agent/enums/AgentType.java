package com.agenthire.agent.enums;

public enum AgentType {

    RESUME_ANALYZER("Resume Analyzer", "Analyzes resumes to extract skills, experience, and provide scoring"),
    JOB_MATCHER("Job Matcher", "Matches candidate profiles against job listings with compatibility scores"),
    INTERVIEW_QUESTION_GENERATOR("Interview Question Generator", "Generates role-specific interview questions across categories"),
    INTERVIEW_EVALUATOR("Interview Evaluator", "Evaluates candidate interview responses and provides scoring"),
    HIRING_RECOMMENDER("Hiring Recommender", "Synthesizes all evaluation data to produce hiring recommendations"),
    RECRUITER_COPILOT("Recruiter Copilot", "AI assistant for recruiters to generate JDs, plans, summaries, and feedback");

    private final String displayName;
    private final String description;

    AgentType(String displayName, String description) {
        this.displayName = displayName;
        this.description = description;
    }

    public String getDisplayName() {
        return displayName;
    }

    public String getDescription() {
        return description;
    }
}
