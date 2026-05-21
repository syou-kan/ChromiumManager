# === 1. 编译前端 ===
FROM node:20-alpine AS nodebuilder
WORKDIR /app
# 修复 pnpm 报错：只拷贝 package.json，不强求 lock 文件
COPY package.json ./
RUN npm install -g pnpm && pnpm install
COPY . .
# 如果前端目录不在根目录，请进入对应目录，例如 RUN cd web && pnpm build
RUN pnpm build

# === 2. 编译后端 ===
FROM golang:1.22-alpine AS gobuilder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o chromium-manager .

# === 3. 最终运行环境 ===
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /app

# 安装 Chromium 运行所需的动态链接库 (不装 xz-utils 了，因为不用解压了)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates libnss3 libnspr4 libatk1.0-0 libatk-bridge2.0-0 \
    libcups2 libdrm2 libxkbcommon0 libxcomposite1 libxdamage1 \
    libxext6 libxfixes3 libxrandr2 libgbm1 libasound2 \
    libpango-1.0-0 libpangocairo-1.0-0 fonts-liberation \
    libx11-6 libx11-xcb1 libxcb1 \
    && rm -rf /var/lib/apt/lists/*

# 【核心修复】：直接把 GitHub Actions 里解压好的文件夹拷贝进来！
COPY chromium-bin /opt/chromium
ENV PATH="/opt/chromium:${PATH}"

# 拷贝前后端产物
COPY --from=nodebuilder /app/dist /app/dist
COPY --from=gobuilder /app/chromium-manager /app/chromium-manager

EXPOSE 3001

ENTRYPOINT ["/app/chromium-manager"]
