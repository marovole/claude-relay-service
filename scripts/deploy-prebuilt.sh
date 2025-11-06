#!/bin/bash

# Claude Relay Service 预构建镜像部署脚本
# 使用 Docker Hub 预构建镜像，避免本地编译内存不足问题

set -e

echo "==========================================="
echo "Claude Relay Service 快速部署"
echo "==========================================="
echo ""

PROJECT_DIR="/opt/claude-relay-service"

# 检查项目目录
if [ ! -d "$PROJECT_DIR" ]; then
    echo "❌ 错误：项目目录 $PROJECT_DIR 不存在"
    exit 1
fi

cd "$PROJECT_DIR"

echo "📍 项目目录: $PROJECT_DIR"
echo ""

# 步骤 1: 停止现有容器
echo "1️⃣ 停止现有容器..."
docker-compose down 2>/dev/null || true
echo "✅ 容器已停止"
echo ""

# 步骤 2: 清理旧凭证
echo "2️⃣ 清理旧凭证..."
rm -f data/init.json
echo "✅ init.json 已删除"
echo ""

# 步骤 3: 拉取预构建镜像
echo "3️⃣ 拉取预构建镜像..."
docker-compose pull
echo "✅ 镜像拉取完成"
echo ""

# 步骤 4: 启动容器
echo "4️⃣ 启动容器..."
docker-compose up -d
echo "✅ 容器已启动"
echo ""

# 步骤 5: 等待容器完全启动
echo "5️⃣ 等待容器启动完成..."
sleep 5
echo ""

# 步骤 6: 显示容器状态
echo "6️⃣ 容器状态："
docker-compose ps
echo ""

echo "==========================================="
echo "✅ 部署完成！"
echo "==========================================="
echo ""
echo "📌 管理后台："
echo "   http://your-ip:3000/admin-next/"
echo ""
echo "📋 登录凭证："
if [ -f ".env" ]; then
    ADMIN_USER=$(grep ADMIN_USERNAME .env | cut -d= -f2 2>/dev/null || echo "admin")
    ADMIN_PASS=$(grep ADMIN_PASSWORD .env | cut -d= -f2 2>/dev/null || echo "admin123456")
    echo "   用户名: $ADMIN_USER"
    echo "   密码:   $ADMIN_PASS"
else
    echo "   用户名: admin"
    echo "   密码:   admin123456"
fi
echo ""
echo "💡 查看实时日志："
echo "   docker-compose logs -f"
echo ""
