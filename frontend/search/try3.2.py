
from collections import defaultdict
import pymysql  # MySQL数据库驱动

# ========== 第一步：复用同学的搜索类 ==========
class CppSyntaxSearcher:
    def __init__(self, syntax_entries=None, syntax_links=None, damping_factor=0.85, max_iter=100, tol=1e-6):
        self.damping_factor = damping_factor
        self.max_iter = max_iter
        self.tol = tol
        self.syntax_entries = syntax_entries or []
        self.syntax_links = syntax_links or defaultdict(list)
        self.pr_scores = {}
        # 初始化时自动计算PageRank
        self.compute_pagerank()

    # 替换原来依赖NumPy的_levenshtein函数
    def _levenshtein(self, s, t):
        if len(s) > len(t):
            s, t = t, s
        m, n = len(s), len(t)
        # 用纯Python列表替换np.arange，避免NumPy依赖
        dp = list(range(m + 1))  # 替代np.arange(m + 1)
        for j in range(1, n + 1):
            prev = dp[0]
            dp[0] = j
            for i in range(1, m + 1):
                temp = dp[i]
                if s[i - 1] == t[j - 1]:
                    dp[i] = prev
                else:
                    dp[i] = min(dp[i], dp[i - 1], prev) + 1
                prev = temp
        return dp[m]

    def _fuzzy_search(self, query, threshold=3):
        results = []
        query_lower = query.lower()
        for cand in self.syntax_entries:
            dist = self._levenshtein(query_lower, cand.lower())
            if dist <= threshold:
                results.append((cand, dist))
        results.sort(key=lambda x: x[1])
        return [item[0] for item in results]

    def compute_pagerank(self):
        nodes = list(self.syntax_links.keys())
        N = len(nodes)
        if N == 0:
            self.pr_scores = {}
            return

        pr = {node: 1.0 / N for node in nodes}
        out_degree = {node: len(self.syntax_links[node]) for node in nodes}

        for _ in range(self.max_iter):
            new_pr = {}
            for node in nodes:
                in_contrib = 0.0
                for other in nodes:
                    if node in self.syntax_links[other]:
                        if out_degree[other] > 0:
                            in_contrib += pr[other] / out_degree[other]
                new_pr[node] = (1 - self.damping_factor) / N + self.damping_factor * in_contrib

            diff = sum(abs(new_pr[node] - pr[node]) for node in nodes)
            pr = new_pr
            if diff < self.tol:
                break

        self.pr_scores = pr

    def search(self, query, fuzzy_threshold=3):
        candidates = self._fuzzy_search(query, threshold=fuzzy_threshold)
        if not candidates:
            return []
        candidates_with_pr = [
            (cand, self.pr_scores.get(cand, 0.0), self._levenshtein(query.lower(), cand.lower()))
            for cand in candidates
        ]
        # 排序规则：PageRank分数降序 → 编辑距离升序
        candidates_with_pr.sort(key=lambda x: (-x[1], x[2]))
        return [cand for cand, _, _ in candidates_with_pr]

    def update_entries(self, new_entries):
        self.syntax_entries = new_entries
        # 更新条目后重新计算PageRank
        self.compute_pagerank()

    def update_links(self, new_links):
        self.syntax_links = defaultdict(list, new_links)
        self.compute_pagerank()

