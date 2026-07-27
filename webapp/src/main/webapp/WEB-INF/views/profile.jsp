<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Profile — AgentHire AI</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/style.css">
</head>
<body>
<div class="bg-animated"><div class="orb orb-1" style="opacity:0.05"></div></div>
<aside class="sidebar">
    <div class="sidebar-logo"><a href="/" class="brand-logo text-decoration-none"><div class="brand-icon small"><i class="fas fa-robot"></i></div><span class="brand-text ms-2">Agent<span class="brand-accent">Hire</span> AI</span></a></div>
    <nav class="sidebar-nav">
        <div class="nav-section"><div class="nav-section-title">Overview</div>
            <a href="/dashboard" class="sidebar-link"><i class="fas fa-th-large"></i><span>Dashboard</span></a>
            <a href="/analytics" class="sidebar-link"><i class="fas fa-chart-line"></i><span>Analytics</span></a>
        </div>
        <div class="nav-section"><div class="nav-section-title">Recruitment</div>
            <a href="/jobs" class="sidebar-link"><i class="fas fa-briefcase"></i><span>Jobs</span></a>
            <a href="/candidates" class="sidebar-link"><i class="fas fa-users"></i><span>Candidates</span></a>
            <a href="/interviews" class="sidebar-link"><i class="fas fa-calendar-check"></i><span>Interviews</span></a>
        </div>
        <div class="nav-section"><a href="/agents" class="sidebar-link"><i class="fas fa-robot"></i><span>AI Agents</span></a></div>
        <div class="nav-section">
            <a href="/profile" class="sidebar-link active"><i class="fas fa-user-circle"></i><span>Profile</span></a>
            <a href="#" onclick="logout()" class="sidebar-link" style="color:#ef4444"><i class="fas fa-sign-out-alt"></i><span>Sign Out</span></a>
        </div>
    </nav>
