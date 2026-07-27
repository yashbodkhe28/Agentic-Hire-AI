<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Jobs — AgentHire AI</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/style.css">
</head>
<body data-jobs-page="true">
    <div class="bg-animated"><div class="orb orb-1" style="opacity:0.05"></div></div>

    <!-- Sidebar (same nav) -->
    <aside class="sidebar">
        <div class="sidebar-logo">
            <a href="/" class="brand-logo text-decoration-none">
                <div class="brand-icon small"><i class="fas fa-robot"></i></div>
                <span class="brand-text ms-2">Agent<span class="brand-accent">Hire</span> AI</span>
            </a>
        </div>
        <nav class="sidebar-nav">
            <div class="nav-section">
                <div class="nav-section-title">Overview</div>
                <a href="/dashboard" class="sidebar-link"><i class="fas fa-th-large"></i><span>Dashboard</span></a>
                <a href="/analytics" class="sidebar-link"><i class="fas fa-chart-line"></i><span>Analytics</span></a>
            </div>
            <div class="nav-section">
                <div class="nav-section-title">Recruitment</div>
                <a href="/jobs" class="sidebar-link active"><i class="fas fa-briefcase"></i><span>Jobs</span></a>
                <a href="/candidates" class="sidebar-link"><i class="fas fa-users"></i><span>Candidates</span></a>
                <a href="/interviews" class="sidebar-link"><i class="fas fa-calendar-check"></i><span>Interviews</span></a>
            </div>
            <div class="nav-section">
                <div class="nav-section-title">AI</div>
                <a href="/agents" class="sidebar-link"><i class="fas fa-robot"></i><span>AI Agents</span></a>
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
                <h1 class="page-title">Job Listings</h1>
                <p style="color:var(--text-secondary);font-size:0.85rem;margin:0">Browse and manage all job postings</p>
            </div>
            <div class="topbar-actions">
                <button class="btn btn-primary-gradient btn-sm" data-bs-toggle="modal" data-bs-target="#postJobModal">
                    <i class="fas fa-plus me-1"></i>Post New Job
                </button>
            </div>
        </div>

        <!-- Search & Filters -->
        <div class="glass-card p-4 mb-4">
            <div class="row g-3 align-items-end">
                <div class="col-md-4">
                    <label class="form-label-dark">Search Jobs</label>
                    <div class="input-group">
                        <span class="input-group-text ig-dark"><i class="fas fa-search"></i></span>
                        <input type="text" class="form-control form-control-dark" id="job-search"
                               placeholder="Title, company, skill..." oninput="debounceSearch()">
                    </div>
                </div>
                <div class="col-md-2">
                    <label class="form-label-dark">Location</label>
                    <input type="text" class="form-control form-control-dark" id="location-filter" placeholder="City, Remote">
                </div>
                <div class="col-md-2">
                    <label class="form-label-dark">Job Type</label>
                    <select class="form-control form-control-dark" id="type-filter">
                        <option value="">All Types</option>
                        <option>FULL_TIME</option>
                        <option>PART_TIME</option>
                        <option>CONTRACT</option>
                        <option>INTERNSHIP</option>
                    </select>
                </div>
                <div class="col-md-2">
                    <label class="form-label-dark">Experience</label>
                    <select class="form-control form-control-dark" id="exp-filter">
                        <option value="">All Levels</option>
                        <option>ENTRY</option>
                        <option>MID</option>
                        <option>SENIOR</option>
                        <option>LEAD</option>
                    </select>
                </div>
                <div class="col-md-1">
                    <div class="form-check mt-2">
                        <input class="form-check-input" type="checkbox" id="remote-filter" onchange="searchJobs()">
                        <label class="form-check-label" style="font-size:0.82rem;color:var(--text-secondary)">Remote</label>
                    </div>
                </div>
                <div class="col-md-1">
                    <button class="btn btn-primary-gradient w-100" onclick="searchJobs()">
                        <i class="fas fa-filter"></i>
                    </button>
                </div>
            </div>
        </div>

        <!-- Jobs Grid -->
        <div id="jobs-container">
            <div class="text-center py-5">
                <div class="ai-spinner mx-auto mb-3"></div>
                <p style="color:var(--text-muted)">Loading jobs...</p>
            </div>
        </div>
    </main>

    <!-- Post Job Modal -->
    <div class="modal fade" id="postJobModal" tabindex="-1">
        <div class="modal-dialog modal-lg modal-dialog-centered">
            <div class="modal-content" style="background:var(--bg-dark);border:1px solid var(--border-color)">
                <div class="modal-header" style="border-color:var(--border-color)">
                    <h5 class="modal-title fw-700">Post New Job</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="row g-3">
                        <div class="col-12">
                            <label class="form-label-dark">Job Title *</label>
                            <input type="text" class="form-control form-control-dark" id="job-title" placeholder="e.g. Senior Java Developer">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label-dark">Job Type</label>
                            <select class="form-control form-control-dark" id="job-type">
                                <option value="FULL_TIME">Full Time</option>
                                <option value="PART_TIME">Part Time</option>
                                <option value="CONTRACT">Contract</option>
                                <option value="INTERNSHIP">Internship</option>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label-dark">Experience Level</label>
                            <select class="form-control form-control-dark" id="job-exp">
                                <option value="ENTRY">Entry Level</option>
                                <option value="MID">Mid Level</option>
                                <option value="SENIOR">Senior</option>
                                <option value="LEAD">Lead / Manager</option>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label-dark">Location</label>
                            <input type="text" class="form-control form-control-dark" id="job-location" placeholder="New York, NY">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label-dark">Min Salary ($)</label>
                            <input type="number" class="form-control form-control-dark" id="job-min-salary" placeholder="80000">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label-dark">Max Salary ($)</label>
                            <input type="number" class="form-control form-control-dark" id="job-max-salary" placeholder="120000">
                        </div>
                        <div class="col-12">
                            <label class="form-label-dark">Job Description *</label>
                            <textarea class="form-control form-control-dark" id="job-desc" rows="5"
                                      placeholder="Describe the role, responsibilities, and what you're looking for..."></textarea>
                        </div>
                        <div class="col-12">
                            <div class="d-flex align-items-center gap-2 mb-2">
                                <div class="form-check m-0">
                                    <input class="form-check-input" type="checkbox" id="job-remote">
                                    <label class="form-check-label" style="color:var(--text-secondary);font-size:0.88rem">Remote Friendly</label>
                                </div>
                                <button class="btn btn-glass btn-sm ms-auto" onclick="generateJDWithAI()">
                                    <i class="fas fa-magic me-1"></i>AI: Write JD for me
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer" style="border-color:var(--border-color)">
                    <button class="btn btn-glass" data-bs-dismiss="modal">Cancel</button>
                    <button class="btn btn-primary-gradient" onclick="submitJob()">
                        <i class="fas fa-paper-plane me-2"></i>Post Job
                    </button>
                </div>
            </div>
        </div>
    </div>

    <style>
        .job-card { transition: all 0.3s; }
        .job-card:hover { transform: translateY(-3px); }
        .ig-dark { background: rgba(255,255,255,0.05) !important; border-color: rgba(255,255,255,0.1) !important; color: var(--text-muted) !important; }
        .fw-700 { font-weight: 700; }
    </style>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/static/js/app.js"></script>
    <script>
        let searchTimer;

        document.addEventListener('DOMContentLoaded', () => {
            searchJobs();
        });

        function debounceSearch() {
            clearTimeout(searchTimer);
            searchTimer = setTimeout(searchJobs, 400);
        }

        async function searchJobs() {
            const filters = {
                title: document.getElementById('job-search').value || undefined,
                location: document.getElementById('location-filter').value || undefined,
                isRemote: document.getElementById('remote-filter').checked || undefined,
                size: 20, page: 0
            };
            Object.keys(filters).forEach(k => filters[k] === undefined && delete filters[k]);
            await loadJobs(filters);
        }

        async function applyForJob(jobId) {
            const user = Auth.getUser();
            if (!user) { window.location.href = '/login'; return; }
            try {
                await Api.post('/api/applications', {
                    jobId: jobId,
                    candidateId: user.id,
                    coverLetter: ''
                });
                showToast('Application submitted successfully! 🎉', 'success');
            } catch(e) {
                if (e.message.includes('409')) showToast('Already applied to this job', 'error');
                else showToast('Error: ' + e.message, 'error');
            }
        }

        async function submitJob() {
            const payload = {
                title: document.getElementById('job-title').value,
                description: document.getElementById('job-desc').value,
                jobType: document.getElementById('job-type').value,
                experienceLevel: document.getElementById('job-exp').value,
                location: document.getElementById('job-location').value,
                minSalary: document.getElementById('job-min-salary').value || null,
                maxSalary: document.getElementById('job-max-salary').value || null,
                isRemote: document.getElementById('job-remote').checked
            };
            if (!payload.title || !payload.description) {
                showToast('Title and description are required', 'error'); return;
            }
            try {
                await Api.post('/api/jobs', payload);
                showToast('Job posted successfully!', 'success');
                bootstrap.Modal.getInstance(document.getElementById('postJobModal')).hide();
                searchJobs();
            } catch(e) { showToast('Error: ' + e.message, 'error'); }
        }

        async function generateJDWithAI() {
            const title = document.getElementById('job-title').value;
            if (!title) { showToast('Enter job title first', 'error'); return; }
            const btn = document.querySelector('[onclick="generateJDWithAI()"]');
            btn.innerHTML = '<div class="ai-spinner d-inline-block me-1"></div>Generating...';
            btn.disabled = true;
            try {
                const data = await Api.post('/api/agents/recruiter-copilot', {
                    taskType: 'JOB_DESCRIPTION',
                    context: 'Write a compelling, inclusive job description for: ' + title,
                    recruiterId: 0
                });
                const result = data.content || '';
                // Handle both plain text (mock mode) and JSON-wrapped responses
                var jdText = result;
                try { var parsed = JSON.parse(result); jdText = parsed.content?.body || parsed.text || result; } catch(e) { /* plain text, use as-is */ }
                document.getElementById('job-desc').value = jdText;
                showToast('AI generated job description!', 'success');
            } catch(e) { showToast('AI Error: ' + e.message, 'error'); }

            finally {
                btn.innerHTML = '<i class="fas fa-magic me-1"></i>AI: Write JD for me';
                btn.disabled = false;
            }
        }
    </script>
</body>
</html>
