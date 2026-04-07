-- ============================================
-- openclaw200 中央数据库初始化脚本
-- 版本：V1.0
-- 创建时间：2026-04-08
-- ============================================

-- 启用扩展
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================
-- 1. 核心基础表
-- ============================================

-- 用户表
CREATE TABLE IF NOT EXISTS users (
    id              BIGSERIAL PRIMARY KEY,
    uuid            UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    username        VARCHAR(50) UNIQUE NOT NULL,
    email           VARCHAR(255) UNIQUE NOT NULL,
    password_hash   VARCHAR(255) NOT NULL,
    phone           VARCHAR(20),
    avatar_url      VARCHAR(500),
    status          SMALLINT DEFAULT 1,
    is_verified     BOOLEAN DEFAULT FALSE,
    is_admin        BOOLEAN DEFAULT FALSE,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_login_at   TIMESTAMP WITH TIME ZONE
);

-- 项目表
CREATE TABLE IF NOT EXISTS projects (
    id              BIGSERIAL PRIMARY KEY,
    uuid            UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    name            VARCHAR(100) NOT NULL,
    slug            VARCHAR(100) UNIQUE NOT NULL,
    description     TEXT,
    category        VARCHAR(50),
    github_repo     VARCHAR(200),
    github_stars    INTEGER DEFAULT 0,
    status          SMALLINT DEFAULT 1,
    is_public       BOOLEAN DEFAULT TRUE,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 配置表
CREATE TABLE IF NOT EXISTS configurations (
    id              BIGSERIAL PRIMARY KEY,
    project_id      BIGINT REFERENCES projects(id) ON DELETE CASCADE,
    config_key      VARCHAR(100) NOT NULL,
    config_value    TEXT NOT NULL,
    config_type     VARCHAR(20) DEFAULT 'string',
    environment     VARCHAR(20) DEFAULT 'production',
    description     TEXT,
    is_encrypted    BOOLEAN DEFAULT FALSE,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(project_id, config_key, environment)
);

-- 备份记录表
CREATE TABLE IF NOT EXISTS backup_records (
    id              BIGSERIAL PRIMARY KEY,
    backup_type     VARCHAR(50) NOT NULL,
    backup_path     VARCHAR(500) NOT NULL,
    backup_size     BIGINT,
    status          VARCHAR(20) DEFAULT 'pending',
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    completed_at    TIMESTAMP WITH TIME ZONE
);

-- ============================================
-- 2. 索引创建
-- ============================================

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_status ON users(status);
CREATE INDEX IF NOT EXISTS idx_projects_slug ON projects(slug);
CREATE INDEX IF NOT EXISTS idx_projects_category ON projects(category);
CREATE INDEX IF NOT EXISTS idx_config_project_id ON configurations(project_id);
CREATE INDEX IF NOT EXISTS idx_backup_records_status ON backup_records(status);

-- ============================================
-- 3. 初始数据插入
-- ============================================

-- 插入默认管理员用户 (密码：admin123，生产环境请修改)
INSERT INTO users (username, email, password_hash, is_admin, is_verified) 
VALUES (
    'admin',
    'rao5201@126.com',
    crypt('admin123', gen_salt('bf')),
    TRUE,
    TRUE
) ON CONFLICT (email) DO NOTHING;

-- 插入所有 24 个项目记录
INSERT INTO projects (name, slug, description, category, github_repo, status) VALUES
('CHXWAI', 'CHXWAI', '茶海虾王 AI 助手 V3.1', 'chxw', 'rao5201/CHXWAI', 1),
('CHXW-V5.3', 'CHXW-V5.3', '茶海虾王量化交易系统 V5.3', 'chxw', 'rao5201/CHXW-V5.3', 1),
('TSSKMS', 'TSSKMS', '茶海虾王·镜心官方网站', 'chxw', 'rao5201/TSSKMS', 1),
('teahaixin', 'teahaixin', '茶海心遇品牌信息', 'chxw', 'rao5201/teahaixin', 1),
('wxchxw', 'wxchxw', '武穴茶海虾王电子商务中心', 'chxw', 'rao5201/wxchxw', 1),
('hnchxw', 'hnchxw', '海南茶海虾王管理有限责任公司', 'chxw', 'rao5201/hnchxw', 1),
('chxw', 'chxw', '茶海虾王电商综合平台', 'chxw', 'rao5201/chxw', 1),
('chxw-aqfh', 'chxw-aqfh', '茶海虾王安全防护网站', 'chxw', 'rao5201/chxw-aqfh', 1),
('chxw.ai', 'chxw.ai', 'AI 商业机会快速连接', 'chxw', 'rao5201/chxw.ai', 1),
('Raoemail', 'Raoemail', '免费电子邮件网站', 'email', 'rao5201/Raoemail', 1),
('email', 'email', '茶海虾王@email 网站', 'email', 'rao5201/email', 1),
('openclaw', 'openclaw', 'openclaw 网站中文版', 'openclaw', 'rao5201/openclaw', 1),
('RaoClaw', 'RaoClaw', '茶海虾王 RaoClaw 网站', 'openclaw', 'rao5201/RaoClaw', 1),
('openclaw.ai', 'openclaw.ai', 'OpenClaw AI', 'openclaw', 'rao5201/openclaw.ai', 1),
('openclaw199', 'openclaw199', '安全防护网站', 'openclaw', 'rao5201/openclaw199', 1),
('openclaw200', 'openclaw200', '网站后端管理/中央备份中心', 'openclaw', 'rao5201/openclaw200', 1),
('99app', '99app', '99 美金 app', 'app', 'rao5201/99app', 1),
('qwenflow-ip', 'qwenflow-ip', '免费 IP 查询工具', 'tool', 'rao5201/qwenflow-ip', 1),
('163', '163', '选修课程/龙虾训练营', 'tool', 'rao5201/163', 1),
('MuleRun', 'MuleRun', '推荐计划', 'tool', 'rao5201/MuleRun', 1),
('rao5201', 'rao5201', '个人主页', 'tool', 'rao5201/rao5201', 1),
('chxw-official', 'chxw-official', '官方网站', 'chxw', 'rao5201/chxw-official', 1)
ON CONFLICT (slug) DO UPDATE SET 
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    updated_at = CURRENT_TIMESTAMP;

-- 插入备份中心配置
INSERT INTO configurations (project_id, config_key, config_value, config_type, description) VALUES
((SELECT id FROM projects WHERE slug = 'openclaw200'), 'backup_retention_days', '30', 'number', '备份保留天数'),
((SELECT id FROM projects WHERE slug = 'openclaw200'), 'backup_schedule', '0 2 * * *', 'string', '备份计划任务'),
((SELECT id FROM projects WHERE slug = 'openclaw200'), 'cloud_sync_enabled', 'true', 'boolean', '是否启用云同步'),
((SELECT id FROM projects WHERE slug = 'openclaw200'), 'alert_email', 'rao5201@126.com', 'string', '告警邮箱')
ON CONFLICT (project_id, config_key, environment) DO NOTHING;

-- ============================================
-- 4. 视图创建
-- ============================================

-- 项目统计视图
CREATE OR REPLACE VIEW project_stats AS
SELECT 
    p.slug,
    p.name,
    p.category,
    p.github_stars,
    p.status,
    COUNT(DISTINCT c.id) as config_count,
    COUNT(DISTINCT b.id) as backup_count
FROM projects p
LEFT JOIN configurations c ON p.id = c.project_id
LEFT JOIN backup_records b ON TRUE
GROUP BY p.id, p.slug, p.name, p.category, p.github_stars, p.status;

-- ============================================
-- 5. 函数创建
-- ============================================

-- 更新时间戳函数
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 为所有表添加更新时间戳触发器
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_projects_updated_at BEFORE UPDATE ON projects
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_configurations_updated_at BEFORE UPDATE ON configurations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 初始化完成
-- ============================================

-- 输出初始化信息
DO $$
DECLARE
    user_count INTEGER;
    project_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO user_count FROM users;
    SELECT COUNT(*) INTO project_count FROM projects;
    
    RAISE NOTICE '================================';
    RAISE NOTICE 'openclaw200 中央数据库初始化完成!';
    RAISE NOTICE '================================';
    RAISE NOTICE '用户表：users (% 个用户)', user_count;
    RAISE NOTICE '项目表：projects (% 个项目)', project_count;
    RAISE NOTICE '配置表：configurations';
    RAISE NOTICE '备份表：backup_records';
    RAISE NOTICE '默认管理员：admin (rao5201@126.com)';
    RAISE NOTICE '================================';
END $$;
