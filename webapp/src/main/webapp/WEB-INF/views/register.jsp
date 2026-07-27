<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Account â€” AgentHire AI</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
    <style>
        *{margin:0;padding:0;box-sizing:border-box}
        :root{--p:#7c3aed;--bg:#050816;--border:rgba(255,255,255,0.1);--t1:#f1f5f9;--t2:#94a3b8;--t3:#475569}
        html,body{min-height:100%;font-family:'Inter',sans-serif;background:var(--bg);color:var(--t1)}
        canvas{position:fixed;inset:0;z-index:0}
        .page{position:relative;z-index:1;display:flex;align-items:flex-start;justify-content:center;padding:40px 20px;min-height:100vh}

        .auth-box{
            width:100%;max-width:520px;
            background:rgba(255,255,255,0.03);border:1px solid rgba(255,255,255,0.1);
            border-radius:24px;padding:44px 44px;
            backdrop-filter:blur(40px);
            box-shadow:0 32px 80px rgba(0,0,0,0.5),inset 0 1px 0 rgba(255,255,255,0.1);
        }
        .brand{display:flex;align-items:center;gap:12px;margin-bottom:28px;text-decoration:none;color:inherit}
        .brand-icon{width:44px;height:44px;border-radius:14px;background:linear-gradient(135deg,#7c3aed,#4f46e5,#06b6d4);display:flex;align-items:center;justify-content:center;font-size:18px;box-shadow:0 6px 24px rgba(124,58,237,0.5)}
        .brand-name{font-size:1.3rem;font-weight:800;letter-spacing:-0.02em}
        .brand-name span{background:linear-gradient(135deg,#a78bfa,#06b6d4);-webkit-background-clip:text;-webkit-text-fill-color:transparent}
        .auth-tag{display:inline-flex;align-items:center;gap:6px;font-size:.75rem;font-weight:600;color:#a78bfa;background:rgba(124,58,237,.12);border:1px solid rgba(124,58,237,.3);border-radius:50px;padding:4px 14px;margin-bottom:16px;letter-spacing:.04em;text-transform:uppercase}
        .auth-title{font-size:1.75rem;font-weight:800;letter-spacing:-0.03em;margin-bottom:6px}
        .auth-sub{font-size:.88rem;color:var(--t2);margin-bottom:28px}

        .row2{display:grid;grid-template-columns:1fr 1fr;gap:16px}
        .field{margin-bottom:18px}
        .field label{display:block;font-size:.75rem;font-weight:600;color:var(--t2);margin-bottom:7px;letter-spacing:.03em;text-transform:uppercase}
        .inp-wrap{position:relative}
        .inp-icon{position:absolute;left:14px;top:50%;transform:translateY(-50%);color:var(--t3);font-size:.85rem}
        .inp{width:100%;padding:13px 14px 13px 40px;background:rgba(255,255,255,0.06);border:1px solid rgba(255,255,255,0.12);border-radius:12px;color:var(--t1);font-size:.9rem;font-family:'Inter',sans-serif;transition:all .3s;outline:none}
        .inp:focus{border-color:rgba(124,58,237,.6);background:rgba(124,58,237,.08);box-shadow:0 0 0 4px rgba(124,58,237,.1)}
        .inp::placeholder{color:var(--t3)}
        .inp-eye{position:absolute;right:12px;top:50%;transform:translateY(-50%);background:none;border:none;color:var(--t3);cursor:pointer;font-size:.85rem;transition:color .2s}
        .inp-eye:hover{color:var(--t1)}

        /* role selector */
        .role-grid{display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-bottom:24px}
        .role-card{
            position:relative;cursor:pointer;
        }
        .role-card input{position:absolute;opacity:0;width:0;height:0}
        .role-label{
            display:flex;flex-direction:column;align-items:center;gap:10px;padding:18px 12px;
            border:1px solid rgba(255,255,255,0.12);border-radius:14px;
            background:rgba(255,255,255,0.04);transition:all .3s;cursor:pointer;
        }
        .role-label:hover{background:rgba(124,58,237,.1);border-color:rgba(124,58,237,.4)}
        .role-card input:checked + .role-label{background:rgba(124,58,237,.15);border-color:rgba(124,58,237,.6);box-shadow:0 0 0 3px rgba(124,58,237,.15)}
        .role-icon{font-size:1.6rem}
        .role-name{font-size:.82rem;font-weight:700;color:var(--t1)}
        .role-desc{font-size:.72rem;color:var(--t2);text-align:center}

        .btn-register{
            width:100%;padding:15px;border:none;border-radius:12px;cursor:pointer;
            background:linear-gradient(135deg,#7c3aed,#4f46e5,#06b6d4);
            color:#fff;font-size:1rem;font-weight:700;font-family:'Inter',sans-serif;
            letter-spacing:.01em;transition:all .3s;
            box-shadow:0 8px 32px rgba(124,58,237,.4);margin-bottom:20px;position:relative;overflow:hidden;
        }
        .btn-register:hover{transform:translateY(-2px);box-shadow:0 12px 40px rgba(124,58,237,.6)}
        .btn-register:disabled{opacity:.6;cursor:not-allowed;transform:none}

        .alert{padding:12px 16px;border-radius:10px;font-size:.85rem;font-weight:500;margin-bottom:18px;display:flex;align-items:center;gap:10px}
        .alert-error{background:rgba(239,68,68,.1);border:1px solid rgba(239,68,68,.3);color:#fca5a5}
        .alert-success{background:rgba(16,185,129,.1);border:1px solid rgba(16,185,129,.3);color:#6ee7b7}
        .hidden{display:none}
        .auth-link{text-align:center;font-size:.85rem;color:var(--t2)}
        .auth-link a{color:#a78bfa;font-weight:600;text-decoration:none}
        .auth-link a:hover{color:#c4b5fd}

        @keyframes spin{to{transform:rotate(360deg)}}
        .spinner{width:16px;height:16px;border:2px solid rgba(255,255,255,.3);border-top-color:#fff;border-radius:50%;animation:spin .7s linear infinite;display:inline-block;vertical-align:middle;margin-right:8px}

        /* password strength */
        .strength-bar{height:4px;border-radius:2px;background:rgba(255,255,255,.1);margin-top:8px;overflow:hidden}
        .strength-fill{height:100%;border-radius:2px;transition:width .4s,background .4s;width:0%}
        .strength-text{font-size:.72rem;color:var(--t2);margin-top:4px;height:14px}
    </style>
</head>
<body>
<canvas id="c"></canvas>
<div class="page">
    <div class="auth-box">
        <a href="/" class="brand">
            <div class="brand-icon">ðŸ¤–</div>
            <div class="brand-name">Agent<span>Hire</span> AI</div>
        </a>
        <div class="auth-tag">âœ¦ New Account</div>
        <h2 class="auth-title">Create your account</h2>
        <p class="auth-sub">Join the AI-powered recruitment revolution</p>

        <div id="alertBox" class="alert hidden"></div>

        <form id="regForm" onsubmit="doRegister(event)" novalidate>
            <!-- Role selection -->
            <div class="field">
                <label>I am a...</label>
                <div class="role-grid">
                    <div class="role-card">
                        <input type="radio" name="role" id="rCandidate" value="CANDIDATE" checked>
                        <label class="role-label" for="rCandidate">
                            <span class="role-icon">ðŸŽ¯</span>
                            <span class="role-name">Candidate</span>
                            <span class="role-desc">Looking for a job</span>
                        </label>
                    </div>
                    <div class="role-card">
                        <input type="radio" name="role" id="rRecruiter" value="RECRUITER">
                        <label class="role-label" for="rRecruiter">
                            <span class="role-icon">ðŸ¢</span>
                            <span class="role-name">Recruiter</span>
                            <span class="role-desc">Hiring talent</span>
                        </label>
                    </div>
                </div>
            </div>

            <div class="row2">
                <div class="field">
                    <label>First Name</label>
                    <div class="inp-wrap">
                        <i class="fas fa-user inp-icon"></i>
                        <input type="text" class="inp" id="firstName" placeholder="John" required>
                    </div>
                </div>
                <div class="field">
                    <label>Last Name</label>
                    <div class="inp-wrap">
                        <i class="fas fa-user inp-icon"></i>
                        <input type="text" class="inp" id="lastName" placeholder="Doe" required>
                    </div>
                </div>
            </div>

            <div class="field">
                <label>Email Address</label>
                <div class="inp-wrap">
                    <i class="fas fa-envelope inp-icon"></i>
                    <input type="email" class="inp" id="email" placeholder="you@company.com" required>
                </div>
            </div>

            <div class="field">
                <label>Phone (optional)</label>
                <div class="inp-wrap">
                    <i class="fas fa-phone inp-icon"></i>
                    <input type="tel" class="inp" id="phone" placeholder="+1 234 567 8900">
                </div>
            </div>

            <div class="field">
                <label>Password</label>
                <div class="inp-wrap">
                    <i class="fas fa-lock inp-icon"></i>
                    <input type="password" class="inp" id="password" placeholder="Min. 8 characters" required oninput="checkStrength(this.value)" style="padding-right:40px">
                    <button type="button" class="inp-eye" onclick="togglePwd(this)"><i class="fas fa-eye"></i></button>
                </div>
                <div class="strength-bar"><div class="strength-fill" id="sFill"></div></div>
                <div class="strength-text" id="sText"></div>
            </div>

            <button type="submit" class="btn-register" id="regBtn">
                <i class="fas fa-user-plus"></i>&nbsp; Create Free Account
            </button>
        </form>
        <div class="auth-link">Already have an account? <a href="/login">Sign in</a></div>
    </div>
</div>

<script>
const API = '';
const Auth={set:d=>{localStorage.setItem('accessToken',d.accessToken);localStorage.setItem('refreshToken',d.refreshToken);localStorage.setItem('user',JSON.stringify(d.user))}};

function showAlert(msg,type){
    const b=document.getElementById('alertBox');
    b.className='alert alert-'+(type||'error');
    b.innerHTML='<i class="fas fa-'+(type==='success'?'check-circle':'exclamation-circle')+'"></i><span>'+msg+'</span>';
    b.classList.remove('hidden');
}
function togglePwd(btn){const i=btn.closest('.inp-wrap').querySelector('input');const ic=btn.querySelector('i');i.type=i.type==='password'?'text':'password';ic.className=i.type==='password'?'fas fa-eye':'fas fa-eye-slash'}

function checkStrength(v){
    const f=document.getElementById('sFill');const t=document.getElementById('sText');
    let s=0,msg='',col='';
    if(v.length>=8)s++;if(/[A-Z]/.test(v))s++;if(/[0-9]/.test(v))s++;if(/[^A-Za-z0-9]/.test(v))s++;
    const levels=[{w:'25%',c:'#ef4444',m:'Weak'},{w:'50%',c:'#f59e0b',m:'Fair'},{w:'75%',c:'#06b6d4',m:'Good'},{w:'100%',c:'#10b981',m:'Strong'}];
    const l=levels[Math.max(0,s-1)]||levels[0];
    f.style.width=v?l.w:'0%';f.style.background=l.c;t.textContent=v?l.m:'';t.style.color=l.c;
}

async function doRegister(e){
    e.preventDefault();
    const btn=document.getElementById('regBtn');
    const role=document.querySelector('input[name="role"]:checked').value;
    const payload={
        firstName:document.getElementById('firstName').value,
        lastName:document.getElementById('lastName').value,
        email:document.getElementById('email').value,
        phone:document.getElementById('phone').value||null,
        password:document.getElementById('password').value,
        role:role
    };
    btn.disabled=true;btn.innerHTML='<span class="spinner"></span>Creating account...';
    try{
        const res=await fetch(API+'/api/auth/register',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(payload)});
        const json=await res.json();
        if(!res.ok)throw new Error(json.message||'Registration failed');
        Auth.set(json.data||json);
        showAlert('Account created! Redirecting to dashboard...','success');
        setTimeout(()=>window.location.href='/dashboard',1200);
    }catch(err){
        showAlert(err.message||'Registration failed. Please try again.','error');
    }finally{
        btn.disabled=false;btn.innerHTML='<i class="fas fa-user-plus"></i>&nbsp; Create Free Account';
    }
}

/* Aurora canvas */
const canvas=document.getElementById('c'),ctx=canvas.getContext('2d');
let W,H,t=0;
function resize(){W=canvas.width=window.innerWidth;H=canvas.height=window.innerHeight}
resize();window.addEventListener('resize',resize);
function draw(){
    ctx.clearRect(0,0,W,H);
    [[124,58,237],[6,182,212],[16,185,129],[139,92,246]].forEach((c,i)=>{
        const x=W*(0.15+i*0.25)+Math.sin(t*0.35+i*2)*120;
        const y=H*(0.25+i%2*0.5)+Math.cos(t*0.28+i)*100;
        const g=ctx.createRadialGradient(x,y,0,x,y,Math.max(W,H)*0.3);
        g.addColorStop(0,'rgba(' + c + ',0.15)');g.addColorStop(1,'rgba(0,0,0,0)');
        ctx.fillStyle=g;ctx.fillRect(0,0,W,H);
    });
    t+=0.004;requestAnimationFrame(draw);
}
draw();
</script>
</body>
</html>

