<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign In â€” AgentHire AI</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
    <style>
        *{margin:0;padding:0;box-sizing:border-box}
        :root{
            --p:#7c3aed;--p2:#4f46e5;--p3:#06b6d4;
            --bg:#050816;--card:rgba(255,255,255,0.04);
            --border:rgba(255,255,255,0.1);
            --t1:#f1f5f9;--t2:#94a3b8;--t3:#475569;
        }
        html,body{height:100%;font-family:'Inter',sans-serif;background:var(--bg);color:var(--t1);overflow:hidden}
        
        /* â”€â”€ CANVAS AURORA â”€â”€ */
        canvas{position:fixed;inset:0;z-index:0}
        
        /* â”€â”€ GRID â”€â”€ */
        .page{position:relative;z-index:1;display:grid;grid-template-columns:1fr 1fr;min-height:100vh}
        
        /* â”€â”€ LEFT PANEL â”€â”€ */
        .panel-left{
            display:flex;flex-direction:column;justify-content:center;padding:60px;
            background:linear-gradient(135deg,rgba(124,58,237,0.12),rgba(6,182,212,0.06));
            border-right:1px solid var(--border);position:relative;overflow:hidden;
        }
        .panel-left::before{
            content:'';position:absolute;width:500px;height:500px;
            background:radial-gradient(circle,rgba(124,58,237,0.25),transparent 70%);
            top:-100px;left:-100px;border-radius:50%;
        }
        .brand{display:flex;align-items:center;gap:14px;margin-bottom:56px}
        .brand-logo-icon{
            width:52px;height:52px;border-radius:16px;
            background:linear-gradient(135deg,#7c3aed,#4f46e5,#06b6d4);
            display:flex;align-items:center;justify-content:center;font-size:22px;
            box-shadow:0 8px 32px rgba(124,58,237,0.5);
        }
        .brand-name{font-size:1.5rem;font-weight:800;letter-spacing:-0.02em}
        .brand-name span{background:linear-gradient(135deg,#a78bfa,#06b6d4);-webkit-background-clip:text;-webkit-text-fill-color:transparent}
        .hero-headline{font-size:clamp(2rem,3.5vw,3rem);font-weight:900;line-height:1.1;letter-spacing:-0.04em;margin-bottom:20px}
        .hero-headline .hl{background:linear-gradient(135deg,#7c3aed,#06b6d4);-webkit-background-clip:text;-webkit-text-fill-color:transparent}
        .hero-sub{font-size:1rem;color:var(--t2);line-height:1.7;max-width:400px;margin-bottom:48px}
        
        /* Feature pills */
        .features{display:flex;flex-direction:column;gap:16px}
        .feat{display:flex;align-items:center;gap:16px;padding:16px 20px;border-radius:14px;background:rgba(255,255,255,0.04);border:1px solid rgba(255,255,255,0.08);transition:all .3s}
        .feat:hover{background:rgba(124,58,237,0.12);border-color:rgba(124,58,237,0.3);transform:translateX(6px)}
        .feat-icon{width:40px;height:40px;border-radius:12px;display:flex;align-items:center;justify-content:center;font-size:16px;flex-shrink:0}
        .fi-purple{background:linear-gradient(135deg,rgba(124,58,237,0.3),rgba(79,70,229,0.3));border:1px solid rgba(124,58,237,0.4)}
        .fi-cyan{background:linear-gradient(135deg,rgba(6,182,212,0.3),rgba(79,70,229,0.3));border:1px solid rgba(6,182,212,0.4)}
        .fi-green{background:linear-gradient(135deg,rgba(16,185,129,0.3),rgba(6,182,212,0.3));border:1px solid rgba(16,185,129,0.4)}
        .feat-label{font-size:.9rem;font-weight:600;color:var(--t1)}
        .feat-desc{font-size:.78rem;color:var(--t2);margin-top:2px}
        
        /* â”€â”€ RIGHT PANEL â”€â”€ */
        .panel-right{display:flex;align-items:center;justify-content:center;padding:60px 40px;position:relative}
        
        /* form card */
        .auth-box{
            width:100%;max-width:420px;
            background:rgba(255,255,255,0.03);
            border:1px solid rgba(255,255,255,0.1);
            border-radius:24px;padding:44px 40px;
            backdrop-filter:blur(40px);
            box-shadow:0 32px 80px rgba(0,0,0,0.5),inset 0 1px 0 rgba(255,255,255,0.1);
        }
        .auth-tag{
            display:inline-flex;align-items:center;gap:6px;font-size:.75rem;font-weight:600;
            color:#a78bfa;background:rgba(124,58,237,0.12);border:1px solid rgba(124,58,237,0.3);
            border-radius:50px;padding:4px 14px;margin-bottom:20px;letter-spacing:.04em;text-transform:uppercase;
        }
        .auth-title{font-size:1.9rem;font-weight:800;letter-spacing:-0.03em;margin-bottom:6px}
        .auth-sub{font-size:.88rem;color:var(--t2);margin-bottom:32px}
        
        /* inputs */
        .field{margin-bottom:20px}
        .field label{display:block;font-size:.8rem;font-weight:600;color:var(--t2);margin-bottom:8px;letter-spacing:.02em;text-transform:uppercase}
        .inp-wrap{position:relative}
        .inp-icon{position:absolute;left:16px;top:50%;transform:translateY(-50%);color:var(--t3);font-size:.88rem;z-index:1}
        .inp{
            width:100%;padding:14px 16px 14px 44px;
            background:rgba(255,255,255,0.06);border:1px solid rgba(255,255,255,0.12);
            border-radius:12px;color:var(--t1);font-size:.95rem;font-family:'Inter',sans-serif;
            transition:all .3s;outline:none;
        }
        .inp:focus{border-color:rgba(124,58,237,0.6);background:rgba(124,58,237,0.08);box-shadow:0 0 0 4px rgba(124,58,237,0.1)}
        .inp::placeholder{color:var(--t3)}
        .inp-eye{position:absolute;right:14px;top:50%;transform:translateY(-50%);background:none;border:none;color:var(--t3);cursor:pointer;padding:4px;font-size:.88rem;transition:color .2s}
        .inp-eye:hover{color:var(--t1)}
        
        /* button */
        .btn-signin{
            width:100%;padding:15px;border:none;border-radius:12px;cursor:pointer;
            background:linear-gradient(135deg,#7c3aed,#4f46e5,#06b6d4);
            color:#fff;font-size:1rem;font-weight:700;font-family:'Inter',sans-serif;
            letter-spacing:.01em;transition:all .3s;position:relative;overflow:hidden;
            box-shadow:0 8px 32px rgba(124,58,237,0.4);margin-bottom:20px;
        }
        .btn-signin::before{content:'';position:absolute;inset:0;background:linear-gradient(135deg,rgba(255,255,255,0.1),transparent);opacity:0;transition:opacity .3s}
        .btn-signin:hover{transform:translateY(-2px);box-shadow:0 12px 40px rgba(124,58,237,0.6)}
        .btn-signin:hover::before{opacity:1}
        .btn-signin:active{transform:translateY(0)}
        .btn-signin:disabled{opacity:.6;cursor:not-allowed;transform:none}
        
        /* divider */
        .div-or{display:flex;align-items:center;gap:12px;margin-bottom:20px}
        .div-or span{color:var(--t3);font-size:.78rem;white-space:nowrap}
        .div-or::before,.div-or::after{content:'';flex:1;height:1px;background:var(--border)}
        
        /* google */
        .btn-google{
            width:100%;padding:13px;border:1px solid rgba(255,255,255,0.15);border-radius:12px;
            background:rgba(255,255,255,0.06);color:var(--t1);font-size:.9rem;font-weight:600;
            font-family:'Inter',sans-serif;cursor:pointer;display:flex;align-items:center;justify-content:center;gap:10px;
            transition:all .3s;margin-bottom:28px;
        }
        .btn-google:hover{background:rgba(255,255,255,0.12);border-color:rgba(255,255,255,0.3);transform:translateY(-2px)}
        
        /* alert */
        .alert{padding:12px 16px;border-radius:10px;font-size:.85rem;font-weight:500;margin-bottom:20px;display:flex;align-items:center;gap:10px}
        .alert-error{background:rgba(239,68,68,.1);border:1px solid rgba(239,68,68,.3);color:#fca5a5}
        .alert-success{background:rgba(16,185,129,.1);border:1px solid rgba(16,185,129,.3);color:#6ee7b7}
        .hidden{display:none}
        
        /* link */
        .auth-link{text-align:center;font-size:.85rem;color:var(--t2)}
        .auth-link a{color:#a78bfa;font-weight:600;text-decoration:none;transition:color .2s}
        .auth-link a:hover{color:#c4b5fd}
        
        /* spinner */
        @keyframes spin{to{transform:rotate(360deg)}}
        .spinner{width:18px;height:18px;border:2px solid rgba(255,255,255,0.3);border-top-color:#fff;border-radius:50%;animation:spin .7s linear infinite;display:inline-block;vertical-align:middle;margin-right:8px}
        
        /* responsive */
        @media(max-width:900px){
            .page{grid-template-columns:1fr}
            .panel-left{display:none}
            .panel-right{padding:30px 20px}
            html,body{overflow:auto}
        }
    </style>
</head>
<body>
<canvas id="c"></canvas>
<div class="page">
    <!-- LEFT: branding -->
    <div class="panel-left">
        <div class="brand">
            <div class="brand-logo-icon">ðŸ¤–</div>
            <div class="brand-name">Agent<span>Hire</span> AI</div>
        </div>
        <h1 class="hero-headline">Hire Smarter<br>with <span class="hl">AI Agents</span></h1>
        <p class="hero-sub">The most advanced AI-powered recruitment platform. Automate screening, conduct live coding interviews, and find top talent 10x faster.</p>
        <div class="features">
            <div class="feat">
                <div class="feat-icon fi-purple"><i class="fas fa-robot" style="color:#a78bfa"></i></div>
                <div><div class="feat-label">AI Resume Screening</div><div class="feat-desc">Intelligent agents rank candidates automatically</div></div>
            </div>
            <div class="feat">
                <div class="feat-icon fi-cyan"><i class="fas fa-code" style="color:#67e8f9"></i></div>
                <div><div class="feat-label">Live Coding Interviews</div><div class="feat-desc">Real-time code evaluation with AI analysis</div></div>
            </div>
            <div class="feat">
                <div class="feat-icon fi-green"><i class="fas fa-chart-line" style="color:#6ee7b7"></i></div>
                <div><div class="feat-label">Smart Analytics</div><div class="feat-desc">Deep insights into your hiring pipeline</div></div>
            </div>
        </div>
    </div>

    <!-- RIGHT: form -->
    <div class="panel-right">
        <div class="auth-box">
            <div class="auth-tag">âœ¦ Secure Login</div>
            <h2 class="auth-title">Welcome back</h2>
            <p class="auth-sub">Sign in to your AgentHire dashboard</p>

            <div id="alertBox" class="alert hidden"></div>

            <form id="loginForm" onsubmit="doLogin(event)">
                <div class="field">
                    <label>Email Address</label>
                    <div class="inp-wrap">
                        <i class="fas fa-envelope inp-icon"></i>
                        <input type="email" class="inp" id="email" placeholder="you@company.com" required autocomplete="email">
                    </div>
                </div>
                <div class="field">
                    <label>Password</label>
                    <div class="inp-wrap">
                        <i class="fas fa-lock inp-icon"></i>
                        <input type="password" class="inp" id="password" placeholder="Your password" required autocomplete="current-password" style="padding-right:44px">
                        <button type="button" class="inp-eye" onclick="togglePwd(this)"><i class="fas fa-eye"></i></button>
                    </div>
                </div>
                <button type="submit" class="btn-signin" id="loginBtn">
                    <i class="fas fa-arrow-right-to-bracket"></i>&nbsp; Sign In
                </button>
            </form>

            <div class="div-or"><span>or continue with</span></div>
            <button class="btn-google" onclick="window.location='/oauth2/authorization/google'">
                <svg width="18" height="18" viewBox="0 0 24 24"><path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/><path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/><path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l3.66-2.84z"/><path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/></svg>
                Continue with Google
            </button>
            <div class="auth-link">Don't have an account? <a href="/register">Create one free</a></div>
        </div>
    </div>
</div>

<script>
const API = '';
const Auth = {
    set: d => { localStorage.setItem('accessToken',d.accessToken); localStorage.setItem('refreshToken',d.refreshToken); localStorage.setItem('user',JSON.stringify(d.user)); },
    isIn: () => !!localStorage.getItem('accessToken')
};

if(Auth.isIn()) window.location.href='/dashboard';

function showAlert(msg,type){
    const b=document.getElementById('alertBox');
    b.className='alert alert-'+(type||'error');
    b.innerHTML='<i class="fas fa-'+(type==='success'?'check-circle':'exclamation-circle')+'"></i><span>'+msg+'</span>';
    b.classList.remove('hidden');
}

function togglePwd(btn){
    const inp=btn.closest('.inp-wrap').querySelector('input');
    const ic=btn.querySelector('i');
    inp.type=inp.type==='password'?'text':'password';
    ic.className=inp.type==='password'?'fas fa-eye':'fas fa-eye-slash';
}

async function doLogin(e){
    e.preventDefault();
    const btn=document.getElementById('loginBtn');
    const email=document.getElementById('email').value;
    const pass=document.getElementById('password').value;
    btn.disabled=true;
    btn.innerHTML='<span class="spinner"></span>Signing in...';
    try{
        const res=await fetch(API+'/api/auth/login',{
            method:'POST',headers:{'Content-Type':'application/json'},
            body:JSON.stringify({email,password:pass})
        });
        const json=await res.json();
        if(!res.ok) throw new Error(json.message||'Invalid credentials');
        Auth.set(json.data||json);
        showAlert('Login successful! Redirecting...','success');
        setTimeout(()=>window.location.href='/dashboard',900);
    }catch(err){
        showAlert(err.message||'Login failed. Check your credentials.','error');
    }finally{
        btn.disabled=false;
        btn.innerHTML='<i class="fas fa-arrow-right-to-bracket"></i>&nbsp; Sign In';
    }
}

/* â”€â”€ Aurora canvas animation â”€â”€ */
const canvas=document.getElementById('c');
const ctx=canvas.getContext('2d');
let W,H,t=0;
function resize(){W=canvas.width=window.innerWidth;H=canvas.height=window.innerHeight}
resize();window.addEventListener('resize',resize);
function draw(){
    ctx.clearRect(0,0,W,H);
    const colors=[[124,58,237],[79,70,229],[6,182,212],[139,92,246]];
    colors.forEach((c,i)=>{
        const x=W*(0.2+i*0.22)+Math.sin(t*0.4+i*1.5)*150;
        const y=H*(0.3+i%2*0.4)+Math.cos(t*0.3+i)*120;
        const r=Math.max(W,H)*0.35;
        const g=ctx.createRadialGradient(x,y,0,x,y,r);
        g.addColorStop(0,'rgba(' + c + ',0.18)');
        g.addColorStop(1,'rgba(0,0,0,0)');
        ctx.fillStyle=g;ctx.fillRect(0,0,W,H);
    });
    t+=0.005;requestAnimationFrame(draw);
}
draw();
</script>
</body>
</html>

