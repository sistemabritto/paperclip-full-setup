#!/bin/bash
# Fix Traefik labels for services that need port exposure

echo "🔧 Corrigindo labels Traefik..."
echo ""

# Portainer
echo "📊 Portainer..."
docker service update portainer_portainer \
  --label-add "traefik.enable=true" \
  --label-add "traefik.http.routers.portainer.rule=Host(\`portainer.workflowapi.com.br\`)" \
  --label-add "traefik.http.routers.portainer.entrypoints=websecure" \
  --label-add "traefik.http.routers.portainer.tls.certresolver=letsencrypt" \
  --label-add "traefik.http.services.portainer.loadbalancer.server.port=9000" \
  --label-add "traefik.http.routers.portainer.service=portainer"

echo "✅ Portainer atualizado"
echo ""

# Verificar se Paperclip está ok
echo "📋 Paperclip..."
docker service inspect paperclip_paperclip --pretty | grep -A 30 "Labels"
echo ""

echo "🎯 Testar acessos:"
echo "Portainer: curl http://localhost:9000"
echo "Paperclip: curl http://localhost:3100/api/health"
