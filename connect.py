from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
from werkzeug.security import generate_password_hash, check_password_hash
import pymysql
import os
import jwt
import datetime
import logging

# 配置日志
logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app, origins=["*"])  # 允许所有源跨域访问

# JWT 密钥配置
SECRET_KEY = os.environ.get('SECRET_KEY', 'your-secret-key-here')

# 数据库配置，可通过环境变量调整
DB_HOST = os.environ.get('DB_HOST', 'localhost')
DB_USER = os.environ.get('DB_USER', 'root')
DB_PASSWORD = os.environ.get('DB_PASSWORD', 'Zhchzh100!')
DB_NAME = os.environ.get('DB_NAME', 'language_function_db')

connection = None

# 启动时测试数据库连接
try:
    logger.info(f"Testing database connection to {DB_HOST}/{DB_NAME}")
    test_conn = pymysql.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASSWORD,
        database=DB_NAME,
        charset='utf8mb4',
        cursorclass=pymysql.cursors.DictCursor,
        autocommit=True
    )
    logger.info("Database connection successful")
    test_conn.close()
except Exception as e:
    logger.error(f"Database connection failed: {str(e)}")
    # 继续运行，让应用启动但记录错误


def get_db_connection():
    # 每次调用获取一个新连接，简单可靠
    return pymysql.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASSWORD,
        database=DB_NAME,
        charset='utf8mb4',
        cursorclass=pymysql.cursors.DictCursor,
        autocommit=True
    )

def verify_token(token):
    """验证 JWT 令牌"""
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=['HS256'])
        return payload
    except jwt.ExpiredSignatureError:
        return None
    except jwt.InvalidTokenError:
        return None


