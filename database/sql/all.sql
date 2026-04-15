DROP DATABASE IF EXISTS language_function_db;
CREATE DATABASE language_function_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;


CREATE DATABASE IF NOT EXISTS language_function_db 
DEFAULT CHARACTER SET utf8mb4 
DEFAULT COLLATE utf8mb4_unicode_ci;
USE language_function_db;
-- 1. 编程语言表（languages）
CREATE TABLE IF NOT EXISTS languages (
    lang_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '语言唯一ID',
    lang_name VARCHAR(50) NOT NULL COMMENT '编程语言名称（如Python、Java）',
    lang_alias VARCHAR(100) COMMENT '语言别名（如Py、JS）',
    lang_description VARCHAR(500) COMMENT '语言简介',
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    -- 确保语言名称唯一
    UNIQUE KEY uk_lang_name (lang_name)
)  DEFAULT CHARSET=utf8mb4 COMMENT = '编程语言基础信息表';

-- 2. 函数表（functions）
CREATE TABLE IF NOT EXISTS functions (
    func_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '函数唯一ID',
    lang_id INT NOT NULL COMMENT '关联的编程语言ID',
    func_name VARCHAR(100) NOT NULL COMMENT '函数名称（如print、println）',
    func_category VARCHAR(50) COMMENT '函数分类（如字符串、数组、IO）',
    is_common TINYINT DEFAULT 1 COMMENT '是否常用函数 1-是 0-否',
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    -- 外键关联编程语言表
    FOREIGN KEY (lang_id) REFERENCES languages(lang_id) ON DELETE CASCADE ON UPDATE CASCADE,
    -- 联合唯一索引（同一语言下函数名唯一）
    UNIQUE KEY uk_lang_func (lang_id, func_name)
)  DEFAULT CHARSET=utf8mb4 COMMENT = '函数核心信息表';

-- 3. 函数详情表（function_details）
CREATE TABLE IF NOT EXISTS function_details (
    detail_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '详情ID',
    func_id INT NOT NULL COMMENT '关联的函数ID',
    func_params TEXT COMMENT '函数参数（JSON格式）',
    func_return VARCHAR(100) COMMENT '返回值类型',
    func_description VARCHAR(500) COMMENT '函数描述',
    func_example_code TEXT COMMENT '示例代码',
    func_notes VARCHAR(500) COMMENT '注意事项',
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    -- 外键关联函数表
    FOREIGN KEY (func_id) REFERENCES functions(func_id) ON DELETE CASCADE ON UPDATE CASCADE
)  DEFAULT CHARSET=utf8mb4 COMMENT = '函数详细信息表';

-- 4. 用户表（users）
CREATE TABLE IF NOT EXISTS users (
    user_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '用户唯一ID',
    email VARCHAR(100) NOT NULL COMMENT '用户邮箱',
    password_hash VARCHAR(255) NOT NULL COMMENT '哈希后的密码',
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    -- 确保邮箱唯一
    UNIQUE KEY uk_email (email)
)  DEFAULT CHARSET=utf8mb4 COMMENT = '用户信息表';

-- 5. 用户设置表（user_settings）
CREATE TABLE IF NOT EXISTS user_settings (
    user_id INT PRIMARY KEY COMMENT '用户ID，与users表关联',
    username VARCHAR(50) COMMENT '用户名',
    avatar_url VARCHAR(255) DEFAULT '../picture/头像.jpg' COMMENT '头像URL',
    font_size INT DEFAULT 16 COMMENT '文字大小（像素）',
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    -- 外键关联用户表
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE
) DEFAULT CHARSET=utf8mb4 COMMENT = '用户个性化设置表';

-- 6. 用户收藏表（favorites）
CREATE TABLE IF NOT EXISTS favorites (
    favorite_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '收藏ID',
    user_id INT NOT NULL COMMENT '用户ID',
    func_id INT NOT NULL COMMENT '函数ID',
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    -- 外键关联
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (func_id) REFERENCES functions(func_id) ON DELETE CASCADE,
    -- 联合唯一索引（同一用户不能重复收藏同一函数）
    UNIQUE KEY uk_user_func (user_id, func_id)
) DEFAULT CHARSET=utf8mb4 COMMENT = '用户收藏函数表';
-- 插入编程语言
INSERT INTO languages (lang_name, lang_alias, lang_description) VALUES
('Python', 'Py', '解释型、面向对象的高级编程语言'),
('Java', 'Java', '面向对象、跨平台的编程语言'),
('JavaScript', 'JS', '前端脚本语言，也可用于后端(Node.js)');
UPDATE languages
SET lang_name = 'C++',
    lang_alias = 'C++',
    lang_description = '面向对象、高性能的系统级编程语言'
WHERE lang_name = 'Java';
select * from languages;
-- 插入Python函数
INSERT INTO functions (lang_id, func_name, func_category, is_common) VALUES
(1,'print','输入输出',1),
(1, 'len', '内置函数', 1),
-- 字符串处理类
(1, 'str', '字符串', 1),
(1, 'split', '字符串', 1),
(1, 'join', '字符串', 1),
(1, 'strip', '字符串', 1),
-- 列表处理类
(1, 'list', '列表', 1),
(1, 'append', '列表', 1),
(1, 'extend', '列表', 1),
(1, 'pop', '列表', 1),
-- 字典处理类
(1, 'dict', '字典', 1),
(1, 'keys', '字典', 1),
(1, 'values', '字典', 1),
-- 数学计算类
(1, 'range', '数学', 1),
(1, 'sum', '数学', 1),
(1, 'max', '数学', 1),
(1, 'min', '数学', 1),
-- 文件操作类
(1, 'open', '文件操作', 1),
-- 集合处理类
(1, 'set', '集合', 1),
(1, 'add', '集合', 1),
(1, 'remove', '集合', 1),
(1, 'union', '集合', 1),
-- 时间处理类

(1, 'datetime.now', '时间处理', 1),

(1, 'datetime.strftime', '时间处理', 1),

-- 异常处理类

(1, 'try-except', '异常处理', 1),

-- 其他常用内置函数

(1, 'type', '内置函数', 1),

(1, 'isinstance', '内置函数', 1),

(1, 'sorted', '内置函数', 1),

(1, 'map', '内置函数', 1),

(1, 'filter', '内置函数', 1),

(1, 'zip', '内置函数', 1),

(1, 'enumerate', '内置函数', 1),

-- 字符串进阶处理

(1, 'lower', '字符串', 1),

(1, 'upper', '字符串', 1),

(1, 'replace', '字符串', 1),

(1, 'find', '字符串', 1),

-- 列表进阶处理

(1, 'sort', '列表', 1),

(1, 'reverse', '列表', 1),

(1, 'index', '列表', 1),

(1, 'count', '列表', 1);
-- Python特有/差异关键字（lang_id=1，func_id=111-119）
INSERT INTO functions (lang_id, func_name, func_category, is_common)
VALUES 
(1, 'elif', '流程控制-分支', 1),          -- 111：Python特有的多分支（C++用else if）
(1, 'lambda', '语法-匿名函数', 1),       -- 112：Python特有匿名函数（C++无等价关键字）
(1, 'yield', '流程控制-生成器', 1),      -- 113：Python生成器（C++无等价关键字）
(1, 'with', '语法-上下文管理', 1),       -- 114：Python资源管理（C++用RAII/析构函数）
(1, 'in', '逻辑判断-成员检测', 1),       -- 115：Python成员判断（C++用find/循环）
(1, 'is', '逻辑判断-身份比较', 1),       -- 116：Python身份比较（C++用==/指针比较）
(1, 'None', '语法-空值', 1),             -- 117：Python空值（C++用NULL/nullptr）
(1, 'global', '语法-作用域', 1),         -- 118：Python全局变量（C++用全局/extern）
(1, 'nonlocal', '语法-作用域', 1);       -- 119：Python嵌套作用域（C++无等价关键字）

-- Python常用基础关键字（lang_id=1，func_id=120-128）
INSERT INTO functions (lang_id, func_name, func_category, is_common)
VALUES 
(1, 'if', '流程控制-分支', 1),          -- 120：条件分支（基础）
(1, 'else', '流程控制-分支', 1),        -- 121：条件分支（基础）
(1, 'for', '流程控制-循环', 1),         -- 122：遍历循环（基础）
(1, 'while', '流程控制-循环', 1),       -- 123：条件循环（基础）
(1, 'break', '流程控制-跳转', 1),       -- 124：跳出循环（基础）
(1, 'continue', '流程控制-跳转', 1),    -- 125：跳过本次循环（基础）
(1, 'def', '语法-函数定义', 1),        -- 126：函数定义（核心）
(1, 'class', '语法-类定义', 1),        -- 127：类定义（面向对象）
(1, 'import', '语法-模块导入', 1);     -- 128：模块导入（基础）


-- 插入C++函数
INSERT INTO functions (lang_id, func_name, func_category, is_common) VALUES
-- 输入输出类
(2, 'printf', '输入输出', 1),
(2, 'scanf', '输入输出', 1),
(2, 'getline', '输入输出', 1),
(2, 'cin.get', '输入输出', 1),
(2, 'cout.put', '输入输出', 1),
-- 字符串处理类（C风格）
(2, 'strlen', '字符串', 1),
(2, 'strcpy', '字符串', 1),
(2, 'strcat', '字符串', 1),
(2, 'strcmp', '字符串', 1),
(2, 'strchr', '字符串', 1),
(2, 'strstr', '字符串', 1),
(2, 'to_string', '字符串', 1),
(2, 'stoi', '字符串', 1),
(2, 'stof', '字符串', 1),
-- 数学计算类
(2, 'abs', '数学', 1),
(2, 'fabs', '数学', 1),
(2, 'sqrt', '数学', 1),
(2, 'pow', '数学', 1),
(2, 'sin', '数学', 1),
(2, 'cos', '数学', 1),
(2, 'tan', '数学', 1),
(2, 'log', '数学', 1),
(2, 'log10', '数学', 1),
(2, 'max', '数学', 1),
(2, 'min', '数学', 1),
-- 容器类（STL）
(2, 'vector.push_back', '容器', 1),
(2, 'vector.pop_back', '容器', 1),
(2, 'vector.size', '容器', 1),
(2, 'vector.empty', '容器', 1),
(2, 'vector.clear', '容器', 1),
(2, 'map.insert', '容器', 1),
(2, 'map.find', '容器', 1),
(2, 'map.erase', '容器', 1),
(2, 'map.size', '容器', 1),
(2, 'string.length', '容器', 1),
(2, 'string.append', '容器', 1),
(2, 'string.substr', '容器', 1),
(2, 'string.find', '容器', 1),
(2, 'string.replace', '容器', 1),
-- 内存管理
(2, 'malloc', '内存管理', 1),
(2, 'free', '内存管理', 1),
(2, 'new', '内存管理', 1),
(2, 'delete', '内存管理', 1),
-- 时间处理
(2, 'time', '时间处理', 1),
(2, 'clock', '时间处理', 1),
-- 算法（STL）
(2, 'sort', '算法', 1),
(2, 'find', '算法', 1),
(2, 'reverse', '算法', 1),
(2, 'swap', '算法', 1),
(2, 'accumulate', '算法', 1),
-- 类型转换
(2, 'static_cast', '类型转换', 1),
(2, 'dynamic_cast', '类型转换', 1),
(2, 'reinterpret_cast', '类型转换', 1),
(2, 'const_cast', '类型转换', 1);
INSERT INTO functions (lang_id, func_name, func_category, is_common) VALUES
(2, 'cin', '输入输出', 1),
(2, 'cout', '输入输出', 1);
-- 插入流程控制关键字到functions表（假设func_id依次为4、5、6、7，可根据实际自增调整）
INSERT INTO functions (lang_id, func_name, func_category, is_common)
VALUES 
(2, 'for', '流程控制-循环', 1),     -- for循环（func_id=4）
(2, 'if', '流程控制-分支', 1),      -- if分支（func_id=5）
(2, 'while', '流程控制-循环', 1),   -- while循环（func_id=6）
(2, 'switch', '流程控制-分支', 1);  -- switch分支（func_id=7）
-- 新增语法关键字到functions表（lang_id=3对应C++，func_id从101开始）
INSERT INTO functions (lang_id, func_name, func_category, is_common)
VALUES 
(2, 'do-while', '流程控制-循环', 1),       -- 101：do-while循环
(2, 'break', '流程控制-跳转', 1),          -- 102：break跳转
(2, 'continue', '流程控制-跳转', 1),       -- 103：continue跳转
(2, 'return', '流程控制-返回', 1),         -- 104：return返回
(2, 'class', '面向对象-类', 1),            -- 105：类定义
(2, 'namespace', '语法-命名空间', 1),      -- 106：命名空间
(2, 'const', '语法-常量修饰', 1),          -- 107：常量修饰符
(2, 'static', '语法-存储类型', 1),         -- 108：静态修饰符
(2, 'int', '语法-基本类型', 1),            -- 109：整型
(2, 'string', '语法-字符串类型', 1);       -- 110：字符串类型（STL）

SELECT * FROM functions;
-- 插入Python print函数详情
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(1, 
 '{"name":"*objects","type":"任意类型","desc":"要打印的对象"},{"name":"sep","type":"str","desc":"分隔符，默认空格"},{"name":"end","type":"str","desc":"结束符，默认换行"}]',
 'None：无返回值',
 '将指定的对象打印到标准输出设备（屏幕）',
 'print("Hello World!")\nprint(1, 2, 3, sep="-")',
 '在Python 2中print是语句，Python 3中是函数');

-- 插入Python len函数详情
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(2,
 '[{"name":"obj","type":"序列/集合","desc":"要计算长度的对象"}]',
 'int：返回对象的长度',
 '返回对象（字符串、列表、元组等）的元素个数',
 'print(len("Python"))  # 输出6\nprint(len([1,2,3]))  # 输出3',
 '不能用于计算数值类型（如int、float）的长度，会报错');
 -- str函数 (func_id=3)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(3,
 '[{"name":"object","type":"任意类型","desc":"要转换为字符串的对象"},{"name":"encoding","type":"str","desc":"编码格式，可选"},{"name":"errors","type":"str","desc":"错误处理方式，可选"}]',
 'str：返回对象的字符串表示形式',
 '将指定对象转换为字符串类型，是Python内置的类型转换函数',
 'num = 123\nstr_num = str(num)\nprint(type(str_num))  # 输出 <class ''str''> \nprint(str([1,2,3]))  # 输出 [1, 2, 3]',
 '对于自定义对象，会调用对象的__str__方法；编码参数主要用于处理字节串转换');

