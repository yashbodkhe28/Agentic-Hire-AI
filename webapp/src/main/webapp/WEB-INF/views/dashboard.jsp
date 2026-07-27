<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard — AgentHire AI</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&family=JetBrains+Mono:wght@400;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/style.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
</head>
<body data-dashboard="true">
    <div class="bg-animated"><div class="orb orb-1" style="opacity:0.06"></div><div class="orb orb-3" style="opacity:0.04"></div></div>

    <!-- Sidebar -->
    <aside class="sidebar" id="sidebar">
        <div class="sidebar-logo">
            <a href="/" class="brand-logo text-decoration-none">
                <div class="brand-icon small"><i class="fas fa-robot"></i></div>
                <span class="brand-text ms-2">Agent<span class="brand-accent">Hire</span> AI</span>
            </a>
        </div>

        <!-- User Info -->
        <div class="sidebar-user px-4 py-3">
            <div class="d-flex align-items-center gap-3">
                <div class="user-avatar">
                    <span class="user-avatar-text">AH</span>
                </div>
                <div>
                    <div class="user-name fw-700" style="font-size:0.85rem;font-weight:700"></div>
                    <div class="user-role" style="font-size:0.72rem;color:var(--text-muted)"></div>
                </div>
            </div>
        </div>

        <nav class="sidebar-nav">
            <div class="nav-section">
                <div class="nav-section-title">Overview</div>
                <a href="/dashboard" class="sidebar-link active">
                    <i class="fas fa-th-large"></i><span>Dashboard</span>
                </a>
                <a href="/analytics" class="sidebar-link">
                    <i class="fas fa-chart-line"></i><span>Analytics</span>
                </a>
            </div>
            <div class="nav-section">
                <div class="nav-section-title">Recruitment</div>
                <a href="/jobs" class="sidebar-link">
                    <i class="fas fa-briefcase"></i><span>Jobs</span>
                    <span class="sidebar-badge ms-auto" id="jobs-badge"></span>
                </a>
                <a href="/candidates" class="sidebar-link">
                    <i class="fas fa-users"></i><span>Candidates</span>
                </a>
                <a href="/interviews" class="sidebar-link">
                    <i class="fas fa-calendar-check"></i><span>Interviews</span>
                </a>
            </div>
            <div class="nav-section">
                <div class="nav-section-title">AI Agents</div>
                <a href="/agents" class="sidebar-link">
                    <i class="fas fa-robot"></i><span>AI Agents</span>
                    <span class="badge ms-auto" style="background:rgba(16,185,129,0.2);color:#10b981;font-size:0.65rem">6 Active</span>
                </a>
            </div>
            <div class="nav-section">
                <div class="nav-section-title">Account</div>
                <a href="/profile" class="sidebar-link">
                    <i class="fas fa-user-circle"></i><span>Profile</span>
                </a>
                <a href="#" onclick="logout()" class="sidebar-link" style="color:#ef4444">
                    <i class="fas fa-sign-out-alt"></i><span>Sign Out</span>
                </a>
            </div>
        </nav>
    </aside>

    <!-- Main Content -->
    <main class="main-content">
        <!-- Topbar -->
        <div class="topbar">
            <div>
                <h1 class="page-title">Dashboard</h1>
                <p style="color:var(--text-secondary);font-size:0.85rem;margin:0">
                    Welcome back, <span class="user-name fw-600"></span> 👋
                </p>
            </div>
            <div class="topbar-actions">
                <button class="btn btn-glass btn-sm" onclick="refreshData()">
                    <i class="fas fa-sync-alt me-1"></i>Refresh
                </button>
                <button class="btn btn-primary-gradient btn-sm" onclick="window.location.href='/jobs'">
                    <i class="fas fa-plus me-1"></i>Post Job
                </button>
                <div class="user-avatar-small">
                    <span class="user-avatar-text" style="font-size:0.75rem;font-weight:700">AH</span>
                </div>
            </div>
        </div>

        <!-- Stats Grid -->
        <div class="stats-grid mb-4">
            <div class="stat-card sc-purple">
                <div class="d-flex align-items-start justify-content-between mb-3">
                    <div class="stat-card-icon si-purple">
                        <i class="fas fa-briefcase"></i>
                    </div>
                    <span class="badge-status badge-active">Live</span>
                </div>
                <div class="stat-card-value text-gradient" id="stat-jobs">—</div>
                <div class="stat-card-label">Active Jobs</div>
                <div class="stat-card-trend trend-up"><i class="fas fa-arrow-up"></i>12% this month</div>
            </div>
            <div class="stat-card sc-cyan">
                <div class="d-flex align-items-start justify-content-between mb-3">
                    <div class="stat-card-icon si-cyan">
                        <i class="fas fa-users"></i>
                    </div>
                    <span class="badge-status bs-info">Pool</span>
                </div>
                <div class="stat-card-value" style="color:#22d3ee" id="stat-candidates">—</div>
                <div class="stat-card-label">Candidates</div>
                <div class="stat-card-trend trend-up"><i class="fas fa-arrow-up"></i>8% this week</div>
            </div>
            <div class="stat-card sc-green">
                <div class="d-flex align-items-start justify-content-between mb-3">
                    <div class="stat-card-icon si-green">
                        <i class="fas fa-calendar-check"></i>
                    </div>
                    <span class="badge-status badge-active">Scheduled</span>
                </div>
                <div class="stat-card-value" style="color:#34d399" id="stat-interviews">—</div>
                <div class="stat-card-label">Interviews</div>
                <div class="stat-card-trend trend-up"><i class="fas fa-arrow-up"></i>24% this week</div>
            </div>
            <div class="stat-card sc-pink">
                <div class="d-flex align-items-start justify-content-between mb-3">
                    <div class="stat-card-icon si-pink">
                        <i class="fas fa-robot"></i>
                    </div>
                    <div class="d-flex align-items-center gap-2">
                        <div class="pulse-dot"></div>
                        <span style="font-size:.65rem;color:var(--green);font-weight:600">Online</span>
                    </div>
                </div>
                <div class="stat-card-value" style="color:#f9a8d4" id="stat-agents">6</div>
                <div class="stat-card-label">AI Agents Active</div>
                <div class="stat-card-trend trend-up"><i class="fas fa-circle" style="font-size:.45rem"></i>All systems healthy</div>
            </div>
        </div>

        <!-- Charts + Agent Panel -->
        <div class="row g-4 mb-4">
            <div class="col-lg-8">
                <div class="glass-card p-4 h-100">
                    <div class="d-flex align-items-center justify-content-between mb-4">
                        <h5 class="fw-700 m-0">Hiring Pipeline</h5>
                        <select class="form-select form-select-sm" style="width:auto;background:var(--bg-card);border-color:var(--border-color);color:var(--text-primary)">
                            <option>Last 30 Days</option>
                            <option>Last 90 Days</option>
                            <option>This Year</option>
                        </select>
                    </div>
                    <div class="chart-container" style="min-height:280px">
                        <canvas id="pipelineChart"></canvas>
                    </div>
                </div>
            </div>
            <div class="col-lg-4">
                <div class="glass-card p-4 h-100">
                    <h5 class="fw-700 mb-4">AI Agent Status</h5>
                    <div class="agents-status-list" id="agents-status"></div>
                    <button class="btn btn-primary-gradient w-100 mt-3 btn-sm" onclick="window.location.href='/agents'">
                        <i class="fas fa-robot me-2"></i>Open AI Agents
                    </button>
                </div>
            </div>
        </div>

        <!-- Recent Applications Table -->
        <div class="glass-card table-card mb-4 recruiter-table-section">
            <div class="table-header">
                <h5 class="table-title">Recent Applications</h5>
                <button class="btn btn-glass btn-sm">View All</button>
            </div>
            <div class="table-responsive">
                <table class="table table-dark-custom mb-0">
                    <thead>
                        <tr>
                            <th>Candidate</th>
                            <th>Position</th>
                            <th>AI Match Score</th>
                            <th>Status</th>
                            <th>Applied</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="applications-table">
                        <tr><td colspan="6" class="text-center py-4 text-muted">
                            <div class="ai-loader justify-content-center"><div class="ai-spinner"></div>Loading applications...</div>
                        </td></tr>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Quick Agent Actions -->
        <div class="row g-4 ai-tools-section">
            <div class="col-md-6">
                <div class="glass-card p-4">
                    <h5 class="fw-700 mb-3"><i class="fas fa-file-search me-2" style="color:#6366f1"></i>Quick Resume Analysis</h5>
                    <div class="mb-3">
                        <label class="form-label-dark">Resume Text / Content</label>
                        <textarea class="form-control form-control-dark" id="resume-text" rows="4"
                                  placeholder="Paste resume text here for instant AI analysis..."></textarea>
                    </div>
                    <button class="btn btn-primary-gradient w-100" onclick="quickAnalyzeResume()">
                        <i class="fas fa-brain me-2"></i>Analyze with AI
                    </button>
                    <div class="agent-result mt-3" id="agent-result-RESUME_ANALYZER" style="display:none"></div>
                </div>
            </div>
            <div class="col-md-6">
                <div class="glass-card p-4">
                    <h5 class="fw-700 mb-3"><i class="fas fa-headset me-2" style="color:#8b5cf6"></i>Recruiter Copilot</h5>
                    <div class="mb-3">
                        <label class="form-label-dark">Task Type</label>
                        <select class="form-control form-control-dark" id="copilot-task">
                            <option value="JOB_DESCRIPTION">Write Job Description</option>
                            <option value="OUTREACH_EMAIL">Candidate Outreach Email</option>
                            <option value="REJECTION_EMAIL">Professional Rejection Email</option>
                            <option value="INTERVIEW_INVITE">Interview Invitation</option>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label class="form-label-dark">Context / Details</label>
                        <textarea class="form-control form-control-dark" id="copilot-context" rows="3"
                                  placeholder="Provide context for the AI to generate content..."></textarea>
                    </div>
                    <button class="btn btn-primary-gradient w-100" onclick="runCopilot()">
                        <i class="fas fa-magic me-2"></i>Generate with AI
                    </button>
                    <div class="agent-result mt-3" id="agent-result-RECRUITER_COPILOT" style="display:none"></div>
                </div>
            </div>
        </div>
    </main>


    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/static/js/app.js"></script>
    <script>
    document.addEventListener('DOMContentLoaded', () => {
        loadDashboardData();
        initPipelineChart();
        renderAgentStatus();
    });

    async function loadDashboardData() {
        // Skip for candidates — real data loaded by app.js loadCandidateDashboard()
        if (window._candidateMode) return;

        // Load real stats
        try {
            var jobs = await Api.get('/api/jobs?size=1&page=0').catch(() => ({}));
            var stats = await Api.get('/api/applications/stats').catch(() => ({}));
            var totalJobs = jobs.totalElements || 0;
            var totalApps = (stats.total || 0);
            var totalInterviews = (stats.interview || 0);
            setTimeout(() => {
                animateCounter(document.getElementById('stat-jobs'), 0, totalJobs, 1200);
                animateCounter(document.getElementById('stat-candidates'), 0, totalApps, 1400);
                animateCounter(document.getElementById('stat-interviews'), 0, totalInterviews, 1600);
            }, 300);
        } catch(e) { /* leave as — */ }

        // Load real recent applications
        try {
            var apps = await Api.get('/api/applications/shortlisted').catch(() => []);
            var list = Array.isArray(apps) ? apps : [];
            var tbody = document.getElementById('applications-table');
            if (!list.length) {
                tbody.innerHTML = '<tr><td colspan="6" class="text-center py-4" style="color:var(--text-muted)"><i class="fas fa-inbox fa-2x mb-2 d-block"></i>No applications yet. <a href="/jobs" style="color:#818cf8">Post a job</a> to get started.</td></tr>';
            } else {
                var statusMap = { APPLIED:'badge-pending', SCREENING:'badge-pending', SHORTLISTED:'badge-hired', INTERVIEW:'badge-active', OFFERED:'badge-active', HIRED:'badge-active', REJECTED:'badge-closed' };
                tbody.innerHTML = list.slice(0, 10).map(function(a) {
                    var initials = 'C' + a.candidateId;
                    var jobLabel = a.jobTitle || ('Job #' + a.jobId);
                    var timeStr = a.appliedAt ? new Date(a.appliedAt).toLocaleDateString() : '—';
                    var badgeClass = statusMap[a.status] || 'badge-pending';
                    return '<tr>' +
                        '<td><div class="d-flex align-items-center gap-2">' +
                        '<div style="width:32px;height:32px;background:var(--gradient-primary);border-radius:8px;display:flex;align-items:center;justify-content:center;font-size:0.7rem;font-weight:700">' + initials + '</div>' +
                        '<span>Candidate #' + a.candidateId + '</span></div></td>' +
                        '<td style="color:var(--text-secondary)">' + jobLabel + '</td>' +
                        '<td><div class="d-flex align-items-center gap-2"><div style="width:40px;height:6px;background:var(--border-color);border-radius:3px"><div style="width:70%;height:100%;background:#6366f1;border-radius:3px"></div></div><span style="color:#6366f1;font-weight:700">—</span></div></td>' +
                        '<td><span class="badge-status ' + badgeClass + '">' + a.status + '</span></td>' +
                        '<td style="color:var(--text-muted)">' + timeStr + '</td>' +
                        '<td><div class="d-flex gap-1"><a href="/jobs" class="btn btn-sm btn-glass px-2"><i class="fas fa-eye"></i></a></div></td></tr>';
                }).join('');
            }
        } catch(e) {
            // fallback to static message
            document.getElementById('applications-table').innerHTML = '<tr><td colspan="6" class="text-center py-3" style="color:var(--text-muted)">Unable to load applications</td></tr>';
        }
    }


    function generateMockRow(name, role, score, status, time) {
        var statusMap = {
            APPLIED: 'badge-pending', SCREENING: 'badge-pending',
            SHORTLISTED: 'badge-hired', INTERVIEW: 'badge-active',
            OFFERED: 'badge-active', HIRED: 'badge-active', REJECTED: 'badge-closed'
        };
        var initials = name.split(' ').map(function(n){ return n[0]; }).join('');
        var scoreColor = score >= 90 ? '#10b981' : score >= 75 ? '#f59e0b' : '#ef4444';
        return '<tr>' +
            '<td><div class="d-flex align-items-center gap-2">' +
            '<div style="width:32px;height:32px;background:var(--gradient-primary);border-radius:8px;display:flex;align-items:center;justify-content:center;font-size:0.72rem;font-weight:700">' + initials + '</div>' +
            '<span>' + name + '</span></div></td>' +
            '<td style="color:var(--text-secondary)">' + role + '</td>' +
            '<td><div class="d-flex align-items-center gap-2">' +
            '<div style="width:40px;height:6px;background:var(--border-color);border-radius:3px;overflow:hidden">' +
            '<div style="width:' + score + '%;height:100%;background:' + scoreColor + ';border-radius:3px"></div></div>' +
            '<span style="color:' + scoreColor + ';font-weight:700;font-size:0.85rem">' + score + '%</span></div></td>' +
            '<td><span class="badge-status ' + (statusMap[status]||'badge-pending') + '">' + status + '</span></td>' +
            '<td style="color:var(--text-muted)">' + time + '</td>' +
            '<td><div class="d-flex gap-1">' +
            '<button class="btn btn-sm btn-glass px-2" title="View Profile"><i class="fas fa-eye"></i></button>' +
            '<button class="btn btn-sm btn-glass px-2" title="AI Analysis"><i class="fas fa-brain"></i></button>' +
            '</div></td></tr>';
    }

    function initPipelineChart() {
        var ctx = document.getElementById('pipelineChart').getContext('2d');

        // Build gradient bars
        var colors = [
            ['rgba(124,58,237,0.9)', 'rgba(99,102,241,0.5)'],
            ['rgba(99,102,241,0.9)', 'rgba(139,92,246,0.5)'],
            ['rgba(6,182,212,0.9)', 'rgba(99,102,241,0.5)'],
            ['rgba(16,185,129,0.9)', 'rgba(6,182,212,0.5)'],
            ['rgba(245,158,11,0.9)', 'rgba(16,185,129,0.5)'],
            ['rgba(16,185,129,1)', 'rgba(6,182,212,0.8)']
        ];
        var gradients = colors.map(function(c) {
            var g = ctx.createLinearGradient(0, 0, 0, 280);
            g.addColorStop(0, c[0]);
            g.addColorStop(1, c[1]);
            return g;
        });

        new Chart(ctx, {
            type: 'bar',
            data: {
                labels: ['Applied', 'Screened', 'Shortlisted', 'Interviewed', 'Offered', 'Hired'],
                datasets: [{
                    label: 'Candidates',
                    data: [185, 102, 64, 38, 22, 14],
                    backgroundColor: gradients,
                    borderColor: colors.map(function(c) { return c[0]; }),
                    borderWidth: 1,
                    borderRadius: { topLeft: 8, topRight: 8 },
                    borderSkipped: false,
                    hoverBackgroundColor: gradients,
                    hoverBorderWidth: 2,
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                animation: { duration: 1200, easing: 'easeOutQuart' },
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        backgroundColor: 'rgba(9,9,15,0.95)',
                        borderColor: 'rgba(124,58,237,0.4)',
                        borderWidth: 1,
                        titleColor: '#eef2ff',
                        bodyColor: '#8892b0',
                        titleFont: { size: 13, weight: '700', family: 'Inter' },
                        bodyFont: { size: 12, family: 'Inter' },
                        padding: 12,
                        cornerRadius: 10,
                        callbacks: {
                            label: function(ctx) { return '  ' + ctx.raw + ' candidates'; }
                        }
                    }
                },
                scales: {
                    x: {
                        grid: { color: 'rgba(255,255,255,0.04)', drawBorder: false },
                        ticks: { color: '#8892b0', font: { size: 12, family: 'Inter' } },
                        border: { display: false }
                    },
                    y: {
                        grid: { color: 'rgba(255,255,255,0.04)', drawBorder: false },
                        ticks: { color: '#8892b0', font: { size: 12, family: 'Inter' }, padding: 8 },
                        border: { display: false },
                        beginAtZero: true
                    }
                }
            }
        });
    }


    function renderAgentStatus() {
        var agents = [
            { name: 'Resume Analyzer', icon: 'fa-file-search', color: '#6366f1', status: 'Ready' },
            { name: 'Job Matcher', icon: 'fa-bullseye', color: '#8b5cf6', status: 'Ready' },
            { name: 'Question Generator', icon: 'fa-question-circle', color: '#06b6d4', status: 'Ready' },
            { name: 'Interview Evaluator', icon: 'fa-clipboard-check', color: '#10b981', status: 'Ready' },
            { name: 'Hiring Recommender', icon: 'fa-award', color: '#f59e0b', status: 'Ready' },
            { name: 'Recruiter Copilot', icon: 'fa-headset', color: '#ec4899', status: 'Ready' },
        ];
        document.getElementById('agents-status').innerHTML = agents.map(function(a) {
            return '<div class="agent-status-item">' +
                '<div class="agent-status-icon" style="background:' + a.color + '22">' +
                '<i class="fas ' + a.icon + '" style="color:' + a.color + '"></i></div>' +
                '<div style="flex:1;font-size:0.8rem;font-weight:500">' + a.name + '</div>' +
                '<div class="status-active"><i class="fas fa-circle me-1" style="font-size:0.4rem"></i>' + a.status + '</div>' +
                '</div>';
        }).join('');
    }

    async function quickAnalyzeResume() {
        var text = document.getElementById('resume-text').value;
        if (!text.trim()) { showToast('Please paste resume text first', 'error'); return; }
        var result = document.getElementById('agent-result-RESUME_ANALYZER');
        result.style.display = 'block';
        result.innerHTML = '<div class="ai-loader"><div class="ai-spinner"></div>AI is analyzing resume...</div>';
        try {
            var data = await executeAgent('RESUME_ANALYZER', { resumeContent: text }, 'DEMO', 0);
            // result is already rendered by executeAgent
        } catch (e) {
            result.innerHTML = '<span style="color:#ef4444">Error: ' + e.message + '</span>';
        }
    }

    async function runCopilot() {
        var task = document.getElementById('copilot-task').value;
        var context = document.getElementById('copilot-context').value;
        if (!context.trim()) { showToast('Please provide context', 'error'); return; }
        var result = document.getElementById('agent-result-RECRUITER_COPILOT');
        result.style.display = 'block';
        result.innerHTML = '<div class="ai-loader"><div class="ai-spinner"></div>AI Copilot is generating content...</div>';
        try {
            var data = await executeAgent('RECRUITER_COPILOT', { taskType: task, context: context }, 'RECRUITER', 0);
            // result is already rendered by executeAgent
        } catch (e) {
            result.innerHTML = '<span style="color:#ef4444">Error: ' + e.message + '</span>';
        }
    }

    function refreshData() { loadDashboardData(); showToast('Dashboard refreshed', 'success'); }
    </script>
</body>
</html>
