#!/bin/bash
# openclaw200 备份监控脚本
# 创建时间：2026-04-08

set -e

BACKUP_DIR="/backups"
ALERT_THRESHOLD_HOURS=2

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}=========================================${NC}"
echo -e "${YELLOW}openclaw200 备份状态检查${NC}"
echo -e "${YELLOW}=========================================${NC}"
echo ""

# 1. 查找最新备份
echo -e "${YELLOW}查找最新备份...${NC}"
LATEST_BACKUP=$(ls -t ${BACKUP_DIR}/full/ | head -1)

if [ -z "${LATEST_BACKUP}" ]; then
    echo -e "${RED}✗ 未找到备份文件${NC}"
    exit 1
fi

echo -e "${GREEN}✓ 最新备份：${LATEST_BACKUP}${NC}"

# 2. 检查备份时间
BACKUP_TIME=$(echo ${LATEST_BACKUP} | grep -oP '\d{8}_\d{6}')
BACKUP_TIMESTAMP=$(date -d "${BACKUP_TIME:0:4}-${BACKUP_TIME:4:2}-${BACKUP_TIME:6:2} ${BACKUP_TIME:9:2}:${BACKUP_TIME:11:2}:${BACKUP_TIME:13:2}" +%s)
CURRENT_TIMESTAMP=$(date +%s)
HOURS_AGO=$(( (CURRENT_TIMESTAMP - BACKUP_TIMESTAMP) / 3600 ))

if [ ${HOURS_AGO} -gt ${ALERT_THRESHOLD_HOURS} ]; then
    echo -e "${RED}✗ 备份已过期 (${HOURS_AGO}小时前)${NC}"
    # 发送告警
    ./scripts/send-alert.sh "备份过期" "最新备份已是${HOURS_AGO}小时前"
    exit 1
else
    echo -e "${GREEN}✓ 备份时间正常 (${HOURS_AGO}小时前)${NC}"
fi

# 3. 检查备份大小
BACKUP_SIZE=$(du -sm ${BACKUP_DIR}/full/${LATEST_BACKUP} | cut -f1)
if [ ${BACKUP_SIZE} -lt 100 ]; then
    echo -e "${RED}✗ 备份文件过小 (${BACKUP_SIZE}MB)${NC}"
    ./scripts/send-alert.sh "备份异常" "备份文件大小异常：${BACKUP_SIZE}MB"
    exit 1
else
    echo -e "${GREEN}✓ 备份大小正常 (${BACKUP_SIZE}MB)${NC}"
fi

# 4. 验证校验和
echo -e "${YELLOW}验证校验和...${NC}"
cd ${BACKUP_DIR}/full/${LATEST_BACKUP}
if md5sum -c checksums.md5 > /dev/null 2>&1; then
    echo -e "${GREEN}✓ 校验和验证通过${NC}"
else
    echo -e "${RED}✗ 校验和验证失败${NC}"
    ./scripts/send-alert.sh "备份损坏" "校验和验证失败"
    exit 1
fi

# 5. 检查磁盘空间
DISK_USAGE=$(df -h ${BACKUP_DIR} | tail -1 | awk '{print $5}' | sed 's/%//')
if [ ${DISK_USAGE} -gt 90 ]; then
    echo -e "${RED}✗ 磁盘空间不足 (使用率${DISK_USAGE}%)${NC}"
    ./scripts/send-alert.sh "磁盘告警" "备份磁盘使用率${DISK_USAGE}%"
    exit 1
else
    echo -e "${GREEN}✓ 磁盘空间正常 (使用率${DISK_USAGE}%)${NC}"
fi

echo ""
echo "========================================="
echo -e "${GREEN}所有检查通过!${NC}"
echo "========================================="

# 生成状态报告
cat << EOF
备份状态报告
============
最新备份：${LATEST_BACKUP}
备份时间：${HOURS_AGO}小时前
备份大小：${BACKUP_SIZE}MB
校验和：验证通过
磁盘使用：${DISK_USAGE}%
状态：正常
EOF
