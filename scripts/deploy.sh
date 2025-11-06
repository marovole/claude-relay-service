#!/bin/bash

set -e

echo "==========================================";
echo "Claude Relay Service 部署脚本"
echo "==========================================";
echo ""

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

PROJECT_DIR="/opt/claude-relay-service"
DOCKER_USERNAME="${DOCKER_USERNAME:-marovole}"
IMAGE_NAME="$DOCKER_USERNAME/claude-relay-service:latest"

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

# 步骤 2: 更新 docker-compose.yml 中的镜像名称
echo -e "${YELLOW}2️⃣ 配置镜像信息...${NC}"
# 替换镜像名称为从 Docker Hub 拉取
sed -i.bak "s|image: .*claude-relay-service:.*|image: $IMAGE_NAME|g" docker-compose.yml
echo -e "${GREEN}✅ 镜像配置已更新: $IMAGE_NAME${NC}"
echo ""

# 步骤 3: 验证 .env 文件
echo -e "${YELLOW}3️⃣ 检查 .env 文件...${NC}"
if [ -f ".env" ]; then
    echo -e "${GREEN}✅ .env 文件已存在${NC}"
    echo "📋 当前 .env 内容："
    cat .env | grep -E "ADMIN_USERNAME|ADMIN_PASSWORD" || echo "   (未找到管理员凭证)"
else
    echo -e "${RED}❌ .env 文件不存在，创建默认配置...${NC}"
    cat > .env << 'EOF'
ADMIN_USERNAME=admin
ADMIN_PASSWORD=admin123456
EOF
    echo -e "${GREEN}✅ 已创建 .env 文件${NC}"
    echo "   用户名: admin"
    echo "   密码:   admin123456"
fi
echo ""

# 步骤 4: 删除旧的 init.json（清除旧凭证）
echo -e "${YELLOW}4️⃣ 清除旧凭证...${NC}"
if [ -f "data/init.json" ]; then
    rm -f data/init.json
    echo -e "${GREEN}✅ init.json 已删除${NC}"
else
    echo -e "${YELLOW}⚠️  init.json 不存在，跳过${NC}"
fi
echo ""

# 步骤 5: 停止现有容器
echo -e "${YELLOW}5️⃣ 停止现有容器...${NC}"
docker-compose down
echo -e "${GREEN}✅ 容器已停止${NC}"
echo ""

# 步骤 6: 拉取最新镜像
echo -e "${YELLOW}6️⃣ 拉取最新 Docker 镜像...${NC}"
docker pull "$IMAGE_NAME"
echo -e "${GREEN}✅ 镜像已拉取${NC}"
echo ""

# 步骤 7: 启动容器
echo -e "${YELLOW}7️⃣ 启动容器...${NC}"
docker-compose up -d
echo -e "${GREEN}✅ 容器已启动${NC}"
echo ""

# 步骤 8: 等待容器完全启动
echo -e "${YELLOW}8️⃣ 等待容器启动完成...${NC}"
sleep 5

# 步骤 9: 验证容器状态
echo -e "${YELLOW}9️⃣ 验证容器状态...${NC}"
docker-compose ps
echo ""

# 步骤 10: 显示日志
echo -e "${YELLOW}🔟 显示启动日志（最后30行）...${NC}"
docker-compose logs --tail=30
echo ""

echo -e "${GREEN}==========================================";
echo "✅ 部署完成！";
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
    ADMIN_PASS=$(grep ADMIN_PASSWORD .env | cut -d= -f2)
    echo "   用户名: $ADMIN_USER"
    echo "   密码:   $ADMIN_PASS"
else
    echo "   用户名: admin"
    echo "   密码:   admin123456"
fi
echo ""
echo -e "${YELLOW}💡 如需查看实时日志：${NC}"
echo "   docker-compose logs -f"
echo ""
echo -e "${YELLOW}📝 更新镜像用户名（可选）：${NC}"
echo "   export DOCKER_USERNAME=your-username && bash scripts/deploy.sh"
echo ""