-- split函数 (func_id=4)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(4,
 '[{"name":"sep","type":"str","desc":"分隔符，默认按空白字符分割"},{"name":"maxsplit","type":"int","desc":"最大分割次数，默认-1（无限制）"}]',
 'list：返回分割后的字符串列表',
 '将字符串按照指定分隔符分割成列表，是字符串的内置方法',
 's = "Python is fun"\nprint(s.split())  # 输出 [''Python'', ''is'', ''fun'']\nprint(s.split(" ", 1))  # 输出 [''Python'', ''is fun'']',
 '如果sep为空字符串会报错；maxsplit为0时不分割；分割符不存在则返回包含原字符串的单元素列表');

-- join函数 (func_id=5)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(5,
 '[{"name":"iterable","type":"可迭代对象","desc":"包含字符串的可迭代对象（列表、元组等）"}]',
 'str：返回拼接后的字符串',
 '将可迭代对象中的字符串元素，通过调用该方法的字符串作为分隔符拼接成一个新字符串',
 'lst = ["Python", "Java", "JS"]\nprint("-".join(lst))  # 输出 Python-Java-JS\nprint("".join(lst))  # 输出 PythonJavaJS',
 '可迭代对象中的元素必须都是字符串类型，否则会报错；空字符串join空列表返回空字符串');

-- strip函数 (func_id=6)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(6,
 '[{"name":"chars","type":"str","desc":"要移除的字符集，默认移除首尾空白字符"}]',
 'str：返回移除指定字符后的新字符串',
 '移除字符串首尾的指定字符（默认是空格、换行、制表符等空白字符），不改变原字符串',
 's = "  hello world  "\nprint(s.strip())  # 输出 hello world\ns2 = "###Python###"\nprint(s2.strip("#"))  # 输出 Python',
 '仅移除首尾字符，中间的不会移除；chars参数是字符集，不是固定字符串（如strip("ab")会移除a或b）');

--  list函数 (func_id=7)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(7,
 '[{"name":"iterable","type":"可迭代对象","desc":"可选，要转换为列表的可迭代对象（字符串、元组、字典等）"}]',
 'list：返回新的列表对象',
 '创建一个新的列表，若传入可迭代对象则将其元素转为列表，无参数则创建空列表',
 'print(list())  # 输出 []\nprint(list("Python"))  # 输出 [''P'', ''y'', ''t'', ''h'', ''o'', ''n'']\nprint(list((1,2,3)))  # 输出 [1, 2, 3]',
 '字典作为参数时，只取键（key）转换为列表；生成器等一次性可迭代对象转换后会被消耗');

--  append函数 (func_id=8)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(8,
 '[{"name":"object","type":"任意类型","desc":"要添加到列表末尾的对象"}]',
 'None：无返回值',
 '向列表的末尾添加一个元素，直接修改原列表，是列表的内置方法',
 'lst = [1,2,3]\nlst.append(4)\nprint(lst)  # 输出 [1, 2, 3, 4]\nlst.append([5,6])\nprint(lst)  # 输出 [1, 2, 3, 4, [5, 6]]',
 '每次只能添加一个元素；添加的元素可以是任意类型（包括列表、字典等）；和extend的区别是append添加整体，extend添加元素');

--  extend函数 (func_id=9)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(9,
 '[{"name":"iterable","type":"可迭代对象","desc":"要添加到列表末尾的可迭代对象"}]',
 'None：无返回值',
 '将可迭代对象中的所有元素依次添加到列表末尾，直接修改原列表',
 'lst = [1,2,3]\nlst.extend([4,5])\nprint(lst)  # 输出 [1, 2, 3, 4, 5]\nlst.extend("67")\nprint(lst)  # 输出 [1, 2, 3, 4, 5, ''6'', ''7'']',
 '参数必须是可迭代对象；和append的区别：extend拆分为单个元素添加，append添加整体');

--  pop函数 (func_id=10)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(10,
 '[{"name":"index","type":"int","desc":"可选，要删除的元素索引，默认-1（最后一个元素）"}]',
 '任意类型：返回被删除的元素',
 '删除列表中指定索引的元素并返回该元素，直接修改原列表',
 'lst = [1,2,3,4]\nprint(lst.pop())  # 输出 4\nprint(lst)  # 输出 [1, 2, 3]\nprint(lst.pop(0))  # 输出 1\nprint(lst)  # 输出 [2, 3]',
 '索引超出列表范围会报IndexError；无参数时删除最后一个元素；空列表调用pop会报错');

--  dict函数 (func_id=11)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(11,
 '[{"name":"**kwargs","type":"键值对","desc":"可选，直接传入键值对"},{"name":"mapping","type":"映射对象","desc":"可选，如字典、元组列表等"}]',
 'dict：返回新的字典对象',
 '创建一个新的字典对象，支持多种参数形式初始化字典',
 'd1 = dict(name="Python", version=3.10)\nprint(d1)  # 输出 {''name'': ''Python'', ''version'': 3.10}\nd2 = dict([("a",1), ("b",2)])\nprint(d2)  # 输出 {''a'': 1, ''b'': 2}',
 '键必须是不可变类型（字符串、数字、元组）；重复的键会被最后一个值覆盖');

--  keys函数 (func_id=12)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(12,
 '[]',
 'dict_keys：返回包含字典所有键的可迭代对象',
 '获取字典中所有的键，返回的dict_keys对象可转换为列表使用',
 'd = {"name":"Python", "type":"language"}\nprint(d.keys())  # 输出 dict_keys([''name'', ''type''])\nprint(list(d.keys()))  # 输出 [''name'', ''type'']',
 '返回的对象是动态的，原字典修改后会同步变化；Python3中keys()返回视图对象，Python2中返回列表');

--  values函数 (func_id=13)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(13,
 '[]',
 'dict_values：返回包含字典所有值的可迭代对象',
 '获取字典中所有的值，返回的dict_values对象可转换为列表使用',
 'd = {"name":"Python", "type":"language"}\nprint(d.values())  # 输出 dict_values([''Python'', ''language''])\nprint(list(d.values()))  # 输出 [''Python'', ''language'']',
 '返回的对象是动态的，原字典修改后会同步变化；值可以是任意类型；无法通过values()直接修改原字典的值');

--  range函数 (func_id=14)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(14,
 '[{"name":"start","type":"int","desc":"起始值，默认0"},{"name":"stop","type":"int","desc":"结束值（不包含）"},{"name":"step","type":"int","desc":"步长，默认1"}]',
 'range：返回一个整数序列的可迭代对象',
 '生成一个整数序列，常用于for循环中指定循环次数，Python3中返回range对象，Python2中返回列表',
 'print(list(range(5)))  # 输出 [0, 1, 2, 3, 4]\nprint(list(range(1,6,2)))  # 输出 [1, 3, 5]',
 'stop参数是必须的（单独使用时）；step不能为0，否则报错；range对象是不可变的序列类型');

--  sum函数 (func_id=15)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(15,
 '[{"name":"iterable","type":"可迭代对象","desc":"包含数字的可迭代对象"},{"name":"start","type":"int/float","desc":"起始值，默认0"}]',
 'int/float：返回可迭代对象元素的总和',
 '计算可迭代对象中所有数字元素的总和，可选起始值会被加到总和中',
 'print(sum([1,2,3]))  # 输出 6\nprint(sum((1,2,3), 10))  # 输出 16\nprint(sum([0.1,0.2]))  # 输出 0.30000000000000004（浮点精度问题）',
 '可迭代对象必须包含数字类型；字符串等非数字类型会报错；浮点型求和可能有精度问题，可使用decimal模块解决');

--  max函数 (func_id=16)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(16,
 '[{"name":"iterable","type":"可迭代对象","desc":"要查找最大值的可迭代对象"},{"name":"*args","type":"多个参数","desc":"直接传入多个值"},{"name":"key","type":"函数","desc":"可选，用于比较的键函数"}]',
 '任意类型：返回可迭代对象/参数中的最大值',
 '返回可迭代对象中的最大值，或多个参数中的最大值，支持自定义比较规则',
 'print(max([1,5,3]))  # 输出 5\nprint(max("Python"))  # 输出 ''y''\nprint(max([(1,3), (2,2)], key=lambda x:x[1]))  # 输出 (1, 3)',
 '空可迭代对象会报ValueError；不同类型（如int和str）直接比较会报错；key参数用于指定比较的依据');

--  min函数 (func_id=17)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(17,
 '[{"name":"iterable","type":"可迭代对象","desc":"要查找最小值的可迭代对象"},{"name":"*args","type":"多个参数","desc":"直接传入多个值"},{"name":"key","type":"函数","desc":"可选，用于比较的键函数"}]',
 '任意类型：返回可迭代对象/参数中的最小值',
 '返回可迭代对象中的最小值，或多个参数中的最小值，支持自定义比较规则',
 'print(min([1,5,3]))  # 输出 1\nprint(min("Python"))  # 输出 ''P''\nprint(min([(1,3), (2,2)], key=lambda x:x[1]))  # 输出 (2, 2)',
 '空可迭代对象会报ValueError；不同类型（如int和str）直接比较会报错；key参数用法和max一致');

--  open函数 (func_id=18)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(18,
 '[{"name":"file","type":"str/path","desc":"文件路径"},{"name":"mode","type":"str","desc":"打开模式，默认''r''"},{"name":"encoding","type":"str","desc":"编码格式，可选"},{"name":"newline","type":"str","desc":"换行符处理，可选"}]',
 '_io.TextIOWrapper：返回文件对象（文件句柄）',
 '打开一个文件并返回对应的文件对象，是Python进行文件读写的核心函数',
 '# 读取文件\nwith open("test.txt", "r", encoding="utf-8") as f:\n    content = f.read()\n    print(content)\n# 写入文件\nwith open("test.txt", "w", encoding="utf-8") as f:\n    f.write("Hello Python!")',
 '常用mode：r(读)、w(写，覆盖)、a(追加)、r+(读写)、b(二进制模式)；推荐使用with语句自动关闭文件；编码参数在文本模式下才有效');
 --  set函数 
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES

(19,

'[{"name":"iterable","type":"可迭代对象","desc":"可选，要转换为集合的可迭代对象（字符串、列表、元组等）"}]',

'set：返回新的集合对象',

'创建一个新的集合，集合是无序、不重复的元素集合，若传入可迭代对象则去重后转为集合，无参数则创建空集合',

'print(set())  # 输出 set()\nprint(set([1,2,2,3]))  # 输出 {1, 2, 3}\nprint(set("Python"))  # 输出 {''P'', ''y'', ''t'', ''h'', ''o'', ''n''}',

'集合元素必须是不可变类型（字符串、数字、元组）；集合无序，无法通过索引访问；自动去重，重复元素会被合并');

-- 5. add函数（集合方法） 
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES

(20,

'[{"name":"element","type":"不可变类型","desc":"要添加到集合的元素"}]',

'None：无返回值',

'向集合中添加一个元素，直接修改原集合，若元素已存在则不做任何操作，是集合的内置方法',

's = {1,2,3}\ns.add(4)\nprint(s)  # 输出 {1, 2, 3, 4}\ns.add(2)\nprint(s)  # 输出 {1, 2, 3, 4}（无变化）',

'添加的元素必须是不可变类型（不能添加列表、字典等可变类型）；添加重复元素不会报错，也不会改变集合');

-- 6. remove函数（集合方法）
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES

(21,

'[{"name":"element","type":"不可变类型","desc":"要从集合中删除的元素"}]',

'None：无返回值',

'从集合中删除指定元素，直接修改原集合，是集合的内置方法',

's = {1,2,3,4}\ns.remove(3)\nprint(s)  # 输出 {1, 2, 4}',

'元素不存在会报KeyError；删除的元素必须是不可变类型；和discard的区别：remove报错，discard不报错');

-- 7. union函数（集合方法） 
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES

(22,

'[{"name":"other_set","type":"集合","desc":"要合并的另一个集合"}]',

'set：返回两个集合的并集（包含两个集合的所有元素，去重）',

'求两个集合的并集，返回一个新集合，不修改原集合，也可使用运算符|实现',

's1 = {1,2,3}\ns2 = {3,4,5}\nprint(s1.union(s2))  # 输出 {1, 2, 3, 4, 5}\nprint(s1 | s2)  # 输出 {1, 2, 3, 4, 5}',

'并集会自动去重；参数可以是多个集合（用逗号分隔）；原集合不会被修改');

-- 8. datetime.now函数 
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES

(23,

'[]',

'datetime.datetime：返回当前本地时间的datetime对象',

'获取当前本地的日期和时间，返回datetime对象，需先导入datetime模块，是时间处理的常用函数',

'import datetime\nnow = datetime.datetime.now()\nprint(now)  # 输出 2026-02-26 15:30:00（示例）\nprint(type(now))  # 输出 <class ''datetime.datetime''> ',

'使用前必须导入datetime模块；返回的datetime对象可通过属性获取年、月、日、时、分、秒（如now.year）');

-- 9. datetime.strftime函数 
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES

(24,

'[{"name":"format","type":"str","desc":"时间格式化字符串（如%Y-%m-%d %H:%M:%S）"}]',

'str：返回格式化后的时间字符串',

'将datetime对象按照指定的格式转换为字符串，是datetime对象的内置方法，需先导入datetime模块',

'import datetime\nnow = datetime.datetime.now()\nprint(now.strftime("%Y-%m-%d"))  # 输出 2026-02-26\nprint(now.strftime("%H:%M:%S"))  # 输出 15:30:00',

'常用格式化符号：%Y（4位年份）、%m（2位月份）、%d（2位日期）、%H（24小时制）、%M（分钟）、%S（秒）；格式错误会报ValueError');

-- 10. try-except（异常处理） 
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES

(25,

'[{"name":"try_block","type":"代码块","desc":"可能出现异常的代码"},{"name":"except_block","type":"代码块","desc":"异常发生时执行的代码"},{"name":"else_block","type":"代码块","desc":"可选，无异常时执行"},{"name":"finally_block","type":"代码块","desc":"可选，无论是否异常都执行"}]',

'None：无返回值（除非在代码块中return）',

'Python的异常处理机制，用于捕获和处理代码运行中的异常，避免程序崩溃，提高程序健壮性',

'try:\n    num = int(input("请输入数字："))\n    print(10 / num)\nexcept ValueError:\n    print("输入错误，请输入整数")\nexcept ZeroDivisionError:\n    print("除数不能为0")\nelse:\n    print("运行成功")\nfinally:\n    print("程序结束")',

'可以捕获多个异常（用多个except）；except后可省略异常类型，捕获所有异常（不推荐）；finally块无论是否发生异常都会执行，常用于释放资源');

-- 11. type函数 
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES

(26,

'[{"name":"object","type":"任意类型","desc":"要查看类型的对象"}]',

'type：返回对象的类型',

'查看指定对象的类型，返回type对象，是Python内置函数，常用于调试和类型判断',

'print(type(123))  # 输出 <class ''int''> \nprint(type("Python"))  # 输出 <class ''str''> \nprint(type([1,2,3]))  # 输出 <class ''list''> ',

'type和isinstance的区别：type只判断当前类型，isinstance判断是否是指定类型或其子类；type也可用于创建类');

-- 12. isinstance函数 

INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES

(27,

'[{"name":"object","type":"任意类型","desc":"要判断类型的对象"},{"name":"classinfo","type":"类型/类型元组","desc":"要判断的类型（可多个）"}]',

'bool：返回True（是指定类型）或False（不是）',

'判断对象是否是指定类型或其子类的实例，支持同时判断多个类型，是Python内置函数，比type更灵活',

'print(isinstance(123, int))  # 输出 True\nprint(isinstance("Python", (str, int)))  # 输出 True\nprint(isinstance([1,2,3], tuple))  # 输出 False',

'classinfo可以是单个类型，也可以是多个类型组成的元组；支持继承关系（如bool是int的子类，isinstance(True, int)返回True）');

-- 13. sorted函数 

INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES

(28,

'[{"name":"iterable","type":"可迭代对象","desc":"要排序的可迭代对象"},{"name":"key","type":"函数","desc":"可选，排序依据的函数"},{"name":"reverse","type":"bool","desc":"可选，是否降序，默认False（升序）"}]',

'list：返回排序后的新列表',

'对可迭代对象进行排序，返回一个新的排序后列表，不修改原可迭代对象，支持自定义排序规则',

'lst = [3,1,4,2]\nprint(sorted(lst))  # 输出 [1, 2, 3, 4]\nprint(sorted(lst, reverse=True))  # 输出 [4, 3, 2, 1]\nprint(sorted(["apple", "banana"], key=len))  # 输出 [''apple'', ''banana'']',

'sorted返回新列表，原对象不变；列表的sort方法修改原列表，无返回值；key参数用于指定排序依据，reverse参数控制升序/降序');

-- 14. map函数 

INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES

(29,

'[{"name":"function","type":"函数","desc":"要应用到每个元素的函数"},{"name":"*iterables","type":"可迭代对象","desc":"一个或多个可迭代对象"}]',

'map：返回一个map对象（可迭代）',

'将指定函数应用到可迭代对象的每个元素上，返回一个map可迭代对象，可转换为列表、元组等，常用于批量处理元素',

'def add_one(x):\n    return x + 1\nlst = [1,2,3]\nresult = map(add_one, lst)\nprint(list(result))  # 输出 [2, 3, 4]\n# 匿名函数用法\nprint(list(map(lambda x: x*2, [1,2,3])))  # 输出 [2, 4, 6]',

'map对象是一次性可迭代对象，遍历后会被消耗；多个可迭代对象长度不一致时，以最短的为准，剩余元素忽略；函数参数个数需和可迭代对象个数一致');

-- 15. filter函数 

INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES

(30,

'[{"name":"function","type":"函数","desc":"用于筛选的函数（返回bool值）"},{"name":"iterable","type":"可迭代对象","desc":"要筛选的可迭代对象"}]',

'filter：返回一个filter对象（可迭代）',

'使用指定函数筛选可迭代对象中的元素，函数返回True的元素会被保留，返回False的元素会被过滤，返回filter可迭代对象',

'def is_even(x):\n    return x % 2 == 0\nlst = [1,2,3,4,5]\nresult = filter(is_even, lst)\nprint(list(result))  # 输出 [2, 4]\n# 匿名函数用法\nprint(list(filter(lambda x: x>3, [1,2,3,4,5])))  # 输出 [4, 5]',

'filter对象是一次性可迭代对象；函数返回值必须是bool类型（或可转换为bool的类型）；函数为None时，直接筛选出布尔值为True的元素');

-- 16. zip函数 

INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES

(31,

'[{"name":"*iterables","type":"可迭代对象","desc":"一个或多个可迭代对象"}]',

'zip：返回一个zip对象（可迭代），元素为元组',

'将多个可迭代对象的对应位置元素打包成元组，返回zip可迭代对象，常用于多组数据的配对',

'lst1 = [1,2,3]\nlst2 = ["a","b","c"]\nresult = zip(lst1, lst2)\nprint(list(result))  # 输出 [(1, ''a''), (2, ''b''), (3, ''c'')]\n# 多个可迭代对象\nprint(list(zip([1,2], [3,4], [5,6])))  # 输出 [(1, 3, 5), (2, 4, 6)]',

'zip对象是一次性可迭代对象；多个可迭代对象长度不一致时，以最短的为准；可使用zip(*zip_obj)反向解压');

-- 17. enumerate函数 

INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES

(32,

'[{"name":"iterable","type":"可迭代对象","desc":"要枚举的可迭代对象"},{"name":"start","type":"int","desc":"可选，起始索引，默认0"}]',

'enumerate：返回一个enumerate对象（可迭代），元素为(索引, 元素)元组',

'将可迭代对象的元素和其索引打包，返回enumerate可迭代对象，常用于for循环中同时获取索引和元素',

'lst = ["a","b","c"]\nfor idx, val in enumerate(lst):\n    print(idx, val)  # 输出 0 a、1 b、2 c\n# 指定起始索引\nfor idx, val in enumerate(lst, start=1):\n    print(idx, val)  # 输出 1 a、2 b、3 c',

'enumerate对象是一次性可迭代对象；start参数用于指定索引的起始值，默认从0开始；比手动维护索引更简洁');

-- 18. lower函数（字符串方法） 

INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES

(33,

'[]',

'str：返回所有字符转为小写的新字符串',

'将字符串中的所有大写字母转为小写，不改变原字符串，非字母字符保持不变，是字符串的内置方法',

's = "Python IS Fun"\nprint(s.lower())  # 输出 ''python is fun''\nprint(s)  # 输出 ''Python IS Fun''（原字符串不变）',

'只转换大写字母，小写字母和非字母字符无变化；不修改原字符串，返回新字符串；和upper函数互为逆操作');

-- 19. upper函数（字符串方法）

INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES

(34,

'[]',

'str：返回所有字符转为大写的新字符串',

'将字符串中的所有小写字母转为大写，不改变原字符串，非字母字符保持不变，是字符串的内置方法',

's = "Python IS Fun"\nprint(s.upper())  # 输出 ''PYTHON IS FUN''\nprint(s)  # 输出 ''Python IS Fun''（原字符串不变）',

'只转换小写字母，大写字母和非字母字符无变化；不修改原字符串，返回新字符串；常用于统一字符串大小写（如验证码校验）');

-- 20. replace函数（字符串方法）

INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES

(35,

'[{"name":"old","type":"str","desc":"要替换的子字符串"},{"name":"new","type":"str","desc":"替换后的子字符串"},{"name":"count","type":"int","desc":"可选，替换次数，默认-1（全部替换）"}]',

'str：返回替换后的新字符串',

'将字符串中的指定子字符串替换为新的子字符串，支持指定替换次数，不改变原字符串，是字符串的内置方法',

's = "Python Python Python"\nprint(s.replace("Python", "Java"))  # 输出 ''Java Java Java''\nprint(s.replace("Python", "Java", 2))  # 输出 ''Java Java Python''',

'不修改原字符串，返回新字符串；old子字符串不存在时，返回原字符串；count参数为0时不进行替换；替换区分大小写');

-- 21. find函数（字符串方法）

INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES

(36,

'[{"name":"sub","type":"str","desc":"要查找的子字符串"},{"name":"start","type":"int","desc":"可选，查找起始索引，默认0"},{"name":"end","type":"int","desc":"可选，查找结束索引，默认字符串长度"}]',

'int：返回子字符串第一次出现的索引，不存在则返回-1',

'查找指定子字符串在原字符串中第一次出现的索引，支持指定查找范围，不修改原字符串，是字符串的内置方法',

's = "Python is fun, Python is easy"\nprint(s.find("Python"))  # 输出 0\nprint(s.find("Python", 10))  # 输出 14\nprint(s.find("Java"))  # 输出 -1',

'和index函数的区别：find返回-1（不存在），index报ValueError；start和end参数限定查找范围，左闭右开；区分大小写');

-- 22. sort函数（列表方法） 

INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES

(37,

'[{"name":"key","type":"函数","desc":"可选，排序依据的函数"},{"name":"reverse","type":"bool","desc":"可选，是否降序，默认False（升序）"}]',

'None：无返回值',

'对列表进行排序，直接修改原列表，支持自定义排序规则，是列表的内置方法，和sorted函数功能类似但不返回新列表',

'lst = [3,1,4,2]\nlst.sort()\nprint(lst)  # 输出 [1, 2, 3, 4]\nlst.sort(reverse=True)\nprint(lst)  # 输出 [4, 3, 2, 1]\nlst.sort(key=lambda x: -x)\nprint(lst)  # 输出 [4, 3, 2, 1]',

'直接修改原列表，无返回值（返回None）；不可用于元组、字符串等不可变序列；key和reverse参数用法和sorted一致');

-- 23. reverse函数（列表方法）

INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES

(38,

'[]',

'None：无返回值',

'将列表中的元素反转顺序，直接修改原列表，不返回新列表，是列表的内置方法',

'lst = [1,2,3,4]\nlst.reverse()\nprint(lst)  # 输出 [4, 3, 2, 1]',

'直接修改原列表，无返回值；和切片lst[::-1]的区别：reverse修改原列表，切片返回新列表；空列表调用reverse无变化');

-- 24. index函数（列表方法） 

INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES

(39,

'[{"name":"value","type":"任意类型","desc":"要查找索引的元素"},{"name":"start","type":"int","desc":"可选，查找起始索引，默认0"},{"name":"end","type":"int","desc":"可选，查找结束索引，默认列表长度"}]',

'int：返回元素在列表中第一次出现的索引',

'查找指定元素在列表中第一次出现的索引，支持指定查找范围，直接修改原列表（无修改，仅查询），是列表的内置方法',

'lst = [1,2,3,2,4]\nprint(lst.index(2))  # 输出 1\nprint(lst.index(2, 2))  # 输出 3',

'元素不存在会报ValueError；start和end参数限定查找范围，左闭右开；索引从0开始；和元组的index方法用法一致');

-- 25. count函数（列表方法） 

INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES

(40,

'[{"name":"value","type":"任意类型","desc":"要统计出现次数的元素"}]',

'int：返回元素在列表中出现的次数',

'统计指定元素在列表中出现的次数，若元素不存在则返回0，直接修改原列表（无修改，仅查询），是列表的内置方法',

'lst = [1,2,3,2,4,2]\nprint(lst.count(2))  # 输出 3\nprint(lst.count(5))  # 输出 0',

'统计的元素类型必须和列表中的元素类型一致；空列表调用count返回0；和元组的count方法用法一致');
 -- 插入C++函数详情
-- 1. printf (func_id=41)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(41,
 '[{"name":"format","type":"const char*","desc":"格式控制字符串"},{"name":"...","type":"可变参数","desc":"要输出的变量列表"}]',
 'int：返回成功输出的字符数，失败返回负数',
 'C风格格式化输出函数，将数据输出到标准输出设备，支持多种格式控制符',
 '#include <cstdio>\nint main() {\n    int a = 10;\n    float b = 3.14;\n    printf("a=%d, b=%.2f\\n", a, b); // 输出 a=10, b=3.14\n    return 0;\n}',
 '常用格式符：%d(整数)、%f(浮点数)、%c(字符)、%s(字符串)、%p(地址)；需要包含<cstdio>头文件；格式化字符串需和参数类型匹配');

-- 2. scanf (func_id=42)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(42,
 '[{"name":"format","type":"const char*","desc":"格式控制字符串"},{"name":"...","type":"可变参数","desc":"变量地址列表"}]',
 'int：返回成功读取的参数个数，失败返回EOF',
 'C风格格式化输入函数，从标准输入读取数据到指定变量，参数必须传地址',
 '#include <cstdio>\nint main() {\n    int a;\n    float b;\n    scanf("%d %f", &a, &b); // 读取整数和浮点数\n    printf("a=%d, b=%.2f\\n", a, b);\n    return 0;\n}',
 '参数必须加&（除字符串数组）；格式符需和变量类型匹配；无法读取带空格的字符串；需要包含<cstdio>头文件');

-- 3. getline (func_id=43)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(43,
 '[{"name":"is","type":"istream&","desc":"输入流对象（如cin）"},{"name":"str","type":"string&","desc":"存储输入的字符串对象"}]',
 'istream&：返回输入流对象引用',
 'C++标准库函数，读取一行输入（包含空格）到string对象，直到遇到换行符',
 '#include <iostream>\n#include <string>\nusing namespace std;\nint main() {\n    string s;\n    getline(cin, s); // 读取整行输入\n    cout << "输入内容：" << s << endl;\n    return 0;\n}',
 '需要包含<string>头文件；会读取换行符前的所有字符（包括空格）；注意cin>>后使用需处理残留的换行符');

-- 4. cin.get (func_id=44)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(44,
 '[{"name":"c","type":"char&","desc":"可选，存储读取字符的变量"},{"name":"n","type":"streamsize","desc":"可选，读取最大字符数"},{"name":"delim","type":"char","desc":"可选，终止字符，默认\\n"}]',
 'int：成功返回读取字符的ASCII码，失败返回EOF',
 'cin的成员函数，读取单个字符或一行字符，可指定终止符，不自动忽略空白字符',
 '#include <iostream>\nusing namespace std;\nint main() {\n    char c;\n    cin.get(c); // 读取单个字符\n    cout << "读取的字符：" << c << endl;\n    char buf[100];\n    cin.get(buf, 100, \'#\'); // 读取到#为止\n    cout << buf << endl;\n    return 0;\n}',
 '读取单个字符时保留空白字符（包括换行）；读取字符数组时自动添加\\0结束符；需要包含<iostream>头文件');

-- 5. cout.put (func_id=45)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(45,
 '[{"name":"c","type":"char","desc":"要输出的字符"}]',
 'ostream&：返回cout对象引用，支持链式调用',
 'cout的成员函数，输出单个字符，比cout<<更底层，适合精准输出字符',
 '#include <iostream>\nusing namespace std;\nint main() {\n    cout.put(\'A\'); // 输出字符A\n    cout.put(\'\\n\').put(\'B\'); // 链式调用，输出换行和B\n    return 0;\n}',
 '只能输出单个字符；返回cout引用，支持链式调用；需要包含<iostream>头文件；等价于cout << \'A\'');

