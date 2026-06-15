

**博雅书院（Boya Academy）** 
是一个面向高校的**综合性智慧校园平台**，集数字图书馆、在线课程、AI推荐、自习管理、元宇宙校园、学术讲座、校友网络等功能于一体。

| 维度 | 详情 |
|------|------|
| **技术栈** | JSP + Servlet + DAO + MySQL 8.0 + HikariCP + Java 21 |
| **架构** | 纯原生 MVC 三层架构（无 Spring） |
| **规模** | ~123个 Java 源文件、39个 JSP 页面、24个 CSS、64张数据库表 |
| **部署** | WAR 包部署，Tomcat 7 Maven Plugin，端口 **8081** |
| **数据库** | MySQL 8.0，数据库名 `javaweb`，用户 `root/123456` |

### 核心特色

- **8套主题系统**（4暗+4亮），3D环形主题选择器
- **全格式电子书阅读器**（TXT/EPUB/PDF/DOCX/Markdown）
- **AI推荐引擎** + 多模型AI对话（DeepSeek/Qwen/Kimi）
- **元宇宙校园**（4个虚拟3D场景）
- **iframe单页架构** + postMessage跨框架通信
- **BCrypt密码加密** + CSRF防护 + XSS双重转义

---

## 🚀 使用方法

### 第一步：环境准备

你需要安装以下软件：

| 软件 | 版本要求 | 用途 |
|------|----------|------|
| **JDK** | 21+ | Java编译运行 |
| **MySQL** | 8.0+ | 数据库 |
| **Maven** | 3.6+ | 项目构建 |
| **Git** | 任意版本 | 克隆代码（可选） |

> 项目使用 Maven 内嵌 Tomcat 7 插件，无需单独安装 Tomcat。

### 第二步：创建数据库

打开 MySQL 客户端，执行以下操作：

```sql
-- 1. 创建数据库
CREATE DATABASE IF NOT EXISTS javaweb DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 2. 导入建表脚本和种子数据
-- 在命令行中执行（替换为你的实际路径）：
-- mysql -u root -p123456 javaweb < D:\Daima_A\JavaWeb\srp24301\mysql\boya_database.sql
```

或者在 MySQL 客户端中：

```sql
USE javaweb;
SOURCE D:/Daima_A/JavaWeb/srp24301/mysql/boya_database.sql;
```

### 第三步：配置数据库连接

配置文件位置：`Mysql_1\src\main\resources\jdbc.properties`

```
jdbc.url=jdbc:mysql://localhost:3306/javaweb?useSSL=false&...
jdbc.username=root
jdbc.password=123456       # ← 改成你的MySQL密码
```

> 如果你的 MySQL 用户名/密码不是 root/123456，修改这里即可。

### 第四步：编译并启动项目

```bash
# 进入项目目录
cd D:\Daima_A\JavaWeb\srp24301\Mysql_1

# 编译并启动（使用 Maven Tomcat 插件）
mvn clean tomcat7:run
```

启动成功后，控制台会显示：
```
[DBManager] HikariCP 连接池初始化成功
```

### 第五步：访问系统

打开浏览器，访问：**http://localhost:8081**

- 首先进入 `index.jsp` 主框架页
- 新用户需要先**注册账号**，已有账号直接**登录**

---

## 📖 功能模块详解

启动后你会看到一个**左侧侧边栏 + 右侧iframe**的主界面。下面按侧边栏菜单顺序介绍：

### 🏠 智识首页 (`/home`)
仪表盘风格首页，展示：
- 统计数据卡片（图书总数、课程数、用户数等）
- 最新新闻公告
- 个性化推荐内容

### 📚 资源中心 (`/resourcePage`)
数字图书馆核心功能：
- **图书网格展示**：封面卡片 + 分类筛选
- **搜索功能**：按书名/作者搜索
- **电子书阅读**：点击图书进入阅读器，支持 TXT/EPUB/PDF/DOCX/MD 五种格式
- **评分与评论**：给图书打分、写书评
- **收藏功能**：收藏喜欢的图书

### 🎓 学域矩阵 (`/majorsPage`)
- 专业分类浏览
- 专业-图书交叉矩阵
- 点击专业查看相关图书

### 🎯 为你推荐 (`/recommend`)
AI 推荐引擎结果：
- 基于用户画像的个性化推荐
- 学习路径规划
- 知识技能树展示

### 📝 笔记中心 (`/notesPage`)
个人笔记管理：
- Markdown 格式笔记编辑器
- 笔记卡片网格展示
- 置顶 + 搜索功能
- 公开/私密设置