@app.route('/api/register', methods=['POST'])
def register():
    data = request.get_json()
    email = data.get('email', '').strip().lower()
    password = data.get('password', '')
    if not email or not password:
        return jsonify({'error': '缺少邮箱或密码'}), 400
    
    # 密码强度验证
    import re
    if len(password) < 8:
        return jsonify({'error': '密码长度至少为8位'}), 400
    if not re.match(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$', password):
        return jsonify({'error': '密码必须包含大写字母、小写字母和数字'}), 400

    hashed = generate_password_hash(password)
    conn = get_db_connection()
    try:
        with conn.cursor() as cur:
            sql = "INSERT INTO users (email, password_hash) VALUES (%s, %s)"
            cur.execute(sql, (email, hashed))
        return jsonify({'message': '注册成功'})
    except pymysql.err.IntegrityError:
        return jsonify({'error': '邮箱已被注册'}), 409
@app.route('/api/login', methods=['POST'])
def login():
    data = request.get_json()
    email = data.get('email', '').strip().lower()
    password = data.get('password', '')
    if not email or not password:
        return jsonify({'error': '缺少邮箱或密码'}), 400

    conn = get_db_connection()
    try:
        with conn.cursor() as cur:
            sql = "SELECT user_id, email, password_hash FROM users WHERE email = %s"
            cur.execute(sql, (email,))
            result = cur.fetchone()
            if result and check_password_hash(result['password_hash'], password):
                # 生成 JWT 令牌
                payload = {
                    'user_id': result['user_id'],
                    'email': result['email'],
                    'exp': datetime.datetime.utcnow() + datetime.timedelta(days=7)  # 7天过期
                }
                token = jwt.encode(payload, SECRET_KEY, algorithm='HS256')
                return jsonify({
                    'message': '登录成功',
                    'user': {'id': result['user_id'], 'email': result['email']},
                    'token': token
                })
            else:
                return jsonify({'error': '邮箱或密码错误'}), 401
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/settings', methods=['GET'])
def get_settings():
    # 从请求头获取 token
    token = request.headers.get('Authorization', '').replace('Bearer ', '')
    if not token:
        return jsonify({'error': '缺少认证令牌'}), 401
    
    # 验证 token
    payload = verify_token(token)
    if not payload:
        return jsonify({'error': '无效的认证令牌'}), 401
    
    user_id = payload['user_id']
    email = payload['email']
    
    conn = get_db_connection()
    try:
        with conn.cursor() as cur:
            # 验证用户是否存在
            cur.execute("SELECT user_id FROM users WHERE user_id = %s", (user_id,))
            user = cur.fetchone()
            if not user:
                return jsonify({'error': '用户不存在'}), 404
            
            # 获取设置，如果不存在则返回默认值
            cur.execute("SELECT username, avatar_url, font_size FROM user_settings WHERE user_id = %s", (user_id,))
            setting = cur.fetchone()
            if not setting:
                setting = {'username': '用户', 'avatar_url': '/frontend/picture/头像.jpg', 'font_size': 16}
            else:
                setting['username'] = setting['username'] or '用户'
                setting['avatar_url'] = setting['avatar_url'] or '/frontend/picture/头像.jpg'
                setting['font_size'] = setting['font_size'] or 16
            
            return jsonify(setting)
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/settings', methods=['PUT'])
def update_settings():
    # 从请求头获取 token
    token = request.headers.get('Authorization', '').replace('Bearer ', '')
    if not token:
        return jsonify({'error': '缺少认证令牌'}), 401
    
    # 验证 token
    payload = verify_token(token)
    if not payload:
        return jsonify({'error': '无效的认证令牌'}), 401
    
    user_id = payload['user_id']
    
    data = request.get_json()
    username = data.get('username', '').strip()
    avatar_url = data.get('avatar_url', '').strip()
    
    conn = get_db_connection()
    try:
        with conn.cursor() as cur:
            # 验证用户是否存在
            cur.execute("SELECT user_id FROM users WHERE user_id = %s", (user_id,))
            user = cur.fetchone()
            if not user:
                return jsonify({'error': '用户不存在'}), 404
            
            # 检查是否已存在设置
            cur.execute("SELECT avatar_url FROM user_settings WHERE user_id = %s", (user_id,))
            existing_setting = cur.fetchone()
            
            # 如果avatar_url为空且存在现有设置，使用现有值
            if not avatar_url and existing_setting:
                avatar_url = existing_setting['avatar_url']
            # 如果avatar_url为空且不存在现有设置，使用默认值
            elif not avatar_url:
                avatar_url = '/frontend/picture/头像.jpg'
            
            # 插入或更新设置
            sql = """
            INSERT INTO user_settings (user_id, username, avatar_url) 
            VALUES (%s, %s, %s) 
            ON DUPLICATE KEY UPDATE 
            username = VALUES(username), 
            avatar_url = VALUES(avatar_url)
            """
            cur.execute(sql, (user_id, username, avatar_url))
            
        return jsonify({'message': '设置更新成功'})
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/change-password', methods=['POST'])
def change_password():
    # 从请求头获取 token
    token = request.headers.get('Authorization', '').replace('Bearer ', '')
    if not token:
        return jsonify({'error': '缺少认证令牌'}), 401
    
    # 验证 token
    payload = verify_token(token)
    if not payload:
        return jsonify({'error': '无效的认证令牌'}), 401
    
    user_id = payload['user_id']
    email = payload['email']
    
    data = request.get_json()
    old_password = data.get('old_password', '')
    new_password = data.get('new_password', '')
    
    if not old_password or not new_password:
        return jsonify({'error': '缺少必要参数'}), 400
    
    # 密码强度验证
    import re
    if len(new_password) < 8:
        return jsonify({'error': '新密码长度至少为8位'}), 400
    if not re.match(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$', new_password):
        return jsonify({'error': '新密码必须包含大写字母、小写字母和数字'}), 400
    
    conn = get_db_connection()
    try:
        with conn.cursor() as cur:
            # 验证旧密码
            cur.execute("SELECT password_hash FROM users WHERE user_id = %s", (user_id,))
            user = cur.fetchone()
            if not user or not check_password_hash(user['password_hash'], old_password):
                return jsonify({'error': '旧密码错误'}), 401
            
            # 更新密码
            new_hash = generate_password_hash(new_password)
            cur.execute("UPDATE users SET password_hash = %s WHERE user_id = %s", (new_hash, user_id))
            
        return jsonify({'message': '密码修改成功'})
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/favorites', methods=['GET'])
def get_favorites():
    # 从请求头获取 token
    token = request.headers.get('Authorization', '').replace('Bearer ', '')
    if not token:
        return jsonify({'error': '缺少认证令牌'}), 401
    
    # 验证 token
    payload = verify_token(token)
    if not payload:
        return jsonify({'error': '无效的认证令牌'}), 401
    
    user_id = payload['user_id']
    
    conn = get_db_connection()
    try:
        with conn.cursor() as cur:
            # 验证用户是否存在
            cur.execute("SELECT user_id FROM users WHERE user_id = %s", (user_id,))
            user = cur.fetchone()
            if not user:
                return jsonify({'error': '用户不存在'}), 404
            
            # 获取收藏的函数
            sql = """
            SELECT f.func_id, f.func_name, l.lang_name 
            FROM favorites fav 
            JOIN functions f ON fav.func_id = f.func_id 
            JOIN languages l ON f.lang_id = l.lang_id 
            WHERE fav.user_id = %s
            """
            cur.execute(sql, (user_id,))
            favorites = cur.fetchall()
            
            return jsonify(favorites)
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/favorites', methods=['POST'])
def add_favorite():
    # 从请求头获取 token
    token = request.headers.get('Authorization', '').replace('Bearer ', '')
    if not token:
        return jsonify({'error': '缺少认证令牌'}), 401
    
    # 验证 token
    payload = verify_token(token)
    if not payload:
        return jsonify({'error': '无效的认证令牌'}), 401
    
    user_id = payload['user_id']
    
    data = request.get_json()
    func_id = data.get('func_id')
    
    if not func_id:
        return jsonify({'error': '缺少函数ID参数'}), 400
    
    conn = get_db_connection()
    try:
        with conn.cursor() as cur:
            # 验证用户是否存在
            cur.execute("SELECT user_id FROM users WHERE user_id = %s", (user_id,))
            user = cur.fetchone()
            if not user:
                return jsonify({'error': '用户不存在'}), 404
            
            # 添加收藏
            cur.execute("INSERT IGNORE INTO favorites (user_id, func_id) VALUES (%s, %s)", (user_id, func_id))
            
        return jsonify({'message': '收藏添加成功'})
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/favorites/<int:func_id>', methods=['DELETE'])
def remove_favorite(func_id):
    # 从请求头获取 token
    token = request.headers.get('Authorization', '').replace('Bearer ', '')
    if not token:
        return jsonify({'error': '缺少认证令牌'}), 401
    
    # 验证 token
    payload = verify_token(token)
    if not payload:
        return jsonify({'error': '无效的认证令牌'}), 401
    
    user_id = payload['user_id']
    
    conn = get_db_connection()
    try:
        with conn.cursor() as cur:
            # 验证用户是否存在
            cur.execute("SELECT user_id FROM users WHERE user_id = %s", (user_id,))
            user = cur.fetchone()
            if not user:
                return jsonify({'error': '用户不存在'}), 404
            
            # 删除收藏
            cur.execute("DELETE FROM favorites WHERE user_id = %s AND func_id = %s", (user_id, func_id))
            
        return jsonify({'message': '收藏删除成功'})
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/check-email', methods=['POST'])
def check_email():
    data = request.get_json()
    email = data.get('email', '').strip().lower()
    if not email:
        return jsonify({'error': '缺少邮箱参数'}), 400
    
    conn = get_db_connection()
    try:
        with conn.cursor() as cur:
            cur.execute("SELECT user_id FROM users WHERE email = %s", (email,))
            result = cur.fetchone()
            return jsonify({'exists': result is not None})
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/forgot-password', methods=['POST'])
def forgot_password():
    data = request.get_json()
    email = data.get('email', '').strip().lower()
    if not email:
        return jsonify({'error': '缺少邮箱参数'}), 400
    
    conn = get_db_connection()
    try:
        with conn.cursor() as cur:
            # 检查邮箱是否存在
            cur.execute("SELECT user_id FROM users WHERE email = %s", (email,))
            result = cur.fetchone()
            if not result:
                return jsonify({'error': '该邮箱未注册'}), 404
            
            # 生成新密码（简单示例，实际应用中应该发送邮件）
            import random
            import string
            new_password = ''.join(random.choices(string.ascii_letters + string.digits, k=10))
            
            # 确保符合密码要求（至少8位，包含大小写和数字）
            while not (len(new_password) >= 8 and 
                      any(c.islower() for c in new_password) and 
                      any(c.isupper() for c in new_password) and 
                      any(c.isdigit() for c in new_password)):
                new_password = ''.join(random.choices(string.ascii_letters + string.digits, k=10))
            
            # 更新密码
            new_hash = generate_password_hash(new_password)
            cur.execute("UPDATE users SET password_hash = %s WHERE email = %s", (new_hash, email))
            
            # 注意：实际应用中应该发送邮件，这里直接返回新密码用于演示
            return jsonify({
                'message': '新密码已生成并发送到您的邮箱',
                'password': new_password  # 演示用，实际不应该返回
            })
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/delete-account', methods=['DELETE'])
def delete_account():
    # 从请求头获取 token
    token = request.headers.get('Authorization', '').replace('Bearer ', '')
    if not token:
        return jsonify({'error': '缺少认证令牌'}), 401
    
    # 验证 token
    payload = verify_token(token)
    if not payload:
        return jsonify({'error': '无效的认证令牌'}), 401
    
    user_id = payload['user_id']
    
    conn = get_db_connection()
    try:
        with conn.cursor() as cur:
            # 开始事务
            conn.begin()
            
            # 验证用户是否存在
            cur.execute("SELECT user_id FROM users WHERE user_id = %s", (user_id,))
            user = cur.fetchone()
            if not user:
                return jsonify({'error': '用户不存在'}), 404
            
            # 删除用户相关数据
            # 1. 删除收藏
            cur.execute("DELETE FROM favorites WHERE user_id = %s", (user_id,))
            # 2. 删除用户设置
            cur.execute("DELETE FROM user_settings WHERE user_id = %s", (user_id,))
            # 3. 删除用户
            cur.execute("DELETE FROM users WHERE user_id = %s", (user_id,))
            
            # 提交事务
            conn.commit()
            
            return jsonify({'message': '账号已成功注销'})
    except Exception as e:
        # 回滚事务
        conn.rollback()
        return jsonify({'error': str(e)}), 500


@app.route('/api/search', methods=['GET'])
def search():
    lang = request.args.get('lang', 'Python')
    query = request.args.get('query', '').strip()
    if not lang:
        return jsonify({'error': '缺少语言参数'}), 400
    
    try:
        # 导入搜索模块
        import sys
        import os
        sys.path.insert(0, os.path.join(os.getcwd(), 'frontend'))
        from search.try3_2 import IntegratedSyntaxSearch
        
        # 初始化搜索器
        db_config = {
            'host': DB_HOST,
            'user': DB_USER,
            'password': DB_PASSWORD,
            'db': DB_NAME
        }
        search_engine = IntegratedSyntaxSearch(lang_name=lang, db_config=db_config)
        
        # 执行搜索
        results = search_engine.search_func(query=query, fuzzy_threshold=3)
        
        print(f"New search results: {len(results)}")
        
        # 转换为前端需要的格式
        func_list = []
        for func in results:
            func_list.append({
                'id': func['func_id'],  # 使用真正的 func_id
                'name': func['func_name'],
                'description': func.get('func_description', ''),
                'category': func.get('func_category', ''),
                'params': func.get('func_params', ''),
                'return_type': func.get('func_return', ''),
                'example': func.get('func_example_code', ''),
                'notes': func.get('func_notes', ''),
                'relevance': func.get('relevance', 0)
            })
        
        return jsonify({'results': func_list})
    except Exception as e:
        print("New search error:", str(e))
        # 回退到原有的简单搜索
        conn = get_db_connection()
        try:
            with conn.cursor() as cur:
                if query:
                    sql = """
                    SELECT f.func_id, f.func_name 
                    FROM functions f
                    JOIN languages l ON f.lang_id = l.lang_id
                    WHERE l.lang_name = %s AND f.func_name LIKE %s
                    ORDER BY f.func_name
                    """
                    cur.execute(sql, (lang, '%' + query + '%'))
                else:
                    sql = """
                    SELECT f.func_id, f.func_name 
                    FROM functions f
                    JOIN languages l ON f.lang_id = l.lang_id
                    WHERE l.lang_name = %s
                    ORDER BY f.func_name
                    """
                    cur.execute(sql, (lang,))
                results = cur.fetchall()
                func_list = [{'id': row['func_id'], 'name': row['func_name']} for row in results]
                return jsonify({'results': func_list})
        except Exception as e2:
            return jsonify({'error': str(e2)}), 500


@app.route('/api/function/<int:func_id>', methods=['GET'])
def get_function_detail(func_id):
    conn = get_db_connection()
    try:
        with conn.cursor() as cur:
            sql = """
            SELECT 
                l.lang_name,
                f.func_name,
                f.func_category,
                fd.func_params,
                fd.func_return,
                fd.func_description,
                fd.func_example_code,
                fd.func_notes
            FROM function_details fd
            JOIN functions f ON fd.func_id = f.func_id
            JOIN languages l ON f.lang_id = l.lang_id
            WHERE f.func_id = %s
            """
            cur.execute(sql, (func_id,))
            result = cur.fetchone()
            if not result:
                return jsonify({'error': '函数不存在'}), 404
            return jsonify(result)
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/')
def index():
    return send_from_directory(os.path.join(os.getcwd(), 'frontend', 'login'), 'login.html')


@app.route('/main')
def main_page():
    return send_from_directory(os.path.join(os.getcwd(), 'frontend', 'main'), 'index.html')


@app.route('/api/save-all-settings', methods=['POST'])
def save_all_settings():
    """保存所有用户设置（应用关闭时调用）"""
    try:
        # 这里可以添加需要自动保存的逻辑
        # 目前用户设置已经通过 /api/settings PUT 接口保存
        return jsonify({'message': 'Settings save operation completed'})
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/static/<path:filename>')
def serve_static(filename):
    return send_from_directory(os.path.join(os.getcwd(), 'frontend'), filename)


@app.route('/<path:filename>')
def serve_frontend_files(filename):
    # 尝试从多个目录查找文件
    directories = [
        os.path.join(os.getcwd(), 'frontend', 'main'),
        os.path.join(os.getcwd(), 'frontend', 'login'),
        os.path.join(os.getcwd(), 'frontend', 'register'),
        os.path.join(os.getcwd(), 'frontend', 'setting'),
        os.path.join(os.getcwd(), 'frontend', 'picture')
    ]
    
    for directory in directories:
        file_path = os.path.join(directory, filename)
        if os.path.exists(file_path):
            return send_from_directory(directory, filename)
    
    # 如果文件不存在，返回404
    return jsonify({'error': 'File not found'}), 404


# 启动Flask应用
try:
    logger.info("Starting Flask application on http://localhost:5000")
    # 启动前请确保已经执行了 FIRST.sql 导入数据库
    app.run(host='0.0.0.0', port=5000, debug=False)
except Exception as e:
    logger.error(f"Error starting Flask application: {str(e)}")
    logger.error(f"Error type: {type(e).__name__}")
    import traceback
    logger.error(f"Error traceback: {traceback.format_exc()}")
    # 尝试使用不同的端口
    try:
        logger.info("Trying to start on port 5001")
        app.run(host='0.0.0.0', port=5001, debug=False)
    except Exception as e2:
        logger.error(f"Error starting on port 5001: {str(e2)}")
