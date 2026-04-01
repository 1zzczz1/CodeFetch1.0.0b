import time
import logging

# 配置日志
logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

logger.info("Test script started")
print("Hello from Python!")

# 模拟长时间运行
for i in range(10):
    logger.info(f"Running iteration {i}")
    print(f"Iteration {i}")
    time.sleep(1)

logger.info("Test script finished")
print("Test script finished")