# ========== 第二步：编写数据库操作类 ==========
class SyntaxDBHandler:
    def __init__(self, host='localhost', user='root', password='Zhchzh100!', db='language_function_db', charset='utf8mb4'):
        # 初始化数据库连接
        self.conn = pymysql.connect(
            host=host,
            user=user,
            password=password,
            database=db,
            charset=charset
        )
        self.cursor = self.conn.cursor(pymysql.cursors.DictCursor)  # 返回字典格式的结果

    def __del__(self):
        # 析构函数：关闭数据库连接
        if hasattr(self, 'conn') and self.conn.open:
            self.cursor.close()
            self.conn.close()

    def get_lang_functions(self, lang_name):
        """
        获取指定编程语言的所有函数名（作为搜索的entries）
        :param lang_name: 编程语言名称（如C++、Python）
        :return: 函数名列表
        """
        sql = """
        SELECT f.func_name 
        FROM functions f
        JOIN languages l ON f.lang_id = l.lang_id
        WHERE l.lang_name = %s
        """
        self.cursor.execute(sql, (lang_name,))
        results = self.cursor.fetchall()
        # 提取函数名列表
        func_names = [item['func_name'] for item in results]
        return func_names

    def get_func_relations(self, lang_name):
        """
        获取指定编程语言的函数关联关系（用于PageRank）
        逻辑：同一分类的函数互相链接（如所有字符串函数互相关联）
        :param lang_name: 编程语言名称
        :return: 字典 {函数名: [关联函数名列表]}
        """
        # 1. 获取该语言的函数分类和函数名映射
        sql = """
        SELECT f.func_name, f.func_category 
        FROM functions f
        JOIN languages l ON f.lang_id = l.lang_id
        WHERE l.lang_name = %s AND f.func_category IS NOT NULL
        """
        self.cursor.execute(sql, (lang_name,))
        results = self.cursor.fetchall()

        # 2. 按分类分组
        category_funcs = defaultdict(list)
        for item in results:
            category_funcs[item['func_category']].append(item['func_name'])

        # 3. 构建关联关系：同一分类的函数互相链接
        func_relations = defaultdict(list)
        for category, funcs in category_funcs.items():
            for func in funcs:
                # 关联同分类的其他函数（排除自己）
                related_funcs = [f for f in funcs if f != func]
                func_relations[func] = related_funcs

        return func_relations

    def get_func_details(self, func_name, lang_name):
        """
        获取函数的完整详情（搜索结果展示用）
        :param func_name: 函数名
        :param lang_name: 编程语言名称
        :return: 函数详情字典
        """
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
        WHERE l.lang_name = %s AND f.func_name = %s
        """
        self.cursor.execute(sql, (lang_name, func_name))
        return self.cursor.fetchone()

# ========== 第三步：整合搜索类和数据库 ==========
class IntegratedSyntaxSearch:
    def __init__(self, lang_name, db_config=None):
        """
        :param lang_name: 要搜索的编程语言（如C++）
        :param db_config: 数据库配置字典 {'host':..., 'user':..., 'password':...}
        """
        db_config = db_config or {'host':'localhost', 'user':'root', 'password':'你的密码'}
        # 1. 初始化数据库处理器
        self.db_handler = SyntaxDBHandler(**db_config)
        # 2. 从数据库读取函数名和关联关系
        self.func_entries = self.db_handler.get_lang_functions(lang_name)
        self.func_relations = self.db_handler.get_func_relations(lang_name)
        # 3. 初始化搜索器
        self.searcher = CppSyntaxSearcher(
            syntax_entries=self.func_entries,
            syntax_links=self.func_relations
        )
        self.lang_name = lang_name

    def search_func(self, query, fuzzy_threshold=3):
        """
        搜索指定函数，返回带详情的结果
        :param query: 搜索关键词，如果为空则返回所有函数
        :param fuzzy_threshold: 模糊匹配阈值（编辑距离）
        :return: 列表，每个元素是函数详情字典
        """
        # 如果查询为空，返回所有函数
        if not query or query.strip() == "":
            matched_funcs = self.func_entries
        else:
            # 1. 调用模糊搜索获取排序后的函数名
            matched_funcs = self.searcher.search(query, fuzzy_threshold)
        
        if not matched_funcs:
            return []
        # 2. 从数据库获取每个函数的详情
        results = []
        for func_name in matched_funcs:
            details = self.db_handler.get_func_details(func_name, self.lang_name)
            if details:
                results.append(details)
        return results
        for func_name in matched_funcs:
            details = self.db_handler.get_func_details(func_name, self.lang_name)
            if details:
                results.append(details)
        return results

# ========== 测试示例 ==========
if __name__ == '__main__':
    # 配置数据库（替换为你的实际配置）
    db_config = {
        'host': 'localhost',
        'user': 'root',
        'password': 'Zhchzh100!',  # 替换为你的MySQL密码
        'db': 'language_function_db'
    }

    # 初始化C++语法搜索器（可替换为Python/Java等）
    cpp_search = IntegratedSyntaxSearch(lang_name='C++', db_config=db_config)

    # 测试模糊搜索（比如输入"print"，匹配"printf"/"println"等）
    search_results = cpp_search.search_func(query='print', fuzzy_threshold=2)

    # 打印结果
    print("搜索结果：")
    for idx, func in enumerate(search_results, 1):
        print(f"\n{idx}. 函数名：{func['func_name']}")
        print(f"   分类：{func['func_category']}")
        print(f"   描述：{func['func_description']}")
        print(f"   示例代码：{func['func_example_code']}")