-- 6. strlen (func_id=46)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(46,
 '[{"name":"str","type":"const char*","desc":"C风格字符串（以\\0结尾）"}]',
 'size_t：返回字符串长度（不包含\\0）',
 'C标准库函数，计算C风格字符串的长度，只统计\\0之前的字符数',
 '#include <cstring>\n#include <cstdio>\nint main() {\n    char str[] = "Hello C++";\n    printf("长度：%zu\\n", strlen(str)); // 输出 7\n    return 0;\n}',
 '需要包含<cstring>头文件；不计算\\0结束符；参数必须是以\\0结尾的合法字符串，否则会越界');

-- 7. strcpy (func_id=47)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(47,
 '[{"name":"dest","type":"char*","desc":"目标字符串数组"},{"name":"src","type":"const char*","desc":"源字符串"}]',
 'char*：返回目标字符串dest的指针',
 'C标准库函数，将源字符串复制到目标字符串数组，包括\\0结束符',
 '#include <cstring>\n#include <cstdio>\nint main() {\n    char dest[20];\n    char src[] = "C++ Programming";\n    strcpy(dest, src);\n    printf("dest：%s\\n", dest); // 输出 C++ Programming\n    return 0;\n}',
 '需要包含<cstring>头文件；目标数组必须足够大，否则会缓冲区溢出；不检查目标数组大小，建议使用strncpy更安全');

-- 8. strcat (func_id=48)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(48,
 '[{"name":"dest","type":"char*","desc":"目标字符串数组"},{"name":"src","type":"const char*","desc":"源字符串"}]',
 'char*：返回目标字符串dest的指针',
 'C标准库函数，将源字符串追加到目标字符串末尾，覆盖目标字符串原有的\\0',
 '#include <cstring>\n#include <cstdio>\nint main() {\n    char dest[20] = "Hello";\n    char src[] = " C++";\n    strcat(dest, src);\n    printf("dest：%s\\n", dest); // 输出 Hello C++\n    return 0;\n}',
 '需要包含<cstring>头文件；目标数组必须有足够空间容纳拼接后的字符串；源字符串和目标字符串不能重叠');

-- 9. strcmp (func_id=49)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(49,
 '[{"name":"str1","type":"const char*","desc":"第一个字符串"},{"name":"str2","type":"const char*","desc":"第二个字符串"}]',
 'int：str1<str2返回负数，str1==str2返回0，str1>str2返回正数',
 'C标准库函数，按ASCII码值比较两个C风格字符串，区分大小写',
 '#include <cstring>\n#include <cstdio>\nint main() {\n    char str1[] = "Apple";\n    char str2[] = "Banana";\n    int res = strcmp(str1, str2);\n    if(res < 0) printf("str1 < str2\\n"); // 输出该结果\n    else if(res > 0) printf("str1 > str2\\n");\n    else printf("相等\\n");\n    return 0;\n}',
 '需要包含<cstring>头文件；按字符逐个比较，直到遇到不同字符或\\0；比较的是ASCII值，不是长度');

-- 10. strchr (func_id=50)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(50,
 '[{"name":"str","type":"const char*","desc":"源字符串"},{"name":"c","type":"int","desc":"要查找的字符（ASCII码）"}]',
 'char*：找到返回字符首次出现的指针，未找到返回NULL',
 'C标准库函数，查找字符在字符串中首次出现的位置，区分大小写',
 '#include <cstring>\n#include <cstdio>\nint main() {\n    char str[] = "Hello C++ World";\n    char* p = strchr(str, \'+\');\n    if(p) printf("找到：%s\\n", p); // 输出 ++ World\n    else printf("未找到\\n");\n    return 0;\n}',
 '需要包含<cstring>头文件；参数c是int类型（实际传char）；返回的指针指向原字符串，修改会影响原字符串');

-- 11. strstr (func_id=51)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(51,
 '[{"name":"str","type":"const char*","desc":"源字符串"},{"name":"substr","type":"const char*","desc":"要查找的子字符串"}]',
 'char*：找到返回子串首次出现的指针，未找到返回NULL',
 'C标准库函数，查找子字符串在源字符串中首次出现的位置，区分大小写',
 '#include <cstring>\n#include <cstdio>\nint main() {\n    char str[] = "Hello C++ World";\n    char* p = strstr(str, "C++");\n    if(p) printf("找到：%s\\n", p); // 输出 C++ World\n    else printf("未找到\\n");\n    return 0;\n}',
 '需要包含<cstring>头文件；子字符串为空时返回源字符串指针；区分大小写；返回的指针指向原字符串');

-- 12. to_string (func_id=52)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(52,
 '[{"name":"val","type":"int/float/double/long等","desc":"要转换的数值"}]',
 'string：返回转换后的字符串对象',
 'C++11新增函数，将数值类型转换为string对象，简化数值转字符串操作',
 '#include <iostream>\n#include <string>\nusing namespace std;\nint main() {\n    int a = 123;\n    double b = 3.14;\n    string s1 = to_string(a); // "123"\n    string s2 = to_string(b); // "3.140000"\n    cout << s1 << " " << s2 << endl;\n    return 0;\n}',
 '需要包含<string>头文件；C++11及以上版本支持；浮点数转换会保留6位小数；支持多种数值类型');

-- 13. stoi (func_id=53)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(53,
 '[{"name":"str","type":"const string&","desc":"要转换的字符串"},{"name":"pos","type":"size_t*","desc":"可选，存储转换停止的位置"},{"name":"base","type":"int","desc":"可选，进制，默认10"}]',
 'int：返回转换后的整数',
 'C++11新增函数，将字符串转换为int类型整数，支持指定进制',
 '#include <iostream>\n#include <string>\nusing namespace std;\nint main() {\n    string s1 = "123";\n    string s2 = "1001", s3 = "FF";\n    int a = stoi(s1); // 123\n    int b = stoi(s2, nullptr, 2); // 9（二进制转十进制）\n    int c = stoi(s3, nullptr, 16); // 255（十六进制转十进制）\n    cout << a << " " << b << " " << c << endl;\n    return 0;\n}',
 '需要包含<string>头文件；C++11及以上支持；字符串非数字会抛invalid_argument异常；超出范围抛out_of_range');

-- 14. stof (func_id=54)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(54,
 '[{"name":"str","type":"const string&","desc":"要转换的字符串"},{"name":"pos","type":"size_t*","desc":"可选，存储转换停止的位置"}]',
 'float：返回转换后的浮点数',
 'C++11新增函数，将字符串转换为float类型浮点数，支持科学计数法',
 '#include <iostream>\n#include <string>\nusing namespace std;\nint main() {\n    string s1 = "3.14";\n    string s2 = "1.23e4"; // 科学计数法\n    float a = stof(s1); // 3.14\n    float b = stof(s2); // 12300.0\n    cout << a << " " << b << endl;\n    return 0;\n}',
 '需要包含<string>头文件；C++11及以上支持；字符串非浮点数会抛异常；对应还有stod（double）、stold（long double）');

-- 15. abs (func_id=55)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(55,
 '[{"name":"n","type":"int/long/long long","desc":"整数"}]',
 '同参数类型：返回整数的绝对值',
 'C++标准库函数，计算整数的绝对值，支持多种整数类型',
 '#include <iostream>\n#include <cstdlib>\nusing namespace std;\nint main() {\n    int a = -10;\n    long b = -123456;\n    cout << abs(a) << endl; // 10\n    cout << abs(b) << endl; // 123456\n    return 0;\n}',
 '需要包含<cstdlib>或<cmath>头文件；只适用于整数类型；浮点数绝对值用fabs');

-- 16. fabs (func_id=56)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(56,
 '[{"name":"x","type":"float/double/long double","desc":"浮点数"}]',
 '同参数类型：返回浮点数的绝对值',
 'C++标准库函数，计算浮点数的绝对值，支持多种浮点类型',
 '#include <iostream>\n#include <cmath>\nusing namespace std;\nint main() {\n    float a = -3.14f;\n    double b = -2.71828;\n    cout << fabs(a) << endl; // 3.14\n    cout << fabs(b) << endl; // 2.71828\n    return 0;\n}',
 '需要包含<cmath>头文件；只适用于浮点数类型；整数绝对值用abs');

-- 17. sqrt (func_id=57)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(57,
 '[{"name":"x","type":"float/double/long double","desc":"非负浮点数"}]',
 '同参数类型：返回x的平方根',
 'C++标准库函数，计算非负浮点数的平方根，参数不能为负数',
 '#include <iostream>\n#include <cmath>\nusing namespace std;\nint main() {\n    double a = 16.0;\n    double b = 2.0;\n    cout << sqrt(a) << endl; // 4.0\n    cout << sqrt(b) << endl; // 1.41421\n    return 0;\n}',
 '需要包含<cmath>头文件；参数为负数会导致未定义行为（C++11后可能返回NaN）；返回值精度依赖于浮点类型');

-- 18. pow (func_id=58)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(58,
 '[{"name":"base","type":"float/double/long double","desc":"底数"},{"name":"exp","type":"float/double/long double","desc":"指数"}]',
 '同参数类型：返回base^exp的结果',
 'C++标准库函数，计算底数的指数次幂，支持浮点数底数和指数',
 '#include <iostream>\n#include <cmath>\nusing namespace std;\nint main() {\n    double a = pow(2.0, 3.0); // 8.0\n    double b = pow(10.0, 2.0); // 100.0\n    double c = pow(4.0, 0.5); // 2.0（平方根）\n    cout << a << " " << b << " " << c << endl;\n    return 0;\n}',
 '需要包含<cmath>头文件；底数为负且指数为小数时结果未定义；浮点数计算有精度误差');

-- 19. sin (func_id=59)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(59,
 '[{"name":"x","type":"float/double/long double","desc":"弧度值"}]',
 '同参数类型：返回x的正弦值',
 'C++标准库函数，计算角度（弧度）的正弦值，参数为弧度不是角度',
 '#include <iostream>\n#include <cmath>\nusing namespace std;\nint main() {\n    const double PI = 3.1415926535;\n    double a = sin(PI/2); // 1.0（90度）\n    double b = sin(0); // 0.0\n    cout << a << " " << b << endl;\n    return 0;\n}',
 '需要包含<cmath>头文件；参数是弧度，角度转弧度公式：弧度=角度×PI/180；返回值范围[-1,1]');

-- 20. cos (func_id=60)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(60,
 '[{"name":"x","type":"float/double/long double","desc":"弧度值"}]',
 '同参数类型：返回x的余弦值',
 'C++标准库函数，计算角度（弧度）的余弦值，参数为弧度不是角度',
 '#include <iostream>\n#include <cmath>\nusing namespace std;\nint main() {\n    const double PI = 3.1415926535;\n    double a = cos(0); // 1.0（0度）\n    double b = cos(PI); // -1.0（180度）\n    cout << a << " " << b << endl;\n    return 0;\n}',
 '需要包含<cmath>头文件；参数是弧度；返回值范围[-1,1]；cos(PI/2)≈0（浮点精度问题）');

-- 21. tan (func_id=61)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(61,
 '[{"name":"x","type":"float/double/long double","desc":"弧度值"}]',
 '同参数类型：返回x的正切值',
 'C++标准库函数，计算角度（弧度）的正切值，参数为弧度不是角度',
 '#include <iostream>\n#include <cmath>\nusing namespace std;\nint main() {\n    const double PI = 3.1415926535;\n    double a = tan(PI/4); // 1.0（45度）\n    double b = tan(0); // 0.0\n    cout << a << " " << b << endl;\n    return 0;\n}',
 '需要包含<cmath>头文件；参数是弧度；PI/2附近值会导致结果趋近于无穷大；浮点精度可能有误差');

-- 22. log (func_id=62)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(62,
 '[{"name":"x","type":"float/double/long double","desc":"正浮点数"}]',
 '同参数类型：返回x的自然对数（以e为底）',
 'C++标准库函数，计算正浮点数的自然对数，参数必须大于0',
 '#include <iostream>\n#include <cmath>\nusing namespace std;\nint main() {\n    double a = log(exp(1)); // 1.0（e的自然对数）\n    double b = log(1.0); // 0.0\n    cout << a << " " << b << endl;\n    return 0;\n}',
 '需要包含<cmath>头文件；参数≤0会导致未定义行为；以10为底的对数用log10，自定义底数用log(x)/log(base)');

-- 23. log10 (func_id=63)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(63,
 '[{"name":"x","type":"float/double/long double","desc":"正浮点数"}]',
 '同参数类型：返回x的常用对数（以10为底）',
 'C++标准库函数，计算正浮点数的常用对数，参数必须大于0',
 '#include <iostream>\n#include <cmath>\nusing namespace std;\nint main() {\n    double a = log10(100.0); // 2.0\n    double b = log10(1.0); // 0.0\n    cout << a << " " << b << endl;\n    return 0;\n}',
 '需要包含<cmath>头文件；参数≤0会导致未定义行为；自然对数用log');

-- 24. max (func_id=64)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(64,
 '[{"name":"a","type":"任意可比较类型","desc":"第一个值"},{"name":"b","type":"同a类型","desc":"第二个值"}]',
 '同参数类型：返回两个值中的较大值',
 'C++标准库模板函数，比较两个同类型值并返回较大值，支持多种数据类型',
 '#include <iostream>\n#include <algorithm>\nusing namespace std;\nint main() {\n    int a = 10, b = 20;\n    double c = 3.14, d = 2.71;\n    cout << max(a, b) << endl; // 20\n    cout << max(c, d) << endl; // 3.14\n    return 0;\n}',
 '需要包含<algorithm>头文件；参数必须是同类型；支持自定义类型（需重载<运算符）；C++11后支持初始化列表max({1,2,3})');

-- 25. min (func_id=65)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(65,
 '[{"name":"a","type":"任意可比较类型","desc":"第一个值"},{"name":"b","type":"同a类型","desc":"第二个值"}]',
 '同参数类型：返回两个值中的较小值',
 'C++标准库模板函数，比较两个同类型值并返回较小值，支持多种数据类型',
 '#include <iostream>\n#include <algorithm>\nusing namespace std;\nint main() {\n    int a = 10, b = 20;\n    double c = 3.14, d = 2.71;\n    cout << min(a, b) << endl; // 10\n    cout << min(c, d) << endl; // 2.71\n    return 0;\n}',
 '需要包含<algorithm>头文件；参数必须是同类型；支持自定义类型（需重载<运算符）；C++11后支持初始化列表min({1,2,3})');

