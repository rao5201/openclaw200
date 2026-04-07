# openclaw200 - 中央数据库备份中心

**版本**: V1.0  
**创建时间**: 2026-04-08  
**描述**: 统一管理 rao5201 所有项目的数据库备份

---

## 📋 目录

1. [架构概述](#架构概述)
2. [快速开始](#快速开始)
3. [备份管理](#备份管理)
4. [恢复指南](#恢复指南)
5. [监控告警](#监控告警)
6. [API 接口](#api-接口)

---

## 架构概述

### 整体架构

```
┌─────────────────────────────────────────────────────────┐
│            中央数据库备份中心 (Backup Hub)               │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │  定时备份   │  │  手动备份   │  │  云同步     │     │
│  │  Scheduler  │  │  Manual     │  │  Cloud Sync │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
│         ↓                ↓                ↓             │
│  ┌─────────────────────────────────────────────────┐   │
│  │           备份存储中心 (Storage Hub)             │   │
│  │  - 本地存储：/backups                           │   │
│  │  - 云存储：S3/OSS/七牛云                         │   │
│  │  - 归档存储：冷备份                              │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
         ↓                ↓                ↓
┌─────────────────────────────────────────────────────────┐
│                    项目数据库层                          │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐         │
│  │CHXWAI│ │TSSKMS│ │email │ │ 99app│ │ ... │         │
│  └──────┘ └──────┘ └──────┘ └──────┘ └──────┘         │
└─────────────────────────────────────────────────────────┘
```

### 备份策略

| 数据类型 | 备份频率 | 保留时间 | 存储位置 |
|---------|---------|---------|---------|
| 核心数据库 | 每小时 | 30 天 | 本地 + 云 |
| 日志数据 | 每天 | 7 天 | 本地 |
| 配置文件 | 每次变更 | 永久 | 本地 + 云 |
| 归档数据 | 每周 | 1 年 | 冷存储 |

---

## 快速开始

### 1. 克隆仓库

```bash
git clone https://github.com/rao5201/openclaw200.git
cd openclaw200
```

### 2. 配置环境

```bash
# 复制环境变量
cp .env.example .env

# 编辑配置
vim .env
```

### 3. 启动备份服务

```bash
# Docker 部署
docker-compose up -d

# 查看服务状态
docker-compose ps
```

### 4. 执行首次备份

```bash
# 备份所有数据库
./scripts/backup-all.sh

# 查看备份文件
ls -lh backups/
```

---

## 备份管理

### 自动备份（定时任务）

```bash
# 编辑 crontab
crontab -e

# 添加定时任务
# 每小时备份核心数据库
0 * * * * /path/to/openclaw200/scripts/backup-core.sh

# 每天凌晨 2 点全量备份
0 2 * * * /path/to/openclaw200/scripts/backup-full.sh

# 每周日归档备份
0 3 * * 0 /path/to/openclaw200/scripts/backup-archive.sh
```

### 手动备份

```bash
# 备份所有数据库
./scripts/backup-all.sh

# 备份指定数据库
./scripts/backup-db.sh rao5201_db

# 备份配置文件
./scripts/backup-config.sh

# 查看备份状态
./scripts/backup-status.sh
```

### 备份脚本

#### backup-all.sh（全量备份）

```bash
#!/bin/bash
# 全量备份所有数据库

BACKUP_DIR="/backups/full/$(date +%Y%m%d_%H%M%S)"
mkdir -p $BACKUP_DIR

# PostgreSQL 备份
docker-compose exec db pg_dump -U postgres rao5201_db | gzip > $BACKUP_DIR/rao5201_db.sql.gz

# Redis 备份
docker-compose exec redis redis-cli BGSAVE
sleep 5
cp /var/lib/redis/dump.rdb $BACKUP_DIR/redis_dump.rdb

# 配置文件备份
cp .env $BACKUP_DIR/
cp docker-compose.yml $BACKUP_DIR/

# 计算校验和
cd $BACKUP_DIR
md5sum * > checksums.md5

# 清理旧备份（保留 30 天）
find /backups/full -mtime +30 -delete

echo "全量备份完成：$BACKUP_DIR"
```

#### backup-incremental.sh（增量备份）

```bash
#!/bin/bash
# 增量备份（仅备份变更的数据）

BACKUP_DIR="/backups/incremental/$(date +%Y%m%d_%H%M%S)"
mkdir -p $BACKUP_DIR

# PostgreSQL WAL 日志备份
docker-compose exec db pg_dump -U postgres rao5201_db --data-only | gzip > $BACKUP_DIR/data_only.sql.gz

# 只备份变更的配置文件
rsync -av --backup --suffix=.bak config/ $BACKUP_DIR/config/

echo "增量备份完成：$BACKUP_DIR"
```

---

## 恢复指南

### 恢复整个数据库

```bash
# 1. 停止服务
docker-compose down

# 2. 解压备份文件
cd /backups/full/20260408_020000
gunzip rao5201_db.sql.gz

# 3. 恢复数据库
docker-compose up -d db
sleep 10
docker-compose exec -T db psql -U postgres -c "DROP DATABASE IF EXISTS rao5201_db;"
docker-compose exec -T db psql -U postgres -c "CREATE DATABASE rao5201_db;"
docker-compose exec -T db psql -U postgres -d rao5201_db < rao5201_db.sql

# 4. 恢复 Redis
docker-compose exec redis redis-cli < redis_dump.rdb

# 5. 重启服务
docker-compose up -d
```

### 恢复单个表

```bash
# 从备份中恢复单个表
docker-compose exec -T db psql -U postgres -d rao5201_db << 'EOF'
-- 删除旧表
DROP TABLE IF EXISTS users CASCADE;

-- 从备份恢复
\i /backups/tables/users.sql
EOF
```

### 时间点恢复（PITR）

```bash
# 1. 找到最近的基准备份
ls -lt /backups/full/

# 2. 恢复基准备份
gunzip /backups/full/20260408_020000/rao5201_db.sql.gz
docker-compose exec -T db psql -U postgres -d rao5201_db < /backups/full/20260408_020000/rao5201_db.sql

# 3. 应用 WAL 日志
docker-compose exec db pg_waldump /var/lib/postgresql/data/pg_wal/

# 4. 恢复到指定时间点
docker-compose exec -T db psql -U postgres -d rao5201_db << 'EOF'
SELECT pg_recovery_target_timeline();
EOF
```

---

## 监控告警

### 备份监控

```bash
# 检查最新备份
./scripts/check-backup-status.sh

# 预期输出：
# ✓ 最新备份：2026-04-08 02:00:00 (2 小时前)
# ✓ 备份大小：1.2GB
# ✓ 校验和：验证通过
```

### 告警配置

```yaml
# monitoring/alerts/backup-alerts.yml
groups:
  - name: backup_alerts
    rules:
      - alert: BackupFailed
        expr: backup_success == 0
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "备份失败"
          description: "最新备份失败，请立即检查"
      
      - alert: BackupOld
        expr: time() - backup_last_timestamp > 7200
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "备份过期"
          description: "最新备份超过 2 小时"
      
      - alert: BackupSizeSmall
        expr: backup_size_bytes < 100000000
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "备份文件过小"
          description: "备份文件大小异常，可能备份不完整"
```

### 通知渠道

```bash
# 配置通知
vim config/notifications.yml

# 支持的通知方式：
# - 邮件通知
# - 钉钉机器人
# - 企业微信
# - Slack
# - Webhook
```

---

## API 接口

### 备份管理 API

```http
# 创建备份
POST /api/v1/backups
Content-Type: application/json

{
  "type": "full",  // full, incremental, archive
  "databases": ["rao5201_db", "redis"],
  "compress": true,
  "encrypt": true
}

# 响应
{
  "success": true,
  "data": {
    "backup_id": "backup_20260408_035000",
    "status": "running",
    "estimated_time": "5-10 分钟"
  }
}
```

```http
# 查询备份列表
GET /api/v1/backups?limit=10&offset=0

# 响应
{
  "success": true,
  "data": {
    "total": 156,
    "backups": [
      {
        "backup_id": "backup_20260408_020000",
        "type": "full",
        "size": "1.2GB",
        "created_at": "2026-04-08T02:00:00Z",
        "status": "completed",
        "checksum": "md5:abc123..."
      }
    ]
  }
}
```

```http
# 恢复备份
POST /api/v1/backups/{backup_id}/restore
Content-Type: application/json

{
  "target": "rao5201_db",
  "mode": "overwrite",  // overwrite, merge, skip
  "verify_before": true
}

# 响应
{
  "success": true,
  "data": {
    "restore_id": "restore_20260408_035500",
    "status": "running",
    "estimated_time": "10-15 分钟"
  }
}
```

```http
# 删除备份
DELETE /api/v1/backups/{backup_id}

# 响应
{
  "success": true,
  "message": "备份已删除"
}
```

```http
# 验证备份
POST /api/v1/backups/{backup_id}/verify

# 响应
{
  "success": true,
  "data": {
    "checksum_valid": true,
    "data_valid": true,
    "can_restore": true
  }
}
```

---

## 云同步

### 配置云存储

```bash
# AWS S3
vim config/s3.yml
s3:
  bucket: rao5201-backups
  region: us-east-1
  access_key: YOUR_ACCESS_KEY
  secret_key: YOUR_SECRET_KEY
  prefix: backups/

# 阿里云 OSS
vim config/oss.yml
oss:
  bucket: rao5201-backups
  endpoint: oss-cn-hangzhou.aliyuncs.com
  access_key_id: YOUR_ACCESS_KEY_ID
  access_key_secret: YOUR_ACCESS_KEY_SECRET
```

### 同步脚本

```bash
#!/bin/bash
# 同步备份到云存储

# 同步到 S3
aws s3 sync /backups s3://rao5201-backups/backups/ \
  --exclude "*" \
  --include "*.gz" \
  --include "*.tar.gz"

# 同步到 OSS
ossutil sync /backups oss://rao5201-backups/backups/ \
  --exclude "*.log" \
  --include "*.gz"

echo "云同步完成"
```

---

## 安全加密

### 备份加密

```bash
# 使用 GPG 加密备份
gpg --symmetric --cipher-algo AES256 backup_20260408.sql.gz

# 输入密码（建议使用强密码）
# 输出：backup_20260408.sql.gz.gpg
```

### 加密配置

```bash
# 配置加密密钥
vim config/encryption.yml
encryption:
  algorithm: AES256
  key_file: /etc/backup/master.key
  passphrase_env: BACKUP_PASSPHRASE
```

---

## 性能优化

### 并行备份

```bash
# 使用并行备份加速
pg_dump -U postgres -j 4 -F d -f backup_dir rao5201_db
```

### 压缩选项

```bash
# 使用更快的压缩算法
# gzip (默认，平衡)
pg_dump | gzip > backup.sql.gz

# pigz (多核，更快)
pg_dump | pigz -p 4 > backup.sql.gz

# zstd (最快，高压缩率)
pg_dump | zstd -19 > backup.sql.zst
```

---

## 故障排查

### 常见问题

**问题 1: 备份失败**
```bash
# 检查磁盘空间
df -h

# 检查数据库连接
docker-compose exec db pg_isready -U postgres

# 查看详细日志
docker-compose logs backup
```

**问题 2: 恢复失败**
```bash
# 检查备份文件完整性
md5sum -c checksums.md5

# 检查数据库版本兼容性
docker-compose exec db psql -U postgres -c "SELECT version();"
```

**问题 3: 备份文件过大**
```bash
# 清理旧备份
./scripts/cleanup-old-backups.sh --days=7

# 排除大表
pg_dump -U postgres --exclude-table-data=logs rao5201_db
```

---

## 最佳实践

### 3-2-1 备份原则

- **3** 份数据副本（1 份生产 + 2 份备份）
- **2** 种不同存储介质（本地 + 云）
- **1** 份异地备份（不同地理位置）

### 定期演练

```bash
# 每月进行一次恢复演练
./scripts/restore-drill.sh

# 验证备份可用性
./scripts/verify-backups.sh
```

### 文档更新

- 每次备份策略变更后更新文档
- 记录所有恢复操作
- 维护备份日志

---

**最后更新**: 2026-04-08  
**维护者**: CHXWAI Team  
**联系**: rao5201@126.com
