USE language_function_db;

-- 修改user_settings表的avatar_url字段类型，从VARCHAR(255)改为LONGTEXT
ALTER TABLE user_settings
MODIFY COLUMN avatar_url LONGTEXT DEFAULT '../picture/头像.jpg' COMMENT '头像URL';

-- 查看修改后的表结构
DESCRIBE user_settings;