-- 26. vector.push_back (func_id=66)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(66,
 '[{"name":"val","type":"vector元素类型","desc":"要添加的元素"}]',
 'void：无返回值',
 'vector容器的成员函数，将元素添加到vector末尾，自动扩容（如需）',
 '#include <iostream>\n#include <vector>\nusing namespace std;\nint main() {\n    vector<int> vec;\n    vec.push_back(1);\n    vec.push_back(2);\n    vec.push_back(3);\n    for(int x : vec) cout << x << " "; // 输出 1 2 3\n    return 0;\n}',
 '需要包含<vector>头文件；会修改原vector；元素类型需和vector定义一致；扩容可能导致迭代器失效');

-- 27. vector.pop_back (func_id=67)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(67,
 '[]',
 'void：无返回值',
 'vector容器的成员函数，删除vector末尾的元素，不返回被删除元素',
 '#include <iostream>\n#include <vector>\nusing namespace std;\nint main() {\n    vector<int> vec = {1,2,3,4};\n    vec.pop_back();\n    for(int x : vec) cout << x << " "; // 输出 1 2 3\n    return 0;\n}',
 '需要包含<vector>头文件；会修改原vector；空vector调用pop_back会导致未定义行为；时间复杂度O(1)');

-- 28. vector.size (func_id=68)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(68,
 '[]',
 'size_t：返回vector中元素的个数',
 'vector容器的成员函数，获取vector当前包含的元素数量，时间复杂度O(1)',
 '#include <iostream>\n#include <vector>\nusing namespace std;\nint main() {\n    vector<int> vec = {1,2,3};\n    cout << "元素个数：" << vec.size() << endl; // 输出 3\n    vec.push_back(4);\n    cout << "元素个数：" << vec.size() << endl; // 输出 4\n    return 0;\n}',
 '需要包含<vector>头文件；返回值是size_t类型（无符号整数）；和capacity()的区别：size是元素数，capacity是分配的空间数');

-- 29. vector.empty (func_id=69)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(69,
 '[]',
 'bool：空返回true，非空返回false',
 'vector容器的成员函数，判断vector是否为空（元素个数为0），时间复杂度O(1)',
 '#include <iostream>\n#include <vector>\nusing namespace std;\nint main() {\n    vector<int> vec;\n    if(vec.empty()) cout << "vector为空" << endl; // 输出\n    vec.push_back(1);\n    if(!vec.empty()) cout << "vector非空" << endl; // 输出\n    return 0;\n}',
 '需要包含<vector>头文件；比size()==0更高效且易读；空vector的size()返回0');

-- 30. vector.clear (func_id=70)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(70,
 '[]',
 'void：无返回值',
 'vector容器的成员函数，清空vector中所有元素，size变为0，但capacity不变',
 '#include <iostream>\n#include <vector>\nusing namespace std;\nint main() {\n    vector<int> vec = {1,2,3};\n    vec.clear();\n    cout << "size：" << vec.size() << endl; // 输出 0\n    cout << "capacity：" << vec.capacity() << endl; // 输出 3（不变）\n    return 0;\n}',
 '需要包含<vector>头文件；会调用元素的析构函数；清空后vector仍占用内存（capacity不变）；要释放内存可配合swap');

-- 31. map.insert (func_id=71)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(71,
 '[{"name":"value","type":"pair<key_type, value_type>","desc":"要插入的键值对"}]',
 'pair<iterator, bool>：插入成功返回{迭代器, true}，失败返回{已存在元素迭代器, false}',
 'map容器的成员函数，插入键值对，键已存在则插入失败，不覆盖原有值',
 '#include <iostream>\n#include <map>\n#include <utility>\nusing namespace std;\nint main() {\n    map<string, int> mp;\n    // 插入方式1\n    mp.insert(make_pair("apple", 5));\n    // 插入方式2\n    auto res = mp.insert({"apple", 10}); // 键已存在，插入失败\n    if(!res.second) cout << "插入失败" << endl;\n    cout << mp["apple"] << endl; // 输出 5\n    return 0;\n}',
 '需要包含<map>头文件；map的键是唯一的；时间复杂度O(log n)；C++11支持列表初始化插入');

-- 32. map.find (func_id=72)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(72,
 '[{"name":"key","type":"key_type","desc":"要查找的键"}]',
 'iterator：找到返回指向键值对的迭代器，未找到返回map.end()',
 'map容器的成员函数，查找指定键对应的键值对，时间复杂度O(log n)',
 '#include <iostream>\n#include <map>\nusing namespace std;\nint main() {\n    map<string, int> mp = {{"apple",5}, {"banana",3}};\n    auto it = mp.find("apple");\n    if(it != mp.end()) {\n        cout << it->first << ":" << it->second << endl; // 输出 apple:5\n    }\n    it = mp.find("orange");\n    if(it == mp.end()) cout << "未找到" << endl;\n    return 0;\n}',
 '需要包含<map>头文件；比[]运算符安全（[]会插入不存在的键）；返回的迭代器指向pair<key, value>');

-- 33. map.erase (func_id=73)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(73,
 '[{"name":"key/iterator","type":"key_type/iterator","desc":"要删除的键或迭代器"}]',
 'size_t：按键删除返回删除的元素数（0或1），按迭代器删除无返回值',
 'map容器的成员函数，删除指定键或迭代器指向的键值对，时间复杂度O(log n)',
 '#include <iostream>\n#include <map>\nusing namespace std;\nint main() {\n    map<string, int> mp = {{"apple",5}, {"banana",3}};\n    // 按键删除\n    mp.erase("apple");\n    // 按迭代器删除\n    auto it = mp.find("banana");\n    if(it != mp.end()) mp.erase(it);\n    cout << mp.size() << endl; // 输出 0\n    return 0;\n}',
 '需要包含<map>头文件；删除不存在的键不会报错；删除end()迭代器会导致未定义行为；可删除一段范围的元素');

-- 34. map.size (func_id=74)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(74,
 '[]',
 'size_t：返回map中键值对的个数',
 'map容器的成员函数，获取map当前包含的键值对数量，时间复杂度O(1)',
 '#include <iostream>\n#include <map>\nusing namespace std;\nint main() {\n    map<string, int> mp = {{"apple",5}, {"banana",3}};\n    cout << "键值对个数：" << mp.size() << endl; // 输出 2\n    mp.erase("apple");\n    cout << "键值对个数：" << mp.size() << endl; // 输出 1\n    return 0;\n}',
 '需要包含<map>头文件；返回值是size_t类型；空map的size()返回0；map的每个键唯一，size等于不同键的数量');

-- 35. string.length (func_id=75)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(75,
 '[]',
 'size_t：返回string中字符的个数（不包含\\0）',
 'string类的成员函数，获取字符串长度，等价于size()成员函数',
 '#include <iostream>\n#include <string>\nusing namespace std;\nint main() {\n    string s = "Hello C++";\n    cout << "长度：" << s.length() << endl; // 输出 7\n    cout << "等价于size：" << s.size() << endl; // 输出 7\n    return 0;\n}',
 '需要包含<string>头文件；返回值是size_t类型；不计算\\0结束符；和C风格strlen的区别：length是O(1)，strlen是O(n)');

-- 36. string.append (func_id=76)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(76,
 '[{"name":"str","type":"const string&/const char*","desc":"要追加的字符串"},{"name":"n","type":"size_t","desc":"可选，追加前n个字符"}]',
 'string&：返回当前string对象的引用，支持链式调用',
 'string类的成员函数，将指定字符串追加到当前字符串末尾，修改原字符串',
 '#include <iostream>\n#include <string>\nusing namespace std;\nint main() {\n    string s = "Hello";\n    s.append(" C++"); // 追加字符串\n    cout << s << endl; // 输出 Hello C++\n    s.append(" World", 5); // 追加前5个字符\n    cout << s << endl; // 输出 Hello C++ World\n    return 0;\n}',
 '需要包含<string>头文件；返回自身引用，支持链式调用；比+运算符更高效（减少临时对象）；支持追加字符、字符数组等');

-- 37. string.substr (func_id=77)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(77,
 '[{"name":"pos","type":"size_t","desc":"起始位置，默认0"},{"name":"len","type":"size_t","desc":"可选，截取长度，默认到末尾"}]',
 'string：返回截取的子字符串',
 'string类的成员函数，截取字符串的指定部分，返回新字符串，不修改原字符串',
 '#include <iostream>\n#include <string>\nusing namespace std;\nint main() {\n    string s = "Hello C++ World";\n    string s1 = s.substr(6, 3); // 从索引6截取3个字符\n    cout << s1 << endl; // 输出 C++\n    string s2 = s.substr(10); // 从索引10截取到末尾\n    cout << s2 << endl; // 输出 World\n    return 0;\n}',
 '需要包含<string>头文件；pos超出范围会抛out_of_range异常；len超出剩余字符数则截取到末尾；索引从0开始');

-- 38. string.find (func_id=78)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(78,
 '[{"name":"str","type":"const string&/const char*/char","desc":"要查找的字符串/字符"},{"name":"pos","type":"size_t","desc":"可选，起始查找位置，默认0"}]',
 'size_t：找到返回起始索引，未找到返回string::npos',
 'string类的成员函数，查找子字符串/字符在字符串中首次出现的位置，区分大小写',
 '#include <iostream>\n#include <string>\nusing namespace std;\nint main() {\n    string s = "Hello C++ World";\n    size_t pos = s.find("C++");\n    if(pos != string::npos) {\n        cout << "找到位置：" << pos << endl; // 输出 6\n    }\n    pos = s.find("Java");\n    if(pos == string::npos) cout << "未找到" << endl;\n    return 0;\n}',
 '需要包含<string>头文件；区分大小写；返回值是size_t类型；string::npos是无符号最大值（表示未找到）');

-- 39. string.replace (func_id=79)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(79,
 '[{"name":"pos","type":"size_t","desc":"起始替换位置"},{"name":"len","type":"size_t","desc":"要替换的字符数"},{"name":"str","type":"const string&","desc":"替换的新字符串"}]',
 'string&：返回当前string对象的引用',
 'string类的成员函数，替换字符串中指定位置的指定长度字符，修改原字符串',
 '#include <iostream>\n#include <string>\nusing namespace std;\nint main() {\n    string s = "Hello Java World";\n    s.replace(6, 4, "C++"); // 从位置6替换4个字符为C++\n    cout << s << endl; // 输出 Hello C++ World\n    return 0;\n}',
 '需要包含<string>头文件；pos超出范围抛out_of_range异常；len超出剩余字符数则替换到末尾；返回自身引用支持链式调用');

-- 40. malloc (func_id=80)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(80,
 '[{"name":"size","type":"size_t","desc":"要分配的内存字节数"}]',
 'void*：成功返回内存地址，失败返回NULL',
 'C标准库函数，从堆上分配指定大小的未初始化内存，需要手动释放',
 '#include <cstdio>\n#include <cstdlib>\nint main() {\n    int* p = (int*)malloc(4 * sizeof(int)); // 分配4个int的内存\n    if(p == NULL) {\n        printf("内存分配失败\\n");\n        return 1;\n    }\n    for(int i=0; i<4; i++) p[i] = i+1;\n    for(int i=0; i<4; i++) printf("%d ", p[i]); // 输出 1 2 3 4\n    free(p); // 释放内存\n    p = NULL; // 避免野指针\n    return 0;\n}',
 '需要包含<cstdlib>头文件；返回void*需强制类型转换；分配的内存未初始化（值随机）；必须用free释放，否则内存泄漏');

-- 41. free (func_id=81)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(81,
 '[{"name":"ptr","type":"void*","desc":"malloc/calloc/realloc分配的内存地址"}]',
 'void：无返回值',
 'C标准库函数，释放由malloc/calloc/realloc分配的堆内存，归还给系统',
 '#include <cstdio>\n#include <cstdlib>\nint main() {\n    char* p = (char*)malloc(100);\n    if(p) {\n        sprintf(p, "Hello C++");\n        printf("%s\\n", p);\n        free(p); // 释放内存\n        p = NULL; // 置空，避免野指针\n    }\n    return 0;\n}',
 '需要包含<cstdlib>头文件；只能释放堆内存，不能释放栈内存；重复释放或释放NULL以外的无效指针会导致未定义行为');

-- 42. new (func_id=82)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(82,
 '[{"name":"type","type":"数据类型","desc":"要分配的类型"},{"name":"[]","type":"","desc":"可选，数组分配"}]',
 '类型指针：成功返回对象/数组地址，失败抛bad_alloc异常（默认）',
 'C++关键字，从堆上分配内存并调用构造函数初始化，需要用delete释放',
 '#include <iostream>\nusing namespace std;\nint main() {\n    // 分配单个对象\n    int* p1 = new int(10); // 初始化值为10\n    cout << *p1 << endl; // 输出 10\n    delete p1;\n    // 分配数组\n    int* p2 = new int[5]{1,2,3,4,5}; // C++11初始化\n    for(int i=0; i<5; i++) cout << p2[i] << " ";\n    delete[] p2; // 释放数组\n    return 0;\n}',
 'new是关键字不是函数；会自动计算内存大小，无需sizeof；分配对象会调用构造函数；数组new必须用delete[]释放');

-- 43. delete (func_id=83)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(83,
 '[{"name":"ptr","type":"类型指针","desc":"new分配的对象/数组地址"}]',
 'void：无返回值',
 'C++关键字，释放new分配的堆内存，调用析构函数（针对对象）',
 '#include <iostream>\n#include <string>\nusing namespace std;\nclass MyClass {\npublic:\n    MyClass() { cout << "构造函数" << endl; }\n    ~MyClass() { cout << "析构函数" << endl; }\n};\nint main() {\n    MyClass* p = new MyClass(); // 调用构造函数\n    delete p; // 调用析构函数并释放内存\n    p = NULL;\n    // 数组释放\n    MyClass* arr = new MyClass[2];\n    delete[] arr; // 必须用delete[]\n    return 0;\n}',
 'delete是关键字；释放对象会调用析构函数；数组必须用delete[]释放；释放NULL指针是安全的；重复释放会导致未定义行为');

-- 44. time (func_id=84)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(84,
 '[{"name":"timer","type":"time_t*","desc":"可选，存储时间的指针，NULL则返回时间值"}]',
 'time_t：返回从1970-01-01 00:00:00 UTC到当前的秒数',
 'C标准库函数，获取当前系统时间（时间戳），单位为秒',
 '#include <iostream>\n#include <ctime>\nusing namespace std;\nint main() {\n    time_t now = time(NULL); // 获取当前时间戳\n    cout << "时间戳：" << now << endl;\n    // 转换为本地时间字符串\n    char* time_str = ctime(&now);\n    cout << "当前时间：" << time_str;\n    return 0;\n}',
 '需要包含<ctime>头文件；返回值是time_t类型（通常是long）；ctime转换的字符串包含换行符；时区为本地时区');

