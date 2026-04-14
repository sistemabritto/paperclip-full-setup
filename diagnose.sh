#!/bin/bash
# Diagnóstico do Traefik e serviços

echo "🔍 Diagnóstico Traefik + Serviços"
echo "=================================="
echo ""

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "📊 1. Serviços rodando:"
docker service ls | grep -E "traefik|paperclip|portainer|mission"
echo ""

echo "🔍 2. Containers ativos:"
docker ps | grep -E "traefik|paperclip|portainer|mission"
echo ""

echo "🌐 3. Testando acesso local:"
echo -n "   Portainer (localhost:9000): "
if curl -s -o /dev/null -w "%{http_code}" http://localhost:9000 | grep -q "200\|302"; then
    echo -e "${GREEN}✓ OK${NC}"
else
    echo -e "${RED}✗ FALHOU${NC}"
fi

echo -n "   Paperclip (localhost:3100): "
if curl -s -o /dev/null -w "%{http_code}" http://localhost:3100 | grep -q "200\|302"; then
    echo -e "${GREEN}✓ OK${NC}"
else
    echo -e "${RED}✗ FALHOU${NC}"
fi

echo -n "   Mission Dash (localhost:3002): "
if curl -s -o /dev/null -w "%{http_code}" http://localhost:3002 | grep -q "200\|302"; then
    echo -e "${GREEN}✓ OK${NC}"
else
    echo -e "${RED}✗ FALHOU${NC}"
fi

echo ""

echo "📋 4. Config Traefik (labels):"
echo "   Portainer:"
docker service inspect portainer_portainer --pretty 2>/dev/null | grep -A 20 "Labels" | grep traefik || echo "   Sem labels Traefik"
echo ""
echo "   Paperclip:"
docker service inspect paperclip_paperclip --pretty 2>/dev/null | grep -A 20 "Labels" | grep traefik || echo "   Sem labels Traefik"
echo ""

echo "📝 5. Logs Traefik (últimas 10 linhas):"
docker service logs traefik_traefik --tail 10 2>&1 | tail -10
echo ""

echo "🌍 6. Domínios configurados:"
echo "   - portainer.workflowapi.com.br"
echo "   - paperclip.workflowapi.com.br"
echo "   - dash.workflowapi.com.br"
echo ""

echo -e "${YELLOW}💡 Dica:${NC} Se tudo responde localmente mas não via domínio:"
echo "   - Verificar DNS (apontando para IP correto?)"
echo "   - Verificar certificados SSL (letsencrypt funcionando?)"
echo "   - Verificar se Cloudflare/Tailscale está interceptando"
