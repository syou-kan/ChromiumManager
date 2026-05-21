# =========================================================
# 阶段一：编译前端 (Vite + Vue3)
# =========================================================
FROM node:20-alpine AS nodebuilder
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
# ✅ 先单独安装依赖，利用 Docker 缓存层，代码改动不会重新 install
RUN npm install -g pnpm && pnpm install --frozen-lockfile
COPY . .
RUN pnpm build

# =========================================================
# 阶段二：编译后端 (Go)
# =========================================================
FROM golang:1.22-alpine AS gobuilder
WORKDIR /app
COPY go.mod go.sum ./
# ✅ 同上，先缓存依赖
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -o chromium-manager .

# =========================================================
# 阶段三：最终运行环境
# =========================================================
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /app

# 安装 Chromium 运行时依赖（不再需要 xz-utils）
RUN apt-get update && apt-get install -y --no-install-recommends \
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
    libxrandr2 \
    libgbm1 \
    libasound2 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    fonts-liberation \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    && rm -rf /var/lib/apt/lists/*

# ✅ 直接 COPY 已解压的目录，无需在容器内执行 tar
COPY chromium-bin/ /opt/chromium/

ENV PATH="/opt/chromium:${PATH}"

COPY --from=gobuilder /app/chromium-manager /app/chromium-manager
COPY --from=nodebuilder /app/dist /app/dist

EXPOSE 3001

ENTRYPOINT ["/app/chromium-manager"]
