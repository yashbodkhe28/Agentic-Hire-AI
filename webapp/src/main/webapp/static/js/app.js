/* =============================================
   AgentHire AI â€” Main Application JavaScript
   ============================================= */

const API_BASE = '';  // API Gateway

// ======== TOKEN MANAGEMENT ========
const Auth = {
    getToken: () => localStorage.getItem('accessToken'),
    getUser: () => JSON.parse(localStorage.getItem('user') || 'null'),
    isLoggedIn: () => !!localStorage.getItem('accessToken'),

    setSession: (data) => {
        localStorage.setItem('accessToken', data.accessToken);
        localStorage.setItem('refreshToken', data.refreshToken);
        localStorage.setItem('user', JSON.stringify(data.user));
    },

    clearSession: () => {
        localStorage.removeItem('accessToken');
        localStorage.removeItem('refreshToken');
        localStorage.removeItem('user');
    },

    headers: () => ({
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${Auth.getToken()}`
    })
};

// ======== API CLIENT ========
const Api = {
    async request(method, url, body = null) {
        const opts = {
            method,
            headers: Auth.headers()
        };
        if (body) opts.body = JSON.stringify(body);

        try {
            const res = await fetch(API_BASE + url, opts);

            if (res.status === 401) {
                // Try refresh
                await Api.refreshToken();
                const retryOpts = { method, headers: Auth.headers() };
                if (body) retryOpts.body = JSON.stringify(body);
                const retry = await fetch(url, retryOpts);
                if (!retry.ok) throw new Error('Unauthorized');
                return retry.json();
            }

            if (!res.ok) {
                const err = await res.json().catch(() => ({}));
                throw new Error(err.message || `HTTP ${res.status}`);
            }

            return res.json();
        } catch (e) {
            console.error(`API Error [${method} ${url}]:`, e.message);
            throw e;
        }
    },

    async refreshToken() {
        const refreshToken = localStorage.getItem('refreshToken');
        if (!refreshToken) {
            Auth.clearSession();
            window.location.href = '/login';
            return;
        }
        try {
            const data = await fetch('/api/auth/refresh', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ refreshToken })
            }).then(r => r.json());
            localStorage.setItem('accessToken', data.accessToken);
            localStorage.setItem('refreshToken', data.refreshToken);
        } catch {
            Auth.clearSession();
            window.location.href = '/login';
        }
    },

    get: (url) => Api.request('GET', url),
    post: (url, body) => Api.request('POST', url, body),
    put: (url, body) => Api.request('PUT', url, body),
    delete: (url) => Api.request('DELETE', url)
};

// ======== LANDING PAGE ANIMATIONS ========
function initLandingPage() {
    // Counter animation
    document.querySelectorAll('.counter').forEach(el => {
        const target = parseInt(el.dataset.target);
        let current = 0;
        const step = target / 60;
        const timer = setInterval(() => {
            current = Math.min(current + step, target);
            el.textContent = Math.floor(current);
            if (current >= target) clearInterval(timer);
        }, 25);
    });

    // Scroll reveal
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.opacity = '1';
                entry.target.style.transform = 'translateY(0)';
                observer.unobserve(entry.target);
            }
        });
    }, { threshold: 0.1 });

    document.querySelectorAll('.feature-card, .agent-card, .tech-item').forEach(el => {
        el.style.opacity = '0';
        el.style.transform = 'translateY(30px)';
        el.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
        observer.observe(el);
    });

    // Particle system
    createParticles();
}

function createParticles() {
    const container = document.getElementById('particles');
    if (!container) return;
    for (let i = 0; i < 30; i++) {
        const particle = document.createElement('div');
        particle.style.cssText = `
            position: absolute;
            width: ${Math.random() * 3 + 1}px;
            height: ${Math.random() * 3 + 1}px;
            background: rgba(99, 102, 241, ${Math.random() * 0.4 + 0.1});
            border-radius: 50%;
            left: ${Math.random() * 100}%;
            top: ${Math.random() * 100}%;
            animation: floatParticle ${Math.random() * 20 + 10}s ease-in-out infinite;
            animation-delay: -${Math.random() * 20}s;
        `;
        container.appendChild(particle);
    }

    const style = document.createElement('style');
    style.textContent = `
        @keyframes floatParticle {
            0%, 100% { transform: translate(0, 0) opacity(0.5); }
            25% { transform: translate(${Math.random() * 100 - 50}px, ${Math.random() * 100 - 50}px); }
            50% { transform: translate(${Math.random() * 100 - 50}px, ${Math.random() * 100 - 50}px); opacity: 1; }
            75% { transform: translate(${Math.random() * 100 - 50}px, ${Math.random() * 100 - 50}px); }
        }
    `;
    document.head.appendChild(style);
}

// ======== AUTH FORMS ========
async function handleLogin(e) {
    e.preventDefault();
    const form = e.target;
    const submitBtn = form.querySelector('[type="submit"]');
    const email = form.querySelector('#email').value;
    const password = form.querySelector('#password').value;

    setButtonLoading(submitBtn, true, 'Signing in...');
    hideAlert();

    try {
        const data = await Api.post('/api/auth/login', { email, password });
        Auth.setSession(data.data);
        showAlert('Login successful! Redirecting...', 'success');
        setTimeout(() => window.location.href = '/dashboard', 1000);
    } catch (e) {
        showAlert(e.message || 'Invalid credentials. Please try again.', 'error');
    } finally {
        setButtonLoading(submitBtn, false, '<i class="fas fa-sign-in-alt me-2"></i>Sign In');
    }
}

async function handleRegister(e) {
    e.preventDefault();
    const form = e.target;
    const submitBtn = form.querySelector('[type="submit"]');

    const payload = {
        email: form.querySelector('#email').value,
        password: form.querySelector('#password').value,
        firstName: form.querySelector('#firstName').value,
        lastName: form.querySelector('#lastName').value,
        phone: form.querySelector('#phone')?.value,
        roleName: form.querySelector('#role')?.value || 'CANDIDATE'
    };

    setButtonLoading(submitBtn, true, 'Creating Account...');
    hideAlert();

    try {
        const data = await Api.post('/api/auth/register', payload);
        Auth.setSession(data.data);
        showAlert('Account created! Redirecting to dashboard...', 'success');
        setTimeout(() => window.location.href = '/dashboard', 1200);
    } catch (e) {
        showAlert(e.message || 'Registration failed. Please try again.', 'error');
    } finally {
        setButtonLoading(submitBtn, false, '<i class="fas fa-user-plus me-2"></i>Create Account');
    }
}

// ======== DASHBOARD ========
async function loadDashboard() {
    if (!Auth.isLoggedIn()) { window.location.href = '/login'; return; }
    const user = Auth.getUser();
    if (user) {
        document.querySelectorAll('.user-name').forEach(el => el.textContent = `${user.firstName} ${user.lastName}`);
        document.querySelectorAll('.user-role').forEach(el => el.textContent = user.role);
        document.querySelectorAll('.user-avatar-text').forEach(el =>
            el.textContent = (user.firstName[0] + user.lastName[0]).toUpperCase());
    }

    if (user && user.role === 'CANDIDATE') {
        await loadCandidateDashboard(user);
    } else {
        await loadRecruiterDashboard();
    }
}

async function loadCandidateDashboard(user) {
    // Set flag so inline JSP dashboard script skips mock data
    window._candidateMode = true;

    // Hide recruiter-only sections
    document.querySelectorAll('#recruiter-stats, .hiring-pipeline-section, .agent-status-section, .recent-apps-section, .recruiter-table-section, .ai-tools-section').forEach(el => el.style.display = 'none');
    // Hide "Post Job" button in topbar
    document.querySelectorAll('.topbar-actions .btn-primary-gradient').forEach(el => { if (el.textContent.includes('Post')) el.style.display = 'none'; });

    // Update stat cards for candidate
    const statCards = document.querySelector('.stats-grid');
    if (statCards) {
        statCards.innerHTML = `
        <div class="stat-card sc-purple">
            <div class="d-flex align-items-start justify-content-between mb-3">
                <div class="stat-card-icon si-purple"><i class="fas fa-paper-plane"></i></div>
                <span class="badge-status badge-active">Live</span>
            </div>
            <div class="stat-card-value text-gradient" id="cstat-applied">—</div>
            <div class="stat-card-label">Applications Sent</div>
        </div>
        <div class="stat-card sc-cyan">
            <div class="d-flex align-items-start justify-content-between mb-3">
                <div class="stat-card-icon si-cyan"><i class="fas fa-star"></i></div>
                <span class="badge-status badge-active">Good</span>
            </div>
            <div class="stat-card-value" style="color:#22d3ee" id="cstat-shortlisted">—</div>
            <div class="stat-card-label">Shortlisted</div>
        </div>
        <div class="stat-card sc-green">
            <div class="d-flex align-items-start justify-content-between mb-3">
                <div class="stat-card-icon si-green"><i class="fas fa-calendar-check"></i></div>
                <span class="badge-status badge-active">Scheduled</span>
            </div>
            <div class="stat-card-value" style="color:#34d399" id="cstat-interviews">—</div>
            <div class="stat-card-label">Interviews</div>
        </div>
        <div class="stat-card sc-pink">
            <div class="d-flex align-items-start justify-content-between mb-3">
                <div class="stat-card-icon si-pink"><i class="fas fa-trophy"></i></div>
                <span class="badge-status badge-active">Status</span>
            </div>
            <div class="stat-card-value" style="color:#f9a8d4" id="cstat-hired">—</div>
            <div class="stat-card-label">Offers Received</div>
        </div>`;
    }

    // Replace chart/table area with "My Applications"
    const chartArea = document.querySelector('.row.g-4.mb-4');
    if (chartArea) {
        chartArea.outerHTML = `
        <div class="glass-card table-card mb-4" id="my-apps-section">
            <div class="table-header">
                <h5 class="table-title">My Applications</h5>
                <a href="/jobs" class="btn btn-primary-gradient btn-sm"><i class="fas fa-search me-1"></i>Browse Jobs</a>
            </div>
            <div class="table-responsive">
                <table class="table table-dark-custom mb-0">
                    <thead><tr>
                        <th>Job Title</th><th>Company</th><th>Applied</th><th>Status</th><th>Actions</th>
                    </tr></thead>
                    <tbody id="my-apps-table"><tr><td colspan="5" class="text-center py-4" style="color:var(--text-muted)"><div class="ai-spinner mx-auto mb-2"></div>Loading...</td></tr></tbody>
                </table>
            </div>
        </div>`;
    }

    // Fetch real data
    try {
        const apps = await Api.get('/api/applications/candidate/' + user.id);
        const list = Array.isArray(apps) ? apps : [];
        const shortlisted = list.filter(a => ['SHORTLISTED','INTERVIEW','HIRED'].includes(a.status));
        const interviews = list.filter(a => a.status === 'INTERVIEW');
        const hired = list.filter(a => a.status === 'HIRED');

        const setVal = (id, val) => { const el = document.getElementById(id); if (el) animateCounter(el, 0, val, 800); };
        setVal('cstat-applied', list.length);
        setVal('cstat-shortlisted', shortlisted.length);
        setVal('cstat-interviews', interviews.length);
        setVal('cstat-hired', hired.length);

        const statusColors = { APPLIED:'badge-pending', SHORTLISTED:'badge-active', REJECTED:'badge-closed', INTERVIEW:'badge-hired', HIRED:'badge-active' };
        const tbody = document.getElementById('my-apps-table');
        if (tbody) {
            if (!list.length) {
                tbody.innerHTML = '<tr><td colspan="5" class="text-center py-5" style="color:var(--text-muted)"><i class="fas fa-briefcase fa-2x mb-3 d-block"></i>No applications yet. <a href="/jobs" style="color:#818cf8">Browse jobs</a></td></tr>';
            } else {
                tbody.innerHTML = list.map(a => `<tr>
                    <td style="font-weight:600">${escHtml(a.jobTitle || ('Job #' + a.jobId))}</td>
                    <td style="color:var(--text-secondary)">${escHtml(a.companyName || '—')}</td>
                    <td style="font-size:0.82rem;color:var(--text-muted)">${a.appliedAt ? new Date(a.appliedAt).toLocaleDateString() : 'N/A'}</td>
                    <td><span class="badge-status ${statusColors[a.status] || 'badge-pending'}">${a.status}</span></td>
                    <td><a href="/interviews" class="btn btn-sm btn-glass"><i class="fas fa-calendar"></i></a></td>
                </tr>`).join('');
            }
        }
    } catch(e) {
        const tbody = document.getElementById('my-apps-table');
        if (tbody) tbody.innerHTML = '<tr><td colspan="5" class="text-center py-4" style="color:var(--text-muted)">No applications found yet. <a href="/jobs" style="color:#818cf8">Browse jobs</a></td></tr>';
        ['cstat-applied','cstat-shortlisted','cstat-interviews','cstat-hired'].forEach(id => { const el = document.getElementById(id); if(el) el.textContent = '0'; });
    }
}

async function loadRecruiterDashboard() {
    try {
        const [jobs, stats] = await Promise.all([
            Api.get('/api/jobs?size=1&page=0'),
            Api.get('/api/applications/stats').catch(() => ({}))
        ]);
        const totalJobs = jobs.totalElements || (jobs.content ? jobs.content.length : 0);
        const el = id => document.getElementById(id);
        if (el('stat-jobs')) animateCounter(el('stat-jobs'), 0, totalJobs, 1000);
        if (el('stat-candidates')) animateCounter(el('stat-candidates'), 0, Number(stats.total || 0), 1000);
        if (el('stat-interviews')) animateCounter(el('stat-interviews'), 0, Number(stats.interview || 0), 1000);
    } catch(e) {
        // fallback — animate with 0
        ['stat-jobs','stat-candidates','stat-interviews'].forEach(id => {
            const el = document.getElementById(id); if (el) el.textContent = '—';
        });
    }
}

function animateCounter(el, start, end, duration) {
    const startTime = performance.now();
    function update(currentTime) {
        const elapsed = currentTime - startTime;
        const progress = Math.min(elapsed / duration, 1);
        const eased = 1 - Math.pow(1 - progress, 3);
        el.textContent = Math.floor(start + (end - start) * eased).toLocaleString();
        if (progress < 1) requestAnimationFrame(update);
    }
    requestAnimationFrame(update);
}

// ======== AGENT EXECUTION ========
async function executeAgent(agentType, payload, referenceType, referenceId) {
    const resultDiv = document.getElementById('agent-result-' + agentType);
    const btn = document.getElementById('agent-btn-' + agentType);

    if (resultDiv) {
        resultDiv.style.display = 'block';
        resultDiv.innerHTML = '<div class="ai-loader"><div class="ai-spinner"></div>AI Agent is processing...</div>';
    }
    if (btn) btn.disabled = true;

    try {
        const data = await Api.post('/api/agents/execute/' + agentType, {
            payload: payload || {},
            referenceType: referenceType || 'GENERAL',
            referenceId: referenceId || 0
        });

        if (resultDiv) {
            // report may be JSON string or plain markdown — handle both
            var reportRaw = data.report || '';
            var displayText = reportRaw;
            try { displayText = JSON.stringify(JSON.parse(reportRaw), null, 2); } catch(e) { /* not JSON, use as-is */ }
            resultDiv.innerHTML = '<pre style="white-space:pre-wrap;word-break:break-word;font-family:Inter,sans-serif;font-size:0.82rem;line-height:1.6">' + displayText + '</pre>';
        }

        showToast('Agent ' + agentType + ' completed!', 'success');
        return data;
    } catch (e) {
        if (resultDiv) {
            resultDiv.innerHTML = '<span style="color:#ef4444">Error: ' + e.message + '</span>';
        }
        showToast('Agent execution failed: ' + e.message, 'error');
        throw e;
    } finally {
        if (btn) btn.disabled = false;
    }
}

// ======== JOB MANAGEMENT ========
async function loadJobs(filters = {}) {
    const params = new URLSearchParams(filters).toString();
    const container = document.getElementById('jobs-container');
    if (!container) return;

    container.innerHTML = '<div class="text-center py-5"><div class="ai-spinner mx-auto"></div></div>';

    try {
        const data = await Api.get(`/api/jobs?${params}`);
        const jobs = data.content || data || [];

        if (jobs.length === 0) {
            container.innerHTML = '<div class="text-center py-5 text-muted"><i class="fas fa-search fa-2x mb-3 d-block"></i>No jobs found</div>';
            return;
        }

        const user = Auth.getUser();
        const isRecruiter = user && user.role === 'RECRUITER';

        container.innerHTML = jobs.map(job => `
            <div class="job-card glass-card p-4 mb-3 hover-lift">
                <div class="d-flex align-items-start justify-content-between">
                    <div class="flex-grow-1">
                        <h5 class="fw-bold mb-1">${escHtml(job.title)}</h5>
                        <div class="d-flex gap-2 flex-wrap mb-2">
                            ${job.company ? `<span class="text-muted small"><i class="fas fa-building me-1"></i>${escHtml(job.company.name)}</span>` : ''}
                            ${job.location ? `<span class="text-muted small"><i class="fas fa-map-marker-alt me-1"></i>${escHtml(job.location)}</span>` : ''}
                            ${job.isRemote ? '<span class="badge-status badge-active">Remote</span>' : ''}
                        </div>
                        <div class="d-flex gap-2 flex-wrap">
                            ${job.jobType ? `<span class="tag">${job.jobType.replace('_', ' ')}</span>` : ''}
                            ${job.experienceLevel ? `<span class="tag">${job.experienceLevel}</span>` : ''}
                            ${job.minSalary ? `<span class="tag">$${(job.minSalary/1000).toFixed(0)}k - $${(job.maxSalary/1000).toFixed(0)}k</span>` : ''}
                        </div>
                    </div>
                    <div class="d-flex flex-column align-items-end gap-2">
                        <span class="badge-status ${job.status === 'ACTIVE' ? 'badge-active' : 'badge-closed'}">${job.status}</span>
                        ${isRecruiter
                            ? `<button class="btn btn-glass btn-sm" onclick="viewApplications(${job.id}, '${escHtml(job.title)}')">
                                <i class="fas fa-users me-1"></i>View Applications
                               </button>`
                            : `<button class="btn btn-primary-gradient btn-sm" onclick="applyForJob(${job.id})">
                                <i class="fas fa-paper-plane me-1"></i>Apply
                               </button>`
                        }
                    </div>
                </div>
            </div>
        `).join('');
    } catch (e) {
        container.innerHTML = `<div class="alert alert-danger">Failed to load jobs: ${e.message}</div>`;
    }
}

// ======== APPLICATIONS WORKFLOW ========
async function viewApplications(jobId, jobTitle) {
    // Inject modal if not present
    if (!document.getElementById('appsModal')) {
        document.body.insertAdjacentHTML('beforeend', `
        <div class="modal fade" id="appsModal" tabindex="-1">
          <div class="modal-dialog modal-lg modal-dialog-centered">
            <div class="modal-content" style="background:var(--bg-dark);border:1px solid var(--border-color)">
              <div class="modal-header" style="border-color:var(--border-color)">
                <h5 class="modal-title fw-bold" id="appsModalTitle">Applications</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
              </div>
              <div class="modal-body" id="appsModalBody"></div>
            </div>
          </div>
        </div>`);
    }
    document.getElementById('appsModalTitle').textContent = 'Applications — ' + jobTitle;
    document.getElementById('appsModalBody').innerHTML = '<div class="text-center py-4"><div class="ai-spinner mx-auto"></div></div>';
    const modal = new bootstrap.Modal(document.getElementById('appsModal'));
    modal.show();
    try {
        const apps = await Api.get('/api/applications/job/' + jobId);
        if (!apps || apps.length === 0) {
            document.getElementById('appsModalBody').innerHTML =
                '<p class="text-center py-4" style="color:var(--text-muted)">No applications yet for this job.</p>';
            return;
        }
        const statusColors = { APPLIED:'badge-pending', SHORTLISTED:'badge-active', REJECTED:'badge-closed', INTERVIEW:'badge-hired', HIRED:'badge-active' };
        document.getElementById('appsModalBody').innerHTML = `
        <table class="table table-dark table-hover mb-0">
          <thead><tr>
            <th>Candidate ID</th><th>Applied At</th><th>Status</th><th>Actions</th>
          </tr></thead>
          <tbody>
          ${apps.map(a => `<tr id="app-row-${a.id}">
            <td><i class="fas fa-user-circle me-2" style="color:var(--neon-purple)"></i>Candidate #${a.candidateId}</td>
            <td style="font-size:0.82rem;color:var(--text-secondary)">${a.appliedAt ? new Date(a.appliedAt).toLocaleDateString() : 'N/A'}</td>
            <td><span class="badge-status ${statusColors[a.status] || 'badge-pending'}" id="app-status-${a.id}">${a.status}</span></td>
            <td>
              <div class="d-flex gap-1">
                ${a.status === 'REJECTED' ? '' : `
                <button class="btn btn-sm" style="background:rgba(16,185,129,0.15);color:#10b981;border:1px solid #10b98133"
                  onclick="acceptApplication(${a.id}, ${jobId})" id="accept-btn-${a.id}">
                  <i class="fas fa-check me-1"></i>Accept & Schedule
                </button>`}
                ${a.status !== 'REJECTED' && a.status !== 'HIRED' ? `
                <button class="btn btn-sm" style="background:rgba(239,68,68,0.15);color:#ef4444;border:1px solid #ef444433"
                  onclick="rejectApplication(${a.id})" id="reject-btn-${a.id}">
                  <i class="fas fa-times me-1"></i>Reject
                </button>` : ''}
              </div>
            </td>
          </tr>`).join('')}
          </tbody>
        </table>`;
    } catch(e) {
        document.getElementById('appsModalBody').innerHTML = `<p class="text-danger">Error: ${e.message}</p>`;
    }
}

async function acceptApplication(appId, jobId) {
    try {
        await Api.put('/api/applications/' + appId + '/status', { status: 'SHORTLISTED' });
        const btn = document.getElementById('accept-btn-' + appId);
        const statusBadge = document.getElementById('app-status-' + appId);
        if (statusBadge) { statusBadge.textContent = 'SHORTLISTED'; statusBadge.className = 'badge-status badge-active'; }
        if (btn) btn.innerHTML = '<i class="fas fa-check me-1"></i>Accepted';
        showToast('Candidate shortlisted! Redirecting to schedule interview...', 'success');
        // Close modal and redirect to interviews with pre-filled applicationId
        setTimeout(() => {
            bootstrap.Modal.getInstance(document.getElementById('appsModal')).hide();
            window.location.href = '/interviews?appId=' + appId;
        }, 1500);
    } catch(e) { showToast('Error: ' + e.message, 'error'); }
}

async function rejectApplication(appId) {
    try {
        await Api.put('/api/applications/' + appId + '/status', { status: 'REJECTED' });
        const row = document.getElementById('app-row-' + appId);
        if (row) {
            const statusBadge = document.getElementById('app-status-' + appId);
            if (statusBadge) { statusBadge.textContent = 'REJECTED'; statusBadge.className = 'badge-status badge-closed'; }
            const acceptBtn = document.getElementById('accept-btn-' + appId);
            const rejectBtn = document.getElementById('reject-btn-' + appId);
            if (acceptBtn) acceptBtn.remove();
            if (rejectBtn) rejectBtn.remove();
        }
        showToast('Application rejected.', 'success');
    } catch(e) { showToast('Error: ' + e.message, 'error'); }
}

// ======== HELPERS ========
function setButtonLoading(btn, loading, text) {
    if (!btn) return;
    btn.disabled = loading;
    btn.innerHTML = loading
        ? '<div class="ai-spinner d-inline-block me-2"></div>Loading...'
        : text;
}

function showAlert(message, type = 'info') {
    const alertDiv = document.getElementById('alert-container');
    if (!alertDiv) return;
    const colors = { success: '#10b981', error: '#ef4444', info: '#6366f1' };
    alertDiv.innerHTML = `
        <div class="d-flex align-items-center gap-2 p-3 rounded-3" 
             style="background: rgba(${type === 'success' ? '16,185,129' : type === 'error' ? '239,68,68' : '99,102,241'},0.1); 
                    border: 1px solid ${colors[type]}33; color: ${colors[type]}">
            <i class="fas fa-${type === 'success' ? 'check-circle' : type === 'error' ? 'exclamation-circle' : 'info-circle'}"></i>
            <span>${escHtml(message)}</span>
        </div>`;
}

function hideAlert() {
    const alertDiv = document.getElementById('alert-container');
    if (alertDiv) alertDiv.innerHTML = '';
}

function showToast(message, type = 'info') {
    const toast = document.createElement('div');
    const colors = { success: '#10b981', error: '#ef4444', info: '#6366f1' };
    toast.style.cssText = `
        position: fixed; bottom: 24px; right: 24px;
        background: rgba(3,7,18,0.95); backdrop-filter: blur(20px);
        border: 1px solid ${colors[type]}44;
        border-left: 3px solid ${colors[type]};
        color: #f1f5f9; padding: 14px 20px;
        border-radius: 10px; font-size: 0.88rem; font-weight: 500;
        z-index: 9999; max-width: 340px;
        animation: slideInRight 0.3s ease;
        box-shadow: 0 8px 30px rgba(0,0,0,0.4);
    `;
    toast.innerHTML = `<i class="fas fa-${type === 'success' ? 'check-circle' : 'info-circle'} me-2" style="color:${colors[type]}"></i>${escHtml(message)}`;
    document.body.appendChild(toast);

    setTimeout(() => {
        toast.style.animation = 'slideOutRight 0.3s ease';
        setTimeout(() => toast.remove(), 300);
    }, 3500);
}

function escHtml(str) {
    if (!str) return '';
    return String(str)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;');
}

// ======== ROLE-BASED ACCESS CONTROL ========
function applyRBAC() {
    const user = Auth.getUser();
    // Only apply RBAC on authenticated pages (skip landing, login, register)
    const publicPaths = ['/login', '/register', '/'];
    const path = window.location.pathname;
    if (publicPaths.includes(path) || !user) return;

    const isCandidate = user.role === 'CANDIDATE';
    const isRecruiter = user.role === 'RECRUITER';

    // ── PAGE-LEVEL GUARDS ──
    // Pages only recruiters can access
    const recruiterOnlyPages = ['/analytics', '/candidates', '/agents'];
    if (isCandidate && recruiterOnlyPages.some(p => path.startsWith(p))) {
        showToast('This section is for recruiters only.', 'error');
        setTimeout(() => window.location.href = '/dashboard', 1200);
        return;
    }

    // ── SIDEBAR: hide recruiter-only links for candidates ──
    if (isCandidate) {
        // Hide specific nav links
        ['/analytics', '/candidates', '/agents'].forEach(href => {
            document.querySelectorAll(`a.sidebar-link[href="${href}"]`).forEach(link => {
                link.style.display = 'none';
            });
        });

        // Hide "AI" nav section entirely if all its links are hidden
        document.querySelectorAll('.nav-section').forEach(section => {
            const title = section.querySelector('.nav-section-title');
            if (title && title.textContent.trim() === 'AI') {
                section.style.display = 'none';
            }
        });

        // Hide "Post New Job" button
        document.querySelectorAll('[data-bs-target="#postJobModal"]').forEach(el => el.style.display = 'none');

        // Hide "Schedule Interview" button (candidates don't schedule, they attend)
        document.querySelectorAll('[data-bs-target="#scheduleModal"]').forEach(el => el.style.display = 'none');

        // Change "Candidates" link text won't be shown anyway — but protect topbar title hint
        const pageTitle = document.querySelector('.page-title');
        if (pageTitle && path === '/interviews') {
            // Update subtitle to say "my interviews"
            const subtitle = pageTitle.nextElementSibling;
            if (subtitle) subtitle.textContent = 'Your scheduled interviews';
        }
    }

    // ── SIDEBAR: show role badge ──
    const sidebarLogo = document.querySelector('.sidebar-logo');
    if (sidebarLogo && !document.getElementById('role-badge')) {
        const badge = document.createElement('div');
        badge.id = 'role-badge';
        badge.style.cssText = `
            margin: 4px 16px 0;
            padding: 3px 10px;
            border-radius: 20px;
            font-size: 0.7rem;
            font-weight: 700;
            letter-spacing: 0.05em;
            text-align: center;
            background: ${isRecruiter
                ? 'linear-gradient(135deg, rgba(99,102,241,0.3), rgba(139,92,246,0.3))'
                : 'linear-gradient(135deg, rgba(16,185,129,0.3), rgba(6,182,212,0.3))'};
            color: ${isRecruiter ? '#a78bfa' : '#34d399'};
            border: 1px solid ${isRecruiter ? '#7c3aed44' : '#059e6f44'};
        `;
        badge.textContent = isRecruiter ? '🏢 RECRUITER' : '👤 CANDIDATE';
        sidebarLogo.appendChild(badge);
    }
}

function logout() {
    const token = Auth.getToken();
    if (token) {
        Api.post('/api/auth/logout', {}).catch(() => {});
    }
    Auth.clearSession();
    showToast('Logged out successfully', 'info');
    setTimeout(() => window.location.href = '/login', 500);
}

// ======== INIT ========
document.addEventListener('DOMContentLoaded', () => {
    const page = document.body.dataset.page;

    if (document.querySelector('.landing-page')) initLandingPage();
    if (document.querySelector('[data-dashboard]')) loadDashboard();
    if (document.querySelector('[data-jobs-page]')) loadJobs();

    // Apply Role-Based Access Control on every authenticated page
    applyRBAC();

    // Bind auth forms
    const loginForm = document.getElementById('loginForm');
    if (loginForm) loginForm.addEventListener('submit', handleLogin);

    const registerForm = document.getElementById('registerForm');
    if (registerForm) registerForm.addEventListener('submit', handleRegister);

    // Add slideIn animation
    const style = document.createElement('style');
    style.textContent = `
        @keyframes slideInRight { from { transform: translateX(100px); opacity: 0; } to { transform: translateX(0); opacity: 1; } }
        @keyframes slideOutRight { from { transform: translateX(0); opacity: 1; } to { transform: translateX(100px); opacity: 0; } }
    `;
    document.head.appendChild(style);
});



