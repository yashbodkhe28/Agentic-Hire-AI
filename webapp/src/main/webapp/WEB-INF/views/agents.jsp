<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AI Agents — AgentHire AI</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/style.css">
</head>
<body>
    <div class="bg-animated"><div class="orb orb-1" style="opacity:0.06"></div><div class="orb orb-2" style="opacity:0.05"></div></div>

    <!-- Sidebar -->
    <aside class="sidebar">
        <div class="sidebar-logo">
            <a href="/" class="brand-logo text-decoration-none">
                <div class="brand-icon small"><i class="fas fa-robot"></i></div>
                <span class="brand-text ms-2">Agent<span class="brand-accent">Hire</span> AI</span>
            </a>
        </div>
        <nav class="sidebar-nav">
            <div class="nav-section">
                <a href="/dashboard" class="sidebar-link"><i class="fas fa-th-large"></i><span>Dashboard</span></a>
                <a href="/analytics" class="sidebar-link"><i class="fas fa-chart-line"></i><span>Analytics</span></a>
            </div>
            <div class="nav-section">
                <div class="nav-section-title">Recruitment</div>
                <a href="/jobs" class="sidebar-link"><i class="fas fa-briefcase"></i><span>Jobs</span></a>
                <a href="/candidates" class="sidebar-link"><i class="fas fa-users"></i><span>Candidates</span></a>
                <a href="/interviews" class="sidebar-link"><i class="fas fa-calendar-check"></i><span>Interviews</span></a>
            </div>
            <div class="nav-section">
                <div class="nav-section-title">AI</div>
                <a href="/agents" class="sidebar-link active"><i class="fas fa-robot"></i><span>AI Agents</span></a>
            </div>
            <div class="nav-section">
                <a href="/profile" class="sidebar-link"><i class="fas fa-user-circle"></i><span>Profile</span></a>
                <a href="#" onclick="logout()" class="sidebar-link" style="color:#ef4444"><i class="fas fa-sign-out-alt"></i><span>Sign Out</span></a>
            </div>
        </nav>
    </aside>

    <main class="main-content">
        <div class="topbar">
            <div>
                <h1 class="page-title">AI Agents Control Center</h1>
                <p style="color:var(--text-secondary);font-size:0.85rem;margin:0">
                    6 autonomous agents powered by <span style="color:#6366f1">GPT-4</span> &amp; <span style="color:#8b5cf6">Gemini Pro</span>
                </p>
            </div>
            <div class="topbar-actions">
                <div class="d-flex align-items-center gap-2 px-3 py-2 glass-card" style="border-radius:10px">
                    <div class="pulse-dot"></div>
                    <span style="font-size:0.82rem;font-weight:600;color:#10b981">All Agents Online</span>
                </div>
            </div>
        </div>

        <!-- Agent Tabs -->
        <ul class="nav nav-tabs agent-tabs mb-4" id="agentTabs">
            <li class="nav-item"><button class="nav-link active" data-bs-toggle="tab" data-bs-target="#tab-resume">
                <i class="fas fa-file-search me-1"></i>Resume Analyzer
            </button></li>
            <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#tab-matcher">
                <i class="fas fa-bullseye me-1"></i>Job Matcher
            </button></li>
            <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#tab-questions">
                <i class="fas fa-question-circle me-1"></i>Question Generator
            </button></li>
            <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#tab-evaluator">
                <i class="fas fa-clipboard-check me-1"></i>Interview Evaluator
            </button></li>
            <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#tab-hiring">
                <i class="fas fa-award me-1"></i>Hiring Recommender
            </button></li>
            <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#tab-copilot">
                <i class="fas fa-headset me-1"></i>Recruiter Copilot
            </button></li>
        </ul>

        <div class="tab-content">

            <!-- Tab 1: Resume Analyzer -->
            <div class="tab-pane fade show active" id="tab-resume">
                <div class="row g-4">
                    <div class="col-lg-5">
                        <div class="glass-card p-4 h-100">
                            <div class="agent-header mb-3">
                                <div class="agent-icon-lg mb-3" style="background:linear-gradient(135deg,#6366f1,#8b5cf6)"><i class="fas fa-file-search"></i></div>
                                <h4 class="fw-bold">Resume Analyzer Agent</h4>
                                <p style="color:var(--text-secondary);font-size:0.88rem">Parses resumes to extract skills, projects, experience, and calculate competency scores with gap analysis.</p>
                            </div>
                            <div class="mb-3">
                                <label class="form-label-dark">Resume Content *</label>
                                <textarea class="form-control form-control-dark" id="ra-resume" rows="8"
                                          placeholder="Paste full resume text here...&#10;&#10;Example:&#10;John Smith&#10;Senior Java Developer | 7 years exp.&#10;Skills: Java, Spring Boot, Kafka, Redis..."></textarea>
                            </div>
                            <div class="mb-3">
                                <label class="form-label-dark">Job Requirements (optional)</label>
                                <textarea class="form-control form-control-dark" id="ra-requirements" rows="3"
                                          placeholder="Paste job requirements for gap analysis..."></textarea>
                            </div>
                            <button class="btn btn-primary-gradient w-100 py-3" onclick="runResumeAnalyzer()">
                                <i class="fas fa-brain me-2"></i>Analyze Resume
                            </button>
                        </div>
                    </div>
                    <div class="col-lg-7">
                        <div class="glass-card p-4 h-100">
                            <div class="d-flex align-items-center justify-content-between mb-3">
                                <h5 class="fw-bold m-0">Analysis Output</h5>
                                <button class="btn btn-glass btn-sm" onclick="copyResult('ra-output')">
                                    <i class="fas fa-copy me-1"></i>Copy
                                </button>
                            </div>
                            <div id="ra-output" class="agent-output">
                                <div class="agent-placeholder">
                                    <i class="fas fa-robot fa-2x mb-3" style="color:rgba(99,102,241,0.3)"></i>
                                    <p>Paste resume content and click "Analyze Resume" to see AI insights</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Tab 2: Job Matcher -->
            <div class="tab-pane fade" id="tab-matcher">
                <div class="row g-4">
                    <div class="col-lg-5">
                        <div class="glass-card p-4 h-100">
                            <div class="agent-icon-lg mb-3" style="background:linear-gradient(135deg,#8b5cf6,#ec4899)"><i class="fas fa-bullseye"></i></div>
                            <h4 class="fw-bold">Job Matching Agent</h4>
                            <p style="color:var(--text-secondary);font-size:0.88rem;margin-bottom:20px">Multi-dimensional compatibility analysis between candidates and job openings.</p>
                            <div class="mb-3">
                                <label class="form-label-dark">Job Title</label>
                                <input type="text" class="form-control form-control-dark" id="jm-title" placeholder="e.g. Senior Java Developer">
                            </div>
                            <div class="mb-3">
                                <label class="form-label-dark">Job Requirements *</label>
                                <textarea class="form-control form-control-dark" id="jm-requirements" rows="5"
                                          placeholder="Paste job requirements/description..."></textarea>
                            </div>
                            <div class="mb-3">
                                <label class="form-label-dark">Candidate Profile *</label>
                                <textarea class="form-control form-control-dark" id="jm-profile" rows="5"
                                          placeholder="Paste candidate profile/resume..."></textarea>
                            </div>
                            <button class="btn btn-primary-gradient w-100 py-3" onclick="runJobMatcher()">
                                <i class="fas fa-crosshairs me-2"></i>Calculate Match Score
                            </button>
                        </div>
                    </div>
                    <div class="col-lg-7">
                        <div class="glass-card p-4 h-100">
                            <h5 class="fw-bold mb-3">Match Analysis Output</h5>
                            <div id="jm-output" class="agent-output">
                                <div class="agent-placeholder">
                                    <i class="fas fa-crosshairs fa-2x mb-3" style="color:rgba(139,92,246,0.3)"></i>
                                    <p>Fill in job and candidate details to get compatibility score</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Tab 3: Question Generator -->
            <div class="tab-pane fade" id="tab-questions">
                <div class="row g-4">
                    <div class="col-lg-5">
                        <div class="glass-card p-4 h-100">
                            <div class="agent-icon-lg mb-3" style="background:linear-gradient(135deg,#06b6d4,#6366f1)"><i class="fas fa-question-circle"></i></div>
                            <h4 class="fw-bold">Interview Question Generator</h4>
                            <p style="color:var(--text-secondary);font-size:0.88rem;margin-bottom:20px">Generates personalized, role-specific interview questions.</p>
                            <div class="mb-3">
                                <label class="form-label-dark">Job Role</label>
                                <input type="text" class="form-control form-control-dark" id="qg-role" placeholder="e.g. Senior Backend Engineer">
                            </div>
                            <div class="mb-3">
                                <label class="form-label-dark">Experience Level</label>
                                <select class="form-control form-control-dark" id="qg-level">
                                    <option value="ENTRY">Entry Level</option>
                                    <option value="MID" selected>Mid Level</option>
                                    <option value="SENIOR">Senior</option>
                                    <option value="LEAD">Lead</option>
                                </select>
                            </div>
                            <div class="mb-3">
                                <label class="form-label-dark">Candidate Skills</label>
                                <textarea class="form-control form-control-dark" id="qg-skills" rows="3"
                                          placeholder="Java, Spring Boot, Kafka, MySQL, Docker..."></textarea>
                            </div>
                            <div class="mb-3">
                                <label class="form-label-dark">Number of Questions</label>
                                <input type="number" class="form-control form-control-dark" id="qg-count" value="15" min="5" max="30">
                            </div>
                            <button class="btn btn-primary-gradient w-100 py-3" onclick="runQuestionGenerator()">
                                <i class="fas fa-magic me-2"></i>Generate Questions
                            </button>
                        </div>
                    </div>
                    <div class="col-lg-7">
                        <div class="glass-card p-4 h-100">
                            <div class="d-flex justify-content-between mb-3">
                                <h5 class="fw-bold m-0">Generated Questions</h5>
                                <button class="btn btn-glass btn-sm" onclick="copyResult('qg-output')"><i class="fas fa-copy me-1"></i>Copy</button>
                            </div>
                            <div id="qg-output" class="agent-output">
                                <div class="agent-placeholder">
                                    <i class="fas fa-list-ul fa-2x mb-3" style="color:rgba(6,182,212,0.3)"></i>
                                    <p>Specify role and skills, then click "Generate Questions"</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Tab 4: Evaluator -->
            <div class="tab-pane fade" id="tab-evaluator">
                <div class="row g-4">
                    <div class="col-lg-5">
                        <div class="glass-card p-4 h-100">
                            <div class="agent-icon-lg mb-3" style="background:linear-gradient(135deg,#10b981,#06b6d4)"><i class="fas fa-clipboard-check"></i></div>
                            <h4 class="fw-bold">Interview Evaluator Agent</h4>
                            <p style="color:var(--text-secondary);font-size:0.88rem;margin-bottom:20px">Evaluate interview responses with detailed scoring and feedback.</p>
                            <div class="mb-3">
                                <label class="form-label-dark">Job Title</label>
                                <input type="text" class="form-control form-control-dark" id="ie-title" placeholder="e.g. Java Developer">
                            </div>
                            <div class="mb-3">
                                <label class="form-label-dark">Questions &amp; Answers (JSON or text)</label>
                                <textarea class="form-control form-control-dark" id="ie-qa" rows="10"
                                          placeholder="Format:&#10;Q: What is the difference between HashMap and ConcurrentHashMap?&#10;A: HashMap is not thread-safe...&#10;&#10;Q: Explain SOLID principles&#10;A: ..."></textarea>
                            </div>
                            <button class="btn btn-primary-gradient w-100 py-3" onclick="runEvaluator()">
                                <i class="fas fa-star-half-alt me-2"></i>Evaluate Interview
                            </button>
                        </div>
                    </div>
                    <div class="col-lg-7">
                        <div class="glass-card p-4 h-100">
                            <h5 class="fw-bold mb-3">Evaluation Report</h5>
                            <div id="ie-output" class="agent-output">
                                <div class="agent-placeholder">
                                    <i class="fas fa-clipboard-check fa-2x mb-3" style="color:rgba(16,185,129,0.3)"></i>
                                    <p>Enter Q&amp;A transcript and click "Evaluate"</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Tab 5: Hiring Recommender -->
            <div class="tab-pane fade" id="tab-hiring">
                <div class="row g-4">
                    <div class="col-lg-5">
                        <div class="glass-card p-4 h-100">
                            <div class="agent-icon-lg mb-3" style="background:linear-gradient(135deg,#f59e0b,#ef4444)"><i class="fas fa-award"></i></div>
                            <h4 class="fw-bold">Hiring Recommender Agent</h4>
                            <p style="color:var(--text-secondary);font-size:0.88rem;margin-bottom:20px">Final hiring decision engine. Input all pipeline data for a comprehensive recommendation.</p>
                            <div class="mb-3">
                                <label class="form-label-dark">Job Title</label>
                                <input type="text" class="form-control form-control-dark" id="hr-title" placeholder="e.g. Senior Java Developer">
                            </div>
                            <div class="mb-3">
                                <label class="form-label-dark">Salary Range</label>
                                <input type="text" class="form-control form-control-dark" id="hr-salary" placeholder="e.g. $100k - $130k">
                            </div>
                            <div class="mb-3">
                                <label class="form-label-dark">Resume Analysis Summary</label>
                                <textarea class="form-control form-control-dark" id="hr-resume" rows="3" placeholder="Paste resume analysis JSON or summary..."></textarea>
                            </div>
                            <div class="mb-3">
                                <label class="form-label-dark">Interview Evaluation Summary</label>
                                <textarea class="form-control form-control-dark" id="hr-interview" rows="3" placeholder="Paste interview evaluation summary..."></textarea>
                            </div>
                            <button class="btn btn-primary-gradient w-100 py-3" onclick="runHiringRecommender()">
                                <i class="fas fa-gavel me-2"></i>Get Final Decision
                            </button>
                        </div>
                    </div>
                    <div class="col-lg-7">
                        <div class="glass-card p-4 h-100">
                            <h5 class="fw-bold mb-3">Hiring Recommendation</h5>
                            <div id="hr-output" class="agent-output">
                                <div class="agent-placeholder">
                                    <i class="fas fa-gavel fa-2x mb-3" style="color:rgba(245,158,11,0.3)"></i>
                                    <p>Provide all pipeline data for final HIRE/REJECT decision</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Tab 6: Recruiter Copilot -->
            <div class="tab-pane fade" id="tab-copilot">
                <div class="row g-4">
                    <div class="col-lg-5">
                        <div class="glass-card p-4 h-100">
                            <div class="agent-icon-lg mb-3" style="background:linear-gradient(135deg,#ec4899,#8b5cf6)"><i class="fas fa-headset"></i></div>
                            <h4 class="fw-bold">Recruiter Copilot Agent</h4>
                            <p style="color:var(--text-secondary);font-size:0.88rem;margin-bottom:20px">Your AI writing assistant for all recruitment communications.</p>
                            <div class="mb-3">
                                <label class="form-label-dark">Task Type</label>
                                <select class="form-control form-control-dark" id="rc-task">
                                    <option value="JOB_DESCRIPTION">Write Job Description</option>
                                    <option value="OUTREACH_EMAIL">Candidate Outreach Email</option>
                                    <option value="REJECTION_EMAIL">Professional Rejection Email</option>
                                    <option value="INTERVIEW_INVITE">Interview Invitation</option>
                                    <option value="STRATEGY_ADVICE">Hiring Strategy Advice</option>
                                </select>
                            </div>
                            <div class="mb-3">
                                <label class="form-label-dark">Context & Details</label>
                                <textarea class="form-control form-control-dark" id="rc-context" rows="8"
                                          placeholder="Describe what you need...&#10;&#10;For Job Description: Role title, company, key requirements&#10;For Email: Candidate name, role, personalization details&#10;For Strategy: Company type, hiring challenges, goals"></textarea>
                            </div>
                            <div class="mb-3">
                                <label class="form-label-dark">Additional Instructions (optional)</label>
                                <input type="text" class="form-control form-control-dark" id="rc-instructions"
                                       placeholder="e.g. Keep it under 200 words, use casual tone">
                            </div>
                            <button class="btn btn-primary-gradient w-100 py-3" onclick="runCopilotAgent()">
                                <i class="fas fa-pen-fancy me-2"></i>Generate Content
                            </button>
                        </div>
                    </div>
                    <div class="col-lg-7">
                        <div class="glass-card p-4 h-100">
                            <div class="d-flex justify-content-between mb-3">
                                <h5 class="fw-bold m-0">Generated Content</h5>
                                <button class="btn btn-glass btn-sm" onclick="copyResult('rc-output')"><i class="fas fa-copy me-1"></i>Copy</button>
                            </div>
                            <div id="rc-output" class="agent-output">
                                <div class="agent-placeholder">
                                    <i class="fas fa-pen-fancy fa-2x mb-3" style="color:rgba(236,72,153,0.3)"></i>
                                    <p>Select task type, provide context, and let the AI write for you</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

        </div><!-- /tab-content -->
    </main>

    <style>
        .agent-tabs { border-bottom: 1px solid var(--border-color); gap: 4px; flex-wrap: wrap; }
        .agent-tabs .nav-link {
            background: transparent; border: none; border-radius: 8px 8px 0 0;
            color: var(--text-secondary); font-size: 0.83rem; font-weight: 600;
            padding: 10px 16px; transition: all 0.2s;
        }
        .agent-tabs .nav-link:hover { color: var(--text-primary); background: rgba(255,255,255,0.05); }
        .agent-tabs .nav-link.active { color: white; background: var(--gradient-primary); }
        .agent-output {
            background: rgba(0,0,0,0.4); border: 1px solid var(--border-color);
            border-radius: 10px; padding: 16px; height: calc(100% - 50px);
            overflow-y: auto; font-family: var(--font-mono); font-size: 0.8rem;
            line-height: 1.6; color: var(--accent-green); min-height: 300px;
        }
        .agent-placeholder { display: flex; flex-direction: column; align-items: center; justify-content: center;
            height: 100%; text-align: center; color: var(--text-muted); }
        .agent-placeholder p { font-family: var(--font-primary); font-size: 0.88rem; max-width: 280px; }
        .fw-bold { font-weight: 700 !important; }
    </style>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/static/js/app.js"></script>
    <script>
        async function runAgentAndDisplay(agentType, payload, outputId, refType) {
            const output = document.getElementById(outputId);
            output.innerHTML = '<div class="ai-loader justify-content-center py-4"><div class="ai-spinner"></div><span class="ms-2">AI Agent is processing your request...</span></div>';
            try {
                const data = await Api.post('/api/agents/execute/' + agentType, {
                    payload: payload, referenceType: refType || 'DEMO', referenceId: 0
                });
                try {
                    const parsed = JSON.parse(data.report || '{}');
                    output.innerHTML = '<pre style="white-space:pre-wrap;color:var(--accent-green)">' + JSON.stringify(parsed, null, 2) + '</pre>';
                } catch {
                    output.innerHTML = '<pre style="white-space:pre-wrap;color:var(--accent-green)">' + (data.report || data.content || JSON.stringify(data, null, 2)) + '</pre>';
                }
                if (data.score) showToast('Agent completed! Score: ' + data.score, 'success');
                else showToast('Agent completed successfully!', 'success');
            } catch(e) {
                output.innerHTML = '<span style="color:#ef4444;font-family:var(--font-primary)"><i class="fas fa-exclamation-triangle me-2"></i>Error: ' + escHtml(e.message) + '</span>';
                showToast('Agent error: ' + e.message, 'error');
            }
        }

        function runResumeAnalyzer() {
            const resume = document.getElementById('ra-resume').value;
            if (!resume.trim()) { showToast('Please enter resume content', 'error'); return; }
            runAgentAndDisplay('RESUME_ANALYZER', {
                resumeContent: resume,
                jobRequirements: document.getElementById('ra-requirements').value
            }, 'ra-output', 'RESUME');
        }

        function runJobMatcher() {
            const req = document.getElementById('jm-requirements').value;
            const prof = document.getElementById('jm-profile').value;
            if (!req || !prof) { showToast('Please fill in requirements and profile', 'error'); return; }
            runAgentAndDisplay('JOB_MATCHER', {
                jobTitle: document.getElementById('jm-title').value || 'Software Engineer',
                jobRequirements: req,
                candidateProfile: prof
            }, 'jm-output', 'JOB');
        }

        function runQuestionGenerator() {
            const role = document.getElementById('qg-role').value;
            if (!role.trim()) { showToast('Please enter job role', 'error'); return; }
            runAgentAndDisplay('INTERVIEW_QUESTION_GENERATOR', {
                jobTitle: role,
                experienceLevel: document.getElementById('qg-level').value,
                candidateSkills: document.getElementById('qg-skills').value,
                questionCount: parseInt(document.getElementById('qg-count').value) || 15
            }, 'qg-output', 'INTERVIEW');
        }

        function runEvaluator() {
            const qa = document.getElementById('ie-qa').value;
            if (!qa.trim()) { showToast('Please enter Q&A transcript', 'error'); return; }
            runAgentAndDisplay('INTERVIEW_EVALUATOR', {
                jobTitle: document.getElementById('ie-title').value || 'Software Engineer',
                questionsAndAnswers: qa,
                interviewTranscript: qa
            }, 'ie-output', 'INTERVIEW');
        }

        function runHiringRecommender() {
            runAgentAndDisplay('HIRING_RECOMMENDER', {
                jobTitle: document.getElementById('hr-title').value || 'Software Engineer',
                salaryRange: document.getElementById('hr-salary').value,
                resumeAnalysis: document.getElementById('hr-resume').value,
                interviewEvaluation: document.getElementById('hr-interview').value
            }, 'hr-output', 'APPLICATION');
        }

        function runCopilotAgent() {
            const context = document.getElementById('rc-context').value;
            if (!context.trim()) { showToast('Please provide context', 'error'); return; }
            runAgentAndDisplay('RECRUITER_COPILOT', {
                taskType: document.getElementById('rc-task').value,
                context: context,
                instructions: document.getElementById('rc-instructions').value
            }, 'rc-output', 'RECRUITER');
        }

        function copyResult(id) {
            const output = document.getElementById(id);
            const text = output.innerText;
            navigator.clipboard.writeText(text).then(() => showToast('Copied to clipboard!', 'success'));
        }
    </script>
</body>
</html>
