import pymysql
import os
import datetime

# 数据库连接信息
DB_HOST = 'localhost'
DB_USER = 'root'
DB_PASSWORD = 'Zhchzh100!'
DB_NAME = 'language_function_db'

# 连接数据库
conn = pymysql.connect(
    host=DB_HOST,
    user=DB_USER,
    password=DB_PASSWORD,
    database=DB_NAME,
    charset='utf8mb4',
    cursorclass=pymysql.cursors.DictCursor
)

try:
    with conn.cursor() as cursor:
        # 备份用户设置表
        cursor.execute("SELECT * FROM user_settings")
        user_settings = cursor.fetchall()
        
        # 备份用户表
        cursor.execute("SELECT * FROM users")
        users = cursor.fetchall()
        
        # 生成备份文件名
        backup_dir = 'database/backup'
        os.makedirs(backup_dir, exist_ok=True)
        timestamp = datetime.datetime.now().strftime('%Y%m%d_%H%M%S')
        backup_file = os.path.join(backup_dir, f'backup_{timestamp}.txt')
        
        # 写入备份数据
        with open(backup_file, 'w', encoding='utf-8') as f:
            f.write(f"数据库备份 - {datetime.datetime.now()}\n\n")
            
            f.write("=== 用户表 (users) ===\n")
            for user in users:
                f.write(str(user) + '\n')
            f.write('\n')
            
            f.write("=== 用户设置表 (user_settings) ===\n")
            for setting in user_settings:
                f.write(str(setting) + '\n')
            f.write('\n')
        
        print(f"数据库备份成功，文件保存到: {backup_file}")
        print(f"备份了 {len(users)} 个用户和 {len(user_settings)} 个用户设置")
finally:
    conn.close()