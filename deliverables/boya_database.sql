-- =============================================================================
-- 博雅书院 · 项目完整数据库
-- 数据库：javaweb  |  字符集：utf8mb4  |  引擎：InnoDB
-- 执行方式：mysql -u root -p javaweb < boya_database.sql
-- 总表数：62张
--
-- ⚠️ 幂等说明（可反复执行，不会破坏已有数据）：
--   • 所有 CREATE TABLE 均使用 IF NOT EXISTS
--     若表已存在则自动跳过，不删除原有表和数据。
--   • 所有 INSERT 均使用 INSERT IGNORE
--     若记录已存在（主键/唯一键冲突）则自动跳过，不会报重复键错误。
--   • 建议：首次部署完整执行；后续迭代只执行新增表的 CREATE TABLE 语句即可。
-- =============================================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- =================================================================
-- 一、核心基础表（3张）
-- =================================================================

-- 1. 用户表
CREATE TABLE IF NOT EXISTS users (
    id VARCHAR(64) PRIMARY KEY COMMENT '用户唯一标识(UUID)',
    username VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名',
    password VARCHAR(255) NOT NULL COMMENT 'BCrypt加密密码',
    nickname VARCHAR(100) DEFAULT '' COMMENT '昵称',
    avatar VARCHAR(255) DEFAULT '' COMMENT '头像路径',
    sex VARCHAR(10) DEFAULT '未知' COMMENT '性别',
    age BIGINT DEFAULT 0 COMMENT '年龄',
    email VARCHAR(100) DEFAULT '' COMMENT '邮箱',
    role VARCHAR(20) DEFAULT 'user' COMMENT '角色：admin/user',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_username (username),
    INDEX idx_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- 2. 图书分类表（与 BookType.java POJO 对应：bTid/bTypeName/btText）
CREATE TABLE IF NOT EXISTS booktype (
    bTid INT PRIMARY KEY AUTO_INCREMENT COMMENT '分类ID',
    bTypeName VARCHAR(100) NOT NULL COMMENT '分类名称',
    btText TEXT COMMENT '分类描述',
    bTPerentId INT DEFAULT 0 COMMENT '父分类ID',
    sort_order INT DEFAULT 0,
    INDEX idx_parent (bTPerentId)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='图书分类表';

-- 3. 图书表（与 Book.java POJO 对应）
CREATE TABLE IF NOT EXISTS book (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '图书ID',
    book_title VARCHAR(200) NOT NULL COMMENT '书名',
    book_author VARCHAR(100) COMMENT '作者',
    book_publish VARCHAR(100) COMMENT '出版社',
    book_summary TEXT COMMENT '简介',
    cover_image VARCHAR(500) COMMENT '封面图片',
    file_path VARCHAR(500) COMMENT '文件路径',
    file_type VARCHAR(20) DEFAULT 'pdf' COMMENT '文件格式',
    file_size BIGINT DEFAULT 0 COMMENT '文件大小',
    download_count INT DEFAULT 0 COMMENT '下载次数',
    read_count INT DEFAULT 0 COMMENT '阅读次数',
    type_id INT COMMENT '分类ID',
    status VARCHAR(20) DEFAULT 'active' COMMENT '状态',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (type_id) REFERENCES booktype(bTid) ON DELETE SET NULL,
    INDEX idx_type_id (type_id),
    INDEX idx_book_title (book_title),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='图书表';

-- =================================================================
-- 二、课程管理表（2张）
-- =================================================================

-- 4. 课程表
CREATE TABLE IF NOT EXISTS course (
    id INT PRIMARY KEY AUTO_INCREMENT,
    course_name VARCHAR(200) NOT NULL COMMENT '课程名称',
    course_category VARCHAR(50) COMMENT '课程分类',
    course_level VARCHAR(20) DEFAULT 'beginner' COMMENT '难度级别',
    instructor_id INT COMMENT '讲师ID',
    instructor_name VARCHAR(100) COMMENT '讲师姓名',
    course_hours INT DEFAULT 0 COMMENT '课时数',
    rating DECIMAL(3,1) DEFAULT 0.0 COMMENT '评分0-5',
    enrolled_count INT DEFAULT 0 COMMENT '报名人数',
    cover_image VARCHAR(500) COMMENT '课程封面',
    description TEXT COMMENT '课程描述',
    status VARCHAR(20) DEFAULT 'active',
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_category (course_category),
    INDEX idx_instructor (instructor_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='课程表';

-- 5. 用户课程学习记录表
CREATE TABLE IF NOT EXISTS user_course_record (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id VARCHAR(64) NOT NULL COMMENT '用户ID',
    course_id INT NOT NULL COMMENT '课程ID',
    progress DECIMAL(5,2) DEFAULT 0.00 COMMENT '学习进度0-100',
    study_hours DECIMAL(6,2) DEFAULT 0.00 COMMENT '学习时长(小时)',
    completed_chapters TEXT COMMENT '已完成章节(逗号分隔)',
    last_study_time DATETIME COMMENT '最后学习时间',
    completed TINYINT(1) DEFAULT 0 COMMENT '是否完成',
    completed_at DATETIME COMMENT '完成时间',
    status VARCHAR(20) DEFAULT 'enrolled',
    enrolled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES course(id) ON DELETE CASCADE,
    UNIQUE KEY uk_user_course (user_id, course_id),
    INDEX idx_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户课程学习记录';

-- =================================================================
-- 三、为你推荐页（recommend.jsp）—— 6张
-- =================================================================

-- 6. 用户学习汇总表
CREATE TABLE IF NOT EXISTS user_study_summary (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id VARCHAR(64) NOT NULL,
    total_courses INT DEFAULT 0 COMMENT '已修课程数',
    total_study_hours DECIMAL(8,2) DEFAULT 0.00 COMMENT '总学习时长',
    campus_points INT DEFAULT 0 COMMENT '校园积分',
    week_progress INT DEFAULT 0 COMMENT '周学习进度',
    streak_days INT DEFAULT 0 COMMENT '连续学习天数',
    last_study_date DATE COMMENT '最后学习日期',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY uk_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户学习汇总';

-- 7. 知识技能雷达图表
CREATE TABLE IF NOT EXISTS knowledge_skills (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id VARCHAR(64) NOT NULL,
    skill_name VARCHAR(50) NOT NULL,
    skill_value INT DEFAULT 0,
    skill_color VARCHAR(20) DEFAULT '#00f2ff',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY uk_user_skill (user_id, skill_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='知识技能雷达图';

-- 8. 学习路径表
CREATE TABLE IF NOT EXISTS learning_paths (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id VARCHAR(64) NOT NULL,
    step_number INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    status VARCHAR(20) DEFAULT 'upcoming' COMMENT 'completed/current/upcoming',
    progress_percent INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_step (user_id, step_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学习路径';

-- 9. 推荐内容表
CREATE TABLE IF NOT EXISTS recommendations (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    category VARCHAR(100),
    description TEXT,
    type VARCHAR(50) NOT NULL COMMENT 'courses/books/lectures/articles',
    badge VARCHAR(50) COMMENT 'hot/new/trending/personal/classic/skill',
    author VARCHAR(100),
    meta_info VARCHAR(200),
    rating DECIMAL(2,1) DEFAULT 5.0,
    image_url VARCHAR(500),
    action_text VARCHAR(50) DEFAULT '立即学习',
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_type (type),
    INDEX idx_badge (badge),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='推荐内容表';

-- 10. 用户兴趣标签表
CREATE TABLE IF NOT EXISTS user_interest_tag (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id VARCHAR(64) NOT NULL,
    tag_name VARCHAR(100) NOT NULL,
    weight DECIMAL(5,2) DEFAULT 1.00 COMMENT '权重0-10',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY uk_user_tag (user_id, tag_name),
    INDEX idx_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户兴趣标签';

-- 11. 推荐记录表
CREATE TABLE IF NOT EXISTS recommendation_log (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id VARCHAR(64) NOT NULL,
    recommend_type VARCHAR(50) NOT NULL COMMENT 'course/book/lecture/article',
    recommend_id BIGINT NOT NULL,
    recommend_reason VARCHAR(200),
    clicked TINYINT(1) DEFAULT 0,
    clicked_at DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_type (recommend_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='推荐记录';

-- =================================================================
-- 四、星链校友页（alumni.jsp）—— 1张
-- =================================================================

-- 12. 校友表
CREATE TABLE IF NOT EXISTS alumni (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    title VARCHAR(200),
    achievement TEXT,
    avatar_url VARCHAR(500),
    company VARCHAR(200),
    graduation_year INT,
    major VARCHAR(100),
    is_honorary TINYINT(1) DEFAULT 0,
    sort_order INT DEFAULT 0,
    is_active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_is_honorary (is_honorary),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='校友表';

-- =================================================================
-- 五、导师光网页（faculty.jsp）—— 1张
-- =================================================================

-- 13. 导师表
CREATE TABLE IF NOT EXISTS faculty (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    title VARCHAR(100) COMMENT '职称',
    avatar_icon VARCHAR(50) COMMENT '头像emoji',
    research_area VARCHAR(200) COMMENT '研究方向',
    department VARCHAR(100) COMMENT '院系',
    email VARCHAR(200) COMMENT '邮箱',
    office VARCHAR(100) COMMENT '办公室',
    office_hours VARCHAR(200) COMMENT '办公时间',
    bio TEXT COMMENT '简介',
    sort_order INT DEFAULT 0,
    is_active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_department (department),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='导师表';

-- =================================================================
-- 六、学域矩阵页（majors.jsp）—— 2张
-- =================================================================

-- 14. 专业表
CREATE TABLE IF NOT EXISTS major (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(50) UNIQUE,
    icon VARCHAR(50),
    description TEXT,
    category VARCHAR(50),
    is_interdisciplinary TINYINT(1) DEFAULT 0,
    department VARCHAR(100),
    degree_type VARCHAR(50),
    duration INT DEFAULT 4,
    sort_order INT DEFAULT 0,
    is_active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_category (category),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='专业表';

-- 15. 学域-图书分类关联表（中间表，major → booktype 多对多）
CREATE TABLE IF NOT EXISTS major_book_type (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    major_code VARCHAR(100) NOT NULL COMMENT '学域代码（对应major.code）',
    book_type_id VARCHAR(50) NOT NULL COMMENT '图书分类ID（对应booktype.bTid）',
    INDEX idx_major_code (major_code),
    INDEX idx_book_type_id (book_type_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学域-图书分类关联表';

-- =================================================================
-- 七、前沿讲坛页（lecture.jsp）—— 2张
-- =================================================================

-- 16. 讲座表
CREATE TABLE IF NOT EXISTS lecture (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL COMMENT '讲座标题',
    speaker VARCHAR(100) COMMENT '主讲人',
    speaker_title VARCHAR(200) COMMENT '主讲人头衔',
    speaker_avatar VARCHAR(500) COMMENT '头像URL',
    lecture_date TIMESTAMP COMMENT '讲座日期',
    lecture_time VARCHAR(50) COMMENT '讲座时间描述',
    description TEXT COMMENT '讲座简介',
    is_online TINYINT(1) DEFAULT 0 COMMENT '是否在线直播',
    meeting_url VARCHAR(500) COMMENT '在线会议链接',
    meeting_id VARCHAR(100),
    status VARCHAR(20) DEFAULT 'upcoming' COMMENT 'upcoming/ongoing/completed/cancelled',
    view_count INT DEFAULT 0 COMMENT '观看次数',
    sort_order INT DEFAULT 0,
    is_active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_status (status),
    INDEX idx_lecture_date (lecture_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='讲座表';

-- 17. 讲座报名表
CREATE TABLE IF NOT EXISTS lecture_registration (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id VARCHAR(64) NOT NULL,
    lecture_id BIGINT NOT NULL,
    registered_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    attendance_status VARCHAR(20) DEFAULT 'registered' COMMENT 'registered/attended/absent',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (lecture_id) REFERENCES lecture(id) ON DELETE CASCADE,
    UNIQUE KEY uk_user_lecture (user_id, lecture_id),
    INDEX idx_user (user_id),
    INDEX idx_lecture (lecture_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='讲座报名表';

-- =================================================================
-- 八、元·文化页（culture.jsp）—— 3张
-- =================================================================

-- 18. 文化活动表
CREATE TABLE IF NOT EXISTS culture_events (
    id INT PRIMARY KEY AUTO_INCREMENT,
    season VARCHAR(50) COMMENT '季节',
    event_name VARCHAR(200) NOT NULL,
    description TEXT,
    event_type VARCHAR(100) COMMENT '展览/论坛/演奏会/峰会',
    event_date DATE,
    location VARCHAR(200),
    image_url VARCHAR(500),
    is_active TINYINT(1) DEFAULT 1,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_season (season),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='文化活动表';

-- 19. 文化艺术作品表
CREATE TABLE IF NOT EXISTS culture_artworks (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    artist VARCHAR(100),
    description TEXT,
    artwork_type VARCHAR(50) COMMENT 'digital/painting/interactive/ai-art/calligraphy/installation/pixel-art',
    image_url VARCHAR(500),
    created_year INT,
    sort_order INT DEFAULT 0,
    is_active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_type (artwork_type),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='文化艺术作品表';

-- 20. 文化社团表
CREATE TABLE IF NOT EXISTS culture_clubs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    icon VARCHAR(50),
    description TEXT,
    member_count INT DEFAULT 0,
    activity_count INT DEFAULT 0,
    sort_order INT DEFAULT 0,
    is_active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='文化社团表';

-- =================================================================
-- 九、数字史册页（history.jsp）—— 1张
-- =================================================================

-- 21. 历史里程碑表
CREATE TABLE IF NOT EXISTS history_records (
    id INT PRIMARY KEY AUTO_INCREMENT,
    year VARCHAR(20) NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    image_url VARCHAR(500),
    sort_order INT DEFAULT 0,
    is_active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_year (year),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='历史里程碑表';

-- =================================================================
-- 十、元宇宙校园页（campus3d.jsp）—— 3张
-- =================================================================

-- 22. 虚拟校园场景表
CREATE TABLE IF NOT EXISTS campus_scene (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    scene_key VARCHAR(50) NOT NULL UNIQUE,
    icon VARCHAR(20) DEFAULT '🌐',
    description TEXT,
    scene_type VARCHAR(50) COMMENT 'learning/experiment/lecture/leisure',
    features TEXT COMMENT 'JSON数组功能列表',
    thumbnail VARCHAR(500),
    scene_url VARCHAR(500),
    category VARCHAR(50),
    visit_count INT DEFAULT 0,
    is_active TINYINT(1) DEFAULT 1,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_scene_key (scene_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='虚拟校园场景表';

-- 23. 校园3D统计表
CREATE TABLE IF NOT EXISTS campus3d_stats (
    id INT PRIMARY KEY AUTO_INCREMENT,
    stat_date DATE NOT NULL,
    online_users INT DEFAULT 0,
    scene_count INT DEFAULT 0,
    satisfaction_rate INT DEFAULT 0,
    is_24h_open TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_stat_date (stat_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='校园3D统计表';

-- 24. 用户场景访问记录表
CREATE TABLE IF NOT EXISTS user_scene_visit (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id VARCHAR(64),
    scene_id INT,
    visited_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (scene_id) REFERENCES campus_scene(id) ON DELETE CASCADE,
    INDEX idx_user_scene (user_id, scene_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户场景访问记录';

-- =================================================================
-- 十一、沉浸自习室页（studyRoom.jsp）—— 4张
-- =================================================================

-- 25. 自习室统计表
CREATE TABLE IF NOT EXISTS studyroom_stats (
    id INT PRIMARY KEY AUTO_INCREMENT,
    stat_date DATE NOT NULL,
    online_users INT DEFAULT 0,
    total_minutes INT DEFAULT 0 COMMENT '今日总学时(分钟)',
    focus_score INT DEFAULT 0 COMMENT '专注度评分',
    room_rank INT DEFAULT 0 COMMENT '自习室排名',
    today_study_text VARCHAR(50) COMMENT '文本：X小时Y分',
    streak_days INT DEFAULT 0 COMMENT '连续学习天数',
    efficiency_score INT DEFAULT 0 COMMENT '效率指数',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_stat_date (stat_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='自习室统计表';

-- 26. 学习任务表（自习室专用）
CREATE TABLE IF NOT EXISTS studyroom_tasks (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id VARCHAR(64) NOT NULL,
    task_content VARCHAR(500) NOT NULL,
    priority VARCHAR(20) DEFAULT 'normal' COMMENT 'low/normal/high',
    due_date DATE,
    completed TINYINT(1) DEFAULT 0,
    completed_at DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_completed (completed)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学习任务表(自习室)';

-- 27. 校园积分明细表
CREATE TABLE IF NOT EXISTS studyroom_points (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id VARCHAR(64) NOT NULL,
    points INT DEFAULT 0 COMMENT '积分变化值',
    total_points INT DEFAULT 0 COMMENT '累计总积分',
    reason VARCHAR(200) COMMENT '积分原因',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='校园积分明细表';

-- 28. 番茄钟会话表
CREATE TABLE IF NOT EXISTS pomodoro_session (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id VARCHAR(64) NOT NULL,
    focus_duration INT NOT NULL COMMENT '专注时长(分钟)',
    break_duration INT DEFAULT 5 COMMENT '休息时长(分钟)',
    started_at TIMESTAMP,
    completed_at TIMESTAMP NULL,
    is_completed TINYINT(1) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='番茄钟记录表';

-- =================================================================
-- 十二、首页（home.jsp）—— 1张
-- =================================================================

-- 29. 首页新闻公告表
CREATE TABLE IF NOT EXISTS home_news (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    news_type VARCHAR(20) DEFAULT 'news' COMMENT 'news/announcement/event',
    priority VARCHAR(20) DEFAULT 'normal' COMMENT 'low/normal/high/urgent',
    cover_image VARCHAR(500),
    author VARCHAR(100),
    publisher_id VARCHAR(64),
    publish_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    expire_time DATETIME,
    is_top TINYINT(1) DEFAULT 0,
    is_important TINYINT(1) DEFAULT 0,
    view_count INT DEFAULT 0,
    status VARCHAR(20) DEFAULT 'published',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_type (news_type),
    INDEX idx_publish_time (publish_time),
    INDEX idx_is_top (is_top)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='首页新闻公告表';

-- =================================================================
-- 十三、管理驾驶舱（adminDashboard.jsp）—— 3张
-- =================================================================

-- 30. 管理统计表
CREATE TABLE IF NOT EXISTS dashboard_stats (
    id INT PRIMARY KEY AUTO_INCREMENT,
    stat_date DATE NOT NULL,
    active_users INT DEFAULT 0,
    today_visits INT DEFAULT 0,
    course_completion_rate INT DEFAULT 0,
    system_health DECIMAL(4,1) DEFAULT 99.9,
    total_courses INT DEFAULT 0,
    total_students INT DEFAULT 0,
    total_teachers INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_stat_date (stat_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='管理驾驶舱统计表';

-- 31. 系统访问统计表
CREATE TABLE IF NOT EXISTS dashboard_access_stats (
    id INT PRIMARY KEY AUTO_INCREMENT,
    stat_date DATE NOT NULL,
    total_visits INT DEFAULT 0,
    unique_visitors INT DEFAULT 0,
    new_users INT DEFAULT 0,
    active_users INT DEFAULT 0,
    page_views INT DEFAULT 0,
    avg_session_duration INT DEFAULT 0,
    bounce_rate DECIMAL(5,2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_date (stat_date),
    INDEX idx_date (stat_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统访问统计表';

-- 32. 系统监控日志表
CREATE TABLE IF NOT EXISTS dashboard_monitor_log (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    log_type VARCHAR(50) NOT NULL COMMENT 'cpu/memory/disk/network/alert',
    metric_name VARCHAR(100) NOT NULL,
    metric_value DECIMAL(10,2) DEFAULT 0.00,
    threshold DECIMAL(10,2),
    status VARCHAR(20) DEFAULT 'normal' COMMENT 'normal/warning/critical',
    message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_type (log_type),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统监控日志表';

-- =================================================================
-- 十四、内容审核页（contentReview.jsp）—— 1张
-- =================================================================

-- 33. 内容审核表
CREATE TABLE IF NOT EXISTS content_review (
    id INT PRIMARY KEY AUTO_INCREMENT,
    content_type VARCHAR(50) NOT NULL COMMENT 'course/article/comment/report/data',
    content_id INT,
    title VARCHAR(300) COMMENT '内容标题',
    content_preview TEXT COMMENT '内容预览',
    author_id VARCHAR(64) COMMENT '作者ID',
    author_name VARCHAR(100) COMMENT '作者名',
    submitter VARCHAR(100) COMMENT '提交者',
    priority VARCHAR(20) DEFAULT 'normal' COMMENT 'high/normal/low/report',
    status VARCHAR(20) DEFAULT 'pending' COMMENT 'pending/approved/rejected',
    reject_reason TEXT COMMENT '拒绝理由',
    reviewer_id VARCHAR(64) COMMENT '审核人ID',
    ai_score DECIMAL(3,1) DEFAULT 0 COMMENT 'AI评分0-10',
    ai_feedback TEXT COMMENT 'AI反馈',
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '提交时间',
    reviewed_at TIMESTAMP NULL COMMENT '审核时间',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_content_type (content_type),
    INDEX idx_status (status),
    INDEX idx_priority (priority)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='内容审核表';

-- =================================================================
-- 十五、通知推送系统（notifications.jsp）—— 2张
-- =================================================================

-- 34. 通知表
CREATE TABLE IF NOT EXISTS notification (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    notification_type VARCHAR(20) DEFAULT 'info' COMMENT 'success/warning/error/info/system',
    target_type VARCHAR(50) DEFAULT 'all' COMMENT 'all/students/teachers/vip/custom',
    sender_id VARCHAR(64),
    send_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    scheduled_time DATETIME,
    status VARCHAR(20) DEFAULT 'sent' COMMENT 'draft/scheduled/sent/failed',
    read_count INT DEFAULT 0,
    total_recipients INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_type (notification_type),
    INDEX idx_send_time (send_time),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='通知表';

-- 35. 用户通知阅读记录表（含软删除/隐藏字段）
CREATE TABLE IF NOT EXISTS user_notification_read (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id VARCHAR(64) NOT NULL COMMENT '用户ID',
    notification_id BIGINT NOT NULL COMMENT '通知ID',
    is_read TINYINT(1) DEFAULT 0 COMMENT '是否已读：0未读 1已读',
    is_hidden TINYINT(1) DEFAULT 0 COMMENT '是否对用户隐藏',
    is_deleted_for_user TINYINT(1) DEFAULT 0 COMMENT '用户是否删除了此通知（软删除）',
    read_at DATETIME COMMENT '阅读时间',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (notification_id) REFERENCES notification(id) ON DELETE CASCADE,
    UNIQUE KEY uk_user_notification (user_id, notification_id),
    INDEX idx_user (user_id),
    INDEX idx_notification (notification_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户通知阅读记录表';

-- =================================================================
-- 十六、私信系统 —— 1张
-- =================================================================

-- 36. 私信表
CREATE TABLE IF NOT EXISTS private_message (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    sender_id VARCHAR(64) NOT NULL COMMENT '发送者ID',
    receiver_id VARCHAR(64) NOT NULL COMMENT '接收者ID',
    content TEXT NOT NULL COMMENT '消息内容',
    is_read TINYINT(1) DEFAULT 0 COMMENT '是否已读',
    is_deleted_sender TINYINT(1) DEFAULT 0 COMMENT '发送者是否删除(0-正常 1-删除)',
    is_deleted_receiver TINYINT(1) DEFAULT 0 COMMENT '接收者是否删除(0-正常 1-删除)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (receiver_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_sender_id (sender_id),
    INDEX idx_receiver_id (receiver_id),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='私信消息表（事务双向软删除）';

-- =================================================================
-- 十七、成就系统 —— 2张
-- =================================================================

-- 37. 成就定义表
CREATE TABLE IF NOT EXISTS achievement (
    id INT PRIMARY KEY AUTO_INCREMENT,
    icon VARCHAR(10) COMMENT 'emoji图标',
    name VARCHAR(200) NOT NULL,
    description VARCHAR(500),
    condition_type VARCHAR(50) COMMENT 'streak_days/total_focus_hours/courses_completed/efficiency_score',
    condition_value INT COMMENT '达标阈值',
    category VARCHAR(50),
    sort_order INT DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学习成就定义表';

-- 38. 用户成就表
CREATE TABLE IF NOT EXISTS user_achievement (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id VARCHAR(64) NOT NULL,
    achievement_id INT NOT NULL,
    progress INT DEFAULT 0 COMMENT '当前进度',
    unlocked_at TIMESTAMP NULL COMMENT '解锁时间',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (achievement_id) REFERENCES achievement(id) ON DELETE CASCADE,
    UNIQUE KEY uk_user_achievement (user_id, achievement_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户已获成就表';

-- =================================================================
-- 十八、学习社区 —— 4张
-- =================================================================

-- 39. 学习任务表（通用版，taskPage Servlet使用）
CREATE TABLE IF NOT EXISTS study_task (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id VARCHAR(64) NOT NULL,
    title VARCHAR(500) NOT NULL,
    description TEXT,
    subject VARCHAR(50),
    priority VARCHAR(20) DEFAULT 'medium' COMMENT 'low/medium/high',
    status VARCHAR(20) DEFAULT 'pending' COMMENT 'pending/completed',
    due_date DATE,
    completed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_due_date (due_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学习任务表';

-- 40. 学习小组表
CREATE TABLE IF NOT EXISTS study_group (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    icon VARCHAR(10),
    description VARCHAR(500),
    subject VARCHAR(50),
    creator_id VARCHAR(64),
    member_count INT DEFAULT 0,
    max_members INT DEFAULT 20,
    is_active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (creator_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学习小组表';

-- 41. 学习小组成员表
CREATE TABLE IF NOT EXISTS study_group_member (
    id INT PRIMARY KEY AUTO_INCREMENT,
    group_id INT NOT NULL,
    user_id VARCHAR(64) NOT NULL,
    role VARCHAR(20) DEFAULT 'member' COMMENT 'member/admin',
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (group_id) REFERENCES study_group(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY uk_group_user (group_id, user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学习小组成员表';

-- 42. 学习会话记录表（自习室深度记录）
CREATE TABLE IF NOT EXISTS study_session (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id VARCHAR(64) NOT NULL,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NULL,
    duration INT DEFAULT 0 COMMENT '持续时长(分钟)',
    focus_score INT DEFAULT 0 COMMENT '专注度评分',
    task_description VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学习会话记录表';

-- =================================================================
-- 十九、图书互动 —— 5张
-- =================================================================

-- 43. 学习笔记表
CREATE TABLE IF NOT EXISTS study_note (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id VARCHAR(64) NOT NULL,
    book_id INT,
    course_id INT,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    tags VARCHAR(500) DEFAULT '' COMMENT '逗号分隔标签',
    is_pinned TINYINT(1) DEFAULT 0 COMMENT '是否置顶',
    is_public TINYINT(1) DEFAULT 0 COMMENT '是否公开',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_book_id (book_id),
    INDEX idx_pinned (is_pinned)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学习笔记表';

-- 44. 图书评分表（UPSERT模式：INSERT ON DUPLICATE KEY UPDATE）
CREATE TABLE IF NOT EXISTS book_rating (
    id INT PRIMARY KEY AUTO_INCREMENT,
    book_id INT NOT NULL,
    user_id VARCHAR(64) NOT NULL,
    rating TINYINT NOT NULL COMMENT '评分1-5',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES book(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY uk_book_user (book_id, user_id),
    INDEX idx_book_id (book_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='图书评分表';

-- 45. 图书评论表
CREATE TABLE IF NOT EXISTS book_review (
    id INT PRIMARY KEY AUTO_INCREMENT,
    book_id INT NOT NULL,
    user_id VARCHAR(64) NOT NULL,
    content TEXT NOT NULL,
    parent_id INT DEFAULT 0 COMMENT '父评论ID(支持嵌套)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES book(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_book_id (book_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='图书评论表';

-- 46. 图书阅读记录表
CREATE TABLE IF NOT EXISTS book_read_record (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id VARCHAR(64) NOT NULL,
    book_id INT NOT NULL,
    current_page INT DEFAULT 1 COMMENT '当前页码',
    total_pages INT DEFAULT 0 COMMENT '总页数',
    reading_time INT DEFAULT 0 COMMENT '累计阅读时间(分钟)',
    last_read_time TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (book_id) REFERENCES book(id) ON DELETE CASCADE,
    UNIQUE KEY uk_user_book (user_id, book_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='图书阅读记录表';

-- 47. 用户收藏表
CREATE TABLE IF NOT EXISTS user_bookmark (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id VARCHAR(64) NOT NULL,
    book_id INT NOT NULL,
    target_type VARCHAR(50) DEFAULT 'book',
    target_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY uk_user_book (user_id, book_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户收藏表';

-- =================================================================
-- 二十、其他辅助表 —— 4张
-- =================================================================

-- 48. 用户活动日志表
CREATE TABLE IF NOT EXISTS user_activity (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id VARCHAR(64),
    activity_type VARCHAR(50) NOT NULL COMMENT 'login/view_book/read/visit_scene/start_pomodoro等',
    reference_id VARCHAR(100),
    detail VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_type (user_id, activity_type),
    INDEX idx_activity_time (created_at),
    INDEX idx_activity_type (activity_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户活动日志表';

-- 49. 用户评价表（课程/讲座等多目标评价）
CREATE TABLE IF NOT EXISTS user_evaluations (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id VARCHAR(64) NOT NULL,
    target_type VARCHAR(50) NOT NULL COMMENT 'course/lecture/book',
    target_id INT NOT NULL,
    rating INT NOT NULL COMMENT '评分1-5',
    comment TEXT COMMENT '评价内容',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_target (target_type, target_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户评价表';

-- 50. 虚拟实验室实验表
CREATE TABLE IF NOT EXISTS lab_experiment (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(200) NOT NULL,
    category VARCHAR(50) NOT NULL COMMENT 'physics/chemistry/biology/cs',
    description TEXT,
    equipment TEXT COMMENT '所需器材',
    steps TEXT COMMENT 'JSON步骤',
    safety_notes TEXT COMMENT '安全须知',
    difficulty VARCHAR(20) DEFAULT 'medium' COMMENT 'easy/medium/hard',
    duration_min INT DEFAULT 30,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active TINYINT(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='虚拟实验室实验表';

-- 51. 图书内容表
CREATE TABLE IF NOT EXISTS book_content (
    id INT PRIMARY KEY AUTO_INCREMENT,
    book_id INT NOT NULL,
    chapter_title VARCHAR(200),
    content TEXT,
    page_number INT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES book(id) ON DELETE CASCADE,
    INDEX idx_book_id (book_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='图书内容表';

-- =================================================================
-- =================================================================
-- 测  试  数  据
-- =================================================================
-- =================================================================

-- 1. 用户测试数据（密码均为 BCrypt("123456")）
INSERT IGNORE INTO users (id, username, password, nickname, sex, age, email, role) VALUES
('u001', 'admin', '$2a$10$EixZaYVK1fsbw1ZfbX3OXe.P0qF1OJ1EYsPU7mJU3wsSC3qG1GN7K', '超级管理员', '男', 30, 'admin@boya.edu', 'admin'),
('u002', 'zhangsan', '$2a$10$EixZaYVK1fsbw1ZfbX3OXe.P0qF1OJ1EYsPU7mJU3wsSC3qG1GN7K', '张三', '男', 21, 'zhangsan@boya.edu', 'user'),
('u003', 'lisi', '$2a$10$EixZaYVK1fsbw1ZfbX3OXe.P0qF1OJ1EYsPU7mJU3wsSC3qG1GN7K', '李四', '女', 20, 'lisi@boya.edu', 'user'),
('u004', 'wangwu', '$2a$10$EixZaYVK1fsbw1ZfbX3OXe.P0qF1OJ1EYsPU7mJU3wsSC3qG1GN7K', '王五', '男', 22, 'wangwu@boya.edu', 'user'),
('u005', 'zhaoliu', '$2a$10$EixZaYVK1fsbw1ZfbX3OXe.P0qF1OJ1EYsPU7mJU3wsSC3qG1GN7K', '赵六', '女', 19, 'zhaoliu@boya.edu', 'user'),
('u006', 'sunqi', '$2a$10$EixZaYVK1fsbw1ZfbX3OXe.P0qF1OJ1EYsPU7mJU3wsSC3qG1GN7K', '孙七', '男', 23, 'sunqi@boya.edu', 'user'),
('u007', 'zhouba', '$2a$10$EixZaYVK1fsbw1ZfbX3OXe.P0qF1OJ1EYsPU7mJU3wsSC3qG1GN7K', '周八', '女', 20, 'zhouba@boya.edu', 'user'),
('u010', 'manager1', '$2a$10$EixZaYVK1fsbw1ZfbX3OXe.P0qF1OJ1EYsPU7mJU3wsSC3qG1GN7K', '教务管理员', '男', 35, 'manager@boya.edu', 'admin')
ON DUPLICATE KEY UPDATE username=VALUES(username);

-- 2. 图书分类测试数据
INSERT IGNORE INTO booktype (bTypeName, btText, sort_order) VALUES
('计算机科学', '计算机科学与技术相关图书', 1),
('人工智能', '人工智能与机器学习相关图书', 2),
('数据科学', '数据分析与大数据相关图书', 3),
('软件工程', '软件开发与工程实践图书', 4),
('网络安全', '信息安全与网络防护图书', 5),
('文学经典', '中外文学名著与经典作品', 6),
('哲学历史', '哲学思辨与历史研究图书', 7),
('经济管理', '经济学与管理学理论与实践', 8),
('艺术设计', '艺术审美与创意设计图书', 9),
('自然科学', '数学物理化学生物等基础科学', 10),
('建筑土木', '建筑设计、结构与土木工程', 11),
('数学基础', '高等数学、线性代数等基础教材', 12)
ON DUPLICATE KEY UPDATE btText=VALUES(btText);

-- 3. 图书测试数据
INSERT IGNORE INTO book (id, book_title, book_author, book_summary, type_id, download_count, book_publish, file_path, cover_image, file_type) VALUES
(1001, '三体', '刘慈欣', '科幻巨作，讲述地球文明与三体文明的接触与碰撞', 6, 5234, '重庆出版社', '/books/santi.pdf', '/covers/santi.jpg', 'PDF'),
(1002, '活着', '余华', '讲述普通人在大时代背景下的生存故事', 6, 4123, '作家出版社', '/books/huozhe.pdf', '/covers/huozhe.jpg', 'PDF'),
(1004, '深入理解计算机系统', 'Randal E. Bryant', '从程序员视角深入理解计算机系统原理', 1, 2345, '机械工业出版社', '/books/csapp.pdf', '/covers/csapp.jpg', 'PDF'),
(1006, '算法导论', 'Thomas H. Cormen', '计算机算法领域的经典教材', 1, 3456, '机械工业出版社', '/books/algo.pdf', '/covers/algo.jpg', 'PDF'),
(2005, 'Python编程从入门到实践', 'Eric Matthes', 'Python编程经典入门教材，项目驱动学习', 1, 4567, '人民邮电出版社', '/books/python.pdf', '/covers/python.jpg', 'PDF'),
(2006, 'JavaScript高级程序设计', 'Matt Frisbie', '前端开发必读红宝书，深入讲解JS核心概念', 1, 3210, '人民邮电出版社', '/books/js.pdf', '/covers/js.jpg', 'PDF'),
(2008, '机器学习实战', 'Peter Harrington', '理论实践结合，含丰富的代码示例', 2, 2345, '人民邮电出版社', '/books/ml.pdf', '/covers/ml.jpg', 'PDF'),
(2009, '深度学习', 'Ian Goodfellow', '深度学习领域权威教材', 2, 1890, '人民邮电出版社', '/books/dl.pdf', '/covers/dl.jpg', 'PDF'),
(2017, '设计中的设计', '原研哉', '日本设计大师的设计哲学与美学思考', 9, 1560, '广西师范大学出版社', '/books/design.pdf', '/covers/design.jpg', 'PDF'),
(2024, '人类简史', '尤瓦尔·赫拉利', '从认知革命到科学革命的人类发展史', 7, 4320, '中信出版社', '/books/sapiens.pdf', '/covers/sapiens.jpg', 'PDF');

-- 4. 课程测试数据
INSERT IGNORE INTO course (id, course_name, course_category, course_level, instructor_id, instructor_name, course_hours, rating, enrolled_count, description) VALUES
(1, 'Python数据分析实战', '数据科学', 'intermediate', 1, '张教授', 48, 4.9, 2300, '从入门到精通的数据分析课程，涵盖NumPy、Pandas、Matplotlib'),
(2, '深度学习与神经网络', 'AI与机器学习', 'advanced', 1, '张教授', 64, 4.8, 1800, '系统学习深度学习理论，掌握CNN、RNN、Transformer'),
(3, 'React全栈开发', '前端开发', 'intermediate', 4, '陈教授', 32, 4.7, 1500, '从零构建React企业级应用'),
(4, 'Web前端开发基础', '前端开发', 'beginner', 4, '陈教授', 40, 4.6, 3200, 'HTML、CSS、JavaScript基础'),
(5, '机器学习基础', 'AI与机器学习', 'beginner', 2, '李博士', 56, 4.8, 2800, '理解机器学习核心算法和原理');

-- 5. 用户课程学习记录
INSERT IGNORE INTO user_course_record (user_id, course_id, progress, study_hours, completed_chapters, last_study_time, completed) VALUES
('u001', 1, 65.00, 32.00, '1,2,3,4,5,6', DATE_SUB(NOW(), INTERVAL 1 DAY), 0),
('u001', 2, 30.00, 12.00, '1,2', DATE_SUB(NOW(), INTERVAL 2 DAY), 0),
('u001', 5, 100.00, 56.00, '1,2,3,4,5,6,7,8', DATE_SUB(NOW(), INTERVAL 30 DAY), 1),
('u002', 3, 45.00, 18.00, '1,2,3,4', DATE_SUB(NOW(), INTERVAL 1 DAY), 0),
('u002', 4, 100.00, 40.00, '1,2,3,4,5,6,7,8,9,10', DATE_SUB(NOW(), INTERVAL 20 DAY), 1),
('u003', 3, 50.00, 24.00, '1,2,3,4,5', DATE_SUB(NOW(), INTERVAL 12 HOUR), 0),
('u003', 5, 80.00, 44.00, '1,2,3,4,5,6', DATE_SUB(NOW(), INTERVAL 2 DAY), 0),
('u004', 4, 70.00, 28.00, '1,2,3,4,5,6,7', NOW(), 0),
('u005', 1, 40.00, 16.00, '1,2,3,4', DATE_SUB(NOW(), INTERVAL 1 DAY), 0),
('u005', 2, 25.00, 10.00, '1,2', DATE_SUB(NOW(), INTERVAL 3 DAY), 0);

-- 6. 用户学习汇总
INSERT IGNORE INTO user_study_summary (user_id, total_courses, total_study_hours, campus_points, week_progress, streak_days, last_study_date) VALUES
('u001', 3, 100.00, 2630, 75, 14, CURDATE()),
('u002', 2, 58.00, 1850, 60, 7, CURDATE()),
('u003', 2, 45.00, 1200, 50, 5, CURDATE()),
('u004', 1, 30.00, 950, 40, 3, CURDATE()),
('u005', 2, 36.00, 1100, 55, 9, DATE_SUB(CURDATE(), INTERVAL 1 DAY));

-- 7. 知识技能雷达图
INSERT IGNORE INTO knowledge_skills (user_id, skill_name, skill_value, skill_color) VALUES
('u001','AI与机器学习',85,'#00f2ff'),('u001','数字人文',70,'#b77eff'),('u001','数据科学',90,'#00f2ff'),
('u001','创意编程',65,'#b77eff'),('u001','量子计算',45,'#00f2ff'),('u001','生物信息',55,'#b77eff'),
('u002','AI与机器学习',70,'#00f2ff'),('u002','数字人文',60,'#b77eff'),('u002','数据科学',75,'#00f2ff'),
('u002','创意编程',80,'#b77eff'),('u002','量子计算',40,'#00f2ff'),('u002','生物信息',50,'#b77eff'),
('u003','AI与机器学习',60,'#00f2ff'),('u003','前端开发',88,'#ff6b6b'),('u003','软件工程',82,'#51cf66'),
('u003','创意编程',72,'#b77eff'),('u003','数据科学',55,'#00f2ff'),('u003','云计算',65,'#ffd43b'),
('u004','前端开发',75,'#ff6b6b'),('u004','UI设计',85,'#b77eff'),('u004','创意编程',90,'#b77eff'),
('u004','数字人文',60,'#b77eff'),('u004','软件工程',55,'#51cf66'),('u004','数据科学',45,'#00f2ff');

-- 8. 学习路径
INSERT IGNORE INTO learning_paths (user_id, step_number, title, description, status, progress_percent) VALUES
('u001',1,'Python编程基础','掌握Python基本语法和编程思维','completed',100),
('u001',2,'数据分析入门','学习NumPy、Pandas等数据分析工具','completed',100),
('u001',3,'机器学习基础','理解机器学习核心算法和原理','current',65),
('u001',4,'深度学习实践','使用TensorFlow/PyTorch构建神经网络','upcoming',0),
('u001',5,'AI项目实战','完成一个完整的AI应用项目','upcoming',0),
('u002',1,'Web前端开发','HTML、CSS、JavaScript基础','completed',100),
('u002',2,'前端框架学习','React/Vue框架应用开发','current',45),
('u002',3,'后端接口开发','RESTful API设计与实现','upcoming',0);

-- 9. 推荐内容
INSERT IGNORE INTO recommendations (title, category, description, type, badge, author, meta_info, rating, sort_order) VALUES
('Python数据分析实战','数据科学','从入门到精通的数据分析课程','courses','hot','李明教授','48课时·2.3万人学习',4.9,1),
('深度学习与神经网络','AI与机器学习','系统学习深度学习理论','courses','new','张伟教授','64课时·1.8万人学习',4.8,2),
('数据科学导论','数据科学','全面介绍数据科学领域','books','trending','王芳博士','352页·豆瓣9.2',4.7,3),
('AI伦理与未来社会','数字人文','探讨AI对社会的影响与挑战','lectures','personal','陈教授','120分钟·直播讲座',4.9,4),
('创意编程艺术','创意编程','用代码创造视觉艺术','courses','skill','刘艺老师','32课时·项目驱动',4.6,5),
('算法之美','计算机科学','经典算法解析与实现','books','classic','Donald Knuth','800页·计算机经典',5.0,6);

-- 10. 用户兴趣标签
INSERT IGNORE INTO user_interest_tag (user_id, tag_name, weight) VALUES
('u001','AI与机器学习',9.5),('u001','数据科学',8.5),('u001','Python编程',8.0),('u001','深度学习',7.5),('u001','量子计算',6.0),
('u002','前端开发',9.0),('u002','Web技术',8.5),('u002','UI设计',7.0),('u002','JavaScript',8.0),
('u003','软件工程',9.0),('u003','Java开发',8.0),('u003','系统设计',7.5),('u003','数据库',7.0),
('u004','创意编程',9.0),('u004','UI/UX设计',8.5),('u004','数字艺术',8.0),('u004','文学阅读',7.0),
('u005','数据分析',8.0),('u005','人工智能',7.5),('u005','Python基础',8.5),('u005','机器学习',7.0);

-- 11. 推荐记录
INSERT IGNORE INTO recommendation_log (user_id, recommend_type, recommend_id, recommend_reason, clicked, clicked_at) VALUES
('u001','course',2,'根据您对AI的兴趣推荐',1,DATE_SUB(NOW(),INTERVAL 2 DAY)),
('u001','book',2008,'与您正在学习的课程相关',1,DATE_SUB(NOW(),INTERVAL 3 DAY)),
('u001','lecture',1,'基于您的AI兴趣标签',1,DATE_SUB(NOW(),INTERVAL 5 DAY)),
('u002','course',3,'基于您的前端开发兴趣推荐',1,DATE_SUB(NOW(),INTERVAL 1 DAY)),
('u002','book',2006,'前端开发进阶必读书籍',1,DATE_SUB(NOW(),INTERVAL 2 DAY)),
('u003','course',3,'基于您的软件工程兴趣推荐',1,DATE_SUB(NOW(),INTERVAL 3 DAY)),
('u003','book',1004,'计算机经典必读',1,DATE_SUB(NOW(),INTERVAL 5 DAY)),
('u004','course',4,'完善前端开发基础',1,DATE_SUB(NOW(),INTERVAL 10 DAY)),
('u005','course',1,'数据科学入门推荐课程',1,DATE_SUB(NOW(),INTERVAL 5 DAY)),
('u005','book',2024,'拓宽知识面的经典读物',1,DATE_SUB(NOW(),INTERVAL 7 DAY));

-- 12. 校友
INSERT IGNORE INTO alumni (name, title, achievement, company, graduation_year, major, is_honorary, sort_order) VALUES
('陈明远','星链科技创始人/CEO','主导研发全球首个教育卫星星座','星链科技',2015,'计算机科学',1,1),
('林诗涵','AI伦理委员会主席','推动全球首个AI教育伦理框架落地','国际AI伦理委员会',2012,'人工智能',1,2),
('王浩然','量子计算实验室主任','突破量子纠错关键技术','国家量子实验室',2018,'物理学',0,3),
('张雅婷','数字人文研究院院长','创建"数字敦煌"项目','故宫博物院',2010,'数字媒体',1,4),
('李思远','生物信息学先驱','开发基因序列分析算法','华大基因',2016,'生物信息',0,5);

-- 13. 导师
INSERT IGNORE INTO faculty (name, title, avatar_icon, research_area, department, email, office, office_hours, bio, sort_order) VALUES
('沈怀瑾','首席科学家','📡','古典文献数字化/AI古籍修复','数字人文学院','shen@boya.edu','科技楼A101','周一、三14:00-16:00','古典文献数字化学者',1),
('柳青辞','教授','🎛️','数字艺术/生成式艺术','数字艺术学院','liu@boya.edu','艺术楼B201','周二、四9:00-11:00','数字艺术先驱',2),
('顾允之','博士','🌐','计算哲学/AI伦理与治理','哲学与AI学院','gu@boya.edu','人文楼C301','周三、五14:00-16:00','计算哲学专家',3),
('周明萱','教授','🧬','计算诗学/数字人文','文学与计算学院','zhou@boya.edu','人文楼A102','周一、四10:00-12:00','计算诗学研究主任',4),
('姚期智','院士','⚡','量子计算/AI前沿','计算机科学学院','yao@boya.edu','科技楼D501','预约制','量子计算讲席教授',5),
('张明远','教授','👨‍🔬','深度学习/计算机视觉','计算机学院','zhang@boya.edu','科技楼A201','周二、四14:00-16:00','AI领域专家',6);

-- 14. 专业
INSERT IGNORE INTO major (name, code, icon, description, category, is_interdisciplinary, department, degree_type, sort_order) VALUES
('人工智能','AI001','🤖','培养掌握AI理论与技术的高级人才','工科',1,'计算机学院','学士',1),
('数据科学与大数据技术','DS001','📊','培养数据分析与挖掘专业人才','工科',0,'计算机学院','学士',2),
('软件工程','SE001','💻','培养软件设计与开发专业人才','工科',0,'软件学院','学士',3),
('网络空间安全','NS001','🔒','培养网络安全与信息防护专业人才','工科',0,'网络空间安全学院','学士',4),
('数字媒体技术','DM001','🎨','培养数字创意与技术融合人才','艺术',1,'艺术学院','学士',5);

-- 15. 学域-图书分类关联
INSERT IGNORE INTO major_book_type (major_code, book_type_id) VALUES
('AI001', '1'), ('AI001', '2'), ('AI001', '3'),
('DS001', '3'), ('DS001', '1'),
('SE001', '4'), ('SE001', '1'),
('NS001', '5'), ('NS001', '1'),
('DM001', '9'), ('DM001', '5');

-- 16. 讲座
INSERT IGNORE INTO lecture (title, speaker, speaker_title, lecture_date, lecture_time, description, is_online, meeting_url, status, view_count, sort_order) VALUES
('量子计算：从理论到实践','李量子教授','量子计算实验室主任','2025-09-15 14:00:00','14:00-16:00','深入浅出讲解量子计算原理',1,'https://meet.boya.edu/quantum','upcoming',156,1),
('AI时代的教育变革','王教育博士','未来教育研究院院长','2025-10-08 10:00:00','10:00-12:00','AI如何重塑教育模式',1,'https://meet.boya.edu/ai-edu','upcoming',89,2),
('元宇宙中的文化遗产保护','张文化教授','数字人文研究中心主任','2025-11-02 15:00:00','15:00-17:00','VR/AR技术在文物保护的案例',1,'https://meet.boya.edu/meta-culture','upcoming',234,3),
('数字人文与古籍活化','王宏甦','北大数字人文中心研究员','2025-12-05 09:00:00','09:00-11:30','数字技术对古籍活化保护',1,'https://meet.boya.edu/lecture4','upcoming',312,4);

-- 17. 讲座报名
INSERT IGNORE INTO lecture_registration (user_id, lecture_id, attendance_status) VALUES
('u001',1,'registered'),('u001',2,'registered'),('u001',3,'attended'),
('u002',1,'registered'),('u002',2,'attended'),
('u003',1,'attended'),('u003',3,'registered'),
('u004',2,'registered'),('u004',3,'registered'),
('u005',1,'registered'),('u005',2,'registered');

-- 18. 文化活动
INSERT IGNORE INTO culture_events (season, event_name, description, event_type, event_date, location, sort_order) VALUES
('仲春','算法诗会','AI协同创作与数字书法展览','exhibition','2025-04-15','博雅艺术馆',1),
('孟夏','未来论坛','脑机接口与人文精神对话','forum','2025-06-08','智识报告厅',2),
('清秋','元宇宙雅集','虚拟现实古琴演奏会','concert','2025-09-20','虚拟空间·云端厅',3),
('岁末','智识年会','跨学科前沿峰会与鸿儒论道','summit','2025-12-28','博雅大礼堂',4);

-- 19. 文化艺术作品
INSERT IGNORE INTO culture_artworks (title, artist, description, artwork_type, image_url, created_year, sort_order) VALUES
('星空·代码','王艺','用Processing生成算法创作的星空图','digital','/images/artworks/starry-code.jpg',2024,1),
('数字水墨·山水','李明','传统水墨画转化为数字算法生成','digital','/images/artworks/digital-ink.jpg',2023,2),
('校园四季','陈诗','博雅书院校园灵感的系列水彩画','painting','/images/artworks/campus-four-seasons.jpg',2024,3),
('数据之舞','赵艺','数据可视化技术创作动态艺术','interactive','/images/artworks/data-dance.jpg',2025,4),
('AI梦境','刘创','使用AI生成的超现实主义作品','ai-art','/images/artworks/ai-dreams.jpg',2025,5);

-- 20. 文化社团
INSERT IGNORE INTO culture_clubs (name, icon, description, member_count, activity_count, sort_order) VALUES
('代码诗人社','✍️','用代码书写诗意',128,24,1),
('数字艺术家联盟','🎨','数字绘画、生成艺术',256,36,2),
('科幻研读会','📚','科幻小说阅读与创作',89,18,3),
('极客茶话会','🍵','技术沙龙，分享前沿技术',312,48,4);

-- 21. 历史里程碑
INSERT IGNORE INTO history_records (year, title, description, sort_order) VALUES
('2025','元宇宙校园启动','打造全球首个教育元宇宙平台',1),
('2024','AI教学助手上线','推出智能教学助手，提供个性化学习建议',2),
('2023','量子计算课程开设','国内高校首批开设量子计算本科课程',3),
('2022','数字人文研究院成立','跨学科融合数字技术与人文科学',4),
('2021','星链教育计划','发射首颗教育卫星，开启太空教育时代',5),
('2020','智能选课系统','上线AI驱动的智能选课推荐系统',6);

-- 22. 虚拟校园场景
INSERT IGNORE INTO campus_scene (name, scene_key, icon, description, scene_type, features, sort_order) VALUES
('数字图书馆','library','📚','海量数字藏书，沉浸式阅读体验','learning','["360°全景","智能书架","沉浸阅读"]',1),
('虚拟实验室','lab','🔬','安全可重复的虚拟实验操作环境','experiment','["实验模拟","数据采集","安全操作"]',2),
('圆形剧场','amphitheater','🎭','在线讲座和学术交流的虚拟空间','lecture','["实时互动","白板协作","语音讨论"]',3),
('智慧花园','garden','🌿','放松身心的虚拟自然空间','leisure','["环境音效","冥想引导","自然景观"]',4);

-- 23. 校园3D统计
INSERT IGNORE INTO campus3d_stats (stat_date, online_users, scene_count, satisfaction_rate) VALUES
(CURDATE(), 320, 12, 95);

-- 24. 自习室统计
INSERT IGNORE INTO studyroom_stats (stat_date, online_users, total_minutes, focus_score, room_rank, today_study_text, streak_days, efficiency_score) VALUES
(CURDATE(), 248, 1250, 86, 12, '2小时35分', 14, 87);

-- 25. 学习任务（自习室专用）
INSERT IGNORE INTO studyroom_tasks (user_id, task_content, priority, due_date, completed) VALUES
('u001','完成《深度学习实战》第3章学习','high',DATE_ADD(CURDATE(),INTERVAL 2 DAY),0),
('u001','预习React状态管理与Hooks','normal',DATE_ADD(CURDATE(),INTERVAL 3 DAY),0),
('u001','完成数学推导作业习题5-10','normal',DATE_ADD(CURDATE(),INTERVAL 1 DAY),1),
('u002','完成前端项目响应式布局','high',DATE_ADD(CURDATE(),INTERVAL 1 DAY),0),
('u005','完成Python数据分析作业','high',DATE_ADD(CURDATE(),INTERVAL 1 DAY),0);

-- 26. 校园积分明细
INSERT IGNORE INTO studyroom_points (user_id, points, total_points, reason) VALUES
('u001',100,100,'完成课程学习-Python数据分析实战'),
('u001',50,150,'参与讲座-量子计算：从理论到实践'),
('u001',200,350,'完成机器学习基础课程'),
('u001',80,430,'连续学习7天奖励'),
('u001',500,960,'获得"学习之星"称号奖励'),
('u001',150,1110,'完成深度学习课程前三章'),
('u002',80,80,'完成任务-前端页面开发'),
('u002',100,180,'完成Web前端开发基础课程'),
('u002',200,380,'连续学习5天奖励'),
('u003',50,50,'完成Java编程基础作业'),
('u003',150,200,'软件工程课程阶段测验通过'),
('u004',50,50,'完成UI设计作品'),
('u004',120,170,'创意编程作品提交');

-- 27. 番茄钟记录
INSERT IGNORE INTO pomodoro_session (user_id, focus_duration, break_duration, started_at, completed_at, is_completed) VALUES
('u001',25,5,DATE_SUB(NOW(),INTERVAL 2 HOUR),DATE_SUB(NOW(),INTERVAL 95 MINUTE),1),
('u001',25,5,DATE_SUB(NOW(),INTERVAL 90 MINUTE),DATE_SUB(NOW(),INTERVAL 65 MINUTE),1),
('u001',50,10,DATE_SUB(NOW(),INTERVAL 55 MINUTE),DATE_SUB(NOW(),INTERVAL 5 MINUTE),1),
('u002',25,5,DATE_SUB(NOW(),INTERVAL 3 HOUR),DATE_SUB(NOW(),INTERVAL 155 MINUTE),1),
('u003',25,5,DATE_SUB(NOW(),INTERVAL 1 HOUR),NULL,0);

-- 28. 首页新闻公告
INSERT IGNORE INTO home_news (title, content, news_type, priority, author, view_count, publish_time, is_top, is_important) VALUES
('2025年春学期选课通知','各位同学，2025年春季学期选课系统将于1月15日正式开放，请及时登录系统完成选课。','announcement','high','教务处',5234,NOW(),1,1),
('系统版本升级公告','博雅书院平台已完成v3.0版本升级，新增AI智能推荐、元宇宙校园等核心功能。','news','urgent','技术部',2345,NOW(),0,1),
('AI创新大赛报名启动','全校AI创新大赛正式启动！总奖金10万元。','event','normal','学生会',3412,NOW(),0,0),
('期末考试时间安排','春季学期期末考试将于6月20日-7月5日进行，请大家合理安排复习时间。','announcement','normal','教务处',876,NOW(),0,0);

-- 29. 管理统计
INSERT IGNORE INTO dashboard_stats (stat_date, active_users, today_visits, course_completion_rate, system_health, total_courses, total_students, total_teachers) VALUES
(CURDATE(), 2480, 1842, 78, 99.8, 156, 3200, 89);

-- 30. 访问统计（7天趋势）
INSERT IGNORE INTO dashboard_access_stats (stat_date, total_visits, unique_visitors, new_users, active_users, page_views, avg_session_duration, bounce_rate) VALUES
(DATE_SUB(CURDATE(),INTERVAL 6 DAY),1200,820,45,680,3600,1080,32.5),
(DATE_SUB(CURDATE(),INTERVAL 5 DAY),1350,890,52,720,4050,1200,30.2),
(DATE_SUB(CURDATE(),INTERVAL 4 DAY),1420,930,38,750,4260,1140,31.8),
(DATE_SUB(CURDATE(),INTERVAL 3 DAY),1580,1020,61,810,4740,1320,28.5),
(DATE_SUB(CURDATE(),INTERVAL 2 DAY),1680,1080,55,860,5040,1260,29.0),
(DATE_SUB(CURDATE(),INTERVAL 1 DAY),1820,1150,68,920,5460,1380,27.3),
(CURDATE(),1900,1200,72,960,5700,1440,26.8);

-- 31. 监控日志
INSERT IGNORE INTO dashboard_monitor_log (log_type, metric_name, metric_value, threshold, status, message) VALUES
('cpu','CPU使用率',42.5,80.0,'normal','CPU使用率正常'),
('memory','内存使用率',65.3,85.0,'normal','内存使用率正常'),
('disk','磁盘使用率',78.2,90.0,'warning','磁盘使用率偏高，请注意清理');

-- 32. 内容审核
INSERT IGNORE INTO content_review (content_type, content_id, title, content_preview, submitter, priority, ai_score, ai_feedback) VALUES
('course',1,'Python数据分析实战课程','这是一门面向初学者的数据分析课程...','张教授','high',9.2,'内容专业性强，建议在代码示例中添加更多注释'),
('article',2,'量子计算入门指南','深入浅出介绍量子计算基础概念...','李研究员','normal',8.5,'观点新颖，论据充分'),
('comment',3,'课程评价：机器学习基础','这门课程讲得非常好，老师很专业...','王同学','normal',7.8,'技术内容准确'),
('report',4,'涉嫌违规讨论','用户举报该讨论涉及敏感技术内容','匿名','report',6.0,'需要人工重点审核'),
('data',5,'数字人文研究论文数据集','包含5万条标注数据的古籍文本数据集','王博士','low',9.0,'数据质量高');

-- 33. 通知
INSERT IGNORE INTO notification (title, content, notification_type, target_type, sender_id, send_time, status, read_count, total_recipients) VALUES
('系统升级完成通知','博雅书院系统已完成版本升级，新增AI助教和推荐系统功能','success','all','u001',NOW(),'sent',156,200),
('选课提醒','2025年春季学期选课将于下周开始，请及时登录系统选课','warning','students','u001',NOW(),'sent',89,150),
('图书馆开放时间调整','寒假期间图书馆开放时间调整为9:00-17:00','info','all','u010',NOW(),'sent',234,200),
('密码安全提醒','检测到部分用户密码过于简单，请及时修改以确保账户安全','error','custom','u001',DATE_SUB(NOW(),INTERVAL 7 DAY),'sent',45,52);

-- 34. 通知阅读记录
INSERT IGNORE INTO user_notification_read (user_id, notification_id, is_read, read_at) VALUES
('u001',1,1,NOW()),('u002',1,1,NOW()),('u002',2,1,NOW()),
('u003',3,0,NULL),('u004',4,1,NOW()),('u005',5,1,NOW());

-- 35. 私信
INSERT IGNORE INTO private_message (sender_id, receiver_id, content, is_read) VALUES
('u002','u003','你好！最近在看什么书呢？',1),
('u003','u002','我正在看《深入理解计算机系统》，挺不错的！',1),
('u002','u003','这本书我也看过，确实很经典，推荐你也看看《算法导论》',0),
('u004','u002','学长，请问Java学习有什么好的建议吗？',0),
('u002','u004','多做项目实践，推荐先从基础开始，然后做一些小型项目',1),
('u001','u002','您好，系统即将进行维护升级，请注意保存数据',0),
('u005','u001','管理员您好，我想申请开设一门新课程',1),
('u003','u005','老师好，请问这门课程什么时候开课呢？',0);

-- 36. 成就定义
INSERT IGNORE INTO achievement (icon, name, description, condition_type, condition_value, sort_order) VALUES
('🔥','专注先锋','连续学习5天','streak_days',5,1),
('⏱️','时间管理师','累计学习50小时','total_focus_hours',50,2),
('📚','博览群书','完成10门课程','courses_completed',10,3),
('🚀','高效达人','效率指数90+','efficiency_score',90,4);

-- 37. 用户成就
INSERT IGNORE INTO user_achievement (user_id, achievement_id, unlocked_at) VALUES
('u001',1,NOW()),('u001',2,NOW()),('u001',3,NOW()),('u001',4,NOW()),
('u002',1,NOW()),('u002',2,NOW()),
('u003',1,NOW()),('u003',4,NOW()),
('u004',1,NOW()),
('u005',1,NOW()),('u005',2,NOW());

-- 38. 学习笔记
INSERT IGNORE INTO study_note (user_id, book_id, title, content, tags, is_pinned) VALUES
('u001',1,'《深度学习》第二章要点','## 反向传播算法\n\n1.链式法则应用\n2.梯度消失问题\n3.ReLU vs Sigmoid','深度学习,算法,笔记',1),
('u001',2,'Java并发编程笔记','## 线程池核心参数\n- corePoolSize\n- maximumPoolSize\n- keepAliveTime\n- workQueue','Java,并发',1),
('u003',3,'Spring Boot启动流程','1.创建SpringApplication\n2.准备Environment\n3.创建ApplicationContext\n4.刷新容器','Spring,框架',0),
('u004',NULL,'本周学习计划','- [x]完成算法作业\n- []复习数据库\n- []阅读论文\n- []准备项目答辩','计划,周报',0);

-- 39. 图书评分
INSERT IGNORE INTO book_rating (book_id, user_id, rating) VALUES
(1001,'u001',5),(1001,'u002',5),(1001,'u003',4),
(1002,'u001',5),(1002,'u004',5),(1002,'u005',5),
(1004,'u001',5),(1004,'u003',4),
(1006,'u002',5),(1006,'u003',5),
(2005,'u001',4),(2005,'u002',5),
(2006,'u002',5),(2006,'u004',4),
(2008,'u001',5),(2009,'u001',5),(2024,'u003',5);

-- 40. 图书评论
INSERT IGNORE INTO book_review (book_id, user_id, content) VALUES
(1001,'u001','《三体》是一部颠覆认知的科幻巨作，刘慈欣用宏大的宇宙观和精妙的科学构思，构建了一个令人叹为观止的宇宙文明图景。'),
(1002,'u001','余华的《活着》用最朴实的语言讲述了最深刻的人生哲理。福贵的一生让人泪目。'),
(1004,'u003','计算机专业的必读经典！从硬件到软件，从底层到应用，全面覆盖了计算机系统的核心知识。'),
(2005,'u001','Python入门最佳选择，循序渐进，实战项目丰富。'),
(2006,'u002','前端开发的必读红宝书！涵盖ES6+新特性，深入浅出讲解JavaScript核心概念。'),
(2024,'u003','尤瓦尔·赫拉利的《人类简史》是一本思考人类命运的奇书。');

-- 41. 图书阅读记录
INSERT IGNORE INTO book_read_record (user_id, book_id, current_page, total_pages, reading_time, last_read_time) VALUES
('u001',2005,156,420,320,DATE_SUB(NOW(),INTERVAL 1 DAY)),
('u001',2008,89,350,180,DATE_SUB(NOW(),INTERVAL 2 DAY)),
('u002',2006,234,560,450,NOW()),
('u002',2005,310,420,600,DATE_SUB(NOW(),INTERVAL 1 DAY)),
('u003',1004,120,850,240,DATE_SUB(NOW(),INTERVAL 3 DAY)),
('u003',1006,340,980,680,DATE_SUB(NOW(),INTERVAL 1 DAY)),
('u005',1002,95,210,200,DATE_SUB(NOW(),INTERVAL 1 DAY)),
('u005',2024,180,460,350,NOW());

-- 42. 用户收藏
INSERT IGNORE INTO user_bookmark (user_id, book_id, target_type) VALUES
('u001',1001,'book'),('u001',2008,'book'),('u002',2006,'book'),('u003',1004,'book');

-- 43. 用户活动日志
INSERT IGNORE INTO user_activity (user_id, activity_type, reference_id, detail) VALUES
('u001','login',NULL,'管理员登录系统'),
('u001','view_book','1001','浏览图书-三体'),
('u002','login',NULL,'用户登录'),
('u002','start_pomodoro',NULL,'开始番茄钟25分钟'),
('u003','login',NULL,'用户登录'),
('u003','visit_scene','1','访问数字图书馆'),
('u004','login',NULL,'用户登录'),
('u005','view_book','2005','浏览图书-Python编程');

-- 44. 用户评价
INSERT IGNORE INTO user_evaluations (user_id, target_type, target_id, rating, comment) VALUES
('u001','course',1,5,'非常棒的课程！张教授讲解清晰，实战项目很有挑战性。'),
('u001','course',2,5,'深度学习领域的顶级课程，内容深入但不难懂。'),
('u002','course',3,4,'React全栈开发课程质量很高，项目实战部分特别有帮助。'),
('u003','course',3,5,'内容全面，从基础到高级循序渐进，很推荐！'),
('u001','lecture',1,5,'量子计算讲座非常前沿，李教授讲得通俗易懂。'),
('u004','lecture',3,5,'元宇宙与文化遗产保护的结合非常有创意！');

-- 45. 实验室实验
INSERT IGNORE INTO lab_experiment (name, category, description, difficulty, duration_min) VALUES
('牛顿第二定律验证实验','physics','通过实验验证牛顿第二定律','medium',45),
('化学反应速率测定','chemistry','测定化学反应速率','medium',60),
('DNA提取实验','biology','从草莓提取DNA','easy',30),
('线性回归算法实现','cs','实现线性回归模型','medium',45),
('神经网络前向传播','cs','实现神经网络前向传播','hard',60);

-- 46. 学习小组
INSERT IGNORE INTO study_group (name, icon, description, creator_id, member_count) VALUES
('AI学习小组','🤖','探讨人工智能前沿技术与实践','u001',12),
('前端开发小组','💻','前端技术分享与项目协作','u002',24),
('设计思维小组','🎨','设计方法论与创意实践','u004',8);

-- 47. 小组成员
INSERT IGNORE INTO study_group_member (group_id, user_id) VALUES
(1,'u001'),(1,'u005'),(1,'u007'),
(2,'u002'),(2,'u004'),(2,'u001'),(2,'u006'),
(3,'u004'),(3,'u003'),(3,'u005');

-- 48. 学习会话记录
INSERT IGNORE INTO study_session (user_id, start_time, end_time, duration, focus_score, task_description) VALUES
('u001',DATE_SUB(NOW(),INTERVAL 3 HOUR),DATE_SUB(NOW(),INTERVAL 1 HOUR),120,85,'深度学习课程-卷积神经网络'),
('u001',DATE_SUB(NOW(),INTERVAL 1 DAY),DATE_SUB(NOW(),INTERVAL 22 HOUR),120,90,'Python数据分析-Pandas操作'),
('u002',DATE_SUB(NOW(),INTERVAL 5 HOUR),DATE_SUB(NOW(),INTERVAL 3 HOUR),120,88,'React组件开发实战'),
('u003',DATE_SUB(NOW(),INTERVAL 4 HOUR),DATE_SUB(NOW(),INTERVAL 2 HOUR),120,82,'设计模式-观察者模式'),
('u004',DATE_SUB(NOW(),INTERVAL 2 HOUR),NOW(),90,92,'UI界面设计-Figma原型'),
('u005',DATE_SUB(NOW(),INTERVAL 6 HOUR),DATE_SUB(NOW(),INTERVAL 4 HOUR),120,70,'机器学习基础课程');

-- =============================================================================
-- 十六、补充缺失表（12张）—— 代码引用但原SQL中缺失的表
-- =============================================================================

-- 52. 图书章节内容表
-- 用途：存储图书的章节拆分内容，支持在线阅读
-- 引用文件：BookActionServlet.java, BooksServlet.java
CREATE TABLE IF NOT EXISTS book_content (
    id INT AUTO_INCREMENT PRIMARY KEY COMMENT '章节主键',
    book_id INT NOT NULL COMMENT '所属图书ID（关联 book.id）',
    chapter_num INT NOT NULL COMMENT '章节序号',
    chapter_title VARCHAR(200) NOT NULL COMMENT '章节标题',
    content TEXT NOT NULL COMMENT '章节正文内容',
    word_count INT DEFAULT 0 COMMENT '章节字数',
    sort_order INT DEFAULT 0 COMMENT '排序序号',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    UNIQUE KEY uk_book_chapter (book_id, chapter_num),
    INDEX idx_book_id (book_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='图书章节内容表';

-- 53. 用户知识技能表
-- 用途：存储用户的知识技能雷达图数据
-- 引用文件：RecommendDao.java, RecommendEngine.java
CREATE TABLE IF NOT EXISTS knowledge_skills (
    id INT AUTO_INCREMENT PRIMARY KEY COMMENT '技能主键',
    user_id VARCHAR(64) NOT NULL COMMENT '用户ID（关联 users.id）',
    skill_name VARCHAR(100) NOT NULL COMMENT '技能名称（如：Java、Python、设计）',
    skill_value INT DEFAULT 0 COMMENT '技能值（0-100）',
    skill_color VARCHAR(20) DEFAULT '#4fc3f7' COMMENT '技能展示颜色（十六进制）',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户知识技能表';

-- 54. 用户学习路径表
-- 用途：存储用户的学习路径步骤
-- 引用文件：RecommendDao.java, RecommendEngine.java
CREATE TABLE IF NOT EXISTS learning_paths (
    id INT AUTO_INCREMENT PRIMARY KEY COMMENT '路径主键',
    user_id VARCHAR(64) NOT NULL COMMENT '用户ID（关联 users.id）',
    step_number INT NOT NULL COMMENT '步骤序号',
    step_title VARCHAR(200) NOT NULL COMMENT '步骤标题',
    step_description TEXT COMMENT '步骤描述',
    is_completed TINYINT(1) DEFAULT 0 COMMENT '是否完成（0=未完成，1=已完成）',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户学习路径表';

-- 55. 用户学习汇总结表
-- 用途：汇总用户的学习数据，用于推荐引擎
-- 引用文件：RecommendDao.java, RecommendEngine.java, StudySummary.java
CREATE TABLE IF NOT EXISTS user_study_summary (
    id INT AUTO_INCREMENT PRIMARY KEY COMMENT '汇总主键',
    user_id VARCHAR(64) NOT NULL UNIQUE COMMENT '用户ID（关联 users.id）',
    total_courses INT DEFAULT 0 COMMENT '完成课程总数',
    total_study_hours DECIMAL(10,2) DEFAULT 0.00 COMMENT '累计学习时长（小时）',
    campus_points INT DEFAULT 0 COMMENT '校园积分',
    week_progress INT DEFAULT 0 COMMENT '本周学习进度（0-100）',
    streak_days INT DEFAULT 0 COMMENT '连续学习天数',
    last_study_date DATE COMMENT '最后学习日期',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户学习汇总结表';

-- 56. 推荐内容表
-- 用途：存储系统推荐的内容卡片
-- 引用文件：RecommendDao.java, RecommendItem.java
CREATE TABLE IF NOT EXISTS recommendations (
    id INT AUTO_INCREMENT PRIMARY KEY COMMENT '推荐主键',
    title VARCHAR(200) NOT NULL COMMENT '推荐标题',
    category VARCHAR(50) COMMENT '分类标签',
    description TEXT COMMENT '推荐描述',
    type VARCHAR(50) COMMENT '推荐类型（course/book/activity等）',
    badge VARCHAR(50) COMMENT '徽章文本（如：HOT、NEW）',
    author VARCHAR(100) COMMENT '作者/讲师',
    meta_info VARCHAR(500) COMMENT '元信息（如：时长、难度）',
    rating DECIMAL(3,1) DEFAULT 0.0 COMMENT '评分（0.0-5.0）',
    action_text VARCHAR(50) DEFAULT '查看详情' COMMENT '操作按钮文本',
    sort_order INT DEFAULT 0 COMMENT '排序序号',
    is_active TINYINT(1) DEFAULT 1 COMMENT '是否启用（0=禁用，1=启用）',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='推荐内容表';

-- 57. 用户课程记录表
-- 用途：记录用户课程学习状态
-- 引用文件：AchievementDao.java, RecommendEngine.java
CREATE TABLE IF NOT EXISTS user_course_record (
    id INT AUTO_INCREMENT PRIMARY KEY COMMENT '记录主键',
    user_id VARCHAR(64) NOT NULL COMMENT '用户ID（关联 users.id）',
    course_id INT NOT NULL COMMENT '课程ID（关联 course.id）',
    status VARCHAR(20) DEFAULT 'in_progress' COMMENT '学习状态（in_progress/completed）',
    progress INT DEFAULT 0 COMMENT '学习进度（0-100）',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY uk_user_course (user_id, course_id),
    INDEX idx_user_id (user_id),
    INDEX idx_course_id (course_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户课程记录表';

-- 58. 用户评价表
-- 用途：存储用户对校园场景/课程的评分和评价
-- 引用文件：Campus3dPageServlet.java
CREATE TABLE IF NOT EXISTS user_evaluations (
    id INT AUTO_INCREMENT PRIMARY KEY COMMENT '评价主键',
    user_id VARCHAR(64) NOT NULL COMMENT '用户ID（关联 users.id）',
    target_type VARCHAR(50) NOT NULL COMMENT '评价目标类型（campus3d/course/book等）',
    target_id INT COMMENT '目标ID',
    rating INT NOT NULL COMMENT '评分（1-5）',
    comment TEXT COMMENT '评价内容',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_target (target_type, target_id),
    INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户评价表';

-- 59. 图书阅读记录表
-- 用途：记录用户图书阅读进度
-- 引用文件：BookActionServlet.java
CREATE TABLE IF NOT EXISTS book_read_record (
    id INT AUTO_INCREMENT PRIMARY KEY COMMENT '记录主键',
    user_id VARCHAR(64) NOT NULL COMMENT '用户ID（关联 users.id）',
    book_id INT NOT NULL COMMENT '图书ID（关联 book.id）',
    current_page INT DEFAULT 1 COMMENT '当前阅读页码',
    reading_progress INT DEFAULT 0 COMMENT '阅读进度（0-100）',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY uk_user_book (user_id, book_id),
    INDEX idx_user_id (user_id),
    INDEX idx_book_id (book_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='图书阅读记录表';

-- 60. 自习室统计表
-- 用途：存储自习室每日统计数据
-- 引用文件：StatsDao.java
CREATE TABLE IF NOT EXISTS studyroom_stats (
    id INT AUTO_INCREMENT PRIMARY KEY COMMENT '统计主键',
    online_users INT DEFAULT 0 COMMENT '在线用户数',
    active_tasks INT DEFAULT 0 COMMENT '活跃任务数',
    completed_today INT DEFAULT 0 COMMENT '今日完成任务数',
    stat_date DATE NOT NULL COMMENT '统计日期',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    UNIQUE KEY uk_stat_date (stat_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='自习室统计表';

-- 61. 校园3D统计表
-- 用途：存储校园3D场景每日统计数据
-- 引用文件：StatsDao.java, Campus3dPageServlet.java
CREATE TABLE IF NOT EXISTS campus3d_stats (
    id INT AUTO_INCREMENT PRIMARY KEY COMMENT '统计主键',
    online_users INT DEFAULT 0 COMMENT '在线用户数',
    scene_count INT DEFAULT 0 COMMENT '场景总数',
    satisfaction_rate INT DEFAULT 0 COMMENT '满意度（百分比）',
    is_24h_open TINYINT(1) DEFAULT 0 COMMENT '是否24小时开放',
    stat_date DATE NOT NULL COMMENT '统计日期',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    UNIQUE KEY uk_stat_date (stat_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='校园3D统计表';

-- 62. 管理驾驶舱统计表
-- 用途：存储管理驾驶舱每日聚合数据
-- 引用文件：StatsDao.java, StatsServlet.java
CREATE TABLE IF NOT EXISTS dashboard_stats (
    id INT AUTO_INCREMENT PRIMARY KEY COMMENT '统计主键',
    active_users INT DEFAULT 0 COMMENT '活跃用户数',
    today_visits INT DEFAULT 0 COMMENT '今日访问量',
    course_completion_rate INT DEFAULT 0 COMMENT '课程完成率（百分比）',
    system_health DECIMAL(5,2) DEFAULT 100.00 COMMENT '系统健康度（0-100）',
    new_users_today INT DEFAULT 0 COMMENT '今日新增用户',
    stat_date DATE NOT NULL COMMENT '统计日期',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    UNIQUE KEY uk_stat_date (stat_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='管理驾驶舱统计表';

-- =============================================================================
-- 十六、补充缺失表的种子数据
-- =============================================================================

-- 52. book_content 种子数据（示例：《Java编程思想》章节）
INSERT IGNORE INTO book_content (book_id, chapter_num, chapter_title, content, word_count, sort_order) VALUES
(1, 1, '第一章 对象导论', '面向对象编程是一种编程范式，它使用"对象"来设计软件。对象是类的实例...', 1250, 1),
(1, 2, '第二章 一切都是对象', '在Java中，一切都是对象。尽管Java是基于C++的，但相比之下，Java是一种更"纯粹"的面向对象语言...', 1580, 2),
(1, 3, '第三章 操作符', 'Java中的操作符与C和C++中的操作符类似。所有操作符都能根据自己的使用方式，与不同类型的操作数一起工作...', 1320, 3);

-- 53. knowledge_skills 种子数据
INSERT IGNORE INTO knowledge_skills (user_id, skill_name, skill_value, skill_color) VALUES
('u001', 'Java', 85, '#4fc3f7'),
('u001', 'Python', 72, '#26c6da'),
('u001', '数据结构', 90, '#66bb6a'),
('u001', '算法', 78, '#ffa726'),
('u002', 'JavaScript', 88, '#ab47bc'),
('u002', 'React', 82, '#42a5f5'),
('u002', 'CSS', 75, '#ec407a');

-- 54. learning_paths 种子数据
INSERT IGNORE INTO learning_paths (user_id, step_number, step_title, step_description, is_completed) VALUES
('u001', 1, 'Java基础语法', '掌握Java基本语法、数据类型、流程控制', 1),
('u001', 2, '面向对象编程', '理解封装、继承、多态', 1),
('u001', 3, '集合框架', '学习List、Set、Map等集合的使用', 0),
('u001', 4, '多线程编程', '掌握线程创建、同步、通信', 0),
('u002', 1, 'HTML/CSS基础', '掌握网页结构和样式基础', 1),
('u002', 2, 'JavaScript入门', '学习JS基本语法和DOM操作', 1),
('u002', 3, 'React框架', '学习React组件化和Hooks', 0);

-- 55. user_study_summary 种子数据
INSERT IGNORE INTO user_study_summary (user_id, total_courses, total_study_hours, campus_points, week_progress, streak_days, last_study_date) VALUES
('u001', 8, 126.50, 320, 75, 12, CURDATE()),
('u002', 5, 89.00, 210, 60, 8, CURDATE()),
('u003', 3, 45.50, 120, 40, 5, CURDATE()),
('u004', 6, 98.00, 280, 85, 15, CURDATE()),
('u005', 4, 67.50, 180, 55, 10, CURDATE());

-- 56. recommendations 种子数据
INSERT IGNORE INTO recommendations (title, category, description, type, badge, author, meta_info, rating, action_text, sort_order, is_active) VALUES
('Python数据分析实战', 'course', '从零开始学习Python数据分析，掌握NumPy、Pandas等核心库', 'course', 'HOT', '张老师', '12课时 | 中级', 4.8, '立即学习', 1, 1),
('深入理解计算机系统', 'book', 'CS经典教材，深入理解计算机底层工作原理', 'book', '经典', '布莱恩·科尼根', '752页 | 计算机', 4.9, '立即阅读', 2, 1),
('AI学习小组招募', 'activity', '加入AI学习小组，与志同道合的同学一起探讨人工智能前沿技术', 'activity', 'NEW', 'AI学社', '线上 | 每周三', 0, '立即加入', 3, 1),
('Web前端开发实战', 'course', '系统学习HTML、CSS、JavaScript，掌握现代前端开发技能', 'course', '', '李老师', '16课时 | 初级', 4.6, '立即学习', 4, 1);

-- 57. user_course_record 种子数据
INSERT IGNORE INTO user_course_record (user_id, course_id, status, progress) VALUES
('u001', 1, 'completed', 100),
('u001', 2, 'in_progress', 65),
('u002', 3, 'completed', 100),
('u002', 4, 'in_progress', 40),
('u003', 1, 'in_progress', 30);

-- 58. user_evaluations 种子数据
INSERT IGNORE INTO user_evaluations (user_id, target_type, target_id, rating, comment) VALUES
('u001', 'campus3d', 1, 5, '3D校园很棒，体验非常真实！'),
('u002', 'campus3d', 1, 4, '场景很精美，希望能增加更多互动功能。'),
('u003', 'course', 1, 5, '课程内容非常实用，老师讲得很清楚。'),
('u004', 'book', 1, 4, '书籍内容详实，适合深入学习。');

-- 59. book_read_record 种子数据
INSERT IGNORE INTO book_read_record (user_id, book_id, current_page, reading_progress) VALUES
('u001', 1, 120, 30),
('u001', 2, 45, 15),
('u002', 1, 300, 75),
('u003', 3, 80, 20);

-- 60. studyroom_stats 种子数据
INSERT IGNORE INTO studyroom_stats (online_users, active_tasks, completed_today, stat_date) VALUES
(12, 8, 5, CURDATE() - INTERVAL 7 DAY),
(15, 10, 7, CURDATE() - INTERVAL 6 DAY),
(18, 12, 9, CURDATE() - INTERVAL 5 DAY),
(20, 14, 11, CURDATE() - INTERVAL 4 DAY),
(22, 15, 12, CURDATE() - INTERVAL 3 DAY),
(25, 18, 14, CURDATE() - INTERVAL 2 DAY),
(28, 20, 16, CURDATE() - INTERVAL 1 DAY),
(30, 22, 18, CURDATE());

-- 61. campus3d_stats 种子数据
INSERT IGNORE INTO campus3d_stats (online_users, scene_count, satisfaction_rate, is_24h_open, stat_date) VALUES
(8, 5, 85, 0, CURDATE() - INTERVAL 7 DAY),
(10, 5, 87, 0, CURDATE() - INTERVAL 6 DAY),
(12, 5, 88, 0, CURDATE() - INTERVAL 5 DAY),
(15, 5, 90, 1, CURDATE() - INTERVAL 4 DAY),
(18, 6, 91, 1, CURDATE() - INTERVAL 3 DAY),
(20, 6, 92, 1, CURDATE() - INTERVAL 2 DAY),
(22, 6, 93, 1, CURDATE() - INTERVAL 1 DAY),
(25, 6, 95, 1, CURDATE());

-- 62. dashboard_stats 种子数据
INSERT IGNORE INTO dashboard_stats (active_users, today_visits, course_completion_rate, system_health, new_users_today, stat_date) VALUES
(45, 120, 68, 98.50, 3, CURDATE() - INTERVAL 7 DAY),
(48, 135, 70, 98.80, 5, CURDATE() - INTERVAL 6 DAY),
(52, 142, 72, 99.10, 4, CURDATE() - INTERVAL 5 DAY),
(55, 158, 73, 99.20, 6, CURDATE() - INTERVAL 4 DAY),
(58, 165, 75, 99.50, 7, CURDATE() - INTERVAL 3 DAY),
(62, 180, 76, 99.60, 5, CURDATE() - INTERVAL 2 DAY),
(65, 195, 78, 99.80, 8, CURDATE() - INTERVAL 1 DAY),
(68, 210, 80, 99.90, 6, CURDATE());

-- =============================================================================
SET FOREIGN_KEY_CHECKS = 1;

SELECT '========================================' AS '';
SELECT '博雅书院数据库初始化完成！' AS result;
SELECT '共创建 62 张表，含完整测试数据' AS detail;
SELECT '========================================' AS '';
