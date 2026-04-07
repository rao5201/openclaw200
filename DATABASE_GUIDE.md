# openclaw200 中央数据库使用指南

**版本**: V1.0  
**创建时间**: 2026-04-08  
**描述**: 中央数据库初始化和使用指南

---

## 📋 目录

1. [快速开始](#快速开始)
2. [数据库初始化](#数据库初始化)
3. [数据验证](#数据验证)
4. [用户管理](#用户管理)
5. [项目管理](#项目管理)
6. [备份管理](#备份管理)
7. [常见问题](#常见问题)

---

## 快速开始

### 1. 启动数据库服务

```bash
cd openclaw200
docker-compose up -d
```

### 2. 初始化数据库

```bash
./scripts/init-db.sh
```

### 3. 验证数据

```bash
docker-compose exec db psql -U postgres -d rao5201_db -c "SELECT COUNT(*) FROM users;"
docker-compose exec db psql -U postgres -d rao5201_db -c "SELECT COUNT(*) FROM projects;"
```

---

## 数据库初始化

### 方法一：自动初始化（推荐）

```bash
./scripts/init-db.sh
```

### 方法二：手动初始化

```bash
# 复制初始化脚本到容器
docker cp scripts/init-database.sql $(docker-compose ps -q db):/tmp/init-database.sql

# 执行初始化
docker-compose exec db psql -U postgres -d rao5201_db -f /tmp/init-database.sql
```

### 初始化内容

**创建的数据表**:
- `users` - 用户表
- `projects` - 项目表（24 个项目）
- `configurations` - 配置表
- `backup_records` - 备份记录表

**初始数据**:
- 默认管理员：admin (rao5201@126.com / admin123)
- 24 个项目记录
- 4 个备份中心配置

---

## 数据验证

### 检查用户数据

```bash
# 查看用户数量
docker-compose exec db psql -U postgres -d rao5201_db -c "SELECT COUNT(*) FROM users;"

# 查看管理员账户
docker-compose exec db psql -U postgres -d rao5201_db -c "SELECT username, email, is_admin FROM users WHERE is_admin = TRUE;"
```

### 检查项目数据

```bash
# 查看项目数量
docker-compose exec db psql -U postgres -d rao5201_db -c "SELECT COUNT(*) FROM projects;"

# 查看所有项目
docker-compose exec db psql -U postgres -d rao5201_db -c "SELECT slug, name, category FROM projects ORDER BY category;"
```

### 检查配置数据

```bash
# 查看配置项
docker-compose exec db psql -U postgres -d rao5201_db -c "SELECT config_key, config_value FROM configurations;"
```

---

## 用户管理

### 创建新用户

```sql
INSERT INTO users (username, email, password_hash)
VALUES ('newuser', 'user@example.com', crypt('password123', gen_salt('bf')));
```

### 修改用户密码

```sql
UPDATE users 
SET password_hash = crypt('newpassword', gen_salt('bf'))
WHERE email = 'user@example.com';
```

### 删除用户

```sql
DELETE FROM users WHERE email = 'user@example.com';
```

### 查看用户列表

```sql
SELECT id, username, email, is_admin, created_at 
FROM users 
ORDER BY created_at DESC;
```

---

## 项目管理

### 添加新项目

```sql
INSERT INTO projects (name, slug, description, category, github_repo)
VALUES ('新项目', 'new-project', '项目描述', 'tool', 'rao5201/new-project');
```

### 更新项目信息

```sql
UPDATE projects 
SET description = '新的描述', 
    updated_at = CURRENT_TIMESTAMP
WHERE slug = 'project-slug';
```

### 查看项目统计

```sql
SELECT category, COUNT(*) as count
FROM projects
GROUP BY category;
```

---

## 备份管理

### 查看备份记录

```sql
SELECT backup_type, backup_path, backup_size, status, created_at
FROM backup_records
ORDER BY created_at DESC
LIMIT 10;
```

### 添加备份记录

```sql
INSERT INTO backup_records (backup_type, backup_path, backup_size, status)
VALUES ('full', '/backups/backup_20260408.sql.gz', 1048576, 'completed');
```

### 查看备份统计

```sql
SELECT 
    backup_type,
    COUNT(*) as total,
    AVG(backup_size) as avg_size,
    MAX(created_at) as last_backup
FROM backup_records
GROUP BY backup_type;
```

---

## 常见问题

### Q1: 初始化失败怎么办？

**A**: 检查 Docker 服务是否运行：
```bash
docker-compose ps
```

如果服务未运行，先启动：
```bash
docker-compose up -d
```

### Q2: 如何重置数据库？

**A**: 删除并重新创建数据库：
```bash
# 停止服务
docker-compose down

# 删除数据卷
docker volume rm openclaw200_postgres_data

# 重新启动
docker-compose up -d

# 重新初始化
./scripts/init-db.sh
```

### Q3: 忘记管理员密码怎么办？

**A**: 重置管理员密码：
```sql
UPDATE users 
SET password_hash = crypt('admin123', gen_salt('bf'))
WHERE email = 'rao5201@126.com';
```

### Q4: 如何查看数据库大小？

**A**: 执行以下查询：
```sql
SELECT pg_size_pretty(pg_database_size('rao5201_db'));
```

### Q5: 如何备份数据库？

**A**: 使用 pg_dump：
```bash
docker-compose exec db pg_dump -U postgres rao5201_db > backup.sql
```

---

## 数据库连接信息

| 项目 | 值 |
|------|-----|
| 主机 | localhost |
| 端口 | 5432 |
| 数据库 | rao5201_db |
| 用户名 | postgres |
| 密码 | postgres_password_2026 |

---

## 安全建议

1. **立即修改默认密码**
   ```sql
   UPDATE users 
   SET password_hash = crypt('你的强密码', gen_salt('bf'))
   WHERE email = 'rao5201@126.com';
   ```

2. **限制数据库访问**
   - 只允许信任的 IP 访问
   - 使用防火墙规则
   - 定期更新密码

3. **定期备份**
   - 每天自动备份
   - 备份到云存储
   - 定期测试恢复

---

**最后更新**: 2026-04-08  
**维护者**: CHXWAI Team  
**联系**: rao5201@126.com