-- 45. clock (func_id=85)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(85,
 '[{"name":"clk_id","type":"clockid_t","desc":"可选，时钟类型，默认CLOCK_REALTIME"}]',
 'clock_t：返回程序占用的CPU时钟周期数',
 'C标准库函数，获取程序运行以来占用的CPU时间，常用于性能计时',
 '#include <iostream>\n#include <ctime>\n#include <cmath>\nusing namespace std;\nint main() {\n    clock_t start = clock();\n    // 耗时操作\n    double sum = 0;\n    for(int i=0; i<1000000; i++) sum += sqrt(i);\n    clock_t end = clock();\n    double duration = (double)(end - start) / CLOCKS_PER_SEC;\n    cout << "耗时：" << duration << "秒" << endl;\n    return 0;\n}',
 '需要包含<ctime>头文件；CLOCKS_PER_SEC是每秒的时钟周期数；返回值是CPU时间，不是墙上时钟时间；精度比time更高');

-- 46. sort (func_id=86)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(86,
 '[{"name":"first","type":"iterator","desc":"起始迭代器"},{"name":"last","type":"iterator","desc":"结束迭代器（不包含）"},{"name":"comp","type":"比较函数","desc":"可选，自定义比较规则，默认升序"}]',
 'void：无返回值',
 'C++标准库算法，对指定范围的元素进行排序，默认升序，不稳定排序（C++11后可指定stable_sort）',
 '#include <iostream>\n#include <vector>\n#include <algorithm>\nusing namespace std;\nbool cmp(int a, int b) { return a > b; } // 降序比较\nint main() {\n    vector<int> vec = {3,1,4,2,5};\n    sort(vec.begin(), vec.end()); // 升序\n    for(int x : vec) cout << x << " "; // 1 2 3 4 5\n    cout << endl;\n    sort(vec.begin(), vec.end(), cmp); // 降序\n    for(int x : vec) cout << x << " "; // 5 4 3 2 1\n    return 0;\n}',
 '需要包含<algorithm>头文件；默认使用<运算符比较；时间复杂度O(n log n)；支持数组和STL容器；C++11支持lambda表达式作为比较函数');

-- 47. find (func_id=87)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(87,
 '[{"name":"first","type":"iterator","desc":"起始迭代器"},{"name":"last","type":"iterator","desc":"结束迭代器（不包含）"},{"name":"val","type":"元素类型","desc":"要查找的值"}]',
 'iterator：找到返回元素迭代器，未找到返回last',
 'C++标准库算法，在指定范围查找指定值，线性查找，时间复杂度O(n)',
 '#include <iostream>\n#include <vector>\n#include <algorithm>\nusing namespace std;\nint main() {\n    vector<int> vec = {1,2,3,4,5};\n    auto it = find(vec.begin(), vec.end(), 3);\n    if(it != vec.end()) {\n        cout << "找到：" << *it << endl; // 输出 3\n    }\n    it = find(vec.begin(), vec.end(), 6);\n    if(it == vec.end()) cout << "未找到" << endl;\n    return 0;\n}',
 '需要包含<algorithm>头文件；支持任意可迭代容器；使用==运算符比较元素；map/set建议用自身的find成员函数（更高效）');

-- 48. reverse (func_id=88)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(88,
 '[{"name":"first","type":"iterator","desc":"起始迭代器"},{"name":"last","type":"iterator","desc":"结束迭代器（不包含）"}]',
 'void：无返回值',
 'C++标准库算法，反转指定范围的元素顺序，修改原容器，时间复杂度O(n)',
 '#include <iostream>\n#include <vector>\n#include <algorithm>\n#include <string>\nusing namespace std;\nint main() {\n    vector<int> vec = {1,2,3,4,5};\n    reverse(vec.begin(), vec.end());\n    for(int x : vec) cout << x << " "; // 5 4 3 2 1\n    string s = "Hello";\n    reverse(s.begin(), s.end());\n    cout << "\\n" << s << endl; // olleH\n    return 0;\n}',
 '需要包含<algorithm>头文件；直接修改原容器；支持数组、vector、string等可迭代对象；空范围调用无效果');

-- 49. swap (func_id=89)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(89,
 '[{"name":"a","type":"任意类型","desc":"第一个值"},{"name":"b","type":"同a类型","desc":"第二个值"}]',
 'void：无返回值',
 'C++标准库模板函数，交换两个同类型值的内容，高效实现，时间复杂度O(1)（多数类型）',
 '#include <iostream>\n#include <algorithm>\n#include <string>\nusing namespace std;\nint main() {\n    int a = 10, b = 20;\n    swap(a, b);\n    cout << a << " " << b << endl; // 20 10\n    string s1 = "Hello", s2 = "World";\n    swap(s1, s2);\n    cout << s1 << " " << s2 << endl; // World Hello\n    return 0;\n}',
 '需要包含<algorithm>头文件；模板函数支持任意类型；内置类型交换是值交换，复杂类型（如string）是指针交换（高效）；容器也有成员swap函数');

-- 50. accumulate (func_id=90)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(90,
 '[{"name":"first","type":"iterator","desc":"起始迭代器"},{"name":"last","type":"iterator","desc":"结束迭代器（不包含）"},{"name":"init","type":"数值类型","desc":"初始值"},{"name":"op","type":"二元函数","desc":"可选，自定义累加操作"}]',
 '同init类型：返回累加结果',
 'C++标准库算法，对指定范围的元素进行累加，默认求和，支持自定义操作',
 '#include <iostream>\n#include <vector>\n#include <numeric>\nusing namespace std;\nint main() {\n    vector<int> vec = {1,2,3,4,5};\n    // 求和，初始值0\n    int sum = accumulate(vec.begin(), vec.end(), 0);\n    cout << "总和：" << sum << endl; // 15\n    // 求乘积，初始值1\n    int product = accumulate(vec.begin(), vec.end(), 1, \n        [](int a, int b) { return a * b; });\n    cout << "乘积：" << product << endl; // 120\n    return 0;\n}',
 '需要包含<numeric>头文件；初始值类型决定返回值类型；自定义操作需是二元函数；支持数值类型和自定义类型（需重载+）');

-- 51. static_cast (func_id=91)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(91,
 '[{"name":"<new_type>","type":"类型名","desc":"目标类型"},{"name":"expression","type":"表达式","desc":"要转换的值/对象"}]',
 'new_type：转换后的类型值/对象',
 'C++静态类型转换，编译期检查，用于相关类型之间的转换，如基本类型、父子类指针（无运行时检查）',
 '#include <iostream>\nusing namespace std;\nint main() {\n    // 基本类型转换\n    double d = 3.14;\n    int i = static_cast<int>(d); // 3（截断）\n    cout << i << endl;\n    // 父子类转换（无运行时检查）\n    class Base {};\n    class Derived : public Base {};\n    Base* b = new Derived();\n    Derived* d_ptr = static_cast<Derived*>(b); // 编译通过\n    delete b;\n    return 0;\n}',
 '编译期转换，无运行时开销；不能转换不相关类型（如int*转char*）；父子类转换不安全（无类型检查）；替代C风格强制转换，更安全');

-- 52. dynamic_cast (func_id=92)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(92,
 '[{"name":"<new_type>","type":"类型名","desc":"目标类型（指针/引用）"},{"name":"expression","type":"表达式","desc":"要转换的对象"}]',
 'new_type：指针转换失败返回NULL，引用转换失败抛bad_cast异常',
 'C++动态类型转换，运行时检查，仅用于多态类型（有虚函数）的父子类转换，安全转换',
 '#include <iostream>\n#include <typeinfo>\nusing namespace std;\nclass Base { virtual void f() {} };\nclass Derived : public Base {};\nclass Other : public Base {};\nint main() {\n    Base* b = new Derived();\n    // 成功转换\n    Derived* d = dynamic_cast<Derived*>(b);\n    if(d) cout << "转换成功" << endl;\n    // 失败转换\n    Other* o = dynamic_cast<Other*>(b);\n    if(!o) cout << "转换失败" << endl;\n    delete b;\n    return 0;\n}',
 '需要虚函数支持；运行时类型检查，有开销；指针转换失败返回NULL，引用转换失败抛异常；只能用于父子类转换');

-- 53. reinterpret_cast (func_id=93)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(93,
 '[{"name":"<new_type>","type":"类型名","desc":"目标类型"},{"name":"expression","type":"表达式","desc":"要转换的值/指针"}]',
 'new_type：重新解释后的类型值',
 'C++重新解释转换，最不安全的转换，直接重新解释二进制位，无类型检查',
 '#include <iostream>\nusing namespace std;\nint main() {\n    // 指针类型转换\n    int a = 0x12345678;\n    int* p = &a;\n    char* c = reinterpret_cast<char*>(p);\n    cout << hex << (int)*c << endl; // 输出 78（小端序）\n    // 整数转指针\n    uintptr_t addr = reinterpret_cast<uintptr_t>(p);\n    cout << addr << endl;\n    return 0;\n}',
 '编译期转换，无检查；仅用于低级编程（如硬件操作）；不同平台行为可能不同；慎用，容易导致未定义行为');

-- 54. const_cast (func_id=94)
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes) VALUES
(94,
 '[{"name":"<new_type>","type":"类型名","desc":"目标类型（添加/移除const）"},{"name":"expression","type":"表达式","desc":"要转换的对象"}]',
 'new_type：转换后的类型值/指针',
 'C++常量转换，仅用于添加或移除const/volatile限定符，不改变类型',
 '#include <iostream>\nusing namespace std;\nvoid func(int* p) { *p = 100; }\nint main() {\n    const int a = 10;\n    // 移除const（仅指针层面，修改原const变量仍未定义）\n    int* p = const_cast<int*>(&a);\n    func(p); // 编译通过\n    cout << a << endl; // 未定义行为（可能10或100）\n    // 添加const\n    int b = 20;\n    const int* cp = const_cast<const int*>(&b);\n    return 0;\n}',
 '只能修改const/volatile限定符；修改原const变量的值会导致未定义行为；用于兼容旧代码，尽量避免使用');
  INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes)
VALUES
(95, 
 '[{"name":"变量","type":"任意可赋值类型","desc":"接收输入的变量（如int、string、float等）"},{"name":">>","type":"运算符","desc":"提取运算符，用于读取输入"}]',
 'istream&：返回cin对象本身，支持链式调用',
 '从标准输入设备（键盘）读取数据，并赋值给指定变量，是C++最常用的输入方式',
 '#include <iostream>\nusing namespace std;\nint main() {\n    int a;\n    string b;\n    cin >> a >> b;  // 链式读取，输入：10 hello\n    cout << a << " " << b;  // 输出：10 hello\n    return 0;\n}',
 '1. cin读取时会自动跳过空格、换行符等空白字符；2. 读取字符串时遇到空白字符停止；3. 需要包含<iostream>头文件；4. 建议使用using namespace std或显式写std::cin');
 
 INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes)
VALUES
(96, 
 '[{"name":"输出内容","type":"任意可输出类型","desc":"要打印的内容（如字符串、数字、变量等）"},{"name":"<<","type":"运算符","desc":"插入运算符，用于输出内容"},{"name":"endl","type":"操纵符","desc":"换行并刷新缓冲区（可选）"}]',
 'ostream&：返回cout对象本身，支持链式调用',
 '将指定的内容输出到标准输出设备（屏幕），是C++最常用的输出方式',
 '#include <iostream>\nusing namespace std;\nint main() {\n    int num = 100;\n    cout << "数字：" << num << endl;  // 输出：数字：100（换行）\n    cout << "Hello" << " " << "World";  // 输出：Hello World\n    return 0;\n}',
 '1. cout输出时不会自动换行，需手动加endl或\\n；2. endl会刷新缓冲区，\\n仅换行；3. 需要包含<iostream>头文件；4. 支持多种数据类型的直接输出，无需格式化转换');
 
 INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes)
VALUES
(97, 
 '[{"name":"初始化表达式","type":"任意语句","desc":"循环开始前执行一次，通常初始化循环变量"},{"name":"条件表达式","type":"bool","desc":"每次循环前判断，true则执行循环体"},{"name":"更新表达式","type":"任意语句","desc":"循环体执行后执行，通常更新循环变量"},{"name":"循环体","type":"语句/代码块","desc":"条件为true时执行的代码"}]',
 '无返回值：属于语法关键字，非函数',
 'C++核心循环语句，用于按指定次数重复执行代码块，适用于已知循环次数的场景，分为传统for循环和范围for循环（C++11+）',
 '#include <iostream>\nusing namespace std;\nint main() {\n    // 传统for循环：遍历0-4\n    for (int i = 0; i < 5; i++) {\n        cout << i << " ";  // 输出：0 1 2 3 4\n    }\n    // 范围for循环（C++11+）：遍历数组\n    int arr[] = {10, 20, 30};\n    for (int num : arr) {\n        cout << num << " ";  // 输出：10 20 30\n    }\n    return 0;\n}',
 '1. 初始化/条件/更新表达式均可省略（如for(;;)是无限循环）；2. 范围for循环适用于遍历容器/数组，无需手动控制索引；3. 循环变量作用域可限制在循环内（C++17+支持for(int i=0;;)）；4. 属于语法关键字，非函数，不能被调用');
 
 INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes)
VALUES
(98, 
 '[{"name":"条件表达式","type":"bool","desc":"判断条件，true则执行if体"},{"name":"if体","type":"语句/代码块","desc":"条件为true时执行的代码"},{"name":"else体","type":"语句/代码块","desc":"可选，条件为false时执行的代码"},{"name":"else if体","type":"语句/代码块","desc":"可选，多条件分支判断"}]',
 '无返回值：属于语法关键字，非函数',
 'C++核心分支语句，根据条件表达式的布尔值执行不同代码块，支持单分支、双分支（if-else）、多分支（if-else if-else）',
 '#include <iostream>\nusing namespace std;\nint main() {\n    int score = 85;\n    if (score >= 90) {\n        cout << "优秀" << endl;\n    } else if (score >= 80) {\n        cout << "良好" << endl;  // 输出：良好\n    } else {\n        cout << "及格/不及格" << endl;\n    }\n    return 0;\n}',
 '1. 条件表达式必须是bool类型（非bool会隐式转换）；2. 单语句块可省略{}，但建议始终添加（避免语法错误）；3. else子句会匹配最近的未匹配if；4. 属于语法关键字，非函数，不能被调用');
 
 INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes)
