# openclaw200 后台管理系统使用指南

**版本**: V1.0  
**创建时间**: 2026-04-09  

---

## 📋 目录

1. [快速开始](#快速开始)
2. [登录后台](#登录后台)
3. [仪表盘功能](#仪表盘功能)
4. [用户管理](#用户管理)
5. [项目管理](#项目管理)
6. [备份管理](#备份管理)
7. [系统设置](#系统设置)

---

## 快速开始

### 1. 访问后台

**后台地址**: http://localhost:8080/admin/login.html

### 2. 默认账户

```
邮箱：rao5201@126.com
密码：admin123
```

⚠️ **首次登录后请立即修改密码！**

---

## 登录后台

### 登录步骤

1. 打开浏览器访问：http://localhost:8080/admin/login.html
2. 输入邮箱和密码
3. 点击"登录"按钮
4. 登录成功后自动跳转到仪表盘

### 登录界面功能

- ✅ 邮箱输入框（默认填充 rao5201@126.com）
- ✅ 密码输入框
- ✅ 忘记密码链接
- ✅ 默认管理员账户提示
- ✅ 错误提示
- ✅ 成功提示

---

## 仪表盘功能

### 统计卡片

仪表盘顶部显示 4 个统计卡片：

| 卡片 | 说明 |
|------|------|
| 👥 总用户数 | 系统注册用户总数 |
| 📦 项目总数 | 所有项目数量 |
| 💾 备份数量 | 备份记录总数 |
| 🔒 配置项数 | 系统配置项数量 |

### 快速操作面板

提供 4 个快速操作入口：

1. **立即备份** - 执行数据库备份
2. **添加用户** - 创建新用户账户
3. **添加项目** - 创建新项目
4. **查看日志** - 查看系统日志

---

## 用户管理

### 查看用户列表

进入"用户管理"页面，可以看到：

| 字段 | 说明 |
|------|------|
| ID | 用户唯一标识 |
| 用户名 | 用户登录名 |
| 邮箱 | 用户邮箱 |
| 角色 | 管理员/普通用户 |
| 状态 | 正常/禁用 |
| 创建时间 | 账户创建时间 |

### 用户操作

**编辑用户**:
- 点击"编辑"按钮
- 修改用户信息
- 保存更改

**删除用户**:
- 点击"删除"按钮
- 确认删除
- 用户被删除

**添加新用户**:
1. 点击"添加用户"按钮
2. 填写用户信息（用户名、邮箱、密码）
3. 选择用户角色
4. 点击"保存"

---

## 项目管理

### 查看项目列表

进入"项目管理"页面，可以看到：

| 字段 | 说明 |
|------|------|
| ID | 项目唯一标识 |
| 项目名称 | 项目显示名称 |
| 分类 | 项目分类（chxw/email/openclaw 等） |
| GitHub | GitHub 仓库地址 |
| 状态 | 活跃/归档 |

### 项目操作

**编辑项目**:
- 点击"编辑"按钮
- 修改项目信息
- 保存更改

**删除项目**:
- 点击"删除"按钮
- 确认删除
- 项目被删除

**添加新项目**:
1. 点击"添加项目"按钮
2. 填写项目信息（名称、slug、描述、分类）
3. 填写 GitHub 仓库地址
4. 点击"保存"

### 当前项目列表 (22 个)

**CHXW 系列 (9 个)**:
- CHXWAI
- CHXW-V5.3
- TSSKMS
- teahaixin
- wxchxw
- hnchxw
- chxw
- chxw-aqfh
- chxw.ai

**邮件服务 (2 个)**:
- Raoemail
- email

**OpenClaw 系列 (5 个)**:
- openclaw
- RaoClaw
- openclaw.ai
- openclaw199
- openclaw200

**其他项目 (6 个)**:
- 99app
- qwenflow-ip
- 163
- MuleRun
- rao5201
- chxw-official

---

## 备份管理

### 查看备份记录

进入"备份管理"页面，可以看到：

| 字段 | 说明 |
|------|------|
| 备份类型 | full/incremental/archive |
| 备份路径 | 备份文件存储路径 |
| 大小 | 备份文件大小 |
| 状态 | pending/running/completed/failed |
| 创建时间 | 备份创建时间 |

### 备份操作

**立即备份**:
1. 点击"立即备份"按钮
2. 选择备份类型（全量/增量）
3. 确认开始备份
4. 等待备份完成

**恢复备份**:
1. 找到要恢复的备份记录
2. 点击"恢复"按钮
3. 选择恢复模式（覆盖/合并）
4. 确认恢复

**删除备份**:
- 点击"删除"按钮
- 确认删除
- 备份被删除

---

## 系统设置

### 配置管理

进入"设置"页面，可以配置：

**备份设置**:
- 备份保留天数（默认 30 天）
- 备份计划任务（默认每天 2:00）
- 云同步开关
- 告警邮箱

**安全设置**:
- 密码策略
- 会话超时时间
- IP 白名单
- 双因素认证

**系统设置**:
- 系统名称
- Logo 上传
- 主题颜色
- 语言设置

---

## API 接口

### 认证接口

```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "rao5201@126.com",
  "password": "admin123"
}

# 响应
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": 1,
      "username": "admin",
      "email": "rao5201@126.com",
      "is_admin": true
    }
  }
}
```

### 用户接口

```http
GET /api/v1/users
Authorization: Bearer {token}

# 响应
{
  "success": true,
  "data": [
    {
      "id": 1,
      "username": "admin",
      "email": "rao5201@126.com",
      "is_admin": true
    }
  ]
}
```

### 项目接口

```http
GET /api/v1/projects
Authorization: Bearer {token}

# 响应
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "CHXWAI",
      "slug": "CHXWAI",
      "category": "chxw",
      "github_repo": "rao5201/CHXWAI"
    }
  ]
}
```

### 备份接口

```http
POST /api/v1/backups
Authorization: Bearer {token}
Content-Type: application/json

{
  "type": "full",
  "compress": true
}

# 响应
{
  "success": true,
  "data": {
    "backup_id": "backup_20260409_160000",
    "status": "running",
    "estimated_time": "5-10 分钟"
  }
}
```

---

## 安全建议

### 1. 修改默认密码

首次登录后立即修改管理员密码：

```sql
UPDATE users 
SET password_hash = crypt('你的强密码', gen_salt('bf'))
WHERE email = 'rao5201@126.com';
```

### 2. 启用 HTTPS

生产环境必须启用 HTTPS：

```bash
# 使用 Let's Encrypt 免费证书
certbot --nginx -d your-domain.com
```

### 3. 限制访问 IP

配置防火墙只允许信任的 IP 访问后台：

```bash
# Nginx 配置
location /admin/ {
    allow 192.168.1.0/24;
    deny all;
}
```

### 4. 定期备份

配置自动备份任务：

```bash
# crontab -e
0 2 * * * /path/to/openclaw200/scripts/backup-full.sh
```

### 5. 监控日志

定期检查系统日志：

```bash
tail -f /var/log/openclaw200/access.log
tail -f /var/log/openclaw200/error.log
```

---

## 常见问题

### Q1: 忘记密码怎么办？

**A**: 重置管理员密码：
```sql
UPDATE users 
SET password_hash = crypt('admin123', gen_salt('bf'))
WHERE email = 'rao5201@126.com';
```

### Q2: 后台无法访问？

**A**: 检查服务是否运行：
```bash
docker-compose ps
```

### Q3: 如何添加管理员？

**A**: 在数据库中设置：
```sql
UPDATE users 
SET is_admin = TRUE 
WHERE email = 'user@example.com';
```

### Q4: 备份文件在哪里？

**A**: 备份文件存储在 `/backups` 目录

### Q5: 如何导出用户数据？

**A**: 使用 pg_dump 导出：
```bash
docker-compose exec db pg_dump -U postgres -t users rao5201_db > users.sql
```

---

## 技术支持

**邮箱**: rao5201@126.com  
**GitHub**: https://github.com/rao5201/openclaw200  
**文档**: https://github.com/rao5201/openclaw200/blob/main/README.md

---

**最后更新**: 2026-04-09  
**维护者**: CHXWAI Team
