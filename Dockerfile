# =========================================================
# 阶段一：编译前端 (Vite + Vue3)
# =========================================================
FROM node:20-alpine AS nodebuilder
WORKDIR /app
COPY . .
# 如果项目没有在根目录下，可能需要 cd 到前端目录，如 RUN cd frontend && pnpm build
RUN npm install -g pnpm && \
    pnpm install --frozen-lockfile && \
    pnpm build

# =========================================================
# 阶段二：编译后端 (Go)
# =========================================================
FROM golang:1.22-alpine AS gobuilder
WORKDIR /app
COPY . .
# 编译 Go 静态程序
RUN CGO_ENABLED=0 GOOS=linux go build -o chromium-manager .

# =========================================================
# 阶段三：最终运行环境 (stage-2)
# =========================================================
FROM ubuntu:22.04

# 声明平台架构变量（由 Buildx 自动注入）
ARG TARGETARCH

# 设置环境变量，避免 apt 安装时出现交互提示
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /app

# 1. 关键修复步骤：安装解压 chromium 的核心依赖 xz-utils，以及 chromium 运行所需的系统动态库
RUN apt-get update && apt-get install -y --no-install-recommends \
    xz-utils \
    ca-certificates \
    libnss3 \
    libnspr4 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    librandr2 \
    libgbm1 \
    libasound2 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    && rm -rf /var/lib/apt/lists/*

# 2. 拷贝并解压 Chromium（根据您提供报错行修改）
COPY ungoogled-chromium-*-${TARGETARCH}_linux.tar.xz /tmp/
RUN mkdir -p /opt/chromium && \
    tar xf /tmp/ungoogled-chromium-*-${TARGETARCH}_linux.tar.xz --strip-components=1 -C /opt/chromium && \
    rm -f /tmp/ungoogled-chromium-*.tar.xz

# 将 chromium 放入系统环境变量中
ENV PATH="/opt/chromium:${PATH}"

# 3. 拷贝前端和后端的可执行文件
COPY --from=gobuilder /app/chromium-manager /app/chromium-manager
COPY --from=nodebuilder /app/dist /app/dist

# 暴露服务端口
EXPOSE 3001

# 启动程序
ENTRYPOINT ["/app/chromium-manager"]
