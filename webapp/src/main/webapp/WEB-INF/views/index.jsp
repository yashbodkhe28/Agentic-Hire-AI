<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AgentHire AI — Agentic Recruitment Ecosystem</title>
    <meta name="description" content="Next-generation AI-powered recruitment platform with autonomous agents, smart matching, and real-time interview tools.">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&family=JetBrains+Mono:wght@400;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/style.css">
</head>
<body class="landing-page">

    <!-- Animated Background -->
    <div class="bg-animated">
        <div class="orb orb-1"></div>
        <div class="orb orb-2"></div>
        <div class="orb orb-3"></div>
        <div class="particles" id="particles"></div>
    </div>

    <!-- 3D Scene Canvas -->
    <canvas id="three-canvas"></canvas>

    <!-- Navbar -->
    <nav class="navbar navbar-expand-lg navbar-dark fixed-top glass-nav">
        <div class="container">
            <a class="navbar-brand brand-logo" href="/">
                <div class="brand-icon"><i class="fas fa-robot"></i></div>
                <span class="brand-text">Agent<span class="brand-accent">Hire</span> AI</span>
            </a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navMenu">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navMenu">
                <ul class="navbar-nav ms-auto align-items-center gap-2">
                    <li class="nav-item"><a class="nav-link" href="#features">Features</a></li>
                    <li class="nav-item"><a class="nav-link" href="#agents">AI Agents</a></li>
                    <li class="nav-item"><a class="nav-link" href="#how-it-works">How it Works</a></li>
                    <li class="nav-item"><a class="nav-link" href="#tech">Tech Stack</a></li>
                    <li class="nav-item"><a class="btn btn-outline-light btn-sm px-4" href="/login">Sign In</a></li>
                    <li class="nav-item"><a class="btn btn-primary-gradient btn-sm px-4" href="/register">Get Started</a></li>
                </ul>
            </div>
        </div>
    </nav>

    <!-- Hero Section -->
    <section class="hero-section">
        <div class="container">
            <div class="row align-items-center min-vh-100">
                <div class="col-lg-6" data-aos="fade-right">
                    <div class="hero-badge mb-4">
                        <i class="fas fa-bolt"></i>
                        <span>Powered by GPT-4 & Gemini Pro</span>
                    </div>
                    <h1 class="hero-title">
                        Hire Smarter with
                        <span class="gradient-text">Autonomous AI</span>
                        Agents
                    </h1>
                    <p class="hero-subtitle">
                        Transform your recruitment with 6 specialized AI agents that analyze resumes,
                        match candidates, generate questions, evaluate interviews, and make hiring decisions
                        — all in real time.
                    </p>
                    <div class="hero-stats">
                        <div class="stat-item">
                            <div class="stat-value counter" data-target="85">0</div>
                            <div class="stat-label">% Faster Hiring</div>
                        </div>
                        <div class="stat-divider"></div>
                        <div class="stat-item">
                            <div class="stat-value counter" data-target="94">0</div>
                            <div class="stat-label">% Match Accuracy</div>
                        </div>
                        <div class="stat-divider"></div>
                        <div class="stat-item">
                            <div class="stat-value counter" data-target="6">0</div>
                            <div class="stat-label">AI Agents</div>
                        </div>
                    </div>
                    <div class="hero-cta mt-5">
                        <a href="/register" class="btn btn-primary-gradient btn-lg me-3">
                            <i class="fas fa-rocket me-2"></i>Start Free Trial
                        </a>
                        <a href="#features" class="btn btn-glass btn-lg">
                            <i class="fas fa-play me-2"></i>See How It Works
                        </a>
                    </div>
                </div>
                <div class="col-lg-6 d-none d-lg-flex justify-content-center" data-aos="fade-left">
                    <div class="hero-visual">
                        <div class="dashboard-preview glass-card">
                            <div class="preview-header">
                                <div class="dot red"></div><div class="dot yellow"></div><div class="dot green"></div>
                                <span class="preview-title">AI Analysis Dashboard</span>
                            </div>
                            <div class="preview-body">
                                <div class="agent-card-mini active-agent">
                                    <div class="agent-icon"><i class="fas fa-file-alt"></i></div>
                                    <div class="agent-info">
                                        <div class="agent-name">Resume Analyzer</div>
                                        <div class="agent-status">
                                            <div class="pulse-dot"></div>Analyzing...
                                        </div>
                                    </div>
                                    <div class="agent-score">92%</div>
                                </div>
                                <div class="agent-card-mini">
                                    <div class="agent-icon"><i class="fas fa-crosshairs"></i></div>
                                    <div class="agent-info">
                                        <div class="agent-name">Job Matcher</div>
                                        <div class="agent-status">Queued</div>
                                    </div>
                                    <div class="agent-score text-muted">—</div>
                                </div>
                                <div class="score-chart mt-3">
                                    <div class="score-bar-item">
                                        <span>Technical</span>
                                        <div class="score-bar"><div class="score-fill" style="width:88%"></div></div>
                                        <span>88</span>
                                    </div>
                                    <div class="score-bar-item">
                                        <span>Experience</span>
                                        <div class="score-bar"><div class="score-fill" style="width:75%"></div></div>
                                        <span>75</span>
                                    </div>
                                    <div class="score-bar-item">
                                        <span>Match</span>
                                        <div class="score-bar"><div class="score-fill" style="width:92%"></div></div>
                                        <span>92</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <!-- Floating cards -->
                        <div class="float-card float-card-1">
                            <i class="fas fa-check-circle text-success me-2"></i>
                            <span>Candidate Shortlisted</span>
                        </div>
                        <div class="float-card float-card-2">
                            <i class="fas fa-brain text-primary me-2"></i>
                            <span>AI Score: 94%</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Features Section -->
    <section class="features-section" id="features">
        <div class="container">
            <div class="section-header text-center mb-5">
                <div class="section-badge">Enterprise Features</div>
                <h2 class="section-title">Everything You Need to <span class="gradient-text">Hire Brilliantly</span></h2>
                <p class="section-subtitle">A complete ecosystem where AI and humans collaborate to find the perfect talent match.</p>
            </div>
            <div class="row g-4">
                <div class="col-md-4">
                    <div class="feature-card glass-card h-100">
                        <div class="feature-icon"><i class="fas fa-microchip"></i></div>
                        <h3 class="feature-title">6 Autonomous AI Agents</h3>
                        <p class="feature-desc">Resume Analyzer, Job Matcher, Question Generator, Interview Evaluator, Hiring Recommender, and Recruiter Copilot work together in a pipeline.</p>
                        <div class="feature-badge">Strategy + Factory Pattern</div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="feature-card glass-card h-100">
                        <div class="feature-icon"><i class="fas fa-shield-alt"></i></div>
                        <h3 class="feature-title">Enterprise Security</h3>
                        <p class="feature-desc">JWT Authentication, Refresh Tokens, Google OAuth2, RBAC with Redis token blacklisting, and API Gateway rate limiting.</p>
                        <div class="feature-badge">Spring Security 6</div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="feature-card glass-card h-100">
                        <div class="feature-icon"><i class="fas fa-stream"></i></div>
                        <h3 class="feature-title">Event-Driven Architecture</h3>
                        <p class="feature-desc">Kafka-powered event streaming connects all 11 microservices. Real-time notifications, resume processing, and audit trails.</p>
                        <div class="feature-badge">Apache Kafka</div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="feature-card glass-card h-100">
                        <div class="feature-icon"><i class="fas fa-code"></i></div>
                        <h3 class="feature-title">Live Coding Interviews</h3>
                        <p class="feature-desc">Real-time collaborative code editor with WebSocket/STOMP. Supports 20+ languages with AI-powered evaluation and hints.</p>
                        <div class="feature-badge">WebSocket + STOMP</div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="feature-card glass-card h-100">
                        <div class="feature-icon"><i class="fas fa-chart-line"></i></div>
                        <h3 class="feature-title">Advanced Analytics</h3>
                        <p class="feature-desc">Prometheus metrics, Grafana dashboards, and Zipkin distributed tracing give full visibility into your hiring pipeline performance.</p>
                        <div class="feature-badge">Grafana + Prometheus</div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="feature-card glass-card h-100">
                        <div class="feature-icon"><i class="fas fa-server"></i></div>
                        <h3 class="feature-title">Cloud-Native Architecture</h3>
                        <p class="feature-desc">11 Spring Boot microservices, Eureka service discovery, Config Server, API Gateway, and Docker Compose orchestration.</p>
                        <div class="feature-badge">Docker + Spring Cloud</div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- AI Agents Section -->
    <section class="agents-section" id="agents">
        <div class="container">
            <div class="section-header text-center mb-5">
                <div class="section-badge">AI Agents</div>
                <h2 class="section-title">Meet Your <span class="gradient-text">Hiring Intelligence</span> Team</h2>
            </div>
            <div class="agents-pipeline">
                <div class="pipeline-line"></div>
                <div class="row g-4">
                    <div class="col-lg-4 col-md-6">
                        <div class="agent-card glass-card">
                            <div class="agent-number">01</div>
                            <div class="agent-icon-lg"><i class="fas fa-file-search"></i></div>
                            <h4>Resume Analyzer Agent</h4>
                            <p>Parses resumes, extracts skills/experience, detects projects, certifications, and calculates technical competency scores with gap analysis.</p>
                            <div class="agent-tags">
                                <span class="tag">Skill Extraction</span>
                                <span class="tag">Scoring</span>
                                <span class="tag">Gap Analysis</span>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-4 col-md-6">
                        <div class="agent-card glass-card">
                            <div class="agent-number">02</div>
                            <div class="agent-icon-lg"><i class="fas fa-bullseye"></i></div>
                            <h4>Job Matching Agent</h4>
                            <p>Computes multi-dimensional compatibility scores between candidates and jobs, provides hiring probability assessments and recommendations.</p>
                            <div class="agent-tags">
                                <span class="tag">Match Score</span>
                                <span class="tag">Compatibility</span>
                                <span class="tag">Salary Fit</span>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-4 col-md-6">
                        <div class="agent-card glass-card">
                            <div class="agent-number">03</div>
                            <div class="agent-icon-lg"><i class="fas fa-question-circle"></i></div>
                            <h4>Question Generator Agent</h4>
                            <p>Generates personalized technical, system design, behavioral, and coding questions tailored to the specific candidate's background.</p>
                            <div class="agent-tags">
                                <span class="tag">Personalized</span>
                                <span class="tag">Multi-Category</span>
                                <span class="tag">Adaptive</span>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-4 col-md-6">
                        <div class="agent-card glass-card">
                            <div class="agent-number">04</div>
                            <div class="agent-icon-lg"><i class="fas fa-clipboard-check"></i></div>
                            <h4>Interview Evaluator Agent</h4>
                            <p>Scores interview responses, provides detailed feedback per question, calculates category scores, and generates pass/fail decisions.</p>
                            <div class="agent-tags">
                                <span class="tag">Objective Scoring</span>
                                <span class="tag">Feedback</span>
                                <span class="tag">Pass/Fail</span>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-4 col-md-6">
                        <div class="agent-card glass-card">
                            <div class="agent-number">05</div>
                            <div class="agent-icon-lg"><i class="fas fa-award"></i></div>
                            <h4>Hiring Recommender Agent</h4>
                            <p>Aggregates all pipeline data and generates final HIRE/REJECT decisions with offer level, salary recommendations, and onboarding plan.</p>
                            <div class="agent-tags">
                                <span class="tag">Final Decision</span>
                                <span class="tag">Salary Rec.</span>
                                <span class="tag">Risk Analysis</span>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-4 col-md-6">
                        <div class="agent-card glass-card">
                            <div class="agent-number">06</div>
                            <div class="agent-icon-lg"><i class="fas fa-headset"></i></div>
                            <h4>Recruiter Copilot Agent</h4>
                            <p>AI assistant for recruiters — writes inclusive job descriptions, outreach emails, rejection letters, and provides strategic hiring advice.</p>
                            <div class="agent-tags">
                                <span class="tag">JD Writing</span>
                                <span class="tag">Emails</span>
                                <span class="tag">Strategy</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Tech Stack Section -->
    <section class="tech-section" id="tech">
        <div class="container">
            <div class="section-header text-center mb-5">
                <div class="section-badge">Technology</div>
                <h2 class="section-title">Built with <span class="gradient-text">Enterprise-Grade</span> Technology</h2>
            </div>
            <div class="tech-grid">
                <div class="tech-item"><i class="fab fa-java"></i><span>Java 17</span></div>
                <div class="tech-item"><div class="tech-icon-custom">SB</div><span>Spring Boot 3.2</span></div>
                <div class="tech-item"><div class="tech-icon-custom">SC</div><span>Spring Cloud</span></div>
                <div class="tech-item"><div class="tech-icon-custom">SS</div><span>Spring Security</span></div>
                <div class="tech-item"><div class="tech-icon-custom">JPA</div><span>Spring Data JPA</span></div>
                <div class="tech-item"><div class="tech-icon-custom">K</div><span>Apache Kafka</span></div>
                <div class="tech-item"><div class="tech-icon-custom">R</div><span>Redis</span></div>
                <div class="tech-item"><div class="tech-icon-custom">MY</div><span>MySQL 8</span></div>
                <div class="tech-item"><i class="fab fa-docker"></i><span>Docker</span></div>
                <div class="tech-item"><div class="tech-icon-custom">EU</div><span>Eureka</span></div>
                <div class="tech-item"><div class="tech-icon-custom">Z</div><span>Zipkin</span></div>
                <div class="tech-item"><div class="tech-icon-custom">G</div><span>Grafana</span></div>
                <div class="tech-item"><div class="tech-icon-custom">AI</div><span>OpenAI GPT-4</span></div>
                <div class="tech-item"><div class="tech-icon-custom">GE</div><span>Gemini Pro</span></div>
                <div class="tech-item"><div class="tech-icon-custom">WS</div><span>WebSocket</span></div>
                <div class="tech-item"><div class="tech-icon-custom">JWT</div><span>JWT Auth</span></div>
            </div>
        </div>
    </section>

    <!-- CTA Section -->
    <section class="cta-section">
        <div class="container text-center">
            <div class="cta-card glass-card">
                <div class="cta-glow"></div>
                <h2 class="cta-title">Ready to Transform Your <span class="gradient-text">Hiring Process</span>?</h2>
                <p class="cta-subtitle">Join the future of intelligent recruitment with AI-powered automation.</p>
                <div class="d-flex gap-3 justify-content-center flex-wrap">
                    <a href="/register?role=RECRUITER" class="btn btn-primary-gradient btn-lg">
                        <i class="fas fa-building me-2"></i>I'm a Recruiter
                    </a>
                    <a href="/register?role=CANDIDATE" class="btn btn-glass btn-lg">
                        <i class="fas fa-user me-2"></i>I'm a Candidate
                    </a>
                </div>
            </div>
        </div>
    </section>

    <!-- Footer -->
    <footer class="footer-section">
        <div class="container">
            <div class="row">
                <div class="col-md-4">
                    <div class="brand-logo mb-3">
                        <div class="brand-icon small"><i class="fas fa-robot"></i></div>
                        <span class="brand-text">Agent<span class="brand-accent">Hire</span> AI</span>
                    </div>
                    <p class="footer-desc">Next-generation agentic recruitment platform powered by Spring Boot microservices and AI.</p>
                </div>
                <div class="col-md-4">
                    <h6 class="footer-heading">Platform</h6>
                    <ul class="footer-links">
                        <li><a href="/jobs">Browse Jobs</a></li>
                        <li><a href="/candidates">Find Talent</a></li>
                        <li><a href="/agents">AI Agents</a></li>
                        <li><a href="/analytics">Analytics</a></li>
                    </ul>
                </div>
                <div class="col-md-4">
                    <h6 class="footer-heading">Tech Stack</h6>
                    <ul class="footer-links">
                        <li><a href="#">Spring Boot 3.2.5</a></li>
                        <li><a href="#">11 Microservices</a></li>
                        <li><a href="#">Kafka + Redis</a></li>
                        <li><a href="#">OpenAI + Gemini</a></li>
                    </ul>
                </div>
            </div>
            <hr class="footer-divider">
            <div class="text-center">
                <p class="footer-copy">&copy; 2024 AgentHire AI. Built with Spring Boot Microservices & Agentic AI.</p>
            </div>
        </div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/static/js/app.js"></script>
    <script src="${pageContext.request.contextPath}/static/js/three-scene.js"></script>
</body>
</html>
