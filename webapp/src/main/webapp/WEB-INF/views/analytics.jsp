<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Analytics — AgentHire AI</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/style.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
</head>
<body>
<div class="bg-animated"><div class="orb orb-1" style="opacity:0.05"></div><div class="orb orb-2" style="opacity:0.04"></div></div>
<aside class="sidebar">
    <div class="sidebar-logo">
        <a href="/" class="brand-logo text-decoration-none">
            <div class="brand-icon small"><i class="fas fa-robot"></i></div>
            <span class="brand-text ms-2">Agent<span class="brand-accent">Hire</span> AI</span>
        </a>
    </div>
    <nav class="sidebar-nav">
        <div id="sidebar-user-section"></div>
        <div class="nav-section"><div class="nav-section-title">Overview</div>
            <a href="/dashboard" class="sidebar-link"><i class="fas fa-th-large"></i><span>Dashboard</span></a>
            <a href="/analytics" class="sidebar-link active"><i class="fas fa-chart-line"></i><span>Analytics</span></a>
        </div>
        <div class="nav-section"><div class="nav-section-title">Recruitment</div>
            <a href="/jobs" class="sidebar-link"><i class="fas fa-briefcase"></i><span>Jobs</span></a>
            <a href="/candidates" class="sidebar-link"><i class="fas fa-users"></i><span>Candidates</span></a>
            <a href="/interviews" class="sidebar-link"><i class="fas fa-calendar-check"></i><span>Interviews</span></a>
        </div>
        <div class="nav-section"><div class="nav-section-title">AI</div>
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
            <h1 class="page-title">Analytics &amp; Insights</h1>
            <p style="color:var(--text-secondary);font-size:0.85rem;margin:0">Recruitment performance metrics — live data</p>
        </div>
        <div class="topbar-actions">
            <select class="form-control form-control-dark" style="width:auto" id="period-select" onchange="loadAnalytics()">
                <option value="7">Last 7 Days</option>
                <option value="30" selected>Last 30 Days</option>
                <option value="90">Last 90 Days</option>
            </select>
        </div>
    </div>

    <!-- KPI Strip -->
    <div class="stats-grid mb-4">
        <div class="stat-card">
            <div class="stat-card-icon" style="background:rgba(99,102,241,0.15)"><i class="fas fa-paper-plane" style="color:#6366f1"></i></div>
            <div class="stat-card-value text-gradient" id="kpi-apps">—</div>
            <div class="stat-card-label">Total Applications</div>
            <div class="stat-card-trend trend-up" id="kpi-apps-sub" style="color:var(--text-muted);font-size:0.75rem">Loading...</div>
        </div>
        <div class="stat-card">
            <div class="stat-card-icon" style="background:rgba(16,185,129,0.15)"><i class="fas fa-handshake" style="color:#10b981"></i></div>
            <div class="stat-card-value" style="color:#10b981" id="kpi-hired">—</div>
            <div class="stat-card-label">Candidates Hired</div>
            <div class="stat-card-trend trend-up" id="kpi-hired-sub" style="color:var(--text-muted);font-size:0.75rem">Loading...</div>
        </div>
        <div class="stat-card">
            <div class="stat-card-icon" style="background:rgba(6,182,212,0.15)"><i class="fas fa-calendar-check" style="color:#06b6d4"></i></div>
            <div class="stat-card-value" style="color:#06b6d4" id="kpi-interviews">—</div>
            <div class="stat-card-label">Interviews Scheduled</div>
            <div class="stat-card-trend" id="kpi-int-sub" style="color:var(--text-muted);font-size:0.75rem">Loading...</div>
        </div>
        <div class="stat-card">
            <div class="stat-card-icon" style="background:rgba(139,92,246,0.15)"><i class="fas fa-briefcase" style="color:#8b5cf6"></i></div>
            <div class="stat-card-value" style="color:#8b5cf6" id="kpi-jobs">—</div>
            <div class="stat-card-label">Active Jobs</div>
            <div class="stat-card-trend" id="kpi-jobs-sub" style="color:var(--text-muted);font-size:0.75rem">Loading...</div>
        </div>
    </div>

    <!-- Charts Row 1 -->
    <div class="row g-4 mb-4">
        <div class="col-lg-8">
            <div class="glass-card p-4">
                <div class="d-flex align-items-center justify-content-between mb-4">
                    <h5 class="fw-700 m-0">Applications Over Time</h5>
                    <span class="badge-status bs-info" id="timeline-label">Last 30 Days</span>
                </div>
                <div style="position:relative;height:260px">
                    <canvas id="timelineChart"></canvas>
                </div>
                <div id="timeline-empty" class="text-center py-3" style="display:none;color:var(--text-muted)">
                    <i class="fas fa-chart-area fa-2x mb-2 d-block"></i>No applications in this period yet.
                </div>
            </div>
        </div>
        <div class="col-lg-4">
            <div class="glass-card p-4">
                <h5 class="fw-700 mb-4">Funnel Conversion</h5>
                <div style="position:relative;height:220px">
                    <canvas id="funnelChart"></canvas>
                </div>
                <div id="funnel-legend" class="mt-3" style="font-size:0.78rem"></div>
            </div>
        </div>
    </div>

    <!-- Charts Row 2 -->
    <div class="row g-4 mb-4">
        <div class="col-lg-4">
            <div class="glass-card p-4">
                <h5 class="fw-700 mb-4">Applications by Job Type</h5>
                <div style="position:relative;height:220px">
                    <canvas id="jobTypeChart"></canvas>
                </div>
            </div>
        </div>
        <div class="col-lg-4">
            <div class="glass-card p-4">
                <h5 class="fw-700 mb-4">Application Status Breakdown</h5>
                <div id="status-bars" style="padding-top:8px"></div>
            </div>
        </div>
        <div class="col-lg-4">
            <div class="glass-card p-4">
                <h5 class="fw-700 mb-3">Hiring Funnel Rates</h5>
                <div id="funnel-rates"></div>
            </div>
        </div>
    </div>

    <!-- Summary Table -->
    <div class="glass-card p-4">
        <h5 class="fw-700 mb-4">Recruitment Summary</h5>
        <div class="table-responsive">
            <table class="table table-dark table-hover mb-0" style="font-size:0.85rem">
                <thead><tr style="color:var(--text-muted);border-bottom:1px solid var(--border-color)">
                    <th>Metric</th><th>Count</th><th>Rate</th><th>Trend</th>
                </tr></thead>
                <tbody id="summary-table">
                    <tr><td colspan="4" class="text-center py-3" style="color:var(--text-muted)">
                        <div class="ai-loader justify-content-center"><div class="ai-spinner"></div>Loading real data...</div>
                    </td></tr>
                </tbody>
            </table>
        </div>
    </div>
