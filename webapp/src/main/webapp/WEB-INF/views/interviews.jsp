<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Interviews — AgentHire AI</title>
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
            <a href="/interviews" class="sidebar-link active"><i class="fas fa-calendar-check"></i><span>Interviews</span></a>
        </div>
        <div class="nav-section"><a href="/agents" class="sidebar-link"><i class="fas fa-robot"></i><span>AI Agents</span></a></div>
        <div class="nav-section">
            <a href="/profile" class="sidebar-link"><i class="fas fa-user-circle"></i><span>Profile</span></a>
            <a href="#" onclick="logout()" class="sidebar-link" style="color:#ef4444"><i class="fas fa-sign-out-alt"></i><span>Sign Out</span></a>
        </div>
    </nav>
</aside>
<main class="main-content">
    <div class="topbar">
        <div><h1 class="page-title">Interviews</h1><p style="color:var(--text-secondary);font-size:0.85rem;margin:0">Schedule, track and evaluate interviews</p></div>
        <div class="topbar-actions">
            <button class="btn btn-primary-gradient btn-sm" data-bs-toggle="modal" data-bs-target="#scheduleModal">
                <i class="fas fa-plus me-1"></i>Schedule Interview
            </button>
        </div>
    </div>

    <!-- Interview Status Cards -->
    <div class="row g-3 mb-4">
        <div class="col-6 col-lg-3"><div class="stat-card">
            <div class="stat-card-icon" style="background:rgba(245,158,11,0.15)"><i class="fas fa-clock" style="color:#f59e0b"></i></div>
            <div class="stat-card-value" style="color:#f59e0b" id="cnt-scheduled">—</div>
            <div class="stat-card-label">Scheduled</div></div></div>
        <div class="col-6 col-lg-3"><div class="stat-card">
            <div class="stat-card-icon" style="background:rgba(6,182,212,0.15)"><i class="fas fa-video" style="color:#06b6d4"></i></div>
            <div class="stat-card-value" style="color:#06b6d4" id="cnt-progress">—</div>
            <div class="stat-card-label">In Progress</div></div></div>
        <div class="col-6 col-lg-3"><div class="stat-card">
            <div class="stat-card-icon" style="background:rgba(16,185,129,0.15)"><i class="fas fa-check-double" style="color:#10b981"></i></div>
            <div class="stat-card-value" style="color:#10b981" id="cnt-completed">—</div>
            <div class="stat-card-label">Completed</div></div></div>
        <div class="col-6 col-lg-3"><div class="stat-card">
            <div class="stat-card-icon" style="background:rgba(99,102,241,0.15)"><i class="fas fa-star" style="color:#6366f1"></i></div>
            <div class="stat-card-value text-gradient" id="cnt-avg-score">—</div>
            <div class="stat-card-label">Avg AI Score</div></div></div>
    </div>

    <!-- Interview List -->
    <div class="glass-card table-card">
        <div class="table-header">
            <h5 class="table-title">All Interviews</h5>
            <div class="d-flex gap-2">
                <select class="form-control form-control-dark" style="width:auto;font-size:0.82rem" id="status-filter" onchange="loadInterviews()">
                    <option value="">All Statuses</option>
                    <option value="SCHEDULED">Scheduled</option>
                    <option value="IN_PROGRESS">In Progress</option>
                    <option value="COMPLETED">Completed</option>
                    <option value="CANCELLED">Cancelled</option>
                </select>
            </div>
        </div>
        <div class="table-responsive">
            <table class="table table-dark-custom mb-0">
                <thead><tr>
                    <th>Candidate</th><th>Position</th><th>Type</th>
                    <th>Scheduled At</th><th>Duration</th><th>AI Score</th>
                    <th>Status</th><th>Actions</th>
                </tr></thead>
                <tbody id="interviews-table">
                    <tr><td colspan="8" class="text-center py-4"><div class="ai-loader justify-content-center"><div class="ai-spinner"></div>Loading...</div></td></tr>
                </tbody>
            </table>
        </div>
    </div>
</main>

