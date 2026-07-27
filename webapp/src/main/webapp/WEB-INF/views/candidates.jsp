<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Candidates — AgentHire AI</title>
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
            <a href="/candidates" class="sidebar-link active"><i class="fas fa-users"></i><span>Candidates</span></a>
            <a href="/interviews" class="sidebar-link"><i class="fas fa-calendar-check"></i><span>Interviews</span></a>
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
        <div><h1 class="page-title">Candidate Pipeline</h1><p style="color:var(--text-secondary);font-size:0.85rem;margin:0">AI-powered talent discovery and screening</p></div>
    </div>

    <!-- Search -->
    <div class="glass-card p-4 mb-4">
        <div class="row g-3 align-items-end">
            <div class="col-md-4"><label class="form-label-dark">Search Candidates</label>
                <div class="input-group">
                    <span class="input-group-text ig-dark"><i class="fas fa-search"></i></span>
                    <input type="text" class="form-control form-control-dark" id="search-q" placeholder="Name, skill, role..." oninput="debounce(searchCandidates, 400)()">
                </div></div>
            <div class="col-md-2"><label class="form-label-dark">Location</label>
                <input type="text" class="form-control form-control-dark" id="search-loc" placeholder="City or Remote"></div>
            <div class="col-md-2"><label class="form-label-dark">Min Experience</label>
                <input type="number" class="form-control form-control-dark" id="search-exp" placeholder="Years" min="0"></div>
            <div class="col-md-2"><label class="form-label-dark">AI Min Score</label>
                <input type="number" class="form-control form-control-dark" id="search-score" placeholder="75" min="0" max="100"></div>
            <div class="col-md-2">
                <button class="btn btn-primary-gradient w-100" onclick="searchCandidates()"><i class="fas fa-filter me-1"></i>Filter</button>
            </div>
        </div>
    </div>

    <!-- Candidates Grid -->
    <div id="candidates-grid" class="row g-4">
        <!-- Populated by JS -->
    </div>
</main>

<!-- Candidate Detail Modal -->
<div class="modal fade" id="candidateModal" tabindex="-1">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content" style="background:var(--bg-dark);border:1px solid var(--border-color)">
            <div class="modal-header" style="border-color:var(--border-color)">
                <h5 class="modal-title" id="modal-candidate-name">Candidate Profile</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body" id="modal-candidate-body"></div>
            <div class="modal-footer" style="border-color:var(--border-color)">
                <button class="btn btn-glass" data-bs-dismiss="modal">Close</button>
                <button class="btn btn-glass" onclick="runMatchAgent()"><i class="fas fa-bullseye me-2"></i>AI Match</button>
                <button class="btn btn-primary-gradient" onclick="scheduleInterview()"><i class="fas fa-calendar-plus me-2"></i>Schedule Interview</button>
            </div>
        </div>
    </div>
</div>