</main>

<style>
.fw-700{font-weight:700}
.bs-info{background:rgba(6,182,212,0.15);color:#06b6d4;padding:4px 12px;border-radius:20px;font-size:0.75rem;font-weight:600}
</style>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/static/js/app.js"></script>
<script>
// Chart registry — destroy before re-creating to avoid canvas reuse errors
var charts = {};
function destroyChart(id) { if (charts[id]) { charts[id].destroy(); delete charts[id]; } }

const CHART_OPTS = {
    color: '#94a3b8',
    plugins: {
        legend: { labels: { color: '#94a3b8', font: { family: 'Inter', size: 12 }, usePointStyle: true, pointStyleWidth: 8 } },
        tooltip: { backgroundColor: 'rgba(3,7,18,0.95)', borderColor: 'rgba(99,102,241,0.3)', borderWidth: 1,
                   titleColor: '#f1f5f9', bodyColor: '#94a3b8', padding: 12, cornerRadius: 10,
                   titleFont: { size: 13, weight: '700', family: 'Inter' } }
    },
    scales: {
        x: { grid: { color: 'rgba(255,255,255,0.05)' }, ticks: { color: '#94a3b8', font: { family: 'Inter' } }, border: { display: false } },
        y: { grid: { color: 'rgba(255,255,255,0.05)' }, ticks: { color: '#94a3b8', font: { family: 'Inter' }, padding: 8 }, border: { display: false }, beginAtZero: true }
    }
};

document.addEventListener('DOMContentLoaded', () => { loadAnalytics(); });

async function loadAnalytics() {
    var days = parseInt(document.getElementById('period-select').value);
    document.getElementById('timeline-label').textContent = 'Last ' + days + ' Days';

    var data = null;
    try {
        data = await Api.get('/api/applications/analytics?days=' + days);
    } catch(e) {
        showToast('Could not load analytics: ' + e.message, 'error');
        return;
    }

    var kpis   = data.kpis   || {};
    var funnel = data.funnel  || {};
    var jTypes = data.jobTypes || {};
    var tl     = data.timeline || [];

    // ── KPIs ────────────────────────────────────────────────────────────────
    animateCounter(document.getElementById('kpi-apps'),        0, kpis.totalApplications || 0, 1000);
    animateCounter(document.getElementById('kpi-hired'),       0, kpis.hired             || 0, 1100);
    animateCounter(document.getElementById('kpi-interviews'),  0, kpis.interview         || 0, 1200);
    animateCounter(document.getElementById('kpi-jobs'),        0, kpis.activeJobs        || 0, 1300);

    var total = kpis.totalApplications || 1;
    document.getElementById('kpi-apps-sub').innerHTML  = '<i class="fas fa-users me-1"></i>' + (kpis.shortlisted||0) + ' shortlisted';
    document.getElementById('kpi-hired-sub').innerHTML = '<i class="fas fa-percent me-1"></i>' + (total > 0 ? ((kpis.hired/total)*100).toFixed(1) : 0) + '% hire rate';
    document.getElementById('kpi-int-sub').innerHTML   = '<i class="fas fa-briefcase me-1"></i>' + (kpis.totalJobs||0) + ' total jobs';
    document.getElementById('kpi-jobs-sub').innerHTML  = '<i class="fas fa-check-circle me-1"></i>' + (kpis.totalJobs||0) + ' jobs posted';

    // ── Timeline Chart ───────────────────────────────────────────────────────
    destroyChart('timeline');
    var tlLabels = tl.map(r => r.date ? r.date.substring(5) : '');  // MM-DD
    var tlData   = tl.map(r => r.count || 0);

    if (tl.length === 0) {
        document.getElementById('timelineChart').style.display = 'none';
        document.getElementById('timeline-empty').style.display = 'block';
    } else {
        document.getElementById('timelineChart').style.display = '';
        document.getElementById('timeline-empty').style.display = 'none';
        var ctx = document.getElementById('timelineChart').getContext('2d');
        var grad = ctx.createLinearGradient(0, 0, 0, 260);
        grad.addColorStop(0, 'rgba(99,102,241,0.4)');
        grad.addColorStop(1, 'rgba(99,102,241,0.02)');
        charts['timeline'] = new Chart(ctx, { type: 'line',
            data: { labels: tlLabels, datasets: [{
                label: 'Applications', data: tlData,
                borderColor: '#6366f1', backgroundColor: grad,
                fill: true, tension: 0.4, borderWidth: 2.5,
                pointRadius: tlData.length < 15 ? 4 : 0,
                pointHoverRadius: 6, pointBackgroundColor: '#6366f1'
            }]},
            options: { ...CHART_OPTS, responsive: true, maintainAspectRatio: false,
                animation: { duration: 1000, easing: 'easeOutQuart' },
                interaction: { mode: 'index', intersect: false },
                plugins: { ...CHART_OPTS.plugins,
                    tooltip: { ...CHART_OPTS.plugins.tooltip,
                        callbacks: { label: ctx => '  ' + ctx.raw + ' application' + (ctx.raw !== 1 ? 's' : '') }
                    }
                }
            }
        });
    }

    // ── Funnel Doughnut ──────────────────────────────────────────────────────
    destroyChart('funnel');
    var fLabels = Object.keys(funnel);
    var fData   = Object.values(funnel);
    var fColors = ['rgba(99,102,241,0.85)','rgba(6,182,212,0.85)','rgba(245,158,11,0.85)','rgba(139,92,246,0.85)','rgba(236,72,153,0.85)','rgba(16,185,129,0.85)'];
    if (fData.some(v => v > 0)) {
        var ctx2 = document.getElementById('funnelChart').getContext('2d');
        charts['funnel'] = new Chart(ctx2, { type: 'doughnut',
            data: { labels: fLabels, datasets: [{ data: fData, backgroundColor: fColors, borderWidth: 0, hoverOffset: 6 }] },
            options: { responsive: true, maintainAspectRatio: false, cutout: '62%',
                plugins: { legend: { display: false },
                    tooltip: { backgroundColor: 'rgba(3,7,18,0.95)', borderColor: 'rgba(99,102,241,0.3)', borderWidth: 1,
                               titleColor: '#f1f5f9', bodyColor: '#94a3b8', padding: 12, cornerRadius: 10 }
                }
            }
        });
    }
    // Funnel legend
    document.getElementById('funnel-legend').innerHTML = fLabels.map((l, i) =>
        '<div class="d-flex justify-content-between mb-1">' +
        '<span style="color:var(--text-secondary)"><span style="display:inline-block;width:10px;height:10px;border-radius:2px;background:' + fColors[i] + ';margin-right:6px"></span>' + l + '</span>' +
        '<strong style="color:#f1f5f9">' + (fData[i] || 0) + '</strong></div>'
    ).join('');

    // ── Job Type Bar Chart ────────────────────────────────────────────────────
    destroyChart('jobType');
    var jtLabels = Object.keys(jTypes).map(k => k.replace(/_/g,' '));
    var jtData   = Object.values(jTypes);
    var jtColors = ['rgba(99,102,241,0.8)','rgba(139,92,246,0.8)','rgba(6,182,212,0.8)','rgba(16,185,129,0.8)'];
    var ctx3 = document.getElementById('jobTypeChart').getContext('2d');
    charts['jobType'] = new Chart(ctx3, { type: 'bar',
        data: { labels: jtLabels, datasets: [{ data: jtData, backgroundColor: jtColors, borderRadius: 8, borderSkipped: false }] },
        options: { ...CHART_OPTS, responsive: true, maintainAspectRatio: false,
            plugins: { ...CHART_OPTS.plugins, legend: { display: false } }
        }
    });

    // ── Status Breakdown Bars ─────────────────────────────────────────────────
    var statusColors = { Applied:'#6366f1', Screening:'#06b6d4', Shortlisted:'#10b981', Interview:'#f59e0b', Offered:'#ec4899', Hired:'#10b981', Rejected:'#ef4444' };
    document.getElementById('status-bars').innerHTML = Object.entries(funnel).map(([k, v]) => {
        var pct = total > 0 ? Math.max(2, Math.round((v / total) * 100)) : 0;
        var col = statusColors[k] || '#6366f1';
        return '<div class="mb-3">' +
            '<div class="d-flex justify-content-between mb-1" style="font-size:0.82rem">' +
            '<span style="color:var(--text-secondary)">' + k + '</span>' +
            '<span style="color:' + col + ';font-weight:600">' + v + ' <span style="color:var(--text-muted);font-weight:400">(' + pct + '%)</span></span>' +
            '</div>' +
            '<div style="height:7px;background:var(--border-color);border-radius:4px">' +
            '<div style="width:' + pct + '%;height:100%;background:' + col + ';border-radius:4px;transition:width 1.2s ease"></div>' +
            '</div></div>';
    }).join('');

    // ── Hiring Funnel Rates ────────────────────────────────────────────────────
    var applied     = funnel['Applied']     || 0;
    var shortlisted = funnel['Shortlisted'] || 0;
    var interviewed = funnel['Interview']   || 0;
    var hired2      = funnel['Hired']       || 0;
    var rates = [
        { label: 'Application → Shortlist', val: applied > 0 ? ((shortlisted/applied)*100).toFixed(1) : 0, icon: 'fa-filter', col: '#06b6d4' },
        { label: 'Shortlist → Interview',   val: shortlisted > 0 ? ((interviewed/shortlisted)*100).toFixed(1) : 0, icon: 'fa-calendar-check', col: '#f59e0b' },
        { label: 'Interview → Hire',        val: interviewed > 0 ? ((hired2/interviewed)*100).toFixed(1) : 0, icon: 'fa-handshake', col: '#10b981' },
        { label: 'Overall Hire Rate',       val: total > 1 ? ((hired2/total)*100).toFixed(1) : 0, icon: 'fa-award', col: '#8b5cf6' }
    ];
    document.getElementById('funnel-rates').innerHTML = rates.map(r =>
        '<div class="d-flex align-items-center gap-3 mb-3 p-2" style="background:rgba(255,255,255,0.03);border-radius:10px">' +
        '<div style="width:38px;height:38px;background:' + r.col + '22;border-radius:10px;display:flex;align-items:center;justify-content:center;flex-shrink:0">' +
        '<i class="fas ' + r.icon + '" style="color:' + r.col + ';font-size:0.9rem"></i></div>' +
        '<div style="flex:1"><div style="font-size:0.78rem;color:var(--text-muted)">' + r.label + '</div>' +
        '<div style="font-size:1.1rem;font-weight:700;color:' + r.col + '">' + r.val + '%</div></div></div>'
    ).join('');

    // ── Summary Table ─────────────────────────────────────────────────────────
    var rows = [
        ['Total Applications', kpis.totalApplications || 0, '100%', ''],
        ['Shortlisted',        kpis.shortlisted       || 0, total > 1 ? (((kpis.shortlisted||0)/total)*100).toFixed(1)+'%' : '—', 'badge-hired'],
        ['In Interview',       kpis.interview         || 0, total > 1 ? (((kpis.interview||0)/total)*100).toFixed(1)+'%'   : '—', 'badge-active'],
        ['Hired',              kpis.hired             || 0, total > 1 ? (((kpis.hired||0)/total)*100).toFixed(1)+'%'       : '—', 'badge-active'],
        ['Rejected',           funnel['Rejected']     || 0, total > 1 ? (((funnel['Rejected']||0)/total)*100).toFixed(1)+'%': '—', 'badge-closed'],
        ['Active Jobs',        kpis.activeJobs        || 0, '—', ''],
        ['Total Jobs Posted',  kpis.totalJobs         || 0, '—', '']
    ];
    document.getElementById('summary-table').innerHTML = rows.map(r =>
        '<tr>' +
        '<td style="color:var(--text-secondary)">' + r[0] + '</td>' +
        '<td style="font-weight:700;color:#f1f5f9">' + r[1] + '</td>' +
        '<td>' + (r[3] ? '<span class="badge-status ' + r[3] + '">' + r[2] + '</span>' : '<span style="color:var(--text-muted)">' + r[2] + '</span>') + '</td>' +
        '<td><span style="color:var(--text-muted);font-size:0.75rem">Live</span></td>' +
        '</tr>'
    ).join('');
}
</script>
</body></html>