<!-- Schedule Modal -->
<div class="modal fade" id="scheduleModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="background:var(--bg-dark);border:1px solid var(--border-color)">
            <div class="modal-header" style="border-color:var(--border-color)">
                <h5 class="modal-title">Schedule Interview</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div class="mb-3"><label class="form-label-dark">Application ID</label>
                    <input type="number" class="form-control form-control-dark" id="sched-app-id" placeholder="Application ID"></div>
                <div class="mb-3"><label class="form-label-dark">Interview Type</label>
                    <select class="form-control form-control-dark" id="sched-type">
                        <option value="TECHNICAL">Technical</option><option value="SYSTEM_DESIGN">System Design</option>
                        <option value="BEHAVIORAL">Behavioral</option><option value="HR">HR</option><option value="FINAL">Final Round</option>
                    </select></div>
                <div class="mb-3"><label class="form-label-dark">Scheduled Date &amp; Time</label>
                    <div class="d-flex gap-2">
                        <input type="date" class="form-control form-control-dark" id="sched-date" style="flex:1">
                        <input type="time" class="form-control form-control-dark" id="sched-time" value="10:00" style="flex:1">
                    </div></div>
                <div class="mb-3"><label class="form-label-dark">Duration (minutes)</label>
                    <input type="number" class="form-control form-control-dark" id="sched-duration" value="60" min="30" max="180"></div>
                <div class="mb-3"><label class="form-label-dark">Meeting Link</label>
                    <input type="url" class="form-control form-control-dark" id="sched-link" placeholder="https://meet.google.com/..."></div>
            </div>
            <div class="modal-footer" style="border-color:var(--border-color)">
                <button class="btn btn-glass" data-bs-dismiss="modal">Cancel</button>
                <button class="btn btn-primary-gradient" onclick="scheduleInterview()"><i class="fas fa-calendar-plus me-2"></i>Schedule</button>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/static/js/app.js"></script>
<script>
document.addEventListener('DOMContentLoaded', () => {
    loadInterviews();
    // Auto-fill default date (tomorrow) and time (10:00) when modal opens
    var schedModal = document.getElementById('scheduleModal');
    if (schedModal) {
        schedModal.addEventListener('show.bs.modal', function() {
            var tomorrow = new Date();
            tomorrow.setDate(tomorrow.getDate() + 1);
            var yyyy = tomorrow.getFullYear();
            var mm = String(tomorrow.getMonth() + 1).padStart(2, '0');
            var dd = String(tomorrow.getDate()).padStart(2, '0');
            document.getElementById('sched-date').value = yyyy + '-' + mm + '-' + dd;
            if (!document.getElementById('sched-time').value) {
                document.getElementById('sched-time').value = '10:00';
            }
        });
    }
    // Auto-open schedule modal if redirected from Accept & Schedule (jobs page)
    var urlParams = new URLSearchParams(window.location.search);
    var appId = urlParams.get('appId');
    if (appId && schedModal) {
        document.getElementById('sched-app-id').value = appId;
        setTimeout(() => { new bootstrap.Modal(schedModal).show(); }, 800);
    }
});


async function loadInterviews() {
    try {
        const user = Auth.getUser();
        const endpoint = user && user.role === 'CANDIDATE'
            ? '/api/interviews/candidate/' + user.id
            : '/api/interviews/recruiter/' + (user ? user.id : 0);
        const data = await Api.get(endpoint);
        renderInterviews(Array.isArray(data) ? data : []);
    } catch(e) {
        const user = Auth.getUser();
        if (user && user.role === 'CANDIDATE') {
            // Candidate sees empty state, not mock recruiter data
            renderInterviews([]);
        } else {
            renderMockInterviews();
        }
    }
}

function renderMockInterviews() {
    // Render demo data when not authenticated or API unavailable
    animateCounter(document.getElementById('cnt-scheduled'), 0, 8, 800);
    animateCounter(document.getElementById('cnt-progress'), 0, 2, 800);
    animateCounter(document.getElementById('cnt-completed'), 0, 34, 1000);
    document.getElementById('cnt-avg-score').textContent = '81%';

    const rows = [
        { name:'Sarah Johnson', role:'Senior Java Dev', type:'TECHNICAL', at:'Jun 10, 10:00 AM', dur:'90 min', score:92, status:'SCHEDULED' },
        { name:'Michael Chen', role:'DevOps Engineer', type:'SYSTEM_DESIGN', at:'Jun 11, 2:00 PM', dur:'60 min', score:null, status:'SCHEDULED' },
        { name:'Priya Sharma', role:'ML Engineer', type:'TECHNICAL', at:'Jun 5, 11:00 AM', dur:'60 min', score:88, status:'COMPLETED' },
        { name:'Alex Rivera', role:'React Developer', type:'HR', at:'Jun 4, 3:00 PM', dur:'45 min', score:76, status:'COMPLETED' },
        { name:'Emma Wilson', role:'Backend Engineer', type:'FINAL', at:'Jun 12, 9:00 AM', dur:'90 min', score:null, status:'SCHEDULED' },
    ];

    const statusMap = { SCHEDULED:'badge-pending', IN_PROGRESS:'badge-hired', COMPLETED:'badge-active', CANCELLED:'badge-closed' };
    document.getElementById('interviews-table').innerHTML = rows.map(function(r) { return '<tr>' +
        '<td><div class="d-flex align-items-center gap-2">' +
            '<div style="width:32px;height:32px;background:var(--gradient-primary);border-radius:8px;display:flex;align-items:center;justify-content:center;font-size:0.72rem;font-weight:700">' + r.name.split(' ').map(function(n){return n[0]}).join('') + '</div>' +
            '<span>' + r.name + '</span></div></td>' +
        '<td style="color:var(--text-secondary)">' + r.role + '</td>' +
        '<td><span class="tag">' + r.type.replace('_',' ') + '</span></td>' +
        '<td style="font-size:0.82rem">' + r.at + '</td>' +
        '<td style="color:var(--text-muted)">' + r.dur + '</td>' +
        '<td>' + (r.score ? '<span style="color:#10b981;font-weight:700">' + r.score + '%</span>' : '<span style="color:var(--text-muted)">Pending</span>') + '</td>' +
        '<td><span class="badge-status ' + statusMap[r.status] + '">' + r.status + '</span></td>' +
        '<td><div class="d-flex gap-1">' +
            '<button class="btn btn-sm btn-glass px-2" title="View"><i class="fas fa-eye"></i></button>' +
            (r.status==='COMPLETED' ? '<button class="btn btn-sm btn-glass px-2" title="AI Evaluate" onclick="aiEvaluate()"><i class="fas fa-brain"></i></button>' : '') +
            (r.status==='SCHEDULED' ? '<a class="btn btn-sm btn-glass px-2" href="'+(r.link||'#')+'" title="Join"><i class="fas fa-video"></i></a>' : '') +
        '</div></td>' +
    '</tr>'; }).join('');
}

