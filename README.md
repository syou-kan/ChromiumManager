

### Chromium 浏览器环境管理系统

轻松管理多个独立浏览器环境，支持指纹伪装、代理配置、Cookie导入导出等。

[核心功能](#-核心功能) • [界面导览](#-界面导览) • [技术架构](#-技术架构) • [安装指南](#-安装指南) • [使用说明](#-使用说明)

---

## ✨ 核心功能

### 🖥️ 多配置管理
- **独立环境** — 每个配置完全隔离
- **分组管理** — 按业务场景自由分组
- **实例管理** — 启动/激活/关闭 Chromium 实例

### 🎭 指纹伪装
- **随机指纹种子** — 每个配置生成随机指纹种子，确保环境独立
- **平台伪装** — 自定义操作系统、浏览器品牌等平台信息
- **硬件参数** — 自定义 CPU 核心数、设备内存、屏幕分辨率
- **多维指纹** — Canvas、WebGL、Audio、Font、ClientRects、GPU

### 🌐 代理管理
- **代理配置** — 集中管理代理服务器，HTTP、HTTPS、SOCKS4、SOCKS5代理协议（支持用户名、密码认证）
- **IP/语言/时区关联** — 代理可绑定 IP 地址、语言、时区和位置
- **自动继承** — 配置可自动继承关联代理的语言、时区和位置

### 🍪 Cookie 管理
- **扩展兼容** — 兼容 Cookie Editor、EditThisCookie 导入导出格式
- **自动配置** — 浏览器自动导入、导出 Cookie
- **导入导出** — 支持手动导入、导出 Cookie

---

## 📸 界面导览

![管理界面](docs/images/image.png)

![浏览器实例](docs/images/image2.png)

---

## 🏗️ 技术架构

| 组件 | 技术 |
|------|------|
| 前端 | Vite + Vue3 + Element Plus |
| 后端 | Go |
| 数据库 | SQLite |
| 浏览器 | Ungoogled Chromium |

---

## 📦 安装指南

### Docker Compose

```yaml
services:
  chromium-manager:
    image: tumi/chromium-manager:latest
    container_name: chromium-manager
    shm_size: 1gb
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Asia/Shanghai
      - LC_ALL=zh_CN.UTF-8
    ports:
      - 3001:3001
    volumes:
      - ./config:/config
    restart: unless-stopped
```

```bash
docker compose up -d
```

### Docker CLI

```bash
docker run -d \
  --name chromium-manager \
  --shm-size=1gb \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Asia/Shanghai \
  -e LC_ALL=zh_CN.UTF-8 \
  -p 3001:3001 \
  -v ./config:/config \
  --restart unless-stopped \
  tumi/chromium-manager:latest
```

### 通过以下网址访问应用

* https://yourhost:3001/

---

## 📖 使用说明

### 创建浏览器配置

1. 在左侧面板创建**分组**
2. 在右侧面板添加新**配置**
3. 配置指纹参数
4. 关联代理（可选）
5. **启动**打开浏览器，**激活**切换到前台，**关闭**关闭浏览器

### 代理配置

1. 进入代理管理页面
2. 添加代理服务器
3. 在配置中选择代理

### Cookie 管理

- **手动导入**: 导入 JSON 格式的 Cookie
- **手动导出**: 导出当前配置的 Cookie

---

## 📄 许可证

MIT License
