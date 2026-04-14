# Paperclip + OpenClaw Integration

## 🎯 O Que É?

**Paperclip** = Orquestrador de empresas AI (gestão de times de agentes)
**OpenClaw** = Agente AI individual (empregado)

Juntos: **Empresa AI autônoma completa** ♞

## 🏗️ Arquitetura

```
┌─────────────────────────────────────────────────────┐
│                   Paperclip Dashboard                │
│  (org charts, metas, orçamentos, tickets)           │
└─────────────────────────────────────────────────────┘
                         │
                         │ webhooks / heartbeats
                         ▼
┌─────────────────────────────────────────────────────┐
│              OpenClaw Gateway (OpenClaw)             │
│  (gerencia canais, sessões, agentes)                │
└─────────────────────────────────────────────────────┘
                         │
                         │ spawns sub-agent
                         ▼
┌─────────────────────────────────────────────────────┐
│           Hagamenon (Business Co-pilot)              │
│  (executa tarefas, reporta progresso)                │
└─────────────────────────────────────────────────────┘
```

## 🚀 Deploy no Docker Swarm

### 1. Gerar Secrets

```bash
# Gerar BETTER_AUTH_SECRET
openssl rand -base64 32

# Salvar no .env
echo "BETTER_AUTH_SECRET=<generated-secret>" >> /workspace/paperclip/.env
```

### 2. Configurar Domínio

Adicionar ao Traefik:
- **paperclip.workflowapi.com.br** → Paperclip Dashboard

### 3. Deploy

```bash
cd /workspace/paperclip
docker stack deploy -c docker-compose.yml paperclip
```

### 4. Acessar

- **Dashboard:** https://paperclip.workflowapi.com.br
- **API:** http://localhost:3100 (local)

## 🔧 Integração com OpenClaw

### Configurar Webhook no OpenClaw

No OpenClaw Gateway, adicionar webhook:

```bash
# Via Telegram ou config
/webhook add https://paperclip.workflowapi.com.br/api/webhooks/openclaw
```

### Criar Agente no Paperclip

1. Acessar dashboard: https://paperclip.workflowapi.com.br
2. Criar nova empresa (ex: "Sistema Britto")
3. Adicionar agente "Hagamenon" com:
   - **Tipo:** OpenClaw Gateway
   - **Webhook URL:** http://openclaw-gateway:8080/webhook
   - **Auth:** Bearer 857853cececf70b53f53289e9655a132aaef6b5082c8b049

### Configurar Heartbeats

No Paperclip, configurar heartbeat para o Hagamenon:

```bash
# A cada 30 minutos
/schedule add "*/30 * * * *" "heartbeat"
```

## 📊 Fluxo de Trabalho

### 1. Definir Meta

No Paperclip:
- Criar meta: "Expandir Sistema Britto para 5 clientes"
- Definir orçamento: $100/mês
- Atribuir: Hagamenon

### 2. Criar Tarefas

No Paperclip:
- Criar ticket: "Onboarding cliente VGRA"
- Prioridade: Alta
- Deadline: 2026-04-15

### 3. Executar

**Paperclip** → Notifica **OpenClaw** → **Hagamenon** executa
- Hagamenon recebe task do OpenClaw
- Executa trabalho
- Reporta progresso via webhook

### 4. Monitorar

No dashboard Paperclip:
- Ver progresso em tempo real
- Acompanhar custos
- Aprovar/rejeitar work

## 🎯 Benefícios

✅ **Orquestração centralizada** - Gerencia múltiplos agentes AI
✅ **Rastreamento de custos** - Budget por agente/tarefa
✅ **Sessões persistentes** - Contexto preserva entre reboots
✅ **Governança** - Aprovações, audit logs, rollback
✅ **Dashboard mobile** - Gerencia negócio do celular
✅ **Multi-empresa** - Um deployment, múltiplas empresas isoladas

## 🔗 Links Úteis

- **Docs Paperclip:** https://paperclip.ing/docs
- **Discord:** https://discord.gg/m4HZY7xNG3
- **GitHub:** https://github.com/paperclipai/paperclip

---

**Status:** ⚠️ Configurando...
**Última atualização:** 2026-04-02
