# paperclip-full-setup

Setup prático para rodar Paperclip + Hermes local + Docker com foco em estabilidade operacional.

## Objetivo

Este repositório documenta um setup funcional para rodar:
- Paperclip como control plane
- Hermes local (hermes_local) como adapter
- Docker em VPS
- coordenação visual no Paperclip
- tasks/issues/heartbeats funcionando

## Problemas que este setup ajuda a superar

Durante a implementação, apareceram dificuldades práticas como:
- DEFAULT_PROMPT_TEMPLATE do adapter induzindo uso de comandos inseguros
- padrões como curl | python3 -c sendo bloqueados pelo scanner do Hermes
- HERMES_HOME malformado via UI
- diferença entre config válida em /paperclip/.hermes/config.yaml e comportamento do adapter no Paperclip
- necessidade de build custom da imagem para persistir patches úteis

## O que este template faz

- usa imagem custom do Paperclip
- instala Hermes local
- persiste /paperclip/.hermes
- documenta envs mínimos
- inclui exemplo de compose
- inclui pipeline para publicar imagem no Docker Hub

## Como usar

1. Clone este repositório.
2. Copie .env.example para .env.
3. Ajuste domínio, secrets, banco e paths.
4. Build ou puxe a imagem do Docker Hub.
5. Suba com Docker Compose ou adapte para Docker Swarm.

## Exemplo de pull da imagem

docker pull sistemabritto/paperclip-full-setup:latest

## Exemplo de uso com compose

docker compose --env-file .env -f docker-compose.example.yml up -d

## Observações importantes

- Agentes antigos podem reter config/template ruim. Para validar mudanças, prefira criar um agente novo.
- Quando usar Prompt Template na UI, use placeholders esperados pelo adapter:
  - {{agentName}}
  - {{agentId}}
  - {{companyId}}
  - {{paperclipApiUrl}}
  - {{taskId}}
  - {{taskTitle}}
  - {{taskBody}}
- Não dependa de HERMES_HOME pela UI se isso estiver sendo serializado errado.
- Se o modelo/provider der 429, o adapter pode estar ok e o gargalo ser o endpoint do modelo.