VALUES
(99, 
 '[{"name":"条件表达式","type":"bool","desc":"每次循环前判断，true则执行循环体"},{"name":"循环体","type":"语句/代码块","desc":"条件为true时执行的代码"}]',
 '无返回值：属于语法关键字，非函数',
 'C++基础循环语句，先判断条件再执行循环体，适用于未知循环次数的场景，与do-while（先执行后判断）互补',
 '#include <iostream>\nusing namespace std;\nint main() {\n    int i = 0;\n    // while循环：遍历0-4\n    while (i < 5) {\n        cout << i << " ";  // 输出：0 1 2 3 4\n        i++;\n    }\n    // do-while循环（变种）：至少执行一次\n    int j = 5;\n    do {\n        cout << j << " ";  // 输出：5\n        j++;\n    } while (j < 5);\n    return 0;\n}',
 '1. 条件表达式为true时持续执行循环体，需在循环体内修改条件变量避免无限循环；2. do-while是while的变种，先执行循环体再判断条件；3. 属于语法关键字，非函数，不能被调用');
 
 INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes)
VALUES
(100, 
 '[{"name":"表达式","type":"整型/枚举/字符串（C++11+）","desc":"要判断的表达式，结果需为可比较的离散值"},{"name":"case常量","type":"字面量","desc":"与表达式匹配的常量值，匹配则执行对应case体"},{"name":"break","type":"关键字","desc":"可选，跳出switch语句"},{"name":"default","type":"关键字","desc":"可选，无匹配case时执行的代码块"}]',
 '无返回值：属于语法关键字，非函数',
 'C++多分支语句，适用于表达式为离散常量值的场景，比多层if-else更简洁高效，核心是“匹配case常量后顺序执行，直到break/结束”',
 '#include <iostream>\nusing namespace std;\nint main() {\n    int num = 2;\n    switch (num) {\n        case 1:\n            cout << "星期一" << endl;\n            break;\n        case 2:\n            cout << "星期二" << endl;  // 输出：星期二\n            break;\n        default:\n            cout << "无效数字" << endl;\n    }\n    return 0;\n}',
 '1. case后必须是常量（不能是变量），且不能重复；2. 缺少break会导致“case穿透”（继续执行下一个case）；3. default可选，建议放在最后；4. C++11后支持字符串作为switch表达式；5. 属于语法关键字，非函数，不能被调用');

INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes)
VALUES
(101, 
 '[{"name":"循环体","type":"语句/代码块","desc":"先执行一次的代码"},{"name":"条件表达式","type":"bool","desc":"循环后判断，true则继续循环"}]',
 '无返回值：属于语法关键字，非函数',
 'C++循环语句，先执行循环体再判断条件，保证循环体至少执行一次，适用于“必须执行一次”的场景（如输入验证）',
 '#include <iostream>\nusing namespace std;\nint main() {\n    int num;\n    // 输入验证：必须输入正数\n    do {\n        cout << "输入一个正数：";\n        cin >> num;\n    } while (num <= 0);\n    cout << "你输入的正数是：" << num;\n    return 0;\n}',
 '1. 条件表达式后必须加分号（;），易遗漏；2. 属于while的变种，先执行后判断；3. 属于语法关键字，非函数');
 
 INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes)
VALUES
(102, 
 '[{"name":"作用范围","type":"循环/switch","desc":"跳出当前循环或switch语句"}]',
 '无返回值：属于语法关键字，非函数',
 'C++跳转关键字，用于立即跳出当前所在的循环（for/while/do-while）或switch语句，仅跳出“当前一层”结构',
 '#include <iostream>\nusing namespace std;\nint main() {\n    // 跳出for循环\n    for (int i = 0; i < 10; i++) {\n        if (i == 5) break;  // i=5时跳出循环\n        cout << i << " ";  // 输出：0 1 2 3 4\n    }\n    // 跳出switch\n    switch (2) {\n        case 2: cout << "break测试"; break;  // 执行后跳出switch\n        case 3: cout << "不会执行";\n    }\n    return 0;\n}',
 '1. 仅跳出当前一层循环/switch，嵌套循环中需配合标志位跳出外层；2. 不能用于if语句（除非if在循环/switch内）；3. 属于语法关键字，非函数');

INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes)
VALUES
(103, 
 '[{"name":"作用范围","type":"循环","desc":"跳过当前循环剩余代码，直接进入下一次循环判断"}]',
 '无返回值：属于语法关键字，非函数',
 'C++跳转关键字，用于跳过当前循环的剩余代码，直接进入下一次循环的条件判断（仅跳过“当前一次”循环）',
 '#include <iostream>\nusing namespace std;\nint main() {\n    // 输出1-10中的奇数\n    for (int i = 1; i <= 10; i++) {\n        if (i % 2 == 0) continue;  // 偶数时跳过后续代码\n        cout << i << " ";  // 输出：1 3 5 7 9\n    }\n    return 0;\n}',
 '1. 与break的区别：continue不跳出循环，仅跳过当前次；break直接跳出循环；2. 仅适用于循环（for/while/do-while）；3. 属于语法关键字，非函数');

INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes)
VALUES
(104, 
 '[{"name":"返回值","type":"任意类型","desc":"可选，与函数返回类型匹配"},{"name":"作用范围","type":"函数","desc":"结束函数执行并返回值（若有）"}]',
 '无返回值：属于语法关键字，非函数（但可携带返回值给函数调用者）',
 'C++核心关键字，用于结束函数执行，若函数有返回类型则必须返回对应类型的值；main函数中return 0表示程序正常退出',
 '#include <iostream>\nusing namespace std;\n// 自定义函数：求和\nint add(int a, int b) {\n    return a + b;  // 返回求和结果\n}\nint main() {\n    int res = add(3, 5);\n    cout << "3+5=" << res;  // 输出：3+5=8\n    return 0;  // main函数返回0表示正常退出\n}',
 '1. void类型函数可省略return，或写return;（无返回值）；2. main函数return 0等价于exit(0)；3. 属于语法关键字，非函数');

INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes)
VALUES
(105, 
 '[{"name":"类名","type":"标识符","desc":"自定义的类名称"},{"name":"成员变量","type":"任意类型","desc":"类的属性"},{"name":"成员函数","type":"函数","desc":"类的方法"},{"name":"访问修饰符","type":"public/private/protected","desc":"控制成员访问权限"}]',
 '无返回值：属于语法关键字，非函数',
 'C++面向对象的核心关键字，用于定义类（对象的模板），封装数据（成员变量）和行为（成员函数），是实现面向对象编程的基础',
 '#include <iostream>\nusing namespace std;\n// 定义Person类\nclass Person {\npublic:  // 公有访问权限\n    string name;\n    int age;\n    // 成员函数：打印信息\n    void showInfo() {\n        cout << "姓名：" << name << "，年龄：" << age;\n    }\n};\nint main() {\n    Person p;  // 创建类的对象\n    p.name = "张三";\n    p.age = 20;\n    p.showInfo();  // 输出：姓名：张三，年龄：20\n    return 0;\n}',
 '1. 类默认访问权限是private（私有）；2. 成员函数可在类内定义或类外实现；3. 属于面向对象核心关键字，非函数');

INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes)
VALUES
(106, 
 '[{"name":"命名空间名","type":"标识符","desc":"自定义的命名空间名称"},{"name":"作用域解析符::","type":"运算符","desc":"访问命名空间内的成员"},{"name":"using namespace","type":"语句","desc":"导入整个命名空间（简化使用）"}]',
 '无返回值：属于语法关键字，非函数',
 'C++语法关键字，用于划分命名空间，避免标识符（变量/函数/类）重名冲突，标准库（如cout/string）默认在std命名空间中',
 '#include <iostream>\n// 自定义命名空间\nnamespace MySpace {\n    int num = 100;\n    void show() {\n        cout << "MySpace::num=" << num;\n    }\n}\nint main() {\n    // 方式1：用::访问\n    cout << MySpace::num << endl;  // 输出：100\n    // 方式2：导入命名空间\n    using namespace MySpace;\n    show();  // 输出：MySpace::num=100\n    return 0;\n}',
 '1. 命名空间可嵌套；2. using namespace std; 是简化标准库使用的常用写法；3. 避免在头文件中全局导入命名空间（易冲突）；4. 属于语法关键字，非函数');
 
 INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes)
VALUES
(107, 
 '[{"name":"修饰对象","type":"变量/函数/指针","desc":"被修饰的对象不可修改"},{"name":"作用","type":"只读约束","desc":"编译期检查，防止意外修改"}]',
 '无返回值：属于语法关键字，非函数',
 'C++常量修饰符，用于定义只读常量（替代#define）、修饰函数参数/返回值/成员函数，被修饰的对象无法被修改，提升代码安全性和可读性',
 '#include <iostream>\nusing namespace std;\nint main() {\n    // 定义常量：PI的值不可修改\n    const double PI = 3.1415926;\n    // PI = 3.14;  // 报错：const变量不可修改\n    cout << "圆的面积（半径2）：" << PI * 2 * 2;  // 输出：12.5663704\n    return 0;\n}',
 '1. const变量必须初始化；2. const修饰指针分三种：const int* p（指针指向的值不可改）、int* const p（指针本身不可改）、const int* const p（都不可改）；3. 属于语法关键字，非函数');
 
 INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes)
VALUES
(108, 
 '[{"name":"修饰对象","type":"变量/函数/类成员","desc":"改变存储类型/作用域"},{"name":"作用域","type":"局部/全局/类","desc":"局部static：生命周期全局；全局static：作用域仅当前文件；类static：所有对象共享"}]',
 '无返回值：属于语法关键字，非函数',
 'C++存储类型修饰符，不同场景下作用不同：局部static变量生命周期为程序全程（仅初始化一次）；类static成员被所有对象共享，无需创建对象即可访问',
 '#include <iostream>\nusing namespace std;\n// 局部static示例\nvoid countCall() {\n    static int cnt = 0;  // 仅初始化一次，生命周期全局\n    cnt++;\n    cout << "调用次数：" << cnt << endl;\n}\nint main() {\n    countCall();  // 输出：调用次数：1\n    countCall();  // 输出：调用次数：2\n    return 0;\n}',
 '1. 局部static变量存储在全局区，而非栈区；2. 类static成员需在类外初始化；3. 全局static函数仅能在当前文件调用；4. 属于语法关键字，非函数');
 
 INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes)
VALUES
(109, 
 '[{"name":"变量名","type":"标识符","desc":"自定义整型变量名"},{"name":"取值范围","type":"整数","desc":"取决于系统（通常4字节，-2^31 ~ 2^31-1）"},{"name":"初始化","type":"整数","desc":"可选，建议初始化"}]',
 '无返回值：属于语法关键字，非函数',
 'C++基本数据类型关键字，用于定义整型变量/常量，存储整数（正数、负数、0），是最常用的数值类型之一，派生类型有short int、long int、unsigned int等',
 '#include <iostream>\nusing namespace std;\nint main() {\n    int a = 10;          // 正整数\n    int b = -5;         // 负整数\n    unsigned int c = 20; // 无符号整型（仅正数）\n    cout << "a=" << a << ", b=" << b << ", c=" << c;\n    return 0;\n}',
 '1. 未初始化的int变量值为随机值（垃圾值）；2. unsigned int取值范围：0 ~ 2^32-1；3. int占4字节（32/64位系统）；4. 属于基本类型关键字，非函数');
 
 INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes)
VALUES
(110, 
 '[{"name":"变量名","type":"标识符","desc":"自定义字符串变量名"},{"name":"初始化值","type":"字符串字面量","desc":"可选，如"hello"","},{"name":"成员函数","type":"函数","desc":"如length()、append()、substr()等"}]',
 '无返回值：属于STL类型别名，非函数（本质是std::string类）',
 'C++字符串类型（STL标准库），替代C语言的字符数组（char[]），支持字符串拼接、截取、长度获取等便捷操作，需包含<string>头文件',
 '#include <iostream>\n#include <string>  // 必须包含头文件\nusing namespace std;\nint main() {\n    string str1 = "Hello";\n    string str2 = " World";\n    string str3 = str1 + str2;  // 拼接字符串\n    cout << str3 << endl;       // 输出：Hello World\n    cout << "长度：" << str3.length();  // 输出：长度：11\n    return 0;\n}',
 '1. 必须包含<string>头文件；2. 支持直接用+拼接、==比较；3. 与char[]的区别：string自动管理内存，无需手动分配/释放；4. 属于STL类型，非原生关键字，但属于C++常用语法元素');

INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes)
VALUES
(111, 
 '[{"name":"条件表达式","type":"bool","desc":"多分支判断条件"},{"name":"elif体","type":"语句/代码块","desc":"条件为true时执行的代码"}]',
 '无返回值：属于Python语法关键字，非函数',
 'Python特有的多分支关键字，合并了C++的“else if”为单个关键字，简化多条件分支写法，仅能在if/else if链中使用',
 '# Python elif示例\nscore = 85\nif score >= 90:\n    print("优秀")\nelif score >= 80:\n    print("良好")  # 输出：良好\nelse:\n    print("及格")',
 '1. 与C++差异：C++写为else if（两个关键字），Python简化为elif（单个关键字）；2. 可连续写多个elif，无需嵌套if；3. 属于Python语法关键字，非函数');
 
 INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes)
VALUES
(112, 
 '[{"name":"参数","type":"任意类型","desc":"匿名函数的参数（多个用,分隔）"},{"name":"表达式","type":"任意表达式","desc":"函数返回值（仅单个表达式）"}]',
 '无返回值：属于Python语法关键字，非函数（返回匿名函数对象）',
 'Python特有的匿名函数关键字，用于快速定义简单的单行函数，无需显式用def命名，C++无等价关键字（需用函数对象/仿函数替代）',
 '# Python lambda示例\nadd = lambda a, b: a + b  # 定义匿名求和函数\nprint(add(3, 5))  # 输出：8\n# 配合列表排序\nnums = [(1,3), (2,1), (3,2)]\nnums.sort(key=lambda x: x[1])  # 按第二个元素排序\nprint(nums)  # 输出：[(2,1), (3,2), (1,3)]',
 '1. 与C++差异：C++无lambda关键字（C++11后有lambda表达式，但语法格式完全不同）；2. Python lambda仅支持单行表达式，无复杂逻辑；3. 常用于临时简单函数场景（如排序、映射）；4. 属于Python语法关键字，非函数');
 
 INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes)
