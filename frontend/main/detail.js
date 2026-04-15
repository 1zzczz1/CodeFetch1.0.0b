// 页面加载完成后执行
document.addEventListener('DOMContentLoaded', function() {
    // 获取URL参数中的函数ID
    const urlParams = new URLSearchParams(window.location.search);
    const funcId = urlParams.get('id');
    
    if (!funcId) {
        document.getElementById('functionDetail').innerHTML = '<p>未找到函数ID</p>';
        return;
    }
    
    // 加载函数详情
    loadFunctionDetail(funcId);
    
    // 检查收藏状态
    checkFavoriteStatus();
    
    // 获取DOM元素
    const favoriteBtn = document.getElementById('favoriteBtn');
    const shareBtn = document.getElementById('shareBtn');
    
    // 状态管理
    let isFavorited = false;
    
    // 收藏功能
    function toggleFavorite() {
        const token = localStorage.getItem('token');
        if (!token) {
            alert('请先登录');
            window.location.href = '../login/login.html';
            return;
        }
        
        if (isFavorited) {
            // 取消收藏
            fetch(`http://localhost:5000/api/favorites/${funcId}`, {
                method: 'DELETE',
                headers: {
                    'Authorization': `Bearer ${token}`
                }
            })
            .then(res => res.json())
            .then(data => {
                if (data.message) {
                    isFavorited = false;
                    favoriteBtn.classList.remove('favorited');
                    alert('已从收藏中移除');
                } else {
                    alert(data.error || '操作失败');
                }
            })
            .catch(err => alert('网络错误'));
        } else {
            // 添加收藏
            fetch('http://localhost:5000/api/favorites', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`
                },
                body: JSON.stringify({ func_id: funcId })
            })
            .then(res => res.json())
            .then(data => {
                if (data.message) {
                    isFavorited = true;
                    favoriteBtn.classList.add('favorited');
                    alert('已添加到收藏');
                } else {
                    alert(data.error || '操作失败');
                }
            })
            .catch(err => alert('网络错误'));
        }
    }

    // 检查收藏状态
    function checkFavoriteStatus() {
        const token = localStorage.getItem('token');
        if (!token) return;
        
        fetch('http://localhost:5000/api/favorites', {
            headers: {
                'Authorization': `Bearer ${token}`
            }
        })
        .then(res => res.json())
        .then(data => {
            if (data.error) return;
            
            const isFav = data.some(fav => fav.func_id == funcId);
            isFavorited = isFav;
            favoriteBtn.classList.toggle('favorited', isFav);
        })
        .catch(err => console.error('检查收藏状态失败', err));
    }
    
    // 分享功能
    function shareContent() {
        if (navigator.share) {
            navigator.share({
                title: '函数详情',
                text: document.getElementById('funcName').textContent,
                url: window.location.href
            }).catch(err => {
                console.error('分享失败:', err);
                copyToClipboard();
            });
        } else {
            copyToClipboard();
        }
    }
    
    // 复制链接到剪贴板
    function copyToClipboard() {
        navigator.clipboard.writeText(window.location.href)
            .then(() => {
                alert('链接已复制到剪贴板');
            })
            .catch(err => {
                console.error('复制失败:', err);
                alert('复制失败，请手动复制链接');
            });
    }
    
    // 事件监听器
    favoriteBtn.addEventListener('click', toggleFavorite);
    shareBtn.addEventListener('click', shareContent);
});

// 加载函数详情
function loadFunctionDetail(funcId) {
    // 显式指定后端地址以避免端口冲突
    const detailUrl = `http://localhost:5000/api/function/${funcId}`;
    fetch(detailUrl)
        .then(response => response.json())
        .then(data => {
            if (data.error) {
                document.getElementById('functionDetail').innerHTML = `<p>错误: ${data.error}</p>`;
                return;
            }
            
            // 更新标题
            document.getElementById('funcName').textContent = `${data.lang_name} - ${data.func_name}`;
            
            // 构建详情HTML
            const detailHtml = `
                <div class="detail-section">
                    <h3>基本信息</h3>
                    <p><strong>语言:</strong> ${data.lang_name}</p>
                    <p><strong>函数名:</strong> ${data.func_name}</p>
                    <p><strong>分类:</strong> ${data.func_category || '未分类'}</p>
                </div>
                
                <div class="detail-section">
                    <h3>参数和返回值</h3>
                    <p><strong>参数:</strong> ${data.func_params || '无'}</p>
                    <p><strong>返回值:</strong> ${data.func_return || '无'}</p>
                </div>
                
                <div class="detail-section">
                    <h3>描述</h3>
                    <p>${data.func_description || '暂无描述'}</p>
                </div>
                
                <div class="detail-section">
                    <h3>示例代码</h3>
                    <pre><code>${data.func_example_code || '暂无示例'}</code></pre>
                </div>
                
                ${data.func_notes ? `
                <div class="detail-section">
                    <h3>备注</h3>
                    <p>${data.func_notes}</p>
                </div>
                ` : ''}
            `;
            
            document.getElementById('functionDetail').innerHTML = detailHtml;
        })
        .catch(error => {
            console.error('Error:', error);
            document.getElementById('functionDetail').innerHTML = '<p>加载失败，请重试</p>';
        });
}