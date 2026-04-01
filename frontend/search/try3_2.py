
from collections import defaultdict
import pymysql  # MySQL数据库驱动
from functools import lru_cache
import time
import concurrent.futures  # 添加并行处理

# ========== 第一步：Trie树数据结构 - 快速前缀搜索 ==========
class TrieNode:
    """Trie树节点"""
    def __init__(self):
        self.children = {}
        self.is_end = False
        self.value = None  # 存储完整的字符串

class Trie:
    """Trie树 - 用于快速前缀匹配"""
    def __init__(self):
        self.root = TrieNode()
    
    def insert(self, word, value=None):
        """插入单词"""
        node = self.root
        for char in word.lower():
            if char not in node.children:
                node.children[char] = TrieNode()
            node = node.children[char]
        node.is_end = True
        node.value = value or word
    
    def prefix_search(self, prefix):
        """前缀搜索 - 返回所有以prefix开头的单词"""
        results = []
        node = self.root
        for char in prefix.lower():
            if char not in node.children:
                return results
            node = node.children[char]
        
        # DFS获取所有完匹配
        def dfs(node):
            if node.is_end:
                results.append(node.value)
            for child in node.children.values():
                dfs(child)
        
        dfs(node)
        return results

# ========== 第二步：优化的搜索类 ==========
class CppSyntaxSearcher:
    def __init__(self, syntax_entries=None, syntax_links=None, damping_factor=0.85, max_iter=100, tol=1e-6):
        self.damping_factor = damping_factor
        self.max_iter = max_iter
        self.tol = tol
        self.syntax_entries = syntax_entries or []
        self.syntax_links = syntax_links or defaultdict(list)
        self.pr_scores = {}
        
        # 构建Trie树用于快速前缀搜索
        self.trie = Trie()
        for entry in self.syntax_entries:
            self.trie.insert(entry)
        
        # 缓存：查询 -> 搜索结果
        self._search_cache = {}
        # 缓存：查询 -> PageRank有序结果
        self._ranked_cache = {}
        
        # 初始化时自动计算PageRank
        self.compute_pagerank()

    @staticmethod
    @lru_cache(maxsize=10000)
    def _levenshtein(s, t):
        """使用LRU缓存的编辑距离计算 - 优化版本"""
        m, n = len(s), len(t)
        if m == 0: return n
        if n == 0: return m
        
        # 优化：使用一维数组代替二维，并添加提前退出
        if abs(m - n) > 3:  # 对于长度差异大的字符串，快速返回
            return max(m, n)
        
        prev = list(range(n + 1))
        for i in range(1, m + 1):
            curr = [i] + [0] * n
            min_val = i  # 跟踪当前行的最小值
            for j in range(1, n + 1):
                if s[i - 1] == t[j - 1]:
                    curr[j] = prev[j - 1]
                else:
                    curr[j] = min(prev[j], curr[j - 1], prev[j - 1]) + 1
                min_val = min(min_val, curr[j])
            if min_val > 3:  # 如果当前行最小值已超过阈值，提前退出
                return min_val
            prev = curr
        return prev[n]

    def _get_prefix_score(self, query, candidate):
        """计算前缀匹配分数 (0-1)"""
        query_lower = query.lower()
        candidate_lower = candidate.lower()
        if candidate_lower.startswith(query_lower):
            # 完全前缀匹配得分更高
            return 1.0 - (len(candidate_lower) - len(query_lower)) / len(candidate_lower)
        count = 0
        for i, char in enumerate(query_lower):
            if i < len(candidate_lower) and candidate_lower[i] == char:
                count += 1
        return count / len(query_lower)

    def _dynamic_threshold(self, query_len):
        """根据查询长度动态调整编辑距离阈值"""
        # 短查询(<3) -> 阈值1, 中等(3-5) -> 2, 长查询(>5) -> 3
        if query_len < 3:
            return 1
        elif query_len < 6:
            return 2
        else:
            return 3

    def _fuzzy_search(self, query, threshold=None):
        """改进的模糊搜索 - 使用缓存和优化策略，并行处理大型数据集"""
        cache_key = f"{query}_{threshold}"
        if cache_key in self._search_cache:
            return self._search_cache[cache_key]
        
        query_lower = query.lower()
        
        # 第一步：用Trie树快速过滤前缀匹配项
        prefix_matches = self.trie.prefix_search(query)
        
        # 第二步：如果前缀匹配足够多，优先使用前缀匹配结果
        if len(prefix_matches) >= 10:  # 阈值可调
            results = prefix_matches
        else:
            # 否则进行编辑距离搜索
            if threshold is None:
                threshold = self._dynamic_threshold(len(query))
            
            # 对于大型数据集，使用并行处理
            if len(self.syntax_entries) > 1000:
                results = self._parallel_fuzzy_search(query_lower, threshold)
            else:
                results = []
                for cand in self.syntax_entries:
                    dist = self._levenshtein(query_lower, cand.lower())
                    if dist <= threshold:
                        results.append((cand, dist))
                results.sort(key=lambda x: x[1])
                results = [item[0] for item in results]
        
        # 缓存结果
        self._search_cache[cache_key] = results
        return results
    
    def _parallel_fuzzy_search(self, query_lower, threshold):
        """并行模糊搜索"""
        def compute_distance(cand):
            dist = self._levenshtein(query_lower, cand.lower())
            return (cand, dist) if dist <= threshold else None
        
        with concurrent.futures.ThreadPoolExecutor(max_workers=4) as executor:
            futures = [executor.submit(compute_distance, cand) for cand in self.syntax_entries]
            results = []
            for future in concurrent.futures.as_completed(futures):
                result = future.result()
                if result:
                    results.append(result)
        
        results.sort(key=lambda x: x[1])
        return [item[0] for item in results]

    def _compute_combined_score(self, query, candidate, pr_score, edit_dist):
        """计算综合得分：PageRank + 编辑距离 + 前缀匹配度"""
        prefix_score = self._get_prefix_score(query, candidate)
        
        # 归一化编辑距离 (0-1，越小越好)
        edit_dist_score = 1.0 / (1.0 + edit_dist)
        
        # 加权组合：前缀匹配(40%) + PageRank(35%) + 编辑距离(25%)
        combined = (prefix_score * 0.4 + 
                   (pr_score / max(1.0, max(self.pr_scores.values())) if self.pr_scores else 0) * 0.35 +
                   edit_dist_score * 0.25)
        return combined

    def compute_pagerank(self):
        """优化的PageRank计算 - 添加收敛检测和加速"""
        nodes = list(self.syntax_links.keys())
        N = len(nodes)
        if N == 0:
            self.pr_scores = {}
            return

        pr = {node: 1.0 / N for node in nodes}
        out_degree = {node: max(1, len(self.syntax_links[node])) for node in nodes}
        
        # 预计算入度，用于加速
        in_links = defaultdict(list)
        for node, links in self.syntax_links.items():
            for link in links:
                in_links[link].append(node)
        
        for iteration in range(self.max_iter):
            new_pr = {}
            max_diff = 0.0
            for node in nodes:
                in_contrib = sum(pr[other] / out_degree[other] for other in in_links[node])
                new_pr[node] = (1 - self.damping_factor) / N + self.damping_factor * in_contrib
                max_diff = max(max_diff, abs(new_pr[node] - pr[node]))
            
            pr = new_pr
            if max_diff < self.tol:
                break

        self.pr_scores = pr

    def search(self, query, fuzzy_threshold=None, multi_keyword=False):
        """改进的搜索方法 - 使用综合评分，支持多关键词"""
        if multi_keyword and ' ' in query:
            # 多关键词搜索：分别搜索每个关键词，取交集
            keywords = query.split()
            candidate_sets = []
            for kw in keywords:
                cands = self._fuzzy_search(kw.strip(), threshold=fuzzy_threshold)
                candidate_sets.append(set(cands))
            
            # 取所有关键词的交集
            candidates = list(set.intersection(*candidate_sets)) if candidate_sets else []
        else:
            candidates = self._fuzzy_search(query, threshold=fuzzy_threshold)
        
        if not candidates:
            return []
        
        # 计算每个候选的综合得分
        scored_candidates = []
        query_lower = query.lower()
        
        for cand in candidates:
            pr_score = self.pr_scores.get(cand, 0.0)
            edit_dist = self._levenshtein(query_lower, cand.lower())
            combined_score = self._compute_combined_score(query, cand, pr_score, edit_dist)
            scored_candidates.append((cand, combined_score, pr_score, edit_dist))
        
        # 按综合得分降序排序
        scored_candidates.sort(key=lambda x: -x[1])
        return [cand for cand, _, _, _ in scored_candidates]

    def update_entries(self, new_entries):
        """更新条目并清除缓存"""
        self.syntax_entries = new_entries
        self.trie = Trie()  # 重建Trie树
        for entry in self.syntax_entries:
            self.trie.insert(entry)
        self._search_cache.clear()  # 清除搜索缓存
        self._ranked_cache.clear()
        self.compute_pagerank()

    def update_links(self, new_links):
        """更新链接关系"""
        self.syntax_links = defaultdict(list, new_links)
        self._ranked_cache.clear()  # 清除排序缓存
        self.compute_pagerank()