### 🌱 成长中心 (`/growthPage`)
学习成长追踪：
- 成就徽章系统（打卡天数、阅读量等）
- 学习统计数据可视化
- 活动时间线

### ✅ 任务中心 (`/taskPage`)
学习任务管理：
- 任务创建/编辑/删除
- 完成状态切换
- 筛选标签（全部/进行中/已完成）
- 番茄钟计时器集成

### 🏫 讲座中心 (`/lecturePage`)
学术讲座信息：
- 讲座列表（在线/线下标签）
- 讲座报名
- 时间地点详情

### 👥 校友网络 (`/alumniPage`)
校友信息展示：
- 校友列表 + 企业信息
- 行业分布

### 👨‍🏫 师资力量 (`/facultyPage`)
导师信息展示：
- 导师列表 + 研究方向
- 学术成果

### 🎨 文化中心 (`/culturePage`)
校园文化活动：
- 文化活动列表
- 艺术作品展示
- 社团信息

### 📜 校园历史 (`/history`)
- 发展里程碑时间线
- 历史事件图文

### 🌐 元宇宙校园 (`/campus3d`)
虚拟校园体验：
- 4个虚拟场景（图书馆、实验室等）
- 场景切换
- 在线人数统计

### 🔔 通知中心 (`/notifications`)
消息通知系统：
- 私信聊天（实时消息）
- 系统通知
- 定时通知管理

---

## 🔧 管理后台

管理员账号登录后可访问以下管理页面：

| 模块 | 路径 | 功能 |
|------|------|------|
| **管理驾驶舱** | `/adminDashboard` | ECharts 数据图表（用户增长/活跃/内容统计/JVM监控） |
| **内容审核** | `/contentReview` | AI辅助内容审核（通过/拒绝） |
| **通知推送** | `/adminPush` | 批量推送管理 |
| **用户管理** | `/usersList` | 用户列表管理 |
| **图书管理** | `/booksList` | 图书增删改查 |
| **分类管理** | `/bookTypeList` | 图书分类管理 |
| **系统日志** | `/adminLogs` | 操作日志查看 |
| **数据报表** | `/adminReport` | 报表导出 |
| **用户分析** | `/adminUserAnalysis` | 用户行为分析 |
| **安全设置** | `/adminSecurity` | 安全策略配置 |
| **数据备份** | `/adminBackup` | 数据库备份 |

---

## 🎨 主题切换

项目内置 **8套主题**，点击左侧栏底部的 🎨 主题按钮：

| 主题名 | 风格 |
|--------|------|
| **量子矩阵** (quantum-matrix) | 深灰蓝科技风 |
| **星云之梦** (nebula-dream) | 暗红棕暖色调 |
| **赛博霓虹** (cyber-neon) | 橙红霓虹风 |
| **数据流** (data-stream) | 深炭灰极简风 |
| **Apple Light** | 苹果浅灰 |
| **Notion Light** | 暖黄经典 |
| **微信读书** (weread-light) | 橄榄绿护眼 |
| **校园 Light** (campus-light) | 奶油白柔和 |

---

## 🤖 AI 功能

### AI 聊天助手
- 点击右下角浮动按钮打开 AI 对话框
- 支持多模型切换（DeepSeek/Qwen/Kimi）
- 需在 `ai.properties` 中配置 API Key

### AI 推荐引擎
- 自动构建用户画像
- 协同过滤 + 内容匹配推荐
- 热门内容降级兜底

---

## ⚠️ 常见问题

| 问题 | 解决方法 |
|------|----------|
| **端口 8081 被占用** | 修改 `pom.xml` 中 `<port>8081</port>` 为其他端口 |
| **数据库连接失败** | 检查 MySQL 是否启动，密码是否正确 |
| **表不存在错误** | 确认已执行 `boya_database.sql` 建表脚本 |
| **JDK 版本不对** | 项目要求 Java 21，检查 `java -version` |
| **Maven 编译报错** | 运行 `mvn clean compile` 查看具体错误 |
| **邮件功能不可用** | 需在 `mail.properties` 中配置 QQ邮箱授权码 |
| **AI 功能不可用** | 需在 `ai.properties` 中配置 API Key |

---

### 快速启动命令汇总

```bash
# 1. 初始化数据库（仅首次）
mysql -u root -p123456 < D:\Daima_A\JavaWeb\srp24301\mysql\boya_database.sql

# 2. 启动项目
cd D:\Daima_A\JavaWeb\srp24301\Mysql_1
mvn clean tomcat7:run

# 3. 浏览器访问
# http://localhost:8081
```