VALUES
(113, 
 '[{"name":"返回值","type":"任意类型","desc":"生成器每次产出的值"},{"name":"作用范围","type":"函数","desc":"仅在函数内使用，将函数转为生成器"}]',
 '无返回值：属于Python语法关键字，非函数（产出值并暂停函数）',
 'Python特有的生成器关键字，用于将普通函数转为生成器（惰性迭代器），每次执行yield时产出值并暂停函数，C++无等价关键字（需自定义迭代器类替代）',
 '# Python yield生成器示例\ndef generate_num(n):\n    i = 0\n    while i < n:\n        yield i  # 产出值并暂停\n        i += 1\n# 惰性遍历生成器\ngen = generate_num(3)\nfor num in gen:\n    print(num)  # 输出：0 1 2',
 '1. 与C++差异：C++无yield关键字，需手动实现迭代器/协程；2. yield函数调用返回生成器对象，而非直接执行；3. 惰性生成值，节省内存（适合大数据量遍历）；4. 属于Python语法关键字，非函数');
 
 INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes)
VALUES
(114, 
 '[{"name":"上下文对象","type":"实现__enter__/__exit__的对象","desc":"如文件/锁等资源对象"},{"name":"as","type":"关键字","desc":"可选，绑定上下文对象到变量"},{"name":"代码块","type":"语句/代码块","desc":"资源使用的代码"}]',
 '无返回值：属于Python语法关键字，非函数',
 'Python特有的资源管理关键字，自动管理资源（如文件打开/关闭、锁获取/释放），执行完代码块后自动调用__exit__释放资源，C++用RAII/析构函数实现类似功能（无with关键字）',
 '# Python with操作文件（自动关闭）\nwith open("test.txt", "w") as f:\n    f.write("Hello Python")\n# 无需手动f.close()，with自动处理\n# 对比C++：需手动close或依赖析构函数',
 '1. 与C++差异：C++无with关键字，靠析构函数自动释放资源；2. with适用于所有实现上下文协议的对象（文件、锁、数据库连接等）；3. 可避免忘记释放资源导致的内存泄漏；4. 属于Python语法关键字，非函数');
 
 INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes)
VALUES
(115, 
 '[{"name":"元素","type":"任意类型","desc":"要检测的元素"},{"name":"可迭代对象","type":"list/str/dict等","desc":"要检测的容器"}]',
 '无返回值：属于Python语法关键字，非函数（返回bool值）',
 'Python特有的成员检测关键字，用于判断元素是否存在于可迭代对象中，C++无等价关键字（需用find函数/循环遍历判断）',
 '# Python in示例\n# 检测字符串子串\nprint("ll" in "hello")  # 输出：True\n# 检测列表元素\nfruits = ["apple", "banana"]\nprint("apple" in fruits)  # 输出：True\n# 对比C++：需用std::find(fruits.begin(), fruits.end(), "apple") != fruits.end()',
 '1. 与C++差异：C++无in关键字，需手动调用find/遍历；2. in支持字符串、列表、字典、集合等所有可迭代对象；3. 字典中in检测的是键，而非值；4. 属于Python语法关键字，非函数');
 
 INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes)
VALUES
(116, 
 '[{"name":"对象1","type":"任意对象","desc":"要比较的第一个对象"},{"name":"对象2","type":"任意对象","desc":"要比较的第二个对象"}]',
 '无返回值：属于Python语法关键字，非函数（返回bool值）',
 'Python特有的身份比较关键字，判断两个变量是否指向同一个内存对象（地址相同），C++无等价关键字（需用指针比较/&取地址）',
 '# Python is示例\na = [1,2,3]\nb = a\nc = [1,2,3]\nprint(a is b)  # 输出：True（同一对象）\nprint(a is c)  # 输出：False（不同对象）\nprint(a == c)  # 输出：True（值相等）\n# 对比C++：需用&a == &b判断地址是否相同',
 '1. 与C++差异：C++无is关键字，用&取地址+==比较；2. is vs ==：is判断身份（地址），==判断值；3. 小整数/短字符串有缓存，is可能返回True（如a=10, b=10，a is b为True）；4. 属于Python语法关键字，非函数');
 
 INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes)
VALUES
(117, 
 '[{"name":"变量","type":"任意类型","desc":"赋值为None的变量"},{"name":"作用","type":"空值标识","desc":"表示变量无有效值"}]',
 '无返回值：属于Python语法关键字，非函数（空值对象）',
 'Python特有的空值关键字，用于表示“无值”“空对象”，是Python的单例对象，C++用NULL（宏）/nullptr（C++11）替代，但语义和使用场景不同',
 '# Python None示例\ndef func():\n    pass  # 无返回值，默认返回None\nres = func()\nprint(res is None)  # 输出：True\n# 初始化空变量\nname = None\nif name is None:\n    name = "Python"\nprint(name)  # 输出：Python\n# 对比C++：char* ptr = nullptr;',
 '1. 与C++差异：C++无None，用NULL/nullptr（仅指针可用），Python None可赋值给任意类型变量；2. 判断None必须用is（而非==）；3. 无返回值的函数默认返回None；4. 属于Python语法关键字（特殊常量），非函数');
 
 INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes)
VALUES
(118, 
 '[{"name":"变量名","type":"标识符","desc":"要声明为全局的变量"},{"name":"作用范围","type":"函数内","desc":"仅在函数内声明全局变量"}]',
 '无返回值：属于Python语法关键字，非函数',
 'Python特有的作用域关键字，用于在函数内声明使用全局作用域的变量（修改全局变量必须声明），C++用全局变量/extern关键字（语法逻辑完全不同）',
 '# Python global示例\ncount = 0\ndef add_count():\n    global count  # 声明使用全局变量\n    count += 1\nadd_count()\nprint(count)  # 输出：1\n# 对比C++：全局变量可直接修改，无需声明（或用extern）',
 '1. 与C++差异：C++全局变量可直接在函数内修改（无需声明），Python必须用global声明才能修改全局变量；2. 仅在函数内使用，声明后函数内的变量指向全局作用域；3. 避免滥用global（易导致代码混乱）；4. 属于Python语法关键字，非函数');
 
 INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes)
VALUES
(119, 
 '[{"name":"变量名","type":"标识符","desc":"要声明的嵌套作用域变量"},{"name":"作用范围","type":"嵌套函数内","desc":"仅在嵌套函数内使用"}]',
 '无返回值：属于Python语法关键字，非函数',
 'Python特有的嵌套作用域关键字，用于在嵌套函数内声明使用外层（非全局）函数的变量，C++无等价关键字（需用引用/指针传递）',
 '# Python nonlocal示例\ndef outer():\n    count = 0\n    def inner():\n        nonlocal count  # 声明使用外层函数的变量\n        count += 1\n        return count\n    return inner\nfn = outer()\nprint(fn())  # 输出：1\nprint(fn())  # 输出：2\n# 对比C++：需将count设为引用/指针传入内层函数',
 '1. 与C++差异：C++无nonlocal关键字，嵌套函数访问外层变量需用引用/指针；2. nonlocal仅作用于嵌套函数（非全局）；3. 与global的区别：global指向全局作用域，nonlocal指向外层函数作用域；4. 属于Python语法关键字，非函数');
 
 INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes)
VALUES
(120, 
 '[{"name":"条件表达式","type":"bool","desc":"判断条件，结果为True/False"},{"name":"代码块","type":"语句/代码块","desc":"条件为True时执行的代码"}]',
 '无返回值：属于Python语法关键字，非函数',
 'Python核心条件分支关键字，根据条件表达式的布尔值决定是否执行代码块，是所有分支逻辑的基础',
 '# Python if基础示例\nage = 18\nif age >= 18:\n    print("已成年")  # 输出：已成年',
 '1. 条件表达式支持任意可转为bool的对象（0/"" /[]为False，非空/非零为True）；2. 代码块需缩进（4个空格/制表符）；3. 属于Python基础语法关键字，非函数');
 
INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes)
VALUES
(121, 
 '[{"name":"关联对象","type":"if/elif","desc":"必须跟在if/elif之后"},{"name":"代码块","type":"语句/代码块","desc":"所有if/elif条件为False时执行的代码"}]',
 '无返回值：属于Python语法关键字，非函数',
 'Python条件分支关键字，与if/elif配合使用，当所有前置条件为False时执行else代码块，是双分支逻辑的核心',
 '# Python if-else示例\nage = 17\nif age >= 18:\n    print("已成年")\nelse:\n    print("未成年")  # 输出：未成年',
 '1. else不能单独使用，必须紧跟if/elif代码块；2. 缩进需与对应if保持一致；3. 属于Python基础语法关键字，非函数');
 
 INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes)
VALUES
(122, 
 '[{"name":"循环变量","type":"任意类型","desc":"遍历可迭代对象时的临时变量"},{"name":"可迭代对象","type":"list/str/range等","desc":"要遍历的对象"},{"name":"代码块","type":"语句/代码块","desc":"每次循环执行的代码"}]',
 '无返回值：属于Python语法关键字，非函数',
 'Python核心遍历循环关键字，用于逐个遍历可迭代对象的元素，无需手动控制索引，是最常用的循环方式',
 '# Python for基础示例\n# 遍历列表\ncolors = ["red", "green", "blue"]\nfor color in colors:\n    print(color)  # 输出：red green blue\n# 遍历数字范围\nfor i in range(2):\n    print(i)  # 输出：0 1',
 '1. Python for是“foreach”风格，区别于C++的计数循环；2. 支持range()生成数字序列，实现计数循环；3. 代码块需缩进，属于基础语法关键字，非函数');
 
 INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes)
VALUES
(123, 
 '[{"name":"条件表达式","type":"bool","desc":"循环继续的条件"},{"name":"代码块","type":"语句/代码块","desc":"条件为True时执行的代码"}]',
 '无返回值：属于Python语法关键字，非函数',
 'Python条件循环关键字，只要条件表达式为True就重复执行代码块，适用于未知循环次数的场景',
 '# Python while基础示例\ni = 0\nwhile i < 3:\n    print(i)  # 输出：0 1 2\n    i += 1',
 '1. 需在循环体内修改条件变量，避免无限循环；2. 支持else子句（循环正常结束时执行）；3. 属于Python基础语法关键字，非函数');
 
 INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes)
VALUES
(124, 
 '[{"name":"作用范围","type":"循环（for/while）","desc":"仅跳出当前所在的循环"}]',
 '无返回值：属于Python语法关键字，非函数',
 'Python循环跳转关键字，用于立即终止当前所在的循环（for/while），跳出后执行循环后的代码',
 '# Python break示例\nfor i in range(5):\n    if i == 2:\n        break  # 跳出循环\n    print(i)  # 输出：0 1',
 '1. 仅跳出当前一层循环，嵌套循环需配合标志位跳出外层；2. 可用于for/while循环，属于基础语法关键字，非函数');
 
 INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes)
VALUES
(125, 
 '[{"name":"作用范围","type":"循环（for/while）","desc":"跳过当前次循环，进入下一次判断"}]',
 '无返回值：属于Python语法关键字，非函数',
 'Python循环跳转关键字，用于跳过当前循环的剩余代码，直接进入下一次循环的条件判断（不终止循环）',
 '# Python continue示例\nfor i in range(4):\n    if i == 2:\n        continue  # 跳过本次循环\n    print(i)  # 输出：0 1 3',
 '1. 与break区别：continue仅跳过本次，break终止整个循环；2. 仅适用于for/while循环，属于基础语法关键字，非函数');
 
 INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes)
VALUES
(126, 
 '[{"name":"函数名","type":"标识符","desc":"自定义的函数名称"},{"name":"参数","type":"任意类型","desc":"函数的输入（可选）"},{"name":"代码块","type":"语句/代码块","desc":"函数执行的逻辑"},{"name":"return","type":"关键字","desc":"可选，函数返回值"}]',
 '无返回值：属于Python语法关键字，非函数（定义函数对象）',
 'Python核心函数定义关键字，用于封装可复用的代码逻辑，是模块化编程的基础，定义后可通过函数名调用',
 '# Python def定义函数示例\ndef add(a, b):\n    """求和函数""" \n    return a + b\n# 调用函数\nresult = add(4, 6)\nprint(result)  # 输出：10',
 '1. 函数定义后需调用才会执行；2. 支持默认参数、可变参数等；3. 文档字符串（""" """）用于说明函数功能；4. 属于核心语法关键字，非函数');
 
 INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes)
VALUES
(127, 
 '[{"name":"类名","type":"标识符","desc":"自定义的类名称"},{"name":"父类","type":"类名","desc":"可选，继承的父类"},{"name":"类体","type":"语句/代码块","desc":"类的属性和方法"}]',
 '无返回值：属于Python语法关键字，非函数（定义类对象）',
 'Python面向对象核心关键字，用于定义类（对象的模板），封装属性（数据）和方法（行为），是实现面向对象编程的基础',
 '# Python class定义类示例\nclass Student:\n    def __init__(self, name):\n        self.name = name  # 实例属性\n    def show_name(self):\n        print(f"姓名：{self.name}")\n# 创建对象并调用方法\ns = Student("李四")\ns.show_name()  # 输出：姓名：李四',
 '1. __init__是构造方法，初始化对象属性；2. self代表实例本身，必须作为方法第一个参数；3. 支持继承、多态等面向对象特性；4. 属于核心语法关键字，非函数');
 
 INSERT INTO function_details (func_id, func_params, func_return, func_description, func_example_code, func_notes)
VALUES
(128, 
 '[{"name":"模块名","type":"标识符","desc":"要导入的模块名称"},{"name":"as","type":"关键字","desc":"可选，模块别名"},{"name":"from","type":"关键字","desc":"可选，导入模块内指定内容"}]',
 '无返回值：属于Python语法关键字，非函数',
 'Python模块导入核心关键字，用于引入外部模块/库的功能，是复用代码、扩展Python能力的基础',
 '# Python import基础示例\n# 导入整个模块\nimport math\nprint(math.sqrt(16))  # 输出：4.0\n# 导入模块指定内容\nfrom math import pi\nprint(pi)  # 输出：3.141592653589793\n# 导入并指定别名\nimport math as m\nprint(m.pow(2, 3))  # 输出：8.0',
 '1. 内置模块可直接导入，第三方模块需先安装；2. from...import...可减少代码量；3. 别名（as）避免模块名冲突；4. 属于基础语法关键字，非函数');

 
SELECT * FROM function_details;


-- 为函数名称添加索引（模糊查询用）
CREATE INDEX idx_func_name ON functions(func_name);
-- 为函数分类添加索引
CREATE INDEX idx_func_category ON functions(func_category);

CREATE DATABASE IF NOT EXISTS USERS_db;
USE  USERS_db;
-- 用户表
CREATE TABLE IF NOT EXISTS admins (
    id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(16) NOT NULL,
    password VARCHAR(64) NOT NULL,
    email CHAR(11) NOT NULL
)  DEFAULT CHARSET=utf8mb4 COMMENT = '用户表';
-- insert into admins(username,  ,  )value(   ,   ,   ) 
select*from admins


