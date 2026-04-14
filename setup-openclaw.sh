#!/bin/bash
# Paperclip + OpenClaw Integration Setup (PostgreSQL externo)
# Felipe Britto - Sistema Britto

set -e

echo "🎯 Paperclip + OpenClaw Integration Setup"
echo "=========================================="
echo ""

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funções
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Verificar se está no diretório correto
if [ ! -f "package.json" ]; then
    log_error "Paperclip package.json not found. Run this from /workspace/paperclip"
    exit 1
fi

log_info "Paperclip repository found ✅"

# Verificar Docker
if ! command -v docker &> /dev/null; then
    log_error "Docker not found. Please install Docker first."
    exit 1
fi

log_info "Docker found ✅"

# Verificar PostgreSQL
log_step "Verificando PostgreSQL..."
if ! docker ps | grep -q "postgres_postgres"; then
    log_warn "PostgreSQL service não encontrado!"
    echo "   Verifique se postgres_postgres está rodando:"
    echo "   docker service ls | grep postgres"
    exit 1
fi

log_info "PostgreSQL encontrado ✅"

# Criar database Paperclip
log_step "Criando database Paperclip..."
chmod +x create-db.sh
./create-db.sh

# Criar .env se não existir
if [ ! -f ".env" ]; then
    log_step "Criando arquivo .env..."
    
    # Gerar BETTER_AUTH_SECRET
    SECRET=$(openssl rand -base64 32)
    
    # Pedir senha do PostgreSQL
    echo ""
    read -sp "Digite a senha do PostgreSQL (ou ENTER para usar 'postgres'): " POSTGRES_PASS
    echo ""
    if [ -z "$POSTGRES_PASS" ]; then
        POSTGRES_PASS="postgres"
    fi
    
    cat > .env <<EOF
# Paperclip Environment
BETTER_AUTH_SECRET=$SECRET
PAPERCLIP_DEPLOYMENT_MODE=authenticated
PAPERCLIP_DEPLOYMENT_EXPOSURE=private
PAPERCLIP_PUBLIC_URL=https://paperclip.workflowapi.com.br

# PostgreSQL
POSTGRES_PASSWORD=$POSTGRES_PASS
DATABASE_URL=postgresql://postgres:$POSTGRES_PASS@postgres_postgres:5432/paperclip

# API Keys (opcional - configure conforme necessário)
# OPENAI_API_KEY=sk-...
# ANTHROPIC_API_KEY=sk-ant-...

# OpenClaw Integration
OPENCLAW_AGENT_NAME=Hagamenon
OPENCLAW_WEBHOOK_URL=http://openclaw-gateway:8080/webhook
OPENCLAW_WEBHOOK_AUTH=Bearer 857853cececf70b53f53289e9655a132aaef6b5082c8b049

# Paperclip Port
PAPERCLIP_PORT=3100

# Data Directory
PAPERCLIP_DATA_DIR=./data/docker-paperclip
EOF
    
    log_info "✅ .env file created"
else
    log_info ".env file already exists ✅"
    log_warn "Review .env and ensure POSTGRES_PASSWORD is set correctly"
fi

# Criar diretório de dados
mkdir -p data/docker-paperclip
log_info "Data directory created ✅"

# Perguntar se quer fazer deploy agora
echo ""
read -p "Deploy Paperclip to Docker Swarm now? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    log_step "Buildando imagem Docker (pode demorar)..."
    
    # Buildar imagem primeiro (Swarm não suporta build)
    docker build -t paperclip-local:latest -f Dockerfile . 2>&1 | grep -E "(Step|Successfully|ERROR|failed)" || true
    
    if [ ${PIPESTATUS[0]} -ne 0 ]; then
        log_error "❌ Docker build failed. Check full logs above."
        exit 1
    fi
    
    log_info "✅ Docker image built successfully"
    
    log_step "Deploying Paperclip stack..."
    
    # Remover stack antiga se existir
    docker stack rm paperclip 2>/dev/null || true
    sleep 2
    
    # Fazer deploy
    docker stack deploy -c docker-compose.yml paperclip
    
    if [ $? -eq 0 ]; then
        log_info "✅ Paperclip deployed successfully!"
        echo ""
        echo -e "${BLUE}🎯 Next Steps:${NC}"
        echo "1. Wait for Paperclip to start (≈30s):"
        echo "   docker service ls | grep paperclip"
        echo ""
        echo "2. Check logs:"
        echo "   docker service logs -f paperclip_paperclip"
        echo ""
        echo "3. Verify health:"
        echo "   curl http://localhost:3100/api/health"
        echo ""
        echo "4. Access dashboard:"
        echo "   https://paperclip.workflowapi.com.br"
        echo ""
        echo -e "${YELLOW}⚠️  First time setup:${NC}"
        echo "   - Create company (ex: 'Sistema Britto')"
        echo "   - Add agents (Hagamenon, etc)"
        echo "   - Configure goals and budgets"
        echo ""
    else
        log_error "❌ Deploy failed. Check logs above."
        exit 1
    fi
else
    log_info "Skipping deploy. Run manually when ready:"
    echo ""
    echo "  docker build -t paperclip-local:latest -f Dockerfile ."
    echo "  docker stack deploy -c docker-compose.yml paperclip"
fi

echo ""
log_info "Setup complete! 🎉"
echo ""
echo "📖 Documentation: /workspace/paperclip/INTEGRACAO_OPENCLAW.md"