<style>
.ig-dark{background:rgba(255,255,255,0.05)!important;border-color:rgba(255,255,255,0.1)!important;color:var(--text-muted)!important}
.candidate-card{padding:24px;cursor:pointer}
.candidate-card:hover{transform:translateY(-4px);border-color:rgba(99,102,241,0.3)}
.skill-chip{display:inline-block;padding:3px 10px;background:rgba(99,102,241,0.1);border:1px solid rgba(99,102,241,0.2);border-radius:50px;font-size:0.72rem;font-weight:500;color:#818cf8;margin:2px}
</style>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/static/js/app.js"></script>
<script>
const mockCandidates = [
    { id:1, name:'Sarah Johnson', role:'Senior Java Developer', exp:7, location:'New York, NY', skills:['Java','Spring Boot','Kafka','Redis','Docker'], score:94, avatar:'SJ', status:'AVAILABLE' },
    { id:2, name:'Michael Chen', role:'Full Stack Engineer', exp:5, location:'San Francisco, CA', skills:['React','Node.js','TypeScript','AWS'], score:87, avatar:'MC', status:'AVAILABLE' },
    { id:3, name:'Priya Sharma', role:'ML / AI Engineer', exp:4, location:'Remote', skills:['Python','TensorFlow','PyTorch','Kafka','SQL'], score:91, avatar:'PS', status:'IN_PROCESS' },
    { id:4, name:'Alex Rivera', role:'DevOps / SRE Engineer', exp:6, location:'Austin, TX', skills:['Docker','Kubernetes','CI/CD','Terraform','Grafana'], score:89, avatar:'AR', status:'AVAILABLE' },
    { id:5, name:'Emma Wilson', role:'Backend Architect', exp:10, location:'Remote', skills:['Java','Microservices','Kafka','MySQL','Zipkin'], score:96, avatar:'EW', status:'AVAILABLE' },
    { id:6, name:'David Park', role:'React Developer', exp:3, location:'Chicago, IL', skills:['React','JavaScript','Redux','CSS','REST APIs'], score:78, avatar:'DP', status:'AVAILABLE' },
];

let selectedCandidate = null;

document.addEventListener('DOMContentLoaded', () => { loadShortlistedCandidates(); });

async function loadShortlistedCandidates() {
    const grid = document.getElementById('candidates-grid');
    grid.innerHTML = '<div class="col-12 text-center py-5"><div class="ai-spinner mx-auto mb-3"></div><p style="color:var(--text-muted)">Loading candidates...</p></div>';
    try {
        const apps = await Api.get('/api/applications/shortlisted');
        allCandidates = Array.isArray(apps) ? apps.map(a => ({
            id: a.id,
            candidateId: a.candidateId,
            name: 'Candidate #' + a.candidateId,
            role: a.jobTitle || ('Job #' + a.jobId),
            company: a.companyName || '',
            exp: 0,
            location: '—',
            skills: [],
            score: 0,
            avatar: 'C' + a.candidateId,
            status: a.status,
            applicationId: a.id,
            appliedAt: a.appliedAt
        })) : [];
        renderCandidates(allCandidates);
    } catch(e) {
        grid.innerHTML = '<div class="col-12 text-center py-5" style="color:var(--text-muted)"><i class="fas fa-users fa-2x mb-3 d-block"></i>No shortlisted candidates yet.<br><small>Accept applications from the <a href="/jobs" style="color:#818cf8">Jobs page</a> to see candidates here.</small></div>';
    }
}

let allCandidates = [];


function debounce(fn, delay) { let t; return function(...a) { clearTimeout(t); t = setTimeout(() => fn(...a), delay); }; }

function searchCandidates() {
    const q = document.getElementById('search-q').value.toLowerCase();
    const loc = document.getElementById('search-loc').value.toLowerCase();
    const minExp = parseInt(document.getElementById('search-exp').value) || 0;
    const minScore = parseInt(document.getElementById('search-score').value) || 0;
    const filtered = allCandidates.filter(c =>
        (!q || c.name.toLowerCase().includes(q) || c.role.toLowerCase().includes(q) || c.skills.some(s => s.toLowerCase().includes(q))) &&
        (!loc || c.location.toLowerCase().includes(loc)) &&
        c.exp >= minExp && c.score >= minScore
    );
    renderCandidates(filtered);
}

function renderCandidates(list) {
    const statusMap = { AVAILABLE:'badge-active', IN_PROCESS:'badge-pending', HIRED:'badge-hired' };
    document.getElementById('candidates-grid').innerHTML = list.length ? list.map(function(c) { return '<div class="col-lg-4 col-md-6">' +
            '<div class="glass-card candidate-card h-100" onclick="viewCandidate(' + c.id + ')">' +
                '<div class="d-flex align-items-center gap-3 mb-3">' +
                    '<div style="width:52px;height:52px;background:var(--gradient-primary);border-radius:14px;display:flex;align-items:center;justify-content:center;font-size:1rem;font-weight:800;flex-shrink:0">' + c.avatar + '</div>' +
                    '<div style="flex:1;min-width:0">' +
                        '<h6 style="font-weight:700;margin:0;white-space:nowrap;overflow:hidden;text-overflow:ellipsis">' + c.name + '</h6>' +
                        '<p style="color:var(--text-secondary);font-size:0.8rem;margin:0">' + c.role + '</p>' +
                    '</div>' +
                    '<span class="badge-status ' + statusMap[c.status] + '">' + c.status.replace('_',' ') + '</span>' +
                '</div>' +
                '<div class="d-flex gap-3 mb-3" style="font-size:0.8rem;color:var(--text-secondary)">' +
                    '<span><i class="fas fa-briefcase me-1"></i>' + c.exp + 'y exp</span>' +
                    '<span><i class="fas fa-map-marker-alt me-1"></i>' + c.location + '</span>' +
                '</div>' +
                '<div class="mb-3">' + c.skills.slice(0,4).map(function(s){return '<span class="skill-chip">'+s+'</span>'}).join('') + (c.skills.length>4 ? '<span class="skill-chip">+'+( c.skills.length-4)+'</span>' : '') + '</div>' +
                '<div class="d-flex align-items-center justify-content-between">' +
                    '<div style="font-size:0.78rem;color:var(--text-muted)">AI Match Score</div>' +
                    '<div class="d-flex align-items-center gap-2">' +
                        '<div style="width:60px;height:6px;background:var(--border-color);border-radius:3px"><div style="width:' + c.score + '%;height:100%;background:' + (c.score>=90?'#10b981':c.score>=75?'#f59e0b':'#ef4444') + ';border-radius:3px"></div></div>' +
                        '<span style="font-weight:700;color:' + (c.score>=90?'#10b981':c.score>=75?'#f59e0b':'#ef4444') + '">' + c.score + '%</span>' +
                    '</div>' +
                '</div>' +
            '</div>' +
        '</div>'; }) .join('') :
        '<div class="col-12 text-center py-5" style="color:var(--text-muted)"><i class="fas fa-users fa-2x mb-3 d-block"></i>No candidates found</div>';
}

function viewCandidate(id) {
    selectedCandidate = mockCandidates.find(c => c.id === id);
    if (!selectedCandidate) return;
    document.getElementById('modal-candidate-name').textContent = selectedCandidate.name;
    document.getElementById('modal-candidate-body').innerHTML = '<div class="row g-3">' +
            '<div class="col-md-4 text-center">' +
                '<div style="width:80px;height:80px;background:var(--gradient-primary);border-radius:20px;display:flex;align-items:center;justify-content:center;font-size:1.5rem;font-weight:800;margin:0 auto 12px">' + selectedCandidate.avatar + '</div>' +
                '<div style="font-size:2rem;font-weight:900;background:var(--gradient-primary);-webkit-background-clip:text;-webkit-text-fill-color:transparent">' + selectedCandidate.score + '%</div>' +
                '<div style="font-size:0.8rem;color:var(--text-secondary)">AI Score</div>' +
            '</div>' +
            '<div class="col-md-8">' +
                '<h5 class="fw-bold mb-1">' + selectedCandidate.role + '</h5>' +
                '<p style="color:var(--text-secondary);font-size:0.88rem;margin-bottom:12px"><i class="fas fa-map-marker-alt me-1"></i>' + selectedCandidate.location + ' · <i class="fas fa-briefcase ms-2 me-1"></i>' + selectedCandidate.exp + ' years experience</p>' +
                '<div class="mb-3">' + selectedCandidate.skills.map(function(s){return '<span class="skill-chip">'+s+'</span>'}).join('') + '</div>' +
                '<div class="d-flex gap-2">' +
                    '<a href="#" class="btn btn-glass btn-sm"><i class="fab fa-linkedin me-1"></i>LinkedIn</a>' +
                    '<a href="#" class="btn btn-glass btn-sm"><i class="fab fa-github me-1"></i>GitHub</a>' +
                '</div>' +
            '</div>' +
        '</div>';
    new bootstrap.Modal(document.getElementById('candidateModal')).show();
}

function runMatchAgent() {
    if (selectedCandidate) { showToast('Redirecting to Job Matcher agent...', 'info'); setTimeout(() => window.location.href='/agents', 800); }
}
function scheduleInterview() { window.location.href='/interviews'; }
</script>
</body></html>
