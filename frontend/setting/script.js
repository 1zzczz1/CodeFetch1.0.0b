document.addEventListener('DOMContentLoaded', function() {
    const API_BASE = 'http://localhost:5000';
    const DEFAULT_AVATAR = '../picture/头像.jpg';
    const userEmail = localStorage.getItem('userEmail'); // 假设登录时存储了邮箱
    console.log('userEmail from localStorage:', userEmail);

    if (!userEmail) {
        alert('请先登录');
        window.location.href = '../login/login.html';
        return;
    }

    // 获取元素
    const usernameInput = document.getElementById('username');
    const emailInput = document.getElementById('email');
    const avatarImg = document.getElementById('avatarImg');
    const avatarFileInput = document.getElementById('avatarFile');
    const updateAvatarBtn = document.getElementById('updateAvatar');
    const oldPasswordInput = document.getElementById('oldPassword');
    const newPasswordInput = document.getElementById('newPassword');
    const confirmPasswordInput = document.getElementById('confirmPassword');
    const changePasswordBtn = document.getElementById('changePassword');
    const saveSettingsBtn = document.getElementById('saveSettings');
    const messageDiv = document.getElementById('message');
    const favoritesList = document.getElementById('favoritesList');
    const logoutBtn = document.getElementById('logoutBtn');
    const deleteAccountBtn = document.getElementById('deleteAccountBtn');

    // 设置邮箱
    emailInput.value = userEmail;

    // 应用用户设置
    applyUserSettings();

    // 统一清洗/修正头像地址（处理旧的 /working/picture/ 等无效地址）
    function sanitizeAvatarUrl(url) {
        if (!url) return DEFAULT_AVATAR;
        // 已经是 dataURL 或相对路径，直接使用
        if (url.startsWith('data:image')) return url;
        if (url.startsWith('../picture/')) return url;
        if (url.startsWith('./picture/')) return url;
        if (url.includes('/frontend/picture/')) {
            const fileName = decodeURIComponent(url.split('/').pop() || '');
            return `../picture/${fileName || '头像.jpg'}`;
        }
        if (url.includes('/working/picture/')) {
            const fileName = decodeURIComponent(url.split('/').pop() || '');
            return `../picture/${fileName || '头像.jpg'}`;
        }
        // 其它未知情况一律回退为默认头像
        return DEFAULT_AVATAR;
    }
    
    // 加载设置
    loadSettings();
    loadFavorites();



    // 更新头像
    updateAvatarBtn.addEventListener('click', function() {
        const file = avatarFileInput.files[0];
        if (file) {
            // 检查文件大小
            if (file.size > 10 * 1024 * 1024) { // 10MB限制
                showMessage('图片大小不能超过10MB', 'error');
                return;
            }
            
            const reader = new FileReader();
            reader.onload = function(e) {
                // 使用Canvas压缩图片
                const img = new Image();
                img.onload = function() {
                    const canvas = document.createElement('canvas');
                    const maxWidth = 300;
                    const maxHeight = 300;
                    let width = img.width;
                    let height = img.height;
                    
                    // 计算压缩比例
                    if (width > height) {
                        if (width > maxWidth) {
                            height *= maxWidth / width;
                            width = maxWidth;
                        }
                    } else {
                        if (height > maxHeight) {
                            width *= maxHeight / height;
                            height = maxHeight;
                        }
                    }
                    
                    canvas.width = width;
                    canvas.height = height;
                    const ctx = canvas.getContext('2d');
                    ctx.drawImage(img, 0, 0, width, height);
                    
                    // 转换为Data URL，质量设为0.5
                    const compressedDataURL = canvas.toDataURL('image/jpeg', 0.5);
                    
                    // 检查压缩后的长度
                    if (compressedDataURL.length > 20000) {
                        showMessage('压缩后的图片仍然过大，请选择更小的图片', 'error');
                        return;
                    }
                    
                    // 更新预览头像
                    avatarImg.src = compressedDataURL;
                    // 更新侧边栏头像
                    const sidebarAvatar = document.querySelector('.avatar-circle img');
                    if (sidebarAvatar) {
                        sidebarAvatar.src = compressedDataURL;
                    }
                    showMessage('头像预览已更新，请保存设置', 'info');
                };
                img.src = e.target.result;
            };
            reader.readAsDataURL(file);
        }
    });

    // 保存设置
    saveSettingsBtn.addEventListener('click', function() {
        const token = localStorage.getItem('token');
        if (!token) {
            alert('请先登录');
            window.location.href = '../login/login.html';
            return;
        }
        const settings = {
            username: usernameInput.value.trim() || '用户',
            avatar_url: avatarImg.src
        };

        fetch(`${API_BASE}/api/settings`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${token}`
            },
            body: JSON.stringify(settings)
        })
        .then(res => res.json())
        .then(data => {
            if (data.message) {
                showMessage('设置保存成功', 'success');
                // 更新localStorage
                localStorage.setItem('userSettings', JSON.stringify(settings));
                // 更新侧边栏头像
                const sidebarAvatar = document.querySelector('.avatar-circle img');
                if (sidebarAvatar) {
                    sidebarAvatar.src = avatarImg.src;
                }
                // 更新侧边栏用户名
                const sidebarUsername = document.querySelector('.title h1');
                if (sidebarUsername) {
                    sidebarUsername.textContent = settings.username;
                }
            } else {
                showMessage(data.error || '保存失败', 'error');
            }
        })
        .catch(err => {
            // 即使网络错误，也保存到本地存储
            localStorage.setItem('userSettings', JSON.stringify(settings));
            // 更新侧边栏头像
            const sidebarAvatar = document.querySelector('.avatar-circle img');
            if (sidebarAvatar) {
                sidebarAvatar.src = avatarImg.src;
            }
            // 更新侧边栏用户名
            const sidebarUsername = document.querySelector('.title h1');
            if (sidebarUsername) {
                sidebarUsername.textContent = settings.username;
            }
            showMessage('网络错误，但设置已保存到本地', 'warning');
        });
    });

    // 修改密码
    changePasswordBtn.addEventListener('click', function() {
        const token = localStorage.getItem('token');
        if (!token) {
            alert('请先登录');
            window.location.href = '../login/login.html';
            return;
        }
        const oldPass = oldPasswordInput.value;
        const newPass = newPasswordInput.value;
        const confirmPass = confirmPasswordInput.value;

        if (!oldPass || !newPass || !confirmPass) {
            showMessage('请填写所有密码字段', 'error');
            return;
        }

        if (newPass !== confirmPass) {
            showMessage('新密码和确认密码不一致', 'error');
            return;
        }

        // 密码强度验证
        const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$/;
        if (newPass.length < 8 || !passwordRegex.test(newPass)) {
            showMessage('新密码必须至少8位，包含大小写字母和数字', 'error');
            return;
        }

        // 禁用按钮，防止重复提交
        changePasswordBtn.disabled = true;
        changePasswordBtn.textContent = '修改中...';

        fetch(`${API_BASE}/api/change-password`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${token}`
            },
            body: JSON.stringify({
                old_password: oldPass,
                new_password: newPass
            })
        })
        .then(res => res.json())
        .then(data => {
            if (data.message) {
                showMessage('密码修改成功', 'success');
                oldPasswordInput.value = '';
                newPasswordInput.value = '';
                confirmPasswordInput.value = '';
            } else {
                showMessage(data.error || '修改失败', 'error');
            }
        })
        .catch(err => showMessage('网络错误', 'error'))
        .finally(() => {
            // 恢复按钮状态
            changePasswordBtn.disabled = false;
            changePasswordBtn.textContent = '修改密码';
        });
    });

    function loadSettings() {
        console.log('Loading settings for email:', userEmail);
        const token = localStorage.getItem('token');
        if (!token) {
            alert('请先登录');
            window.location.href = '../login/login.html';
            return;
        }
        
        // 获取侧边栏头像元素
        const sidebarAvatar = document.querySelector('.avatar-circle img');
        
        // 先从localStorage获取设置（侧边栏使用的设置）
        const localSettings = localStorage.getItem('userSettings');
        if (localSettings) {
            const userSettings = JSON.parse(localSettings);
            if (usernameInput) usernameInput.value = userSettings.username || '用户';
            if (avatarImg) avatarImg.src = sanitizeAvatarUrl(userSettings.avatar_url) || DEFAULT_AVATAR;
            if (sidebarAvatar) sidebarAvatar.src = sanitizeAvatarUrl(userSettings.avatar_url) || DEFAULT_AVATAR;
        }
        
        // 再从后端获取设置（作为备份）
        fetch(`${API_BASE}/api/settings`, {
            headers: {
                'Authorization': `Bearer ${token}`
            }
        })
        .then(res => {
            console.log('Settings API response status:', res.status);
            return res.json();
        })
        .then(data => {
            console.log('Settings data:', data);
            if (data.error) {
                showMessage(data.error, 'error');
                return;
            }

            // 只有当localStorage中没有设置时，才使用后端返回的设置
            const localSettings = localStorage.getItem('userSettings');
            if (!localSettings) {
                if (usernameInput) usernameInput.value = data.username || '用户';
                if (avatarImg) avatarImg.src = sanitizeAvatarUrl(data.avatar_url);
                if (sidebarAvatar) sidebarAvatar.src = sanitizeAvatarUrl(data.avatar_url);
                
                // 存储到localStorage
                const settingsToStore = {
                    username: data.username || '用户',
                    avatar_url: sanitizeAvatarUrl(data.avatar_url),
                    font_size: data.font_size || 16
                };
                localStorage.setItem('userSettings', JSON.stringify(settingsToStore));
            } else {
                // 即使已有本地设置，也尝试修正一次侧边栏 & 预览中的旧头像地址
                const stored = JSON.parse(localSettings);
                const fixedUrl = sanitizeAvatarUrl(stored.avatar_url);
                if (avatarImg) avatarImg.src = fixedUrl;
                if (sidebarAvatar) sidebarAvatar.src = fixedUrl;
                stored.avatar_url = fixedUrl;
                localStorage.setItem('userSettings', JSON.stringify(stored));
            }
        })
        .catch(err => {
            console.error('Load settings error:', err);
            // 加载失败时也回退到默认头像
            if (avatarImg) {
                avatarImg.src = DEFAULT_AVATAR;
            }
            if (sidebarAvatar) {
                sidebarAvatar.src = DEFAULT_AVATAR;
            }
            showMessage('加载设置失败', 'error');
        });
    }

    function loadFavorites() {
        const token = localStorage.getItem('token');
        if (!token) {
            alert('请先登录');
            window.location.href = '../login/login.html';
            return;
        }
        fetch(`${API_BASE}/api/favorites`, {
            headers: {
                'Authorization': `Bearer ${token}`
            }
        })
        .then(res => res.json())
        .then(data => {
            if (data.error) {
                favoritesList.innerHTML = '<p>加载收藏失败</p>';
                return;
            }

            if (data.length === 0) {
                favoritesList.innerHTML = '<p>暂无收藏</p>';
                return;
            }

            const html = data.map(fav => `
                <div class="favorite-item">
                    <span class="favorite-info" data-id="${fav.func_id}">${fav.lang_name} - ${fav.func_name}</span>
                    <button onclick="removeFavorite(${fav.func_id})")">删除</button>
                </div>
            `).join('');
            favoritesList.innerHTML = html;
            
            // 添加点击跳转到详情页的事件监听器
            document.querySelectorAll('.favorite-info').forEach(info => {
                info.addEventListener('click', function() {
                    const funcId = this.dataset.id;
                    window.location.href = '../main/detail.html?id=' + funcId;
                });
            });
        })
        .catch(err => {
            favoritesList.innerHTML = '<p>加载收藏失败</p>';
        });
    }

    window.removeFavorite = function(funcId) {
        const token = localStorage.getItem('token');
        if (!token) {
            alert('请先登录');
            window.location.href = '../login/login.html';
            return;
        }
        fetch(`${API_BASE}/api/favorites/${funcId}`, {
            method: 'DELETE',
            headers: {
                'Authorization': `Bearer ${token}`
            }
        })
        .then(res => res.json())
        .then(data => {
            if (data.message) {
                showMessage('收藏删除成功', 'success');
                loadFavorites();
            } else {
                showMessage(data.error || '删除失败', 'error');
            }
        })
        .catch(err => showMessage('网络错误', 'error'));
    };

    function showMessage(msg, type) {
        messageDiv.textContent = msg;
        messageDiv.className = `message ${type}`;
        setTimeout(() => {
            messageDiv.textContent = '';
            messageDiv.className = 'message';
        }, 3000);
    }

    // 应用用户设置
    function applyUserSettings() {
        const settings = localStorage.getItem('userSettings');
        if (settings) {
            const userSettings = JSON.parse(settings);
            
            // 应用用户名
            if (usernameInput) {
                usernameInput.value = userSettings.username || '用户';
            }
            
            // 应用头像
            if (avatarImg) {
                avatarImg.src = sanitizeAvatarUrl(userSettings.avatar_url) || DEFAULT_AVATAR;
            }
            
            // 应用侧边栏头像和用户名
            const sidebarAvatar = document.querySelector('.avatar-circle img');
            const sidebarUsername = document.querySelector('.title h1');
            if (sidebarAvatar) {
                sidebarAvatar.src = sanitizeAvatarUrl(userSettings.avatar_url) || DEFAULT_AVATAR;
            }
            if (sidebarUsername) {
                sidebarUsername.textContent = userSettings.username || '用户';
            }
        }
    }

    // 退出账号
    logoutBtn.addEventListener('click', function() {
        if (confirm('确定要退出账号吗？')) {
            // 清除本地存储的用户信息
            localStorage.removeItem('userEmail');
            localStorage.removeItem('userSettings');
            // 跳转到登录页面
            window.location.href = '../login/login.html';
        }
    });

    // 注销账号
    deleteAccountBtn.addEventListener('click', function() {
        const token = localStorage.getItem('token');
        if (!token) {
            alert('请先登录');
            window.location.href = '../login/login.html';
            return;
        }
        if (confirm('注销账号将永久删除您的所有数据，此操作不可恢复！确定要注销吗？')) {
            fetch(`${API_BASE}/api/delete-account`, {
                method: 'DELETE',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`
                }
            })
            .then(res => res.json())
            .then(data => {
                if (data.message) {
                    // 清除本地存储的用户信息
                    localStorage.removeItem('userEmail');
                    localStorage.removeItem('userSettings');
                    localStorage.removeItem('token');
                    // 跳转到登录页面
                    alert('账号已成功注销');
                    window.location.href = '../login/login.html';
                } else {
                    showMessage(data.error || '注销失败', 'error');
                }
            })
            .catch(err => showMessage('网络错误', 'error'));
        }
    });

    // 页面关闭或离开时触发保存设置
    window.addEventListener('beforeunload', async function() {
        if (window.electronAPI && typeof window.electronAPI.triggerSaveSettings === 'function') {
            try {
                await window.electronAPI.triggerSaveSettings();
            } catch (error) {
                console.error('Failed to trigger save settings:', error);
            }
        }
    });
});