function renderInterviews(data) {
    if (!data || !data.length) {
        document.getElementById('interviews-table').innerHTML =
            '<tr><td colspan="8" style="text-align:center;padding:40px;color:var(--text-muted)">No interviews scheduled yet. Click "+ Schedule Interview" to add one.</td></tr>';
        return;
    }
    const statusMap = { SCHEDULED:'badge-pending', IN_PROGRESS:'badge-hired', COMPLETED:'badge-active', CANCELLED:'badge-closed' };
    document.getElementById('interviews-table').innerHTML = data.map(function(r) { return '<tr>' +
        '<td>Candidate #' + r.candidateId + '</td>' +
        '<td style="color:var(--text-secondary)">Job #' + r.jobId + '</td>' +
        '<td><span class="tag">' + (r.interviewType||'').replace('_',' ') + '</span></td>' +
        '<td style="font-size:0.82rem">' + (r.scheduledAt ? new Date(r.scheduledAt).toLocaleString() : 'TBD') + '</td>' +
        '<td style="color:var(--text-muted)">' + (r.durationMinutes || 60) + ' min</td>' +
        '<td>' + (r.overallScore ? '<span style="color:#10b981;font-weight:700">'+r.overallScore+'%</span>' : '<span style="color:var(--text-muted)">Pending</span>') + '</td>' +
        '<td><span class="badge-status ' + (statusMap[r.status] || 'badge-pending') + '">' + r.status + '</span></td>' +
        '<td><button class="btn btn-sm btn-glass px-2"><i class="fas fa-eye"></i></button></td>' +
    '</tr>'; }).join('');
}

async function scheduleInterview() {
    var user = Auth.getUser();
    var appId = document.getElementById('sched-app-id').value;
    var dateVal = document.getElementById('sched-date').value;
    var timeVal = document.getElementById('sched-time').value || '10:00';
    if (!appId || !dateVal) { showToast('Application ID and date are required', 'error'); return; }
    var scheduledAt = dateVal + 'T' + timeVal + ':00';

    // Look up application to get real candidateId and jobId
    var candidateId = 0, jobId = 0;
    try {
        var apps = await Api.get('/api/applications/candidate/0').catch(() => null);
        // Instead, fetch by applicationId via the status endpoint trick
        // Fetch the shortlisted list and find this app
        var allApps = await Api.get('/api/applications/shortlisted').catch(() => []);
        var found = (Array.isArray(allApps) ? allApps : []).find(a => String(a.id) === String(appId));
        if (found) {
            candidateId = found.candidateId || 0;
            jobId = found.jobId || 0;
        }
    } catch(e) { /* non-critical, proceed with 0 */ }

    try {
        await Api.post('/api/interviews', {
            applicationId: parseInt(appId),
            candidateId: candidateId,
            recruiterId: user ? user.id : 0,
            jobId: jobId,
            interviewType: document.getElementById('sched-type').value,
            scheduledAt: scheduledAt,
            durationMinutes: parseInt(document.getElementById('sched-duration').value),
            meetingLink: document.getElementById('sched-link').value
        });
        showToast('Interview scheduled successfully! 🎉', 'success');
        bootstrap.Modal.getInstance(document.getElementById('scheduleModal')).hide();
        loadInterviews();
    } catch(e) { showToast('Error: ' + e.message, 'error'); }
}


function aiEvaluate() { window.location.href = '/agents'; }
</script>
</body></html>