# ========== 第二步：编写数据库操作类 ==========
class SyntaxDBHandler:
    def __init__(self, host='localhost', user='root', password=None, db='language_function_db', charset='utf8mb4'):
        import os
        # 使用环境变量或默认值
        self.password = password or os.environ.get('DB_PASSWORD', 'Zhchzh100!')
        # 初始化数据库连接
        self.conn = pymysql.connect(
            host=host,
            user=user,
            password=self.password,
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
            f.func_id,
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

    def search_func(self, query, fuzzy_threshold=3, multi_keyword=False):
        """
        搜索指定函数，返回带详情的结果
        :param query: 搜索关键词，如果为空则返回所有函数
        :param fuzzy_threshold: 模糊匹配阈值（编辑距离）
        :param multi_keyword: 是否启用多关键词搜索
        :return: 列表，每个元素是函数详情字典，包含相关性信息
        """
        # 如果查询为空，返回所有函数
        if not query or query.strip() == "":
            matched_funcs = self.func_entries
            func_with_scores = [(name, 0.0, 0) for name in matched_funcs]  # 默认相关性
        else:
            # 1. 调用模糊搜索获取候选
            candidates = self.searcher.search(query, fuzzy_threshold=fuzzy_threshold, multi_keyword=multi_keyword)
            if not candidates:
                return []
            # 2. 计算每个候选的相关性分数
            candidates_with_pr = [
                (cand, self.searcher.pr_scores.get(cand, 0.0), self.searcher._levenshtein(query.lower(), cand.lower()))
                for cand in candidates
            ]
            # 计算综合得分
            candidates_with_pr = [
                (cand, pr_score, dist, self.searcher._compute_combined_score(query, cand, pr_score, dist))
                for cand, pr_score, dist in candidates_with_pr
            ]
            # 3. 排序：综合得分降序（编辑距离升序作为次要）
            candidates_with_pr.sort(key=lambda x: (-x[3], x[2]))
            func_with_scores = candidates_with_pr
        
        # 4. 从数据库获取每个函数的详情，并添加相关性分数
        results = []
        for func_name, pr_score, dist, combined_score in func_with_scores:
            details = self.db_handler.get_func_details(func_name, self.lang_name)
            if details:
                details['relevance'] = combined_score  # 添加综合得分作为相关性
                details['edit_distance'] = dist  # 添加编辑距离
                results.append(details)
        return results

# ========== 测试示例 ==========
if __name__ == '__main__':
    # 配置数据库（使用环境变量或默认值）
    import os
    db_config = {
        'host': 'localhost',
        'user': 'root',
        'password': os.environ.get('DB_PASSWORD', 'Zhchzh100!'),
        'db': 'language_function_db'
    }

    # 初始化C++语法搜索器（可替换为Python/Java等）
    cpp_search = IntegratedSyntaxSearch(lang_name='C++', db_config=db_config)

    # 测试模糊搜索（比如输入"print"，匹配"printf"/"println"等）
    search_results = cpp_search.search_func(query='print', fuzzy_threshold=2)

    # 打印结果
    print("单关键词搜索结果：")
    for idx, func in enumerate(search_results[:5], 1):  # 只显示前5个
        print(f"\n{idx}. 函数名：{func['func_name']}")
        print(f"   分类：{func['func_category']}")
        print(f"   描述：{func['func_description']}")
        print(f"   相关性：{func['relevance']:.4f}")
    
    # 测试多关键词搜索
    multi_results = cpp_search.search_func(query='string find', fuzzy_threshold=2, multi_keyword=True)
    print("\n\n多关键词搜索结果（'string find'）：")
    for idx, func in enumerate(multi_results[:5], 1):
        print(f"\n{idx}. 函数名：{func['func_name']}")
        print(f"   分类：{func['func_category']}")
        print(f"   描述：{func['func_description']}")
        print(f"   相关性：{func['relevance']:.4f}")
        print(f"   描述：{func['func_description']}")
        print(f"   示例代码：{func['func_example_code']}")