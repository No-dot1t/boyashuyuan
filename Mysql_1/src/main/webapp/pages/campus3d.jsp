<%--
 =============================================================================
 campus3d.jsp
 =============================================================================

 用途      功能页面

 ── 使用的关键 API / 技术 ────────────────────────────────────────────────────

   Three.js - WebGL 3D渲染引擎
   Ajax 异步请求 —— fetch
   DOM 事件处理
   OrbitControls - 轨道控制

 =============================================================================
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ebookBuy301.pojo.CampusScene, java.util.ArrayList, java.util.Map" %>
<%
    ArrayList<CampusScene> scenes = (ArrayList<CampusScene>) request.getAttribute("scenes");
    if (scenes == null) scenes = new ArrayList<>();
    Map<String, Object> campusStats = (Map<String, Object>) request.getAttribute("campusStats");
    if (campusStats == null) campusStats = new java.util.HashMap<>();
    int onlineUsers = campusStats.get("onlineUsers") != null ? ((Number)campusStats.get("onlineUsers")).intValue() : 0;
    int sceneCount = campusStats.get("sceneCount") != null ? ((Number)campusStats.get("sceneCount")).intValue() : scenes.size();
    int satisfactionRate = campusStats.get("satisfactionRate") != null ? ((Number)campusStats.get("satisfactionRate")).intValue() : 95;
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<script>!function(){var t=localStorage.getItem('boya-theme');if(t)document.documentElement.setAttribute('data-theme',t);else try{var p=window.parent;if(p&&p!==window){var e=p.document.documentElement.getAttribute('data-theme');if(e)document.documentElement.setAttribute('data-theme',e)}}catch(t){}}();</script>

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes">
    <title>博雅书院 · 科技风 | 元宇宙校园</title>
    <link rel="stylesheet" href="<%= ctx %>/CSS/index.css">
    <script>window.CONTEXT_PATH = '<%= ctx %>';</script>
    <style>
        *{margin:0;padding:0;box-sizing:border-box}
        body{background:#0a0b1a;color:#fff;font-family:'Segoe UI','PingFang SC','Microsoft YaHei',sans-serif;min-height:100vh;overflow-x:hidden}
        @keyframes fadeInUp{from{opacity:0;transform:translateY(30px)}to{opacity:1;transform:translateY(0)}}
        @keyframes shimmer{0%,100%{background-position:-200% 0}50%{background-position:200% 0}}
        @keyframes pulse{0%,100%{opacity:1}50%{opacity:0.6}}
        
        .campus-container{padding:20px}
        .campus-header{text-align:center;margin-bottom:30px;animation:fadeInUp .6s ease-out}
        .campus-header h1{font-size:2.5rem;margin-bottom:10px;background:linear-gradient(135deg,#fff 0%,#00f2ff 50%,#a855f7 100%);background-size:300% auto;-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;animation:shimmer 4s linear infinite}
        .header-subtitle{color:rgba(255,255,255,0.5);font-size:1.1rem}
        
        .campus-stats{display:flex;justify-content:center;gap:30px;margin-top:25px;flex-wrap:wrap}
        .campus-stat{background:rgba(255,255,255,0.03);border:1px solid rgba(255,255,255,0.06);border-radius:14px;padding:20px 35px;min-width:120px;text-align:center;transition:all .3s}
        .campus-stat:hover{transform:translateY(-4px);border-color:rgba(0,242,255,0.2)}
        .stat-value{font-size:1.8rem;font-weight:700;color:#00f2ff}
        .stat-label{font-size:.85rem;color:rgba(255,255,255,0.5);margin-top:5px}

        .campus-main{max-width:1400px;margin:0 auto}
        .scene-container{background:rgba(255,255,255,0.02);border:1px solid rgba(255,255,255,0.06);border-radius:20px;overflow:hidden;margin-bottom:30px}
        .scene-header{display:flex;justify-content:space-between;align-items:center;padding:20px 25px;border-bottom:1px solid rgba(255,255,255,0.05)}
        .scene-header h2{font-size:1.3rem;color:#fff}
        .scene-controls{display:flex;gap:8px;flex-wrap:wrap}
        .scene-btn{padding:10px 20px;background:rgba(255,255,255,0.04);border:1px solid rgba(255,255,255,0.08);border-radius:10px;color:rgba(255,255,255,0.7);cursor:pointer;font-size:.9rem;transition:all .3s}
        .scene-btn:hover{background:rgba(0,242,255,0.1);border-color:rgba(0,242,255,0.3);color:#fff}
        .scene-btn.active{background:rgba(0,242,255,0.15);border-color:#00f2ff;color:#00f2ff}

        .scene-view{display:flex;height:500px}
        .scene-canvas{flex:1;background:linear-gradient(180deg,#0a0b1a 0%,#0d1321 100%);position:relative}
        #canvas3d{width:100%;height:100%;display:block}
        .canvas-overlay{position:absolute;bottom:20px;left:20px;background:rgba(0,0,0,0.7);backdrop-filter:blur(10px);border-radius:12px;padding:15px;color:rgba(255,255,255,0.6);font-size:.85rem}
        .canvas-overlay h4{color:#00f2ff;margin-bottom:8px;font-size:.95rem}
        .canvas-controls{display:flex;gap:8px;margin-top:10px}
        .control-btn{width:36px;height:36px;border:none;border-radius:8px;background:rgba(255,255,255,0.1);color:#fff;cursor:pointer;transition:all .3s}
        .control-btn:hover{background:rgba(0,242,255,0.2);color:#00f2ff}

        .scene-info{width:320px;padding:25px;background:rgba(255,255,255,0.03);border-left:1px solid rgba(255,255,255,0.05);display:flex;flex-direction:column}
        .scene-info h3{font-size:1.1rem;margin-bottom:15px;color:#fff}
        .scene-features{list-style:none;padding:0;margin-bottom:25px}
        .scene-features li{color:rgba(255,255,255,0.6);line-height:2;margin-bottom:8px;font-size:.9rem}
        .enter-scene-btn{margin-top:auto;padding:14px;border:none;border-radius:12px;background:linear-gradient(135deg,#00d4e0,#00a8b5);color:#0a0b1a;font-weight:600;font-size:1rem;cursor:pointer;transition:all .3s}
        .enter-scene-btn:hover{transform:translateY(-2px);box-shadow:0 8px 25px rgba(0,212,224,0.35)}

        .features-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(280px,1fr));gap:20px;margin-bottom:30px}
        .feature-card{background:rgba(255,255,255,0.02);border:1px solid rgba(255,255,255,0.06);border-radius:18px;padding:25px;transition:all .4s}
        .feature-card:hover{transform:translateY(-6px);border-color:rgba(0,242,255,0.2);box-shadow:0 12px 35px rgba(0,0,0,0.3)}
        .feature-card .feature-icon{font-size:2.5rem;margin-bottom:15px}
        .feature-card h3{font-size:1.15rem;margin-bottom:10px;color:#fff}
        .feature-card p{color:rgba(255,255,255,0.5);font-size:.9rem;line-height:1.6;margin-bottom:18px}
        .feature-action{padding:10px 20px;border:none;border-radius:10px;background:rgba(0,242,255,0.1);color:#00f2ff;cursor:pointer;font-size:.9rem;transition:all .3s}
        .feature-action:hover{background:rgba(0,242,255,0.2);transform:translateX(4px)}

        .social-section{background:rgba(255,255,255,0.02);border:1px solid rgba(255,255,255,0.06);border-radius:20px;padding:30px}
        .social-section h2{font-size:1.5rem;margin-bottom:25px;color:#fff}
        .social-features{display:grid;grid-template-columns:repeat(auto-fill,minmax(220px,1fr));gap:20px}
        .social-card{background:rgba(255,255,255,0.03);border-radius:14px;padding:20px;text-align:center;transition:all .3s}
        .social-card:hover{transform:scale(1.02)}
        .social-icon{font-size:2.2rem;margin-bottom:10px}
        .social-card h4{font-size:1rem;color:#fff;margin-bottom:8px}
        .social-card p{color:rgba(255,255,255,0.5);font-size:.85rem}

        .loading-overlay{position:absolute;top:50%;left:50%;transform:translate(-50%,-50%);text-align:center}
        .loading-ring{width:60px;height:60px;border:3px solid rgba(0,242,255,0.1);border-top-color:#00f2ff;border-radius:50%;animation:spin 1s linear infinite;margin:0 auto 15px}
        @keyframes spin{to{transform:rotate(360deg)}}
        .loading-text{color:rgba(255,255,255,0.5)}
        
        .info-panel{position:absolute;top:20px;right:20px;background:rgba(0,0,0,0.7);backdrop-filter:blur(10px);border-radius:12px;padding:15px;color:#fff;font-size:.85rem}
        .info-panel .label{color:rgba(255,255,255,0.5)}
        .info-panel .value{color:#00f2ff;font-weight:600}
    </style>
    <!-- ========== 浅色主题全局兜底覆盖 ========== -->
    <style>
        html[data-theme$="-light"],html[data-theme$="-light"] body{background:#e8dfcf!important;color:#3d3929!important}
        html[data-theme$="-light"] [class*="card"],html[data-theme$="-light"] [class*="box"],html[data-theme$="-light"] [class*="module"]{background:rgba(238,233,222,.92)!important;border-color:rgba(139,119,80,.07)!important}
        html[data-theme$="-light"] h1,html[data-theme$="-light"] h2,html[data-theme$="-light"] h3,html[data-theme$="-light"] [class*="title"]{color:#3d3929!important}
        html[data-theme$="-light"] p,html[data-theme$="-light"] li,html[data-theme$="-light"] [class*="desc"],html[data-theme$="-light"] [class*="muted"]{color:#7a7360!important}
        html[data-theme$="-light"] a{color:#0071e3!important}
        html[data-theme$="-light"] input,html[data-theme$="-light"] textarea,html[data-theme$="-light"] select{background:rgba(238,233,222,.94)!important;border-color:rgba(139,119,80,.12)!important;color:#3d3929!important}
        html[data-theme$="-light"] [class*="header"],html[data-theme$="-light"] [class*="navbar"]{background:rgba(238,233,222,.94)!important;border-color:rgba(139,119,80,.07)!important}
        html[data-theme$="-light"] [class*="item"]{background:rgba(238,233,222,.72)!important}
        html[data-theme$="-light"] [class*="particle"],html[data-theme$="-light"] [class*="star"]{opacity:.15!important}
        html[data-theme$="-light"] span,html[data-theme$="-light"] label,html[data-theme$="-light"] div{color:#3d3929!important}
        html[data-theme$="-light"] button:not([class*="primary"]){color:#3d3929!important}
        html[data-theme$="-light"] svg,html[data-theme$="-light"] [class*="icon"]{color:#5c5540!important;fill:#5c5540!important}
        html[data-theme$="-light"] input::placeholder,html[data-theme$="-light"] textarea::placeholder{color:#968e78!important}
        html[data-theme$="-light"] [class*="tag"],html[data-theme$="-light"] [class*="badge"]{color:#3d3929!important;background:rgba(139,119,80,.08)!important}
        html[data-theme$="-light"] [class*="toast"],[class*="notification"]{color:#3d3929!important;background:rgba(248,243,230,.96)!important}
        html[data-theme$="-light"] a{color:#2563eb!important}
    </style>

</head>
<body>
    <div class="campus-container">
        <div class="campus-header">
            <h1><span>🌐</span> 元宇宙校园</h1>
            <p class="header-subtitle">沉浸式虚拟学习空间，探索未来教育形态</p>

            <div class="campus-stats">
                <div class="campus-stat">
                    <div class="stat-value" id="onlineUsers"><%= onlineUsers %></div>
                    <div class="stat-label">在线用户</div>
                </div>
                <div class="campus-stat">
                    <div class="stat-value"><%= sceneCount %></div>
                    <div class="stat-label">虚拟场景</div>
                </div>
                <div class="campus-stat">
                    <div class="stat-value"><%= satisfactionRate %>%</div>
                    <div class="stat-label">体验满意度</div>
                </div>
                <div class="campus-stat">
                    <div class="stat-value">24/7</div>
                    <div class="stat-label">全天开放</div>
                </div>
            </div>
        </div>

        <div class="campus-main">
            <div class="scene-container">
                <div class="scene-header">
                    <h2>🖥️ 虚拟校园场景</h2>
                    <div class="scene-controls">
                        <% for (int i = 0; i < scenes.size(); i++) {
                            CampusScene sc = scenes.get(i); %>
                        <button class="scene-btn <%= i == 0 ? "active" : "" %>" data-scene="<%= sc.getSceneKey() %>" data-scene-id="<%= sc.getId() %>"><%= sc.getName() %></button>
                        <% } %>
                        <% if (scenes.isEmpty()) { %>
                        <button class="scene-btn active" data-scene="default" data-scene-id="1">图书馆</button>
                        <button class="scene-btn" data-scene="science" data-scene-id="2">科学楼</button>
                        <button class="scene-btn" data-scene="classroom" data-scene-id="3">教学楼</button>
                        <button class="scene-btn" data-scene="gym" data-scene-id="4">体育馆</button>
                        <% } %>
                    </div>
                </div>

                <div class="scene-view">
                    <div class="scene-canvas">
                        <canvas id="canvas3d"></canvas>
                        <div class="loading-overlay" id="loadingOverlay">
                            <div class="loading-ring"></div>
                            <div class="loading-text">加载3D场景中...</div>
                        </div>
                        <div class="canvas-overlay">
                            <h4>🎮 操作说明</h4>
                            <p>鼠标左键旋转 | 右键平移 | 滚轮缩放</p>
                            <div class="canvas-controls">
                                <button class="control-btn" title="重置视角" onclick="resetCamera()">🔄</button>
                                <button class="control-btn" title="自动旋转" onclick="toggleAutoRotate()">🔃</button>
                                <button class="control-btn" title="全屏" onclick="toggleFullscreen()">⛶</button>
                            </div>
                        </div>
                        <div class="info-panel" id="infoPanel">
                            <div><span class="label">场景:</span> <span class="value" id="currentScene">图书馆</span></div>
                            <div><span class="label">FPS:</span> <span class="value" id="fps">0</span></div>
                        </div>
                    </div>

                    <div class="scene-info">
                        <h3>场景功能说明</h3>
                        <ul class="scene-features">
                            <li>• 360°全景视角自由探索</li>
                            <li>• 实时语音/文字聊天系统</li>
                            <li>• 虚拟白板协作工具</li>
                            <li>• 个性化虚拟形象定制</li>
                            <li>• 跨平台设备支持</li>
                        </ul>
                        <button class="enter-scene-btn" id="enterSceneBtn">🚀 进入虚拟校园</button>
                    </div>
                </div>
            </div>

            <div class="features-grid">
                <div class="feature-card">
                    <div class="feature-icon">👨‍🎓</div>
                    <h3>虚拟形象</h3>
                    <p>创建个性化3D虚拟形象，支持多种装扮和动作</p>
                    <button class="feature-action" data-action="avatar">创建形象</button>
                </div>

                <div class="feature-card">
                    <div class="feature-icon">🏫</div>
                    <h3>虚拟教室</h3>
                    <p>参加实时互动课程，与讲师和同学面对面交流</p>
                    <button class="feature-action" data-action="classroom">查看课表</button>
                </div>

                <div class="feature-card">
                    <div class="feature-icon">🔬</div>
                    <h3>虚拟实验室</h3>
                    <p>进行安全、可重复的虚拟实验操作</p>
                    <button class="feature-action" data-action="lab">开始实验</button>
                </div>

                <div class="feature-card">
                    <div class="feature-icon">🎨</div>
                    <h3>创意工坊</h3>
                    <p>3D建模、动画创作和数字艺术展示</p>
                    <button class="feature-action" data-action="workshop">进入工坊</button>
                </div>
            </div>

            <div class="social-section">
                <h2>👥 社交互动</h2>
                <div class="social-features">
                    <div class="social-card">
                        <div class="social-icon">💬</div>
                        <h4>实时聊天</h4>
                        <p>语音、文字、表情等多种交流方式</p>
                    </div>

                    <div class="social-card">
                        <div class="social-icon">🎯</div>
                        <h4>小组协作</h4>
                        <p>虚拟空间中的团队项目和讨论</p>
                    </div>

                    <div class="social-card">
                        <div class="social-icon">🎪</div>
                        <h4>虚拟活动</h4>
                        <p>讲座、展览、音乐会等在线活动</p>
                    </div>

                    <div class="social-card">
                        <div class="social-icon">📱</div>
                        <h4>移动端支持</h4>
                        <p>随时随地访问元宇宙校园</p>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/three@0.160.0/build/three.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/three@0.160.0/examples/js/controls/OrbitControls.js"></script>
    
    <script>
    var scene, camera, renderer, controls;
    var buildings = [];
    var lights = [];
    var isAutoRotate = false;
    var fpsCount = 0, fpsTime = 0;

    function init3D() {
        var canvas = document.getElementById('canvas3d');
        var container = canvas.parentElement;
        
        scene = new THREE.Scene();
        scene.background = new THREE.Color(0x0a0b1a);
        
        camera = new THREE.PerspectiveCamera(60, container.clientWidth / container.clientHeight, 0.1, 1000);
        camera.position.set(15, 12, 15);
        
        renderer = new THREE.WebGLRenderer({canvas: canvas, antialias: true});
        renderer.setSize(container.clientWidth, container.clientHeight);
        renderer.setPixelRatio(window.devicePixelRatio);
        renderer.shadowMap.enabled = true;
        renderer.shadowMap.type = THREE.PCFSoftShadowMap;
        
        controls = new THREE.OrbitControls(camera, renderer.domElement);
        controls.enableDamping = true;
        controls.dampingFactor = 0.05;
        controls.minDistance = 5;
        controls.maxDistance = 50;
        controls.maxPolarAngle = Math.PI / 2.2;
        
        createLights();
        createGround();
        createCampus();
        
        document.getElementById('loadingOverlay').style.display = 'none';
        
        window.addEventListener('resize', onWindowResize);
        animate();
    }
    
    function createLights() {
        var ambientLight = new THREE.AmbientLight(0x404080, 0.5);
        scene.add(ambientLight);
        
        var mainLight = new THREE.DirectionalLight(0xffffff, 1);
        mainLight.position.set(10, 20, 10);
        mainLight.castShadow = true;
        mainLight.shadow.mapSize.width = 2048;
        mainLight.shadow.mapSize.height = 2048;
        mainLight.shadow.camera.near = 0.5;
        mainLight.shadow.camera.far = 50;
        mainLight.shadow.camera.left = -20;
        mainLight.shadow.camera.right = 20;
        mainLight.shadow.camera.top = 20;
        mainLight.shadow.camera.bottom = -20;
        scene.add(mainLight);
        lights.push(mainLight);
        
        var fillLight = new THREE.DirectionalLight(0x00f2ff, 0.3);
        fillLight.position.set(-10, 10, -10);
        scene.add(fillLight);
        lights.push(fillLight);
        
        var pointLight1 = new THREE.PointLight(0x00f2ff, 0.8, 30);
        pointLight1.position.set(-5, 8, -5);
        scene.add(pointLight1);
        lights.push(pointLight1);
        
        var pointLight2 = new THREE.PointLight(0xa855f7, 0.6, 25);
        pointLight2.position.set(5, 6, 5);
        scene.add(pointLight2);
        lights.push(pointLight2);
    }
    
    function createGround() {
        var groundGeometry = new THREE.PlaneGeometry(80, 80);
        var groundMaterial = new THREE.MeshStandardMaterial({
            color: 0x0a1628,
            roughness: 0.8,
            metalness: 0.2
        });
        var ground = new THREE.Mesh(groundGeometry, groundMaterial);
        ground.rotation.x = -Math.PI / 2;
        ground.receiveShadow = true;
        scene.add(ground);
        
        var gridHelper = new THREE.GridHelper(80, 80, 0x1a2a4a, 0x1a2a4a);
        gridHelper.position.y = 0.01;
        scene.add(gridHelper);
        
        for (var i = -35; i <= 35; i += 10) {
            for (var j = -35; j <= 35; j += 10) {
                var grassGeometry = new THREE.CylinderGeometry(0.3, 0.2, 0.5, 8);
                var grassMaterial = new THREE.MeshStandardMaterial({color: 0x1a472a});
                var grass = new THREE.Mesh(grassGeometry, grassMaterial);
                grass.position.set(i + (Math.random() - 0.5) * 2, 0.25, j + (Math.random() - 0.5) * 2);
                grass.scale.y = 0.5 + Math.random() * 0.5;
                grass.castShadow = true;
                scene.add(grass);
            }
        }
    }
    
    function createCampus() {
        createBuilding(-8, 0, -5, 6, 12, 8, '#006688', '图书馆');
        createBuilding(8, 0, -5, 5, 10, 7, '#448866', '科学楼');
        createBuilding(0, 0, 8, 7, 8, 9, '#664488', '教学楼');
        createBuilding(-12, 0, 8, 5, 6, 6, '#886644', '体育馆');
        createBuilding(12, 0, 8, 4, 7, 5, '#884466', '艺术中心');
        
        createTower(0, 0, 0, 2, 18, 2, '#00f2ff');
        
        createWalkways();
        createTrees();
    }
    
    function createBuilding(x, z, y, width, height, depth, color, name) {
        var geometry = new THREE.BoxGeometry(width, height, depth);
        var material = new THREE.MeshStandardMaterial({
            color: color,
            roughness: 0.7,
            metalness: 0.3
        });
        var building = new THREE.Mesh(geometry, material);
        building.position.set(x, height / 2, z);
        building.castShadow = true;
        building.receiveShadow = true;
        building.userData = {name: name};
        buildings.push(building);
        scene.add(building);
        
        var windowMaterial = new THREE.MeshStandardMaterial({
            color: 0x00f2ff,
            emissive: 0x0066aa,
            transparent: true,
            opacity: 0.8
        });
        
        for (var wy = 1; wy < height - 1; wy += 2) {
            for (var wx = -width/2 + 1; wx < width/2 - 1; wx += 1.5) {
                var windowGeometry = new THREE.BoxGeometry(0.6, 1, 0.1);
                var windowMesh = new THREE.Mesh(windowGeometry, windowMaterial);
                windowMesh.position.set(x + wx, wy, z + depth/2 + 0.05);
                windowMesh.castShadow = true;
                scene.add(windowMesh);
                
                var windowMesh2 = new THREE.Mesh(windowGeometry, windowMaterial);
                windowMesh2.position.set(x + wx, wy, z - depth/2 - 0.05);
                windowMesh2.castShadow = true;
                scene.add(windowMesh2);
            }
        }
        
        var roofGeometry = new THREE.BoxGeometry(width + 0.2, 0.5, depth + 0.2);
        var roofMaterial = new THREE.MeshStandardMaterial({color: 0x2a2a4a});
        var roof = new THREE.Mesh(roofGeometry, roofMaterial);
        roof.position.set(x, height / 2 + 0.25, z);
        roof.castShadow = true;
        scene.add(roof);
    }
    
    function createTower(x, z, y, width, height, depth, color) {
        var towerGeometry = new THREE.CylinderGeometry(width, width * 0.8, height, 16);
        var towerMaterial = new THREE.MeshStandardMaterial({
            color: color,
            roughness: 0.3,
            metalness: 0.8,
            emissive: 0x0066aa,
            emissiveIntensity: 0.2
        });
        var tower = new THREE.Mesh(towerGeometry, towerMaterial);
        tower.position.set(x, height / 2 + y, z);
        tower.castShadow = true;
        scene.add(tower);
        
        var topGeometry = new THREE.CylinderGeometry(width * 0.4, 0, 2, 8);
        var topMaterial = new THREE.MeshStandardMaterial({
            color: 0xffffff,
            emissive: 0xffffaa,
            emissiveIntensity: 0.8
        });
        var top = new THREE.Mesh(topGeometry, topMaterial);
        top.position.set(x, height + y + 1, z);
        scene.add(top);
    }
    
    function createWalkways() {
        var walkwayMaterial = new THREE.MeshStandardMaterial({
            color: 0x3a3a4a,
            roughness: 0.9,
            metalness: 0.1
        });
        
        var paths = [
            {x: -15, z: 0, w: 2, l: 30},
            {x: 0, z: -15, w: 2, l: 30},
            {x: 5, z: 0, w: 1.5, l: 25},
            {x: 0, z: 5, w: 1.5, l: 25}
        ];
        
        paths.forEach(function(path) {
            var geometry = new THREE.BoxGeometry(path.l, 0.1, path.w);
            var walkway = new THREE.Mesh(geometry, walkwayMaterial);
            walkway.position.set(path.x, 0.05, path.z);
            walkway.receiveShadow = true;
            scene.add(walkway);
        });
    }
    
    function createTrees() {
        var treePositions = [
            [-15, -15], [-15, 15], [15, -15], [15, 15],
            [-10, -8], [-10, 8], [10, -8], [10, 8],
            [-5, -12], [-5, 12], [5, -12], [5, 12]
        ];
        
        treePositions.forEach(function(pos) {
            var trunkGeometry = new THREE.CylinderGeometry(0.3, 0.4, 3, 8);
            var trunkMaterial = new THREE.MeshStandardMaterial({color: 0x5a3d2b});
            var trunk = new THREE.Mesh(trunkGeometry, trunkMaterial);
            trunk.position.set(pos[0], 1.5, pos[1]);
            trunk.castShadow = true;
            scene.add(trunk);
            
            var foliageGeometry = new THREE.SphereGeometry(2.5, 16, 16);
            var foliageMaterial = new THREE.MeshStandardMaterial({
                color: 0x2d5a27,
                roughness: 0.8,
                metalness: 0.1
            });
            var foliage = new THREE.Mesh(foliageGeometry, foliageMaterial);
            foliage.position.set(pos[0], 5, pos[1]);
            foliage.castShadow = true;
            scene.add(foliage);
            
            var foliageTopGeometry = new THREE.SphereGeometry(1.5, 12, 12);
            var foliageTop = new THREE.Mesh(foliageTopGeometry, foliageMaterial);
            foliageTop.position.set(pos[0], 7.5, pos[1]);
            foliageTop.castShadow = true;
            scene.add(foliageTop);
        });
    }
    
    function animate() {
        requestAnimationFrame(animate);
        
        var time = performance.now() * 0.001;
        fpsCount++;
        if (time - fpsTime >= 1) {
            document.getElementById('fps').textContent = fpsCount;
            fpsCount = 0;
            fpsTime = time;
        }
        
        lights.forEach(function(light, index) {
            if (light instanceof THREE.PointLight) {
                light.intensity = 0.6 + Math.sin(time * 2 + index) * 0.2;
            }
        });
        
        buildings.forEach(function(building) {
            building.rotation.y += isAutoRotate ? 0.002 : 0;
        });
        
        controls.update();
        renderer.render(scene, camera);
    }
    
    function onWindowResize() {
        var container = document.getElementById('canvas3d').parentElement;
        camera.aspect = container.clientWidth / container.clientHeight;
        camera.updateProjectionMatrix();
        renderer.setSize(container.clientWidth, container.clientHeight);
    }
    
    function resetCamera() {
        camera.position.set(15, 12, 15);
        controls.target.set(0, 5, 0);
        controls.update();
    }
    
    function toggleAutoRotate() {
        isAutoRotate = !isAutoRotate;
    }
    
    function toggleFullscreen() {
        var canvas = document.getElementById('canvas3d');
        if (!document.fullscreenElement) {
            canvas.requestFullscreen();
        } else {
            document.exitFullscreen();
        }
    }
    
    function loadScene(sceneKey) {
        document.getElementById('currentScene').textContent = sceneKey;
        resetCamera();
    }
    
    document.addEventListener('DOMContentLoaded', function() {
        init3D();
        
        document.querySelectorAll('.scene-btn').forEach(function(btn) {
            btn.addEventListener('click', function() {
                document.querySelectorAll('.scene-btn').forEach(function(b) { b.classList.remove('active'); });
                this.classList.add('active');
                var sceneKey = this.getAttribute('data-scene');
                loadScene(sceneKey);
            });
        });
        
        document.getElementById('enterSceneBtn').addEventListener('click', function() {
            location.href = window.CONTEXT_PATH + '/campusTour';
        });
        
        var actionRoutes = {avatar:'/avatar', classroom:'/virtualClassroom', lab:'/virtualLab', workshop:'/creativeWorkshop'};
        document.querySelectorAll('.feature-action').forEach(function(btn) {
            btn.addEventListener('click', function() {
                var action = this.getAttribute('data-action');
                var route = actionRoutes[action];
                if (route) location.href = window.CONTEXT_PATH + route;
                else alert('功能开发中');
            });
        });
        
        setInterval(function() {
            fetch(window.CONTEXT_PATH + '/stats?module=campus3d')
                .then(function(r){return r.json();})
                .then(function(d){
                    if(d.onlineUsers !== undefined) document.getElementById('onlineUsers').textContent = d.onlineUsers;
                })
                .catch(function(){});
        }, 30000);
    });
    </script>
<script>
// ══════════ 主题同步 ══════════
(function(){var t='quantum-matrix';try{if(window.parent&&window.parent!==window){var pt=window.parent.document.documentElement.getAttribute('data-theme');if(pt)t=pt;}}catch(e){}var s=localStorage.getItem('boya-theme');if(s)t=s;document.documentElement.setAttribute('data-theme',t);var l=document.createElement('link');l.rel='stylesheet';l.id='boya-light-css';l.href='<%= request.getContextPath() %>/CSS/sub-pages-light.css';document.head.appendChild(l);window.addEventListener('message',function(e){if(e.data&&e.data.type==='themeChange'&&e.data.theme){document.documentElement.setAttribute('data-theme',e.data.theme);localStorage.setItem('boya-theme',e.data.theme);}});})();
</script>
</body>
</html>