# Paperclip Full Setup by Sistema Britto

Setup funcional para rodar Paperclip + Hermes local + Docker com imagem publicada no Docker Hub.

## Imagem

docker pull sistemabritto/paperclip-full-setup:latest

## Objetivo

Este setup foi ajustado para resolver, na prática, problemas comuns ao usar o adapter Hermes local com Paperclip, incluindo:
- prompt default induzindo padrões inseguros
- bloqueios em comandos com pipe
- inconsistências com HERMES_HOME
- necessidade de persistir patches no build da imagem
- dificuldade de reproduzir um ambiente funcional completo

## Rodando com Docker

Exemplo rápido:

docker run -d \
  --name paperclip \
  -p 3100:3100 \
  -e NODE_ENV=production \
  -e HOME=/paperclip \
  -e HOST=0.0.0.0 \
  -e PORT=3100 \
  -e SERVE_UI=true \
  -e PAPERCLIP_HOME=/paperclip \
  -e PAPERCLIP_INSTANCE_ID=default \
  -e PAPERCLIP_CONFIG=/paperclip/instances/default/config.json \
  -e PAPERCLIP_DEPLOYMENT_MODE=authenticated \
  -e PAPERCLIP_DEPLOYMENT_EXPOSURE=private \
  -v paperclip_data:/paperclip \
  sistemabritto/paperclip-full-setup:latest

## Observações

- Para testar mudanças no adapter Hermes, prefira criar um agente novo.
- Se houver erro 429, o gargalo pode estar no provider/modelo e não no adapter.
- Se usar Prompt Template customizado na UI, use placeholders compatíveis com o adapter:
  - {{agentName}}
  - {{agentId}}
  - {{companyId}}
  - {{paperclipApiUrl}}
  - {{taskId}}
  - {{taskTitle}}
  - {{taskBody}}

## Docker Hub

sistemabritto/paperclip-full-setup:latest
