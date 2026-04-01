// 页面加载完成后执行
 document.addEventListener('DOMContentLoaded', function() {
  // 应用用户设置
  applyUserSettings();

  // 获取DOM元素
  const searchInput = document.getElementById('searchInput');
  const searchBtn = document.getElementById('searchBtn');
  const searchDropdown = document.getElementById('searchDropdown');
  const suggestionsList = document.getElementById('suggestionsList');
    const favoriteBtn = document.getElementById('favoriteBtn');
    const refreshBtn = document.getElementById('refreshBtn');
    const shareBtn = document.getElementById('shareBtn');
    const backToTop = document.getElementById('backToTop');
    const addBtn = document.getElementById('add');
    const favoritesList = document.getElementById('favoritesList');
    
    // 当前语言（根据页面路径自动识别）
    let currentLang = 'Python';
    const path = window.location.pathname || '';
    if (path.includes('C++.html')) {
      currentLang = 'C++';
    } else if (path.includes('python.html')) {
      currentLang = 'Python';
    }
    
    // 状态管理
    let isFavorited = false;
    let suggestionTimer = null;
    
    // 加载收藏列表
    function loadFavorites() {
      // 如果当前页面没有收藏列表容器，则直接跳过
      if (!favoritesList) {
        return;
      }
      // 从localStorage获取token和用户邮箱（假设已登录）
      const token = localStorage.getItem('token');
      const userEmail = localStorage.getItem('userEmail');
      if (!token || !userEmail) {
        favoritesList.innerHTML = '<p class="no-favorites">请先登录</p>';
        return;
      }
      
      const apiUrl = `http://localhost:5000/api/favorites`;
      fetch(apiUrl, {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      })
        .then(response => response.json())
        .then(data => {
          if (data.error) {
            console.error('Error loading favorites:', data.error);
            favoritesList.innerHTML = '<p class="no-favorites">加载收藏失败</p>';
            return;
          }
          
          renderFavorites(data);
        })
        .catch(error => {
          console.error('Error:', error);
          favoritesList.innerHTML = '<p class="no-favorites">加载收藏失败</p>';
        });
    }
    
    // 渲染收藏列表
    function renderFavorites(favorites) {
      if (!favoritesList) {
        return;
      }

      if (favorites.length === 0) {
        favoritesList.innerHTML = '<p class="no-favorites">暂无收藏的函数</p>';
        return;
      }
      
      favoritesList.innerHTML = '';
      favorites.forEach(fav => {
        const itemDiv = document.createElement('div');
        itemDiv.className = 'favorite-item';
        itemDiv.innerHTML = `
          <div class="favorite-info" data-id="${fav.func_id}">
            <div class="favorite-name">${fav.func_name}</div>
            <div class="favorite-lang">${fav.lang_name}</div>
          </div>
          <button class="remove-favorite" data-id="${fav.func_id}">删除</button>
        `;
        favoritesList.appendChild(itemDiv);
      });
      
      // 添加删除事件监听器
      document.querySelectorAll('.remove-favorite').forEach(btn => {
        btn.addEventListener('click', function(e) {
          e.stopPropagation(); // 阻止事件冒泡
          const funcId = this.dataset.id;
          removeFavorite(funcId);
        });
      });
      
      // 添加点击跳转到详情页的事件监听器
      document.querySelectorAll('.favorite-info').forEach(info => {
        info.addEventListener('click', function() {
          const funcId = this.dataset.id;
          window.location.href = `detail.html?id=${funcId}`;
        });
      });
    }
    
    // 删除收藏
    function removeFavorite(funcId) {
      const token = localStorage.getItem('token');
      const userEmail = localStorage.getItem('userEmail');
      if (!token || !userEmail) {
        alert('请先登录');
        return;
      }
      
      const apiUrl = `http://localhost:5000/api/favorites/${funcId}`;
      fetch(apiUrl, {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${token}`
        }
      })
        .then(response => response.json())
        .then(data => {
          if (data.error) {
            console.error('Error removing favorite:', data.error);
            alert('删除失败：' + data.error);
            return;
          }
          
          // 重新加载收藏列表
          loadFavorites();
          alert('删除成功');
        })
        .catch(error => {
          console.error('Error:', error);
          alert('删除失败');
        });
    }
    
    // 搜索功能（跳转到搜索结果页）
    function handleSearch() {
      if (!searchInput) return;
      const query = searchInput.value.trim();
      if (!query) {
        alert('请输入搜索内容');
        return;
      }
      const url = `search_results.html?lang=${encodeURIComponent(currentLang)}&query=${encodeURIComponent(query)}`;
      window.location.href = url;
    }

    // 搜索联想（从后端获取前5个最相近结果）
    function handleSearchInput() {
      if (!searchInput || !searchDropdown || !suggestionsList) return;
      const query = searchInput.value.trim();
      if (!query) {
        suggestionsList.innerHTML = '';
        searchDropdown.style.display = 'none';
        return;
      }
      if (suggestionTimer) {
        clearTimeout(suggestionTimer);
      }
      suggestionTimer = setTimeout(() => {
        const apiUrl = `http://localhost:5000/api/search?lang=${encodeURIComponent(currentLang)}&query=${encodeURIComponent(query)}`;
        fetch(apiUrl)
          .then(response => response.json())
          .then(data => {
            if (!data || !Array.isArray(data.results)) {
              suggestionsList.innerHTML = '<li class="dropdown-item" style="padding:8px 12px;color:#999;">无建议</li>';
              searchDropdown.style.display = 'block';
              return;
            }
            const topResults = data.results.slice(0, 5);
            if (topResults.length === 0) {
              suggestionsList.innerHTML = '<li class="dropdown-item" style="padding:8px 12px;color:#999;">暂无相关结果</li>';
              searchDropdown.style.display = 'block';
              return;
            }
            suggestionsList.innerHTML = '';
            topResults.forEach(item => {
              const li = document.createElement('li');
              li.className = 'dropdown-item';
              li.style.padding = '8px 12px';
              li.style.cursor = 'pointer';
              li.innerHTML = `
                <div class="item-content">
                  <span>🔍</span>
                  <span style="margin-left: 8px;">${item.name}</span>
                </div>
              `;
              li.addEventListener('click', () => {
                searchInput.value = item.name;
                searchDropdown.style.display = 'none';
                handleSearch();
              });
              suggestionsList.appendChild(li);
            });
            searchDropdown.style.display = 'block';
          })
          .catch(() => {
            // 出错时不打断主流程，只隐藏下拉
            suggestionsList.innerHTML = '';
            searchDropdown.style.display = 'none';
          });
      }, 300);
    }
    
    // 收藏功能
    function toggleFavorite() {
      isFavorited = !isFavorited;
      favoriteBtn.classList.toggle('favorited', isFavorited);
      
      // 存储收藏状态到localStorage
      localStorage.setItem('mainPageFavorited', isFavorited);
    }
    
    // 刷新功能
    function refreshPage() {
      // 显示刷新动画
      refreshBtn.classList.add('refreshing');
      
      // 1秒后移除刷新动画
      setTimeout(() => {
        refreshBtn.classList.remove('refreshing');
      }, 1000);
      window.location.reload();
    }
    
    // 增加功能 - 打开新的主界面
    function addfunction(){
      // 在新标签页中打开主界面
      window.open('index.html', '_blank');
    }
    // 分享功能
    function shareContent() {
      if (navigator.share) {
        navigator.share({
          title: 'CodeFetch',
          text: '发现新用法',
          url: window.location.href
        }).catch(err => {
          console.error('分享失败:', err);
          // 分享失败时使用剪贴板复制
          copyToClipboard();
        });
      } else {
        // 不支持Web Share API时使用剪贴板复制
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
    
    // 回到顶部功能
    function scrollToTop() {
      window.scrollTo({
        top: 0,
        behavior: 'smooth'
      });
    }
    
    // 滚动事件处理
    function handleScroll() {
      if (window.scrollY > 300) {
        backToTop.classList.add('show');
      } else {
        backToTop.classList.remove('show');
      }
    }
    
    // 从localStorage加载收藏状态
    function loadFavoriteStatus() {
      const savedFavorited = localStorage.getItem('mainPageFavorited');
      if (savedFavorited !== null) {
        isFavorited = JSON.parse(savedFavorited);
        favoriteBtn.classList.toggle('favorited', isFavorited);
      }
    }
    
    // 事件监听器
    if (searchBtn && searchInput) {
      searchBtn.addEventListener('click', handleSearch);
      searchInput.addEventListener('keypress', function(e) {
        if (e.key === 'Enter') {
          handleSearch();
        }
      });
      // 只有在存在下拉容器（Python 页面）时才绑定联想输入
      if (searchDropdown && suggestionsList) {
        searchInput.addEventListener('input', handleSearchInput);
      }
    }

    favoriteBtn.addEventListener('click', toggleFavorite);
    refreshBtn.addEventListener('click', refreshPage);
    shareBtn.addEventListener('click', shareContent);
    backToTop.addEventListener('click', scrollToTop);
    window.addEventListener('scroll', handleScroll);
    addBtn.addEventListener('click', addfunction);

    // 点击页面其他区域时关闭联想下拉
    if (searchDropdown && searchInput) {
      document.addEventListener('click', function(e) {
        if (!searchDropdown.contains(e.target) && !searchInput.contains(e.target)) {
          searchDropdown.style.display = 'none';
        }
      });
    }
    
    // 加载收藏状态和收藏列表
    loadFavoriteStatus();
    loadFavorites();
  });

  // 统一清洗/修正头像地址
  function sanitizeAvatarUrl(url) {
    const DEFAULT_AVATAR = '../picture/头像.jpg';
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

  // 应用用户设置
  function applyUserSettings() {
    const settings = localStorage.getItem('userSettings');
    if (settings) {
      const userSettings = JSON.parse(settings);
      
      // 应用文字大小
      if (userSettings.font_size) {
        document.documentElement.style.fontSize = userSettings.font_size + 'px';
      }
      
      // 应用头像和用户名（如果有侧边栏）
      const avatarImg = document.querySelector('.avatar-circle img');
      const usernameEl = document.querySelector('.title h1');
      if (avatarImg) {
          avatarImg.src = sanitizeAvatarUrl(userSettings.avatar_url) || '../picture/头像.jpg';
      }
            if (usernameEl) {
                usernameEl.textContent = userSettings.username || '用户';
            }
    }
  }