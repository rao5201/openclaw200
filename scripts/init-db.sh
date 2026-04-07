#!/bin/bash
# openclaw200 数据库初始化脚本
# 创建时间：2026-04-08

set -e

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}=========================================${NC}"
echo -e "${YELLOW}openclaw200 中央数据库初始化${NC}"
echo -e "${YELLOW}=========================================${NC}"
echo ""

# 1. 检查 Docker 是否运行
echo -e "${YELLOW}[1/4] 检查 Docker 服务...${NC}"
if ! docker-compose ps | grep -q "Up"; then
    echo -e "${RED}错误：Docker 服务未运行${NC}"
    echo "请先运行：docker-compose up -d"
    exit 1
fi
echo -e "${GREEN}✓ Docker 服务已运行${NC}"

# 2. 等待数据库就绪
echo -e "${YELLOW}[2/4] 等待数据库就绪...${NC}"
sleep 5
echo -e "${GREEN}✓ 数据库已就绪${NC}"

# 3. 运行初始化脚本
echo -e "${YELLOW}[3/4] 运行数据库初始化脚本...${NC}"
docker-compose exec -T db psql -U postgres -d rao5201_db -f /tmp/init-database.sql || \
  docker cp scripts/init-database.sql $(docker-compose ps -q db):/tmp/init-database.sql
docker-compose exec -T db psql -U postgres -d rao5201_db -f /tmp/init-database.sql

echo -e "${GREEN}✓ 数据库初始化完成${NC}"

# 4. 验证数据
echo -e "${YELLOW}[4/4] 验证数据...${NC}"
USER_COUNT=$(docker-compose exec -T db psql -U postgres -d rao5201_db -t -c "SELECT COUNT(*) FROM users;")
PROJECT_COUNT=$(docker-compose exec -T db psql -U postgres -d rao5201_db -t -c "SELECT COUNT(*) FROM projects;")

echo ""
echo "========================================="
echo -e "${GREEN}数据库初始化完成!${NC}"
echo "========================================="
echo "用户数量：${USER_COUNT}"
echo "项目数量：${PROJECT_COUNT}"
echo ""
echo "默认管理员:"
echo "  邮箱：rao5201@126.com"
echo "  密码：admin123 (请立即修改)"
echo "========================================="
