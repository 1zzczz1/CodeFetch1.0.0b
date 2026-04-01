import pymysql
import os

# 数据库配置
DB_HOST = os.environ.get('DB_HOST', 'localhost')
DB_USER = os.environ.get('DB_USER', 'root')
DB_PASSWORD = os.environ.get('DB_PASSWORD', 'Zhchzh100!')
DB_NAME = os.environ.get('DB_NAME', 'language_function_db')

# 连接MySQL（不指定数据库，因为要创建数据库）
connection = pymysql.connect(
    host=DB_HOST,
    user=DB_USER,
    password=DB_PASSWORD,
    charset='utf8mb4',
    autocommit=True
)

try:
    with open('database/sql/all.sql', 'r', encoding='utf-8') as f:
        sql_script = f.read()
    
    # 分割SQL语句（简单分割，可能不完美，但对于这个脚本应该够）
    statements = sql_script.split(';')
    
    with connection.cursor() as cursor:
        for statement in statements:
            statement = statement.strip()
            if statement:
                cursor.execute(statement)
    
    print("数据库初始化成功")
except Exception as e:
    print(f"错误: {e}")
finally:
    connection.close()