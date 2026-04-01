import pymysql

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
        # 修改user_settings表的avatar_url字段类型
        sql = """
        ALTER TABLE user_settings
        MODIFY COLUMN avatar_url LONGTEXT COMMENT '头像URL'
        """
        cursor.execute(sql)
        conn.commit()
        print("成功修改avatar_url字段类型为LONGTEXT")
        
        # 查看修改后的表结构
        cursor.execute("DESCRIBE user_settings")
        result = cursor.fetchall()
        print("\n修改后的表结构:")
        for row in result:
            print(row)
finally:
    conn.close()