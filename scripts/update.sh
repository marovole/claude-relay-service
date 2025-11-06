#!/bin/bash

set -e

echo "==========================================";
echo "Claude Relay Service 更新脚本"
echo "==========================================";
echo ""

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

PROJECT_DIR="/opt/claude-relay-service"
IMAGE_NAME="marovole/claude-relay-service:latest"

# 检查项目目录
if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${RED}❌ 错误：项目目录 $PROJECT_DIR 不存在${NC}"
    exit 1
fi

cd "$PROJECT_DIR"

echo -e "${YELLOW}📍 进入项目目录: $PROJECT_DIR${NC}"
echo ""

# 步骤 1: 拉取最新代码
echo -e "${YELLOW}1️⃣ 拉取最新代码...${NC}"
git pull origin main
echo -e "${GREEN}✅ 代码已更新${NC}"
echo ""

# 步骤 2: 检查 Dockerfile 是否存在
if [ ! -f "Dockerfile" ]; then
    echo -e "${RED}❌ 错误：找不到 Dockerfile${NC}"
    exit 1
fi

echo -e "${YELLOW}2️⃣ 停止现有容器...${NC}"
docker-compose down
echo -e "${GREEN}✅ 容器已停止${NC}"
echo ""

# 步骤 3: 构建新的 Docker 镜像
echo -e "${YELLOW}3️⃣ 构建新的 Docker 镜像: $IMAGE_NAME${NC}"
docker build -t "$IMAGE_NAME" .
echo -e "${GREEN}✅ 镜像构建完成${NC}"
echo ""

# 步骤 4: 备份原 docker-compose.yml
echo -e "${YELLOW}4️⃣ 备份原 docker-compose.yml...${NC}"
if [ -f "docker-compose.yml" ]; then
    cp docker-compose.yml docker-compose.yml.bak.$(date +%Y%m%d_%H%M%S)
    echo -e "${GREEN}✅ 备份完成${NC}"
fi
echo ""

# 步骤 5: 更新 docker-compose.yml 中的镜像名称
echo -e "${YELLOW}5️⃣ 更新 docker-compose.yml 中的镜像名称...${NC}"
sed -i.bak "s|image: weishaw/claude-relay-service:latest|image: $IMAGE_NAME|g" docker-compose.yml
echo -e "${GREEN}✅ docker-compose.yml 已更新${NC}"
echo ""

# 步骤 6: 删除旧的 init.json（清除旧凭证）
echo -e "${YELLOW}6️⃣ 删除旧的初始化文件...${NC}"
if [ -f "data/init.json" ]; then
    rm -f data/init.json
    echo -e "${GREEN}✅ init.json 已删除${NC}"
else
    echo -e "${YELLOW}⚠️  init.json 不存在，跳过${NC}"
fi
echo ""

# 步骤 7: 验证 .env 文件
echo -e "${YELLOW}7️⃣ 检查 .env 文件...${NC}"
if [ -f ".env" ]; then
    echo -e "${GREEN}✅ .env 文件已存在${NC}"
    echo "📋 当前 .env 内容："
    cat .env | grep -E "ADMIN_USERNAME|ADMIN_PASSWORD"
else
    echo -e "${YELLOW}⚠️  .env 文件不存在，将使用默认凭证${NC}"
fi
echo ""

# 步骤 8: 启动容器
echo -e "${YELLOW}8️⃣ 启动容器...${NC}"
docker-compose up -d
echo -e "${GREEN}✅ 容器已启动${NC}"
echo ""

# 步骤 9: 等待容器完全启动
echo -e "${YELLOW}9️⃣ 等待容器启动完成...${NC}"
sleep 5

# 步骤 10: 验证容器状态
echo -e "${YELLOW}🔟 验证容器状态...${NC}"
docker-compose ps
echo ""

# 步骤 11: 显示日志
echo -e "${YELLOW}1️⃣1️⃣ 显示启动日志（最后50行）...${NC}"
docker-compose logs --tail=50
echo ""

echo -e "${GREEN}==========================================";
echo "✅ 更新完成！";
echo "==========================================";
echo ""
echo -e "${YELLOW}📌 重要信息：${NC}"
echo "   管理后台地址: http://your-ip:3000/admin-next/"
echo "   API 端点:     http://your-ip:3000/api/v1/messages"
echo "   健康检查:     http://your-ip:3000/health"
echo ""
echo -e "${YELLOW}📋 登录凭证：${NC}"
if [ -f ".env" ]; then
    ADMIN_USER=$(grep ADMIN_USERNAME .env | cut -d= -f2)
    echo "   用户名: $ADMIN_USER"
    echo "   密码:   (在 .env 文件中设置)"
else
    echo "   用户名: admin"
    echo "   密码:   admin123456"
fi
echo ""
echo -e "${YELLOW}💡 如需查看实时日志：${NC}"
echo "   docker-compose logs -f"
echo ""
