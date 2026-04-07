#!/bin/bash
# openclaw200 全量备份脚本
# 创建时间：2026-04-08

set -e

# 配置
BACKUP_DIR="/backups/full/$(date +%Y%m%d_%H%M%S)"
DB_NAME="rao5201_db"
DB_USER="postgres"
RETENTION_DAYS=30

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}=========================================${NC}"
echo -e "${YELLOW}openclaw200 全量备份${NC}"
echo -e "${YELLOW}=========================================${NC}"
echo ""

# 1. 创建备份目录
echo -e "${YELLOW}[1/6] 创建备份目录...${NC}"
mkdir -p ${BACKUP_DIR}
echo -e "${GREEN}✓ 备份目录已创建${NC}"

# 2. PostgreSQL 备份
echo -e "${YELLOW}[2/6] 备份 PostgreSQL 数据库...${NC}"
docker-compose exec db pg_dump -U ${DB_USER} ${DB_NAME} | gzip > ${BACKUP_DIR}/${DB_NAME}.sql.gz
echo -e "${GREEN}✓ PostgreSQL 备份完成${NC}"

# 3. Redis 备份
echo -e "${YELLOW}[3/6] 备份 Redis 数据...${NC}"
docker-compose exec redis redis-cli BGSAVE
sleep 5
cp /var/lib/redis/dump.rdb ${BACKUP_DIR}/redis_dump.rdb 2>/dev/null || echo "⊘ Redis 备份跳过"
echo -e "${GREEN}✓ Redis 备份完成${NC}"

# 4. 配置文件备份
echo -e "${YELLOW}[4/6] 备份配置文件...${NC}"
cp .env ${BACKUP_DIR}/ 2>/dev/null || true
cp docker-compose.yml ${BACKUP_DIR}/ 2>/dev/null || true
cp -r config/ ${BACKUP_DIR}/ 2>/dev/null || true
echo -e "${GREEN}✓ 配置文件备份完成${NC}"

# 5. 计算校验和
echo -e "${YELLOW}[5/6] 计算校验和...${NC}"
cd ${BACKUP_DIR}
md5sum * > checksums.md5
echo -e "${GREEN}✓ 校验和已计算${NC}"

# 6. 清理旧备份
echo -e "${YELLOW}[6/6] 清理旧备份 (保留${RETENTION_DAYS}天)...${NC}"
find /backups/full -mtime +${RETENTION_DAYS} -delete
echo -e "${GREEN}✓ 清理完成${NC}"

# 显示备份信息
echo ""
echo "========================================="
echo -e "${GREEN}备份完成!${NC}"
echo "========================================="
echo "备份目录：${BACKUP_DIR}"
echo "备份大小：$(du -sh ${BACKUP_DIR} | cut -f1)"
echo "保留期限：${RETENTION_DAYS} 天"
echo "========================================="

# 上传到云存储（如果配置）
if [ -n "${AWS_ACCESS_KEY_ID}" ]; then
    echo "上传到 S3..."
    aws s3 sync ${BACKUP_DIR} s3://${S3_BUCKET}/backups/full/$(date +%Y%m%d_%H%M%S)/
fi