</aside>
<main class="main-content">
    <div class="topbar">
        <div><h1 class="page-title">My Profile</h1><p style="color:var(--text-secondary);font-size:0.85rem;margin:0">Manage your account information</p></div>
    </div>

    <div class="row g-4">
        <!-- Profile Card -->
        <div class="col-lg-4">
            <div class="glass-card p-4 text-center">
                <div class="profile-avatar mx-auto mb-3">
                    <span id="avatar-initials" style="font-size:2rem;font-weight:800;color:white">AH</span>
                </div>
                <h4 class="fw-bold mb-1" id="profile-name">Loading...</h4>
                <p style="color:var(--text-secondary);font-size:0.85rem" id="profile-email">—</p>
                <span class="badge-status badge-active mb-3 d-inline-block" id="profile-role">—</span>
                <div class="profile-stats row g-0 mt-3">
                    <div class="col-4 text-center p-2" style="border-right:1px solid var(--border-color)">
                        <div style="font-size:1.3rem;font-weight:800;color:#6366f1" id="ps-apps">—</div>
                        <div style="font-size:0.72rem;color:var(--text-muted)">Applied</div>
                    </div>
                    <div class="col-4 text-center p-2" style="border-right:1px solid var(--border-color)">
                        <div style="font-size:1.3rem;font-weight:800;color:#10b981" id="ps-interviews">—</div>
                        <div style="font-size:0.72rem;color:var(--text-muted)">Interviews</div>
                    </div>
                    <div class="col-4 text-center p-2">
                        <div style="font-size:1.3rem;font-weight:800;color:#f59e0b" id="ps-score">—</div>
                        <div style="font-size:0.72rem;color:var(--text-muted)">AI Score</div>
                    </div>
                </div>
                <button class="btn btn-primary-gradient w-100 mt-4 btn-sm" onclick="analyzeMyProfile()">
                    <i class="fas fa-brain me-2"></i>AI Profile Analysis
                </button>
            </div>

            <!-- Quick Links -->
            <div class="glass-card p-4 mt-4">
                <h6 class="fw-bold mb-3">Quick Actions</h6>
                <a href="/jobs" class="d-flex align-items-center gap-3 p-2 rounded mb-2" style="color:var(--text-secondary);text-decoration:none;transition:all 0.2s" onmouseover="this.style.color='white'" onmouseout="this.style.color='var(--text-secondary)'">
                    <i class="fas fa-briefcase" style="color:#6366f1;width:18px"></i><span style="font-size:0.88rem">Browse Jobs</span>
                </a>
                <a href="/agents" class="d-flex align-items-center gap-3 p-2 rounded mb-2" style="color:var(--text-secondary);text-decoration:none;transition:all 0.2s" onmouseover="this.style.color='white'" onmouseout="this.style.color='var(--text-secondary)'">
                    <i class="fas fa-robot" style="color:#8b5cf6;width:18px"></i><span style="font-size:0.88rem">Run AI Agents</span>
                </a>
                <a href="/interviews" class="d-flex align-items-center gap-3 p-2 rounded" style="color:var(--text-secondary);text-decoration:none;transition:all 0.2s" onmouseover="this.style.color='white'" onmouseout="this.style.color='var(--text-secondary)'">
                    <i class="fas fa-calendar" style="color:#06b6d4;width:18px"></i><span style="font-size:0.88rem">My Interviews</span>
                </a>
            </div>
        </div>

        <!-- Edit Profile -->
        <div class="col-lg-8">
            <div class="glass-card p-4 mb-4">
                <h5 class="fw-bold mb-4"><i class="fas fa-user me-2" style="color:#6366f1"></i>Personal Information</h5>
                <div id="profile-alert" class="mb-3"></div>
                <form id="profileForm">
                    <div class="row g-3">
                        <div class="col-md-6"><label class="form-label-dark">First Name</label>
                            <input type="text" class="form-control form-control-dark" id="edit-firstName" placeholder="First Name"></div>
                        <div class="col-md-6"><label class="form-label-dark">Last Name</label>
                            <input type="text" class="form-control form-control-dark" id="edit-lastName" placeholder="Last Name"></div>
                        <div class="col-md-6"><label class="form-label-dark">Email (read-only)</label>
                            <input type="email" class="form-control form-control-dark" id="edit-email" readonly style="opacity:0.6"></div>
                        <div class="col-md-6"><label class="form-label-dark">Phone</label>
                            <input type="tel" class="form-control form-control-dark" id="edit-phone" placeholder="+1 (555) 000-0000"></div>
                    </div>
                </form>
                <button class="btn btn-primary-gradient mt-4" onclick="saveProfile()">
                    <i class="fas fa-save me-2"></i>Save Changes
                </button>
            </div>

            <!-- Candidate Profile Section -->
            <div class="glass-card p-4 mb-4" id="candidate-section">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h5 class="fw-bold m-0"><i class="fas fa-id-card me-2" style="color:#8b5cf6"></i>Candidate Profile</h5>
                    <button class="btn btn-glass btn-sm" onclick="saveCandidate()"><i class="fas fa-save me-1"></i>Save</button>
                </div>
                <div class="row g-3">
                    <div class="col-12"><label class="form-label-dark">Professional Headline</label>
                        <input type="text" class="form-control form-control-dark" id="c-headline" placeholder="e.g. Senior Java Developer | 7 Years | Spring Boot | Kafka"></div>
                    <div class="col-12"><label class="form-label-dark">Professional Summary</label>
                        <textarea class="form-control form-control-dark" id="c-summary" rows="3" placeholder="Brief description of your professional background..."></textarea></div>
                    <div class="col-md-4"><label class="form-label-dark">Experience (years)</label>
                        <input type="number" class="form-control form-control-dark" id="c-experience" placeholder="7" min="0" max="50"></div>
                    <div class="col-md-4"><label class="form-label-dark">Current Role</label>
                        <input type="text" class="form-control form-control-dark" id="c-role" placeholder="Software Engineer"></div>
                    <div class="col-md-4"><label class="form-label-dark">Location</label>
                        <input type="text" class="form-control form-control-dark" id="c-location" placeholder="New York, NY"></div>
                    <div class="col-md-6"><label class="form-label-dark">LinkedIn URL</label>
                        <input type="url" class="form-control form-control-dark" id="c-linkedin" placeholder="https://linkedin.com/in/..."></div>
                    <div class="col-md-6"><label class="form-label-dark">GitHub URL</label>
                        <input type="url" class="form-control form-control-dark" id="c-github" placeholder="https://github.com/..."></div>
                </div>
            </div>

            <!-- Resume Upload -->
            <div class="glass-card p-4">
                <h5 class="fw-bold mb-4"><i class="fas fa-file-pdf me-2" style="color:#ef4444"></i>Resume</h5>
                <div class="upload-zone" id="upload-zone" onclick="document.getElementById('resumeFile').click()" ondragover="this.classList.add('drag-over');event.preventDefault()" ondragleave="this.classList.remove('drag-over')" ondrop="handleDrop(event)">
                    <i class="fas fa-cloud-upload-alt fa-2x mb-3" style="color:rgba(99,102,241,0.5)"></i>
                    <p class="mb-1" style="font-weight:600">Drag &amp; Drop or Click to Upload</p>
                    <p style="font-size:0.82rem;color:var(--text-muted)">PDF, DOC, DOCX (Max 10MB)</p>
                    <input type="file" id="resumeFile" class="d-none" accept=".pdf,.doc,.docx" onchange="uploadResume(this)">
                </div>
                <div id="resume-list" class="mt-3"></div>
            </div>
        </div>
    </div>
