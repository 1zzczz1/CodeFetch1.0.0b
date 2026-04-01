document.addEventListener('DOMContentLoaded', function() {
    // 获取表单元素
    const registerForm = document.getElementById('registerForm');
    const emailInput = document.getElementById('email');
    const passwordInput = document.getElementById('password');
    const confirmPasswordInput = document.getElementById('confirmPassword');
    const emailErr = document.getElementById('emailerr');
    const passErr = document.getElementById('passerr');
    const confirmErr = document.getElementById('confirmerr');
    const formMsg = document.getElementById('formMsg');
    const visibtn = document.getElementById('visibtn');
    const visibtn2 = document.getElementById('visibtn2');
    
    // 密码显示/隐藏功能
    visibtn.addEventListener('click', function() {
        const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
        passwordInput.setAttribute('type', type);
        this.textContent = type === 'password' ? '显示' : '隐藏';
    });
    
    visibtn2.addEventListener('click', function() {
        const type = confirmPasswordInput.getAttribute('type') === 'password' ? 'text' : 'password';
        confirmPasswordInput.setAttribute('type', type);
        this.textContent = type === 'password' ? '显示' : '隐藏';
    });
    
    // 邮箱唯一性检查
    emailInput.addEventListener('blur', function() {
        const email = this.value.trim();
        if (email && /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
            checkEmailExists(email);
        }
    });
    
    // 表单验证
    function validateForm() {
        let isValid = true;
        
        // 重置错误信息
        emailErr.textContent = '';
        emailErr.classList.add('hidden');
        emailErr.setAttribute('aria-hidden', 'true');
        
        passErr.textContent = '';
        passErr.classList.add('hidden');
        passErr.setAttribute('aria-hidden', 'true');
        
        confirmErr.textContent = '';
        confirmErr.classList.add('hidden');
        confirmErr.setAttribute('aria-hidden', 'true');
        
        formMsg.textContent = '';
        formMsg.classList.add('hidden');
        formMsg.setAttribute('aria-hidden', 'true');
        
        // 验证邮箱
        const email = emailInput.value.trim();
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!email) {
            emailErr.textContent = '请输入邮箱地址';
            emailErr.classList.remove('hidden');
            emailErr.setAttribute('aria-hidden', 'false');
            isValid = false;
        } else if (!emailRegex.test(email)) {
            emailErr.textContent = '请输入有效的邮箱地址';
            emailErr.classList.remove('hidden');
            emailErr.setAttribute('aria-hidden', 'false');
            isValid = false;
        }
        
        // 验证密码
        const password = passwordInput.value;
        const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$/;
        if (!password) {
            passErr.textContent = '请输入密码';
            passErr.classList.remove('hidden');
            passErr.setAttribute('aria-hidden', 'false');
            isValid = false;
        } else if (password.length < 8) {
            passErr.textContent = '密码长度至少为8位';
            passErr.classList.remove('hidden');
            passErr.setAttribute('aria-hidden', 'false');
            isValid = false;
        } else if (!passwordRegex.test(password)) {
            passErr.textContent = '密码必须包含大写字母、小写字母和数字';
            passErr.classList.remove('hidden');
            passErr.setAttribute('aria-hidden', 'false');
            isValid = false;
        }
        
        // 验证确认密码
        const confirmPassword = confirmPasswordInput.value;
        if (!confirmPassword) {
            confirmErr.textContent = '请再次输入密码';
            confirmErr.classList.remove('hidden');
            confirmErr.setAttribute('aria-hidden', 'false');
            isValid = false;
        } else if (password !== confirmPassword) {
            confirmErr.textContent = '两次输入的密码不一致';
            confirmErr.classList.remove('hidden');
            confirmErr.setAttribute('aria-hidden', 'false');
            isValid = false;
        }
        
        return isValid;
    }
    
    // 通过后台API注册用户
    registerForm.addEventListener('submit', function(e) {
        e.preventDefault();
        
        if (validateForm()) {
            const email = emailInput.value.trim();
            const password = passwordInput.value;
            
            // 发送请求到后端
            const API_BASE = (window.API_BASE) ? window.API_BASE : 'http://localhost:5000';
            fetch(API_BASE + '/api/register', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ email, password })
            })
            .then(resp => resp.json().then(data => ({ status: resp.status, body: data })))
            .then(({ status, body }) => {
                if (status === 200) {
                    formMsg.textContent = '注册成功，即将跳转到登录页面';
                    formMsg.classList.remove('hidden');
                    formMsg.setAttribute('aria-hidden', 'false');
                    setTimeout(() => {
                        window.location.href = '../login/login.html';
                    }, 1500);
                } else if (status === 409) {
                    emailErr.textContent = '该邮箱已被注册';
                    emailErr.classList.remove('hidden');
                    emailErr.setAttribute('aria-hidden', 'false');
                } else {
                    formMsg.textContent = '注册失败：' + (body.error || '未知错误');
                    formMsg.style.color = '#b91c1c';
                    formMsg.classList.remove('hidden');
                    formMsg.setAttribute('aria-hidden', 'false');
                }
            })
            .catch(err => {
                formMsg.textContent = '网络错误：' + err.message;
                formMsg.style.color = '#b91c1c';
                formMsg.classList.remove('hidden');
                formMsg.setAttribute('aria-hidden', 'false');
            });
        }
    });
    
    // 检查邮箱是否已存在
    function checkEmailExists(email) {
        fetch('http://localhost:5000/api/check-email', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ email })
        })
        .then(res => res.json())
        .then(data => {
            if (data.exists) {
                emailErr.textContent = '该邮箱已被注册';
                emailErr.classList.remove('hidden');
                emailErr.setAttribute('aria-hidden', 'false');
            } else {
                emailErr.textContent = '';
                emailErr.classList.add('hidden');
                emailErr.setAttribute('aria-hidden', 'true');
            }
        })
        .catch(err => {
            console.error('检查邮箱失败:', err);
        });
    }
});