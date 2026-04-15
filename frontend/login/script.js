import backendChecker from '../utils/backend-check.js';

(function(){
    const emailinput=document.getElementById('email');
    const passwordinput=document.getElementById('password');
    const emailerr=document.getElementById('emailerr');
    const passerr=document.getElementById('passerr');
    const visibtn=document.getElementById('visibtn');
    const form=document.getElementById('loginForm');
    const formMsg=document.getElementById('formMsg');

    // 忘记密码相关
    const forgotPasswordLink = document.getElementById('forgotPasswordLink');
    const forgotPasswordModal = document.getElementById('forgotPasswordModal');
    const closeModal = document.getElementById('closeModal');
    const forgotEmail = document.getElementById('forgotEmail');
    const sendPasswordBtn = document.getElementById('sendPasswordBtn');
    const forgotMsg = document.getElementById('forgotMsg');
    
    // 注册链接
    const registerLink = document.querySelector('a[href="../register/register.html"]');
    
    // 注册链接点击事件
    if (registerLink) {
        registerLink.addEventListener('click', async (e) => {
            e.preventDefault();
            
            // 检查并启动后端服务
            backendChecker.showLoading('正在检查服务...');
            const backendReady = await backendChecker.ensureBackend();
            backendChecker.hideLoading();
            
            if (!backendReady) {
                setStatus('后端服务启动失败，请检查服务配置', false);
                return;
            }
            
            // 跳转到注册页面
            window.location.href = "../register/register.html";
        });
    }

    // 优化：添加加载状态管理
    let isSubmitting = false;
    
    // 优化：添加防抖函数
    function debounce(func, wait) {
        let timeout;
        return function() {
            clearTimeout(timeout);
            timeout = setTimeout(() => func.apply(this, arguments), wait);
        };
    }

    function setStatus(msg, success){
        formMsg.textContent = msg;
        formMsg.style.color = success ? '#059669' : '#b91c1c';
        formMsg.classList.remove('hidden');
        formMsg.setAttribute('aria-hidden', 'false');
        
        // 优化：3秒后自动隐藏状态消息
        setTimeout(() => {
            formMsg.classList.add('hidden');
            formMsg.setAttribute('aria-hidden', 'true');
        }, 3000);
    }
    
    // 优化：密码显示/隐藏功能，添加图标和动画效果
    visibtn.addEventListener('click',()=>{
        if(passwordinput.type==='password'){
            passwordinput.type='text';
            visibtn.textContent=' 隐藏';
            // 添加过渡动画
            passwordinput.style.transition = 'all 0.3s ease';
            passwordinput.style.transform = 'scale(1.02)';
            setTimeout(() => {
                passwordinput.style.transform = 'scale(1)';
            }, 300);
        }else{
            passwordinput.type='password';
            visibtn.textContent=' 显示';
            // 添加过渡动画
            passwordinput.style.transition = 'all 0.3s ease';
            passwordinput.style.transform = 'scale(1.02)';
            setTimeout(() => {
                passwordinput.style.transform = 'scale(1)';
            }, 300);
        }
    });

    function showError(el,msg){
        el.textContent=msg;
        el.classList.remove('hidden');
        el.setAttribute('aria-hidden','false');
        // 优化：添加错误提示动画
        el.style.transition = 'all 0.3s ease';
        el.style.opacity = '0';
        el.style.transform = 'translateY(-10px)';
        setTimeout(() => {
            el.style.opacity = '1';
            el.style.transform = 'translateY(0)';
        }, 10);
    }
    
    function clearError(el){
        // 优化：添加淡出动画
        el.style.transition = 'all 0.3s ease';
        el.style.opacity = '0';
        el.style.transform = 'translateY(-10px)';
        setTimeout(() => {
            el.textContent='';
            el.classList.add('hidden');
            el.setAttribute('aria-hidden','true');
            el.style.opacity = '1';
            el.style.transform = 'translateY(0)';
        }, 3000);
    }  
    
    // 忘记密码模态框
    forgotPasswordLink.addEventListener('click', (e) => {
        e.preventDefault();
        forgotPasswordModal.classList.remove('hidden');
        forgotEmail.focus();
    });

    closeModal.addEventListener('click', () => {
        forgotPasswordModal.classList.add('hidden');
        forgotMsg.textContent = '';
        forgotEmail.value = '';
    });

    // 点击模态框外部关闭
    window.addEventListener('click', (e) => {
        if (e.target === forgotPasswordModal) {
            forgotPasswordModal.classList.add('hidden');
            forgotMsg.textContent = '';
            forgotEmail.value = '';
        }
    });

    // ESC键关闭模态框
    window.addEventListener('keydown', (e) => {
        if (e.key === 'Escape' && !forgotPasswordModal.classList.contains('hidden')) {
            forgotPasswordModal.classList.add('hidden');
            forgotMsg.textContent = '';
            forgotEmail.value = '';
        }
    });

    // 发送密码
    sendPasswordBtn.addEventListener('click', async () => {
        const email = forgotEmail.value.trim();
        if (!email) {
            forgotMsg.textContent = '请输入邮箱';
            forgotMsg.style.color = 'red';
            return;
        }

        // 检查并启动后端服务
        backendChecker.showLoading('正在检查服务...');
        const backendReady = await backendChecker.ensureBackend();
        backendChecker.hideLoading();
        
        if (!backendReady) {
            forgotMsg.textContent = '后端服务启动失败，请检查服务配置';
            forgotMsg.style.color = 'red';
            return;
        }

        sendPasswordBtn.disabled = true;
        sendPasswordBtn.textContent = '发送中...';

        fetch('http://localhost:5000/api/forgot-password', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ email })
        })
        .then(res => res.json())
        .then(data => {
            if (data.password) {
                forgotMsg.textContent = `您的密码是：${data.password}`;
                forgotMsg.style.color = 'green';
            } else {
                forgotMsg.textContent = data.error || '发送失败';
                forgotMsg.style.color = 'red';
            }
        })
        .catch(err => {
            forgotMsg.textContent = '网络错误';
            forgotMsg.style.color = 'red';
        })
        .finally(() => {
            sendPasswordBtn.disabled = false;
            sendPasswordBtn.textContent = '发送密码';
        });
    });
    
    // 优化：实时验证函数
    const validateEmail = debounce(() => {
        const em = emailinput.value.trim();
        if (!em) {
            showError(emailerr, '请输入邮箱');
        } else if (!/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(em)) {
            showError(emailerr, '邮箱格式不正确');
        } else {
            clearError(emailerr);
        }
    }, 500);
    
    const validatePassword = debounce(() => {
        const pw = passwordinput.value;
        if (!pw) {
            showError(passerr, '请输入密码');
        } else if (pw.length < 8) {
            showError(passerr, '密码长度至少8位');
        } else if (!/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$/.test(pw)) {
            showError(passerr, '密码需包含大小写字母和数字');
        } else {
            clearError(passerr);
        }
    }, 500);
    
    // 优化：添加实时验证
    emailinput.addEventListener('input', validateEmail);
    passwordinput.addEventListener('input', validatePassword);

    form.addEventListener('submit', async (e)=>{
        e.preventDefault();
        
        // 优化：防止重复提交
        if (isSubmitting) return;
        
        // 检查并启动后端服务
        backendChecker.showLoading('正在检查服务...');
        const backendReady = await backendChecker.ensureBackend();
        backendChecker.hideLoading();
        
        if (!backendReady) {
            setStatus('后端服务启动失败，请检查服务配置', false);
            return;
        }
        
        clearError(emailerr);
        clearError(passerr);
        
        const em=emailinput.value.trim();
        const pw=passwordinput.value;
        let ok=true;
        
        // 优化：更全面的表单验证
        if(!em){showError(emailerr,'请输入邮箱');ok=false;}
        else if(!/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(em)){showError(emailerr,'邮箱格式不正确');ok=false;}
        
        if(!pw){showError(passerr,'请输入密码');ok=false;}
        else if(pw.length < 8){showError(passerr,'密码长度至少8位');ok=false;}
        else if(!/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$/.test(pw)){showError(passerr,'密码需包含大小写字母和数字');ok=false;}
        
        if(!ok)return;
        
        // 优化：添加加载状态
        isSubmitting = true;
        setStatus('正在登录...', true);
        
        // 实际登录逻辑：发送API请求
        // 如果前端页面通过文件协议打开，请确保将 API_BASE 改为 http://localhost:3000
        const API_BASE =  'http://localhost:5000';
        fetch(API_BASE + '/api/login', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                email: em,
                password: pw
            })
        })
        .then(response => {
            if (!response.ok) {
                // try parse error body
                return response.json().then(err => { throw new Error(err.error || response.statusText || '登录失败'); });
            }
            return response.json();
        })
        .then(data => {
            // 存储登录状态
            localStorage.setItem('token', data.token);
            localStorage.setItem('user', JSON.stringify(data.user));
            localStorage.setItem('userEmail', data.user.email); // 存储邮箱用于设置页面
            
            // 显示成功消息
            setStatus('登录成功！正在跳转...', true);
            
            // 延迟跳转，让用户看到成功消息
            setTimeout(() => {
                // 跳转到主页面
                window.location.href = "../main/index.html";
            }, 1000);
        })
        .catch(error => {
            // 显示错误消息
            setStatus('登录失败：' + error.message, false);
            isSubmitting = false;
        });
    });

    
})();