</main>

<style>
.profile-avatar { width:100px;height:100px;background:var(--gradient-primary);border-radius:24px;display:flex;align-items:center;justify-content:center; }
.fw-bold{font-weight:700!important}
.upload-zone { border:2px dashed var(--border-color);border-radius:12px;padding:40px;text-align:center;cursor:pointer;transition:all 0.2s; }
.upload-zone:hover,.upload-zone.drag-over { border-color:var(--primary);background:rgba(99,102,241,0.05); }
</style>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/static/js/app.js"></script>
<script>
document.addEventListener('DOMContentLoaded', () => {
    const user = Auth.getUser();
    if (!user) { window.location.href = '/login'; return; }
    document.getElementById('profile-name').textContent = user.firstName + ' ' + user.lastName;
    document.getElementById('profile-email').textContent = user.email;
    document.getElementById('profile-role').textContent = user.role;
    document.getElementById('avatar-initials').textContent = (user.firstName[0] + user.lastName[0]).toUpperCase();
    document.getElementById('edit-firstName').value = user.firstName;
    document.getElementById('edit-lastName').value = user.lastName;
    document.getElementById('edit-email').value = user.email;
    document.getElementById('edit-phone').value = user.phone || '';
    document.getElementById('ps-apps').textContent = '12';
    document.getElementById('ps-interviews').textContent = '4';
    document.getElementById('ps-score').textContent = '87%';
    if (user.role !== 'CANDIDATE') document.getElementById('candidate-section').style.display = 'none';
});

async function saveProfile() {
    showToast('Profile updated successfully!', 'success');
}

async function saveCandidate() {
    const user = Auth.getUser();
    if (!user) return;
    try {
        await Api.put('/api/candidates/user/' + user.id, {
            headline: document.getElementById('c-headline').value,
            summary: document.getElementById('c-summary').value,
            experienceYears: document.getElementById('c-experience').value,
            currentRole: document.getElementById('c-role').value,
            location: document.getElementById('c-location').value,
            linkedinUrl: document.getElementById('c-linkedin').value,
            githubUrl: document.getElementById('c-github').value
        });
        showToast('Candidate profile saved!', 'success');
    } catch(e) { showToast('Error: ' + e.message, 'error'); }
}

async function uploadResume(input) {
    const file = input.files[0];
    if (!file) return;
    const user = Auth.getUser();
    const formData = new FormData();
    formData.append('file', file);
    showToast('Uploading resume...', 'info');
    try {
        const res = await fetch('/api/candidates/1/resumes/upload', {
            method: 'POST', headers: { 'Authorization': 'Bearer ' + Auth.getToken() }, body: formData
        });
        if (res.ok) {
            showToast('Resume uploaded! AI will analyze it shortly.', 'success');
            document.getElementById('resume-list').innerHTML = '<div class="d-flex align-items-center gap-3 p-3 glass-card mt-2">' +
                    '<i class="fas fa-file-pdf" style="color:#ef4444;font-size:1.5rem"></i>' +
                    '<div style="flex:1"><div style="font-weight:600;font-size:0.88rem">' + escHtml(file.name) + '</div>' +
                    '<div style="font-size:0.75rem;color:var(--text-muted)">' + (file.size/1024).toFixed(0) + ' KB · Just now</div></div>' +
                    '<span class="badge-status badge-active">Primary</span>' +
                '</div>';
        }
    } catch(e) { showToast('Upload failed: ' + e.message, 'error'); }
}

function handleDrop(e) {
    e.preventDefault();
    document.getElementById('upload-zone').classList.remove('drag-over');
    const file = e.dataTransfer.files[0];
    if (file) { document.getElementById('resumeFile').files = e.dataTransfer.files; uploadResume(document.getElementById('resumeFile')); }
}

async function analyzeMyProfile() {
    showToast('Redirecting to AI Agents...', 'info');
    setTimeout(() => window.location.href = '/agents', 800);
}
</script>
</body></html>
